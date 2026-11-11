# Ruby / RSpec: RuboCop offenses that fail PRs

## RSpec/MessageSpies

Set expectations with `receive`. Use `have_received` only after `allow` stubbed the call.

```ruby
# ✗
expect(Orders::Facade).not_to have_received(:fetch_by_id)
# ✓
expect(Orders::Facade).not_to receive(:fetch_by_id)
```

## RSpec/StubbedMock

Stub return values with `allow`. Use `expect(...).to receive` only when the call is the assertion.

```ruby
# ✗
expect(Foo).to receive(:bar).and_return(42)
# ✓
allow(Foo).to receive(:bar).and_return(42)
```

## RSpec/DescribedClass

Inside `RSpec.describe SomeClass`, write `described_class`, not the class name.

```ruby
# ✗
RSpec.describe OrderParams do
  controller(ActionController::Base) { include OrderParams }
end
# ✓
RSpec.describe OrderParams do
  controller(ActionController::Base) { include described_class }
end
```

## RSpec/SubjectStub

Never stub the object under test. Stub the collaborator that feeds it.

```ruby
# ✗
before { allow(presenter).to receive(:title).and_return('x') }
# ✓
before { allow(order).to receive(:title).and_return('x') }
```

## Limits

- `RSpec/NestedGroups`: at most 4 levels (`describe → context → context → context`). Flatten with compound names: `context 'when X and Y'`.
- `RSpec/ExampleLength`: at most 25 lines per `it`. Move setup into `let` / `before` or split the example.
- `Layout/LineLength`: 120 characters.
- `Metrics/ModuleLength`: 100 lines per module.
- `Rails/OutputSafety`: never `.html_safe` user-controlled strings.
