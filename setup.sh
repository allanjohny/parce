#!/usr/bin/env bash
#
# setup.sh — bootstrap your personal AI assistant from this template.
# Idempotent: run it as many times as you like. Re-running lets you rename
# your assistant or change language; your memories are never touched.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$REPO_ROOT/templates/ASSISTANT.template.md"
PROFILE_TEMPLATE="$REPO_ROOT/templates/user_profile.template.md"
ASSISTANT_MD="$REPO_ROOT/ASSISTANT.md"
MEM_DIR="$REPO_ROOT/memory"

say()  { printf '  \033[36m→\033[0m %s\n' "$1"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }

echo ""
echo "🤝 Parce setup — let's build your assistant"
echo ""

# ── 1. the three questions ───────────────────────────────────────────────
default_name="Parce"
read -rp "  1/3 What's your assistant's name? [$default_name] " ASSISTANT_NAME
ASSISTANT_NAME="${ASSISTANT_NAME:-$default_name}"

default_user="$(git config user.name 2>/dev/null || whoami)"
read -rp "  2/3 What's your name? [$default_user] " USER_NAME
USER_NAME="${USER_NAME:-$default_user}"

read -rp "  3/3 What language should $ASSISTANT_NAME speak? [English] " LANGUAGE
LANGUAGE="${LANGUAGE:-English}"

echo ""

# ── 2. generate ASSISTANT.md from template ───────────────────────────────
sed -e "s/{{ASSISTANT_NAME}}/$ASSISTANT_NAME/g" \
    -e "s/{{USER_NAME}}/$USER_NAME/g" \
    -e "s/{{LANGUAGE}}/$LANGUAGE/g" \
    "$TEMPLATE" > "$ASSISTANT_MD"
ok "ASSISTANT.md generated ($ASSISTANT_NAME, speaking $LANGUAGE)"

# ── 3. seed first memory (never overwrite an existing one) ───────────────
if [ ! -f "$MEM_DIR/user_profile.md" ]; then
  sed -e "s/{{ASSISTANT_NAME}}/$ASSISTANT_NAME/g" \
      -e "s/{{USER_NAME}}/$USER_NAME/g" \
      -e "s/{{LANGUAGE}}/$LANGUAGE/g" \
      "$PROFILE_TEMPLATE" > "$MEM_DIR/user_profile.md"
  if ! grep -q 'user_profile.md' "$MEM_DIR/MEMORY.md"; then
    printf -- '- [%s](user_profile.md) — who %s is\n' "$USER_NAME" "$USER_NAME" >> "$MEM_DIR/MEMORY.md"
  fi
  ok "memory/user_profile.md seeded — $ASSISTANT_NAME's first memory is you"
else
  ok "memory/user_profile.md already exists — kept as is"
fi

# ── 4. symlinks: one source of truth, every harness ──────────────────────
ln -sfn "ASSISTANT.md" "$REPO_ROOT/CLAUDE.md"
ok "CLAUDE.md → ASSISTANT.md            (Claude Code)"

ln -sfn "ASSISTANT.md" "$REPO_ROOT/AGENTS.md"
ok "AGENTS.md → ASSISTANT.md            (Cursor, Codex, Zed, most agents)"

mkdir -p "$REPO_ROOT/.github"
ln -sfn "../ASSISTANT.md" "$REPO_ROOT/.github/copilot-instructions.md"
ok ".github/copilot-instructions.md → ASSISTANT.md  (VS Code Copilot)"

# ── 5. optional deps check ───────────────────────────────────────────────
command -v node >/dev/null && ok "node found — brain graph ready (node skills/brain/build-graph.mjs)" \
  || say "node not found — install it to use the brain graph (optional)"

echo ""
echo "🧠 Done. Open this repo in your AI tool and say hi — $ASSISTANT_NAME knows its name."
echo "   Docs: README.md · docs/writing-memories.md · docs/harnesses.md"
echo ""
