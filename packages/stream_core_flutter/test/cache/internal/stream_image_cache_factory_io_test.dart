import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';
// Imported directly (rather than through the `stream_image_cache.dart`
// conditional import) so this test always compiles the IO factory against the
// real IO `DefaultCacheManager`.
import 'package:stream_core_flutter/src/cache/internal/stream_image_cache_factory_io.dart';

void main() {
  group('createStreamCacheManager (IO)', () {
    // Signature-drift guard. `stream_image_cache_factory_io.dart` passes
    // `cleanupStrategy` and `cacheDirectoryProvider`, which exist only on the IO
    // `DefaultCacheManager`, behind `// ignore: undefined_named_parameter` — the
    // analyzer resolves the package's conditional export against the stub variant
    // and cannot see those parameters. That suppression means `melos run analyze`
    // cannot catch a future `cached_network_image_ce` release that renames or
    // removes either parameter. On the VM, however, this test compiles against
    // the real IO constructor, so such a break fails the test suite here instead
    // of shipping.
    //
    // Construction is filesystem-free: `DefaultCacheManager` only touches the
    // temp dir / Hive box lazily on the first fetch, so this test needs no test
    // binding and never writes to disk.
    test('builds the shared cache manager on IO', () {
      expect(createStreamCacheManager(), isA<BaseCacheManager>());
    });
  });
}
