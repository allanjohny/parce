# Architecture Decision Records (ADRs)

A log of decisions with lasting consequences — the kind you don't want to re-litigate or accidentally reverse six months later. Not every choice needs one; write an ADR when the decision is hard to reverse, affects multiple projects, or you know you'll forget the reasoning.

## Format

Each entry follows:

- **Date**: when it was decided
- **Context**: why a decision was needed
- **Decision**: what was decided
- **Consequences**: what changes as a result — tradeoffs accepted, follow-up work implied

## Decisions

### ADR-001: Use trunk-based development with short-lived branches (2026-01-15)
- **Context**: Long-lived feature branches were causing painful merge conflicts across projects.
- **Decision**: All projects merge to `main` directly or via branches that live less than a day; feature flags gate incomplete work instead of long branches.
- **Consequences**: Faster integration, fewer conflicts; requires discipline around feature flags and a CI pipeline that can gate merges.

<!-- Add new entries above this line, numbered sequentially (ADR-002, ADR-003, ...). -->
