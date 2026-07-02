---
name: flutter-a11y
description: >
  Apply when adding or modifying Flutter accessibility (a11y) in a design system or reusable component library —
  Semantics widget properties, MergeSemantics, ExcludeSemantics, SemanticsRole, focus management, screen reader
  announcements (one-shot vs live regions), and accessibility testing (meetsGuideline, tester.semantics.find,
  custom widget semantics). Use whenever building a new component, exposing a11y parameters (tooltip / autofocus /
  semanticLabel) on a public API, or wiring Semantics inside a reusable widget. Also applies to debugging
  "TalkBack focus / announcement / role is wrong" issues by dumping the semantics tree.
---

# flutter-a11y

Directive shortlist for Flutter accessibility work in a design system / reusable component library. Organized as a workflow: how to **manage** semantics when writing components, how to **audit** them with tests, and how to **debug** the semantics tree when something is wrong.

## Contents

- [Core principle](#core-principle)
- [Managing semantics](#managing-semantics)
- [Auditing accessibility](#auditing-accessibility)
- [Debugging the semantics tree](#debugging-the-semantics-tree)
- [When in doubt](#when-in-doubt)

## Core principle

**One focus stop per interactive element.** Don't merge interactive children together. Don't leave decorative elements as separate focus stops. Use a container label for orientation, but keep children individually focusable.

**For design system components specifically:** consumers should get correct a11y *by default*. They shouldn't have to wrap your widget with `Semantics(...)` or remember to pass labels for the common case. Bake a11y in.

---

## Managing semantics

How to wire accessibility into Flutter widgets correctly the first time. Pick the right primitive, place wrappers in the right position, avoid the common pitfalls.

### Building accessible components

When adding a new component to the design system or modifying an existing one, the goal is **accessibility by default** — consumers using the public API correctly should produce a screen-reader-friendly result without extra work.

- **Mirror Flutter's standard widget API for a11y parameters.** Match `IconButton.tooltip`, `ElevatedButton.autofocus`, `Image.semanticLabel`, `Text.semanticsLabel`, `Tooltip.message`. Consumers already know these names; gratuitous renaming creates friction.
- **For icon-only widgets, expose a label parameter.** Either a `tooltip:` (matches `IconButton`) or a `semanticLabel:` (matches `Icon`). Either is acceptable; pick one and be consistent across the library.
- **Place internal `Semantics` / `Tooltip` widgets inside the component, not as the wrapper around it.** This matters especially for `ButtonStyleButton` subclasses (Elevated/Text/Outlined/Filled) — their outer `Semantics(container: true)` blocks ancestor merging. The component itself should wrap the child below that boundary.
- **Internal MergeSemantics for composite chrome.** If your component renders bordered chrome around an inner editable widget (a text input with leading/trailing icons; a card with an avatar), wrap the chassis in `MergeSemantics` so consumers see one focus region matching the visible bounds — not the inner editable area alone.
- **Preserve a11y across customization.** If your component supports a factory / builder / override pattern (custom child builders, `WidgetBuilder`-style hooks, replaceable sub-slots), the default implementation must be accessible and the docs should call out which `Semantics` properties a custom implementation must preserve to keep parity. A consumer overriding your button should not silently lose tooltip behavior.
- **Test the component's a11y in isolation.** A regression in the design system breaks every consumer. The component's tests should hold the line — see *Auditing accessibility* below.
- **Document a11y behavior in the component dartdoc.** Public APIs that affect a11y (`tooltip:`, `autofocus:`, `isSelected:`, `semanticLabel:`) should call out the effect — "Used as the visual tooltip and as the screen-reader accessibility label" — so consumers don't have to read source.

### Quick decisions

| Need | Use |
|---|---|
| Label an icon-only button | `IconButton(tooltip: ..., onPressed: ..., icon: ...)` — `tooltip` becomes both visual tooltip and a11y label. For your own icon-button widgets, expose the same `tooltip:` parameter. |
| Label a text button | The child `Text` is the label. No tooltip needed. (`ElevatedButton`/`TextButton`/`OutlinedButton`) |
| Override a11y label without changing visible text | `Text(text, semanticsLabel: ...)` or `Icon(icon, semanticLabel: ...)` |
| Make a composite widget one accessible region | `MergeSemantics(child: ...)` |
| Exclude a decorative icon from a11y tree | `ExcludeSemantics(child: ...)` |
| Add an orientation label to a region | `Semantics(container: true, explicitChildNodes: true, label: ..., child: ...)` |
| Announce one-shot event | `SemanticsService.sendAnnouncement(View.of(context), msg, Directionality.of(context))` |
| Auto-announce on value change | `Semantics(liveRegion: true, child: ...)` |
| Tab/toggle selected state | `Semantics(selected: true, ...)` |
| Hint about activation behavior | `Semantics(hint: ..., child: ...)` |
| Assign an explicit role (Flutter 3.27+) | `Semantics(role: SemanticsRole.list, child: ...)` — newer API; complements the boolean-flag style (`button: true`, `header: true`). Available roles include `list`, `listItem`, `button`, `link`, `tab`, `tabPanel`, `menu`, `menuItem`, `radioGroup`, `radio`, etc. Use when boolean flags don't cover the semantic. |
| Tap target ≥ 48dp | Material defaults handle it; check with `meetsGuideline(androidTapTargetGuideline)` |

### Container regions

For a logical UI section that should announce itself when entered (e.g., a toolbar, a settings group, a navigation rail):

```dart
Semantics(
  container: true,
  explicitChildNodes: true,
  label: 'Toolbar',
  child: Row(children: [...]),
)
```

- `container: true` — creates the orientation node carrying the label.
- `explicitChildNodes: true` — children remain individually focusable.

Without `explicitChildNodes`, children merge into the container and lose individual access.

### Role-annotation vs. container wrapping

For a widget that only needs to carry a semantic *role* (`tabPanel`, `list`, `search`, `alert`), pass the role as an annotation on a non-container `Semantics`; don't reach for `container: true` reflexively.

```dart
// ✓ Matches Flutter's own TabBarView — role attaches to the panel content's
//   existing semantic node, no extra SR stop introduced.
Semantics(role: SemanticsRole.tabPanel, child: panelContent)

// ✗ Introduces a separate SR stop announcing the panel-level label before
//   the user can reach panel content. If the tab bar already announced
//   "Poll tab, selected", the second announcement is redundant.
Semantics(
  container: true,
  explicitChildNodes: true,
  role: SemanticsRole.tabPanel,
  label: tabTitle,
  child: panelContent,
)
```

Rule of thumb: if the descendant already establishes its own container (typical for interactive widgets), a role-only wrapper is enough. Reach for `container: true, explicitChildNodes: true` only when you need the wrapper itself to be a distinct orientation stop with its own label.

### Focus management

Prefer `autofocus:` over plumbing FocusNodes when the use case fits:

```dart
TextField(autofocus: true)                  // initial focus on mount
IconButton(autofocus: isSelected, ...)      // for the current tab/option in a tab strip
```

`autofocus` only fires on first mount — perfect for "focus when a new subtree appears" (pickers, dialogs, freshly-opened regions).

For design-system widgets that have a "selected" or "current" notion (tab buttons, segmented controls, radio chips), accept an `autofocus` param and forward it to the inner focusable. Don't force consumers to plumb FocusNodes for the common case.

Gate SR-specific behavior with `MediaQuery.accessibleNavigationOf(context)`.

### `FocusTraversalGroup` is for keyboards, not screen readers

Common misconception: `FocusTraversalGroup` does *not* control screen-reader traversal order. Its dartdoc is explicit — "the policy used to move the focus from one focus node to another when traversing them using a keyboard." Internally the widget wraps its child in a `Focus(includeSemantics: false, …)`, so it contributes nothing to the semantic tree.

Two separate trees; only one is walked by SR gestures:

| Tree | Built from | Traversed by |
|---|---|---|
| Focus | `Focus` / `FocusScope` / `FocusTraversalGroup` | Keyboard Tab, arrow keys |
| Semantics | `Semantics` widget | TalkBack / VoiceOver swipe gestures |

To reorder SR traversal, use `Semantics(sortKey: OrdinalSortKey(...))` on siblings, restructure the widget tree, or use `Semantics(container: true)` grouping — not `FocusTraversalGroup`.

### Programmatic focus dispatch (`FocusSemanticEvent`)

`RenderObject.sendSemanticsEvent(const FocusSemanticEvent())` moves the SR reading cursor onto a specific node. Use it for the narrow case where the platform's automatic focus decision on route/modal entry isn't the element the user needs to interact with (e.g., landing focus on the primary input rather than the toolbar's first button). For everything else, prefer declarative Semantics (`autofocus:`, `scopesRoute: true`, `namesRoute: true`) which the platform handles more reliably.

One constraint to know: **`onDidGainAccessibilityFocus` does not fire from these dispatches.** The callback fires only when the platform SR service explicitly acquires focus via `ACTION_ACCESSIBILITY_FOCUS` (user-initiated navigation). A programmatic `FocusSemanticEvent` moves the cursor but doesn't round-trip back through the callback, so it isn't usable as an "early stop" signal for retry loops.

### Modal sheets & dialogs

```dart
showModalBottomSheet(
  context: context,
  barrierLabel: 'Error',  // ← TalkBack announces when modal appears
  builder: (_) => MySheet(),
);

// Inside the sheet:
Semantics(header: true, child: Text('Title', style: textTheme.headingMd))
```

Flutter handles focus trap and return-focus for `showModalBottomSheet`/`showDialog` automatically.

For inline dismissable panels (not modals), use `PopScope` to intercept system back:

```dart
PopScope(
  canPop: !_isPickerVisible,
  onPopInvokedWithResult: (didPop, _) {
    if (!didPop) _hidePicker();
  },
  child: ...,
)
```

### Announcement patterns — choose the right one

Three distinct shapes; mixing them up causes either silent failures or announcement spam.

| Pattern | When to use | API |
|---|---|---|
| **One-shot event** — fires on a discrete action that happened (picker opened, attachment added, error appeared). No deduplication; the same call always announces. | Picker open/close, item added, error appeared, action confirmed. | `SemanticsService.sendAnnouncement(View.of(context), msg, Directionality.of(context))` |
| **State-change with dedup** — content changes; should announce on each *string* change, but consecutive calls with the same message should not re-announce. | A status indicator that updates (`"AI is typing"` → `"AI is generating"`); upload progress label changes. | Wrap in `Semantics(liveRegion: true)`. Flutter dedupes consecutive identical strings. |
| **Reshow-on-visible** — a transient surface that appears/disappears repeatedly; each *show* should re-announce (different from string-change dedup). | Replying-to preview, autocomplete suggestions, snackbars that may reappear with the same message. | Trigger `sendAnnouncement` on every `false → true` visibility transition. Don't rely on `liveRegion: true` (which dedupes identical strings across show/hide cycles). |

The critical distinction: `liveRegion: true` dedupes on string identity (correct for state changes), `sendAnnouncement` on every visibility flip is correct for transient reshows. They're not interchangeable.

### Pitfalls to check before writing

1. **`MergeSemantics` absorbs ALL descendants, interactive ones included.** Don't wrap a Row of multiple buttons in MergeSemantics — they collapse into one focus stop, losing individual access. Only use when descendants are decorative or share a single semantic action.

2. **`SemanticsService.announce` is deprecated.** Use `SemanticsService.sendAnnouncement(view, message, textDirection)` — multi-window safe.

3. **`Semantics(hint:)` is user-disable-able.** Never put critical info in hints. Critical info goes in `label:` or `value:`.

4. **Focusing a `TextField`'s FocusNode opens the IME.** There is no clean Flutter API to focus an editable text field without the keyboard. Workarounds (`readOnly`, `keyboardType: TextInputType.none`) make the field non-editable. Accept the keyboard opening, or focus a non-TextField parent if you need "focus the area without keyboard."

5. **Flutter Web's semantics tree is disabled by default** for performance. The DOM only includes the invisible `aria-label="Enable accessibility"` button until the user activates it — assistive tech users won't get a11y info otherwise. If shipping for web, either tell users about the button, or force semantics on programmatically:

   ```dart
   import 'package:flutter/foundation.dart';
   import 'package:flutter/semantics.dart';

   void main() {
     if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
     runApp(const MyApp());
   }
   ```

   To visualize web semantics during development:
   ```
   flutter run -d chrome --profile --dart-define=FLUTTER_WEB_DEBUG_SHOW_SEMANTICS=true
   ```
   Chrome DevTools → Elements tab → "Accessibility" sub-tab shows the exported ARIA tree.

6. **On Android, TalkBack may fail to focus content rendered outside its parent's measured bounds.** Android's accessibility framework uses each view's `getBoundsInScreen()` for hit testing. If a Flutter `Stack` child overflows the Stack via `Positioned` with offsets that exceed the parent's bounds, the visual rendering can look fine while TalkBack reports degenerate bounds and can't focus the content. Most Flutter overlays (via `Overlay`/`OverlayPortal`) mount into the Navigator's full-screen overlay and aren't affected — but a `Stack`-with-overflow in a small parent (e.g., a tooltip-like popover inside a 48dp button row) can hit this. If you suspect it, dump the a11y tree with `uiautomator dump` (see Debugging section) and look for `bounds="[x,y][x,y]"` with `top > bottom` — that's the symptom. Fix by mounting the overlay in a taller ancestor (use `Overlay.of(context)` rather than a local `Stack`).

### Anti-patterns to avoid

1. **Auto-focusing typeahead / autocomplete suggestions on appear.** Each keystroke that produces new suggestions would re-steal focus from the active `TextField`, breaking continuous typing. ARIA combobox spec explicitly forbids this; iOS VoiceOver and Android TalkBack have the same constraint. Announce on show via `sendAnnouncement('Suggestions available')` instead, and rely on standard screen-reader navigation gestures (swipe) for the user to reach the list when they want.

2. **Nested focusables.** Don't wrap a `GestureDetector(onTap: ...)` around an `IconButton(onPressed: ...)` (or any tappable inside another tappable). The user gets two focus stops for one action. Either make the outer non-interactive (`HitTestBehavior.translucent` only, no callback) or mark the inner with `ExcludeSemantics`.

3. **Hardcoded labels in a design system component.** A component shipped to multiple products must accept localized labels through its public API; never bake English strings inside. Required-label parameters (`tooltip: String` not `tooltip: String?`) for icon-only widgets are a defensible pattern.

4. **`Semantics(hint:)` as the only carrier of critical information.** Users can disable hints in screen-reader settings. Hints are *supplementary*. Critical state goes in `label:` or `value:`.

5. **Auto-focusing a screen's primary `TextField` on page entry.** Opens the IME on page load, partially covers content, disorients SR users. Most mainstream apps land focus at the top of the screen (channel header, screen title, back button) on entry and let the user explicitly tap into the input when they're ready — match that convention unless there's a strong reason to override.

6. **Subscribing to `MediaQuery.accessibleNavigationOf(context)` inside list items.** Toggling SR re-renders every item. Subscribe only in components that actually swap UI based on SR state.

7. **Returning focus to the trigger element on close for inline pickers tightly coupled to a primary input.** For one-shot system modals (settings sheets, confirmation dialogs) the trigger-return pattern is correct. But for inline pickers attached to a text input where the user is mid-flow (e.g., emoji pickers, mention pickers, attachment menus), the convention is to focus the primary input on close so the user can keep typing. Match what mainstream apps in your domain do; don't reinvent.

8. **`liveRegion: true` to force-announce a static dialog title.** Use `Semantics(header: true)` + `barrierLabel:` on `showModalBottomSheet` instead. Live regions are for content that *changes*.

9. **Pushing a11y responsibility to consumers.** "The consumer can wrap our widget with `Semantics(label: ...)` if they want a screen reader to read it" is the wrong default for a design system. Bake a11y in; require labels in the public API where appropriate.

---

## Auditing accessibility

How to verify that what you wrote actually works. The canonical Flutter testing flow: enable semantics, run guideline checks first (they catch ~80% of regressions), then drop into per-node assertions for the specific behavior you fixed.

For a design system, tests are the contract: a regression in a base component breaks every consumer. Hold the line in the component's own test file, not downstream.

### Setup — the canonical pattern

```dart
testWidgets('...', (tester) async {
  final handle = tester.ensureSemantics();
  await tester.pumpWidget(...);
  // assertions
  handle.dispose();
});
```

Dispose the handle **inline at the end of the test body**. Roughly 99% of Flutter's own widget tests use this pattern (counted across the 3.44 SDK: 164 uses of `tester.ensureSemantics()`, only 2 with `addTearDown(handle.dispose)` — and those 2 don't actually call `tester.ensureSemantics()`).

> ⚠️ **Don't use `addTearDown(handle.dispose)` with `tester.ensureSemantics()`.** Inside `testWidgets`, the framework's `_verifySemanticsHandlesWereDisposed` check runs *before* tearDown callbacks fire — the handle is still active at verification time, the test fails. The `addTearDown` pattern *is* valid for rendering-only tests that use `TestRenderingFlutterBinding.instance.ensureSemantics()` or `SemanticsBinding.instance.ensureSemantics()` directly (different binding, no end-of-test handle check). For `testWidgets`, inline dispose is the only correct pattern.

### Guideline-level checks (catches most regressions)

```dart
await expectLater(tester, meetsGuideline(androidTapTargetGuideline));   // ≥48×48
await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));       // ≥44×44
await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));   // every tappable labeled
await expectLater(tester, meetsGuideline(textContrastGuideline));       // ≥4.5:1 / 3:1
```

### Matchers — pick by intent

| Matcher | Behavior | When to use |
|---|---|---|
| `containsSemantics(...)` | Subset — only specified properties checked; allows extras | **Default for most tests.** Survives SDK upgrades that add new flags. |
| `matchesSemantics(...)` | Exhaustive — every parameter checked, unspecified MUST be absent | When you want to lock down a precise spec. Brittle to Flutter SDK additions. |
| `isSemantics(...)` | Strict (Flutter 3.43+ replacement for `matchesSemantics`) | Same use case as `matchesSemantics`; preferred for new code. |
| `includesNodeWith(...)` | "Some node in the tree matches" | Existence checks ("there's a node labeled 'Alert' with `namesRoute` flag"). |
| `meetsGuideline(...)` | Guideline-level | Tap targets, contrast, label presence. |

> ⚠️ `TestSemantics`/`SemanticsTester`/`hasSemantics(TestSemantics.root(...))` are **`@Deprecated` (Flutter 3.43+)**. Don't reach for full-tree-shape assertions in new tests — they break on every SDK change. Use `containsSemantics`/`isSemantics` against `tester.semantics.find(finder)` or `tester.getSemantics(finder)` instead.

### Inspecting a single node

```dart
// Returns the merged node when MergeSemantics is involved.
final node = tester.semantics.find(find.byType(MyWidget));
expect(node, containsSemantics(label: 'Send', isButton: true, hasTapAction: true));
```

`tester.semantics.find` is the newer API and recommended; `tester.getSemantics` still works and returns the same node.

### Testing focus / traversal order

`tester.semantics.simulatedAccessibilityTraversal` is the closest you get to "what a TalkBack user swiping right experiences":

```dart
final order = tester.semantics
  .simulatedAccessibilityTraversal(startNode: find.semantics.byLabel('Add attachment'))
  .map((node) => node.label)
  .toList();

expect(order, ['Add attachment', 'Message input', 'Send message']);
```

Use this for any UI where the focus order matters (composers, toolbars, forms, picker tab strips).

### Verifying announcements fire

Mock the platform a11y channel and capture the announcement payload:

```dart
final announcements = <String>[];
TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
  .setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (msg) async {
    if (msg is Map && msg['type'] == 'announce') {
      announcements.add(msg['data']['message'] as String);
    }
  });

await tester.pumpWidget(MyComposer());
await tester.tap(find.bySemanticsLabel('Add attachment'));
await tester.pump();

expect(announcements, contains('Attachment picker opened'));
```

This pins the announcement-on-action contract — pickers, mention overlays, error states.

### Simulating a screen-reader-triggered action

To verify the SR-driven activation path (which can differ from finger-tap, especially for desktop `TextField` focus):

```dart
tester.platformDispatcher.onSemanticsActionEvent!(SemanticsActionEvent(
  type: SemanticsAction.tap,
  viewId: tester.view.viewId,
  nodeId: tester.semantics.find(find.byType(MyWidget)).id,
));
await tester.pumpAndSettle();
```

### Validating `Semantics(role: ...)` configuration

Flutter throws `FlutterError` when `SemanticsRole.tab` is missing `selected:`, `radioGroup` has multiple checked items, etc. Assert no exception is thrown:

```dart
await tester.pumpWidget(MyWidget());
expect(tester.takeException(), isNull, reason: 'Semantic role configured correctly');
```

Catches "I added `role: tab` but forgot `selected:`" before it ships.

### Recipe per widget shape

| Widget shape | Minimal assertion |
|---|---|
| Icon-only button | `containsSemantics(label: ..., isButton: true, hasTapAction: true)` against `find.byType(MyButton)` |
| Disabled button | `containsSemantics(label: ..., isButton: true, hasTapAction: false)` |
| Toggle / switch | `containsSemantics(hasToggledState: true, isToggled: <expected>)` |
| Checkbox | `containsSemantics(hasCheckedState: true, isChecked: <expected>)` |
| Tab in a TabBar | `containsSemantics(hasSelectedState: true, isSelected: <expected>)` |
| Slider | `containsSemantics(value: '50%', increasedValue: '55%', decreasedValue: '45%')` |
| TextField | `final node = tester.getSemantics(find.byType(MyField)); expect(node.label, ...); expect(node.value, ...);` |
| Live-region content | `containsSemantics(label: ..., isLiveRegion: true)` |
| Dialog title | `expect(semantics, includesNodeWith(label: ..., flags: [namesRoute, scopesRoute]))` |
| Focus order | `tester.semantics.simulatedAccessibilityTraversal(...).map((n) => n.label).toList()` |
| Announcement on action | Mock `SystemChannels.accessibility`, assert log |
| Tap-target compliance | `await expectLater(tester, meetsGuideline(androidTapTargetGuideline))` |

### Regression-guard discipline

Verify the test FAILS without your fix. `git stash` the fix, run the test, restore.

A passing test that doesn't fail without the fix is a false positive — common when a `containsSemantics(...)` happens to match irrelevant properties, or when `meetsGuideline` is checking a guideline the widget already satisfied. Always verify the test's negative case.

### Platform-conditional assertions

If your widget's a11y differs per platform (common for dialogs — iOS/macOS skip the `Alert` wrapper that Android/Linux/Windows include), branch the assertion:

```dart
final isApple = defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

if (isApple) {
  expect(semantics, isNot(includesNodeWith(label: 'Alert')));
} else {
  expect(
    semantics,
    includesNodeWith(
      label: 'Alert',
      flags: [SemanticsFlag.namesRoute, SemanticsFlag.scopesRoute],
    ),
  );
}
```

Run such tests across platforms via `TargetPlatformVariant`:

```dart
testWidgets('...', (tester) async {
  // ...
}, variant: const TargetPlatformVariant({
  TargetPlatform.iOS,
  TargetPlatform.android,
}));
```

---

## Debugging the semantics tree

When TalkBack ignores a view, can't focus a row, focuses the wrong thing, or announces the wrong text — dump the semantics tree and read it directly. Two complementary tools, use whichever fits the diagnosis.

### `debugDumpSemanticsTree()` — Flutter-native, fastest

Print the current semantic tree to the debug console from inside the app:

```dart
import 'package:flutter/rendering.dart';

GestureDetector(
  onLongPress: () => debugDumpSemanticsTree(),
  child: ...,
)
```

Output shows the full SemanticsNode hierarchy, each node's rect, flags, label, hint, value, and actions. Use when you want to verify a node exists / merged correctly / has the right flags without leaving Flutter. No platform tooling needed.

Tip: ensure semantics are actually being computed before dumping — `tester.ensureSemantics()` in tests, or `MaterialApp(showSemanticsDebugger: true)` in runtime debugging.

### `uiautomator dump` — Android-side ground truth

Use when the Flutter dump looks correct but TalkBack still behaves wrong — the issue is likely in how Flutter's semantic tree maps to Android `View` bounds.

```bash
# 1. Put the app in the state you want to inspect.
adb shell uiautomator dump /sdcard/window_dump.xml
adb pull /sdcard/window_dump.xml ./window_dump.xml

# 2. Find your view — grep by a known label / text.
grep -A2 'text="Submit"' window_dump.xml
grep -B1 -A1 'content-desc="Profile section"' window_dump.xml
```

Each `<node>` has `bounds="[left,top][right,bottom]"` in screen pixels:

| Symptom in `bounds` | Meaning |
|---|---|
| `[0,0][0,0]` | View never measured (mid-mount or detached from a11y tree). |
| `top > bottom` or `left > right` | Clipped by parent — `getBoundsInScreen()` clamped to a smaller ancestor. TalkBack treats this as empty. **Move the mount to a taller parent.** |
| Bounds outside the screen | Off-screen or pushed by keyboard; TalkBack won't focus it. |
| Bounds present, `clickable="true"`, `focusable="true"`, but still unreachable | Check `importantForAccessibility` chain and sibling z-order — something opaque may be above it. |

Other useful node attributes: `class` (underlying Android View class — helps when a Flutter widget compiles to something unexpected), `package` (confirms you're looking at your app, not system UI), `clickable`/`focusable`/`enabled` (all must be true for TalkBack focus), `content-desc` (what TalkBack speaks — if empty when you expected a label, the prop didn't bind correctly).

Caveats:
- Single snapshot. If the view animates in, dump *after* the animation settles.
- TalkBack itself can affect what gets dumped — turn it off when diagnosing layout, on when diagnosing focus order.
- The XML reflects native bounds *after* Flutter's layout pass. A wrong dump usually means Flutter gave Android wrong layout, not that the dump is lying.

---

## When in doubt

1. Default to one focus stop per interactive element.
2. Bake a11y into the component's public API; don't push it to consumers.
3. Mirror Flutter's standard a11y parameter names (`tooltip:`, `autofocus:`, `semanticLabel:`).
4. Use `MergeSemantics` for composite chrome — but only when descendants are decorative or share an action.
5. Use `ExcludeSemantics` aggressively for decorative icons.
6. Use `Semantics.liveRegion` sparingly — only when content genuinely needs auto-announce on change.
7. Use `SemanticsService.sendAnnouncement` for one-shot events.
8. Write a `meetsGuideline` regression test in the component's own test file.
9. Test on a real device with TalkBack/VoiceOver before declaring done.
10. Don't over-plumb FocusNodes. `autofocus:` often gets the same result with less code.
