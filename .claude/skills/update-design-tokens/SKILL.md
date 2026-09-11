---
name: update-design-tokens
description: >
  Sync color design tokens from the GetStream/design-system-tokens repo into stream_core_flutter, and assess what
  an upstream token change means for this package. Use whenever a design-system-tokens PR or commit needs
  reviewing ("what does this token PR do to us?", "assess the impact of this change"), whenever a color value or
  a new semantic token has to land in `theme/primitives/internal/tokens/`, whenever a new `StreamColorScheme`
  field is being added or wired up, and whenever someone asks where a color comes from or why a token resolves
  the way it does. Covers tracing the blast radius into the consuming SDKs (stream-chat-flutter for chat tokens,
  stream-video-flutter for video), where the derived values actually live. Also use before hard-coding any `Color(0x...)` in this package — the answer is almost always a
  token or a colorScheme field instead.
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
---

# Updating design tokens

Colors in `stream_core_flutter` originate in
[GetStream/design-system-tokens](https://github.com/GetStream/design-system-tokens)
— the same repo the icons come from. This skill covers reading a change upstream
and landing it here.

Two things make this less mechanical than it sounds: **this package deliberately
vendors only a fraction of what upstream publishes**, and **the generated output
is sorted**, so a diff of it hides value changes in re-sort noise. Both are
covered below.

## What lives where

| | |
| --- | --- |
| source of truth | `tokens/{core,chat,video}/semantics/{light,dark}.json` upstream |
| upstream Flutter build | `build/flutter/tokens/lib/src/{android,ios,web}/{light,dark}/stream_tokens.dart` |
| colors vendored here | `lib/src/theme/primitives/internal/tokens/{light,dark}/stream_tokens.dart` |
| dimensions vendored here | `lib/src/theme/primitives/internal/tokens/stream_tokens_dimensions.dart` (one copy — mode-independent) |
| root semantics | `lib/src/theme/semantics/stream_color_scheme.dart` |
| derived values | each component's `build` / defaults, reading `colorScheme.*` |

The vendored files are **maintained by hand** — there is no sync command, and the
upstream build output is not copied in verbatim. Their readers are only the
primitive and semantic classes: `stream_colors.dart` and
`stream_color_scheme.dart` for the colors, and `stream_spacing.dart`,
`stream_radius.dart` and `stream_tokens_typography.dart` for the dimensions. No
component theme or widget ever references `StreamTokens` directly — a component
reads a `colorScheme` field or one of those classes.
(`stream_color_swatch_helper.dart` is *not* a reader: it generates shades in HCT
from a seed, and is measured against the vendored values rather than driven by
them.)

**Colors are byte-identical across the three upstream flavors, and so is every
dimension except font size.** iOS runs a size up at almost every step
(`typographyFontSizeMd` is 17 there against 16 on android and web), which is why
that one group is vendored per flavor while the rest is not. Read colors from any
flavor; read a font size from the flavor whose scale you are editing.

The font *family* does not arise: this package never sets one for text, and ships
no text font — only the generated `Stream Icons` face. Upstream's
`typographyFontFamilySans` is therefore not vendored.

Spacing, radius, line heights and font weights are identical across all three
flavors, so no flavor choice arises for them. They live in
`internal/tokens/stream_tokens_dimensions.dart`, one copy rather than one per
mode, read by `StreamSpacing`, `StreamRadius`, `StreamLineHeight` and
`StreamFontWeight`.

**Font sizes are the exception**: iOS runs a size up at almost every step, so
they mirror upstream's flavor split in
`internal/tokens/{android,ios}/stream_tokens_font_size.dart` and feed
`StreamFontSize.android` and `StreamFontSize.ios`. A size change has to be taken
from the matching flavor — `check:tokens` enforces that both declare the same
names, but it cannot tell you a value came from the wrong one.

Only core and chat semantics are vendored into `internal/tokens/`; the video
namespace is not. That is about *vendoring*, not about impact — a video token can
still be implemented by a core component here, and chat components live in this
repo outright. See [Downstream component defaults](#downstream-component-defaults).

## Reading an upstream change

Diff the **flattened source**, never the generated Dart/Kotlin/Swift. Upstream's
generator sorts keys, so adding one token re-sorts the file and a real value
change hides among hundreds of moved lines. This is not hypothetical — it is how
a live `accent/warning` change once reached review unnoticed.

```bash
# from a checkout of design-system-tokens
git fetch origin <pr-branch>
python3 <skill>/scripts/flatten_tokens.py --diff main FETCH_HEAD tokens/core/semantics/light.json
```

To catch up rather than review one PR, diff from the last synced commit — recorded
under **Last sync** in `references/derived-token-map.md`, and worth updating there
whenever you land a sync, since nothing in the repo itself records it:

```bash
python3 <skill>/scripts/flatten_tokens.py --diff <last-sync-sha> origin/main tokens/core/semantics/light.json
```

Run it for each namespace and mode the change touches (`core`/`chat` here,
`light` and `dark` both — they alias different primitives and can drift apart).
Output is `ADDED` / `REMOVED` / `CHANGED` per token path. Without `--diff` the
script just prints one revision as sorted `path = value` lines.

Values stay as authored (`{yellow.200}`, not the resolved hex) so that an alias
change reads differently from a raw-value change.

Then classify what you found:

- **`CHANGED` on a token this package vendors or maps** — the real work. Trace it
  to its `StreamColorScheme` field and to any component reading that field.
- **`ADDED`** — additive; adopt it only when a component actually needs it (see
  below).
- **`REMOVED` / renamed** — check whether the old name appears here at all before
  treating it as breaking, then check the SDK that owns the namespace, since a
  renamed derived token is often implemented there rather than here.

When assessing impact, distinguish a token **definition** from a **paint site**.
A grep for the field name will mostly hit the color scheme and generated
`.g.theme.dart` plumbing; what matters is whether a widget renders with it:

```bash
grep -rn "accentWarning" packages/stream_core_flutter/lib/src --include="*.dart" \
  | grep -v "theme/semantics/stream_color_scheme"
```

A change to a field nothing paints with is real API surface but no visual change
— say so plainly rather than reporting it as a regression.

## Downstream component defaults

A clean bill of health *here* does not mean no impact. Because this package
vendors only root semantics, upstream's derived tokens are implemented as
**component defaults in a consuming SDK** — so a derived-token change has no
counterpart in this repo at all and can only be assessed downstream.

The namespace does **not** tell you which repo to open. It tells you which SDK to
check *in addition to* this one:

| changed under | also check | why |
| --- | --- | --- |
| `tokens/core/**` | both SDKs | core is shared by everything |
| `tokens/chat/**` | stream-chat-flutter | but chat components live *here*, under `chat.dart`, so the work is usually in this repo |
| `tokens/video/**` | stream-video-flutter | video tokens can still land here — see below |

A `tokens/video/**` change reaching this repo is not hypothetical:
`control/call-control-error-badge/*` is a video token whose only implementation is
`StreamErrorBadge`, a core component that video merely wraps. Never conclude "video
namespace, not our problem" from the path alone.

### A token for an internal component

Upstream giving a component its own token is a signal that the component is part
of the design system's surface, so a themeable, public component is usually the
right shape — even where today's implementation is internal. Public components are
named with a `Stream` prefix.

**Ask before making one public.** Widening the public API is a maintenance
commitment the SDK carries until the next major version, and that is the owner's
call, not a detail to slip into a token sync. Implement the theme, note that the
widget it themes is internal, and put the question to them.

Which ref to inspect:

| repo | ref |
| --- | --- |
| stream-chat-flutter | `origin/master` |
| stream-video-flutter | `origin/v2` — the design-system work lives there, not on `main` |

Both are normally checked out as siblings of this repo; locate them rather than
assuming a path, and ask if neither is present. Prefer a local checkout over
GitHub code search, which indexes only default branches and would miss video
entirely.

### Finding the readers

For a **root semantic** (anything with a `StreamColorScheme` field), the mapping is
derivable — don't keep notes on it, generate it:

```bash
python3 <skill>/scripts/map_token_usage.py <repo> origin/v2 accentWarning
# accentWarning   connection_quality_indicator_defaults, connection_quality_indicator_theme
```

Omit the field name for the whole scheme (~28 lines for video). The script matches
both `colorScheme.x` and the `_colorScheme.x` used inside `_Defaults` classes, skips
tests, and inspects a ref directly so nothing needs checking out.

Two limits worth knowing, both by design:

- It reports where a field is **read**, one indirection from the widget that renders
  it — a component theme's defaults class shows up rather than the widget consuming
  that theme. Follow the theme field on to the widget when the answer needs to name
  a component.
- It cannot see **derived** tokens at all, because they have no field. Those are in
  `references/derived-token-map.md`, hand-traced, with the caveat that it points at
  repos which move independently — verify a row before acting on it.

And one that is not by design: the pattern matches the bare string `colorScheme.`,
so **Material's** `Theme.of(context).colorScheme.surface` is reported exactly like a
`StreamColorScheme` read. There are none in this repo, which uses
`StreamTheme.of(context).colorScheme`, but the consuming SDKs are Material apps
where the collision is real. Check the `Theme.of` receiver before reading a hit as
a Stream token — and read a *clean* result with the same suspicion, since app and
example directories are not filtered either.

When you do trace a derived token by hand, add the row. That is the only mapping
worth recording: the greppable half goes stale the moment someone edits a widget,
while the non-greppable half is what nobody can reconstruct without repeating your
work.

## Coordinating a change across repos

A token change that needs work in both this package and an SDK cannot be validated
in one branch: chat and video depend on `stream_core_flutter` **from pub**, so an
edit here is invisible to them until it is released. Wire them together with a git
dependency override, in this order:

1. Branch and push here first — the override resolves against the remote, so a
   local commit is not enough.
2. Take the pushed SHA (`git rev-parse HEAD`), branch in the consumer under the
   **same name** (see below), and point its `stream_core_flutter` at that SHA.
3. `melos bootstrap` in the consumer. Both halves are now buildable and reviewable
   together.

### Branch naming

The `ref:` is a SHA, so the branch name is not load-bearing for resolution — but
it is shared vocabulary across repos, and matching names are what let someone find
the other half of a change.

- **If core is already on a branch for this work, use that branch everywhere.**
  Reuse it rather than cutting a second one, and give the consumer's branch the same
  name.
- **Otherwise name the core branch `feat/update-tokens-{feature}`**, where
  `{feature}` is the main thing that changed in the tokens — the subject of the
  change, not a token path. The PR that added the on-elevation pair and restructured
  the indicators would be `feat/update-tokens-on-elevation`.

The override needs a `path:`, because this package is not at the repo root:

```yaml
dependency_overrides:
  stream_core_flutter:
    git:
      url: https://github.com/GetStream/stream-core-flutter.git
      ref: dbf84703ceb4dc19a7c847707428e8727d867203 # a commit, never a branch
      path: packages/stream_core_flutter
```

**Where that block goes differs per consumer**, and getting it wrong looks like the
override being silently ignored:

| consumer | resolution | put `dependency_overrides` in |
| --- | --- | --- |
| stream-video-flutter | pub workspace (`resolution: workspace`) | the **root** `pubspec.yaml` — it already has an overrides block |
| stream-chat-flutter | melos, no pub workspace | the **consuming package's** pubspec, `packages/stream_chat_flutter/pubspec.yaml` |

**The override is expected to merge — do not treat it as something to strip before
the consumer's PR lands.** This package is not released on every change, so gating
each consumer PR on a core release would stall them. The override lives on the
consumer's default branch and comes off only when that SDK is released: at that
point this package is released too, and the dependency goes back to a published
version constraint.

**Always pin a commit SHA, never a branch name.** A branch ref resolves to
whatever the tip happens to be at `pub get` time and writes that SHA into
`pubspec.lock`, so the locked version drifts unpredictably as the branch moves and
two checkouts of the same consumer commit can resolve differently. A SHA is stable
and survives the branch being rebased or deleted.

**Repoint only the package your change touches.** `stream_core` and
`stream_core_flutter` come from this repo but are separate git dependencies with
separate pins, and a consumer is often pinned to an older core than `main`.
Dragging `stream_core` forward for a change that only touches
`stream_core_flutter` pulls in unrelated churn — the error layer, for one.

Distinct from the sibling-path override this repo's CI guidance warns about — a git
ref is reproducible off-machine, where a `path:` to a sibling checkout is not. Do
not reach for a path override to make a cross-repo change build.

## Naming

Upstream's generator flattens `group/subgroup/name` into camelCase. The
`StreamColorScheme` field then **drops the `core` / `utility` group segment**,
because Flutter has no such layer:

```
upstream token            vendored constant        colorScheme field
border/utility/selected   borderUtilitySelected    borderSelected
background/core/highlight backgroundCoreHighlight  backgroundHighlight
```

Some fields also shorten further where the upstream suffix carried no meaning
here (`background/core/surface-default` → `backgroundSurface`). Match the
existing neighbors in `stream_color_scheme.dart` rather than deriving the name
mechanically.

## Wiring a field default

Look at what the token aliases upstream. The answer decides whether a vendored
constant is needed at all — and getting it wrong is how a custom brand color
silently stops applying:

- **`{chrome.*}` or `{brand.*}`** → resolve through the generated swatch:
  `chrome.shade100`, `brand.shade500`, `chrome[0] ?? StreamColors.white`.
  Never the baked hex. These scales are regenerated from a seed color, so a
  hard-coded value ignores `StreamColorScheme.light(brand: ...)`.
- **another semantic** → alias the field: `borderWarning ??= accentWarning`.
  Check both modes before generalising — `textLink` aliases `accentPrimary` in
  light but resolves `brand.shade600` in dark, so the two factories can differ.
- **a raw hex, or a primitive outside those two scales** (a `yellow`, a
  transparent black) → add a constant to both vendored files and read it:
  `light_tokens.StreamTokens.backgroundCoreHighlight`.

Only the third case earns a vendored constant. Add the same name to **both**
`light/` and `dark/`, keeping the file's existing ordering.

### Writing the dartdoc

The field's dartdoc comes from the token's own `$description`, which upstream
carries alongside `$value` in the semantics JSON:

```bash
python3 -c "import json;d=json.load(open('tokens/core/semantics/light.json'));\
print(d['border']['core']['on-elevation'])"
```

Quote it rather than inventing prose — it is the designer's statement of intent,
and matching wording is what lets the next person recognize the field as that
token. Swap upstream's token paths for `[fieldName]` references.

**Read the claim against the resolved light and dark values first**, and note
what it is *not* saying. A description usually tracks the token's own light→dark
progression, not a comparison with the sibling it names: `border/core/on-elevation`
"steps up in dark mode" because it goes `{chrome.150}` → `{chrome.300}` as the
elevated surface lightens — while in that same mode it lands on `{chrome.300}`,
exactly `border/core/on-surface`, the token it tells you to use instead. Both
halves are true and they are easy to read as contradictory. Resolve the aliases
before deciding a description is wrong, and add the nuance the description omits
rather than replacing wording that is accurate.

## Root semantics only

Upstream also publishes derived semantics — `badge/*`, `button/*`, `avatar/*`.
**Do not vendor or map those.** They are re-derived in Dart from the root
semantics, at the component's defaults:

```dart
// lib/src/components/badge/stream_badge_notification.dart
Color get errorBackgroundColor => _colorScheme.accentError;
```

So upstream `badge/bg-error` has no counterpart here, by design — a component
theme reads `colorScheme.accentError` instead. This keeps the token surface small
and keeps every component overridable through one seedable color scheme.

**Add a constant only when a field will read it**, and add it to both `light/` and
`dark/`. An unread constant is not harmless: it reads as an invitation to paint a
component from a token, which is the one thing a component must not do — a
constant bypasses the seedable color scheme, so a custom brand or chrome stops
applying.

Spacing, radius and line heights live in `stream_tokens_dimensions.dart` instead
— one mode-independent file, read by `StreamSpacing`, `StreamRadius` and
`StreamLineHeight`. Edit the value there and the classes follow; do not
re-introduce a literal in a class, which is the same hazard as baking a hex where
a swatch belongs, one layer up.

One upstream dimension is deliberately absent: **`radiusNone`**, since the
analyzer's `use_named_constants` prefers `Radius.zero` over `circular(0)`. The
font family is not carried either — this package never sets one for text, only
for the emoji and icon fonts. Weights are carried as `FontWeight` rather than the
raw 400/500/600/700, for the same reason the rest are `double`: it is the type
Flutter consumes, and `FontWeight` has no public constructor from a number.

**`melos run check:tokens` enforces all of this.** It fails when a constant in
`internal/tokens/` is never referenced, and when `light/` and `dark/` disagree
about which constants exist — the second because a field resolving from a constant
in one mode but not the other falls back silently rather than failing. So there is
no judgment call about what belongs: add a constant when a field or class will
read it, and CI tells you if you got it wrong.

Run it after any token edit, alongside `analyze`. Its allowlist is empty and worth
keeping that way; an entry there is a token the SDK carries without using.

## After editing

```bash
melos run analyze
melos run check:tokens
melos run test:flutter
```

Regenerate only if you touched a `.theme.dart` annotation (adding a color-scheme
field does): `melos run generate:flutter`. A new field also needs wiring into the
gallery's Theme Studio (`apps/design_system_gallery/lib/config/theme_configuration.dart`
and `widgets/theme_studio/theme_customization_panel.dart`) — follow the
surrounding fields.

### Goldens

Goldens only move if a component actually paints with the changed color. The
palette golden (`test/theme/goldens/ci/stream_theme_color_generation.png`) covers
seed-generated brand/chrome ladders, not semantic accents, so a semantic value
change usually leaves it alone.

**Expect every macOS-variant golden to fail locally, change or no change.** Only
the `ci/` images are committed — there are no `macos/` ones in the repo at all —
so on a Mac those tests have nothing to compare against. That is the noise you
will see, not evidence your change broke something, and the local failure count
tends to match the number of committed goldens exactly. When in doubt, prove it:
revert your edit, re-run the same test, and watch it fail identically.

**Regenerate the `ci/` images on CI, not on your machine.** The workflow runs on
ubuntu, which is what makes them match CI in the first place:

```bash
gh workflow run update_goldens.yml --ref <your-branch>
gh run list --workflow=update_goldens.yml --limit 1   # then: gh run watch <id>
git pull                                              # picks up "chore: Update Goldens"
```

It bootstraps the workspace, runs `melos run update:goldens`, and commits every
changed PNG back to the branch you dispatched, as the Stream SDK Bot. Dispatching
it is also the cheapest way to *see* what a color change did — the bot's diff is a
before/after of every affected component, which is worth attaching to the PR when
the change is a value move rather than a new token.

Two caveats. The regeneration step is `continue-on-error`, so a green run does not
mean the goldens rebuilt cleanly — read the bot's commit and check the images moved
the way you expected, and that nothing you did not touch moved with them. And it
commits to whatever ref you dispatch, so pass your own branch.

**Run it on the consuming SDKs too.** stream-chat-flutter and
stream-video-flutter each have the same `update_goldens.yml`, and a value change
moves their goldens as surely as it moves this package's — a component they own
paints with the field. Their CI fails on the `variant: CI` goldens, which is the
signal, and dispatching the workflow on the consumer's branch is the fix:

```bash
gh workflow run update_goldens.yml --repo GetStream/stream-video-flutter --ref <branch>
```

Do it once the consumer's override points at your core commit, so the images it
renders are the ones the change actually produces. Expect this on any value
change: the call control badge going red to yellow moved
`call_control_button` and `call_feature_button`, neither of which is in this repo.

## Changelog

`StreamColorScheme` is exported from `core.dart`, so **every one of its fields is
public API**. A token whose *value* changes is a visual change for anyone reading
the field instead of overriding it, and needs a `### 🔄 Changed` CHANGELOG entry
under `## Upcoming` even though no signature moved.

**A line or two.** Name the old and new resolved values, since that is what a
consumer diffing screenshots needs, and say if the new value constrains what can
sit on it. Everything else — why upstream changed it, contrast ratios, which
component made it visible — belongs in the PR.

A field that is removed or renamed follows the deprecation policy in
`STYLE_GUIDE.md` (annotate, `### 🛑 Breaking / Removals`, and a `fix_data.yaml`
transform).

## Contrast is not automatic

Token aliases carry no contrast guarantee, and upstream can move a value across
the light/dark divide — a warning color going from orange to a pale yellow flips
which text color is legible on it. When adopting a changed fill, check what text
or icon token is painted on top of it, and say so if the pairing no longer works.
`accent/*` values have no `on-*` counterpart in the core namespace, so this has to
be reasoned about rather than looked up.
