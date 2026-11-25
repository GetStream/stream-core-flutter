// Platform-interface boilerplate (token, default instance, and the
// UnimplementedError stubs that platform implementations override).
// coverage:ignore-file
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'stream_thumbnail_format.dart';
import 'stream_thumbnail_method_channel.dart';
import 'stream_thumbnail_source.dart';

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

  /// Generates a thumbnail file for each of the given `sources`.
  Future<List<XFile>> thumbnailFiles({
    required List<StreamThumbnailSource> sources,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    throw UnimplementedError('thumbnailFiles() has not been implemented.');
  }

  /// Generates a thumbnail file for the given `source`.
  Future<XFile> thumbnailFile({
    required StreamThumbnailSource source,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    throw UnimplementedError('thumbnailFile() has not been implemented.');
  }

  /// Generates a thumbnail for the given `source` as in-memory bytes.
  Future<Uint8List> thumbnailData({
    required StreamThumbnailSource source,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    throw UnimplementedError('thumbnailData() has not been implemented.');
  }
}
