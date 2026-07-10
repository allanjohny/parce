#!/usr/bin/env bash
# graphify-onboard.sh — equip a repo with a typed code graph via graphify (idempotent).
#
# Usage: ./skills/graphify-onboard.sh [repo-path]      (default: current directory)
#
# Requires: uv tool install "graphifyy[mcp]"   (https://pypi.org/project/graphifyy/)
#
# Steps, in order:
#   1. .NET guard-rail: if there are .csproj/.sln files, require bin/ and obj/ in
#      .gitignore (graphify has no ignore list of its own — it relies on gitignore;
#      otherwise it indexes build artifacts).
#   2. graphify update  -> generates graphify-out/graph.json (local AST, incremental, zero LLM).
#   3. merges the 'graphify' server into .mcp.json WITHOUT removing existing servers.
#   4. adds graphify-out/ to .gitignore.
#   5. installs .git/hooks/post-commit (incremental rebuild; never overwrites a foreign hook).
#
# Safe to re-run: nothing is duplicated.
set -euo pipefail

GRAPHIFY="$HOME/.local/bin/graphify"
REPO="${1:-$PWD}"

REPO="$(cd "$REPO" 2>/dev/null && pwd)" || { echo "error: path '$1' does not exist"; exit 1; }
command -v git >/dev/null            || { echo "error: git not found"; exit 1; }
[ -x "$GRAPHIFY" ]                   || { echo "error: graphify not installed ($GRAPHIFY). Run: uv tool install \"graphifyy[mcp]\""; exit 1; }
git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "error: '$REPO' is not a git repo"; exit 1; }
ROOT="$(git -C "$REPO" rev-parse --show-toplevel)"
cd "$ROOT"

echo "== graphify onboard: $ROOT =="

# 1. .NET guard-rail
if find . -maxdepth 4 \( -name node_modules -o -name .git \) -prune -o \( -name '*.csproj' -o -name '*.sln' \) -print 2>/dev/null | grep -q .; then
  for pat in bin obj; do
    if ! grep -qi "${pat}/" .gitignore 2>/dev/null; then
      echo "ABORTED: .NET repo without '${pat}/' in .gitignore -> graphify would index build artifacts."
      echo "  add 'bin/' and 'obj/' to .gitignore and re-run."
      exit 2
    fi
  done
  echo "  .NET guard-rail ok (bin/ obj/ ignored)"
fi

# 2. build the graph
echo "  graphify update…"
"$GRAPHIFY" update "$ROOT" >/dev/null 2>&1 || { echo "graphify update failed"; exit 1; }
[ -f graphify-out/graph.json ] || { echo "error: graph.json not generated"; exit 1; }
NODES="$(python3 -c "import json;print(len(json.load(open('graphify-out/graph.json'))['nodes']))")"
echo "  graph: $NODES nodes"

# 3. .mcp.json — merge the 'graphify' server, preserving the rest
python3 - "$ROOT" <<'PY'
import json, os, sys
root = sys.argv[1]
p = os.path.join(root, ".mcp.json")
data = {}
if os.path.exists(p):
    with open(p) as f:
        data = json.load(f) or {}
servers = data.setdefault("mcpServers", {})
servers["graphify"] = {
    "type": "stdio",
    "command": os.path.expanduser("~/.local/bin/graphify-mcp"),
    "args": [os.path.join(root, "graphify-out", "graph.json")],
}
with open(p, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print("  .mcp.json: server 'graphify' written (%d server(s) total)" % len(servers))
PY

# 4. .gitignore
if ! grep -qxF 'graphify-out/' .gitignore 2>/dev/null; then
  printf '\n# graphify code graph (rebuilt via .git/hooks/post-commit)\ngraphify-out/\n' >> .gitignore
  echo "  .gitignore: graphify-out/ added"
else
  echo "  .gitignore: graphify-out/ already ignored"
fi

# 5. post-commit hook (never overwrite a foreign hook)
HOOK="$(git rev-parse --git-path hooks/post-commit)"
if [ -f "$HOOK" ] && ! grep -q graphify "$HOOK"; then
  echo "  WARNING: a non-graphify .git/hooks/post-commit already exists -> not overwritten. Merge manually if you want automatic rebuilds."
else
  cat > "$HOOK" <<'HK'
#!/bin/sh
# graphify — incremental code-graph rebuild after each commit (graphify-out/ is gitignored).
repo=$(git rev-parse --show-toplevel) || exit 0
changed=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null \
  | grep -Ev '^graphify-out/' \
  | grep -E '\.(cs|ts|tsx|js|mjs|py|go|rs|java|rb|php|md)$')
[ -z "$changed" ] && exit 0
( "$HOME/.local/bin/graphify" update "$repo" >/dev/null 2>&1 & ) >/dev/null 2>&1
exit 0
HK
  chmod +x "$HOOK"
  echo "  post-commit hook installed"
fi

echo "== done. Open the repo in your AI tool and approve the 'graphify' MCP server; commit .mcp.json + .gitignore when ready. =="
