import 'package:synchronized/extension.dart';

import '../errors/client_exception.dart';
import 'token_provider.dart';
import 'user_token.dart';

/// A callback invoked whenever the manager caches a newly loaded token.
///
/// Invoked synchronously after the token is cached, before it is returned to
/// the caller that triggered the load. Throwing from it surfaces to that
/// caller, even though the token was loaded and cached successfully.
typedef OnTokenUpdated = void Function(UserToken token);

/// Manages user authentication tokens with caching and thread-safe access.
///
/// Provides token caching and automatic loading for user authentication tokens.
/// Ensures thread-safe access to tokens and handles token lifecycle efficiently.
///
/// ## Usage
///
/// ```dart
/// final manager = TokenManager(
///   userId: 'user-123',
///   tokenProvider: TokenProvider.static(UserToken('jwt-token')),
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
  /// Creates a [TokenManager] for the specified `userId` with the given
  /// `tokenProvider`.
  ///
  /// The `userId` identifies the user for whom tokens will be managed.
  /// The `tokenProvider` is used to load tokens when needed.
  ///
  /// An optional `onTokenUpdated` callback is invoked after every successful
  /// token load. It is not invoked for callers served from the cache.
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

  // The user being managed and the provider that loads their tokens.
  //
  // A single field rather than two, so the two can never disagree: a user
  // without a provider cannot load, and a provider without a user has nothing
  // to load for. `null` means no identity is configured.
  ({String userId, TokenProvider provider})? _identity;

  /// The unique identifier of the user whose tokens are managed, or `null` when
  /// no identity is configured.
  ///
  /// Changes when the manager is pointed at another user with
  /// [setTokenProvider], and returns to `null` after [reset].
  String? get userId => _identity?.userId;

  // Invoked after every successful token load.
  final OnTokenUpdated? _onTokenUpdated;

  /// Points this manager at `userId`, loading its tokens from `tokenProvider`.
  ///
  /// The user and the provider change together, so the manager can never cache
  /// one user's token under another. Expires the cached token, and discards a
  /// load already in flight, so the next [getToken] call loads a fresh one for
  /// the new user.
  ///
  /// To reuse a manager across users, or to authenticate as a user whose
  /// identity is only known after an authenticated request — a guest, whose id
  /// and token are both issued in exchange for an anonymous one — consider:
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
  /// Re-setting the identity this manager already has does nothing: expiring
  /// the cached token would send the next caller to the provider for no reason.
  /// The provider is compared by instance, so this only applies when the same
  /// one is passed again.
  void setTokenProvider(
    String userId, {
    required TokenProvider tokenProvider,
  }) {
    // Compared with `identical` rather than `==`: a provider defines its own
    // equality, and one that calls itself equal to another would keep the
    // provider and the cached token this call means to replace.
    final unchanged = userId == this.userId && identical(tokenProvider, _identity?.provider);
    if (unchanged) return;

    _identity = (userId: userId, provider: tokenProvider);

    // The cached token belongs to the previous user and provider, so drop it
    // and let the next `getToken` call load a fresh one.
    expireToken();
  }

  /// Drops the configured identity, returning this manager to the state of
  /// [TokenManager.unconfigured].
  ///
  /// [getToken] fails until [setTokenProvider] supplies an identity again. Use
  /// this when the user is going away for good; to keep the identity and only
  /// force a reload, use [expireToken].
  void reset() {
    _identity = null;
    expireToken();
  }

  // The currently cached token, if any.
  UserToken? _cachedToken;

  // Bumped every time the cached token is invalidated, so a load that started
  // before that point can tell its result is no longer wanted.
  var _generation = 0;

  /// Returns the currently cached token without loading a new one.
  ///
  /// Returns the cached [UserToken] if available, or null if no token
  /// is currently cached or if the token has been expired.
  UserToken? peekToken() => _cachedToken;

  /// Whether this manager uses a static token provider.
  ///
  /// Returns true if the token provider is static (doesn't refresh tokens),
  /// false if it's dynamic (fetches fresh tokens on each call) or if no
  /// identity is configured.
  bool get usesStaticProvider => _identity?.provider is StaticTokenProvider;

  /// Gets a valid token for the user, loading one if necessary.
  ///
  /// Returns the cached token if available, otherwise loads a new token
  /// from the [TokenProvider] and caches it for future use. This method
  /// is thread-safe and ensures only one token loading operation occurs
  /// at a time.
  ///
  /// Returns a [Future] that resolves to a [UserToken] for the user.
  ///
  /// Fails with a [ClientException] when no identity is configured, either
  /// because the manager was created with [TokenManager.unconfigured] or
  /// because [reset] dropped the previous one, and when [reset] runs while the
  /// token is loading.
  ///
  /// Loads are serialised, so a provider that never returns blocks every later
  /// caller — including one for a different user configured by
  /// [setTokenProvider] in the meantime.
  Future<UserToken> getToken() {
    final cached = _cachedToken;
    if (cached != null) return Future.value(cached);

    return synchronized(() {
      final currentToken = _cachedToken;
      if (currentToken != null) return Future.value(currentToken);

      return _loadAndNotify();
    });
  }

  // Loads a token from the provider and, unless the cached token was
  // invalidated while it loaded, caches it and notifies `onTokenUpdated`.
  Future<UserToken> _loadAndNotify() async {
    final identity = _identity;
    if (identity == null) {
      throw ClientException(message: 'No user is configured, call setTokenProvider before loading a token');
    }

    final loadingFor = identity.userId;
    final loadingGeneration = _generation;
    final updatedToken = await identity.provider.loadToken(loadingFor);

    // Both built-in providers check this, but a custom one is under no
    // obligation to, and caching a token for another user would authenticate
    // every later request as them.
    if (updatedToken.userId != loadingFor) {
      throw ArgumentError(
        'User ID mismatch: expected "$loadingFor", got "${updatedToken.userId}"',
      );
    }

    // `setTokenProvider` or `expireToken` may have run while this loaded, in
    // which case the token is the one the caller asked to stop using.
    if (loadingGeneration != _generation) {
      // A `reset` means the user is gone, so nothing may go out as them. A
      // switch is different: the request that started as this user may finish
      // as them.
      if (_identity == null) {
        throw ClientException(message: 'The user was reset while its token was loading');
      }

      return updatedToken;
    }

    _cachedToken = updatedToken;
    _onTokenUpdated?.call(updatedToken);

    return updatedToken;
  }

  /// Expires the currently cached token.
  ///
  /// Clears the cached token, forcing the next call to [getToken] to
  /// load a fresh token from the provider. This is useful when a token
  /// becomes invalid or needs to be refreshed.
  ///
  /// A load already in flight is discarded too, rather than caching the token
  /// this call asked to stop using.
  void expireToken() {
    _generation++;
    _cachedToken = null;
  }
}
