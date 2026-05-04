## Upcoming

### ✨ Features

- Added `StreamJumpToUnreadButton` component and `StreamJumpToUnreadButtonTheme`.
- Added `StreamVideoPlayIndicator` component with `StreamVideoPlayIndicatorSize` variants.
- Added `StreamFileTypeIconSize.md` and `StreamFileTypeIconSize.sm` variants.
- Added `trailing` slot to `StreamMessageAnnotation`, with matching `trailingTextStyle`/`trailingTextColor` on `StreamMessageAnnotationStyle`.
- Added `StreamTapTargetPadding`, a reusable primitive that grows a child's layout and hit-test area to a configurable `minSize` without changing its visual size, with a directional `alignment` that controls which direction the extra tap area extends into.
- Added `StreamSheetHeader` component and `StreamSheetHeaderTheme` for bottom-sheet and modal headers, with platform-aware auto-implied dismissal based on the enclosing route.
- Added `StreamHeaderToolbar`, a three-slot layout primitive shared by `StreamAppBar` and `StreamSheetHeader` that keeps the title geometrically centred even when leading and trailing widths differ.
- Added `StreamSheet`, `StreamSheetDragHandle`, `StreamSheetRoute`, `StreamSheetTransition` and the `showStreamSheet` helper — Stream-styled modal bottom sheets with scroll-aware drag-to-dismiss and stacking support. `StreamSheet` can also be used standalone outside the modal route.
- Added `StreamSheetTheme` and `StreamSheetThemeData` (`StreamTheme.sheetTheme`) for theming `StreamSheet` and modal sheets opened with `showStreamSheet`.
- `StreamEmojiPickerSheet.show` now resolves its background color and border radius from the ambient `StreamSheetTheme` so the picker visually matches other Stream-styled sheets by default.
- `StreamLoadingSpinner` now renders a completion checkmark when progress reaches 100%.
- `StreamCommandChip` is now tappable across its whole surface, not just the × icon.
- `StreamRemoveControl` now meets the 48 dp minimum tap target by default while keeping its 20 dp visible badge anchored to the top-end corner. Exposes `tapTargetSize`, `visualDensity`, and `semanticLabel`, and announces itself as a button to screen readers.
- Added `textAlignVertical` to `StreamTextInput` (and `StreamTextInputProps`) for controlling the vertical alignment of the text within the input.
- Added `cursorColor`, `cursorErrorColor`, `cursorWidth`, `cursorHeight`, and `cursorRadius` to `StreamTextInputStyle` for customizing the text input cursor. `cursorErrorColor` is applied automatically when `helperState` is `StreamHelperState.error`. `StreamMessageComposerInputField` also honors these cursor properties from the theme.
- Exported `DefaultStreamEmoji` so consumers can compose with or wrap the default emoji rendering when overriding via `StreamComponentFactory`.

### 🐞 Fixed

- Fixed RTL layout for composer input field.
- Fixed RTL layout for audio waveform and waveform slider.
- Fixed `StreamTextInput` stretching vertically when placed inside a parent with bounded `maxHeight` (e.g. `AlertDialog.content`, `Flexible`). The input now always hugs its intrinsic height.
- Fixed `StreamTextInput` content alignment so text and prefix/suffix slots are centered vertically.
- Changed `StreamTextInput` default `textCapitalization` to `TextCapitalization.sentences`.
- Updated `StreamReactionPicker` spacing to match the Figma specification.
- Updated `StreamStepper` button style to match the Figma specification.
- `StreamEmoji` now pins its primary `fontFamily` to the platform's native emoji font (Apple Color Emoji on iOS/macOS, Segoe UI Emoji on Windows, Noto Color Emoji elsewhere) so the existing per-platform `fontSize` correction lines up with the font that actually renders the glyph. `fontFamilyFallback` is unchanged.

### 💥 Breaking Changes

- Unified `StreamRadius` across platforms; removed platform factory, `.raw()`, `.ios`, and `.android`.
- Renamed Stream Icons by removing the size suffix from the icon names.
- Renamed `StreamFileTypeIconSize` variants: `s48` → `xl`, `s40` → `lg`.
- Removed `StreamMessageAnnotation.rich` and `spanTextStyle`/`spanTextColor`; use the new `trailing` slot instead.
- Aligned `StreamButton` API with Flutter's built-in buttons: renamed `label` (`String?`) to required `child` (`Widget`), changed `icon`/`iconLeft`/`iconRight` from `IconData` to `Widget`, and renamed `onTap` to `onPressed`. `StreamButtonProps` mirrors the same renames.
- Redesigned `StreamAppBar` with a slots-based API (`leading`/`title`/`subtitle`/`trailing`) and platform-aware auto-implied leading; replaces the previous Material `AppBar` wrapper. Adds `StreamAppBarStyle`, `StreamAppBarTheme`, and `StreamAppBarThemeData`.
- `placeholder` on `StreamCoreMessageComposer`, `StreamMessageComposerInput`, and `StreamMessageComposerInputField` is now an optional `String?` (was `String` defaulting to `''`, and `required` on `StreamMessageComposerInputField`).
- Removed `StreamMessageTheme`, `StreamMessageThemeData`, and `StreamMessageStyle`; `MessageComposerReplyAttachment` and `MessageComposerLinkPreviewAttachment` now read colors directly from `StreamColorScheme`.

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
