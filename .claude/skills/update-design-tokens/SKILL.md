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
| vendored here | `packages/stream_core_flutter/lib/src/theme/primitives/internal/tokens/{light,dark}/stream_tokens.dart` |
| root semantics | `lib/src/theme/semantics/stream_color_scheme.dart` |
| derived values | each component's `build` / defaults, reading `colorScheme.*` |

The vendored files are **maintained by hand** — there is no sync command, and the
upstream build output is not copied in verbatim. Only
`stream_color_scheme.dart`, `stream_colors.dart` and
`stream_color_swatch_helper.dart` import them; no component theme or widget ever
references `StreamTokens`.

Colors are byte-identical across the three upstream platform flavours (only
typography differs), so when you do read the upstream build, the flavour is
irrelevant — pick any. Typography, spacing and radius are **not** synced at all:
`stream_tokens_typography.dart` composes `TextStyle`s on a single `Geist` family,
and `stream_spacing.dart` / `stream_radius.dart` declare their own scales.

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
      ref: 2762ea870b3f38bdfb33280230d0709540bde35a # a commit, never a branch
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
upstream token          vendored constant         colorScheme field
border/utility/warning  borderUtilityWarning      borderWarning
background/core/on-accent  backgroundCoreOnAccent  backgroundOnAccent
```

Some fields also shorten further where the upstream suffix carried no meaning
here (`background/core/surface-default` → `backgroundSurface`). Match the
existing neighbours in `stream_color_scheme.dart` rather than deriving the name
mechanically.

## Wiring a field default

Look at what the token aliases upstream. The answer decides whether a vendored
constant is needed at all — and getting it wrong is how a custom brand color
silently stops applying:

- **`{chrome.*}` or `{brand.*}`** → resolve through the generated swatch:
  `chrome.shade100`, `brand.shade500`, `chrome[0] ?? StreamColors.white`.
  Never the baked hex. These scales are regenerated from a seed color, so a
  hard-coded value ignores `StreamColorScheme.light(brand: ...)`.
- **another semantic** → alias the field: `borderWarning ??= accentWarning`,
  `textLink ??= accentPrimary`.
- **a raw hex, or a primitive outside those two scales** (a `yellow`, a
  transparent black) → add a constant to both vendored files and read it:
  `light_tokens.StreamTokens.backgroundCoreHighlight`.

Only the third case earns a vendored constant. Add the same name to **both**
`light/` and `dark/`, keeping the file's existing ordering.

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

The vendored files still carry a historical full dump of ~500 constants, of which
roughly a third are read. Treat the unread ones as dead weight: don't add more,
and don't take their presence as precedent.

## After editing

```bash
melos run analyze
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

## Changelog

`StreamColorScheme` is exported from `core.dart`, so **every one of its fields is
public API**. A token whose *value* changes is a visual change for anyone reading
the field instead of overriding it, and needs a `### 🔄 Changed` CHANGELOG entry
under `## Upcoming` even though no signature moved. Name the old and new resolved
values — that is what a consumer diffing screenshots needs.

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
