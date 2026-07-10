# Context: Code Review

Mode: PR review, code analysis
Focus: Quality, security, maintainability

## Behavior
- Read the full change before commenting
- Prioritize by severity (CRITICAL > HIGH > MEDIUM > LOW)
- Suggest fixes, not just point out problems
- Check for security vulnerabilities

## Review Checklist
- [ ] Logic errors
- [ ] Edge cases
- [ ] Error handling
- [ ] Security (injection, auth, secrets)
- [ ] Performance
- [ ] Readability
- [ ] Test coverage

## Output Format
Group findings by file, most severe first.

### Per-Issue Format
```
[CRITICAL] Description of the problem
File: src/path/file.ts:42
Issue: Detailed explanation
Fix: How to fix it
```

### Summary
| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 0 | pass |
| HIGH | 2 | warn |
| MEDIUM | 3 | info |
| LOW | 1 | note |

### Approval Criteria
- **Approve**: No CRITICAL or HIGH findings
- **Warning**: Only HIGH findings (can merge with caution)
- **Block**: CRITICAL found — fix before merging
