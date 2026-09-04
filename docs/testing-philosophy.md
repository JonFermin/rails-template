# Testing Philosophy

> Decided. Governs what gets tested, at what level, and what's explicitly
> out of scope — the goal is confidence per line of test code, not coverage
> percentage for its own sake.

## Guiding principle

Test *behavior*, not *implementation*. A test should survive a refactor that
doesn't change what the code does, and should fail when the behavior actually
changes. If renaming a private method breaks a test, the test is wrong.

## Framework: Minitest

Minitest, not RSpec — this matches the Basecamp corpus the rest of the style
guide is modeled on and keeps the template internally consistent. It's the
Rails default and requires no additional gem to justify.

## What level to test at

| Layer | Tool | When |
|---|---|---|
| Model validations/associations/scopes | Unit (model test) | Always — cheap, fast, high signal |
| Business logic in plain objects (service objects, form objects) | Unit | Always — this is where the actual logic lives |
| Controller actions | Request test | Test the HTTP contract (status, redirects, JSON shape) — not the internals |
| Full user flows (login → create room → post message) | System test (Capybara) | Sparingly — 3–5 critical paths, not every permutation |
| Background jobs | Unit on the job's `#perform`, plus one integration test that it's enqueued | Always test the job logic directly; don't re-test business logic already covered elsewhere |
| External API integrations (LLM calls, third-party services) | VCR-recorded cassette + a unit test of the parsing/handling logic | Never hit real APIs in CI |
| LLM prompt construction | Structure/shape test (see below) | Whenever a prompt-building method changes |

## What NOT to test

- Rails framework behavior itself (don't test that `validates :presence` on a
  column actually validates presence — test *your* custom validation logic)
- Trivial delegations (`delegate :name, to: :user`) — no test needed unless
  there's custom fallback logic attached
- Every branch of a conditional when the branches are symmetric and simple —
  one representative case per meaningfully different outcome, not combinatorial
  coverage of every input
- Private methods directly — test through the public interface

## Coverage as a signal, not a target

`simplecov` runs in CI with an **85% threshold, hard gate**. The number is a
smoke detector, not a goal. 100% coverage with weak assertions (`assert
response`) is worse than 85% coverage with assertions that actually pin
behavior. If coverage drops, the question is "did we skip testing something
important," not "did the number go down."

## Test naming

Describe the behavior in plain language, from the perspective of someone who
doesn't know the implementation:

```ruby
test "archiving a room removes it from members' active room list" do
  # ...
end
```

Not:

```ruby
test "sets archived_at and calls broadcast_remove" do
  # ...
end
```

The first survives an internal refactor of *how* archiving works. The second
breaks the moment you change the mechanism without changing the behavior.

## Fixtures vs. factories

Prefer `factory_bot` for anything with meaningful object graphs or
validations that need satisfying — factories make the *setup* of a test
readable inline, which matters more than DRY-ing up test data. Rails
fixtures are acceptable for small, stable reference data (e.g., seed-like
lookup tables) that rarely changes shape.

## Flaky tests

A flaky test is a bug in the test, not a fact of life. No `sleep`, no
retry-until-pass. System tests use Capybara's built-in waiting
(`have_content`, etc.) rather than manual timing. A test that can't be made
deterministic gets deleted or rewritten, not silenced with a retry wrapper.

## AI/LLM prompt regression testing

Every method that constructs a prompt gets a **structure test**, not a full
prompt-text snapshot: assert which fields/keys are present in the payload
sent to the LLM, not the literal string. This catches silent scope creep
(a new field quietly added to the prompt) without being brittle to wording
changes.

```ruby
test "room summary prompt includes only allowlisted fields" do
  payload = Ai::RoomSummarizer.new(room).build_prompt_payload
  assert_equal %i[room_name message_count recent_topics], payload.keys
end
```

This ties directly to the security checklist's requirement to define
explicitly what data reaches the LLM.

## CI gate

- Full suite runs on every PR
- `bin/rails test` for fast unit/request feedback locally; full suite
  (including system tests) in CI
- No merge on red — no "known flaky, ignore" culture
