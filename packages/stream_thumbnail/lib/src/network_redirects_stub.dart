import 'stream_thumbnail_source.dart';

/// Returns [source] unchanged, where the platform follows redirects itself.
Future<StreamThumbnailSource> resolveRedirects(StreamThumbnailSource source) async => source;
