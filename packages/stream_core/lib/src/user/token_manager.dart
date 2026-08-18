import 'package:synchronized/extension.dart';

import 'token_provider.dart';
import 'user_token.dart';

/// A callback invoked whenever the manager caches a newly loaded token.
///
/// The manager awaits the callback before returning the token to the caller that triggered the load.
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
/// // Force a reload from the provider
/// final freshToken = await manager.refreshToken();
///
/// // Peek at cached token without loading
/// final cachedToken = manager.peekToken();
///
/// // Expire the cached token
/// manager.expireToken();
/// ```
class TokenManager {
  /// Creates a [TokenManager] for the specified [userId] with the given [_tokenProvider].
  ///
  /// The [userId] identifies the user for whom tokens will be managed.
  /// The [_tokenProvider] is used to load tokens when needed.
  ///
  /// An optional [initialToken] seeds the cache, so the first [getToken] call
  /// returns it without contacting the provider. Once the token is expired
  /// via [expireToken] (or reloaded via [refreshToken]), subsequent loads go
  /// through the provider.
  ///
  /// An optional [onTokenUpdated] callback is invoked after every successful
  /// token load. It is not invoked for the [initialToken] or for callers
  /// served from the cache.
  TokenManager({
    required this.userId,
    required this._tokenProvider,
    UserToken? initialToken,
    this.onTokenUpdated,
  }) : _cachedToken = initialToken;

  /// The unique identifier of the user whose tokens are managed.
  final String userId;

  /// Invoked after every successful token load.
  final OnTokenUpdated? onTokenUpdated;

  // The provider used to load tokens when needed.
  TokenProvider _tokenProvider;

  /// Replaces the provider used to load tokens.
  ///
  /// Expires the cached token when the provider changes, so the next
  /// [getToken] call loads a fresh token from the new provider.
  set tokenProvider(TokenProvider provider) {
    if (_tokenProvider == provider) return;
    _tokenProvider = provider;
    expireToken();
  }

  // The currently cached token, if any.
  UserToken? _cachedToken;

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

  /// Forces a reload from the provider, bypassing the cache.
  Future<UserToken> refreshToken() {
    final snapshot = _cachedToken;
    return synchronized(() {
      final currentToken = _cachedToken;
      if (snapshot != currentToken && currentToken != null) {
        return Future.value(currentToken);
      }

      return _loadAndNotify();
    });
  }

  // Loads a token from the provider, caches it, and notifies the
  // [onTokenUpdated] callback.
  Future<UserToken> _loadAndNotify() async {
    final updatedToken = await _tokenProvider.loadToken(userId);
    _cachedToken = updatedToken;
    await onTokenUpdated?.call(updatedToken);
    return updatedToken;
  }

  /// Expires the currently cached token.
  ///
  /// Clears the cached token, forcing the next call to [getToken] to
  /// load a fresh token from the provider. This is useful when a token
  /// becomes invalid or needs to be refreshed.
  void expireToken() => _cachedToken = null;
}
