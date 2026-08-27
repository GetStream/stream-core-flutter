import '../errors/stream_exception.dart';
import '../utils/in_flight_cache.dart';
import 'token_provider.dart';
import 'user_token.dart';

/// A callback invoked whenever the manager caches a newly loaded token.
///
/// Invoked synchronously after the token is cached, before it is returned to
/// the caller that triggered the load.
typedef OnTokenUpdated = void Function(UserToken token);

/// Loads user authentication tokens from a [TokenProvider], and caches the one in use.
///
/// A token is loaded when nothing usable is cached, and reused until it expires or [expireToken],
/// [setTokenProvider] or [reset] invalidates it. Concurrent callers of [getToken] share one load.
///
/// ## Usage
///
/// ```dart
/// final manager = TokenManager(
///   userId: 'user-123',
///   tokenProvider: TokenProvider.static(UserToken(rawJwt)),
/// );
///
/// // Get a token (loads and caches if needed)
/// final token = await manager.getToken();
///
/// // Peek at cached token without loading
/// final cachedToken = manager.peekToken();
///
/// // Expire the cached token
/// manager.expireToken();
/// ```
class TokenManager {
  /// Creates a [TokenManager] for the specified [userId] with the given
  /// [tokenProvider].
  ///
  /// An optional `onTokenUpdated` callback is invoked whenever a loaded token is cached. Not for a
  /// caller served from the cache, and not for a load that [expireToken] or [setTokenProvider]
  /// invalidated while it ran: that token reaches its caller but is never cached.
  TokenManager({
    required String userId,
    required TokenProvider tokenProvider,
    this._onTokenUpdated,
  }) : _identity = (userId: userId, provider: tokenProvider);

  /// Creates a [TokenManager] that manages no user yet.
  ///
  /// [getToken] fails until [setTokenProvider] supplies one. Distinct from a
  /// manager holding an anonymous identity, which is a user that can load a
  /// token; this one has no user at all.
  TokenManager.unconfigured({this._onTokenUpdated}) : _identity = null;

  // A single field rather than two, so a user can never be paired with another user's provider.
  // `null` means no identity is configured.
  ({String userId, TokenProvider provider})? _identity;

  /// The unique identifier of the user whose tokens are managed, or `null` when
  /// no identity is configured.
  ///
  /// Changes when the manager is pointed at another user with
  /// [setTokenProvider], and returns to `null` after [reset].
  String? get userId => _identity?.userId;

  // Invoked after every successful token load.
  final OnTokenUpdated? _onTokenUpdated;

  /// Points this manager at [userId], loading its tokens from [tokenProvider].
  ///
  /// The user and the provider change together, so the manager can never cache one user's token
  /// under another. Expires the cached token and discards a load already in flight. Setting the
  /// identity it already has does nothing; providers are compared with `==`.
  ///
  /// Useful to reuse a manager across users, or to adopt an id that is only known after an
  /// authenticated request, such as a guest's.
  ///
  /// ```dart
  /// // Authenticate anonymously while the real identity is being obtained.
  /// final manager = TokenManager(
  ///   userId: User.anonymousUserId,
  ///   tokenProvider: TokenProvider.static(UserToken.anonymous()),
  /// );
  ///
  /// // Adopt the identity once it is known.
  /// manager.setTokenProvider(
  ///   userId,
  ///   tokenProvider: TokenProvider.static(UserToken(rawToken)),
  /// );
  /// ```
  ///
  /// See also:
  ///
  ///  * [reset], which drops the identity rather than replacing it.
  void setTokenProvider(
    String userId, {
    required TokenProvider tokenProvider,
  }) {
    final identity = (userId: userId, provider: tokenProvider);
    if (_identity == identity) return;

    _identity = identity;

    // The cached token belongs to the previous user and provider, so drop it
    // and let the next `getToken` call load a fresh one.
    expireToken();
  }

  /// Drops the configured identity, returning this manager to the state of
  /// [TokenManager.unconfigured].
  ///
  /// [getToken] fails until [setTokenProvider] supplies an identity again. Consider this when the
  /// user is logging out; to keep the identity and force only a reload, consider [expireToken].
  void reset() {
    _identity = null;
    expireToken();
  }

  // The currently cached token, if any.
  UserToken? _cachedToken;

  // Bumped every time the cached token is invalidated, so a load that started
  // before that point can tell its result is no longer wanted.
  var _generation = 0;

  // Keyed by generation, so an invalidated load is never joined by a later caller.
  final _loads = InFlightCache<int, UserToken>();

  /// Returns the cached token, without loading a new one.
  ///
  /// `null` when nothing is cached, or when the cache was expired.
  UserToken? peekToken() => _cachedToken;

  /// Whether tokens come from a provider that always returns the same one.
  ///
  /// `false` when no identity is configured.
  bool get usesStaticProvider => _identity?.provider is StaticTokenProvider;

  /// Returns the cached token, loading one from the [TokenProvider] when nothing is cached.
  ///
  /// Concurrent callers share one load, and its outcome, success or failure alike. A caller arriving
  /// after [expireToken], [setTokenProvider] or [reset] starts its own load rather than joining the
  /// one those invalidated, so a provider that never returns cannot hold up a caller for the
  /// identity that replaced it.
  ///
  /// Fails with a [StreamAuthenticationException] when no identity is configured, when [reset] runs
  /// while the token is loading, or when the [TokenProvider] fails — whatever the provider threw is
  /// preserved as the exception's `cause`. Fails with an [ArgumentError] when the provider returns
  /// a token that does not belong to the user it was loading for.
  Future<UserToken> getToken() async {
    final cached = peekToken();
    if (cached != null && !_isSpent(cached)) return cached;

    return _loads.run(_generation, _loadAndNotify);
  }

  bool _isSpent(UserToken token) {
    // A static provider has nothing fresher to replace it with.
    if (usesStaticProvider) return false;
    return token.isExpired();
  }

  // Loads a token from the provider and, unless the cached token was
  // invalidated while it loaded, caches it and notifies `onTokenUpdated`.
  Future<UserToken> _loadAndNotify() async {
    final identity = _identity;
    if (identity == null) {
      throw const StreamAuthenticationException(
        message: 'No user is configured, call setTokenProvider before loading a token',
      );
    }

    final loadingFor = identity.userId;
    final loadingGeneration = _generation;
    final updatedToken = await _loadFrom(identity.provider, loadingFor);

    // Both built-in providers check this, but a custom one need not: caching another user's token
    // would authenticate every later request as them.
    if (updatedToken.userId != loadingFor) {
      throw ArgumentError('User ID mismatch: expected "$loadingFor", got "${updatedToken.userId}"');
    }

    // `setTokenProvider` or `expireToken` may have run while this loaded, in which case the token
    // is the one the caller asked to stop using.
    if (loadingGeneration != _generation) {
      // After a `reset` the user is gone, so the token is not returned. After a switch it is: the
      // caller that started as this user may finish as them.
      if (_identity == null) {
        throw const StreamAuthenticationException(message: 'The user was reset while its token was loading');
      }

      return updatedToken;
    }

    _cachedToken = updatedToken;
    _onTokenUpdated?.call(updatedToken);

    return updatedToken;
  }

  Future<UserToken> _loadFrom(TokenProvider provider, String userId) async {
    try {
      return await provider.loadToken(userId);
    } on Exception catch (e, stackTrace) {
      throw StreamAuthenticationException(
        message: 'The token provider failed to load a token for user "$userId"',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Expires the currently cached token.
  ///
  /// Clears the cached token, forcing the next call to [getToken] to
  /// load a fresh token from the provider. This is useful when a token
  /// becomes invalid or needs to be refreshed.
  ///
  /// A load already in flight is discarded too, so it cannot cache the token this call asked to
  /// stop using.
  void expireToken() {
    _generation++;
    _cachedToken = null;
  }
}
