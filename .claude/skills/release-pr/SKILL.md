---
name: release-pr
description: >
  Open a release PR for stream-core-flutter: bump the version(s) of one or more packages, finalise their
  hand-curated CHANGELOGs (promote `## Upcoming` → `## X.Y.Z`), and open a PR from a `release/` branch. Per-package
  independent versioning — release one package or several in a single PR.
disable-model-invocation: true
argument-hint: "[<package> <version> ...]"
arguments: [packages]
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
  - Bash(melos *)
  - Bash(which *)
  - Bash(grep *)
  - Bash(sed *)
  - Read
  - Edit
  - Write
---

# release-pr

Opens a release PR for stream-core-flutter. Branch `release/<...>` → base `main` → title
`chore(<scope>): release <package> vX.Y.Z` (single package) or `chore(repo): release packages` (multiple).

**This skill only opens the PR.** After merge, tagging and pub.dev publishing are automatic:
[`release_tag.yml`](../../../.github/workflows/release_tag.yml) tags every bumped package (`<pkg>-vX.Y.Z`) and
[`release_publish.yml`](../../../.github/workflows/release_publish.yml) publishes each and cuts a GitHub Release.
See the "Releasing" section of `STYLE_GUIDE.md`.

## Key facts for this repo

- **Independent per-package versioning.** Each package releases on its own tag `<pkg>-vX.Y.Z`. A single release PR
  may bump **one package or several** — each still gets its own tag + publish run.
- **CHANGELOGs are hand-curated.** Never run `melos version` — it regenerates changelog entries from commit messages
  and clobbers the curated `## Upcoming` bullets. Releasing means *promoting* the existing `## Upcoming` heading to
  `## X.Y.Z`, not rewriting it.
- **`release/` branch is required**, not a convention: the changelog-placement check in `pr_title.yml` only allows a
  `## Upcoming` heading to become `## X.Y.Z` on a `release/` branch.

Publishable packages are the non-private ones under `packages/*` — list them with
`melos list --no-private`. Their conventional-commit scopes are defined in
`.github/workflows/pr_title.yml` (the `semantic_changelog_update` job maps each
scope to a package path); read that map rather than hard-coding it, so adding a
package needs no change here:

```bash
grep -A12 'semantic_changelog_update' .github/workflows/pr_title.yml
```

## Inputs

1. **Which packages + versions.** If given as args (e.g. `/release-pr stream_core 0.4.1 stream_core_flutter 0.5.0`),
   use them; strip any leading `v`. Otherwise **detect and confirm**: a package needs releasing when its
   `CHANGELOG.md` has a non-empty `## Upcoming` section. List those and, for each, propose a version per
   [Choosing the version](#choosing-the-version) — the user confirms or overrides.
2. **Base branch** is always `main`.

## Choosing the version

Two steps: classify the release from its CHANGELOG, then map that onto the package's current version.

**1. Classify.** Read the package's curated `## Upcoming` sub-headings — the same bullets that become the release
notes, so they are the authority on what the release contains:

```bash
sed -n '/^## Upcoming/,/^## [0-9]/p' packages/<pkg>/CHANGELOG.md | grep -i '^### .*breaking'
```

- **any** match → **breaking**. Match on the word *breaking*, not one exact heading — the current entry is
  `### 🛑 Breaking / Removals`, but `### 💥 Breaking Changes` and `### 💥 BREAKING CHANGES` also appear in these
  changelogs, and the wording may change again.
- no match (only Features / Bug Fixes / Deprecations) → **compatible**

**Deprecations are not breaking** — a deprecated API still works, so a release that only deprecates is compatible.

**2. Map onto the current version.** The same release is a different bump depending on where the package sits,
per the Dart community convention in
[Package versioning](https://dart.dev/tools/pub/versioning#semantic-versions):

> Although semantic versioning doesn't promise any compatibility between versions prior to `1.0.0`, the Dart
> community convention is to treat those versions semantically as well. The interpretation of each number is just
> shifted down one slot: going from `0.1.2` to `0.2.0` indicates a breaking change, going to `0.1.3` indicates a new
> feature, and going to `0.1.2+1` indicates a change that doesn't affect the public API. For simplicity's sake,
> avoid using `+` after the version reaches `1.0.0`.

Read the current version first — `grep '^version:' packages/<pkg>/pubspec.yaml` — and pick the column from it
rather than assuming either regime:

| Release | at/above `1.0.0` | below `1.0.0` |
| --- | --- | --- |
| breaking | major | minor |
| compatible, adds API | minor | patch |
| no public API change | patch | build (`+1`) |

The shift matters because a caret constraint stops at the leading significant digit: `^1.4.1` means
`>=1.4.1 <2.0.0` (major breaks), while `^0.4.1` means `>=0.4.1 <0.5.0` (minor breaks). Whichever slot that is for
the package at hand, bumping it strands every consumer on the old caret until they hand-edit their pubspec — so
bump it only for a genuinely breaking release.

State the proposed version, the heading it came from, and which column you used; then ask the user to confirm —
**they still decide**. If they supply a version that disagrees with the derivation, say so once, then use theirs.

A behavior change that is source-compatible but alters rendered output (color math, layout metrics, changed
defaults) belongs under `### 🛑 Breaking / Removals`, not Features — file it there when writing the entry and the
derivation above reaches the right answer on its own.

> Precedent: `stream_core_flutter` v0.5.0 was released as a minor with no breaking section — it should have been
> `0.4.2`. It shipped to pub.dev before the error was caught, and pub.dev cannot delete a version, so it was left in
> place. Get the bump right before merge; there is no undo.

## Pre-flight

Run these. **If any fails, stop, surface it to the user, and do not auto-fix** (no stashing, no force-pull, no
killing processes).

- `git checkout main && git pull --ff-only` leaves `git status --short` clean — **including untracked files**, so a
  stray local file can't slip into the release commit at `git add -A` (step 5).
- `which melos`, `gh auth status` succeed.
- Latest CI on `main` is green: `gh run list --branch main --limit 5` — no failures on the most recent runs.
- No open release PR for the same branch: `gh pr list --head <branch> --state all --json number` returns `[]`.

## Steps

### 1. Branch off main

```bash
git checkout -b <branch>
```

Branch name: `release/<pkg>-vX.Y.Z` for a single package, or `release/YYYY-MM-DD` for a multi-package release.

### 2. Bump version(s)

For **each** package being released:

- Set `version: <newver>` in `packages/<pkg>/pubspec.yaml`.

Only if a released package is a **dependency that a dependent must now require at the new version** (the dependent
started using a new API), also bump that package's entry in `melos.yaml`'s `command.bootstrap.dependencies` block
(`grep -nE 'stream_(core|core_flutter|thumbnail):' melos.yaml`) — and release the dependent too. A compatible bump
that the existing caret already allows (e.g. `stream_core 0.4.0 → 0.4.1` under `stream_core: ^0.4.0`) needs **no**
block change.

Then propagate constraints:

```bash
melos bootstrap
```

Do **not** run `melos version`.

### 3. Finalise each released package's CHANGELOG

For every package being released, in `packages/<pkg>/CHANGELOG.md` rename the top `## Upcoming` heading to
`## <newver>`. Keep the curated bullets exactly as they are — do not add, rewrite, or regenerate them. Sub-headings
(`### ✨ Features`, `### 🐛 Bug Fixes`, `### 🛑 Breaking / Removals`) stay untouched.

If a package is being released only because a dependency bump forces it (no user-facing change of its own), give it a
`## <newver>` section with a single bullet noting the dependency bump — every released package must have a non-empty
`## <newver>` section (pana fails on an empty or missing one).

Do not hand-write cross-package "bumps stream_core to X.Y.Z" lines beyond that; per `STYLE_GUIDE.md`, cross-linking is
the release tooling's job.

### 4. Sanity-check

```bash
melos run analyze
melos run lint:pub
```

If either fails, surface it and stop.

### 5. Commit and push

```bash
git add -A
git commit -m "<title>"
git push -u origin <branch>
```

Single commit. **The title is load-bearing** — `release_tag.yml` gates on the `chore(...): release` prefix:

- One package: `chore(<scope>): release <package> vX.Y.Z` (e.g. `chore(llc): release stream_core v0.4.1`).
- Several: `chore(repo): release packages` — generic, so the title stays short no matter how many packages bump.

Tagging derives from package state, not this title, so a typo can't mis-tag — but keep the prefix intact or the tag
job won't fire.

### 6. Open the PR

Build the body from the promoted CHANGELOG sections (the same content that becomes each GitHub Release). Do **not**
use `gh api .../generate-notes` — this repo deliberately does not use GitHub's generated notes.

```bash
gh pr create --base main --head <branch> --title "<title>" --body-file <notes>
```

A good body lists each released package, its version, and its `## <newver>` CHANGELOG section. Return the PR URL.

**Tell the user to squash-merge it.** `release_tag.yml` gates on the *tip* commit's message, so a squash lands the
`chore(...): release` title as that commit. A merge commit would make the tip `Merge pull request #…` and the release
would silently not run.

## After merge (FYI)

`release_tag.yml` tags every bumped package and `release_publish.yml` publishes each (OIDC) and creates a per-package
GitHub Release from its CHANGELOG section. Multi-package releases publish in dependency order automatically (the
publish job waits for in-workspace dependencies to be live first).

## Don't

- **Never bump a package's breaking slot without a breaking section** in its `## Upcoming` — that slot is the major
  at/above `1.0.0` and the minor below it, and bumping it strands every consumer on the old caret. See
  [Choosing the version](#choosing-the-version).
- **Never run `melos version`** — it clobbers the hand-curated CHANGELOGs.
- **Never tag or push a tag** — `release_tag.yml` does it on merge.
- **Never run `melos run release:pub` locally** — it's the CI publish step; running it publishes from an unreviewed
  tree. Refuse even if asked. (Tagging is inlined in `release_tag.yml`, not a melos script — don't run it by hand.)
- **Never create a GitHub release** (`gh release create`) — `release_publish.yml` creates it after the tag is pushed.
- **Never merge the PR.** Return the URL and stop.
