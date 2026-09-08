import 'package:cached_network_image_ce/cached_network_image.dart' show BaseCacheManager;

import 'stream_image_cache_factory.dart' if (dart.library.io) 'stream_image_cache_factory_io.dart';

/// Stream-owned shared image cache backing every `StreamNetworkImage`.
///
/// A single [BaseCacheManager] (from `cached_network_image_ce`) is shared by
/// all network images so the whole SDK caches through one place. On native
/// platforms it evicts least-recently-used entries first once the cache is
/// full; on web it keeps the same size limit but falls back to the library's
/// default eviction ordering. Cache size and stale period use the underlying
/// library defaults.
///
/// This is an internal implementation detail of `StreamNetworkImage` and is
/// not part of the package's public API.
final class StreamImageCache {
  StreamImageCache._();

  /// The shared cache manager, created lazily on first access.
  ///
  /// Dart initializes `static final` fields lazily, so the underlying
  /// `DefaultCacheManager` (which touches the temp dir / Hive) is only built
  /// when the first image actually loads.
  static final BaseCacheManager manager = createStreamCacheManager();
}
