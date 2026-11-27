# Stream Thumbnail

## Introduction

A Flutter plugin for creating a thumbnail image from a video. Give it a local file path or a video URL and it returns the thumbnail as bytes or as a saved image file. Works on Android, iOS, macOS, Windows, Linux, and web.

Windows requires the [Media Feature Pack](https://support.microsoft.com/en-us/topic/media-feature-pack-list-for-windows-n-editions-c1c6bfba-4bf7-4be6-ae13-8608318bf3d4) for decoding (present by default outside of "N"/"KN" Windows editions), and doesn't yet support `StreamThumbnailFormat.webp` or headers for authenticated remote videos. File sources must be absolute paths on a local drive.

Linux requires FFmpeg and libwebp development packages on the build machine, e.g. on Debian/Ubuntu: `libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libwebp-dev`. Videos are read from single-file containers only, not playlists such as HLS or DASH.

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

### Sources

Every method takes a `StreamThumbnailSource` that says where the video comes from:

| Source | Use for |
| ------ | ------- |
| `StreamThumbnailSource.network(url, headers: ...)` | A video URL. Only `http` and `https` URLs are fetched. |
| `StreamThumbnailSource.file(path)` | A video stored on the device, such as one the user picked. On web, the object URL of the video. |
| `StreamThumbnailSource.contentUri(uri)` | A video an Android content provider serves. Android only. |

### Bytes

Get the thumbnail as in-memory bytes — ideal for `Image.memory`:

```dart
final bytes = await StreamThumbnail.thumbnailData(
  source: StreamThumbnailSource.network(Uri.parse('https://example.com/video.mp4')),
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
  source: StreamThumbnailSource.file('/path/to/video.mp4'),
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
  sources: [
    StreamThumbnailSource.file('/path/to/a.mp4'),
    StreamThumbnailSource.file('/path/to/b.mp4'),
  ],
);
```

## Options

Every method accepts the same options:

| Option          | Description                                                                     |
| --------------- | ------------------------------------------------------------------------------- |
| `source`(s)     | The video to thumbnail; see [Sources](#sources). `network` sources carry the HTTP headers to send, which Windows ignores. |
| `imageFormat`   | `JPEG`, `PNG`, or `WEBP`. Defaults to `PNG`. WebP on iOS/macOS is backed by `libwebp`; not yet supported on Windows.|
| `maxHeight` / `maxWidth` | Max size in pixels, or `0` to keep the source resolution.              |
| `timeMs`        | Capture position in milliseconds.                                               |
| `quality`       | Output quality, `0`–`100` (ignored for PNG).                                    |
