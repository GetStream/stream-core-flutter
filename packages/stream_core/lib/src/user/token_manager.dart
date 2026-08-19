import 'package:synchronized/extension.dart';

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
    required this._userId,
    required this._tokenProvider,
    this._onTokenUpdated,
  });

  /// The unique identifier of the user whose tokens are managed.
  ///
  /// Changes when the manager is pointed at another user with
  /// [setTokenProvider].
  String get userId => _userId;
  String _userId;

  // The provider used to load tokens when needed.
  TokenProvider _tokenProvider;

  // Invoked after every successful token load.
  final OnTokenUpdated? _onTokenUpdated;

  /// Points this manager at `userId`, loading its tokens from `tokenProvider`.
  ///
  /// The user and the provider change together, so the manager can never cache
  /// one user's token under another. Expires the cached token, and discards a
  /// load already in flight, so the next [getToken] call loads a fresh one for
  /// the new user.
  ///
  /// Use this to reuse a manager across users, and when a user's identity is
  /// only known after an authenticated request — a guest, whose id and token
  /// are both issued in exchange for an anonymous one:
  ///
  /// ```dart
  /// // Authenticate anonymously while the real identity is being obtained.
  /// final manager = TokenManager(
  ///   userId: UserToken.anonymousUserId,
  ///   tokenProvider: TokenProvider.static(UserToken.anonymous()),
  /// );
  ///
  /// // Adopt the identity once it is known.
  /// manager.setTokenProvider(
  ///   userId,
  ///   tokenProvider: TokenProvider.static(UserToken(rawToken)),
  /// );
  /// ```
  void setTokenProvider(
    String userId, {
    required TokenProvider tokenProvider,
  }) {
    _userId = userId;
    _tokenProvider = tokenProvider;

    // The cached token belongs to the previous user and provider, so drop it
    // and let the next `getToken` call load a fresh one.
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
  /// false if it's dynamic (fetches fresh tokens on each call).
  bool get usesStaticProvider => _tokenProvider is StaticTokenProvider;

  /// Gets a valid token for the user, loading one if necessary.
  ///
  /// Returns the cached token if available, otherwise loads a new token
  /// from the [TokenProvider] and caches it for future use. This method
  /// is thread-safe and ensures only one token loading operation occurs
  /// at a time.
  ///
  /// Returns a [Future] that resolves to a [UserToken] for the user.
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
    final loadingFor = _userId;
    final loadingGeneration = _generation;
    final updatedToken = await _tokenProvider.loadToken(loadingFor);

    // Only cache the token if nothing invalidated the cache while it loaded.
    // `setTokenProvider` or `expireToken` may have run, which means this token
    // is the one the caller asked us to stop using.
    if (loadingGeneration != _generation) return updatedToken;

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
