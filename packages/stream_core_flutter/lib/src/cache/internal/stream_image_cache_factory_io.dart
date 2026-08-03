import 'dart:io';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Builds the shared image cache manager on IO platforms.
///
/// Uses [LruCleanupStrategy] so that, once the cache exceeds the library's
/// default object limit, the least-recently-used entries are evicted first.
///
/// The manager's base directory is pinned to a dedicated `stream_image_cache`
/// folder inside the app-scoped temporary directory ([getTemporaryDirectory]);
/// the library then nests its own `cached_network_image_ce` folder under that,
/// so files actually land at `<temp>/stream_image_cache/cached_network_image_ce`.
/// A bare `DefaultCacheManager()` instead stores its files and Hive metadata box
/// under `<temp>/cached_network_image_ce` — the same location the library's
/// package-default manager (`CachedNetworkImageProvider.defaultCacheManager`)
/// uses. Two managers sharing that directory keep separate, mutually-unaware
/// metadata boxes, so each one's background orphan sweep can delete the other's
/// cached files (see the warning in the library's own
/// `default_cache_manager.dart`). Storing this manager under a dedicated
/// sub-directory keeps it isolated from the package default — and from any
/// other `cached_network_image_ce` manager that leaves the base temp directory
/// untouched.
///
/// The base is resolved via `path_provider` rather than `Directory.systemTemp`
/// so the cache lands in the platform's app-scoped temp location (which is not
/// always where the raw OS temp root points on Android/desktop).
///
/// `cleanupStrategy` and `cacheDirectoryProvider` exist only on the IO
/// `DefaultCacheManager`, which is why this variant is isolated behind a
/// conditional import.
BaseCacheManager createStreamCacheManager() {
  // These named parameters exist only on the IO `DefaultCacheManager`. When the
  // analyzer resolves the package's conditional export against the
  // platform-agnostic (stub) variant it cannot see them, but this file is only
  // ever compiled for IO targets, where they are valid. This is a permanent
  // consequence of the conditional export, not a temporary workaround.
  return DefaultCacheManager(
    // ignore: undefined_named_parameter
    cleanupStrategy: const LruCleanupStrategy(),
    // ignore: undefined_named_parameter
    cacheDirectoryProvider: () async {
      final tempDir = await getTemporaryDirectory();
      return Directory(p.join(tempDir.path, 'stream_image_cache'));
    },
  );
}
