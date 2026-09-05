# AGENTS.md

Conventions for this app live in [`docs/`](docs/README.md) and are the source of truth. Read them before changing
code, in this order: [rails-doctrine](docs/rails-doctrine.md) → [style-guide](docs/style-guide.md) →
[naming-conventions](docs/naming-conventions.md) → [rubocop-conventions](docs/rubocop-conventions.md) →
[testing-philosophy](docs/testing-philosophy.md) → [security-checklist](docs/security-checklist.md).

Change a convention in `docs/` first, then the config that enforces it (`.rubocop.yml`, `test/test_helper.rb`,
`.github/workflows/ci.yml`). Do not restate the docs here or in code comments.

## Gates (all blocking, run them before claiming done)

```sh
bin/rubocop --parallel
bin/brakeman --no-pager --exit-on-warn --exit-on-error
bin/bundler-audit check --update
bin/rails test:all        # PARALLEL_WORKERS=1 on Windows
```

`bin/ci` runs the same set. Tests never contact a model provider — use the VCR cassettes in `test/cassettes/`.

## Where things go

- Domain logic: models and capability concerns (`app/models/concerns`, named `-able`).
- Plain Ruby objects with one public `#call`: `app/services/` (model calls only through `Ai::Completion`).
- Jobs stay thin (`#perform` decides and hands off); controllers stay skinny; views hold no logic.
- Authorization: a Pundit policy per model in `app/policies/`; scope, then find.
- Decisions already made and why: [README.md](README.md#decisions-and-rationale).
