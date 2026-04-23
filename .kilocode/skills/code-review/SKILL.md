---
name: code-review
description: This skill describes how to write code reviews
---

# Instructions

This skill describes how to write code reviews

## Code Review Guidelines

When reviewing code, provide structured feedback using the following format:

```
File: [filename]

[review-type] L[line numbers]: 
[specific comment/review note]

[review-type] L[line numbers]: 
[specific comment/review note]
```

### Review Types (in order of severity):
1. **bug** - Critical issues that cause incorrect behavior or crashes
2. **potential-bug** - Code that may cause issues under certain conditions
3. **change-request** - Suggested improvements to functionality or approach
4. **suggestion** - Recommendations for better code structure or performance
5. **nit** - Minor style or formatting improvements
6. **typo** - Spelling or grammatical errors
7. **comment** - General observations or questions

### Review Organization:
1. Group reviews by file
2. Sort reviews by severity within each file
3. Include specific line numbers for each review
4. Provide clear, actionable feedback

### Example Review Structure:
```
File: src/services/user_service.ts

[bug] L45-47
Missing null check could cause NullPointerException when user is not found

[potential-bug] L78-82
Password validation doesn't handle edge cases with special characters

[suggestion] L23-25
Consider extracting user validation logic into separate method

[nit] L12
Variable name 'usr' should be 'user' for better readability
```

## Code Review Checklist

Before approving code review:

- [ ] All tests are passing (TDD compliance)
- [ ] Behavior is clearly defined and tested (BDD compliance)
- [ ] Each class/method has single responsibility (S)
- [ ] Code is open for extension but closed for modification (O)
- [ ] Subtypes are substitutable for their base types (L)
- [ ] Interfaces are specific and client-specific (I)
- [ ] Dependencies are abstracted and injected (D)
- [ ] Code duplication has been eliminated (DRY)
- [ ] All review comments have been addressed
