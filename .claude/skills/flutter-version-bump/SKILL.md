---
name: flutter-version-bump
description: >
  Adopt a new Flutter stable release in this monorepo — diagnose and fix the analyze, format, golden, and barrel
  failures a new toolchain introduces, then raise the published minimum Flutter/Dart floor to the SDK's
  "latest stable − 1" policy. Use when CI suddenly goes red after a Flutter release, when
  `dart analyze --fatal-infos` reports diagnostics that did not exist before, when goldens drift after upgrading,
  or when asked to "support Flutter X" or "bump the min Flutter version".
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
---

# flutter-version-bump

Two different jobs share the phrase "bump Flutter". Decide which one you are doing **before** touching a file —
they produce different diffs, different review burdens, and only one of them changes what consumers can resolve.

| Track | Goal | Scope | Consumer impact |
|---|---|---|---|
| **A — Compat** (first) | Make CI green on the new stable | Source fixes, lint config, goldens | None |
| **B — Floor raise** (policy-driven) | Move the minimum to latest − 1 | 6 pubspecs + `melos.yaml` + `legacy_version_analyze.yml` + CHANGELOGs + newly-activated lints | Apps below the floor stop resolving |

A floor raise is **not** a breaking change: no `!` in the commit/PR title, and the CHANGELOG bullet does not go
under `### 🛑 Breaking / Removals`. Existing code keeps compiling; older SDKs simply stop resolving the new
version. Do not invent a `!` for it.

**Do Track A first, always.** "CI broke after the new Flutter came out" is Track A, and it must land green before
Track B starts — otherwise you cannot tell a floor-raise failure from a new-stable failure.

**Then check whether Track B is due.** The SDK's policy is **minimum supported = latest stable − 1**, so a new
stable makes the floor raise *routine, not exceptional*: when 3.47 shipped, the floor moved 3.38 → **3.44**. Pair
each Flutter minor with its Dart SDK (3.44 → Dart 3.12, 3.47 → Dart 3.13); `fvm releases` lists both, and the
authoritative list is
`https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json` (`fvm`'s cache goes stale).

Track B belongs in a minor/major release rather than a hotfix, and must be its own commit — its diff has nothing
to do with the compat fixes.

Only **two** version knobs move on a floor raise here, and they are both the *floor*, never the new stable:

| Knob | Value |
|---|---|
| `melos.yaml` `command.bootstrap.environment` | the new floor — source of truth, `melos bs` propagates to every pubspec |
| `.github/workflows/legacy_version_analyze.yml` `env.flutter_version` | the new floor — this job *is* the floor's regression test |

> The repo has **no `.fvmrc`** — local Flutter selection is not pinned here. Do not create one as a side effect of
> a version bump; that is its own decision. It does mean nothing forces a developer's local toolchain to be the
> floor, so newer-than-floor API usage is caught only by `legacy_version_analyze`, which analyzes
> **`stream_core/lib` only** (see below). Analyse against the floor by hand.

## Why CI breaks the day a Flutter stable ships

`.github/workflows/stream_core_flutter_workflow.yml` installs Flutter with

```yaml
channel: ${{ env.FLUTTER_CHANNEL }}   # stable — no version pin
```

so both jobs (`analyze` and `test`) **auto-adopt the new stable within hours of release**.
`legacy_version_analyze.yml` (the N-1 canary) pins a version and does *not* follow. So the first symptom is always
"CI went red and nobody changed anything", while a local machine on an older SDK still passes.

`melos run analyze` runs `dart analyze --fatal-infos` (examples excluded). New SDKs ship new diagnostics as
**infos and warnings**, which `--fatal-infos` turns into hard failures. That is why an SDK bump hurts here more
than in a typical repo.

### Check the canary first — it usually already told you

`beta_version_analyze.yml` runs the `package_analysis` action against the **beta** channel every Monday and Slacks
on failure. Beta becomes stable roughly a quarter later, so this workflow reports the next release's analyzer
failures *months* early. Before investigating anything, read its history:

```bash
gh run list --workflow=beta_version_analyze.yml --limit 10
gh run view <id> --log-failed | grep -E "warning -|info -|error"
```

Two traps when reading it, both because `.github/actions/package_analysis/action.yml` is a **one-package action**:

```bash
cd packages/stream_core/lib && dart analyze --fatal-warnings . && cd .. && flutter test --exclude-tags golden
```

- **It only covers `stream_core`.** `stream_core_flutter`, `stream_thumbnail` and the gallery are never analysed
  by the canary or by `legacy_version_analyze`. A green canary says nothing about the Flutter packages.
- **It is `--fatal-warnings`, not `--fatal-infos`,** and `lib/` only. New *infos* — the bulk of what a new SDK
  ships — pass the canary and fail `melos run analyze`.

If the canary has been red and unactioned for weeks, that is the most valuable finding in the exercise — report it
separately from the code fixes.

## Step 1 — Branch off main

Never branch a toolchain bump off a feature branch. Bootstrap rewrites lockfiles repo-wide.

```bash
git fetch origin
git checkout -b chore/flutter-<version> origin/main
```

## Step 2 — Install the new SDK side by side

Keep the old one. Every claim below is an A/B comparison, and you cannot make one with a single toolchain.

```bash
fvm install <new>                       # e.g. 3.47.0
fvm list                                # confirm old + new are both cached
NEW=~/fvm/versions/<new>
OLD=~/fvm/versions/<current floor, from melos.yaml>
```

On a floor raise you want **three**: the old floor, the new floor (must analyse clean — it is what
`legacy_version_analyze` will run) and the latest stable (what CI's `analyze` job actually resolves to).

## Step 3 — Measure before you fix

The single most important habit: **never attribute a failure to the new SDK without seeing the old SDK pass it.**
Repos accumulate drift; a feature branch may already be dirty; a local `build/` directory can inject hundreds of
phantom issues. Run each check under both toolchains and diff.

### Format

CI runs `melos run format:verify` → `dart format --set-exit-if-changed .` from the root, which walks untracked
trees too. Scope to tracked files so `build/` noise cannot pollute the comparison:

```bash
git ls-files '*.dart' > /tmp/dartfiles.txt
for V in $OLD $NEW; do
  echo "== $V"
  $V/bin/cache/dart-sdk/bin/dart format --output=none --set-exit-if-changed $(cat /tmp/dartfiles.txt) 2>&1 | tail -3
done
```

The root `analysis_options.yaml` sets `page_width: 120` and `trailing_commas: preserve`; `dart format` reads it
from the file nearest the target, so always format from the repo root, never from inside a package with its own
options file.

Interpretation:

- **Both 0 changed** → the formatter did not change. Do not touch formatting in this PR.
- **New > 0, old = 0** → `dart_style` changed. Apply it as an **isolated commit** touching nothing else, so the
  real fixes stay reviewable.
- **Old > 0, new = 0** → the repo is already formatted for a newer formatter than the floor. Pre-existing drift,
  harmless. Not yours to fix here — but mention it.

### Analyze

> **Run `melos bootstrap` first, and re-run it after every pubspec edit.** `dart analyze` reads the *language
> version* from `.dart_tool/package_config.json`, written by `pub get` — **not** from `pubspec.yaml`. A stale
> `.dart_tool` reports a confidently clean result that CI will not reproduce, and editing an SDK constraint
> without re-bootstrapping changes nothing at all. Verify with:
>
> ```bash
> python3 -c "import json;d=json.load(open('packages/stream_core_flutter/.dart_tool/package_config.json'));\
> print([p.get('languageVersion') for p in d['packages'] if p['name']=='stream_core_flutter'])"
> ```
>
> Despite the root `pubspec.yaml` being named `stream_core_flutter_workspace`, this is **not** a pub workspace —
> no package declares `resolution: workspace`. Melos bootstraps each package separately, so every package has its
> own `.dart_tool/package_config.json` and you must check the one you care about.

Mirror `melos run analyze` (`--fatal-infos`, examples excluded) and **filter local build artifacts**, which are
not in CI and will otherwise bury the real signal:

```bash
set -o pipefail   # otherwise a matching grep masks an analyzer that crashed
for V in $OLD $NEW; do
  echo "##### $V"
  for p in packages/stream_core packages/stream_core_flutter packages/stream_thumbnail apps/design_system_gallery; do
    echo "### $p"
    # `|| true` so a package with no diagnostics is not reported as a failure
    (cd "$p" && $V/bin/cache/dart-sdk/bin/dart analyze --fatal-infos . 2>&1 \
      | { grep -E "^\s+(info|warning|error)" | grep -v " build/" || true; })
  done
done
```

Everything present under `$NEW` and absent under `$OLD` is your work list. Everything in both is pre-existing —
leave it alone and say so.

### Tests and goldens — `GITHUB_ACTIONS=true` is mandatory

`packages/stream_core_flutter/test/flutter_test_config.dart` switches alchemist on **`GITHUB_ACTIONS` only** —
not the more common `CI`. Setting `CI=true` looks right and silently runs the *platform* variant instead:

```dart
final isRunningInCi = Platform.environment.containsKey('GITHUB_ACTIONS');
ciGoldensConfig: CiGoldensConfig(enabled: isRunningInCi),
platformGoldensConfig: PlatformGoldensConfig(enabled: !isRunningInCi),
```

**Only `goldens/ci/` is committed** (47 files). A bare `flutter test` on your machine runs the platform variant,
whose goldens do not exist in the repo, and fails every golden test for reasons that have nothing to do with the
new SDK. Always:

```bash
for V in $OLD $NEW; do
  (cd packages/stream_core_flutter && GITHUB_ACTIONS=true $V/bin/flutter test --reporter=compact > /tmp/t-$(basename $V).log 2>&1)
done
# compare the failure sets, not the counts — `\r` matters, the compact reporter uses it
for V in $OLD $NEW; do
  tr '\r' '\n' < /tmp/t-$(basename $V).log | grep -E '\[E\]$' | sed 's|.*/test/|test/|' | sort -u \
    > /tmp/fail-$(basename $V).txt
done
comm -13 /tmp/fail-$(basename $OLD).txt /tmp/fail-$(basename $NEW).txt   # caused by the new SDK
comm -12 /tmp/fail-$(basename $OLD).txt /tmp/fail-$(basename $NEW).txt   # pre-existing, out of scope
```

Repeat for `packages/stream_core` (pure Dart, no goldens).

Committed goldens are Linux-rendered, so some fail on macOS even on the old SDK. That baseline noise is exactly
what `comm` separates out. **Only the lines the new SDK adds are yours.**

> **Never run `git checkout -- .` between runs.** Alchemist only writes untracked `failures/*.png` directories,
> so there is nothing to revert — and a blanket checkout silently destroys the source fixes you just made. Clean
> up with `git clean -fd -- '*/failures'` instead, and keep `git status --short` in view.

### Barrels

`melos run check:barrels` gates the PR alongside analyze. It is not toolchain-sensitive on its own, but a fix
that moves or adds a file under `packages/stream_core_flutter/lib/src/` breaks it. Run it in the same breath as
analyze.

## Step 4 — Fix, by failure class

Work the diff from Step 3. Known classes and this repo's chosen remedy:

### New analyzer diagnostics (the usual bulk)

New SDKs add diagnostics that `--fatal-infos` promotes to failures. Treat each as a real finding first — most of
them point at a genuine latent bug — and only suppress when the diagnostic is wrong about this code.

| Remedy | When |
|---|---|
| Fix the code | Default. The diagnostic is usually right. |
| `// ignore: <name>` with a one-line reason above it | The diagnostic is correct in general but wrong here, or the fix belongs to an upstream package. Never a bare ignore — see `STYLE_GUIDE.md`. |
| Flip the rule to `false` in `analysis_options.yaml`, or delete it from `all_lint_rules.yaml` | The lint was **removed or renamed** by the SDK. An unrecognized rule name is itself a warning. |

The lint config here is inverted relative to most repos: `all_lint_rules.yaml` is an **explicit list of every
rule**, included wholesale, and `analysis_options.yaml` then switches individual rules back to `false` with a
comment saying why. Two consequences:

- **A new SDK's new rules do not activate on their own.** The list is static, so adopting them means adding the
  names to `all_lint_rules.yaml` — a code-style decision with its own before/after numbers, and **always its own
  PR**, never this one.
- **A removed or renamed rule fires `undefined_lint` in `all_lint_rules.yaml`, not in `analysis_options.yaml`.**
  Delete it there; if `analysis_options.yaml` also disables it, delete that line too or it becomes the next
  `undefined_lint`.

To find removed/renamed/deprecated lints mechanically rather than by guessing, analyse the options files
themselves — `melos run analyze` never does, because both sit at the repo **root**, outside every melos package:

```bash
for V in $OLD $NEW; do
  echo "== $V"; $V/bin/cache/dart-sdk/bin/dart analyze --fatal-infos analysis_options.yaml all_lint_rules.yaml
done
```

`undefined_lint` means the rule was removed or renamed — a hard failure once the root is analysed.
`deprecated_lint` means it still parses but is on its way out — cheaper to drop now than to discover as
`undefined_lint` two releases later. Run it under both toolchains: a `deprecated_lint` that also fires on the old
SDK is pre-existing debt, not something this release introduced.

### Framework deprecations

New `deprecated_member_use` infos are fatal here. Prefer migrating to the replacement API. If the replacement does
not exist on the floor in `melos.yaml`, you cannot use it — suppress with a scoped ignore naming the reason, and
leave the migration for the release that raises the floor.

### New runtime assertions

Flutter adds asserts that only fire in tests, so they surface as widget-test failures, not analyzer output. Read
the assertion and fix the widget tree; do not silence the test.

### Golden pixel drift

Small diffs (well under 1%) across unrelated widgets mean the engine's rasterisation changed — legitimate, and the
goldens must be regenerated. Larger diffs confined to one widget family usually mean a real layout change;
investigate before regenerating. **On a Track B floor raise, goldens should not move at all** — CI still runs the
latest stable either way. If they do, that is a signal to investigate, not to regenerate.

**Goldens are always regenerated by the CI workflow — never locally. No exceptions.**

`melos run update:goldens` writes the *platform* variant on your machine; the committed `goldens/ci/*.png` are
Linux-rendered. Regenerating locally therefore produces macOS pixels the repo does not even track. Locally you may
**compare** (`GITHUB_ACTIONS=true flutter test`) to see which goldens moved — never write them.

`update_goldens.yml` checks out with `secrets.BOT_SSH_PRIVATE_KEY` and commits `**/test/**/goldens/*.png` back to
whatever branch you dispatch against, so **push the branch first**. It has no inputs — it always regenerates
everything, on `ubuntu-latest`, with `flutter-version: "3.x"` (the new stable, automatically).

> **Confirm with the user before running this.** It pushes a branch and dispatches a workflow that writes a commit
> to the remote. It is the one outward-facing action in this skill — never dispatch it unprompted, and expect the
> branch to stay red on goldens until it has run.

```bash
git push -u origin chore/flutter-<version>
gh workflow run update_goldens.yml --ref chore/flutter-<version>
gh run watch $(gh run list --workflow=update_goldens.yml --limit 1 --json databaseId --jq '.[0].databaseId')
git pull    # pick up the bot's "chore: Update Goldens" commit
```

Two consequences to state plainly when you report:

- **The branch is not verifiable-green on macOS.** Even after regeneration, a local `GITHUB_ACTIONS=true` run
  still shows the pre-existing Linux-vs-macOS baseline diffs from Step 3. Give the reviewer that number so a
  non-zero local failure count is not read as "the fix did not work".
- `legacy_version_analyze.yml` never runs golden tests, so regenerating against the new stable cannot break the
  N-1 canary.

### Files the toolchain rewrites underneath you

`melos bootstrap` and `flutter pub get` both edit tracked files. Anything they rewrite that you do not commit
fails the **format** job, since `melos run format:verify` runs after bootstrap in CI.

- **`pubspec.lock`** — the workspace has a single root lock. Commit it.
- **`analyzer.exclude` blocks injected into an app-type `analysis_options.yaml`** — Flutter 3.47's `pub get`
  writes `build/`, `android/`, `ios/`, … exclusions into packages that have a `flutter:` SDK dep *and* platform
  directories (here: `apps/design_system_gallery`, `packages/stream_thumbnail/example`). It is tool-authored
  config, not ours. **Surface it, do not decide it yourself** — and note that `pub get` *merges* its full list
  into any existing `exclude:`, so a hand-trimmed version is not a stable fixed point.
- **`test_api: any` / `flutter_test: any` appended to `dev_dependencies`** — melos injects these around bootstrap
  and normally strips them again. **Never commit them**: `flutter_test` has no pub.dev version, so committing it
  makes the next `melos bootstrap` fail version solving outright.

There are **no Android/iOS build jobs** in this repo's CI — nothing compiles the gallery or the thumbnail example
for a device. So Gradle/AGP/Kotlin/Xcode floors never gate a PR here, and a new Flutter's raised build-tool floors
are invisible until someone builds locally. Say that rather than implying the platform projects are verified.

## Step 5 — Verify like CI does

```bash
melos bootstrap
melos run analyze
melos run check:barrels
melos run format:verify
GITHUB_ACTIONS=true melos run test:all
git status --short          # expect only your intended edits
git clean -fdn -- '*/failures'   # review, then drop -n to remove alchemist's diff images
```

Two things will still look wrong locally and are not:

- `melos run analyze` surfaces `build/` noise if you have ever built the gallery. Compare against Step 3's
  baseline instead of expecting a clean zero.
- `GITHUB_ACTIONS=true melos run test:all` still fails the pre-existing Linux-vs-macOS goldens. Compare failure
  **sets**, not counts.

Also re-check the floor, since `legacy_version_analyze.yml` gates the PR — and remember it covers `stream_core`
only, so extend it by hand to the packages it misses:

```bash
for p in packages/*/; do (cd "$p/lib" && $FLOOR/bin/cache/dart-sdk/bin/dart analyze --fatal-infos .); done
```

A fix that relies on syntax newer than the floor passes on `$NEW` and fails that job.

## Step 6 — Track B: raise the floor to latest − 1

Keep this out of the Track A commit — it changes what consumers can resolve and needs to be reviewable on its own.

Version-carrying files, all of which must move together. **Derive the list by grep, do not trust this one** — it
is accurate as of the 3.44 raise:

```bash
git ls-files '*pubspec.yaml' | xargs grep -ln 'sdk: \^3\.'
```

- `melos.yaml` — `command.bootstrap.environment.{sdk,flutter}` (the source of truth; `melos bs` propagates)
- `pubspec.yaml` (root workspace) — `environment.sdk` only; the root carries no `flutter` constraint
- `packages/stream_core/pubspec.yaml` — `sdk` only. It is **pure Dart and carries no `flutter` constraint — do
  not add one.**
- `packages/stream_core_flutter/pubspec.yaml` — `sdk` + `flutter`
- `packages/stream_thumbnail/pubspec.yaml` and `packages/stream_thumbnail/example/pubspec.yaml`
- `apps/design_system_gallery/pubspec.yaml`
- `.github/workflows/legacy_version_analyze.yml` — `env.flutter_version`. Set it to the **new floor** (never the
  new stable): this job exists to prove the floor still analyses clean. Note the existing value may be a *patch*
  of the floor (`3.38.10` for a `>=3.38.1` floor) — pick one convention, say which in the commit message.

Confirm melos actually propagated rather than assuming it:

```bash
melos bootstrap && git diff --stat -- '*pubspec.yaml'
```

Melos only rewrites keys that already exist, so a pubspec missing a `flutter:` key stays missing one — which is
what you want for `stream_core`, and what you must fix by hand anywhere it is wrong.

### The floor raise activates dormant lints — budget for it

This is the step that surprises people. Raising the Dart constraint raises each package's **language version**,
and lints stay silent while their suggested fix is not yet expressible. Raise the floor and they all fire at once,
in code nobody touched.

Concretely, the Dart 3.10 → 3.12 raise activated `prefer_initializing_formals` on 24 sites across
`stream_core`, `stream_core_flutter` and the gallery, because Dart 3.12 legalised `this._privateField` as a named
parameter. Zero issues before, 24 after — none of it caused by the new *stable*, all of it caused by the *floor*.

So: **`melos bootstrap` and re-analyse immediately after editing the constraints**, before you write the
CHANGELOG. Then let the tooling do the mechanical work:

```bash
for p in packages/*/ apps/design_system_gallery; do (cd $p && dart fix --dry-run); done
# then, per lint, once you have decided the fix is right:
(cd <pkg> && dart fix --apply --code=prefer_initializing_formals)
```

Two things to check by hand afterwards — `dart fix` is mechanical, not thoughtful:

- **Doc comments get mangled *and silently deleted*.** It rewrites `[logger]` to `[_logger]` in the doc above the
  constructor — leaking a private name into public API docs, when callers still pass the *public* name
  (`logger:`, underscore stripped). It also drops any `///` comment attached to the parameter it rewrites. Review
  every comment line the refactor touched, in both directions:

  ```bash
  git diff -- '*.dart' | grep -E "^[-+]\s*(///|//)"
  ```

  Checking only added lines misses the deletions — that is how a lost doc comment survives review.
- **Confirm no public parameter was renamed.** For every `this._foo` it introduced, the parameter it replaced must
  have been named exactly `foo`. A mismatch is a silent breaking change for callers — and in this repo a public
  widget or theme constructor is API that downstream SDKs (`stream-chat-flutter`, `stream-video-flutter`) depend
  on.

This repo generates heavily (`json_serializable`, `theme_extensions_builder`). Re-run `melos run generate:all`
afterwards and confirm the generated call sites are unchanged — the generators read constructor parameters, so a
renamed parameter would silently change `.g.dart` / `.g.theme.dart`.

**Always `dart format` after build_runner.** Generated files carry a `// dart format width=80` marker and are
emitted at 80 columns while the repo's `analysis_options.yaml` sets `page_width: 120`, so a regen can dirty
generated files with pure reflow. Format before concluding codegen "changed" anything. Note the root analyzer
`exclude` covers `packages/*/lib/**/*.*.dart`, so generated files are not analysed — but they *are* formatted.

Then, per `STYLE_GUIDE.md`, one short bullet under `## Upcoming` in each published package's CHANGELOG:

```md
- Raised minimum Flutter to `>=X.Y.Z` and Dart SDK to `^A.B.C`.
```

`stream_core` is Dart-only — its bullet mentions the Dart SDK only. `apps/design_system_gallery` is not published
and has no CHANGELOG. The style guide's heading list (`### ✨ Features`, `### 🐛 Bug Fixes`,
`### 🛑 Breaking / Removals`, `### ⚠️ Deprecations`) has no "changed" bucket; a floor raise is **not** breaking, so
use `### 🔄 Changed` and update `STYLE_GUIDE.md` if you introduce it.

Two CI gates read the CHANGELOG and will bite:

- `semantic_changelog_update` in `pr_title.yml` maps scopes `llc`/`ui`/`thumb` to packages. A `chore(repo):` PR is
  outside that map, so it is not *required* to touch a changelog — but if you do touch one, `changelog_placement`
  requires the entries to be under `## Upcoming`, not under an already-published version heading.
- A package that was just released may have **no `## Upcoming` section at all**. Add one at the top rather than
  filing the bullet under the released version — that is precisely what `changelog_placement` fails on.

Finish with `melos bootstrap` and commit the resulting root `pubspec.lock`.

## Step 7 — Changelog and PR

Track A changes that are user-visible (a widget swapped, a deprecation migrated) get a CHANGELOG bullet in the
affected package. Pure CI/tooling/golden churn does not.

PR title follows Conventional Commits with a **required scope** from `llc` / `ui` / `repo` / `thumb`
(`pr_title.yml` enforces it):

- Track A → `chore(repo): support Flutter <version>`
- Track B → `chore(repo): bump min Flutter to <version> and Dart SDK to <version>`

## Report back with attribution

When summarising, always separate the three buckets — it is the difference between a reviewable PR and a mystery:

1. **Caused by the new SDK** (present on new, absent on old) — what this PR fixes.
2. **Pre-existing** (present on both) — explicitly out of scope, named so nobody re-investigates.
3. **Local-only noise** (`build/` artifacts, platform goldens without `GITHUB_ACTIONS=true`) — never appears in
   CI, never fix.

Say plainly what you could not verify. Here that is a short list — there are no build jobs — but
`legacy_version_analyze` covering only `stream_core` means "the canary is green" is a much weaker claim than it
sounds.
