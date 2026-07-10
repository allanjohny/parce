# Writing good memories

The memory system is the heart of your assistant. These rules keep it useful as it grows from 5 memories to 500.

## One fact per file

A memory file holds **one** fact, decision, or preference. Small memories compose: the brain graph links them, the index summarizes them, and the assistant loads only what's relevant. Big documents rot — nobody updates paragraph 7 of a 200-line file.

## The four types

| type | what goes in it | example |
|---|---|---|
| `user` | who the user is: role, stack, orgs, repos, preferences | "Works mostly in the acme-corp GitHub org, main repo acme-api" |
| `feedback` | how the assistant should work — corrections AND confirmed wins, with the **why** | "Never force-push; user was burned by a lost review. **Why:** …" |
| `project` | ongoing work, goals, constraints not derivable from code | "The v2 migration is frozen until the audit closes (2026-08-01)" |
| `reference` | pointers to external resources | "Staging dashboard: https://…; login via SSO" |

## Frontmatter

```markdown
---
name: short-kebab-case-slug
description: One-line summary — this is what recall reads to decide relevance
metadata:
  type: feedback
---
```

The `description` matters more than the body: it's what gets scanned when deciding which memories to load. Write it like a good commit subject.

## The index (`MEMORY.md`)

One line per memory: `- [Title](file.md) — hook`. The index is loaded at session start; memory bodies are loaded on demand. Keep the hook short and distinctive — it's a routing signal, not a summary.

## Hygiene rules

- **Update, don't duplicate.** Before writing, check whether an existing memory covers the topic.
- **Delete what's wrong.** A stale memory is worse than no memory.
- **Absolute dates.** "Next Friday" is meaningless in three weeks. Write 2026-07-17.
- **Don't store what git already knows.** Code structure, past fixes, commit history — the repo records those.
- **Link liberally.** `[[other-memory]]` links power the brain graph. A link to a memory that doesn't exist yet is a TODO, not an error.
- **Feedback needs a why.** "User prefers X" without the reason will get misapplied. Capture the incident that taught the lesson.

## Rebuild the brain after writing

```bash
node skills/brain/build-graph.mjs
```

This keeps `## Related (auto)` sections fresh, so reading any one memory surfaces its neighbors.
