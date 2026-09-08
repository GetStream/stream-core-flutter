import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';

import 'messages.g.dart';
import 'stream_thumbnail_format.dart';
import 'stream_thumbnail_platform.dart';

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
    required String video,
    required Map<String, String>? headers,
    String? thumbnailPath,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    return ThumbnailRequest(
      video: video,
      headers: headers,
      thumbnailPath: thumbnailPath,
      format: _wireFormat(imageFormat),
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      timeMs: _getTimeMsValue(timeMs),
      quality: quality,
    );
  }

  @override
  Future<List<XFile>> thumbnailFiles({
    required List<String> videos,
    required Map<String, String>? headers,
    required String? thumbnailPath,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    final results = <XFile>[];

    for (final video in videos) {
      results.add(
        await thumbnailFile(
          video: video,
          headers: headers,
          thumbnailPath: thumbnailPath,
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
    required String video,
    required Map<String, String>? headers,
    required String? thumbnailPath,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    final path = await _hostApi.thumbnailFile(
      _request(
        video: video,
        headers: headers,
        thumbnailPath: thumbnailPath,
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
    required String video,
    required Map<String, String>? headers,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    return _hostApi.thumbnailData(
      _request(
        video: video,
        headers: headers,
        imageFormat: imageFormat,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        timeMs: timeMs,
        quality: quality,
      ),
    );
  }
}
