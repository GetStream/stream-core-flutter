# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Before writing or reviewing code, read [`STYLE_GUIDE.md`](STYLE_GUIDE.md).** It is the source of truth for coding conventions, the barrel contract, theming, testing, and changelog policy. See [`TESTING.md`](TESTING.md) for guidance on writing effective tests, and [`EFFECTIVE_DART_DOC.md`](EFFECTIVE_DART_DOC.md) — a vendored copy of Effective Dart's documentation guide — before writing any dartdoc; the style guide wins where they disagree. This file is a repo overview; the style guide is the rulebook.

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

`StreamIcons` is generated: an icon font (`lib/fonts/stream_icons_font.otf`) plus
Dart constants, built by `melos run generate:icons` from the source SVGs in
`packages/stream_core_flutter/assets_source/icons/`. Those SVGs are copied from the
[design-system-tokens](https://github.com/GetStream/design-system-tokens/tree/main/assets/icons)
repo. Multicolour file-type icons are not part of the font — they ship as runtime
assets in `assets/file_type/` and are resolved by path by `StreamFileTypeIcon`.

Glyph code points are append-only and recorded in `assets_source/icon_log.g.txt`,
so adding, renaming or retiring an icon has consequences beyond the file you touch.
Never hand-edit the generated Dart, the font, or the log.

**Use the `update-icons` skill** for any icon work — it covers finding an icon
upstream, the naming and size conventions, RTL mirroring, deprecations, and the
file-type assets.

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
4. **Tokens** — light/dark concrete values in `theme/primitives/internal/tokens/`, copied by hand from the design-token repo and not part of the public API (see [Design tokens](#design-tokens))

Generated files have `.g.theme.dart` extension. After modifying `.theme.dart` files, run `melos run generate:flutter`.

### Design tokens

Colors originate in [design-system-tokens](https://github.com/GetStream/design-system-tokens),
the same repo the icons come from. `theme/primitives/internal/tokens/{light,dark}/stream_tokens.dart`
holds the vendored values; it is maintained by hand, is not part of the public API,
and only `stream_colors.dart` and `stream_color_scheme.dart` read it.

Only the **root semantics** are mapped to a `StreamColorScheme` field. Upstream's
derived tokens (`badge/*`, `button/*`, `avatar/*`) get no field — components
re-derive them from `colorScheme.*` in their own defaults. Typography, spacing and
radius do come from upstream, but `StreamTokensTypography`, `StreamSpacing` and
`StreamRadius` hard-code the values rather than reading a token constant, so a
dimension change is applied to those classes by hand. `StreamColorScheme` is
exported from `core.dart`, so every field on it is public API.

A field's dartdoc comes from the token's own `$description` in the upstream JSON —
quote it rather than inventing prose, but resolve the aliases first, since a
description tracks the token's own light/dark progression and not a comparison
with the sibling it names.

**Use the `update-design-tokens` skill** when syncing a token change or assessing
an upstream PR — it covers the naming rules, how a field default should resolve,
and how to read a change without drowning in the generator's re-sort noise.

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
