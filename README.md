# Rails Template

A Rails 8 starting point with the house conventions already wired in and enforced: `rubocop-rails-omakase` with the
project's metric caps, Minitest + `factory_bot` + VCR with an 85% SimpleCov gate, Pundit, Rails 8 authentication,
Solid Queue/Cable, Hotwire, and a blocking CI pipeline (RuboCop, Brakeman, bundler-audit, the full test suite).

The conventions live in [`docs/`](docs/README.md) and are the source of truth — this README only points at them and
records the decisions made while turning them into a running app. Read order for a new contributor:
[doctrine](docs/rails-doctrine.md) → [style guide](docs/style-guide.md) → [naming](docs/naming-conventions.md) →
the enforcement docs ([rubocop](docs/rubocop-conventions.md), [testing](docs/testing-philosophy.md),
[security](docs/security-checklist.md)).

**Everything here is a tunable starting point.** The metric thresholds, the coverage number, the queue layout — all
of it is meant to be adjusted for the real app. Change the docs first, then the config that enforces them.

## What's in the box

| Area | Where | Notes |
|---|---|---|
| Lint | `.rubocop.yml`, `.rubocop_todo.yml` | Omakase base + `rubocop-rails` + `rubocop-performance`; caps exactly as in the docs table; todo file is empty on purpose and explains how to add an owned entry |
| Tests | `test/` | Minitest, factories in `test/factories`, VCR cassettes in `test/cassettes`, SimpleCov gate in `test/test_helper.rb` |
| CI | `.github/workflows/ci.yml`, `bin/ci` (`config/ci.rb`) | Every job blocks; `bin/ci` is the same set of gates for a local pre-push run |
| Auth | `app/controllers/concerns/authentication.rb`, `Session`, `User` | Rails 8 generator, unchanged apart from rate limits; STI subclasses for roles |
| Authorization | `app/policies/` | Pundit, deny-by-default `ApplicationPolicy`, `verify_authorized` / `verify_policy_scoped` app-wide |
| AI | `app/services/ai.rb`, `app/services/ai/` | Provider-agnostic `Ai::` namespace; `Ai::Completion` is the only place a model is called |
| Example slice | `app/models`, `app/controllers`, `app/views` | A small worked example exercising every convention at least once — see the model, controller, and test names for the shape |

## Running it locally

Ruby 3.4, PostgreSQL, and Chrome (for system tests) are the only prerequisites.

```sh
bin/setup                # bundle, db:prepare, seeds
bin/dev                  # web server; jobs run in-process outside production
bin/rails test:all       # unit + request + system tests, with the coverage gate
bin/ci                   # the full CI gate set, locally
```

Seeds create one set of example records with two logins (see `db/seeds.rb`, password `password` for both) so the
pages can be clicked through. The model provider key is read from `Rails.application.credentials.anthropic.api_key`
or `ANTHROPIC_API_KEY`; it is only needed to re-record cassettes — the test suite never contacts a provider.

Re-recording a cassette (`test/cassettes/ai/`):

```sh
ANTHROPIC_API_KEY=... VCR_RECORD=all bin/rails test test/services/ai
```

Check the new file contains only synthetic data before committing it. The three cassettes are hand-written: a good
response, a provider refusal, and a malformed response carrying a script tag — the last one is what proves the
schema validation and the escaping.

Windows notes: run tests with `PARALLEL_WORKERS=1` (no `fork`), and when committing the `bin/` scripts from a
Windows checkout run `git update-index --chmod=+x bin/*` once so CI on Linux can execute them.

## Decisions and rationale

The docs leave a handful of choices open. Each was resolved toward the most idiomatic Rails 8 / omakase option:

- **PostgreSQL, not SQLite.** The docs allow SQLite only for genuinely small apps. Some of the example tables are
  the kind that grow continuously and get reported on, and the production config already splits cache, queue and
  cable databases. Nothing in the app is Postgres-specific except one partial unique index, which is the cleanest
  way to guarantee at most one open record of a kind per owner.
- **Rails 8 built-in authentication, STI for roles.** The generator's `Session`/`User`/`Current` is kept as
  generated. Two role subclasses inherit from `User` via a `type` column, which keeps `user.<role>?` a real class
  check and lets each role own its associations; a `role` enum would have pushed every association behind a
  condition.
- **`rate_limit` instead of Rack::Attack.** The checklist asks for "Rack::Attack or equivalent". Rails 8's
  `rate_limit` macro is the omakase equivalent and is applied per IP on sign-in and password reset
  (10 per 3 minutes). Rack::Attack is still the right upgrade if limits need to move to the edge or cover
  non-controller paths.
- **Two separate limits on the model endpoint.** The controller that triggers a model call has its own named
  `rate_limit` per user (5 per hour). Independently, `Ai::Completion` keeps a rolling daily counter in the cache
  (`config/ai.yml` → `daily_call_limit`) and raises `Ai::BudgetExhausted` past it — a runaway loop is a cost
  incident, so the cap lives at the call site, not the controller. The test environment's null cache store counts
  nothing, so the cap is exercised in a unit test with an injected memory store.
- **`Ai::Completion` is the only place a model is called.** It requests structured output, treats a provider
  refusal as `Ai::Refused`, validates the JSON against a `json_schemer` schema before anything is persisted, and
  logs metadata only (model, stop reason, token counts). Provider wiring is `Ai.client`, one line, injected
  everywhere else. The provider SDK is Anthropic's; swapping it means changing `Ai.client` and the `request` method.
- **Prompt allowlist, audited.** The generator's `PROMPT_FIELDS` constant is a fixed allowlist of a handful of
  structured fields — not the record's identifying details, attachments, or its free-text notes field (which can
  carry incidental PII). The audit log records the record id and the field *names*, never the values. A structure
  test pins the payload keys.
- **Length limits live in Active Record, not the schema.** The provider's structured-output schema does not
  accept min/max constraints, so the generated summary model validates its body length and highlight count in
  Active Record; a response that fails those validations is treated as `Ai::InvalidResponse`, not saved.
- **Broadcasts carry no data.** `Broadcastable` calls `broadcasts_refreshes_to` on the owning record: a Turbo page
  refresh, so no record data is written to the cable and only a page that already passed Pundit renders the signed
  stream name. Turbo debounces refreshes through a job, which is why the test uses `perform_enqueued_jobs`.
- **Scope, then find.** Every show/update path loads through `policy_scope` before `authorize`, so another user's
  record is a 404 — indistinguishable from a missing record. Action-level denials (a user attempting an action
  their role doesn't allow) redirect with a flash and `303`.
- **`present?` is taken.** The example model uses `#checked_in?` rather than `#present?`, which would shadow
  `Object#present?` from Active Support.
- **One event model, two resources.** Check-in and check-out are events on the same underlying row, exposed as
  singular `create`-only resources so the controllers stay at one action each and the routes read as verbs.
- **Process-parallel tests, coverage merged.** The Rails default (`parallelize` with processes) is kept; thread
  workers share Capybara's session and database connections and deadlock once system tests join the run. Each
  worker names its SimpleCov slice and the results merge, so the 85% gate measures the whole suite. CI runs
  `test:all` in one job for the same reason.
- **`.rubocop_todo.yml` is empty and stays visible.** The file exists so the mechanism (owner + removal target,
  quarterly review) is in place before the first exception. `--auto-gen-config` is off the table.
- **Generated code is the only inline `rubocop:disable`.** The Active Storage migration exceeds `AbcSize` /
  `MethodLength`; the docs explicitly allow generated framework code, and the disable says so.
- **Minitest 6 extracted `minitest/mock`.** The `minitest-mock` gem is added so instance-level `stub` keeps
  working; the job test uses it to prove the discard path without touching the provider.

### Judgment calls from the security checklist

Each context-dependent item has a decision recorded here rather than silence:

- **Upload validation.** The example model's photo attachment accepts JPEG/PNG/WebP up to 10 MB, validated on the
  blob's content type. Uploads are served through Active Storage's redirect URLs; a separate cookie-less domain for
  serving sensitive uploaded media is the right next step before real traffic and is not set up in the template.
- **Job payloads at rest.** The example background job carries only a `GlobalID`; the record is loaded inside the
  job, so nothing sensitive sits in the queue table. Keep it that way — pass ids, not attributes.
- **Session timeout / remember me.** The generated session cookie is permanent (`cookies.signed.permanent`). For
  an app handling sensitive personal data that is too long; a real deployment should expire sessions (a
  `Session#expired?` check on `updated_at` in `resume_session`) and should not offer "remember me". Left as
  generated so the choice is visible, not buried.
- **PII in error tracking.** No error tracker is wired. When one is, scrub the fields listed in the checklist
  (names, contact info, timestamps, notes) by default; `config.filter_parameters` already covers passwords and
  tokens.
- **`docs/security-checklist.md`'s owner-consent / pet-data handling section.** That doc is written for a pet
  boarding platform, so this item is resolved as documented rather than genericized here: no pet data is used for
  training or profiling, the ownership relationship is the consent record, and everything hanging off a pet record
  is destroyed with it. Retention window to document for a real deployment: boarding period plus one year, with
  photos deleted when a pet is un-enrolled/removed. Not enforced by a job here.
