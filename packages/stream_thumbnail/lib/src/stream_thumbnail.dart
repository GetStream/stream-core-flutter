// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';

import 'stream_thumbnail_format.dart';
import 'stream_thumbnail_platform.dart';
import 'stream_thumbnail_source.dart';

/// Creates thumbnails from a local video file or from a video URL.
abstract final class StreamThumbnail {
  /// Generates a thumbnail file for each of [sources], in order.
  ///
  /// Use [maxHeight] and [maxWidth] to bound the size, or `0` to keep the
  /// source resolution. A lower [quality] reduces image quality but is ignored
  /// for [StreamThumbnailFormat.png]. The videos are processed one at a time.
  ///
  /// Each thumbnail is written to its own temporary directory. Use
  /// [XFile.saveTo] to copy one somewhere permanent; the temporary file is left
  /// behind for the platform to reclaim.
  ///
  /// On web there is no file system: each [XFile] wraps an object URL that the
  /// caller owns and should release with `URL.revokeObjectURL` once the bytes
  /// have been read via [XFile.readAsBytes].
  ///
  /// Fails with an `UNSUPPORTED_SOURCE` [PlatformException] if a source can't
  /// be opened on this platform.
  static Future<List<XFile>> thumbnailFiles({
    required List<StreamThumbnailSource> sources,
    StreamThumbnailFormat imageFormat = StreamThumbnailFormat.png,
    int maxHeight = 0,
    int maxWidth = 0,
    int? timeMs,
    int quality = 10,
  }) async {
    if (sources.isEmpty) return [];
    for (final source in sources) {
      if (source.unsupportedReason case final reason?) throw reason;
    }

    return StreamThumbnailPlatform.instance.thumbnailFiles(
      sources: sources,
      imageFormat: imageFormat,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      timeMs: timeMs,
      quality: quality,
    );
  }

  /// Generates a thumbnail file for [source].
  ///
  /// Use [maxHeight] and [maxWidth] to bound the size, or `0` to keep the
  /// source resolution. A lower [quality] reduces image quality but is ignored
  /// for [StreamThumbnailFormat.png].
  ///
  /// The thumbnail is written to its own temporary directory. Use [XFile.saveTo]
  /// to copy it somewhere permanent; the temporary file is left behind for the
  /// platform to reclaim.
  ///
  /// On web there is no file system: the [XFile] wraps an object URL that the
  /// caller owns and should release with `URL.revokeObjectURL` once the bytes
  /// have been read via [XFile.readAsBytes].
  ///
  /// Fails with an `UNSUPPORTED_SOURCE` [PlatformException] if [source] can't
  /// be opened on this platform.
  static Future<XFile> thumbnailFile({
    required StreamThumbnailSource source,
    StreamThumbnailFormat imageFormat = StreamThumbnailFormat.png,
    int maxHeight = 0,
    int maxWidth = 0,
    int? timeMs,
    int quality = 10,
  }) {
    if (source.unsupportedReason case final reason?) return Future.error(reason);

    return StreamThumbnailPlatform.instance.thumbnailFile(
      source: source,
      imageFormat: imageFormat,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      timeMs: timeMs,
      quality: quality,
    );
  }

  /// Generates a thumbnail for [source] as in-memory bytes.
  ///
  /// The returned bytes can be rendered directly with `Image.memory`. Use
  /// [maxHeight] and [maxWidth] to bound the size, or `0` to keep the source
  /// resolution. A lower [quality] reduces image quality but is ignored for
  /// [StreamThumbnailFormat.png].
  ///
  /// Fails with an `UNSUPPORTED_SOURCE` [PlatformException] if [source] can't
  /// be opened on this platform.
  static Future<Uint8List> thumbnailData({
    required StreamThumbnailSource source,
    StreamThumbnailFormat imageFormat = StreamThumbnailFormat.png,
    int maxHeight = 0,
    int maxWidth = 0,
    int? timeMs,
    int quality = 10,
  }) {
    if (source.unsupportedReason case final reason?) return Future.error(reason);

    return StreamThumbnailPlatform.instance.thumbnailData(
      source: source,
      imageFormat: imageFormat,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      timeMs: timeMs,
      quality: quality,
    );
  }
}
