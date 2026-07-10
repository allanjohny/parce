# Security — Mandatory Rules

Security checks REQUIRED before any commit.

## Pre-Commit Checklist
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user input validated
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevented (HTML sanitized)
- [ ] Auth/authorization verified
- [ ] Rate limiting in place on endpoints
- [ ] Error messages don't leak sensitive data

## Secrets Management
- NEVER hardcode secrets in code
- ALWAYS use environment variables or a secrets manager (e.g. user-secrets for .NET, `.env` + a vault for other stacks)
- Validate that required secrets exist at startup
- Rotate any secret that gets exposed

## Response Protocol
If you find a security issue:
1. STOP immediately
2. Fix CRITICAL issues before continuing with anything else
3. Rotate any exposed secrets
4. Review the rest of the codebase for similar issues

## Details
For a full checklist with code examples, see:
- [skills/backend/security-review.md](../skills/backend/security-review.md)
