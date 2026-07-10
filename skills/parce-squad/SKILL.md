---
name: parce-squad
description: >
  Spec-driven development cycle for building anything — a new app, a feature, or a task.
  Runs pre-flight (environment prep / main sync), writes the spec docs (PRD, design, tasks),
  gets approval, then builds task by task with verification and proof of execution.
  Use when the user says "parce-squad", "let's build an app", "new project", "build this
  feature", "implement X end to end", or asks for a structured development cycle.
---

# Parce Squad — spec-driven development cycle

You are about to build something real. Don't jump to code. The cycle below turns a request into a spec, a spec into tasks, and tasks into a verified, working result. Docs first — they're cheaper to change than code, and they keep every later session on rails.

**The cycle:** Intake → Pre-flight → Spec → *approval gate* → Build loop → Verify → Wrap-up.

Skip nothing silently. If a phase genuinely doesn't apply (a one-file task doesn't need a PRD), say so in one line and move on.

## Phase 0 — Intake

Classify the request:

| Type | Signal | Spec depth |
|---|---|---|
| **New project** | "let's create an app that…" | Full: PRD + design + tasks |
| **Feature** | "add X to <project>" | design + tasks (PRD only if scope is fuzzy) |
| **Task / fix** | "fix Y", "change Z" | tasks.md only, or none if trivial |

Before writing anything, close the open questions — target users, must-have vs nice-to-have, stack preference, where it will live/deploy. Ask now, in one batch; every assumption you don't confirm here becomes rework later. **Every requirement must arrive at a verifiable acceptance criterion** ("user can register and log in" → a test or a demo step, not a vibe).

## Phase 1 — Pre-flight

Prepare the ground the project will live on. Nothing else starts until pre-flight is green.

**New project:**
1. Decide the home directory with the user (e.g. `~/dev/<slug>`), `git init`, first commit with scaffold.
2. Reserve ports in the `dev-local` skill's registry (`skills/dev-local/references/ports.md`) BEFORE anything binds a port — this machine may run several projects.
3. Add a row to `projects/_index.md` (status: In development).

**Existing project:**
1. `git -C <repo> fetch origin && git status` — never build on a stale or dirty tree.
2. Sync: `git checkout main && git pull` (or rebase the working branch on main). Surface conflicts to the user; don't resolve destructively on your own.
3. Create a branch: `git checkout -b feat/<slug>`.
4. Install deps and run the existing build + test suite. **Baseline must be green before you change anything** — otherwise you can't tell your breakage from inherited breakage. If baseline is red, report it and ask whether to fix or proceed.

## Phase 2 — Spec (the docs, all pretty)

Write the docs in `docs/specs/<slug>/` inside the target project (templates in this skill's `references/`):

1. **`spec.md`** — problem, goals, non-goals, user stories, **acceptance criteria (each one verifiable)**. Scope is a contract: what's OUT is written down too.
2. **`design.md`** — architecture, data model, API contracts, key decisions with alternatives considered. For anything with a UI: **mockup first** — build a static HTML mockup or wireframe and show it before wiring real logic; pixels are cheaper than plumbing.
3. **`tasks.md`** — ordered checklist. Each task: small (≤ half a day), independently verifiable, with its own "done when" line. Mark tasks that can run in parallel.

**Approval gate:** present the spec to the user and get an explicit OK before writing production code. Spec changes after the gate are fine — update the doc first, then the code (the doc is the source of truth, always).

Check `decisions/_index.md`: if the design contradicts an existing ADR, raise it now. If the design makes a new hard-to-reverse choice, draft the ADR entry as part of the spec.

## Phase 3 — Build loop

Work `tasks.md` top to bottom. Per task:

1. **Bug or logic change → failing test first.** Watch it fail, then make it pass.
2. Implement the minimum that satisfies the task. Simplicity first: no speculative abstraction, no features the spec didn't ask for. Surgical diffs.
3. Verify the task's own "done when" line — run it, don't assume it.
4. Tick the checkbox in `tasks.md` and commit atomically (one task ≈ one commit).

Independent tasks → delegate to parallel subagents when your harness supports it (cheap/fast model for mechanical tasks, main model for design-heavy ones). Never parallelize tasks that touch the same files.

Stuck or the spec turned out wrong? Stop patching around it — go back to Phase 2, amend the doc, then return.

## Phase 4 — Verify (proof, not promises)

Before calling it done:

1. Full test suite green.
2. **Drive the real flow end to end** — start the app (via `dev-local` ports), exercise the acceptance criteria one by one as a user would. UI change → look at it (screenshot/preview), don't infer from code.
3. Every acceptance criterion in `spec.md` gets a ✅ with evidence: command output, test name, screenshot, or curl response. "I wrote it" is not evidence; "I ran it and here's the output" is.
4. Diff review against `rules/` (security checklist, coding style) and against relevant ADRs in `decisions/`.

Anything red → back to Phase 3. Report honestly: a failing criterion reported beats a green lie.

## Phase 5 — Wrap-up

1. Update `projects/_index.md` (status, stack, summary) and the project's doc page.
2. Record new ADRs in `decisions/_index.md`.
3. Write memories worth keeping (non-obvious constraints, recipes that worked, user feedback) and rebuild the brain: `node skills/brain/build-graph.mjs`.
4. Merge/PR per the user's workflow. Never push or deploy without being asked.
5. Close with a summary: what shipped, evidence per acceptance criterion, what was deliberately left out.

## Rules of the cycle

- **Doc is truth.** Code follows spec; when they diverge, one of them gets fixed consciously.
- **Verifiable or it doesn't exist.** Requirements, tasks, and "done" all need a check you can run.
- **Baseline green, always.** Never start work on a red build.
- **Proof of execution.** Nothing is reported as done without measured evidence.
- **Ask early, not often.** One batch of sharp questions in Intake beats twenty mid-build interruptions.
