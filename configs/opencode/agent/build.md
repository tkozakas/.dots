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
subagents:
  - name: code-reviewer
    description: Reviews code for clean code violations, security issues, and best practices
    trigger: proactive
    use_when: After writing significant code changes (>50 lines) or completing a feature
  - name: refactorer
    description: Identifies code smells and refactors code to follow clean code principles
    trigger: on-demand
    use_when: When dealing with legacy code or complex functions that need simplification
---

# Clean Code Principles

When writing code (Groovy/Jenkinsfile, Go, Ruby, Python, YAML), follow these rules:

## Core Rules
- **Small functions** - Do ONE thing well
- **Intention-revealing names** - Name answers why, what, how
- **0-2 function arguments** - Avoid 3+, never use boolean flags
- **Caller above callee** - Top-down reading flow
- **Single return** per function - One entry, one exit
- **Command-Query Separation** - Change state OR return info, not both
- **No train wrecks** - Avoid `obj.get().get().get()`, use `obj.doSomething()`
- **Clean code = fast code** - Don't rush, messes slow you down
# Go Specifics
- File Layout - Imports → Constants → Types → Constructors → Public → Private
- Reading Distance - Place private helpers immediately below the public function that calls them (Step-down rule)
- Error Handling - Use Guard Clauses (early return on error) to avoid nesting; overrides "Single Return" rule
- Testing - Use Table-Driven Tests for 3+ cases; naming format TestTarget_Scenario
