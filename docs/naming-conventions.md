# Naming Conventions

## Guiding principle

A class, method, or variable name should answer "what is this / what does it
do" for someone who has never seen the codebase, without needing to open the
file. If the name requires the reader to already know the pattern being
used, it has failed.

## Models

- Singular noun, the domain object itself: `Room`, `Membership`, `Message`
- No suffixes that describe the layer (no `RoomModel`) — Rails' naming
  convention already tells you it's a model via its location
- Join/association models get a name for the *relationship*, not a mashup of
  the two table names: `Membership` (not `RoomUser` or `RoomsUsersJoin`)

## Concerns

- Named for the **capability** they add, as an adjective or `-able` form:
  `Attachable`, `Broadcastable`, `Archivable`
- Not named for the technical mechanism: avoid `RoomCallbacks`,
  `MessageHelperMethods` — these describe implementation, not capability
- A concern should be extractable to a one-sentence description: "this makes
  a model attachable to files." If you can't state that in one sentence, it's
  probably not cohesive enough to be a concern yet.

## Service / plain Ruby objects

- Named for the **action or process**, as a noun phrase or gerund:
  `RoomInvitation`, `MessageBroadcaster`, `PasswordReset`
- Avoid generic technical suffixes that carry no domain meaning:
  `RoomService`, `RoomManager`, `RoomHandler` — "Service"/"Manager"/"Handler"
  describe that *something* happens, not *what*
- Public method is always **`#call`**, project-wide. This is the de facto
  Ruby community convention (`SomeService.new(...).call`), unambiguous, and
  doesn't require inventing a bespoke verb per class.

## Jobs

- Named for what gets done, ending in `Job` per Rails convention:
  `RoomInvitationJob`, `WeeklyDigestJob`
- The job class stays thin — it should read as "what triggers, what runs,"
  with the actual logic delegated to a model or plain object

## Controllers

- Named for the **resource**, plural, nested to match the route:
  `Rooms::MessagesController`, not `MessageCreationController`
- Actions stick to the 7 RESTful verbs wherever possible; a custom action
  name (`archive`, `duplicate`) should read as a verb a user would recognize

## Booleans

- Predicate methods end in `?` and read as a yes/no question:
  `archived?`, `member?(user)` — never `is_archived` or `get_archived_status`
- Boolean columns/variables: `archived`, not `is_archived` — Rails
  auto-generates the `?` method, so the raw attribute doesn't need the prefix

## Variables

- Loop/block variables named for the singular of the collection:
  `rooms.each { |room| ... }`, not `rooms.each { |r| ... }` or
  `rooms.each { |item| ... }`
- Avoid abbreviations that save fewer than ~4 characters — `msg` saves
  nothing over `message` and costs a reader a half-second of decoding

## What to avoid project-wide

- Hungarian notation or type prefixes (`strName`, `arrRooms`)
- Generic bucket names (`data`, `info`, `obj`, `result`) when a domain name
  is available — `result` is acceptable only in genuinely transient/throwaway
  local scope, never as an ivar or method return that escapes the method
- Cleverness/puns in production code names — fine in a test fixture
  (`users(:ringo)`), not in a class that ships

## AI-related classes

Namespace under **`Ai::`**, with provider-agnostic names inside it:
`Ai::RoomSummarizer`, not `OpenAiRoomSummarizer`. The provider (OpenAI,
Anthropic, etc.) is an injected/configured dependency of the class, never
part of its name — swapping providers shouldn't require a rename.
