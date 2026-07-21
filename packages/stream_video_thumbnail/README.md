# Stream Video Thumbnail

## Introduction

A Flutter plugin for creating a thumbnail image from a video. Give it a local file path or a video URL and it returns the thumbnail as bytes or as a saved image file. Works on Android, iOS, and web.

## Installation

Add the following to your `pubspec.yaml` and replace `[version]` with the latest version:

```yaml
dependencies:
  stream_video_thumbnail: ^[version]
```

## Usage

```dart
import 'package:stream_video_thumbnail/stream_video_thumbnail.dart';
```

### Bytes

Get the thumbnail as in-memory bytes — ideal for `Image.memory`:

```dart
final bytes = await StreamVideoThumbnail.thumbnailData(
  video: 'https://example.com/video.mp4',
  imageFormat: StreamThumbnailFormat.jpeg,
  maxWidth: 128, // 0 keeps the source resolution
  quality: 25,
);
```

### File

Write the thumbnail to disk and get back an `XFile`. If `thumbnailPath` is omitted, the
image is saved next to the video (or in the cache directory for remote videos):

```dart
final thumbnail = await StreamVideoThumbnail.thumbnailFile(
  video: '/path/to/video.mp4',
  imageFormat: StreamThumbnailFormat.png,
  maxHeight: 200,
);
```

### Multiple files

Generate thumbnails for several videos in one call:

```dart
final thumbnails = await StreamVideoThumbnail.thumbnailFiles(
  videos: ['/path/to/a.mp4', '/path/to/b.mp4'],
);
```

## Options

Every method accepts the same options:

| Option          | Description                                                                     |
| --------------- | ------------------------------------------------------------------------------- |
| `video`(s)      | Path to a local video file or a video URL.                                      |
| `headers`       | HTTP headers sent when fetching a remote video.                                 |
| `thumbnailPath` | Output path (file variants only). Defaults to the video's folder or cache dir.  |
| `imageFormat`   | `JPEG`, `PNG`, or `WEBP`. Defaults to `PNG`. WebP on iOS is backed by `libwebp`.|
| `maxHeight` / `maxWidth` | Max size in pixels, or `0` to keep the source resolution.              |
| `timeMs`        | Capture position in milliseconds.                                               |
| `quality`       | Output quality, `0`–`100` (ignored for PNG).                                    |
