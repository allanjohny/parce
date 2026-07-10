# Testing — Requirements

## Minimum Coverage: 80%

### Test Types (all required)
1. **Unit** — Functions, utilities, services, domain entities
2. **Integration** — API endpoints, database operations
3. **E2E** — Critical user flows (e.g. Playwright)

## TDD (Required Workflow)
1. Write the test first (RED)
2. Run it — it must FAIL
3. Write the minimal implementation (GREEN)
4. Run it — it must PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Example Stack by Layer

| Layer | Backend example (.NET) | Frontend example (React) |
|-------|------------------------|---------------------------|
| Unit | xUnit + FluentAssertions | Vitest + Testing Library |
| Integration | xUnit + WebApplicationFactory | Vitest + MSW |
| E2E | — | Playwright |

Swap these for whatever your stack's equivalent tools are (e.g. pytest for Python, Jest for Node, Go's `testing` package).

## Rules
- Test behavior, not internal implementation
- Never test third-party libraries/packages (trust the ecosystem)
- 100% coverage on business rules
- Pragmatic coverage on UI (critical behaviors only)
- Avoid brittle snapshot tests
- Fix the implementation, not the test — unless the test itself is wrong

## Details
- E2E patterns: [skills/frontend/e2e-testing.md](../skills/frontend/e2e-testing.md)
- React stack: [skills/frontend/react.md](../skills/frontend/react.md)
- .NET stack: [skills/backend/csharp-dotnet.md](../skills/backend/csharp-dotnet.md)
