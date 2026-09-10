---
name: update-icons
description: >
  Add, update, retire or debug icons in stream_core_flutter — pulling SVGs from GetStream/design-system-tokens
  into `assets_source/icons/`, regenerating the icon font and `StreamIcons` via `melos run generate:icons`,
  handling RTL mirroring, deprecations and code points, and updating the multicolor file-type SVGs. Use whenever
  an icon needs adding or replacing, whenever `melos run generate:icons` fails or warns, whenever an icon renders
  as the wrong glyph or a box, whenever an icon should mirror in RTL, and whenever someone asks whether an icon
  exists upstream. Also use before deleting any SVG from `assets_source/icons/` — a bare delete silently
  repoints every icon after it.
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
---

# Updating icons

Icons come from
[GetStream/design-system-tokens](https://github.com/GetStream/design-system-tokens/tree/main/assets/icons),
the same repo the color tokens come from. `melos run generate:icons` turns
`assets_source/icons/` into a font (`lib/fonts/stream_icons_font.otf`) plus the
`StreamIcons` / `StreamIconData` classes.

The single fact that governs everything here: **glyph code points are
append-only**. The font ships as a binary asset, so a shifted code point silently
repoints every icon after it in any app that has not rebuilt. That is why
deleting an SVG needs a deprecation entry, why names must be unique, and why
`assets_source/icon_log.g.txt` is never hand-edited.

## Finding the icon upstream

Upstream groups by *product*, then style, then size:

```
assets/icons/{core,chat,video}/flat/{12,16,20,32}/
assets/icons/{core,chat,video}/line/
assets/icons/chat/filetype/
```

Products follow **component ownership, not subject matter**, so the product tells
you nothing about what an icon depicts: `camera` is a **chat** icon (the
composer's camera button) while `camera-flip-fill` is **video**. Search all three
before concluding an icon does not exist:

```bash
# from a design-system-tokens checkout (normally a sibling of this repo)
find assets/icons -name "*camera*" -path "*/flat/*"
```

Only `flat/` (solid filled paths) goes into the font. `line/` is a stroke-based
outline set covering nearly the same names and is **deliberately unused** — the
two styles do not read as one set, so do not mix them in. `chat/filetype/` is
multicolor and takes a completely separate path (see the end of this file).

## Copying it in

This repo carries a single size-keyed tree, no product split:
`assets_source/icons/{16,20,32}/`. The generator emits one font and one
`StreamIcons` class, so there is nothing for a product segment to key off — which
also means a `core` name and a `video` name collide here exactly as two sizes
would.

Naming on the way in:

- **`20/` is the default** and holds essentially everything. Strip the upstream
  size suffix: `core/flat/20/account-20.svg` → `20/account.svg`.
- **Off-default sizes need a name that cannot collide with their `20/` sibling.**
  `32/` established `-large`: `chat/flat/32/camera-32.svg` → `32/camera-large.svg`.
  `16/` has no convention yet — its single icon (`xmark-small`) was copied bare
  back when nothing in `20/` shared the name.

Copy in **only the sizes a design actually calls for**. Upstream ships everything
in all four sizes; do not bulk-copy a folder to "have it available" — every name
burns a permanent code point.

**Names must be unique across sizes and across products.** The generator fails on
a duplicate rather than letting directory order pick a winner. This is a live
trap: upstream ships `xmark-small` in both `core/flat/16` and `core/flat/20`
**with different artwork**. We ship the 16px one. Adopting the 20px variant too
means giving it a distinct name and a new code point — never silently swapping
the artwork behind the existing name, which would repaint the glyph everywhere it
is already used.

## RTL mirroring

If the icon should mirror in RTL layouts, add its base name to `_rtlIcons` in
`scripts/generate_icons.dart` so the generator emits
`matchTextDirection: true`.

This covers the obvious directional glyphs (arrows, chevrons, `reply`, `send`,
`sidebar`) but also icons whose *metaphor* is directional and reads wrong
unmirrored (`audio`, `megaphone`, `search`, `video`). Skip anything symmetric or
brand-owned (a bell, a heart, a logo). When unsure, look at what comparable icons
in the list already do.

## Regenerating

```bash
melos run generate:icons
```

Two expected messages, both harmless:

- a warning about **mixed viewBox sizes** — that is the `16/` and `32/` folders
  doing their job.
- nothing about re-centering: `stream_icons.yaml` sets `normalize: false` on
  purpose. The default re-centers each glyph by its bounding box, which undoes
  deliberate optical offsets (the `play-fill` triangle is nudged right inside its
  viewBox so it reads as centered to the eye).

Commit the SVG sources, the regenerated font, the Dart output **and** the updated
`icon_log.g.txt` together — they have to stay in sync. Never hand-edit the
generated `stream_icons.dart` / `stream_icons.g.dart`, the font, or the log.

The log records the date each icon was first seen and the generator orders glyphs
by it, which is what preserves code points across runs. Reordering it reshuffles
the font.

## Broken or odd-looking source SVGs

Fix the artwork **upstream**, with a PR to design-system-tokens — never add a
repair step to the generator. The generator's job is to validate and fail loudly,
not to paper over source defects; a workaround here means every other platform
keeps consuming the broken file.

## Retiring an icon

A bare delete is what shifts code points, so deleting an SVG requires a line in
`assets_source/deprecated.txt`:

```
deprecated;replacement;included
more;more-horizontal;true
```

- **`replacement`** — the icon whose SVG draws the glyph. A deprecated icon always
  keeps its glyph and therefore its code point; pointing at a replacement is what
  lets you delete the retired SVG and still render something sensible. A
  self-reference (`more;more;true`) keeps the original artwork while retiring just
  the name.
- **`included`** — whether the name survives in the generated Dart. `true` emits
  `StreamIcons.more` and `StreamIconData.more` annotated with
  `@Deprecated('Use moreHorizontal instead.')`; `false` drops both while the glyph
  stays in the font.

Entries are effectively permanent — removing one releases its glyph and shifts
every later code point. The generator fails if a replacement has no SVG file, or
if a deprecated name has neither an SVG nor a logged code point (which means a
typo).

Deprecating also means a `dart fix` migration in
`packages/stream_core_flutter/lib/fix_data.yaml`, plus the usual
`### 🛑 Breaking / Removals` CHANGELOG entry. Two things specific to icons:

- `element.uris` must list the declaring library **and** every barrel it is
  exported from (`core.dart`, `chat.dart`, `stream_core_flutter.dart`). A
  transform whose uris miss the barrel the consumer actually imported never
  fires.
- `StreamIcons.copyWith(more: ...)` needs its own transform with
  `inMixin: "_$StreamIcons"`. `copyWith` is generated onto that private mixin,
  which does not inherit the field's `@Deprecated`, so the call raises no warning
  while the field exists — the transform only fires once the field is deleted and
  the call becomes an `undefined_named_parameter` error.

**Verify a transform by running it, not by reading the YAML.** Write a throwaway
file exercising each call shape (bare constant, instance field, constructor
argument, `copyWith`), run `dart fix --dry-run`, then re-run with the transform
removed to confirm the fix disappears — the analyzer offers generic "did you
mean" fixes that are easy to mistake for your own.

## File-type icons

`chat/filetype/` follows a completely separate path and **none of the rules above
apply** — no generator, no font, no code points. The SVGs are copied into
`packages/stream_core_flutter/assets/file_type/`, declared as assets in
`pubspec.yaml`, and resolved by path at runtime by `StreamFileTypeIcon`. Updating
them is copy-and-rename.

Upstream names them by t-shirt size; this repo renames each to its **pixel
height**, because the widget interpolates that height straight into the asset path
(`assets/file_type/filetype-pdf-${size.height.toInt()}.svg`):

| upstream | here | dimensions |
| --- | --- | --- |
| `-sm` | `-24` | 19×24 |
| `-md` | `-32` | 26×32 |
| `-lg` | `-40` | 32×40 |
| `-xl` | `-48` | 40×48 |

Sizes are uniform across kinds, so `filetype-pdf-lg.svg` →
`filetype-pdf-40.svg`, `filetype-audio-lg.svg` → `filetype-audio-40.svg`. The
glyphs are portrait — the width is *not* what the name encodes.

All nine kinds (`audio`, `code`, `compression`, `other`, `pdf`, `presentation`,
`spreadsheet`, `text`, `video`) must ship in all four sizes: a missing file is a
runtime asset failure, not a compile error, so keep the set complete.

When diffing these against upstream, **expect every file to differ even when
nothing changed** — each Figma re-export bumps the `clip0_…` element ids and
jitters path coordinates in the 4th decimal. Compare the rendered artwork, not
the bytes, and do not re-copy all 36 files just to absorb that noise.
