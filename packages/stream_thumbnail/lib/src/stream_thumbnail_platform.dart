// Platform-interface boilerplate (token, default instance, and the
// UnimplementedError stubs that platform implementations override).
// coverage:ignore-file
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'stream_thumbnail_format.dart';
import 'stream_thumbnail_method_channel.dart';

/// The interface that platform-specific implementations of
/// `stream_thumbnail` must implement.
abstract class StreamThumbnailPlatform extends PlatformInterface {
  /// Constructs a StreamThumbnailPlatform.
  StreamThumbnailPlatform() : super(token: _token);

  static final _token = Object();

  static StreamThumbnailPlatform _instance = MethodChannelStreamThumbnail();

  /// The default instance of [StreamThumbnailPlatform] to use.
  ///
  /// Defaults to [MethodChannelStreamThumbnail].
  static StreamThumbnailPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StreamThumbnailPlatform] when
  /// they register themselves.
  static set instance(StreamThumbnailPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Generates a thumbnail file for each of the given `videos`.
  Future<List<XFile>> thumbnailFiles({
    required List<String> videos,
    required Map<String, String>? headers,
    required String? thumbnailPath,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    throw UnimplementedError('thumbnailFiles() has not been implemented.');
  }

  /// Generates a thumbnail file for the given `video`.
  Future<XFile> thumbnailFile({
    required String video,
    required Map<String, String>? headers,
    required String? thumbnailPath,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    throw UnimplementedError('thumbnailFile() has not been implemented.');
  }

  /// Generates a thumbnail for the given `video` as in-memory bytes.
  Future<Uint8List> thumbnailData({
    required String video,
    required Map<String, String>? headers,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    throw UnimplementedError('thumbnailData() has not been implemented.');
  }
}
