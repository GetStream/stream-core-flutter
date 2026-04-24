## Upcoming

### ✨ Features

- Added `StreamJumpToUnreadButton` component and `StreamJumpToUnreadButtonTheme`.
- Added `StreamVideoPlayIndicator` component with `StreamVideoPlayIndicatorSize` variants.
- Added `StreamFileTypeIconSize.md` and `StreamFileTypeIconSize.sm` variants.
- Added `trailing` slot to `StreamMessageAnnotation`, with matching `trailingTextStyle`/`trailingTextColor` on `StreamMessageAnnotationStyle`.
- Added `StreamTapTargetPadding`, a reusable primitive that grows a child's layout and hit-test area to a configurable `minSize` without changing its visual size, with a directional `alignment` that controls which direction the extra tap area extends into.
- `StreamLoadingSpinner` now renders a completion checkmark when progress reaches 100%.
- `StreamCommandChip` is now tappable across its whole surface, not just the × icon.
- `StreamRemoveControl` now meets the 48 dp minimum tap target by default while keeping its 20 dp visible badge anchored to the top-end corner. Exposes `tapTargetSize`, `visualDensity`, and `semanticLabel`, and announces itself as a button to screen readers.

### 🐞 Fixed

- Fixed RTL layout for composer input field.
- Fixed RTL layout for audio waveform and waveform slider.

### 💥 Breaking Changes

- Unified `StreamRadius` across platforms; removed platform factory, `.raw()`, `.ios`, and `.android`.
- Renamed Stream Icons by removing the size suffix from the icon names.
- Renamed `StreamFileTypeIconSize` variants: `s48` → `xl`, `s40` → `lg`.
- Removed `StreamMessageAnnotation.rich` and `spanTextStyle`/`spanTextColor`; use the new `trailing` slot instead.

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
