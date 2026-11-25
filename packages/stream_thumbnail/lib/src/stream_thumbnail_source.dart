import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'stream_thumbnail.dart';

/// Where a [StreamThumbnailSource] reads its video from.
@internal
enum StreamThumbnailSourceKind { network, file, contentUri }

/// The video a thumbnail is generated from.
///
/// [StreamThumbnailSource.network] fetches an `http` or `https` URL,
/// [StreamThumbnailSource.file] reads a video stored on this device, and
/// [StreamThumbnailSource.contentUri] reads from an Android content provider.
///
/// {@tool snippet}
/// Thumbnail a video attachment, preferring the local copy when there is one:
///
/// ```dart
/// final source = localPath != null
///     ? StreamThumbnailSource.file(localPath)
///     : StreamThumbnailSource.network(Uri.parse(videoUrl));
///
/// final bytes = await StreamThumbnail.thumbnailData(source: source);
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamThumbnail.thumbnailData], which generates the thumbnail as bytes.
///  * [StreamThumbnail.thumbnailFile], which writes the thumbnail to a file.
@immutable
final class StreamThumbnailSource {
  /// A video fetched from [url].
  ///
  /// Only `http` and `https` URLs with a host are fetched; generating a
  /// thumbnail for any other URL fails with an `UNSUPPORTED_SOURCE`
  /// [PlatformException].
  ///
  /// [headers] are sent with the request, except on Windows, which cannot
  /// attach them.
  StreamThumbnailSource.network(Uri url, {Map<String, String>? headers})
    : kind = StreamThumbnailSourceKind.network,
      location = url.toString(),
      headers = headers == null ? null : Map<String, String>.unmodifiable(headers);

  /// A video stored on this device at [path].
  ///
  /// [path] is a file system path or a `file:` URI. On web, where there is no
  /// file system, it is the object URL of the video, such as the `path` of a
  /// picked `XFile`.
  ///
  /// Generating a thumbnail fails with an `UNSUPPORTED_SOURCE`
  /// [PlatformException] for a URL naming a host, such as an `https` URL, and
  /// on Windows for anything other than an absolute path on a local drive.
  StreamThumbnailSource.file(String path)
    : assert(path.isNotEmpty, 'path must not be empty'),
      kind = StreamThumbnailSourceKind.file,
      location = path,
      headers = null;

  /// A video an Android content provider serves at [uri].
  ///
  /// Only supported on Android; generating a thumbnail on any other platform,
  /// or for a URI whose scheme isn't `content`, fails with an
  /// `UNSUPPORTED_SOURCE` [PlatformException].
  StreamThumbnailSource.contentUri(Uri uri)
    : kind = StreamThumbnailSourceKind.contentUri,
      location = uri.toString(),
      headers = null;

  /// Where the video is read from.
  @internal
  final StreamThumbnailSourceKind kind;

  /// The URL, path or URI of the video, as the platform receives it.
  @internal
  final String location;

  /// The HTTP headers sent when fetching a [StreamThumbnailSource.network]
  /// video, or `null` for other sources.
  @internal
  final Map<String, String>? headers;

  /// Why this source can't be opened on any platform, or `null` if it can.
  @internal
  PlatformException? get unsupportedReason {
    final uri = Uri.tryParse(location);
    return switch (kind) {
      StreamThumbnailSourceKind.network
          when uri == null || !(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty =>
        PlatformException(code: 'UNSUPPORTED_SOURCE', message: 'A network video must be an http or https URL.'),
      StreamThumbnailSourceKind.file when uri != null && uri.hasAuthority && !uri.isScheme('file') => PlatformException(
        code: 'UNSUPPORTED_SOURCE',
        message: 'A file video must be a path on this device.',
      ),
      StreamThumbnailSourceKind.contentUri when uri == null || !uri.isScheme('content') => PlatformException(
        code: 'UNSUPPORTED_SOURCE',
        message: 'A content video must be a content URI.',
      ),
      StreamThumbnailSourceKind.network ||
      StreamThumbnailSourceKind.file ||
      StreamThumbnailSourceKind.contentUri => null,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StreamThumbnailSource &&
        other.kind == kind &&
        other.location == location &&
        mapEquals(other.headers, headers);
  }

  @override
  int get hashCode => Object.hash(
    kind,
    location,
    headers == null ? null : Object.hashAllUnordered(headers!.entries.map((e) => Object.hash(e.key, e.value))),
  );

  @override
  String toString() {
    final uri = Uri.tryParse(location);
    final shown = uri != null && uri.hasAuthority ? '${uri.scheme}://${uri.host}${uri.path}' : location;
    return 'StreamThumbnailSource.${kind.name}($shown)';
  }
}
