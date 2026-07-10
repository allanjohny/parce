---
name: healthcheck
description: Verify the assistant's memory, structure, and harness wiring are all in working order — counts indexed memories, checks rules/ and contexts/ are present, checks whether the knowledge graph is stale, and confirms which harness files are correctly symlinked. Use when the user asks "are you active?", "is your memory loaded?", "healthcheck", "are you working?", or wants a status/diagnostic of the assistant itself.
---

# Healthcheck

A quick, silent self-check of the assistant's setup. Run the checks in parallel, don't narrate them, then report a short status table.

## What to check

**(a) Memory index**

```bash
wc -l memory/MEMORY.md
ls memory/*.md | grep -v -e MEMORY.md -e _template.md | wc -l
```

Confirm `memory/MEMORY.md` exists and is readable. Count entries (lines starting with `- [`) and compare against the number of `.md` files in `memory/` (excluding `MEMORY.md` and `_template.md`) — flag it if the index is missing files or has stale entries pointing at deleted ones.

**(b) Structure present**

```bash
ls rules/ contexts/
```

Confirm both directories exist and are non-empty.

**(c) Graph freshness**

```bash
ls -t memory/*.md | grep -v -e MEMORY.md -e _template.md | head -1 | xargs stat -f "%m %N"
stat -f "%m %N" memory/graph.json 2>/dev/null
```

Compare the newest memory file's mtime against `memory/graph.json`'s mtime. If any memory file is newer than the graph (or `graph.json` doesn't exist yet), report it as stale and suggest:

```bash
node skills/brain/build-graph.mjs
```

**(d) Harness files**

```bash
for f in CLAUDE.md AGENTS.md .github/copilot-instructions.md; do
  if [ -L "$f" ]; then
    echo "$f -> symlink -> $(readlink "$f")"
  elif [ -e "$f" ]; then
    echo "$f -> exists but NOT a symlink"
  else
    echo "$f -> missing"
  fi
done
```

Each of these should exist and be a symlink pointing at `ASSISTANT.md`. Flag any that are missing or that exist as real (non-symlink) files — the latter means edits to them won't propagate to `ASSISTANT.md`.

## Output

Report a short status table, one row per check, then a one-line verdict:

| Check | Status | Detail |
|---|---|---|
| Memory index | OK / gap | N memories indexed, M files on disk |
| rules/ + contexts/ | OK / missing | — |
| Graph freshness | OK / stale | newest memory vs graph.json mtime |
| Harness symlinks | OK / gap | which files are missing or not symlinks |

Verdict: **Active** (all OK), **Partial** (memory + structure OK, something else off), or **Inactive** (memory or structure broken). If something is stale or missing, name the exact fix command instead of just flagging it.
