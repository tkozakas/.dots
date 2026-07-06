# Go — Uber style

Follow the Uber Go Style Guide: <https://github.com/uber-go/guide/blob/master/style.md>

Highest-signal rules to apply by default:

- **Never-nester**: guard clauses and early returns; avoid deep nesting.
- **Table-driven tests** for anything with multiple input/output cases.
- Return errors, don't panic; wrap with `%w` and add context.
- Zero-value-useful structs; avoid unnecessary constructors.
- Accept interfaces, return concrete types.
- `defer` for cleanup; keep the happy path un-indented.
- Keep interfaces small; define them on the consumer side.
- No naked returns in long functions; name results only for docs/defer.
- `errors.Is` / `errors.As` for comparison, not `==`.
