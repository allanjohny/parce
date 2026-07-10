# Per-project port registry

Single source of truth for running several projects on the same machine without collisions.
**When you add a new project, register its trio here.** Suggested default ranges for new
entries: front **81xx**, API **53xx**, DB **54xx** (pick the next free one).

| Project | Repo (local path) | Front (Vite) | API | DB (docker container) | DB / user |
|---|---|---|---|---|---|
| **Example App** *(fictional — replace with your own)* | `~/dev/example-app` | 8100 | 5300 | 5450 (`example-app-db`) | `example` / `example` |

## Rules
- **Never** `pkill -f vite` / `pkill -f dotnet` / `pkill node` — that kills other projects too. Kill **by port**: `lsof -ti:<port> | xargs kill -9`.
- Vite always with `strictPort: true` on the reserved port (never let it hop to 8081/8082).
- Each project's DB is an isolated container (`<project>-db`) — idempotent, don't tear it down.
- Keep a running note of the next free trio at the bottom of this table so you don't have to recompute it each time.

## Health & seed (for S4.5 — wait_healthy / api_token)

| Project | Health (API) | Seed login (dev) |
|---|---|---|
| Example App | `:5300/health` | `admin` / `changeme` |

`?` = confirm on first use and fix here. The token field name varies (`token` vs `accessToken`).
