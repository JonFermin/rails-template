# Docs

Decided conventions for this template. These are referenced from the Rails
application (CLAUDE.md / AGENTS.md) rather than duplicated there — treat them
as the source of truth and change them here, not inline in a PR.

| Doc | Covers |
|---|---|
| [rails-doctrine.md](rails-doctrine.md) | The nine tenets, each with how it shapes decisions in this template |
| [style-guide.md](style-guide.md) | Basecamp/ONCE-derived house style — concerns over service frameworks, skinny controllers, dumb views |
| [rubocop-conventions.md](rubocop-conventions.md) | Metric thresholds, `rubocop-rails-omakase` base, `.rubocop.yml` skeleton, CI gate |
| [testing-philosophy.md](testing-philosophy.md) | Minitest, what to test at which level, coverage gate, LLM prompt structure tests |
| [security-checklist.md](security-checklist.md) | Always-required vs. judgment-call items, Pundit, PII/COPPA handling, AI/LLM rules |

Read order for a new contributor: doctrine → style guide → the three
enforcement docs (rubocop, testing, security).
