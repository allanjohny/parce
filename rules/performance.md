# Performance — Context and Model Management

Performance optimization for working with an AI coding agent.

## Model Selection

Pick the model tier based on the task, not habit:

### Small/fast model
- Lightweight, frequently-invoked agents
- Pair-programming and boilerplate code generation
- Worker agents in a multi-agent system

### Mid-tier model
- Main day-to-day development work
- Orchestrating multi-agent workflows
- Complex coding tasks

### Top-tier model
- Complex architectural decisions
- Tasks needing maximum reasoning depth
- Deep research and analysis

Model names and versions change frequently — pick whichever current release matches each tier rather than hardcoding a specific version here.

## Context Window Management

Avoid starting new work in the last ~20% of the context window for:
- Large refactors
- Features spanning many files
- Debugging complex interactions

Tasks that are less context-sensitive:
- Single-file edits
- Creating independent utilities
- Doc updates
- Simple bug fixes

## Extended Thinking / Reasoning Mode
- Enable extended reasoning for genuinely hard problems
- For complex tasks: combine planning mode with extended thinking

## Build Troubleshooting
If a build fails:
1. Read the error message carefully
2. Fix incrementally
3. Verify after each fix
4. Don't brute-force it
