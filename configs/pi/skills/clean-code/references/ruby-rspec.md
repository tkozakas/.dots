# Ruby / RSpec — vinted-eve lint rules

Recurring `vinted-eve` (RuboCop runner) comments on PRs. Fix these before
opening a PR to avoid review noise. Self-contained; no external links.

## RSpec/MessageSpies — `receive` vs `have_received`

Most frequent offender. To **set** an expectation use `expect(...).to receive(...)`,
not the spy form. `have_received` is only for **verifying** a call already
stubbed with `allow`.

```ruby
# BAD — sets expectation with spy form
expect(MyOrders::Facade).not_to have_received(:fetch_by_id)

# GOOD — set expectation up front
expect(MyOrders::Facade).not_to receive(:fetch_by_id)
# ... call code ...
```

If you want spy semantics (assert after the fact), `allow` it first and the
cop accepts `have_received`.

## RSpec/StubbedMock — `allow` vs `expect` for return values

To **stub a return value** (don't care if/how often called) use `allow`, not
`expect`. Use `expect(...).to receive` only when the call itself is the assertion.

```ruby
# BAD
expect(Foo).to receive(:bar).and_return(42)

# GOOD
allow(Foo).to receive(:bar).and_return(42)
```

## RSpec/DescribedClass

Inside `RSpec.describe SomeClass`, refer to the subject as `described_class`,
not the literal name.

```ruby
# BAD
RSpec.describe ComplaintParams do
  controller(ActionController::Base) { include ComplaintParams }
end

# GOOD
RSpec.describe ComplaintParams do
  controller(ActionController::Base) { include described_class }
end
```

## RSpec/SubjectStub

Don't stub methods on the object under test. If the subject needs canned
behavior, refactor: extract a collaborator and stub that, or build the subject
with the data you need.

```ruby
# BAD
subject(:presenter) { Presenter.new(order) }
before { allow(presenter).to receive(:title).and_return('x') }

# GOOD — stub the dependency that feeds title
before { allow(order).to receive(:title).and_return('x') }
```

## RSpec/NestedGroups — max depth 4

Max nesting is 4 (`describe → context → context → context`). A 5th level fails
the cop. Flatten with shared examples or compound context names
(`context 'when X and Y'`).

## RSpec/ExampleLength — max 25 lines

A single `it` block can't exceed 25 lines. Extract setup into `let` / `before`,
or split into multiple examples.

## Lint/AvoidComplaintFactories (more-backend rule)

`@vinted/more-backend` packages: don't use `:complaint`, `:complaint_order_item`,
etc. factories directly. Go through `Complaints::Repository` or a facade. If
unavoidable, ping `#more`.

## Lint/AvoidComplaintRecords

Same idea for production code: no direct `Complaint` ActiveRecord access. Use
`Complaints::Repository` or a facade.

## Lint/DeprecatedFactory

Many legacy factories (`item`, `user`, etc.) are deprecated. Stub the **public
API** of the owning package instead.

## Layout / Metrics (non-RSpec but common alongside)

- `Layout/LineLength`: max 120 chars.
- `Metrics/ModuleLength`: max 100 lines per module.
- `Rails/OutputSafety`: don't `.html_safe` user-controlled strings.

## Pre-PR checklist

- [ ] No `have_received` on un-stubbed mocks → use `receive`.
- [ ] No `expect(...).to receive(...).and_return(...)` for pure stubs → use `allow`.
- [ ] `described_class` instead of repeating the class name.
- [ ] No stubs on the subject itself.
- [ ] Nesting ≤ 4 levels.
- [ ] Each `it` ≤ 25 lines.
- [ ] No direct `:complaint*` factories or `Complaint` AR access (more-backend).
- [ ] No deprecated factories — stub the package's public API.
