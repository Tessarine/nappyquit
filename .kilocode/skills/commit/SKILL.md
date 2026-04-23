---
name: commit
description: This skill describes how to write commit messages
---

# Instructions

This skill describes how to write commit messages

## Pre Commit Checklist

- [ ] Behavior is clearly defined and tested (BDD compliance)
- [ ] Tests are extended with the new feature and all tests are passing (TDD compliance)
- [ ] UI is separated from the business logic
- [ ] SOLID principles were applied in the change
- [ ] Code duplication has been eliminated (DRY)
- [ ] All review comments have been addressed

## Commit Message Examples

### Good (no co-author):
```
feat: Add user authentication service

- Implement JWT-based authentication
- Add password hashing with bcrypt
- Include login/logout endpoints
- Write comprehensive tests for all auth flows
```

### Bad (includes co-author):
```
feat: Add user authentication service

Co-authored-by: John Doe <john@example.com>
- Implement JWT-based authentication
- Add password hashing with bcrypt
- Include login/logout endpoints
- Write comprehensive tests for all auth flows
```
