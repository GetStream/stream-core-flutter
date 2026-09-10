# Derived-token map

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
| `control/call-control-error-badge/bg` | `{accent.warning}` | **core** · `components/badge/stream_error_badge.dart` → `colorScheme.accentError` | `StreamErrorBadge`, wrapped by video's `CallButtonBadge` |
| `control/call-control-error-badge/text` | `{base.black}` | **core** · same file → `colorScheme.textOnAccent` | `StreamErrorBadge` |
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
