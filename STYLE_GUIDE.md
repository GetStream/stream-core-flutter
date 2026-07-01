# Style guide for stream-core-flutter

This style guide is adapted from the [Flutter repository's style guide](https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md).
Where our conventions differ, the divergence is called out inline so readers understand
the choice was deliberate.

The primary audience is contributors (human and AI) working inside this monorepo. If
you are integrating the design system into your own app, follow whatever style your app
uses — this guide is not meant to constrain consumers.

## Summary

Optimize for readability. Split the public API cleanly between `core.dart` and
`chat.dart`. Use relative imports inside `lib/src/`. Every component ships with a
theme, a golden test, and a Widgetbook use-case. Update the affected package's
`CHANGELOG.md` in the same PR.

## Introduction

This document describes high-level philosophy, policy decisions, and specific style
rules for the code in this monorepo. It applies to the two SDK packages (`stream_core`,
`stream_core_flutter`) and the Widgetbook gallery under `apps/design_system_gallery/`.

The linter here opts into **all** of Dart's lints via `all_lint_rules.yaml`, then
selectively disables those that don't fit; the analyzer is the source of truth for
what compiles cleanly. This guide covers the human conventions above and around the
linter.

Sections below cover:

- [Quick rules](#quick-rules) — the short checklist to skim before every change
- [Philosophy](#philosophy) — the "why" behind the rules
- [Repository structure](#repository-structure) — monorepo layout, Melos, barrel contract
- [Documentation](#documentation) — dartdoc conventions
- [Coding patterns](#coding-patterns) — asserts, dispose, equality, streams, etc.
- [Testing](#testing) — unit, widget, and golden tests
- [Naming](#naming) — identifiers, callbacks, booleans
- [Comments](#comments) — when to write them, when not to
- [Formatting](#formatting) — line length, class ordering
- [Widgets, themes, and design system](#widgets-themes-and-design-system) — components,
  theme hierarchy, Widgetbook, icons
- [Commits, PRs, and changelogs](#commits-prs-and-changelogs)


## Quick rules

The hard rules to check before opening a PR. Every rule below is expanded later in the
document; the section link is provided.

**Public API and package boundaries**

- Every new public file under `lib/src/` must be exported from exactly one of
  `core.dart` or `chat.dart`. `melos run check:barrels` enforces this and fails PR
  builds. → [Public barrel contract](#public-barrel-contract)
- No file under `lib/src/` may import a public barrel (`core.dart`, `chat.dart`,
  `stream_core_flutter.dart`). Use a relative import to the source file. →
  [Public barrel contract](#public-barrel-contract)
- `stream_core` (the pure-Dart LLC) never depends on Flutter. Anything visual or
  widget-related belongs in `stream_core_flutter`.

**Code**

- Line width: **120 characters** (configured in `analysis_options.yaml`). Comments
  and docs follow the same limit.
- Single quotes, **relative imports inside `lib/src/`** (`always_use_package_imports`
  is disabled here — a deliberate divergence from Flutter's style, favouring
  refactor-friendly relative paths inside the package).
- Trailing commas preserved, `const` wherever possible, `final` for locals that
  aren't reassigned.
- Prefer named parameters for booleans (`avoid_positional_boolean_parameters`).
- File names are `snake_case.dart` (`file_names`). Imports follow the standard order:
  `dart:` → `package:` → relative — one blank line between groups
  (`directives_ordering`).

**Design system**

- Every new component ships with:
  1. A widget file under `lib/src/components/<category>/`.
  2. A `<Widget>Theme` + `<Widget>ThemeData` in `lib/src/theme/components/`,
     annotated with `@themeGen`. → [Theme system](#theme-system)
  3. A golden test in `test/components/<name>/`.
  4. A Widgetbook use-case in `apps/design_system_gallery/`.
- Defaults live in the widget implementation (nullable theme fields, null-coalescing
  chain in `build`) — mirrors Flutter's own `AppBar`/`TabBar` pattern.
- Never hand-roll `copyWith`, `merge`, `lerp`, `==`, or `hashCode` on theme classes —
  the generator produces them. → [Theme system](#theme-system)
- Icons are generated from SVGs. Do not hand-edit the icon font or the generated
  `StreamIcons` class. → [Icons](#icons)

**Docs and comments**

- Public dartdoc describes the observable contract, not the implementation. Skip
  mentions of `BehaviorSubject`, "unmodifiable", "Stream emits X", or which internal
  type is used. → [Public docs describe the contract, not implementation](#public-docs-describe-the-contract-not-implementation)
- `_`-prefixed members receive `//` block comments, not `///` dartdoc.
- Default to zero inline `//` comments in implementation. Prefer well-named locals
  and early returns over comments explaining what code does.
- `// ignore: ...` directives do not require an explanatory comment. This is the
  repo style, not the Flutter convention.

**Process**

- Update the affected package's `CHANGELOG.md` under the `Upcoming` heading with
  labels like `### ✨ Features`, `### 🐛 Bug Fixes`, `### 🛑 Breaking / Removals`.
  → [Changelog policy](#changelog-policy)
- PR titles follow [Conventional Commits](https://www.conventionalcommits.org/):
  `fix(scope): …`, `feat(scope): …`, `refactor(scope)!: …` for breaking changes.


## A word on designing APIs

Designing an API is an art. Like all forms of art, one learns by practicing. In the
absence of one's own experience, one can attempt to rely on the experience of others.
When receiving feedback about API design from an experienced API designer, they will
sometimes seem unhappy without being able to articulate why. When this happens,
seriously consider that your API should be scrapped and a new solution found.

This requires a different and equally important skill: not getting attached to your
creations. Try many wildly different APIs, then write code that uses them. Throw away
APIs that feel frustrating or lead to buggy code.

An SDK API is for years, not just for the one PR you are working on. A design system
is even worse — every widget lands in downstream apps, and each field of each theme
becomes a compat constraint. A signature committed today is one we have to keep
supporting until we ship a major version bump.


## Philosophy

### Lazy programming

Write what you need and no more, but when you write it, do it right.

Avoid implementing features you don't need. You can't design a feature without knowing
what the constraints are. Implementing features "for completeness" results in unused
code that is expensive to maintain, learn about, document, test, etc.

Avoid workarounds. Workarounds merely kick the problem further down the road, but at
a higher cost. Take the time to fix a problem properly rather than being the one who
fixes everything quickly but leaves cleanup for later.

### Write Test, Find Bug

When you fix a bug, first write a test that fails, then fix the bug and verify the
test passes.

When you implement a new component or feature, write tests for it (widget tests and
golden tests for visible components). If something isn't tested, it is very likely to
regress or get "optimized away" during a refactor.

Don't submit code with the promise to "write tests later".

### Avoid duplicating state

There should be no objects that represent live state that reflect some state from
another source, since they are expensive to maintain. **Keep only one source of
truth**, and **don't replicate live state**.

Concretely for this repo: theme values flow one direction (theme data → widget
`build`); widgets don't cache computed theme values. `ChangeNotifier`-driven state
(controllers) is the source of truth; snapshots in local `State` are stale by design.

### Getters feel faster than methods

Property getters should be efficient (e.g. returning a cached value or an O(1) table
lookup). If an operation is inefficient, it should be a method instead.

Similarly, a getter that returns a `Future` or `Stream` should not kick off the work
represented by the future. The work should be started from a method or constructor,
and the getter should return the preexisting future or stream.

### No synchronous slow work

There should be no public APIs that require synchronously completing an expensive
operation (e.g. blocking on a network call). Expensive work should be asynchronous
and the type signature (`Future`, `Stream`) should show it.

### Layers

The SDK is two-package layered:

```text
stream_core            # Pure Dart — WebSocket (RxDart), HTTP (Dio), models
  └── stream_core_flutter  # Flutter UI primitives + design system
```

Convenience APIs belong at the layer above the one they are simplifying. Do not push
a "convenience" API down a layer just to have it available to lower layers — that
pulls higher-level concepts into places they don't belong.

`stream_core_flutter` further splits its public API through two barrels: `core.dart`
(cross-product primitives) and `chat.dart` (chat-domain widgets). See
[Public barrel contract](#public-barrel-contract).

### Avoid interleaving multiple concepts together

Each API should be self-contained and should not know about other features.
Interleaving concepts leads to complexity.

- Widgets that take a `child` should be entirely agnostic about the type of that
  child. Don't use `is` checks to act differently based on the type of the child.
- Prefer immutable data models. `Message`, `User`, and friends are immutable. Themes
  are immutable. Callers get a new instance from `copyWith`, never mutation.

### Avoid secret (or global) state

A function should operate only on its arguments and, if it is an instance method,
data stored on its object. Global state makes code hard to test, hard to reason
about, and hard to reuse.

Theme values are threaded through `StreamTheme.of(context)` — an
`ThemeExtension` lookup that resolves to a concrete `StreamTheme`. We do
not have singletons for theme, colors, or design tokens.

### Prefer general APIs, but use dedicated APIs where there is a reason

Having dedicated APIs for performance reasons is fine. If one specific operation is
expensive using the general API but could be implemented more efficiently using a
dedicated API, that is where a dedicated API belongs.

### Avoid APIs that encourage bad practices

Don't provide APIs that walk entire trees, or that encourage O(N²) algorithms, or
that encourage sequential long-lived operations where the operations could be run
concurrently. Similarly, if an operation is expensive, that expense should be
represented in the API (e.g. by returning a `Future` or a `Stream`).

### Avoid heuristics and magic

Predictable APIs that give the developer control are generally preferred over APIs
that mostly do the right thing but don't give the developer any way to adjust the
results. Predictability is reassuring.

### Solve real problems by literally solving a real problem

Where possible, partner with a real customer (an internal Stream product team or an
external integrator) who wants the feature and is willing to help you test it. Only
by actually using a feature in the real world can we be confident it is ready.

### Start designing APIs from the closest point to the developer

When we create a new feature that requires a change across the stack, it's tempting
to design the lowest-level API first, since that's the closest to the "interesting"
code. Design the top-level API first — the widget or theme field a caller will
touch — then work down to the primitives.

### Only log actionable messages to the console

If the logs contain messages users can safely ignore, they will do so, and eventually
their logs will be so chatty they'll miss the critical messages. Only log actual
errors and actionable warnings.

Use `Logger` from `stream_core/src/logger/` at an appropriate level. `avoid_print` is
disabled repo-wide (`analysis_options.yaml`) but that's a temporary allowance — in
`stream_core_flutter`, prefer `debugPrint` (which respects the framework's rate
limiter) over raw `print`.

### Error messages should be useful

Every time you find the need to report an error, consider how you can make this the
most useful and helpful error message. Put yourself in the shoes of whoever sees it.
**Every error message is an opportunity to make someone love our product.**


## Policies

### Workarounds

Temporary workarounds (`// ignore` hacks, monkey-patches of upstream APIs) should be
documented with a link to the tracking issue and a plan for removing them. Long-term
workarounds should be turned into proper fixes.

### Avoid abandonware

Code that is no longer maintained should be deleted, not commented out. Commented-out
code bitrots quickly and will confuse people maintaining the code.

If a component is being deprecated, follow the deprecation policy: annotate with
`@Deprecated('Use X instead.')`, add a `### 🛑 Breaking / Removals` CHANGELOG entry,
and keep the deprecated API for at least one minor release before removal.

### Copyright and licensing

New source files should carry the standard header used elsewhere in the repo.
Third-party code must live in a `third_party/` subdirectory of the package with a
`LICENSE` file that describes the license and a `README` describing its provenance.


## Repository structure

### Monorepo layout

```text
stream-core-flutter/
├── melos.yaml                # Workspace + centralized dependencies
├── analysis_options.yaml     # Delegates to all_lint_rules.yaml + selective disables
├── all_lint_rules.yaml       # Opt-in-all Dart lint set
├── STYLE_GUIDE.md            # This file
├── CLAUDE.md                 # AI-agent pointer to this guide + repo overview
├── packages/
│   ├── stream_core/          # LLC — pure Dart (RxDart WebSocket, Dio HTTP)
│   └── stream_core_flutter/  # Flutter UI + design system
├── apps/
│   └── design_system_gallery/  # Widgetbook-based interactive showcase
└── scripts/                  # Repo-level helpers
```

### Public barrel contract

`stream_core_flutter` exposes multiple narrow public barrels so each Stream product
SDK (chat today; video, feeds, … in the future) can pull in just the primitives it
needs without paying for other products' code:

- `package:stream_core_flutter/core.dart` — cross-product primitives, theme tokens,
  the component factory. Safe for any Stream SDK.
- `package:stream_core_flutter/chat.dart` — chat-specific widgets (message bubble,
  composer attachments, reactions, …). Chat SDKs import this **alongside**
  `core.dart`.
- `package:stream_core_flutter/stream_core_flutter.dart` — deprecated convenience
  barrel that re-exports the others. Will be removed at 1.0.0.

Additional product barrels (`video.dart`, `feeds.dart`, …) can be added when a new
Stream product needs domain-specific widgets that don't belong in `core.dart`. Each
new barrel gets its own entry in `check_barrels.yaml` under `barrels:`, and the
same rules apply.

Rules enforced by `melos run check:barrels` (config at
`packages/stream_core_flutter/check_barrels.yaml`, wired into CI):

1. Every public file under `lib/src/` must appear in exactly **one** listed barrel.
   No duplicates, no orphans, no dangling exports.
2. No file under `lib/src/` may import a public barrel (`core.dart`, `chat.dart`,
   `stream_core_flutter.dart`, and any future product barrel). Use a relative
   import to the source file — barrels are for **consumers**, not internal code.
3. Anything under a directory listed in `check_barrels.yaml`'s `internal_dirs` is
   excluded from coverage. Use this for figma-generated tokens and other
   implementation-only artefacts (currently: `lib/src/theme/primitives/internal`).

When adding a new public widget or theme: create the file under `lib/src/…`, then
add an `export 'src/…/my_file.dart';` line to the appropriate barrel — `core.dart`
if the widget is product-agnostic, `chat.dart` if it's chat-specific, or a new
product barrel if you're introducing one. The check fails on PR if you forget.

### Dependency management

Dependencies for all packages are centrally managed in `melos.yaml` under
`command.bootstrap.dependencies`. Do **not** edit version constraints directly in an
individual package's `pubspec.yaml` — update `melos.yaml` and run `melos bootstrap`.

When you add a new dependency:

1. Add it to `melos.yaml` under `command.bootstrap.dependencies` (or
   `dev_dependencies`).
2. Add the bare package name to the affected `pubspec.yaml` files.
3. Run `melos bootstrap`.

### Generated code

Generated files (`*.g.dart`, `*.freezed.dart`, `*.g.theme.dart`) are excluded from
analysis (`packages/*/lib/**/*.*.dart` in `analysis_options.yaml`). Do not edit them
by hand. If a generated file is stale, run:

```bash
melos run generate:all
```

Sub-tasks:

- `melos run generate:icons` — regenerates the icon font from SVGs in
  `assets_source/icons/`. → [Icons](#icons)
- `melos run gen-l10n` — regenerates localization ARB output.


## Documentation

Public dartdocs are encouraged but currently **not lint-enforced**
(`public_member_api_docs` is disabled in `analysis_options.yaml`; this is temporary
while the repo catches up). New public code should still ship with dartdocs.

In general, follow the [Effective Dart documentation guide](https://dart.dev/effective-dart/documentation)
except where this page contradicts it.

### Answer your own questions straight away

When working on the SDK, if you find yourself asking a question about our systems,
place the answer into the documentation where you first looked. That way, the docs
consist of answers to real questions, in the places where people would look to find
them.

### Avoid useless documentation

If someone could have written the same documentation without knowing anything about
the class other than its name, then it's useless.

```dart
// BAD:
/// The size.
final StreamAvatarSize size;

// GOOD:
/// The diameter of the avatar in logical pixels.
///
/// Defaults to [StreamAvatarSize.md] (32px). Use a preset like
/// [StreamAvatarSize.sm] rather than a raw pixel value to stay aligned with the
/// design system.
final StreamAvatarSize size;
```

### Public docs describe the contract, not implementation

Dartdoc describes the observable behavior of an API, not how it happens to be
implemented today. Skip mentions of:

- Specific implementation types the caller doesn't see (e.g. `BehaviorSubject`,
  `UnmodifiableListView`)
- Internal caching strategies unless the caller's code needs to know
- "Stream emits X" style — describe what values are produced and when, not the
  stream mechanics

**Exception:** public base classes and mixins in the type signature (e.g.
`extends ValueNotifier<T>`, `with ChangeNotifier`) are part of the contract, not a
leak. Mentioning them helps callers reach for `ValueListenableBuilder`.

### No Flutter internals in comments

Do not justify code by cross-referencing Flutter framework internals ("matching
Flutter's `AppBar`", "same behavior as `MaterialButton`"). Describe what the code
does directly. This applies even here, where we deliberately follow Flutter's
`AppBar`/`TabBar` pattern for defaults — say "defaults live in the widget's build,
not the theme data" without name-dropping.

### Writing prompts for good documentation

If you're stuck coming up with useful documentation, some prompts:

- If someone is looking at this documentation, they have a question they couldn't
  answer by guessing or reading the code. What could that question be?
- What might a caller want to know that isn't obvious from the type?
- Are there edge cases outside the normal range (negative numbers, empty lists,
  `null`, `disabled`, `loading`)?
- Does this member interact with any others?
- Are there lifecycle considerations? Who owns the object? Who calls `dispose`?

### Avoid empty prose

```dart
// BAD:
/// Note: It is important to be aware of the fact that in the absence of an
/// explicit value, this property defaults to 2.

// GOOD:
/// Defaults to 2.
```

Do not start sentences with "Note:" or "Note that". It adds nothing.

### Leave breadcrumbs in the comments

If a class is typically obtained via some mechanism other than its constructor,
mention that in the class documentation.

Use `See also:` to link to related APIs:

```dart
/// See also:
///
///  * [StreamAvatar], which uses these size variants.
///  * [StreamAvatarThemeData.size], for setting a global default size.
```

Each `See also:` line ends with a period. Prefer "which…" over parenthetical
descriptions.

### Refactor the code when the documentation would be incomprehensible

If writing the documentation proves difficult because the API is convoluted, rewrite
the API rather than trying to document it.

### Use correct grammar

Avoid starting a sentence with a lowercase letter. End all sentences with a period.

```dart
// BAD:
/// [foo] must not be null.

// GOOD:
/// The [foo] argument must not be null.
```

### Use the passive voice; recommend, do not require

Avoid "you" and "we". Rather than telling someone to do something, use "Consider",
as in "To obtain the foo, consider using [bar]."

Never use "simply", or say the reader need "just" do something.

### Private members use `//`, not `///`

`_`-prefixed members receive `//` block comments, not `///` dartdoc. Dartdoc
machinery (cross-references, IDE hover from outside the library) buys nothing for
library-private surfaces, and using `///` on private members makes the tooling
suggest they should be public.

```dart
// GOOD (private member):
// Cached because computing the mask involves iterating every pixel.
Path? _cachedClipMask;

// GOOD (public member):
/// The diameter of the avatar in logical pixels.
final double size;
```

### Provide sample code

Include a short `dart` code block in the dartdoc for widgets and complex APIs.
Longer, runnable examples belong in `apps/design_system_gallery/` (Widgetbook).

Do not use `{@tool dartpad}` — we don't have infrastructure to render it.

### Clearly mark deprecated APIs

Use `@Deprecated('Use X instead.')`. Add a `CHANGELOG.md` entry under
`### 🛑 Breaking / Removals` describing the deprecation and pointing at the
replacement.

### Dartdoc-specific requirements

The first paragraph of any dartdoc section must be a short, self-contained sentence
explaining the purpose of the item. Subsequent paragraphs elaborate. Avoid multi-
sentence first paragraphs — the first paragraph gets extracted for tables of
contents.

When referencing a parameter, use backticks. When referencing a parameter that also
corresponds to a property, use square brackets instead.

Avoid using "above" or "below" to reference other dartdoc sections. Dartdoc pages
are often viewed in isolation.


## Coding patterns

The linter enforces most of the rules in this section — see
[`analysis_options.yaml`](analysis_options.yaml) (which delegates to
[`all_lint_rules.yaml`](all_lint_rules.yaml)) for the authoritative list. Rules
highlighted below either extend a lint (adding rationale or a repo-specific pattern)
or capture conventions the linter can't check.

### Use asserts liberally to detect contract violations

`assert()` lets us verify invariants without paying a cost in release mode, because
Dart only evaluates asserts in debug mode.

Use asserts for conditions that should be impossible unless there is a bug. Do not
use asserts to validate user input or network data (those must throw at runtime).

Assert messages are **not required** in this repo (`prefer_asserts_with_message` is
disabled). Add a message when the invariant isn't self-evident from the expression;
otherwise a bare `assert(condition)` is fine.

```dart
// Fine — the expression is self-explanatory.
assert(size > 0);

// Better with a message — the invariant needs context.
assert(!_disposed, 'StreamAvatarController used after dispose()');
```

### Prefer specialized functions, methods, and constructors

Use the most relevant constructor when there are multiple options.

```dart
// BAD:
const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0);

// GOOD:
const EdgeInsets.symmetric(vertical: 8.0);
```

### Minimize the visibility scope of constants

Prefer a local `const` or a `static const` in a relevant class over a global
constant. Global constants that _do_ need to exist should be prefixed with `k`.

### Avoid `if` chains or `?:` with enum values

Use `switch` (statement or expression) with exhaustive cases when examining an enum;
the analyzer will warn if you miss a value. Avoid `default:` unless the switched
value isn't statically known — a default clause silences the exhaustiveness check.

```dart
// GOOD:
final radius = switch (size) {
  StreamAvatarSize.xs => 10.0,
  StreamAvatarSize.sm => 12.0,
  StreamAvatarSize.md => 16.0,
  StreamAvatarSize.lg => 20.0,
  StreamAvatarSize.xl => 24.0,
  StreamAvatarSize.xxl => 40.0,
};
```

### Prefer explicit types on public APIs, avoid `dynamic`

The analyzer runs with `strict-inference: true` and `strict-raw-types: true`.
Combined with the linter, this means:

- All public API members should have explicit type annotations — parameters, fields,
  and return types (`always_declare_return_types`, `type_annotate_public_apis`).
- Raw types (`List`, `Map`, `Future` without a type argument) are flagged; declare
  the element type.
- Avoid `dynamic`. If the type is unknown, prefer `Object?` and casting; `dynamic`
  disables all static checking.

For local variables, follow the `omit_local_variable_types` lint — omit the
annotation when the type is obvious from the initializer, but keep it when it isn't.

### Import conventions inside the package

Inside `packages/<pkg>/lib/src/`, use **relative imports**
(`always_use_package_imports` is disabled here — a deliberate divergence from
Flutter's style guide, matching Dart's Effective Dart recommendation for
package-internal code).

```dart
// GOOD — relative for in-package files.
import '../../theme/components/stream_avatar_theme.dart';
import '../common/stream_network_image.dart';

// GOOD — package: for external and cross-package imports.
import 'package:flutter/material.dart';
import 'package:stream_core/stream_core.dart';
```

Do not use `package:stream_core_flutter/...` inside `lib/src/` — that path is
reserved for consumers, and using it internally would round-trip through the public
barrel (which the `check:barrels` rule also forbids).

Directive order: `dart:` → `package:` → relative, with one blank line between
groups (`directives_ordering`).

### Guidelines for `extension`s

Extension methods let you add additional functionality to an existing type.
When choosing between declaring a regular instance method and an extension
method, consider the trade-offs. Extension methods are resolved statically and
cannot be overridden. Furthermore, misusing extension methods can pollute IDE
suggestions and cause naming collisions.

Don't declare an extension method when declaring a regular method will do.

Don't use extension methods if the end developer might want to override the
extension method's implementation. Extension methods cannot be overridden.

Don't create extension methods with the same name on the same type in separate
libraries. This causes collisions if both libraries are imported.

### Avoid `FutureOr<T>` in public APIs

`FutureOr` is a Dart-internal type used to explain aspects of the `Future` API.
`avoid_futureor_void` is enabled here. In public APIs, avoid the temptation to
create APIs that are both synchronous and asynchronous — it results in APIs that
are less type-safe and harder to reason about.

You may use `FutureOr` for callback parameters where the caller's callback may or
may not be async.

### Avoid `@visibleForTesting`

The `@visibleForTesting` annotation marks a public API such that callers get a
warning outside `test/` directories. The API is still public.

Rather than rely on it, design APIs so they are testable through the public API
without exposing sensitive internals. If a member is _only_ used for testing,
prefix its name with `debug` or move it into the test file.

### Never add timeouts, and avoid other race conditions

If you look for an available port, then try to open it, several times a week some
other code will open that port between your check and your open. Similarly, timeouts
based on how long something "usually takes" will trigger spuriously.

Race conditions are the primary cause of flaky tests. Avoid timeouts entirely. Wait
for a triggering event.

### Avoid magic numbers

Numbers should be understandable. If the derivation isn't obvious, either restructure
the expression to be self-describing or add a comment.

```dart
// BAD:
final radius = 4.24264068712;

// GOOD:
final radius = 3.0 * math.sqrt(2);
```

### Perform dirty checks in setters

When defining mutable properties that require notifying listeners on change:

```dart
StreamAvatarSize get size => _size;
StreamAvatarSize _size;
set size(StreamAvatarSize value) {
  if (_size == value) {
    return;
  }
  _size = value;
  notifyListeners();
}
```

Do not perform side effects in setters other than marking the object dirty and
updating internal state.

### Common boilerplates for `operator ==` and `hashCode`

For value classes without generated equality, use:

```dart
@override
bool operator ==(Object other) {
  if (identical(other, this)) {
    return true;
  }
  return other is Foo
      && other.bar == bar
      && other.baz == baz;
}

@override
int get hashCode => Object.hash(bar, baz);
```

Themes get their `==`/`hashCode` from `theme_extensions_builder`; models often use
`equatable`. Do not hand-roll equality when a generator or an `Equatable` base can
do it.

### Override `toString` on debuggable objects

For classes that appear in error messages or logs, override `toString`. Avoid bare
`$runtimeType` — use `objectRuntimeType(this, 'ClassName')`, which strips runtime
type at release-mode.

### Be explicit about `dispose()` and the object lifecycle

If a class holds a `StreamSubscription`, a `Listenable` listener, a
`ChangeNotifier`, or a persistent connection, provide a `dispose()` method and
document who is responsible for calling it.

The `close_sinks`, `cancel_subscriptions`, and
`use_late_for_private_fields_and_variables` lints catch some cases; the rest is a
review responsibility.

### No InheritedWidget lookup in `initState`

`InheritedWidget.of(context)` and `.maybeOf(context)` use
`context.dependOnInheritedWidgetOfExactType`, which is forbidden inside `initState`.
Move the lookup to `didChangeDependencies` (for lifecycle-scoped lookups) or
`didUpdateWidget` (for reactions to prop changes). Reading the inherited widget in
`initState` throws in debug mode and returns the wrong value in release mode.

```dart
// BAD:
@override
void initState() {
  super.initState();
  final theme = StreamTheme.of(context); // Throws in debug mode.
}

// GOOD:
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final theme = StreamTheme.of(context);
}
```

### Prefer early returns

Return inside each branch of a conditional rather than reassigning a shared variable
that gets post-processed after the branches.

```dart
// BAD:
Widget build(BuildContext context) {
  Widget child;
  if (isLoading) {
    child = const CircularProgressIndicator();
  } else if (hasError) {
    child = const StreamErrorView();
  } else {
    child = _content();
  }
  return Padding(padding: const EdgeInsets.all(8), child: child);
}

// GOOD:
Widget build(BuildContext context) {
  const padding = EdgeInsets.all(8);
  if (isLoading) return const Padding(padding: padding, child: CircularProgressIndicator());
  if (hasError) return const Padding(padding: padding, child: StreamErrorView());
  return Padding(padding: padding, child: _content());
}
```

### Use of streams and `Listenable`s

At the Flutter widget layer, prefer `Listenable` subclasses (`ValueNotifier`
or `ChangeNotifier`) over `Stream` for widget-owned state. Streams have several
disadvantages that make them awkward inside widget code:

- Streams have a heavy API. They can be synchronous or asynchronous, broadcast
  or single-client, paused and resumed. Determining the right semantics for a
  particular stream when it's used in all the ways widget code could use it is
  non-trivial.
- Streams don't have a "current value" accessor, which makes them difficult to
  use in `build` methods.
- The APIs for manipulating streams are non-trivial (e.g. transformers).

This matches Flutter's own guidance inside the framework.

At the transport layer, streams are the natural primitive — WebSocket events
and connection lifecycle changes arrive asynchronously and have no meaningful
"current value" at every moment. `SharedEmitter` and `StateEmitter` are the
primitives; both implement `Stream<T>`.

## Testing

This section covers repo-level testing conventions. For guidance on **how to write
good tests** — naming, factoring, one behavior per test — see
[`TESTING.md`](TESTING.md).

### Make each test entirely self-contained

Embrace code duplication in tests. It makes it easier to create new tests by copying
and tweaking existing ones.

Avoid test-global variables or state shared between tests — they make maintenance,
debugging, and refactoring significantly harder. Instead of `setUp`, use local
helper functions called inside each test block. For cleanup, prefer `addTearDown`
over the global `tearDown` callback.

### Prefer more test files, avoid long test files

Organize tests into smaller files grouped by feature, widget, or behavior. Split
one big `stream_avatar_test.dart` into `stream_avatar_layout_test.dart`,
`stream_avatar_theme_test.dart`, etc., as the test surface grows.

### Mock only at the seam

Prefer mocking at the boundary between your code and the outside world (HTTP
client, WebSocket, image loading). Do not mock every collaborator.

- Use `mocktail` (no code generation required). Extend `Mock` and stub the methods
  you exercise.
- For simple stubs, prefer explicit fake classes over `Mock` — they read better and
  survive interface changes without a regeneration step.

### Golden tests

Widget tests that verify pixel-level rendering use the `alchemist` package. Golden
tests live in `_golden_test.dart` files next to the unit tests, and the generated
images go under `test/components/<category>/goldens/`. The alchemist config in
`test/flutter_test_config.dart` runs:

- `ciGoldensConfig` — enabled only when `GITHUB_ACTIONS` is set. Produces
  `goldens/ci/*.png`. **These are the goldens that get committed.**
- `platformGoldensConfig` — enabled only locally. Produces `goldens/<platform>/`
  (e.g. `goldens/macos/`). These are auto-generated during local runs and
  gitignored (`.gitignore` allowlists only `goldens/ci/`).

Golden tests are tagged with `golden` in `dart_test.yaml`. Every visible component
must ship with a golden test that exercises the primary variants (sizes, states,
theme brightness).

To regenerate goldens:

```bash
melos run update:goldens
```

Regenerate goldens deliberately, in a separate commit from behavior changes, so
reviewers can see what visually changed. Do not check in a golden mismatch just
because a test "works locally" — only the CI-generated PNGs under `goldens/ci/`
are committed and diffed.


## Naming

### Begin global constant names with the prefix `k`

```dart
const double kDefaultBorderRadius = 8;
const String kDefaultLocale = 'en';
```

Prefer avoiding global constants — `StreamAvatar.defaultSize` reads better than
`kDefaultAvatarSize`. Reach for a class-scoped constant first.

### Avoid abbreviations

Unless the abbreviation is more recognizable than the expansion (e.g. `XML`, `HTTP`,
`JSON`, `URL`, `SDK`), expand it. Avoid one-character names unless idiomatic
(`i` for a loop counter is fine; `x` and `y` for coordinates are fine).

### Stream-prefix all public widgets and themes

Every public widget, theme, and enum in `stream_core_flutter` is prefixed with
`Stream` (e.g. `StreamAvatar`, `StreamAvatarThemeData`, `StreamAvatarSize`). This
avoids collisions with consumer app code and Material/Cupertino types.

Private implementation classes do not need the prefix.

### Naming rules for callbacks and typedefs

For callbacks, use `FooCallback` for the typedef, `onFoo` for the property, and
`handleFoo` for the method that is called.

If `Foo` is a verb, prefer present tense over past tense (`onTap`, not `onTapped`).

Never call a method `onFoo`. If a property is called `onFoo` it must be a function
type. Prefer typedefs for callbacks — they can be documented and make it easier to
grep for common signatures.

### Spelling

Prefer US English spellings. `color`, not `colour`. `canceled`, not `cancelled`.

### Capitalization consistent with spelling

If a word is written as a single compound word (e.g. `toolbar`, `scrollbar`), keep
it compound: no inner capitalization. If it's two words (e.g. `app bar`), use
camelCase: `appBar`, `tabBar`.

Avoid class names containing `iOS`. Prefer `Cupertino` or `UIKit`. If you must use
`iOS` in an identifier, capitalize it as `IOS`.

### Avoid double negatives in APIs

Name boolean variables positively, even if the default is `true`.

### Prefer naming the argument to a setter `value`

Unless it causes problems, use `value` for the setter's argument.

### Qualify variables and methods used only for debugging

Prefix debug-only helpers with `debug` (or `_debug` for private).

### Avoid "new" / "old" modifiers

The definition of "new" changes as code grows. Name things after the idea, not the
version.


## Comments

### Avoid checking in comments that ask questions

Find the answers to the questions, or describe the confusion, including references
where you found answers.

If commenting on a workaround for a bug, describe the constraint and (when one
exists) link the tracking issue:

```dart
// TODO(localize): move "remove" hint to localizations.
// TODO: When the minimum Flutter SDK is >= 3.40, replace this with X.
```

TODOs are either bare `// TODO:` or use a category tag `// TODO(<tag>):` where the
tag names a workstream (e.g. `localize`, `perf-migration`). This diverges from
Flutter's guide, which requires `TODO(github-handle):`. Include an issue link when
the deferred work is tracked; if the constraint is self-explanatory, a link isn't
required.

### Bare ignore directives are fine

`// ignore: rule_name` directives do not require an explanatory comment
(`document_ignores` is disabled). This intentionally diverges from Flutter's guide.

```dart
// GOOD (matches repo style):
foo(); // ignore: unnecessary_null_comparison
```

If an `// ignore` covers something genuinely subtle, a comment is welcome. Do not
add "explanatory" comments to every ignore just to match Flutter's convention.

### Minimize inline comments

Default to zero `//` comments in implementation. Prefer named locals over rationale
comments; prefer early returns over "// handle the loading case" markers.

```dart
// BAD:
Widget build(BuildContext context) {
  // If the user is offline, show the offline banner.
  if (!isOnline) return const OfflineBanner();
  // Otherwise, show the content.
  return const _Content();
}

// GOOD:
Widget build(BuildContext context) {
  if (!isOnline) return const OfflineBanner();
  return const _Content();
}
```

Comments earn their place when they explain _why_ — a hidden constraint, a subtle
invariant, a workaround for a specific bug. Pre-existing comments should not be
removed as part of unrelated changes.

### Comment all test skips

Every skipped test must carry a reason as its `skip` argument. Bare `skip: true` is
a red flag — the next person to look will not know whether the skip is temporary,
permanent, or forgotten.

```dart
// GOOD:
skip: 'Golden diverges on M1 hardware — investigating.'
skip: 'Blocked on Flutter #12345 — remove once that ships.'

// BAD:
skip: true
```

Include an issue link when the skip is tied to a tracked bug; otherwise a plain
reason is fine. File an issue if the skip becomes long-lived.

### Comment empty closures to `setState`

Usually the closure passed to `setState` includes all the state changes. Sometimes
the state changed elsewhere and `setState` is called in response — in those cases
include a comment describing what changed:

```dart
setState(() {
  // The stream subscription fired; the state is already up to date.
});
```


## Formatting

Run the formatter via Melos, not directly:

```bash
melos run format          # dart format . across every package
melos run format:verify   # check-only; used in CI
melos run lint:all        # analyze + format check
```

`melos run format` wraps `dart format` so every package is checked with the same
settings. Do not invoke `dart format` on a single file with ad-hoc flags — the
workspace-level config (line length, trailing commas) applies uniformly.

Line length is **120 characters** for both code and comments, configured in
`analysis_options.yaml`. Trailing commas are preserved rather than automatically
added, so include a trailing comma anywhere you want the formatter to break the
argument list onto multiple lines.

### Constructors come first

The default constructor comes first, followed by named constructors, followed by
everything else. Enforced by `sort_constructors_first` and
`sort_unnamed_constructors_first`.

### Order other class members in a way that makes sense

If there's a clear lifecycle, order members chronologically (e.g. `initState` before
`build` before `dispose`).

If no order is obvious, use:

1. Constructors, default first.
2. Constants of the same type as the class.
3. Static methods that return the same type as the class.
4. Final fields set from the constructor.
5. Other static methods.
6. Static properties and constants.
7. Mutable-property members (getter, private field, setter — no blank lines
   separating the three).
8. Read-only properties (other than `hashCode`).
9. Operators (other than `==`).
10. Methods (other than `toString` and `build`).
11. The `build` method.
12. `operator ==`, `hashCode`, `toString`, and diagnostics methods.

### Use braces for long function bodies

Use a block (with braces) when a body would wrap onto more than one line.

### Prefer `+=` over `++`

`+=` reads as an assignment. `++` hides mutation.

### Use double literals for double constants

Include a decimal point in double literals, even for whole numbers:

```dart
Padding(padding: EdgeInsets.all(8.0)); // good
Padding(padding: EdgeInsets.all(8));   // avoid — reads as int
```


## Widgets, themes, and design system

### Component structure

Components live under `packages/stream_core_flutter/lib/src/components/<category>/`.
Current categories: `accessories/`, `avatar/`, `badge/`, `buttons/`, `common/`,
`context_menu/`, `controls/`, `emoji/`, `list/`, `media_viewer/`, `message/`,
`message_composer/`, `message_layout/`, `reaction/`, `sheet/`, `snackbar/`,
`toolbar/`. Add a new category directory when a component doesn't fit an existing
one.

Each component ships with:

- **Widget file** — under `lib/src/components/<category>/<name>.dart`.
- **Theme file** — under `lib/src/theme/components/<name>_theme.dart`. See
  [Theme system](#theme-system).

  Naming convention: top-level component themes use `<Component>ThemeData`;
  sub-configurations nested inside a top-level theme use `<Component>Style`. For
  example, `StreamButtonThemeData` (top-level) contains `StreamButtonTypeStyle` +
  `StreamButtonThemeStyle` (per-variant sub-configurations). New code follows this
  split. A handful of existing top-level themes are grandfathered into the `Style`
  suffix (e.g. `StreamMessageBubbleStyle`, `StreamMessageMetadataStyle`) — don't
  add more.
- **Widget or unit tests** — under `test/components/<category>/<name>_test.dart`.
  Golden variants use the `_golden_test.dart` suffix (e.g.
  `stream_button_golden_test.dart`, `stream_button_test.dart`). See
  [Golden tests](#golden-tests).
- **Widgetbook use-case** — under
  `apps/design_system_gallery/lib/components/<category>/`.
- **Barrel export** — an `export '…';` line added to `core.dart` or `chat.dart`.

Missing any of the four is a review-blocker.

### Theme system

Themes are generated via `theme_extensions_builder`. **Never hand-roll `copyWith`,
`merge`, `lerp`, `==`, or `hashCode`.** Annotate with `@themeGen` (or
`@ThemeExtensions` for the root) and let the generator produce them.

The hierarchy is layered: **primitives** (`theme/primitives/`, raw tokens) →
**semantics** (`theme/semantics/`, semantic mappings) → **component themes**
(`theme/components/`, per-widget classes, 50+) → **tokens** (figma-generated,
internal).

Adding a new component theme:

```dart
// lib/src/theme/components/stream_widget_theme.dart

@immutable
@themeGen
class StreamWidgetThemeData with _$StreamWidgetThemeData {
  const StreamWidgetThemeData({this.backgroundColor, this.borderRadius});

  // All fields are nullable — defaults do not live here.
  final Color? backgroundColor;
  final double? borderRadius;
}

class StreamWidgetTheme extends InheritedTheme {
  const StreamWidgetTheme({super.key, required this.data, required super.child});
  final StreamWidgetThemeData data;

  static StreamWidgetThemeData of(BuildContext context) {
    final local = context.dependOnInheritedWidgetOfExactType<StreamWidgetTheme>();
    return StreamTheme.of(context).widgetTheme.merge(local?.data);
  }
  // ... wrap + updateShouldNotify.
}
```

Then add `widgetTheme` as a field on `StreamTheme`, run `melos run generate:flutter`,
and consume it in the widget:

```dart
Widget build(BuildContext context) {
  final theme = StreamWidgetTheme.of(context);
  final backgroundColor = widget.backgroundColor
      ?? theme.backgroundColor
      ?? Theme.of(context).colorScheme.surface;
  // ...
}
```

**Place defaults in the widget's `build`, not in the theme data class.** This
mirrors Flutter's `AppBar`/`TabBar` pattern: theme data holds overrides with
nullable fields; the widget resolves the effective value via null-coalescing.

Note: the root `StreamTheme` is an exception — it extends
`ThemeExtension<StreamTheme>` and uses
`@ThemeExtensions(constructor: 'raw', buildContextExtension: false)` so it plugs
into Material's `ThemeData.extensions`. New component themes follow the
`@themeGen` pattern above, not the root pattern.

### Component factory

The design system uses `StreamComponentFactory` to let consumers substitute
individual components without forking. When adding a new component that has a
default implementation, register a factory hook so consumers can override it.

Reference pattern: see how `StreamMessageBubble` resolves its default builder via
`StreamComponentFactory.of(context).messageBubble` in
`packages/stream_core_flutter/lib/src/components/message/stream_message_bubble.dart`.
The factory class itself lives at
`packages/stream_core_flutter/lib/src/factory/stream_component_factory.dart` —
add a nullable builder field there, wire it up through the factory's `copyWith`
and default fallback, and consume it in the component's `build` with the standard
null-coalescing chain.

### Icons

Source SVGs live in `packages/stream_core_flutter/assets_source/icons/`. They come
from the [design-system-tokens](https://github.com/GetStream/design-system-tokens/tree/main/assets/icons)
repository.

When adding or updating icons:

1. Pull the latest SVGs from `design-system-tokens/assets/icons/` into
   `assets_source/icons/`.
2. Run `melos run generate:icons` to regenerate the icon font and the `StreamIcons`
   class.
3. Commit both the SVG sources and the regenerated font + Dart output together —
   they must stay in sync.

Do not edit the generated `StreamIcons.dart` or the icon font by hand.

### Widget essentials

Every **new** public widget in `stream_core_flutter` should:

- Accept `Key? key` in its constructor via `super.key`
  (`use_key_in_widget_constructors`, `use_super_parameters`).
- Support accessibility on both Android (TalkBack) and iOS (VoiceOver). A `Tooltip`
  is usually sufficient as the accessible label.
- Support both LTR and RTL layouts.
- Support text scaling.
- Have documentation for every public member.
- Have a golden test covering the default state and the primary theme variants.
- Have a Widgetbook use-case that lets a designer or reviewer interact with all
  props.

Some earlier components predate parts of this checklist (e.g. missing widget tests
or Widgetbook use-cases). When you touch such a component for a substantive change,
try to close the gap in the same PR — but don't block landing a fix on backfilling
years of missing coverage.


## Commits, PRs, and changelogs

### PR titles and commits

PR titles follow [Conventional Commits](https://www.conventionalcommits.org/):

- `fix(scope): description` — bug fix
- `feat(scope): description` — new feature
- `refactor(scope)!: description` — breaking change (note the `!`)
- `chore(scope): description`, `docs:`, `test:`, `ci:`

`scope` is usually the affected package (`llc` for `stream_core`, `ui` for
`stream_core_flutter`, or `repo` for monorepo-wide changes).

### Changelog policy

Every PR that changes package behavior updates the affected package's
`CHANGELOG.md` under the `Upcoming` heading. Entries live under one of these
sub-headings:

```markdown
## Upcoming

### ✨ Features

- Added `StreamJumpToUnreadButton` component and `StreamJumpToUnreadButtonTheme`.

### 🐛 Bug Fixes

- Fixed a crash when opening the media viewer with an empty attachments list.

### 🛑 Breaking / Removals

- Removed `StreamCoreMessageComposer`. Use `StreamMessageComposer` from
  `stream_chat_flutter` instead.
```

Prefer **one short bullet** per entry, describing the functional change. Longer
entries are acceptable for user-visible multi-facet features where the extra
context matters to someone deciding whether to upgrade — but avoid sub-bullets,
per-method enumeration, and internal implementation notes.

Older entries in the changelog use `### 🐞 Fixed` and `### 💥 Breaking Changes` /
`### 💥 BREAKING CHANGES` — those forms are grandfathered but new entries should
use the labels above.

### Cross-package PRs

If a PR touches both `stream_core` and `stream_core_flutter`, update each package's
`CHANGELOG.md` separately. Cross-linking between packages ("bumps stream_core to
X.Y.Z") is handled by the release tooling — do not write these entries by hand.


## Where to look when you're stuck

- **Repo-wide overview**: [`CLAUDE.md`](CLAUDE.md) — architecture, commands, package
  layout. Points here for style rules.
- **Testing guide**: [`TESTING.md`](TESTING.md) — how to write effective tests.
- **Melos commands**: `melos.yaml` — every task the repo runs.
- **Design source**: the Chat SDK Design System Figma project — accessed via the
  Figma MCP when implementing UI.
- **Design tokens**: `packages/stream_core_flutter/lib/src/theme/primitives/internal/tokens/`
  and the [design-system-tokens](https://github.com/GetStream/design-system-tokens)
  sibling repo.

When something isn't covered here and isn't obvious from surrounding code, prefer
to ask in the PR rather than guessing. If a convention isn't documented, propose
adding it to this guide as part of the PR.
