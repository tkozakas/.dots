---
name: clean-code
description: Clean-code guidelines for writing and editing code. Use when implementing or refactoring, especially Go (Uber style) or Ruby/RSpec (vinted-eve lint rules).
globs:
  - "**/*.go"
  - "**/*.rb"
---

# Clean Code

- Small functions — do ONE thing
- Intention-revealing names
- 0-2 arguments, no boolean flags
- Caller above callee
- Command-Query Separation
- No train wrecks: `obj.doSomething()` not `obj.get().get().get()`

## Language-specific references

Read the relevant file before writing code in that language:

- **Go** → `references/go-uber.md` (Uber style, never-nester, table-driven tests)
- **Ruby / RSpec** → `references/ruby-rspec.md` (vinted-eve lint rules — fix before PR)
