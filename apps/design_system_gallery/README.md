# Stream Design System Gallery

Production Widgetbook app for documenting and validating `stream_core_flutter`
components and design tokens.

## What This App Provides

- Interactive component use cases with knobs (Widgetbook).
- Foundation token showcases (primitives + semantic tokens).
- Theme Studio controls for live visual tuning.
- Device preview wrapper for realistic UI evaluation.

## Run Locally

```bash
cd apps/design_system_gallery
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

## Quality Checks

```bash
cd apps/design_system_gallery
dart run build_runner build --delete-conflicting-outputs
dart format lib
flutter analyze
```

## Adding A New Component Showcase

1. Create a use-case file in `lib/components/<category>/`.
2. Add `@widgetbook.UseCase(...)` entries (at minimum: Playground + Showcase).
3. Regenerate directories with `build_runner`.
4. Run format and analyze checks.

The generated file `lib/app/gallery_app.directories.g.dart` is owned by
`widgetbook_generator` and should not be edited manually.
