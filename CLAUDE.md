# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

## Design

UI components are designed in **Figma**. When implementing or modifying components, use the **Figma MCP** to inspect designs directly — check spacing, colors, typography, and component structure from the source rather than guessing.

## Architecture

### Theme System (`stream_core_flutter/lib/src/theme/`)

Uses `theme_extensions_builder` to generate Material 3 theme extensions. The hierarchy is:

1. **Primitives** — raw design tokens: colors, typography, spacing, radius, icons
2. **Semantics** — semantic mappings (e.g., `primaryColor`, `bodyText`)
3. **Component themes** — per-widget theme classes (50+ components), defined in `theme/components/`
4. **Tokens** — light/dark concrete values in `theme/tokens/`

Generated files have `.g.theme.dart` extension. After modifying `.theme.dart` files, run `melos run generate:flutter`.

### Component Structure (`stream_core_flutter/lib/src/components/`)

Components are organized by category: `avatar/`, `buttons/`, `badge/`, `channel_list/`, `list/`, `message_composer/`, `emoji/`, `context_menu/`, `controls/`, `common/`, `accessories/`.

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
