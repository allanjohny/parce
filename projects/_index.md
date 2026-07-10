# Project Map

One row per repo or project you actively work on. The assistant keeps this table updated as it learns which projects you touch — new row when it sees a new repo, status/stack/summary refreshed as things change.

| Project | Status | Stack | Summary | Docs |
|---|---|---|---|---|
| **acme-api** | In production | Node.js + Express + PostgreSQL | Internal billing API for Acme Corp | [docs](acme-api.md) |

## How this works

- One folder or one `.md` file per project (e.g. `acme-api.md`, or `acme-api/` if it needs more than one page).
- The table above is the index — keep entries short; put detail in the linked doc, not here.
- Status is a snapshot, not history: "In production", "In development", "Paused", "Archived" — whatever vocabulary you actually use.
- When you mention a new repo in conversation, the assistant should add a row (even a bare `- to document -` placeholder is fine) rather than let it go untracked.
- Delete or archive rows for projects you've dropped — a stale map is worse than no map.
