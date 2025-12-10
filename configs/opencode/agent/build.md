---
description: Write-enabled build agent
mode: primary
tools:
  read: true
  write: true
  edit: true
  grep: true
  glob: true
  list: true
  bash: true
  webfetch: true
  patch: true
permission:
  edit: allow
  bash: allow
  webfetch: allow
---

# Clean Code

- Small functions - do ONE thing
- Intention-revealing names
- 0-2 arguments, no boolean flags
- Caller above callee
- Command-Query Separation
- No train wrecks: `obj.doSomething()` not `obj.get().get().get()`

## Go
- Layout: Imports -> Constants -> Types -> Constructors -> Public -> Private
- Guard clauses for errors (early return)
- Table-driven tests

# MCP Tools

## ck-search
- `semantic_search` - find code by meaning ("error handling", "auth logic")
- `regex_search` - exact pattern match
- `hybrid_search` - both combined

## gh_grep
- Find real-world examples from GitHub repos
