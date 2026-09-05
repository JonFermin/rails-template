# Style Guide — Basecamp / ONCE Corpus

## Core stance

Basecamp's house style optimizes for **a new engineer reading the file cold**,
not for maximum reuse or maximum abstraction. The recurring theme: push logic
*down* into small, well-named objects (models, concerns, jobs) rather than
*up* into service-object or interactor frameworks. Fewer layers to trace
through when debugging.

The patterns below are observed across Basecamp's open-source Rails apps
(once-campfire, Fizzy, Kamal-deployed small apps); the snippets are written
fresh to demonstrate each pattern, not copied from source.

## Patterns to lift

### 1. Fat-ish models are fine — if they're organized with concerns
Basecamp doesn't fear putting behavior on the model. What it avoids is an
*unorganized* fat model. Related behavior gets pulled into a `Concern` named
for what it does, not how it's implemented.

```ruby
class Message < ApplicationRecord
  include Attachable
  include Broadcastable
  include Mentionable
end
```

Each concern is small enough to read in one screen and named as a capability,
not a technical layer (`Attachable`, not `MessageAttachmentLogic`).

### 2. Skinny controllers, one action = one job
Controller actions read almost like a table of contents. Any branching or
multi-step logic gets pushed to the model or a plain Ruby object — the
controller's job is orchestration, not decision-making.

```ruby
class Rooms::MessagesController < ApplicationController
  def create
    @message = @room.messages.create!(message_params)
    broadcast_append_to @room, target: "messages", partial: "messages/message", locals: { message: @message }
  end
end
```

### 3. Minimal service-object machinery
No `Interactor`/`dry-monads`/base-class-per-action frameworks. When logic
needs to live outside a model, it's a plain object with a single public
method — see [naming-conventions.md](naming-conventions.md) for what that
method is named. No imposed base class, no `ApplicationService`.

```ruby
class RoomInvitation
  def initialize(room, inviter)
    @room, @inviter = room, inviter
  end

  def call(user)
    room.memberships.create!(user: user)
    RoomMailer.invitation(user, room, inviter).deliver_later
  end
end
```

### 4. Comments explain *why*, not *what*
Code is expected to be self-explanatory for *what* it does through naming;
comments are reserved for non-obvious *why* — a workaround, a business rule,
a gotcha that bit someone once.

### 5. No premature interfaces
No `ApplicationService`, `BaseQuery`, or abstract superclass created "in case"
a second implementation shows up. Abstraction is extracted after the second
real occurrence, not anticipated before the first.

### 6. Tests read as documentation
Minitest — see [testing-philosophy.md](testing-philosophy.md) for the
framework choice and for how test names are written.

Test files mirror the class under test 1:1, matching Rails' own default:
`app/models/room.rb` → `test/models/room_test.rb`. No custom naming scheme.

### 7. Views stay dumb
Logic-free ERB. Anything beyond a simple conditional or loop moves to a
presenter/decorator method or a model method — the view calls it, doesn't
compute it.

### 8. Naming is plain English over pattern jargon
Classes are named for the *thing* (`Room`, `Membership`, `Invitation`), not
for the *pattern* (`RoomFactory`, `MembershipRepository`). Jargon shows up
only when it earns its keep.

## Patterns to be cautious about lifting wholesale

- **SQLite in production** — a deliberate ONCE/self-hosted choice, not a
  universal recommendation; don't cargo-cult it into a multi-tenant SaaS
  context without the same constraints
- **Minimal test framework tooling** (no factory_bot, hand-rolled fixtures in
  some repos) — works for a small, stable team; this template uses
  `factory_bot` instead (see Testing Philosophy) since object graphs here are
  more complex than a single-team internal tool

## N+1 prevention

Eager-loading decisions live in a **named scope on the model**
(`Room.with_recent_messages`), not as an inline `.includes` scattered across
controllers. This keeps the query-shaping decision next to the query it
belongs to and matches "views/controllers stay dumb, logic lives on the
model."

```ruby
class Room < ApplicationRecord
  scope :with_recent_messages, -> { includes(:messages) }
end
```
