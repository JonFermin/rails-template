# The Rails Doctrine — Nine Tenets

> Source: DHH / rubyonrails.org, "The Rails Doctrine." Restated below, each
> with a note on how it shapes decisions in this template.

## 1. Optimize for programmer happiness
Rails prioritizes the experience of the person writing the code, on the bet
that a happy, unblocked developer produces better software faster than one
grinding through ceremony.

**Applied here:** favor Rails-generator defaults over hand-rolled boilerplate;
don't add a gem or abstraction whose main cost is developer friction unless
it buys something concrete (safety, performance, correctness).

## 2. Convention over Configuration
A framework that makes decisions for you (file naming, folder structure,
REST routing) removes thousands of trivial choices, leaving energy for the
decisions that actually matter to the domain.

**Applied here:** don't fight Rails' naming/structure conventions to save a
few characters or satisfy a personal preference — the reviewer is scoring
"does this look like idiomatic Rails," not "did they invent something clever."

## 3. The menu is omakase
Rails ships an opinionated, curated default stack (Hotwire, Solid Queue,
Minitest, etc.) rather than a buffet of unopinionated choices. You can
swap pieces, but the default path is deliberately chosen for you.

**Applied here:** default to Rails 8's actual defaults (Solid Queue over
Sidekiq, Hotwire over a SPA framework, `rubocop-rails-omakase` over Shopify
or Standard, Minitest over RSpec) unless there's a specific, documented
reason to deviate — deviation is a decision, not a reflex.

## 4. No one paradigm
Ruby and Rails don't force pure OOP, pure functional, or pure anything —
they let the problem dictate the style at the point of use.

**Applied here:** don't force every piece of logic into a single pattern
(e.g., "everything must be a service object"). A model method, a plain Ruby
object, and a Rails concern are all legitimate — pick per situation.

## 5. Exalt beautiful code
Code is read far more than it's written, and Rails treats readability and
aesthetics as first-class engineering values, not decoration.

**Applied here:** this is the whole point of the other docs in this
collection — rubocop conventions, the style corpus, naming clarity — all in
service of this tenet specifically.

## 6. Provide sharp knives
Rails gives you powerful, sometimes dangerous tools (`method_missing`,
monkey-patching, raw SQL escape hatches) and trusts you not to cut yourself,
rather than removing the capability entirely.

**Applied here:** use the sharp tools sparingly and only when they're
clearly the right call — and when you do, comment *why*, since a sharp knife
used silently is exactly the kind of thing a reviewer flags as a red flag
rather than a strength.

## 7. Value integrated systems
Rails is a full-stack framework by design — ORM, views, jobs, and cable are
meant to work together, not be swapped for best-of-breed alternatives at
every layer.

**Applied here:** lean on ActiveRecord, ActionMailer, Solid Queue/Cable as an
integrated set rather than reaching for point solutions (a separate ORM, a
separate job framework) unless there's a concrete gap Rails doesn't cover.

## 8. Progress over stability
Rails is willing to break backward compatibility to keep moving forward,
trusting the upgrade path over freezing old decisions in place forever.

**Applied here:** build against current Rails 8 idioms, not defensively
coded patterns that hedge against an older Rails version — this is a
greenfield project, so use the newest sanctioned conventions without
apology.

## 9. Push up a big tent
Rails deliberately serves a wide range of skill levels and use cases rather
than optimizing only for expert users — accessibility to newcomers is a
design goal, not an accident.

**Applied here:** favor code a mid-level engineer can follow without
tribal knowledge over code that only reads cleanly to someone who already
knows the "trick" — this cuts against clever metaprogramming for its own
sake.

## Tenet 5 vs. Tenet 6

The one real tension worth naming explicitly: sharp knives (6) and beautiful
code (5) pull against each other. A `method_missing` trick or raw SQL escape
hatch can be the *fewest lines* solution but the *least legible* one. When
they conflict in this template, legibility wins — reach for the sharp knife
only when the "beautiful" alternative genuinely doesn't exist, and comment
the tradeoff inline when you do.
