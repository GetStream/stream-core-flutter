// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:pool/pool.dart';

import 'network_redirects.dart';
import 'stream_thumbnail_format.dart';
import 'stream_thumbnail_platform.dart';
import 'stream_thumbnail_source.dart';

/// Creates thumbnails from a local video file or from a video URL.
///
/// At most three thumbnails are generated at a time; further calls wait for
/// one to finish. A thumbnail that takes longer than a minute fails with a
/// `THUMBNAIL_ERROR` [PlatformException], and frees its place for the next
/// call. A thumbnail is at most 4096 pixels on its longest side, and
/// a video more than 8192 pixels on a side fails with a `THUMBNAIL_ERROR`
/// [PlatformException].
abstract final class StreamThumbnail {
  static final _pool = Pool(3);

  static Future<T> _generate<T>(Future<T> Function() task) {
    return _pool.withResource(
      () => task().timeout(
        const Duration(minutes: 1),
        onTimeout: () => throw PlatformException(
          code: 'THUMBNAIL_ERROR',
          message: 'Generating the thumbnail took longer than a minute.',
        ),
      ),
    );
  }

  /// Generates a thumbnail file for each of [sources], in order.
  ///
  /// Use [maxHeight] and [maxWidth] to bound the size, or `0` to keep the
  /// source resolution, up to 4096 pixels. A lower [quality] reduces image quality but is ignored
  /// for [StreamThumbnailFormat.png]. The videos are processed one at a time.
  ///
  /// Each thumbnail is written to a new, uniquely named file in a temporary
  /// directory. Use [XFile.saveTo] to copy one somewhere permanent; the
  /// temporary file is left behind for the platform to reclaim.
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

    return _generate(
      () async => StreamThumbnailPlatform.instance.thumbnailFiles(
        sources: [for (final source in sources) await resolveRedirects(source)],
        imageFormat: imageFormat,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        timeMs: timeMs,
        quality: quality,
      ),
    );
  }

  /// Generates a thumbnail file for [source].
  ///
  /// Use [maxHeight] and [maxWidth] to bound the size, or `0` to keep the
  /// source resolution, up to 4096 pixels. A lower [quality] reduces image quality but is ignored
  /// for [StreamThumbnailFormat.png].
  ///
  /// The thumbnail is written to a new, uniquely named file in a temporary
  /// directory. Use [XFile.saveTo] to copy it somewhere permanent; the
  /// temporary file is left behind for the platform to reclaim.
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

    return _generate(
      () async => StreamThumbnailPlatform.instance.thumbnailFile(
        source: await resolveRedirects(source),
        imageFormat: imageFormat,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        timeMs: timeMs,
        quality: quality,
      ),
    );
  }

  /// Generates a thumbnail for [source] as in-memory bytes.
  ///
  /// The returned bytes can be rendered directly with `Image.memory`. Use
  /// [maxHeight] and [maxWidth] to bound the size, or `0` to keep the source
  /// resolution, up to 4096 pixels. A lower [quality] reduces image quality but is ignored for
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

    return _generate(
      () async => StreamThumbnailPlatform.instance.thumbnailData(
        source: await resolveRedirects(source),
        imageFormat: imageFormat,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        timeMs: timeMs,
        quality: quality,
      ),
    );
  }
}
