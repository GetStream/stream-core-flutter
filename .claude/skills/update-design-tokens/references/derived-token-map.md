# Token sync state

## Last sync

| | |
| --- | --- |
| upstream commit | `4ef9b54bf93f2e42f346340690296dfca480ebc9` |
| upstream PR | [design-system-tokens#73](https://github.com/GetStream/design-system-tokens/pull/73) |
| date | 2026-09-10 |

**Update this on every sync.** Nothing in the repo records which upstream state the
vendored tokens correspond to, and unlike a token's readers it cannot be recovered
by grepping — you would have to bisect upstream comparing values. One line here
turns the next sync into a mechanical diff:

```bash
python3 <skill>/scripts/flatten_tokens.py --diff 4ef9b54 origin/main tokens/core/semantics/light.json
```

Read it as *"every semantic change up to here has been triaged"*, not *"the vendored
files mirror this commit"*. They do not, and knowingly so: the vendored set is a
strict **subset** of upstream. Every name here exists upstream under the same
spelling, but a large share of upstream's names are deliberately absent — mostly
derived tokens a component re-derives from a `colorScheme` field instead.

Two properties also hold as of this commit: every vendored color constant has a
reader, and `light/` and `dark/` declare the same set. Neither is a claim about
upstream, so check the subset relation yourself rather than trusting a count that
rots:

```bash
python3 <skill>/scripts/flatten_tokens.py tokens/core/semantics/light.json
```

## Derived-token map

Where upstream's **derived** chat and video semantics are actually implemented.

This file exists because that mapping is not greppable. Derived tokens have no
`StreamColorScheme` field — the SDK inlines the value as a swatch or root-semantic
read inside a component-theme default, so nothing in the code carries the token's
name. `indicator/sound-indicator/speaking` is implemented as a `speakingColor`
defaulting to `colorScheme.brand.shade300`; no search for "speaking" or
"soundIndicator" reaches it.

Root semantics need no entry here — they have a field, so
`scripts/map_token_usage.py` finds their readers in seconds. Only add a row when
the connection cost you a manual trace.

**Verify a row before acting on it.** These point at other repos, which move
independently and will not update this file. Opening the named file to confirm is
cheap; trusting a stale row is not. If a row is wrong, fix it in the same change
that discovered the problem — and add rows as you trace new ones, so the next
person pays the cost once.

## Video

Reference ref: `origin/v2` in stream-video-flutter (the design-system branch).

| upstream token | resolves to | implemented in | component |
| --- | --- | --- | --- |
| `indicator/connection-quality/poor` | `{accent.error}` | video · `indicators/connection_quality_indicator_defaults.dart` → `poorColor` | `StreamConnectionQualityIndicator` |
| `indicator/connection-quality/fair` | `{accent.warning}` | video · same file → `fairColor` | `StreamConnectionQualityIndicator` |
| `indicator/connection-quality/great` | `{accent.success}` | video · same file → `greatColor` | `StreamConnectionQualityIndicator` |
| `indicator/sound-indicator/speaking` | `{brand.400}` | video · `theme/components/participant_label_theme.dart` → `speakingColor` | `StreamAudioIndicator` |
| `control/call-control-error-badge/bg` | `{accent.warning}` | **core** · `components/badge/stream_error_badge.dart` → `warningBackgroundColor`, i.e. `colorScheme.accentWarning` | `StreamErrorBadge`, wrapped by video's `CallButtonBadge` |
| `control/call-control-error-badge/text` | `{base.black}` | **core** · same file → `warningForegroundColor`, a literal `StreamColors.black` — `textOnAccent` resolves to white in *both* modes and cannot satisfy `{base.black}` | `StreamErrorBadge` |
| `indicator/microphone-level/bar-active` | `{brand.400}` | not implemented — the lobby level meter is new | — |
| `indicator/microphone-level/bar-inactive` | `{chrome.200}` | not implemented | — |

Two things this table is worth reading for:

- **A video token can land in this repo.** The call-control error badge is a video
  token whose only implementation is `StreamErrorBadge`, a core component. Video's
  `CallButtonBadge` just wraps it. So "video namespace" never means "not our
  problem" — it means check the video SDK *as well*.
- **`speakingColor` resolves `brand.shade300` while the token says `{brand.400}`.**
  Whether that is a deliberate deviation or drift is unresolved; treat it as a
  question to ask, not a bug to fix silently.

## Chat

Chat components live in this repo, under the `chat.dart` barrel, so a
`tokens/chat/**` change usually means work **here** rather than in
stream-chat-flutter — the reverse of the intuition the namespace suggests.
Chat semantics are also vendored into `internal/tokens/` with a `chat` prefix
(`chatReplyIndicatorIncoming`, `chatTextTypingIndicator`).

Reference ref: `origin/master` in stream-chat-flutter.

No manually-traced rows yet. Add them as they come up, in the same shape as the
video table.
