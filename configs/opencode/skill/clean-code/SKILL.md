# Clean Code

- Small functions — do ONE thing
- Intention-revealing names
- 0-2 arguments, no boolean flags
- Caller above callee
- Command-Query Separation
- No train wrecks: `obj.doSomething()` not `obj.get().get().get()`

## Go

- Follow Uber Go style guide
- Never nester — guard clauses, early returns, avoid deep nesting
- Table-driven tests
