import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut: 'android/src/main/kotlin/io/getstream/stream_thumbnail/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'io.getstream.stream_thumbnail'),
    swiftOut: 'ios/stream_thumbnail/Sources/stream_thumbnail/Messages.g.swift',
    dartPackageName: 'stream_thumbnail',
  ),
)
/// Wire representation of the image format for a generated thumbnail.
enum ThumbnailFormat { jpeg, png, webp }

/// A single thumbnail generation request sent to the native platform.
class ThumbnailRequest {
  ThumbnailRequest({
    required this.video,
    required this.headers,
    required this.thumbnailPath,
    required this.format,
    required this.maxHeight,
    required this.maxWidth,
    required this.timeMs,
    required this.quality,
  });

  final String video;
  final Map<String, String>? headers;
  final String? thumbnailPath;
  final ThumbnailFormat format;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;
}

@HostApi()
abstract class StreamThumbnailHostApi {
  /// Generates a thumbnail for [ThumbnailRequest.video] and returns its bytes.
  @async
  Uint8List thumbnailData(ThumbnailRequest request);

  /// Generates a thumbnail for [ThumbnailRequest.video] and returns the path
  /// it was written to.
  @async
  String thumbnailFile(ThumbnailRequest request);
}
