import 'package:pigeon/pigeon.dart';

// `swiftOut` is intentionally omitted here: iOS and macOS each need their own
// physical copy under their own SwiftPM package root (SPM rejects a target
// `path:` that escapes its package root), so it's passed explicitly via
// `--swift_out` for each platform in melos.yaml's `generate:pigeon` script
// instead of being fixed to a single path here.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut: 'android/src/main/kotlin/io/getstream/stream_thumbnail/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'io.getstream.stream_thumbnail'),
    cppHeaderOut: 'windows/pigeon/messages.g.h',
    cppSourceOut: 'windows/pigeon/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'stream_thumbnail_windows', headerIncludePath: 'messages.g.h'),
    gobjectHeaderOut: 'linux/pigeon/messages.g.h',
    gobjectSourceOut: 'linux/pigeon/messages.g.cc',
    gobjectOptions: GObjectOptions(module: 'StreamThumbnail', headerIncludePath: 'messages.g.h'),
    dartPackageName: 'stream_thumbnail',
  ),
)
/// Wire representation of the image format for a generated thumbnail.
enum ThumbnailFormat { jpeg, png, webp }

/// Where [ThumbnailRequest.video] is read from, and so how it may be opened.
///
/// `network` must only be fetched over http or https, `file` must only be
/// opened as a local path, and `contentUri` only through an Android content
/// resolver.
enum ThumbnailSourceKind { network, file, contentUri }

/// A single thumbnail generation request sent to the native platform.
class ThumbnailRequest {
  ThumbnailRequest({
    required this.video,
    required this.sourceKind,
    required this.headers,
    required this.format,
    required this.maxHeight,
    required this.maxWidth,
    required this.timeMs,
    required this.quality,
  });

  final String video;
  final ThumbnailSourceKind sourceKind;
  final Map<String, String>? headers;
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
