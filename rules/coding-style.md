# Coding Style — Universal Rules

Style principles that apply to ALL code (backend and frontend, any stack).

## Immutability (critical)
- ALWAYS create new objects, NEVER mutate existing ones
- Prefer spread operators, `.map()`, `.filter()` over in-place mutation
- Prevents hidden side effects and makes debugging much easier

## File Organization
- MANY SMALL FILES beat FEW LARGE ONES
- Aim for 200-400 lines per file, 800 as a hard ceiling
- Extract utilities out of large modules
- Organize by feature/domain, not by technical type

## Functions
- Max ~50 lines
- Max 4 levels of nesting (use early returns)
- Descriptive names over comments

## Error Handling
- Handle errors explicitly at every layer
- Friendly messages in the UI
- Detailed logs on the server
- Never swallow errors silently

## Input Validation
- Validate at system boundaries (user input, external APIs)
- Use schema-based validation — e.g. Zod for TypeScript, FluentValidation for .NET, Pydantic for Python
- Fail fast with clear messages
- Never trust external data

## Code Quality Checklist
- [ ] Code is readable and well-named
- [ ] Functions are small (< 50 lines)
- [ ] Files are focused (< 800 lines)
- [ ] No deep nesting (> 4 levels)
- [ ] Adequate error handling
- [ ] No hardcoded values
- [ ] No mutation
- [ ] No debug logging left in production code
