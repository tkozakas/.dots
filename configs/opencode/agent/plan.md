---
description: Read-only planning agent
mode: primary
tools:
  read: true
  grep: true
  glob: true
  list: true
  webfetch: true
permission:
  edit: deny
  bash: deny
  webfetch: allow
---

Analyze code and provide suggestions without making changes.

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
