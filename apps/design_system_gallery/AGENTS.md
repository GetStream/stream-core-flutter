# Design System Gallery - Agent Guide

This document provides guidance for AI agents working on the Stream Design System Gallery (Widgetbook).

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
│   ├── semantics/                        # Semantic token showcases
│   │   ├── typography.dart               # StreamTextTheme showcase
│   │   └── elevations.dart               # StreamBoxShadow showcase
│   ├── config/
│   │   ├── theme_configuration.dart      # Theme state (colors, brightness, etc.)
│   │   └── preview_configuration.dart    # Preview state (device, text scale)
│   ├── core/
│   │   └── preview_wrapper.dart          # Wraps use cases with theme/device frame
│   └── widgets/
│       ├── toolbar/                      # Top toolbar widgets
│       └── theme_studio/                 # Theme customization panel widgets
```

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
2. Use path `[App Foundation]/TokenName` in the `@UseCase` annotation
3. Follow the same regeneration process as components

**Example:**
```dart
@widgetbook.UseCase(
  name: 'All Styles',
  type: StreamTextTheme,
  path: '[App Foundation]/Typography',
)
Widget buildStreamTextThemeShowcase(BuildContext context) {
  // Showcase implementation
}
```

## Category Ordering

The widgetbook generator sorts categories **alphabetically**. To control order, use prefixes:

- `[App Foundation]` - Sorts first (for tokens/foundations)
- `[Components]` - Sorts second

**Current structure:**
```
├── App Foundation (typography, elevations)
└── Components (avatar, button, etc.)
```

## Theme Configuration

### Accessing Theme in Use Cases

```dart
final streamTheme = StreamTheme.of(context);
final colorScheme = streamTheme.colorScheme;
final textTheme = streamTheme.textTheme;
final boxShadow = streamTheme.boxShadow;
```

### Adding New Theme Properties

1. Add private field and getter in `theme_configuration.dart`
2. Add setter using `_update()` pattern
3. Include in `_rebuildTheme()` colorScheme.copyWith()
4. Add to `resetToDefaults()`
5. Add UI control in `theme_customization_panel.dart`

## Knobs Best Practices

### Do's
- Always add `description` parameter to knobs
- Use `context.knobs.object.dropdown` for enums
- Remove knobs for properties controlled by Theme Studio

### Don'ts
- Don't add knobs that duplicate Theme Studio controls
- Don't use deprecated `context.knobs.list` (use `object.dropdown`)

## Preview Wrapper

The `PreviewWrapper` applies:
- StreamTheme as a Material theme extension
- Device frame (optional)
- Text scale

**Important:** StreamTheme is provided via `ThemeData.extensions` so `StreamTheme.of(context)` works correctly.

## Color Picker Usage

When using `flutter_colorpicker`, note that it may not rebuild correctly with `StatefulBuilder`. The current implementation uses a simple local variable approach:

```dart
var pickerColor = initialColor;
// Don't wrap in StatefulBuilder - let ColorPicker manage its own state
ColorPicker(
  pickerColor: pickerColor,
  onColorChanged: (c) => pickerColor = c,
)
```

## Styling Guidelines

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
boxShadow: streamTheme.boxShadow.elevation2

// Bad - custom shadows
boxShadow: [BoxShadow(blurRadius: 10, ...)]
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

## Common Commands

```bash
# Regenerate widgetbook directories
dart run build_runner build --delete-conflicting-outputs

# Format code
dart format lib/

# Analyze
flutter analyze

# Run gallery
flutter run -d chrome  # or macos/windows
```

## Troubleshooting

### Theme changes not reflecting in use cases
Ensure `StreamTheme` is added to `ThemeData.extensions` in `PreviewWrapper`:
```dart
Theme(
  data: ThemeData(
    extensions: [streamTheme],  // Required!
  ),
  child: ...,
)
```

### Generated file has wrong order
The generator sorts alphabetically. Use category name prefixes to control order (e.g., "App Foundation" before "Components").

