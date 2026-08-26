import 'dart:async';

/// Coalesces concurrent identical async calls by sharing a single in-flight
/// [Future] keyed by [K].
///
/// When [run] is called and no [Future] is in flight for the key, the work
/// closure runs and its [Future] is cached. Concurrent callers passing the
/// same key receive the cached [Future] and share its eventual outcome —
/// both success and failure, including a synchronous throw from the work.
/// Sequential callers arriving after the [Future] settles see an empty cache
/// and start fresh.
///
/// Sharing failures is intentional: falling through to a fresh call on
/// error would defeat the dedup precisely when it matters most (e.g., a
/// rate-limit storm), turning one rejected request into N.
///
/// This is the single-flight pattern, after Go's `golang.org/x/sync/singleflight`.
/// `AsyncCache.ephemeral` from `package:async` covers the single-key case, without
/// the keying or the capture of a synchronous throw.
class InFlightCache<K, V> {
  final _inFlight = <K, Future<V>>{};

  /// Returns the in-flight [Future] for [key] if one exists, otherwise runs
  /// [work], caches its [Future], and frees the slot when it settles.
  Future<V> run(K key, Future<V> Function() work) {
    if (_inFlight[key] case final existing?) return existing;

    final future = Future.sync(work);
    _inFlight[key] = future;
    future.whenComplete(() => _inFlight.remove(key)).ignore();

    return future;
  }
}
