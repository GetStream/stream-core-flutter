## Upcoming

### ✨ Features

- Added macOS, Windows and Linux support, alongside the existing Android, iOS and web.
  macOS requires 10.15 or later. Linux needs FFmpeg and libwebp development packages
  present at build time — on Debian/Ubuntu: `libavcodec-dev libavformat-dev
  libavutil-dev libswscale-dev libwebp-dev`.
- On Windows, `StreamThumbnailFormat.webp` is not supported yet and fails with an
  `UNSUPPORTED_FORMAT` error, and `headers` is ignored — a remote video needing
  authentication cannot be thumbnailed there.

### 💥 BREAKING CHANGES

- `thumbnailFile` and `thumbnailFiles` no longer take a `thumbnailPath`, and no longer
  write next to the source video or into the cache directory. Each thumbnail goes to its
  own temporary directory and is returned as an `XFile`. Use `XFile.saveTo` to copy it
  somewhere permanent, or `XFile.readAsBytes` on web.
- `thumbnailFiles` now throws if any video fails, instead of dropping it from the
  returned list. A shorter list no longer silently means some videos failed.

### 🐞 Fixed

- Failures now surface as a `PlatformException` with a code and message on every
  platform, rather than a generic `Exception`. On iOS, a failed `thumbnailData` used to
  crash on a null cast instead of reporting the error.
- On iOS, a percent-encoded `file://` video now resolves to the right file:
  `file:///tmp/a%20b.mp4` used to look for a literal `a%20b.mp4`. macOS behaves the
  same; Android, Linux and Windows read the path as given, so pass those an unencoded
  path.
- On web, the returned `XFile` now carries a file name, so `XFile.saveTo` saves
  `clip.png` instead of an unnamed file.

## 0.1.0+1

### 🔄 Changed

- Raised the minimum Flutter version to `>=3.44.0` and the Dart SDK to `^3.12.0`.

## 0.1.0

* Initial release.
