## Upcoming

### ✨ Features

- Added macOS support, sharing the same `AVAssetImageGenerator` + `libwebp` approach
  as iOS.
- Added Windows support, via Media Foundation for decoding and WIC for JPEG/PNG
  encoding. `StreamThumbnailFormat.webp` and `headers` (for authenticated remote
  videos) are not yet supported on Windows.

### 💥 BREAKING CHANGES

- `thumbnailFiles` now fails fast: if any video fails to produce a thumbnail, the call
  throws instead of silently omitting that video from the returned list.

### 🐞 Fixed

- Fixed a crash on iOS where a failed `thumbnailData` call returned `null` instead of an
  error, causing the Dart side to crash casting `null` to `Uint8List`.
- Native errors now surface as typed `PlatformException`s on all platforms instead of a
  generic `Exception` wrapping a raw Android stack trace.
- Unified the platform-channel implementation: Android previously acknowledged a call
  immediately and delivered the real result via a separate reverse invocation; it now
  replies once with the actual result, like iOS and web.

### 🔧 Internal

- Migrated the Android/iOS platform channel to Pigeon-generated, type-safe messaging
  and rewrote the iOS plugin in Swift (previously Objective-C). The public Dart API is
  unchanged; web keeps its separate hand-written implementation, since Pigeon does not
  support it.

## 0.1.0

* Initial release.
