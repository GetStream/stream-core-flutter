# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Before writing or reviewing code, read [`STYLE_GUIDE.md`](STYLE_GUIDE.md).** It is the source of truth for coding conventions, the barrel contract, theming, testing, and changelog policy. See [`TESTING.md`](TESTING.md) for guidance on writing effective tests. This file is a repo overview; the style guide is the rulebook.

## Project Overview

A Flutter monorepo managed with **Melos** containing:
- `packages/stream_core` — Pure Dart SDK (WebSocket, HTTP, models, utilities)
- `packages/stream_core_flutter` — Flutter UI component library with a full design system
- `apps/design_system_gallery` — Widgetbook-based interactive component showcase

## Common Commands

All commands use Melos and should be run from the repo root.

```bash
# Setup
melos bootstrap

# Linting & formatting
melos run lint:all          # analyze + format check
melos run analyze
melos run format
melos run format:verify     # check only, no changes
melos run check:barrels     # validate public-barrel contract (see Architecture)

# Testing
melos run test:all          # all tests with coverage
melos run test:dart         # stream_core only
melos run test:flutter      # stream_core_flutter only

# Golden tests
melos run update:goldens    # regenerate golden images

# Code generation (run after model/theme changes)
melos run generate:all
melos run generate:icons    # regenerate icon font from SVGs
melos run gen-l10n          # regenerate localizations
```

**Line width:** 120 characters (set in `analysis_options.yaml`).

### Icons

Source SVGs in `packages/stream_core_flutter/assets_source/icons/` come from the [design-system-tokens](https://github.com/GetStream/design-system-tokens/tree/main/assets/icons) repository. When adding or updating icons, pull the latest SVGs from that repo first, then run `melos run generate:icons` to regenerate the icon font and Dart classes.

Upstream names carry a size suffix that this repo strips or rewrites: everything in `20/` keeps its bare name (`account-20.svg` → `account.svg`), `16/` currently holds only `xmark-small.svg`, and `32/` uses a `-large` suffix (`camera-32.svg` → `camera-large.svg`).

**Names must be unique across the size folders.** Glyphs are keyed by bare filename, so copying a whole upstream size folder is how you accidentally end up with e.g. `16/xmark-small.svg` and `20/xmark-small.svg` competing for one glyph. The generator fails on a duplicate rather than letting directory-listing order pick a winner.

**Code points are append-only.** `assets_source/icon_log.g.txt` records the date each icon was first seen, and the generator orders glyphs by that date so every icon keeps its code point across runs. The font ships as `lib/fonts/stream_icons_font.otf`, so a shifted code point silently repoints every icon after it in any app that has not rebuilt. Never reorder or hand-edit the log.

**Deleting an icon therefore requires a deprecation entry** in `assets_source/deprecated.txt` — one `deprecated;replacement;included` line per icon:

```
more;more-horizontal;true
```

- `replacement` — the icon whose SVG draws the glyph. A deprecated icon always keeps its glyph, and with it its code point; pointing at a replacement is what lets you delete the retired SVG and still render something sensible. Naming itself (`more;more;true`) keeps the original artwork while retiring the name.
- `included` — whether the name survives in the generated Dart. `true` emits `StreamIcons.more` and `StreamIconData.more` annotated with `@Deprecated('Use moreHorizontal instead.')`; `false` drops both while the glyph stays in the font.

Entries are effectively permanent — removing one releases its glyph and shifts every later code point. The generator fails if a replacement has no SVG file, or if a deprecated name has neither an SVG file nor a logged code point (which means a typo).

Deprecating an icon also means adding transforms to `lib/fix_data.yaml`; see [Deprecations](#deprecations).

## Design

UI components are designed in **Figma**. When implementing or modifying components, use the **Figma MCP** to inspect designs directly — check spacing, colors, typography, and component structure from the source rather than guessing.

## Deprecations

The policy itself lives in [`STYLE_GUIDE.md`](STYLE_GUIDE.md#clearly-mark-deprecated-apis): annotate with `@Deprecated('Use X instead.')`, add a `### 🛑 Breaking / Removals` CHANGELOG entry pointing at the replacement, and keep the deprecated API for at least one minor release.

On top of that, give every deprecated member a migration in `packages/stream_core_flutter/lib/fix_data.yaml` ([format docs](https://dart.dev/tools/dart-fix)) so consumers can move off it with:

```bash
dart fix --apply
```

Things worth knowing about that file:

- Dart only reads it at `lib/fix_data.yaml` or `lib/fix_data/*.yaml`. `element.uris` must list the library that declares the member **and** every barrel it is exported from (`core.dart`, `chat.dart`, `stream_core_flutter.dart`) — a transform whose uris miss the barrel the consumer actually imported never fires.
- Treat it as **append-only**. A transform's real value is carrying someone across the release that finally deletes the member, so it has to outlive the deprecation that motivated it. Never drop an entry just because the member is gone.
- A member reached only through generated code needs its own transform, and may not warn at all. `StreamIcons.copyWith(more: ...)` is the worked example: `copyWith` is generated onto the private `_$StreamIcons` mixin, which does not inherit the field's `@Deprecated`, so the call raises no warning while the field exists — its transform (`inMixin: "_$StreamIcons"`) only fires once the field is deleted and the call becomes an `undefined_named_parameter` error.
- **Verify a transform by running it, not by reading the YAML.** Write a throwaway file exercising each call shape (bare constant, instance field, constructor argument, `copyWith`), run `dart fix --dry-run`, then re-run with the transform removed to confirm the fix disappears — the analyzer offers generic "did you mean" fixes that are easy to mistake for your own.

## Architecture

### Public-Barrel Contract (`stream_core_flutter`)

The package exposes two narrow public barrels so non-chat Stream SDKs (video, feeds, ...) can pull in just the shared primitives without paying for chat code:

- `package:stream_core_flutter/core.dart` — shared UI primitives, theme tokens, the component factory. Safe for any Stream SDK.
- `package:stream_core_flutter/chat.dart` — chat-specific widgets (message bubble, composer attachments, reactions, ...). Chat SDKs import this **alongside** `core.dart`.
- `package:stream_core_flutter/stream_core_flutter.dart` — deprecated convenience barrel that re-exports both. Will be removed at 1.0.0.

Rules enforced by `melos run check:barrels` (config at `packages/stream_core_flutter/check_barrels.yaml`, and wired into CI):

1. Every public file under `lib/src/` must appear in exactly one barrel. No duplicates, no orphans, no dangling exports.
2. No file under `lib/src/` may import a public barrel (`core.dart`, `chat.dart`, `stream_core_flutter.dart`). Use a specific relative import to the source file instead — barrels are for **consumers**, not internal code.
3. Anything under an `internal/` directory listed in `check_barrels.yaml`'s `internal_dirs` is excluded from coverage. Use this for figma-generated tokens and other implementation-only artefacts.

When adding a new public widget or theme: create the file under `lib/src/...`, then add an `export 'src/.../my_file.dart';` line to either `core.dart` or `chat.dart`. The check fails on PR if you forget.

### Theme System (`stream_core_flutter/lib/src/theme/`)

Uses `theme_extensions_builder` to generate Material 3 theme extensions. The hierarchy is:

1. **Primitives** — raw design tokens: colors, typography, spacing, radius, icons
2. **Semantics** — semantic mappings (e.g., `primaryColor`, `bodyText`)
3. **Component themes** — per-widget theme classes (50+ components), defined in `theme/components/`
4. **Tokens** — light/dark concrete values in `theme/primitives/internal/tokens/` (figma-generated, not part of the public API)

Generated files have `.g.theme.dart` extension. After modifying `.theme.dart` files, run `melos run generate:flutter`.

### Component Structure (`stream_core_flutter/lib/src/components/`)

Components are organized by category: `avatar/`, `buttons/`, `badge/`, `list/`, `message_composer/`, `emoji/`, `context_menu/`, `controls/`, `common/`, `accessories/`.

Each component typically has:
- A widget file
- A theme file in `theme/components/`
- A golden test in `test/components/<name>/`
- A Widgetbook use-case in `apps/design_system_gallery/`

### stream_core Package

Pure Dart. Key modules:
- `src/ws/` — WebSocket client with reconnect/backoff logic (RxDart-based)
- `src/api/` — Dio HTTP client with interceptors
- `src/attachment/` — File upload and CDN client
- `src/query/` — Query builders and filter models
- `src/logger/` — Structured logging
- `src/user/` — User models and token management

### Golden Testing

Golden tests use **Alchemist** (`^0.13.0`). Goldens are stored under:
- `test/components/<name>/goldens/ci/` — for CI
- `test/components/<name>/goldens/macos/` — for local macOS development

Golden tests are tagged with `golden` in `dart_test.yaml`. Run `melos run update:goldens` to regenerate after visual changes.

### Code Generation

- **json_serializable** — model serialization (`.g.dart` files)
- **build_runner** — orchestrates all generation
- **theme_extensions_builder** — generates theme extension classes (`.g.theme.dart`)
- **widgetbook_generator** — auto-generates Widgetbook entries

After any model or theme annotation changes, run the appropriate generate command before running tests.
