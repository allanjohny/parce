# Tasks — <feature/project name>

> Spec: ./spec.md · Design: ./design.md
> Legend: [P] = can run in parallel with adjacent [P] tasks

- [ ] T1 — Scaffold project / branch + baseline green
      done when: build + existing tests pass locally
- [ ] T2 [P] — Data model + migration
      done when: migration applies cleanly; model unit tests pass
- [ ] T3 [P] — Static UI mockup approved
      done when: user approved the mockup
- [ ] T4 — Endpoint POST /api/…
      done when: integration test returns 201 + row in DB
- [ ] T5 — Wire UI to API
      done when: flow works end to end in the browser (AC1)
- [ ] T6 — Verify phase: all acceptance criteria ✅ with evidence
      done when: spec.md table updated with proof per AC
