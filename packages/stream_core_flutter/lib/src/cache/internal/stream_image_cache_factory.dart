import 'package:cached_network_image_ce/cached_network_image.dart';

/// Builds the shared image cache manager for the current platform.
///
/// This is the default (non-IO) implementation, used on web and any platform
/// where `DefaultCacheManager` does not accept a custom `CleanupStrategy` or
/// `cacheDirectoryProvider`.
///
/// Unlike the IO variant, this returns the library's own shared
/// [CachedNetworkImageProvider.defaultCacheManager] rather than a fresh
/// `DefaultCacheManager()`. On web there is no cache directory to namespace, so
/// every `DefaultCacheManager` opens the same fixed-name IndexedDB store — the
/// isolation the IO variant achieves is impossible here. Constructing a second
/// manager would only put two independent instances (each with its own Hive
/// handle) on that one store; reusing the library default keeps web behaviour
/// identical to a plain `CachedNetworkImage` and avoids that duplication. The
/// cache keeps the library's default size limits and eviction ordering (TTL).
///
/// The IO implementation in `stream_image_cache_factory_io.dart` selects
/// `LruCleanupStrategy` and an isolated directory; the correct file is chosen
/// via a conditional import in `stream_image_cache.dart`.
BaseCacheManager createStreamCacheManager() => CachedNetworkImageProvider.defaultCacheManager;
