# Design System Gallery - Agent Guide

This document provides guidance for AI agents working on the Stream Design System Gallery (Widgetbook).

---

## Table of Contents

1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [Common Commands](#common-commands)
4. [Theme & Styling](#theme--styling)
   - [Accessing Theme](#accessing-theme-in-use-cases-context-extensions)
   - [Styling Guidelines](#styling-guidelines)
   - [Keeping Material Theme in Sync](#keeping-material-theme-in-sync)
5. [Adding Content](#adding-content)
   - [Adding Components](#adding-new-components)
   - [Adding Semantic Tokens](#adding-semantic-token-showcases)
   - [Adding Primitives](#adding-primitive-token-showcases)
   - [Showcase Structure Patterns](#showcase-structure-patterns)
   - [Category Ordering](#category-ordering)
   - [Knobs Best Practices](#knobs-best-practices)
6. [Technical Details](#technical-details)
   - [ThemeConfiguration](#themeconfiguration)
   - [Preview Wrapper](#preview-wrapper)
7. [Troubleshooting](#troubleshooting)

---

## Overview

The gallery showcases Stream's design system components and foundation tokens. It uses:
- **Widgetbook** for component documentation
- **Provider** for state management
- **device_frame_plus** for device previews

## Project Structure

```
apps/design_system_gallery/
├── lib/
│   ├── app/
│   │   ├── gallery_app.dart              # Entry point with ChangeNotifierProvider setup
│   │   ├── gallery_app.directories.g.dart # Generated widgetbook directories (DO NOT EDIT)
│   │   └── gallery_shell.dart            # Main shell with toolbar and layout
│   ├── components/                        # Component use cases
│   │   ├── button.dart
│   │   ├── stream_avatar.dart
│   │   ├── stream_avatar_stack.dart
│   │   └── stream_online_indicator.dart
│   ├── semantics/                        # Semantic token showcases (design system level)
│   │   ├── typography.dart               # StreamTextTheme showcase
│   │   └── elevations.dart               # StreamBoxShadow showcase
│   ├── primitives/                       # Primitive token showcases (raw values)
│   │   ├── radius.dart                   # StreamRadius showcase
│   │   ├── spacing.dart                  # StreamSpacing showcase
│   │   └── colors.dart                   # StreamColors showcase
│   ├── config/
│   │   ├── theme_configuration.dart      # Theme state (colors, brightness, etc.)
│   │   └── preview_configuration.dart    # Preview state (device, text scale)
│   ├── core/
│   │   └── preview_wrapper.dart          # Wraps use cases with theme/device frame
│   └── widgets/
│       ├── toolbar/                      # Top toolbar widgets
│       └── theme_studio/                 # Theme customization panel widgets
```

## Common Commands

```bash
# Regenerate widgetbook directories (after adding/modifying use cases)
dart run build_runner build --delete-conflicting-outputs

# Format code
dart format lib/

# Analyze
flutter analyze

# Run gallery
flutter run -d chrome  # or macos/windows
```

---

# Theme & Styling

## Accessing Theme in Use Cases (Context Extensions)

**Preferred:** Use context extensions for clean, concise access:

```dart
// Recommended - use context extensions
final colorScheme = context.streamColorScheme;
final textTheme = context.streamTextTheme;
final boxShadow = context.streamBoxShadow;
final radius = context.streamRadius;
final spacing = context.streamSpacing;

// For component themes
final avatarTheme = context.streamAvatarTheme;
final indicatorTheme = context.streamOnlineIndicatorTheme;
```

**Alternative:** Direct access via `StreamTheme.of(context)`:

```dart
final streamTheme = StreamTheme.of(context);
final colorScheme = streamTheme.colorScheme;
final textTheme = streamTheme.textTheme;
```

## Styling Guidelines

### Use context extensions (preferred)

```dart
// Good - use context extensions
final colorScheme = context.streamColorScheme;
final textTheme = context.streamTextTheme;
style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary)

// Avoid - passing parameters through widget tree
MyWidget({required this.colorScheme, required this.textTheme})
```

### Don't pass theme data as parameters

Widgets should access theme from context, not receive it as constructor parameters:

```dart
// Good - access from context in build method
class _MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    return Text('Hello', style: textTheme.bodyDefault);
  }
}

// Bad - passing through constructor
class _MyWidget extends StatelessWidget {
  final StreamColorScheme colorScheme;
  final StreamTextTheme textTheme;
  // ...
}
```

### Use StreamTheme tokens

```dart
// Good
style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary)

// Bad - hardcoded values
style: TextStyle(fontSize: 12, color: Colors.grey)
```

### Use StreamBoxShadow

```dart
// Good
boxShadow: context.streamBoxShadow.elevation2

// Bad - custom shadows
boxShadow: [BoxShadow(blurRadius: 10, ...)]
```

### Use StreamRadius

```dart
// Good
borderRadius: BorderRadius.all(context.streamRadius.md)

// Bad - hardcoded values
borderRadius: BorderRadius.circular(8)
```

### Border handling

Use `foregroundDecoration` for borders to prevent clipping:

```dart
Container(
  clipBehavior: Clip.antiAlias,
  decoration: BoxDecoration(
    color: colorScheme.backgroundSurface,
    borderRadius: BorderRadius.circular(12),
  ),
  foregroundDecoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: colorScheme.borderSurfaceSubtle),
  ),
  child: ...,
)
```

## Keeping Material Theme in Sync

When modifying `ThemeConfiguration`, ensure `buildMaterialTheme()` stays updated:

1. **New color properties** → Add to `ColorScheme` mapping and relevant theme components (buttons, inputs, dialogs, etc.)
2. **New text styles** → Update `TextTheme` mapping to use appropriate Stream styles
3. **New radius/spacing** → Update component themes that use borders/padding

**Check these areas in `buildMaterialTheme()`:**
- `ColorScheme` - maps Stream colors to Material semantic colors
- `ThemeData` properties - `primaryColor`, `scaffoldBackgroundColor`, etc.
- Component themes - `dialogTheme`, `appBarTheme`, `filledButtonTheme`, etc.
- `TextTheme` - maps Stream text styles to Material text styles
- `extensions` - must include `[themeData]` for `StreamTheme.of(context)` to work

---

# Adding Content

## Adding New Components

### 1. Create Use Case File

Create a new file in `lib/components/`:

```dart
import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Playground',
  type: MyComponent,
  path: '[Components]/MyComponent',  // Category in brackets, then folder
)
Widget buildMyComponentPlayground(BuildContext context) {
  // Use knobs for interactive controls
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Default',
    description: 'Description for this knob.',
  );

  // Access theme
  final streamTheme = StreamTheme.of(context);
  final colorScheme = streamTheme.colorScheme;

  return MyComponent(label: label);
}
```

### 2. Use Case Naming Convention

Each component should have these use cases (in order):
1. **Playground** - Interactive with knobs
2. **Type/Size Variants** - Shows all variants side by side
3. **Real-world Example** - Contextual usage

### 3. Regenerate Directories

After adding/modifying use cases:

```bash
cd apps/design_system_gallery
dart run build_runner build --delete-conflicting-outputs
dart format lib/
flutter analyze
```

## Adding Semantic Token Showcases

Semantic tokens (like `StreamTextTheme`, `StreamBoxShadow`) are showcased in `lib/semantics/`:

1. Create a new file in `lib/semantics/`
2. Use path `[App Foundation]/Semantics/TokenName` in the `@UseCase` annotation
3. Follow the same regeneration process as components

**Example:**
```dart
@widgetbook.UseCase(
  name: 'All Styles',
  type: StreamTextTheme,
  path: '[App Foundation]/Semantics/Typography',
)
Widget buildStreamTextThemeShowcase(BuildContext context) {
  // Showcase implementation
}
```

## Adding Primitive Token Showcases

Primitives (raw values like `StreamRadius`, `StreamSpacing`, `StreamColors`) are showcased in `lib/primitives/`:

1. Create a new file in `lib/primitives/`
2. Use path `[App Foundation]/Primitives/TokenName` in the `@UseCase` annotation

**Example:**
```dart
@widgetbook.UseCase(
  name: 'Scale',
  type: StreamRadius,
  path: '[App Foundation]/Primitives/Radius',
)
Widget buildStreamRadiusShowcase(BuildContext context) {
  // Showcase implementation
}
```

## Showcase Structure Patterns

All primitives and semantics showcases follow a consistent structure. Reference existing files (`radius.dart`, `spacing.dart`, `typography.dart`, `elevations.dart`) for implementation examples.

### Required Elements

1. **`_SectionLabel` widget** - Accent-colored label for section headers (uppercase, letter-spacing)
2. **`_QuickReference` section** - Usage patterns and common choices at the bottom
3. **Token cards** - Visual preview (left) + info (right) layout

### Card Styling Conventions

- Token names: `accentPrimary` color, monospace font
- Value chips: `backgroundSurfaceSubtle` background, `textSecondary` color
- Usage descriptions: `textTertiary` color
- Borders: Use `foregroundDecoration` (not `border:` in BoxDecoration)
- Shadows: `boxShadow.elevation1`

## Category Ordering

The widgetbook generator sorts categories **alphabetically**. To control order, use prefixes:

- `[App Foundation]` - Sorts first (for tokens/foundations)
- `[Components]` - Sorts second

**Current structure:**
```
├── App Foundation
│   ├── Primitives
│   │   ├── Colors
│   │   ├── Radius
│   │   └── Spacing
│   └── Semantics
│       ├── Elevations
│       └── Typography
└── Components
    ├── Avatar (StreamAvatar, StreamAvatarStack)
    ├── Button
    └── Indicator (StreamOnlineIndicator)
```

## Knobs Best Practices

### Do's
- Always add `description` parameter to knobs
- Use `context.knobs.object.dropdown` for enums
- Remove knobs for properties controlled by Theme Studio

### Don'ts
- Don't add knobs that duplicate Theme Studio controls
- Don't use deprecated `context.knobs.list` (use `object.dropdown`)

---

# Technical Details

## ThemeConfiguration

### Accessing ThemeConfiguration

Use `context.read<ThemeConfiguration>()` for calling methods (no rebuild on change):

```dart
// For calling setters/methods - use read
context.read<ThemeConfiguration>().setAccentPrimary(color);
context.read<ThemeConfiguration>().resetToDefaults();
```

Use `context.watch<ThemeConfiguration>()` only when you need to rebuild on changes (typically only in `gallery_app.dart`).

### Adding New Theme Properties

1. Add private field and getter in `theme_configuration.dart`
2. Add setter using `_update()` pattern
3. Include in `_rebuildTheme()` colorScheme.copyWith()
4. Add to `resetToDefaults()`
5. Add UI control in `theme_customization_panel.dart`

### Best Practices

**Use class getters directly** in `buildMaterialTheme()`:

```dart
// Good - uses class getters directly
ThemeData buildMaterialTheme() {
  return ThemeData(
    primaryColor: accentPrimary,  // Class getter
    scaffoldBackgroundColor: backgroundApp,  // Class getter
  );
}

// Avoid - unnecessary indirection
ThemeData buildMaterialTheme() {
  final cs = themeData.colorScheme;
  return ThemeData(
    primaryColor: cs.accentPrimary,  // Through colorScheme
  );
}
```

**Use public getters** instead of private fields within the class:

```dart
// Good
final isDark = brightness == Brightness.dark;

// Avoid
final isDark = _brightness == Brightness.dark;
```

## Preview Wrapper

The `PreviewWrapper` applies:
- StreamTheme as a Material theme extension
- Device frame (optional)
- Text scale

**Important:** StreamTheme is provided via `ThemeData.extensions` so `StreamTheme.of(context)` works correctly.

---

## Troubleshooting

### Theme changes not reflecting in use cases
Ensure `StreamTheme` is added to `ThemeData.extensions`:
```dart
ThemeData(
  extensions: [streamTheme],  // Required for StreamTheme.of(context)!
)
```

This is done in `ThemeConfiguration.buildMaterialTheme()`.

### Generated file has wrong order
The generator sorts alphabetically. Use category name prefixes to control order (e.g., "App Foundation" before "Components").

### Widgets not updating when theme changes
Ensure you're using context extensions (`context.streamColorScheme`) which properly depend on the inherited theme. Don't cache theme values in state.


