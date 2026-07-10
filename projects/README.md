# projects/

A living map of the repos and projects you work on: one row in `_index.md` per project, with an optional longer `.md` file (or folder) per project for anything that doesn't belong in the table.

The assistant maintains this on its own:

- Notices a new repo or project mentioned in conversation → adds a row.
- Learns a project's stack, status, or purpose → fills in or updates the row.
- Status changes ("shipped", "paused", "rewritten") → updates the row, doesn't just append.

This is project *metadata* (what it is, where it stands), not project *history* — that belongs in `memory/` as `project` memories, linked from here if useful.
