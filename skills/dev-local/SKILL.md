---
name: dev-local
description: Safely run any locally-cloned project (DB/docker + API + front) on a machine where MULTIPLE projects run at the same time. Per-project port registry + cleanup scoped strictly by port (NEVER a generic pkill of vite/node/dotnet) + strictPort. Use when the user says "run <project> locally", "start the dev server", "spin up the stack", "test locally", "mirror prod locally", or BEFORE starting any dev server / docker compose / dotnet run / npm run dev on a machine with several projects.
license: MIT
---

You are running a project on a machine where **several projects live and run at the same time**. The golden rule: **every project owns its ports, and you only ever touch that project's ports.** One careless move (`pkill -f vite`, a dev server silently hopping ports) takes down or collides with someone else's stack. This skill is the protocol that keeps that from happening.

## S0 — Single source of truth for ports

Before anything else, read the registry: `Read(references/ports.md)` (relative to this skill). It's the table of ports reserved per project. **Every port decision comes from it.** If the project isn't listed yet, you'll register it (S5).

## S1 — Identify the project and its ports

1. Confirm the repo (cwd / path the user named — local clones typically live under one dev root, e.g. `~/dev/`).
2. Find its ports, in this order:
   - **Registry** (`references/ports.md`) — if it already has an entry, use it.
   - **Otherwise, inspect the repo's own config:**
     - Front: `vite.config.*` → `server.port`.
     - .NET API: `Properties/launchSettings.json` → `applicationUrl`.
     - DB/services: `docker-compose.yml` / `compose.yml` → `ports:` + `container_name`.
     - Connection string: `appsettings.Development.json` / `.env` → `Host=...;Port=...`.
   - **If no port is defined anywhere** (brand-new project) → assign a free trio (S5).

## S2 — Pre-flight (don't take down the others)

List what's occupying the relevant ports — **this project's** and **everyone else's** (to confirm you won't touch theirs):

```bash
for p in <THIS_PROJECT_PORTS> <OTHER_PROJECTS_PORTS>; do
  PIDS=$(lsof -ti:$p 2>/dev/null)
  [ -n "$PIDS" ] && echo ":$p -> $(ps -o command= -p $(echo $PIDS|tr ' ' ',') 2>/dev/null | head -c 80)"
done
```

Check the result: if another project is already running on its own ports, **leave it alone**. You only ever act on your own project's ports.

## S3 — Cleanup SCOPED by port (the golden rule)

Kill **only** what's on this project's reserved ports:

```bash
kill_port() { lsof -ti:"$1" 2>/dev/null | xargs kill -9 2>/dev/null || true; }
kill_port <FRONT>   # e.g. 8080
kill_port <API>     # e.g. 5303
```

**FORBIDDEN (kills other projects' processes):**
- `pkill -f vite` · `pkill -f "dotnet run"` · `pkill node` · `pkill -f dotnet`
- `docker compose down` on a shared compose file without checking first
- Killing by generic process name instead of by port

DB in docker: **don't tear it down** — `docker compose up -d` is idempotent and the project's container (`<project>-db`) is isolated. Only start it if it isn't already up.

## S4 — Bring the stack up

If the repo has a `scripts/dev.sh`, **use it** (it already does scoped cleanup + correct ports):
```bash
./scripts/dev.sh
```

Otherwise, bring it up manually, in order, always on the reserved ports:
```bash
# 1. Database (idempotent)
( cd <repo>/api && docker compose up -d )
# wait until ready: docker exec <project>-db pg_isready -U <user> -d <db>

# 2. API (.NET example) — port from launchSettings
( cd <repo>/api/<Api> && ASPNETCORE_ENVIRONMENT=Development ASPNETCORE_URLS=http://localhost:<API> dotnet run --launch-profile http ) &
# wait: curl -s localhost:<API>/health

# 3. Front (Vite) — FIXED port (see S6)
( cd <repo> && npm run dev )
```

To run in the background for verification (e.g. browser automation), redirect logs (`> /tmp/<project>-dev.log 2>&1 &`) and detect the port from the log. When done, **scoped cleanup** (S3), never a blanket kill.

## S4.5 — Lifecycle helpers (restart / health / token) — reuse these, don't reinvent them

The #1 wasted effort: killing a port, blind `sleep N`, and redoing a curl login dozens of times. Protocol:

```bash
wait_healthy() { local url=$1 t=${2:-40}; until curl -fsS -o /dev/null "$url" 2>/dev/null; do t=$((t-1)); [ $t -le 0 ] && { echo "TIMEOUT $url"; return 1; }; sleep 1; done; echo "OK $url"; }

restart_api() { # usage: restart_api <port> <dir> <health-path> <cmd...>
  local port=$1 dir=$2 hp=$3; shift 3
  lsof -ti:$port | xargs kill -9 2>/dev/null || true
  ( cd "$dir" && "$@" > /tmp/dev-$port.log 2>&1 & )
  wait_healthy "http://localhost:$port$hp" || { tail -20 /tmp/dev-$port.log; return 1; }
}

api_token() { # usage: api_token <port> <email> <password> — caches 30min in /tmp
  local port=$1 cache=/tmp/token-$port
  [ -f "$cache" ] && [ $(( $(date +%s) - $(stat -f %m "$cache") )) -lt 1800 ] && { cat "$cache"; return; }
  curl -s -X POST "http://localhost:$port/api/auth/login" -H 'Content-Type: application/json' \
    -d "{\"email\":\"$2\",\"password\":\"$3\"}" \
    | python3 -c 'import sys,json,re;d=json.load(sys.stdin);print(d.get("token") or d.get("accessToken"))' | tee "$cache"
}
```

Rules:
- **Never a blind `sleep N`** waiting for a service — always `wait_healthy`.
- **Before any UI/API test**, `wait_healthy` on the project's ports; if it's down, `restart_api` right away — don't wait for the user to report it.
- **One token per session** via `api_token` (cached), not a fresh login curl per test.
- Seed credentials and health paths per project: "Health & seed" section in `references/ports.md`.

## S5 — NEW project (no ports registered yet)

1. Pick a **free trio** that doesn't collide with the registry — fill in your own ranges (e.g. front `81xx`, API `53xx`, DB `54xx`).
2. Pin it in the repo: `vite.config` (`port` + `strictPort: true`), `launchSettings.json` (`applicationUrl`), `docker-compose.yml` (`ports:` + `container_name: <project>-db`), connection string.
3. **Register it in `references/ports.md`** (edit the table) — mandatory, it's what prevents future collisions.
4. **Register it in your dev-server launch config**, if your tooling uses one, so "start the dev server" resolves without guessing.
5. (Optional, recommended) add a `scripts/dev.sh` mirroring the scoped-cleanup pattern above.

## S6 — strictPort (always)

Every Vite front must have `strictPort: true` on its reserved port. Without it, Vite **silently jumps** to 8081/8082 when the port is busy — leaving a zombie process that can collide with another project. With strictPort, it **fails loudly** and you fix it (kill that project's stale process).

## S7 — Production data locally (optional)

To test with real data without touching prod: dump from prod → restore into the project's local, isolated docker DB. Always restore into a **local isolated database**, never point the local app at prod. Afterward, restart the API (scoped by port — S3) so it reapplies migrations and re-seeds the dev login (a `--clean` restore drops tables, wiping any test user that only gets created by the dev seed).

## Checklist
- [ ] Used only this project's reserved ports (S0/S1).
- [ ] Cleanup was by port (`lsof -ti:<port>`), never a generic `pkill`.
- [ ] Didn't touch any other project's process or port.
- [ ] strictPort fixed on the front.
- [ ] New project → registered in `references/ports.md`.
