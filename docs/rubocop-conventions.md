# Rubocop Conventions

## Philosophy

Rubocop enforces *legibility at a glance*, not cleverness. A reviewer (human or
future-you) should be able to read a file top to bottom without holding much
state in their head. Every metric below exists to force decomposition before a
method or class becomes a place where bugs hide.

Base config: **`rubocop-rails-omakase`**. This is Rails 8's own default and
directly reflects Rails Doctrine tenet 3 ("the menu is omakase") — don't swap
it for Shopify or Standard without a documented reason in a PR description.

## Size limits

| Metric | Default | This project | Rationale |
|---|---|---|---|
| `Metrics/MethodLength` | 10 lines | 10–12 | A method should do one thing; if you can't see the whole thing without scrolling, it's doing two |
| `Metrics/ClassLength` | 100 lines | 150–200 | Rails models/controllers legitimately grow; extend rather than raise indefinitely |
| `Metrics/ModuleLength` | 100 lines | same as class | |
| `Metrics/AbcSize` | 17 | 17–20 | Catches methods that are *short but doing too much* (branches + assignments + calls) |
| `Metrics/CyclomaticComplexity` | 7 | 7 | Hard cap — high complexity is a correctness risk, not just a style one |
| `Metrics/BlockLength` | 25 | exclude `spec/**/*`, routes, config | Specs and DSLs (routes, RSpec `describe`) legitimately run long |
| `Layout/LineLength` | 120 | 120 | Match your widest comfortable split-screen editor width |
| `Metrics/ParameterLists` | 5 | 4 | More than 4 params — reach for a keyword-args object or form object |

**No per-directory exceptions.** `app/services/**/*` uses the same
`MethodLength`/`AbcSize` caps as the rest of the app. A separate, stricter cap
for one directory creates a rule an agent has to remember applies only in one
place — if service objects are getting long, that's already a signal from
`AbcSize`/`CyclomaticComplexity`, not a reason for a bespoke threshold.

This applies to `app/models/**/*` too — models are **not** excluded from
`ClassLength`. A model pushing past the cap is the signal to pull related
behavior into a concern named for the capability it provides, which is the
answer the style guide already gives for fat models. Excluding models would
remove exactly the pressure that produces that decomposition.

## When a file *should* exceed a limit

Rubocop excludes are a design decision, not a shortcut. Acceptable reasons to
add a file/line to `.rubocop_todo.yml` or an inline `# rubocop:disable`:

- Legacy code being migrated incrementally (todo file, with a removal plan)
- Generated code (schema.rb, routes in some DSL-heavy cases)
- A genuinely irreducible data structure (a large lookup table/enum)

Not acceptable: "the method just needs to be long" — that's usually a sign it
should be a service object or split into named private steps.

## Custom conventions worth codifying

- No `rescue => e` swallowing exceptions silently — always re-raise, log, or
  handle with intent (`Rubocop::Lint/RescueException`, `Lint/SuppressedException`)
- Ban `update_attribute` (skips validations) in favor of `update`
- Require frozen string literals (`# frozen_string_literal: true`) project-wide
- `Rails/SkipsModelValidations` on — force explicit opt-out when bypassing validations
- Prefer guard clauses over nested conditionals (`Style/GuardClause`)
- No Sorbet/RBS-adjacent cops (`Style/StrictFreeze`, etc.) — adds ceremony
  without buying safety unless Sorbet is already in use elsewhere in the
  project; skip for this template

## `.rubocop.yml` skeleton

```yaml
require:
  - rubocop-rails-omakase
  - rubocop-rspec
  - rubocop-performance

AllCops:
  NewCops: enable
  TargetRubyVersion: 3.4
  Exclude:
    - 'db/schema.rb'
    - 'bin/*'
    - 'vendor/**/*'

Metrics/MethodLength:
  Max: 12

Metrics/ClassLength:
  Max: 150

Layout/LineLength:
  Max: 120
```

## CI gate

- `rubocop --parallel` runs on every PR, fails the build (no "warn only" mode)
- New violations block merge; existing ones tracked in `.rubocop_todo.yml` with
  an owner and a removal target, reviewed quarterly
