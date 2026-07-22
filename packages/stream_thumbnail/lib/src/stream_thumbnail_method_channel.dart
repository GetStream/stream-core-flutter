import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'stream_thumbnail_format.dart';
import 'stream_thumbnail_platform.dart';

/// An implementation of [StreamThumbnailPlatform] that uses method
/// channels.
class MethodChannelStreamThumbnail extends StreamThumbnailPlatform {
  /// The method channel used to interact with the native platform.
  static const methodChannel = MethodChannel(
    'plugins.getstream.io/stream_thumbnail',
  );

  int _getTimeMsValue(int? timeMs) => defaultTargetPlatform == TargetPlatform.android ? timeMs ?? -1 : timeMs ?? 0;

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
    final reqMap = <String, dynamic>{
      'video': video,
      'headers': headers,
      'path': thumbnailPath,
      'format': imageFormat.index,
      'maxh': maxHeight,
      'maxw': maxWidth,
      'timeMs': _getTimeMsValue(timeMs),
      'quality': quality,
    };

    final path = await methodChannel.invokeMethod<String>('file', reqMap);
    return XFile(path!);
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
  }) async {
    final reqMap = <String, dynamic>{
      'video': video,
      'headers': headers,
      'format': imageFormat.index,
      'maxh': maxHeight,
      'maxw': maxWidth,
      'timeMs': _getTimeMsValue(timeMs),
      'quality': quality,
    };

    final result = await methodChannel.invokeMethod<Uint8List>('data', reqMap);
    return result!;
  }
}
