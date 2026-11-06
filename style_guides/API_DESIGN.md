# API design for forward compatibility

An SDK API is for years, not just for the one PR you are working on. A signature
committed today is one we have to keep supporting until we ship a major version bump.
This guide is about choosing shapes that let an API grow in a minor release.

It applies to every Stream Flutter SDK (core, chat, video, feeds). The other
repositories link here, or to a single section, rather than keeping their own copy.
It is part of the [stream-core-flutter style guide](../STYLE_GUIDE.md), which wins
where the two disagree.

## Design for the second version

Most breaking changes are not bugs; they come from an API that could not grow. When
you add a public member, ask what the next feature request will need from it — one
more value in a callback, one more state, one more option — and choose the shape that
takes that addition as a minor release. The sections below are the shapes that
have repeatedly forced breaking releases in `stream-chat-flutter` and
`stream-video-flutter`, and the shapes that would have avoided them.

What counts as breaking is wider than "a signature changed". All of these break a
consumer who compiled fine before:

- adding a parameter to a function type (typedef, callback, builder);
- adding a value to an enum, or a subclass to a `sealed` class, that consumers switch
  on exhaustively;
- adding an abstract member to a class consumers `implements` or `extends`;
- adding a required parameter, or reordering or renaming a positional one;
- changing a return type (`void` → `Future<void>`, `T` → `T?`) or a field type;
- renaming or adding a field on a record type that appears in the public API.

## Pass callbacks and builders a single details object

A callback or builder takes the `BuildContext` (if it needs one) plus **one** object
carrying everything else. New information is a new field on that object, which is not
a breaking change. Every positional argument beyond that is a promise that the
callback will never learn anything else.

```dart
// BAD: the next piece of information is a breaking change.
typedef StreamAttachmentTapCallback = void Function(Message message, Attachment attachment);

// GOOD: new information is a new field on StreamAttachmentTapDetails.
typedef StreamAttachmentTapCallback = void Function(BuildContext context, StreamAttachmentTapDetails details);
```

The same applies to callbacks that start with no arguments: a `VoidCallback` that
later needs a reason or a source is a breaking change. If there is any plausible
payload, start with a details object, even an empty one.

Name the object after its role: `…Details` for callback payloads (Flutter's own
`TapUpDetails`, `DragEndDetails`) and `…Props` for builder inputs, matching
`StreamComponentBuilder<T> = Widget Function(BuildContext context, T props)`. Give the
class a `const` constructor, make every field added after the first release optional
or defaulted, and add `copyWith` when consumers are expected to tweak and forward it.

Builders that let a consumer wrap or adjust the default rendering should receive the
default's inputs (`props`) from day one, so they can rebuild the default widget with a
change rather than re-implementing it.

Decide the callback's return type up front too. If the SDK might ever need to know
whether the consumer handled the event, or wait for it, return `FutureOr<bool>` (or a
result object) from the first release; turning `void` into `bool` later breaks every
implementation.

History:

- Chat's attachment tap callback went from `void Function(Message message, Attachment
  attachment)` to `FutureOr<bool> Function(BuildContext context, Message message,
  Attachment attachment)` in one breaking change (v10, #2426): it gained a context
  and a return value.
- Chat's message builder changed shape three times (1.x added a default widget
  argument, 9.x renamed its type, 10.0 replaced it with `(context, message, props)`),
  and 5.2.0 had to add `bottomRowBuilderWithDefaultWidget` next to `bottomRowBuilder`
  because the original typedef could not grow.
- Video's ten `Widget Function(BuildContext, Call, CallState)` builders were each
  deprecated and replaced by a parallel `*WidgetBuilder` (0.10.0, removed in 1.0.0).
  The replacement, `CallWidgetBuilderWithData<T extends CallbackData>`, carries the
  lesson in its own doc comment: add properties to the data object, never to the
  function. Livestream builders added afterwards repeated the mistake and were
  deprecated again (#1118).
- Video's `onCallDisconnected` went from `VoidCallback` to
  `void Function(CallDisconnectedProperties)` (0.9.0). By contrast,
  `LivestreamNotConnectedBuilder` shipped with a properties object and later gained
  `isMigrating` and `isReconnecting` without a break.
- Core's `MarkdownTapMentionCallback = void Function(String displayText, String id)`
  could not take a mention type, so #120 added `MarkdownTapAnyMentionCallback` next
  to it instead of extending it.

## Decide whether a set of values is closed before using an enum or `sealed`

Consumers switch exhaustively on public enums and sealed classes — the style guide
tells them to ([Avoid `if` chains or `?:` with enum values](../STYLE_GUIDE.md#avoid-if-chains-or--with-enum-values)).
That makes adding a value or subclass a breaking change for them. Use an `enum` or
`sealed` hierarchy only when the set is closed, or when adding a member is something
we are willing to ship in a major release.

A set is closed when it is **closed by definition**: no future value can exist
(`Axis`, `TextDirection`, ascending/descending, "delete for me" vs "for everyone").
A set is not closed because today's list is complete. Anything enumerated by a design
spec, a product decision, or the backend will grow, however settled it looks — so in
practice almost every design-system enum is open.

For sets that will grow, pick a type consumers cannot switch on exhaustively:

- **Design scales** (sizes, variants, emphasis levels): an `@immutable` class with a
  public `const` constructor and `static const` presets, where each preset carries
  the metrics that go with it.

  ```dart
  @immutable
  class StreamAvatarSize {
    const StreamAvatarSize({required this.diameter, required this.borderWidth});

    static const sm = StreamAvatarSize(diameter: 24, borderWidth: 1);
    static const lg = StreamAvatarSize(diameter: 40, borderWidth: 1);

    final double diameter;
    final double borderWidth;

    // operator ==, hashCode, and a static lerp.
  }
  ```

  Adding a preset is not breaking, and a consumer who needs a size between two
  presets constructs one instead of waiting for a release. Required constructor
  parameters take over the job of the exhaustive `switch`: a size cannot be added
  without its metrics. A class can also be lerped in a theme, which an enum cannot.
  Turning an existing enum into this shape keeps `StreamAvatarSize.lg` and `.lg`
  compiling; only `switch`, `.values`, `.name`, and `.index` break.
- **Values that come from the backend** (reasons, types, roles, statuses): an
  extension type over `String` with `static const` instances, like
  `StreamMentionType`. Unknown values from a newer backend still round-trip instead
  of failing to parse, and adding a constant is not breaking.
- **Values consumers may add themselves**: a non-sealed class (or `abstract` class)
  with `static const` instances or subclasses, so a custom value is a subclass rather
  than a fork.
- **States that may need to carry data**: a class hierarchy from the start. An enum
  value cannot hold a payload; a subclass can.

When an `enum` or `sealed` type that may grow has to stay one, say so in its dartdoc
and tell consumers to keep a wildcard (`_`) branch in their `switch`. Dart cannot
enforce this, so it is a fallback, not a substitute for choosing an open type.

History:

- Core's `enum StreamAvatarSize` was treated as closed because it matched the design
  spec, until the ringing screens needed a 104px avatar (#189). The same PR added
  sizes to the avatar group and online indicator enums. Our own gallery stopped
  analyzing because its size tables switch exhaustively — as would any consumer's
  `switch`. A 64px avatar that sat between two named sizes also needed an internal
  diameter override, which a constructible size would not.

- Chat's `enum MessageSendingStatus` could not carry whether a delete was hard, so it
  was replaced by a freezed `MessageState` (6.7.0, removed in 7.0.0).
- Chat's `enum AttachmentPickerType` became a `sealed class` with an open
  `CustomAttachmentPickerType` subclass (v10, #2293), once consumers needed their own
  picker types.
- Video added `ActionCallIncomingFailed` to the sealed `RingingEvent` in a minor
  release (1.6.0, #1323) — breaking for every exhaustive `switch (event)`.

## Model modes, not flags

A `bool` holds two states and its name fixes which one is `true`. When a third state
arrives, the parameter has to change type. Prefer an enum (or class, per the section
above) whenever a setting is a mode rather than an on/off switch, and name booleans
positively (`showX`, `includeX`) so the default never has to flip.

History:

- Chat's `MessageState.deleting({required bool hard})` became
  `deleting({required MessageDeleteScope scope})` when "delete for me" arrived (v10,
  #2394), breaking every `whenOrNull(deleting: (hard) => …)`.
- Video renamed `ignoreLocalParticipantVideo` to `includeLocalParticipantVideo`
  (0.8.0, #857), flipping both name and default.

## Group configuration into an options object

When a constructor or method takes a growing list of tuning knobs or builders, put
them on a dedicated options class (`…Options`, `…Configuration`, `…Builders`) with a
`const` constructor, defaults for every field, and `copyWith`. Adding a knob is then a
new optional field. This only works if the object can grow: required fields and
positional constructor parameters on the options class bring the problem back.

Separately, take the model or value object when the parameters describe an entity,
rather than spreading its fields over the signature.

History:

- Chat moved ~17 `*Builder` parameters and the behaviour flags off
  `StreamMessageListView` into `StreamMessageListViewBuilders` and
  `StreamMessageListViewConfiguration` (v10, #2674).
- Chat's `sendReaction(Message message, String type, {int score, Map extraData, …})`
  became `sendReaction(Message message, Reaction reaction, …)` when reactions gained
  `emojiCode` (v10, #2326).
- Video moved `maxDuration` and `maxParticipants` on `Call.getOrCreate` into
  `StreamLimitsSettings` (0.6.0), which later gained two fields without a break, and
  moved `StreamVideo` constructor flags into `StreamVideoOptions` (0.1.0).

## Use named parameters for anything optional

Optional positional parameters (`[Message? message]`) cannot be followed by named
ones and cannot be reordered, so the second optional argument forces a break. Public
methods use named parameters for everything optional.

History: chat's `addMembers(List<String> memberIds, [Message? message])` became
`addMembers(memberIds, {Message? message, bool hideHistory = false})` (5.0.0), along
with `removeMembers`, `inviteMembers`, and `update`.

## Don't add abstract members to types consumers implement

Every class a consumer may `implements` is frozen: a new abstract member breaks every
implementation. Choose the class modifier deliberately:

- `final class` for types consumers only use. We can add anything.
- `base class` (or `abstract base class`) for types consumers extend. New members
  ship with a default implementation, so subclasses keep compiling.
- `interface class` or plain `abstract class` only for genuinely small contracts that
  will not grow. If one has to grow, add the member with a default in a mixin or base
  class consumers extend, or add a separate capability interface.

Configuration that consumers override piecemeal belongs in an options object with
`copyWith`, not an interface.
→ [Group configuration into an options object](#group-configuration-into-an-options-object)

History:

- Chat added four abstract methods to `AttachmentFileUploader` (v10, #2396), and
  earlier six to `ChatPersistenceClient` (3.0.0).
- Video's `abstract class CallPreferences` has gained about a dozen abstract getters
  over time; the 1.7.0 changelog tells implementers to "add the getter to your
  implementation".

## Wrap values that might grow

A public field, return value, or controller value that is a bare collection,
primitive, or record cannot gain a sibling. Wrap it in a named class when there is a
plausible second piece of information, even if it starts with one field. Never expose
a record type in the public API: records are structural, so adding or renaming a field
is always breaking. And return something meaningful from the start — a "nothing"
return type that later needs to carry a result is a breaking change.

History:

- Chat's `StreamAttachmentPickerController extends ValueNotifier<List<Attachment>>`
  became a controller of `AttachmentPickerValue` when polls were added (9.0.0).
- Video's `Call.stats` returned a record whose fields were renamed and retyped
  (0.11.0, #1053).
- Video's `setScreenShareEnabled` went from `Future<Result<None>>` to
  `Future<Result<RtcLocalTrack>>` (0.9.0, #915).
