---
description: Implements code changes, runs tests after edits
mode: subagent
tools:
  read: true
  write: true
  edit: true
  grep: true
  glob: true
  bash: true
  patch: true
permission:
  edit: allow
  bash: allow
---

Implement code changes. Run tests after edits. Use /skill clean-code for guidelines.
