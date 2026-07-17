# Writing effective tests

This guide is about **how to write good tests**, not how to run them or which
testing tools to use. For repo-level testing conventions (mocking library, golden
tests, `mocktail`, `alchemist`, self-containment), see the
[Testing section of STYLE_GUIDE.md](STYLE_GUIDE.md#testing).

This document is adapted from Flutter's
[Writing-Effective-Tests](https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Writing-Effective-Tests.md).

Tests are a critical tool for stability and education. They fulfill three roles:

- Automatically protect against regressions.
- Define an executable specification that captures original intent.
- Educate other developers about why and how to use an API.

To support those roles, four practices matter more than any others.

## Name tests based on the behavior being tested

Tests often get named after the widget or class under test rather than the
behavior. That communicates nothing to the reader — the class is already visible
from the file being edited.

```dart
// BAD — the reader already knows we're testing StreamAvatar.
testWidgets('StreamAvatar', (tester) async { ... });

// BAD — same problem.
test('StreamWsClient', () { ... });
```

Instead, name the test after the behavior or the expected outcome:

```dart
// GOOD
testWidgets('StreamAvatar renders initials when image is null', (tester) async { ... });

// GOOD
testWidgets('StreamAvatar uses the size from theme when size is not overridden', (tester) async { ... });

// GOOD
test('StreamWsClient reconnects with exponential backoff after connection loss', () { ... });
```

A reader scanning `flutter test`'s output should be able to tell what broke from
the test name alone, without opening the file.

## One behavior per test

A single test that exercises multiple behaviors turns a failure report into a
mystery: is one thing broken, or many?

```dart
// BAD — this test exercises three behaviors.
testWidgets('StreamAvatar', (tester) async {
  await _pumpAvatar(tester, size: StreamAvatarSize.md);
  expect(find.byType(StreamAvatar), findsOneWidget);

  await _pumpAvatar(tester, size: StreamAvatarSize.lg);
  expect(tester.getSize(find.byType(StreamAvatar)).width, equals(40.0));

  await _pumpAvatar(tester, size: StreamAvatarSize.md, name: 'Ada');
  expect(find.text('A'), findsOneWidget);
});
```

Split into one behavior per test:

```dart
// GOOD
testWidgets('StreamAvatar renders when given no other arguments', (tester) async {
  await _pumpAvatar(tester);

  expect(find.byType(StreamAvatar), findsOneWidget);
});

testWidgets('StreamAvatar sizes itself to StreamAvatarSize.lg (40px)', (tester) async {
  await _pumpAvatar(tester, size: StreamAvatarSize.lg);

  expect(tester.getSize(find.byType(StreamAvatar)).width, equals(40.0));
});

testWidgets('StreamAvatar renders the first letter of the name when no image', (tester) async {
  await _pumpAvatar(tester, name: 'Ada');

  expect(find.text('A'), findsOneWidget);
});
```

**What counts as "one behavior"?** Usually one action with one assertion. There are
cases where multiple calls represent a single behavior (e.g. "when the WebSocket
disconnects and then reconnects, missed frames are re-fetched") — use your
judgment. A larger number of shorter tests beats a smaller number of longer ones.

## Only include relevant details in a test

Tests often need setup that isn't part of the behavior under test. When that setup
lives inline, readers can't easily tell which parts of the fixture matter and which
are noise.

```dart
// BAD — the setup dwarfs the behavior being tested.
testWidgets('StreamAvatar renders a fallback icon when name is empty', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: StreamTheme(
        data: StreamThemeData.light(),
        child: const Scaffold(
          body: Center(
            child: StreamAvatar(
              name: '',
              size: StreamAvatarSize.md,
            ),
          ),
        ),
      ),
    ),
  );

  expect(find.byType(Icon), findsOneWidget);
});
```

Extract the setup into a helper named for its purpose:

```dart
// GOOD — the test reads as a specification.
testWidgets('StreamAvatar renders a fallback icon when name is empty', (tester) async {
  await _pumpAvatar(tester, name: '');

  expect(find.byType(Icon), findsOneWidget);
});
```

The helper (`_pumpAvatar`) lives at the bottom of the test file. Its name tells the
reader what it does; the reader doesn't need to look inside unless something breaks.

## Optimize tests for comprehension

Even a well-factored test benefits from small edits that separate "the thing under
test" from "the actions we take on it".

```dart
// OK — but the thing being tested and the action are entangled.
testWidgets('StreamAvatar honors the size passed as a constructor argument', (tester) async {
  await _pumpAvatar(
    tester,
    size: StreamAvatarSize.lg,
    name: 'Ada',
    padding: const EdgeInsets.all(8),
  );

  expect(tester.getSize(find.byType(StreamAvatar)).width, equals(40.0));
});
```

Extract the props and let the test name the two moving parts explicitly:

```dart
// GOOD — the props are named and the action is a separate line.
testWidgets('StreamAvatar honors the size passed as a constructor argument', (tester) async {
  const props = _AvatarProps(size: StreamAvatarSize.lg, name: 'Ada');

  await _pumpAvatar(tester, props: props);

  final width = tester.getSize(find.byType(StreamAvatar)).width;
  expect(width, equals(40.0));
});
```

The difference is small but real: on a scan, the reader sees "here are the props,
here is the action, here is the assertion" as three separate ideas instead of one
blob of arguments.

When writing a test, imagine the developer who will read it six months from now.
Anything you can do to help that reader understand what and why the test is
checking is worth doing.

## `group` is for shared preconditions, not for organizing a file

Reach for `group(...)` when several tests share a precondition that's worth
stating once: "when the widget is in dark mode", "when `textDirection` is RTL",
"when the button is disabled". The group description names the precondition;
the test descriptions inside name the behaviors that follow from it.

```dart
group('when textDirection is RTL', () {
  testWidgets('StreamAvatar keeps its label on the trailing side', (tester) async { ... });
  testWidgets('StreamButton mirrors its leading icon', (tester) async { ... });
});
```

Do not use `group` to organize a file by widget or method — that's what the
file itself is for. If a `group` is doing the work a separate file should be
doing,
[split the file instead](STYLE_GUIDE.md#prefer-more-test-files-avoid-long-test-files).
Nested groups more than one level deep are almost always a signal to split.

## Golden tests are behavioural tests too

Golden tests aren't a shortcut around the four principles above. A golden with a
name like `StreamAvatar_default` is worse than a plain unit test named
`StreamAvatar_default` — the golden's failure mode is "pixels changed", not "a
specific behavior broke", which makes triage harder.

Instead, name goldens after the variant being pinned:

```dart
// GOOD
goldenTest(
  'StreamAvatar renders correctly across every size preset',
  fileName: 'stream_avatar_sizes',
  builder: () => ...,
);

goldenTest(
  'StreamButton disabled state is dimmed and non-interactive',
  fileName: 'stream_button_disabled',
  builder: () => ...,
);
```

Regenerate goldens deliberately, in a separate commit from behavior changes, so
reviewers can see what visually changed. Prefer the `update_goldens` GitHub
Action over regenerating locally — see
[Golden tests in STYLE_GUIDE.md](STYLE_GUIDE.md#golden-tests) for the workflow.

## See also

- [STYLE_GUIDE.md — Testing](STYLE_GUIDE.md#testing) — repo-level testing
  conventions (mocktail, alchemist golden tests, self-contained tests,
  `addTearDown`).
- Flutter's [Writing-Effective-Tests](https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Writing-Effective-Tests.md)
  — the source this guide was adapted from.
