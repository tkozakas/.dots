---
name: clean-code
description: Applies the user's clean-code preferences when writing or refactoring Go or Ruby/RSpec. Use when implementing, refactoring, or reviewing .go or .rb files.
globs:
  - "**/*.go"
  - "**/*.rb"
---

# Clean code

- At most 2 arguments; no boolean flag arguments. Split the function instead.
  ✗ `render(user, true)`  ✓ `render_summary(user)`
- Callers above callees in the file.
- A method either changes state or returns a value, not both.
- Talk to direct collaborators only.
  ✗ `order.buyer.address.city`  ✓ `order.buyer_city`

## Go

- Guard clauses and early returns; keep the happy path unindented.
- Table-driven tests for multiple input/output cases.
- Wrap errors with `%w` and context; compare with `errors.Is` / `errors.As`.
- Define small interfaces on the consumer side; return concrete types.

## Ruby / RSpec

Read `references/ruby-rspec.md` before writing specs: it lists the RuboCop offenses that fail PRs.
