---
name: brain
description: Rebuild the assistant's memory knowledge graph — generates graph.json, brain.html (navigable mind map) and auto-links related memories. Use after creating or editing memories, or when the user asks to "rebuild the brain" or "show me your brain".
---

# Brain rebuild

Rebuilds the memory knowledge graph: generates `memory/graph.json`, `memory/brain.html` (interactive mind map) and updates the `## Related (auto)` section in each memory `.md` file.

## Usage

```bash
node skills/brain/build-graph.mjs
```

The script resolves the memory directory as: env `MEMORY_DIR` → `<repo>/memory` (relative to the script itself). Portable: runs in any clone with zero config.

## What it does

1. Reads every `*.md` in the memory directory (except `MEMORY.md`, `_template.md`)
2. Computes weighted edges from: explicit links (`[[wikilinks]]` and markdown links), shared filename prefix, shared tags, same type, keyword overlap (TF-IDF cosine)
3. Normalizes weights to [0, 1], discards < 0.25
4. Writes `memory/graph.json`
5. Patches `## Related (auto)` (top-3 neighbors) into each memory file — idempotent
6. Generates `memory/brain.html` — open in a browser, works fully offline

## Expected output

```
Found 50 memory files
Computed 312 edges (raw: 1225)
graph.json: 50 nodes, 312 edges, avg 0.41
Patched 48 files with Related (auto)
brain.html written
```

## Query the brain

```bash
node skills/brain/brain-query.mjs <terms...> [--top=N] [--type=feedback]
```

## When to run

- After creating or editing significant memories
- When starting a new project (new memories → new links)
- Monthly, as maintenance
