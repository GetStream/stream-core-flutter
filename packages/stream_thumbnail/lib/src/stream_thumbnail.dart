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
  /// Exactly one of [sources] and the deprecated [videos] must be given. Fails
  /// with an `UNSUPPORTED_SOURCE` [PlatformException] if a source can't be
  /// opened on this platform.
  static Future<List<XFile>> thumbnailFiles({
    List<StreamThumbnailSource>? sources,
    @Deprecated('Use sources instead.') List<String>? videos,
    @Deprecated('Use StreamThumbnailSource.network(headers:) instead.') Map<String, String>? headers,
    StreamThumbnailFormat imageFormat = StreamThumbnailFormat.png,
    int maxHeight = 0,
    int maxWidth = 0,
    int? timeMs,
    int quality = 10,
  }) async {
    if (sources == null && videos == null) throw ArgumentError('Pass either sources or videos.');
    assert(sources == null || videos == null, 'Pass only one of sources and videos; sources wins.');
    assert(headers == null || videos != null, 'headers only apply to videos; give them to each network source.');

    final resolved = sources ?? [for (final video in videos!) _legacySource(video, headers)];
    if (resolved.isEmpty) return [];
    for (final source in resolved) {
      if (source.unsupportedReason case final reason?) throw reason;
    }

    return StreamThumbnailPlatform.instance.thumbnailFiles(
      sources: resolved,
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
  /// Exactly one of [source] and the deprecated [video] must be given. Fails
  /// with an `UNSUPPORTED_SOURCE` [PlatformException] if [source] can't be
  /// opened on this platform.
  static Future<XFile> thumbnailFile({
    StreamThumbnailSource? source,
    @Deprecated('Use source instead.') String? video,
    @Deprecated('Use StreamThumbnailSource.network(headers:) instead.') Map<String, String>? headers,
    StreamThumbnailFormat imageFormat = StreamThumbnailFormat.png,
    int maxHeight = 0,
    int maxWidth = 0,
    int? timeMs,
    int quality = 10,
  }) {
    if (source == null && video == null) throw ArgumentError('Pass either source or video.');
    assert(source == null || video == null, 'Pass only one of source and video; source wins.');
    assert(headers == null || video != null, 'headers only apply to video; give them to the network source.');

    final resolved = source ?? _legacySource(video!, headers);
    if (resolved.unsupportedReason case final reason?) return Future.error(reason);

    return StreamThumbnailPlatform.instance.thumbnailFile(
      source: resolved,
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
  /// Exactly one of [source] and the deprecated [video] must be given. Fails
  /// with an `UNSUPPORTED_SOURCE` [PlatformException] if [source] can't be
  /// opened on this platform.
  static Future<Uint8List> thumbnailData({
    StreamThumbnailSource? source,
    @Deprecated('Use source instead.') String? video,
    @Deprecated('Use StreamThumbnailSource.network(headers:) instead.') Map<String, String>? headers,
    StreamThumbnailFormat imageFormat = StreamThumbnailFormat.png,
    int maxHeight = 0,
    int maxWidth = 0,
    int? timeMs,
    int quality = 10,
  }) {
    if (source == null && video == null) throw ArgumentError('Pass either source or video.');
    assert(source == null || video == null, 'Pass only one of source and video; source wins.');
    assert(headers == null || video != null, 'headers only apply to video; give them to the network source.');

    final resolved = source ?? _legacySource(video!, headers);
    if (resolved.unsupportedReason case final reason?) return Future.error(reason);

    return StreamThumbnailPlatform.instance.thumbnailData(
      source: resolved,
      imageFormat: imageFormat,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      timeMs: timeMs,
      quality: quality,
    );
  }

  static StreamThumbnailSource _legacySource(String video, Map<String, String>? headers) {
    assert(video.isNotEmpty, 'video must not be empty');

    final uri = Uri.tryParse(video);
    if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
      return StreamThumbnailSource.network(uri, headers: headers);
    }
    if (uri != null && uri.isScheme('content')) return StreamThumbnailSource.contentUri(uri);
    return StreamThumbnailSource.file(video);
  }
}
