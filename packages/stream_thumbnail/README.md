# Stream Thumbnail

## Introduction

A Flutter plugin for creating a thumbnail image from a video. Give it a local file path or a video URL and it returns the thumbnail as bytes or as a saved image file. Works on Android, iOS, macOS, Windows, Linux, and web.

Windows requires the [Media Feature Pack](https://support.microsoft.com/en-us/topic/media-feature-pack-list-for-windows-n-editions-c1c6bfba-4bf7-4be6-ae13-8608318bf3d4) for decoding (present by default outside of "N"/"KN" Windows editions), and doesn't yet support `StreamThumbnailFormat.webp` or `headers` for authenticated remote videos.

Linux requires FFmpeg and libwebp development packages on the build machine, e.g. on Debian/Ubuntu: `libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libwebp-dev`.

## Installation

Add the following to your `pubspec.yaml` and replace `[version]` with the latest version:

```yaml
dependencies:
  stream_thumbnail: ^[version]
```

## Usage

```dart
import 'package:stream_thumbnail/stream_thumbnail.dart';
```

### Bytes

Get the thumbnail as in-memory bytes — ideal for `Image.memory`:

```dart
final bytes = await StreamThumbnail.thumbnailData(
  video: 'https://example.com/video.mp4',
  imageFormat: StreamThumbnailFormat.jpeg,
  maxWidth: 128, // 0 keeps the source resolution
  quality: 25,
);
```

### File

Write the thumbnail to a temporary directory and get back an `XFile`:

```dart
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final thumbnail = await StreamThumbnail.thumbnailFile(
  video: '/path/to/video.mp4',
  imageFormat: StreamThumbnailFormat.png,
  maxHeight: 200,
);

// Copy it somewhere permanent; the temporary file is left for the OS to reclaim.
final cacheDir = await getApplicationCacheDirectory();
await thumbnail.saveTo(p.join(cacheDir.path, thumbnail.name));
```

On web there is no file system. The `XFile` wraps an object URL the caller owns, so
read the bytes with `XFile.readAsBytes` and then release it with `URL.revokeObjectURL`
— calling `saveTo` there ignores the path and triggers a browser download instead.

### Multiple files

Generate thumbnails for several videos in one call:

```dart
final thumbnails = await StreamThumbnail.thumbnailFiles(
  videos: ['/path/to/a.mp4', '/path/to/b.mp4'],
);
```

## Options

Every method accepts the same options:

| Option          | Description                                                                     |
| --------------- | ------------------------------------------------------------------------------- |
| `video`(s)      | Path to a local video file or a video URL.                                      |
| `headers`       | HTTP headers sent when fetching a remote video. Not supported on Windows.       |
| `imageFormat`   | `JPEG`, `PNG`, or `WEBP`. Defaults to `PNG`. WebP on iOS/macOS is backed by `libwebp`; not yet supported on Windows.|
| `maxHeight` / `maxWidth` | Max size in pixels, or `0` to keep the source resolution.              |
| `timeMs`        | Capture position in milliseconds.                                               |
| `quality`       | Output quality, `0`–`100` (ignored for PNG).                                    |
