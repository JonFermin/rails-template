# Security Checklist

## Always required (no exceptions without a written reason)

- [ ] `brakeman` runs in CI, zero unreviewed warnings at merge (each warning
      is either fixed or has an inline `# brakeman:ignore` with a one-line reason)
- [ ] `bundler-audit` runs in CI against the CVE database, blocks on known
      vulnerable gem versions
- [ ] All params are strong-parameter filtered (`params.expect` / `.require.permit`)
      — no raw `params` passed to `create`/`update`
- [ ] All user-facing output goes through Rails' default HTML escaping — no
      `raw`, `html_safe`, or `.html_safe` on anything derived from user input
      or an external API response (including LLM output — see AI-specific below)
- [ ] SQL is parameterized — no string interpolation into `where`, `find_by_sql`,
      or raw SQL fragments with untrusted input
- [ ] Mass-assignment protection verified on every model that accepts nested
      attributes
- [ ] Secrets live in `Rails.application.credentials` or environment
      variables, never committed to the repo, never logged
- [ ] `Rack::Attack` or equivalent rate limiting on auth endpoints
      (login, password reset, signup) at minimum
- [ ] CSRF protection on, not globally disabled (`protect_from_forgery` default)
- [ ] Authorization checked on every action that touches another user's
      data — not just authentication, enforced via **Pundit** policies
      (see rationale below), applied consistently, not ad hoc
      `current_user.id == record.user_id` scattered inline

## Authorization: Pundit

Chosen over Action Policy for this template. Pundit's plain-PORO-per-model
policy class is a simpler mental model than Action Policy's rule-based DSL,
and it's easier to generate consistently from a template — one
`RoomPolicy`, `MembershipPolicy`, etc., each with the same predictable shape.

## What "sensitive" means in this domain (childcare platform)

Treat all of the following as PII-tier data, subject to every rule below:

- Children's full names, photos, or any identifying images
- Guardian/parent contact info (phone, email, address)
- Attendance and check-in/check-out timestamps
- Health, allergy, or medical notes
- Any free-text notes field that could contain incidental PII

## Context-dependent — judgment call, document the decision

- [ ] File upload validation: content-type allowlist, size limits, and
      (if serving user uploads) considering whether uploads need to be
      served from a separate domain/cookie-less subdomain
- [ ] Whether background job payloads containing sensitive data need
      encryption at rest in the job queue table
- [ ] Session timeout length and whether "remember me" is offered, given
      the sensitivity of the data in-app
- [ ] Whether PII gets included in error-tracking payloads (Sentry/Honeybadger)
      — scrub the fields listed above by default; only include a field if
      there's a specific debugging need and it's documented in the PR

## AI/LLM-specific

- [ ] Never render LLM output as raw HTML — treat it exactly like any other
      untrusted user input, escape by default
- [ ] Define explicitly what data gets sent to the LLM API — log/document
      the prompt-construction step so it's auditable. **No PII-tier field
      (see list above) is sent to an LLM API** unless the feature explicitly
      requires it and that's called out in the PR description
- [ ] No secrets, internal IDs, or unrelated user data leak into the prompt
      via naive interpolation (e.g., don't dump a whole ActiveRecord object
      into a prompt string — pick fields explicitly, and cover the allowlist
      with a structure test — see Testing Philosophy)
- [ ] If using structured output / function calling, validate the LLM's
      response against a schema before acting on it — don't trust it to
      always return well-formed data
- [ ] Rate-limit and cost-cap LLM-calling endpoints separately from normal
      rate limiting — a runaway loop calling an LLM API is a cost incident,
      not just an availability one
- [ ] LLM API request/response logging is scrubbed to the same PII standard
      as error tracking — it's a new place PII ends up at rest, treated no
      differently than any other log

## COPPA / child-data handling

Applies even to synthetic/take-home data, as a demonstration of awareness:

- No child data is used for AI training or fine-tuning
- No behavioral profiling of children (usage patterns, engagement scoring)
- Retention limits are documented for any child-related record, even if not
  enforced by a background job in the take-home itself
- Parental-consent language is noted in the relevant model/feature comment
  even where the take-home doesn't implement a real consent flow

## Process

- Brakeman + bundler-audit block merge, run on every PR, not just main
- New security-relevant code (auth, authorization, payment, PII handling)
  gets a second reviewer explicitly for that lens, not just general code review
- Any deliberately-skipped item above gets a one-line note in the PR
  description, not silence
