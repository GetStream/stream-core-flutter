## Upcoming

### ✨ Features

- Added `StreamAccessibilityAutofocus` — behavior-only wrapper that requests screen-reader focus on its child shortly after mount; useful for redirecting focus on route entry.
- Added `StreamSemanticsAnnouncer` — imperative one-shot screen-reader announcement helper.
- Added `StreamSemanticsTransitionAnnouncer` — observes a `Listenable` and dispatches transition announcements to the screen reader.
- Added `labelText` and `helperAffinity` to `StreamTextInput` for a floating label above the field and helper text positioned inside or outside the bordered chassis.
- Added `focusNode` and `autofocus` pass-through on `StreamListTile`.
- Added optional `semanticLabel` to `StreamBadgeNotification`, `StreamFileTypeIcon`, `StreamStepper`, `StreamMessageComposerAttachment`, and `StreamMessageComposerMediaAttachment`.
- Added `excludeHeaderSemantics` to `StreamAppBar` and `StreamSheetHeader` for opting out of the default heading role and route naming on the title.
- Added `onVisible` callback to `StreamSnackbar` — fires after the entrance animation completes (or synchronously when a screen reader is active).
- Added `StreamColorScheme.fromSeed` — builds a complete light or dark color scheme from a single brand color, optionally with a custom chrome color. When chrome is omitted it is derived from the brand hue at `StreamColorScheme.neutralChroma`.
- `StreamColorSwatch.fromColor` now generates shades in the HCT color space instead of HSL. Each shade takes its tone from a fixed ladder measured from the Stream design tokens, so a shade's contrast is predictable regardless of the seed's hue — seeding a light color such as yellow now yields an accent that can carry white text. Two consequences: the seed is no longer reproduced verbatim at shade 500 (it is normalized onto the ladder), and dark scales now mirror the ladder so the seed's tone lands on shade 300, matching the default dark palette.

### 🐞 Fixed

- Fixed `StreamButton` icons picking up the host app's `ElevatedButtonThemeData.iconColor` instead of the button's own `foregroundColor`.

## 0.4.0

### ✨ Features

- Split the public API into `package:stream_core_flutter/core.dart` (shared primitives for any Stream SDK) and `package:stream_core_flutter/chat.dart` (chat-only widgets; re-exports `core.dart`); the convenience barrel `package:stream_core_flutter/stream_core_flutter.dart` is now deprecated.
- Added `StreamSnackbar` and `StreamSnackbarTheme` — Stream-styled transient feedback snackbars with a messenger-driven queue.
- Added `StreamIcons.megaphone` and `StreamIcons.shield` (20px) to the icon set.
- Added `StreamMentionType` identifier for supported mention types and options for mention text customisation per type.

## 0.3.0

### 🛑 Breaking / Removals

- Removed `StreamCoreMessageComposer`, `StreamMessageComposerInput`, `StreamMessageComposerInputField`, `StreamCoreMessageComposerInputTrailing`, `StreamVoiceRecordingButton`, `VoiceRecordingCallback`, `StreamMessageComposerInputTrailingState`, and `InputThemeDefaults`. These composer-flow widgets now live entirely in `stream_chat_flutter`. The attachment widgets (`StreamMessageComposerAttachment` and variants) remain in this package.

### ✨ Features

- Added `StreamOnlineIndicatorSize.xxl` (20px) to pair with `StreamAvatarSize.xxl`.
- Added `StreamJumpToUnreadButton` component and `StreamJumpToUnreadButtonTheme`.
- Added `StreamVideoPlayIndicator` component with `StreamVideoPlayIndicatorSize` variants.
- Added `StreamFileTypeIconSize.md` and `StreamFileTypeIconSize.sm` variants.
- Added `trailing` slot to `StreamMessageAnnotation`, with matching `trailingTextStyle`/`trailingTextColor` on `StreamMessageAnnotationStyle`.
- Added `StreamIntrinsicFlex`, `StreamIntrinsicRow`, and `StreamIntrinsicColumn` layout primitives, extending `StreamFlex` with full main-axis flex behavior (`Expanded`, `Flexible`, `MainAxisAlignment`, `MainAxisSize`) and `CrossAxisAlignment.baseline` support while retaining cross-axis shrink-wrapping.
- Added `StreamTapTargetPadding`, a reusable primitive that grows a child's layout and hit-test area to a configurable `minSize` without changing its visual size, with a directional `alignment` that controls which direction the extra tap area extends into.
- Added `StreamSheetHeader` component and `StreamSheetHeaderTheme` for bottom-sheet and modal headers, with platform-aware auto-implied dismissal based on the enclosing route.
- Added `StreamToolbar`, a three-slot layout primitive shared by `StreamAppBar`, `StreamBottomAppBar`, and `StreamSheetHeader` that keeps the title geometrically centred even when leading and trailing widths differ.
- Added `StreamBottomAppBar` and `StreamBottomAppBarTheme`, the bottom counterpart to `StreamAppBar` with the same three-slot (`leading`/`heading`/`trailing`) layout, optional title + subtitle, top hairline border, `SafeArea(top: false)` when primary, and per-slot button style propagation.
- Added `StreamMediaViewer` and `StreamMediaViewerTheme`, a full-screen media chrome controller that composes optional header/footer chrome over an edge-to-edge child, animates the chrome in/out via `showChrome`, and fades to an immersive background when hidden. The theme exposes scoped `appBarStyle`/`bottomAppBarStyle` so descendant chrome bars can be tinted (e.g. light-on-dark over dark media) without touching app-wide themes.
- Added `StreamSheet`, `StreamSheetDragHandle`, `StreamSheetRoute`, `StreamSheetTransition` and the `showStreamSheet` helper — Stream-styled modal bottom sheets with scroll-aware drag-to-dismiss and stacking support. `StreamSheet` can also be used standalone outside the modal route.
- Added `StreamSheetTheme` and `StreamSheetThemeData` (`StreamTheme.sheetTheme`) for theming `StreamSheet` and modal sheets opened with `showStreamSheet`.
- `StreamEmojiPickerSheet.show` now resolves its background color and border radius from the ambient `StreamSheetTheme` so the picker visually matches other Stream-styled sheets by default.
- `StreamLoadingSpinner` now supports determinate progress via a `value` parameter (`0.0`–`1.0`), and renders a completion checkmark when `value` reaches `1.0`. Omit `value` for the existing indeterminate spinning state.
- `StreamCommandChip` is now tappable across its whole surface, not just the × icon.
- `StreamRemoveControl` now meets the 48 dp minimum tap target by default while keeping its 20 dp visible badge anchored to the top-end corner. Exposes `tapTargetSize`, `visualDensity`, and `semanticLabel`, announces itself as a button to screen readers, and shows a click cursor on web/desktop when hovered.
- Added `textAlignVertical` to `StreamTextInput` (and `StreamTextInputProps`) for controlling the vertical alignment of the text within the input.
- Added `cursorColor`, `cursorErrorColor`, `cursorWidth`, `cursorHeight`, and `cursorRadius` to `StreamTextInputStyle` for customizing the text input cursor. `cursorErrorColor` is applied automatically when `helperState` is `StreamHelperState.error`. `StreamMessageComposerInputField` also honors these cursor properties from the theme.
- Exported `DefaultStreamEmoji` so consumers can compose with or wrap the default emoji rendering when overriding via `StreamComponentFactory`.
- Added `StreamMessageComposerEditMessageAttachment`, a preview shown above the composer input while editing a message.
- Added `StreamMessageComposerUnsupportedAttachment`, a placeholder shown for attachments the client cannot render.
- Added a themed `thumbnail` slot to `StreamMessageComposerReplyAttachment` and `StreamMessageComposerEditMessageAttachment`, with matching `thumbnailSize`/`thumbnailShape`/`thumbnailSide` theme fields.
- Added per-widget themes for the message composer attachments: `StreamMessageComposerAttachmentTheme`, `StreamMessageComposerEditMessageAttachmentTheme`, `StreamMessageComposerFileAttachmentTheme`, `StreamMessageComposerLinkPreviewAttachmentTheme`, `StreamMessageComposerMediaAttachmentTheme`, `StreamMessageComposerReplyAttachmentTheme`, and `StreamMessageComposerUnsupportedAttachmentTheme`. All seven are wired into `StreamTheme` with matching `BuildContext` extensions.
- The composer attachment widgets (`StreamMessageComposerAttachment`, `StreamMessageComposerEditMessageAttachment`, `StreamMessageComposerFileAttachment`, `StreamMessageComposerLinkPreviewAttachment`, `StreamMessageComposerMediaAttachment`, `StreamMessageComposerReplyAttachment`, `StreamMessageComposerUnsupportedAttachment`) can now be customized via `StreamComponentFactory` — each exposes a matching builder slot taking its `*Props` configuration object.

### 🐞 Fixed

- Fixed RTL layout for composer input field.
- Fixed RTL layout for audio waveform and waveform slider.
- Fixed `StreamTextInput` stretching vertically when placed inside a parent with bounded `maxHeight` (e.g. `AlertDialog.content`, `Flexible`). The input now always hugs its intrinsic height.
- Fixed `StreamTextInput` content alignment so text and prefix/suffix slots are centered vertically.
- Changed `StreamTextInput` default `textCapitalization` to `TextCapitalization.sentences`.
- Updated `StreamReactionPicker` spacing to match the Figma specification.
- Updated `StreamStepper` button style to match the Figma specification.
- `StreamEmoji` now pins its primary `fontFamily` to the platform's native emoji font (Apple Color Emoji on iOS/macOS, Segoe UI Emoji on Windows, Noto Color Emoji elsewhere) so the existing per-platform `fontSize` correction lines up with the font that actually renders the glyph. `fontFamilyFallback` is unchanged.
- `StreamFileTypeIcon` now centers its SVG inside the icon's render box, so it stays centered when given larger constraints.

### 💥 Breaking Changes

- Unified `StreamRadius` across platforms; removed platform factory, `.raw()`, `.ios`, and `.android`.
- Renamed Stream Icons by removing the size suffix from the icon names.
- Renamed `StreamFileTypeIconSize` variants: `s48` → `xl`, `s40` → `lg`.
- `StreamFlex`, `StreamRow`, and `StreamColumn` now default `mainAxisSize` to `MainAxisSize.min` (was `MainAxisSize.max`). Callers that relied on the widget expanding to fill available space must now pass `mainAxisSize: MainAxisSize.max` explicitly.
- Removed `StreamMessageAnnotation.rich` and `spanTextStyle`/`spanTextColor`; use the new `trailing` slot instead.
- Aligned `StreamButton` API with Flutter's built-in buttons: renamed `label` (`String?`) to required `child` (`Widget`), changed `icon`/`iconLeft`/`iconRight` from `IconData` to `Widget`, and renamed `onTap` to `onPressed`. `StreamButtonProps` mirrors the same renames.
- Redesigned `StreamAppBar` with a slots-based API (`leading`/`title`/`subtitle`/`trailing`) and platform-aware auto-implied leading; replaces the previous Material `AppBar` wrapper. Adds `StreamAppBarStyle`, `StreamAppBarTheme`, and `StreamAppBarThemeData`.
- `placeholder` on `StreamCoreMessageComposer`, `StreamMessageComposerInput`, and `StreamMessageComposerInputField` is now an optional `String?` (was `String` defaulting to `''`, and `required` on `StreamMessageComposerInputField`).
- Removed `StreamMessageTheme`, `StreamMessageThemeData`, and `StreamMessageStyle`; `MessageComposerReplyAttachment` and `MessageComposerLinkPreviewAttachment` now read colors directly from `StreamColorScheme`.
- Renamed `StreamMessageComposerAttachmentContainer` to `StreamMessageComposerAttachment` to mirror the existing `StreamMessageAttachment` naming.
- `StreamMessageComposerAttachment` now uses `shape: OutlinedBorder?` and `side: BorderSide?` (matching `StreamMessageAttachmentStyle`) in place of the previous `borderColor` / `borderRadius` fields and constructor params. Added a `style:` constructor param taking `StreamMessageComposerAttachmentThemeData?` for per-instance overrides; the old `backgroundColor` and `borderColor` widget params are gone.
- Added `style:` per-instance override params to `MessageComposerFileAttachment`, `MessageComposerMediaFileAttachment`, `MessageComposerLinkPreviewAttachment`, and `MessageComposerReplyAttachment`. Renamed `MessageComposerReplyAttachment.style` (the `ReplyStyle` enum slot) to `direction:` so `style:` is free for the theme-data override.
- Renamed the four composer attachment widgets to add the `Stream` prefix: `MessageComposerFileAttachment` → `StreamMessageComposerFileAttachment`, `MessageComposerMediaFileAttachment` → `StreamMessageComposerMediaAttachment` (also dropped the redundant "File" segment), `MessageComposerLinkPreviewAttachment` → `StreamMessageComposerLinkPreviewAttachment`, `MessageComposerReplyAttachment` → `StreamMessageComposerReplyAttachment`.
- Replaced `ReplyStyle` with `StreamReplyDirection` (same `incoming` / `outgoing` values) used by `StreamMessageComposerReplyAttachment.direction`.
- Renamed `StreamMessageComposerLinkPreviewAttachment.media` to `thumbnail`, and `StreamMessageComposerReplyAttachment.trailing` to `thumbnail`.
- Renamed `StreamMessageComposerLinkPreviewAttachmentThemeData` fields: `mediaSize` → `thumbnailSize`, `mediaShape` → `thumbnailShape`, `mediaSide` → `thumbnailSide`.

## 0.2.0

### 💥 Breaking Changes

- Renamed `StreamInputTheme`/`StreamInputThemeData` to `StreamTextInputTheme`/`StreamTextInputThemeData` with a redesigned API
- Renamed `StreamTheme.inputTheme` to `StreamTheme.textInputTheme`
- Removed `alignment` and `offset` from `StreamOnlineIndicatorThemeData` (these are layout concerns, not theme)

### ✨ Features

- Added `child`, `alignment`, and `offset` parameters to `StreamBadgeNotification` for badge-over-child positioning
- Added `child`, `alignment`, and `offset` parameters to `StreamBadgeCount` for badge-over-child positioning
- Added `StreamSwitch` component with platform-aware styling and `style` prop
- Added `StreamTextInput` component with configurable helper text, icons, and validation states
- Added `StreamStepper` component for numeric value adjustment with customizable bounds and `style` prop
- Extended `StreamButtonThemeStyle` with sizing, alignment, padding, and shape options
- Expanded `StreamListTile` with `contentPadding` and text style customization

## 0.1.0

* First release of the Stream Core Flutter package.
* Main content of this package is the Stream Design System for Flutter, but also contains other cross-SDK utilities that depend on Flutter.
