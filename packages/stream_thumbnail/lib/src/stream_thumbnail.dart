// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';

import 'stream_thumbnail_format.dart';
import 'stream_thumbnail_platform.dart';

/// The file extension the native implementations give a thumbnail of [format].
///
/// Kept in sync with `formatExt` (Android), `fileExtension` (iOS/macOS), and
/// `FileExtension` (Windows/Linux).
String _extensionFor(StreamThumbnailFormat format) => switch (format) {
  StreamThumbnailFormat.jpeg => 'jpg',
  StreamThumbnailFormat.png => 'png',
  StreamThumbnailFormat.webp => 'webp',
};

/// Creates thumbnails from a local video file or from a video URL.
abstract final class StreamThumbnail {
  /// Generates a thumbnail file for each of the given `videos`.
  ///
  /// Each video can be a local file or a URL in an iOS/Android supported video
  /// format. When `thumbnailPath` is null, files are written next to each
  /// video. Use `maxHeight`/`maxWidth` to bound the size, or `0` to keep the
  /// source resolution. A lower `quality` reduces image quality but is ignored
  /// for the `PNG` format.
  ///
  /// For more than one video, `thumbnailPath` must name a directory rather than
  /// a file, otherwise an [ArgumentError] is thrown. Every video in the batch
  /// would otherwise be written to that one path.
  static Future<List<XFile>> thumbnailFiles({
    required List<String> videos,
    Map<String, String>? headers,
    String? thumbnailPath,
    StreamThumbnailFormat imageFormat = StreamThumbnailFormat.png,
    int maxHeight = 0,
    int maxWidth = 0,
    int? timeMs,
    int quality = 10,
  }) async {
    if (videos.isEmpty) return [];

    // Every platform treats a `thumbnailPath` that already ends in the target
    // extension as the exact file to write to. With more than one video that
    // points the whole batch at a single path, so the requests overwrite each
    // other and the returned files all describe the same bytes.
    if (videos.length > 1 && thumbnailPath != null && thumbnailPath.endsWith(_extensionFor(imageFormat))) {
      throw ArgumentError.value(
        thumbnailPath,
        'thumbnailPath',
        'must be a directory when generating thumbnails for multiple videos, not a single file',
      );
    }

    return StreamThumbnailPlatform.instance.thumbnailFiles(
      videos: videos,
      headers: headers,
      thumbnailPath: thumbnailPath,
      imageFormat: imageFormat,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      timeMs: timeMs,
      quality: quality,
    );
  }

  /// Generates a thumbnail file for the given `video`.
  ///
  /// The video can be a local file or a URL in an iOS/Android supported video
  /// format. When `thumbnailPath` is null, the file is written next to the
  /// video. Use `maxHeight`/`maxWidth` to bound the size, or `0` to keep the
  /// source resolution. A lower `quality` reduces image quality but is ignored
  /// for the `PNG` format.
  static Future<XFile> thumbnailFile({
    required String video,
    Map<String, String>? headers,
    String? thumbnailPath,
    StreamThumbnailFormat imageFormat = StreamThumbnailFormat.png,
    int maxHeight = 0,
    int maxWidth = 0,
    int? timeMs,
    int quality = 10,
  }) {
    assert(video.isNotEmpty);

    return StreamThumbnailPlatform.instance.thumbnailFile(
      video: video,
      headers: headers,
      thumbnailPath: thumbnailPath,
      imageFormat: imageFormat,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      timeMs: timeMs,
      quality: quality,
    );
  }

  /// Generates a thumbnail for the given `video` as in-memory bytes.
  ///
  /// The returned bytes can be rendered directly with `Image.memory`. The video
  /// can be a local file or a URL in an iOS/Android supported video format. Use
  /// `maxHeight`/`maxWidth` to bound the size, or `0` to keep the source
  /// resolution. A lower `quality` reduces image quality but is ignored for the
  /// `PNG` format.
  static Future<Uint8List> thumbnailData({
    required String video,
    Map<String, String>? headers,
    StreamThumbnailFormat imageFormat = StreamThumbnailFormat.png,
    int maxHeight = 0,
    int maxWidth = 0,
    int? timeMs,
    int quality = 10,
  }) {
    assert(video.isNotEmpty);

    return StreamThumbnailPlatform.instance.thumbnailData(
      video: video,
      headers: headers,
      imageFormat: imageFormat,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      timeMs: timeMs,
      quality: quality,
    );
  }
}
