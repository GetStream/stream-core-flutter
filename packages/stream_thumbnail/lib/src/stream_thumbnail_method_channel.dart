import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';

import 'messages.g.dart';
import 'stream_thumbnail_format.dart';
import 'stream_thumbnail_platform.dart';
import 'stream_thumbnail_source.dart';

/// An implementation of [StreamThumbnailPlatform] that uses a Pigeon-generated
/// platform channel.
class MethodChannelStreamThumbnail extends StreamThumbnailPlatform {
  /// Constructs a [MethodChannelStreamThumbnail].
  ///
  /// [hostApi] is exposed for tests to inject a mock of the generated
  /// [StreamThumbnailHostApi].
  MethodChannelStreamThumbnail({StreamThumbnailHostApi? hostApi}) : _hostApi = hostApi ?? StreamThumbnailHostApi();

  final StreamThumbnailHostApi _hostApi;

  int _getTimeMsValue(int? timeMs) => defaultTargetPlatform == TargetPlatform.android ? timeMs ?? -1 : timeMs ?? 0;

  ThumbnailFormat _wireFormat(StreamThumbnailFormat format) {
    switch (format) {
      case StreamThumbnailFormat.jpeg:
        return ThumbnailFormat.jpeg;
      case StreamThumbnailFormat.png:
        return ThumbnailFormat.png;
      case StreamThumbnailFormat.webp:
        return ThumbnailFormat.webp;
    }
  }

  ThumbnailRequest _request({
    required StreamThumbnailSource source,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    return ThumbnailRequest(
      video: source.location,
      sourceKind: switch (source.kind) {
        StreamThumbnailSourceKind.network => ThumbnailSourceKind.network,
        StreamThumbnailSourceKind.file => ThumbnailSourceKind.file,
        StreamThumbnailSourceKind.contentUri => ThumbnailSourceKind.contentUri,
      },
      headers: source.headers,
      format: _wireFormat(imageFormat),
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      timeMs: _getTimeMsValue(timeMs),
      quality: quality,
    );
  }

  @override
  Future<List<XFile>> thumbnailFiles({
    required List<StreamThumbnailSource> sources,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    final results = <XFile>[];

    for (final source in sources) {
      results.add(
        await thumbnailFile(
          source: source,
          imageFormat: imageFormat,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          timeMs: timeMs,
          quality: quality,
        ),
      );
    }

    return results;
  }

  @override
  Future<XFile> thumbnailFile({
    required StreamThumbnailSource source,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    final path = await _hostApi.thumbnailFile(
      _request(
        source: source,
        imageFormat: imageFormat,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        timeMs: timeMs,
        quality: quality,
      ),
    );
    return XFile(path);
  }

  @override
  Future<Uint8List> thumbnailData({
    required StreamThumbnailSource source,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    return _hostApi.thumbnailData(
      _request(
        source: source,
        imageFormat: imageFormat,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        timeMs: timeMs,
        quality: quality,
      ),
    );
  }
}
