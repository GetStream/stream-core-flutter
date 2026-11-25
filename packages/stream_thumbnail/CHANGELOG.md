## Upcoming

### ✨ Features

- Added `StreamThumbnailSource`, which says whether a video is a network URL, a local file or an Android content
  URI.

### 💥 BREAKING CHANGES

- Removed the `video`, `videos` and `headers` parameters; `source` and `sources` are now required. Pass
  `StreamThumbnailSource.network(url, headers: ...)`, `StreamThumbnailSource.file(path)` or
  `StreamThumbnailSource.contentUri(uri)` instead.
- Only `http` and `https` URLs are fetched; any other scheme fails with an `UNSUPPORTED_SOURCE` `PlatformException`.
- On Windows, a file source must be an absolute path on a local drive.
- On Linux, videos are read only from single-file containers; playlists such as HLS and DASH are not supported.

### 🔄 Changed

- `thumbnailFile` and `thumbnailFiles` give each thumbnail a generated file name instead of the video's file name. On
  web, the download name is `thumbnail.<ext>`.
- A thumbnail is at most 4096 pixels on its longest side, including when `maxWidth` and `maxHeight` are left at `0`.
  A video more than 8192 pixels on a side fails with a `THUMBNAIL_ERROR` `PlatformException`.
- At most three thumbnails are generated at a time; further calls wait for one to finish.
- A network video sent with headers that redirects to another scheme, host or port, including from `http` to `https`,
  is fetched from there without the `Authorization`, `Cookie` and `Proxy-Authorization` headers. On web, the browser
  follows redirects itself.
- On Linux, reading a network video fails after 30 seconds without data.

### 🐞 Fixed

- On Android 10 and later, a local video with `maxWidth` or `maxHeight` left at `0` now produces a
  thumbnail instead of failing.
- On Android, running out of memory while generating a thumbnail fails with a `THUMBNAIL_ERROR` `PlatformException`
  instead of crashing the app.

## 0.2.0

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
