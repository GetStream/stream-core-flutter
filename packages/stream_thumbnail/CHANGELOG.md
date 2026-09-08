## Upcoming

### ✨ Features

- Added macOS support, sharing the same `AVAssetImageGenerator` + `libwebp` approach
  as iOS.
- Added Windows support, via Media Foundation for decoding and WIC for JPEG/PNG
  encoding. `StreamThumbnailFormat.webp` and `headers` (for authenticated remote
  videos) are not yet supported on Windows.
- Added Linux support, via FFmpeg for decoding and jpeg/png encoding, and `libwebp`
  for WebP — the only platform besides Android with full format support, including
  `headers` for authenticated remote videos.

### 💥 BREAKING CHANGES

- `thumbnailFiles` now fails fast: if any video fails to produce a thumbnail, the call
  throws instead of silently omitting that video from the returned list.
- `thumbnailFile` and `thumbnailFiles` no longer take a `thumbnailPath`. Every thumbnail
  is written to a fresh temporary directory and returned as an `XFile`; call
  `XFile.saveTo` to move one somewhere permanent, or `XFile.readAsBytes` on web. The
  parameter meant "a directory, or the output file itself", and each platform decided
  which by inspecting the string — differently. Web ignored it outright.

### 🐞 Fixed

- Fixed a crash on iOS where a failed `thumbnailData` call returned `null` instead of an
  error, causing the Dart side to crash casting `null` to `Uint8List`.
- Fixed a `file://` video whose path is percent-encoded resolving to the wrong file on
  iOS and macOS: `file:///tmp/a%20b.mp4` looked for a literal `a%20b.mp4` rather than
  `a b.mp4`. Android, Linux and Windows still open the path verbatim, so pass those
  three an unencoded path. A `?` or `#` in a file name is safe everywhere.
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

## 0.1.0+1

### 🔄 Changed

- Raised the minimum Flutter version to `>=3.44.0` and the Dart SDK to `^3.12.0`.

## 0.1.0

* Initial release.
