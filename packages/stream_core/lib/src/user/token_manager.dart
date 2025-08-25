import 'package:synchronized/extension.dart';

import 'token_provider.dart';
import 'user_token.dart';

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
  /// Creates a [TokenManager] for the specified [userId] with the given [tokenProvider].
  ///
  /// The [userId] identifies the user for whom tokens will be managed.
  /// The [tokenProvider] is used to load tokens when needed.
  TokenManager({
    required this.userId,
    required TokenProvider tokenProvider,
  }) : _tokenProvider = tokenProvider;

  /// The unique identifier of the user whose tokens are managed.
  final String userId;

  // The provider used to load tokens when needed.
  final TokenProvider _tokenProvider;
  set tokenProvider(TokenProvider provider) {
    // If the provider changes, expire the current token.
    if (_tokenProvider != provider) expireToken();
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
  Future<UserToken> getToken() async {
    final snapshot = _cachedToken;
    return synchronized(() async {
      // If the snapshot is no longer equal to the cached token, it means
      // that the token has been updated by another thread, so we use the
      // updated value.
      final currentToken = _cachedToken;
      if (snapshot != currentToken && currentToken != null) {
        return currentToken;
      }

      // Otherwise, we load a new token from the provider and cache it.
      final updatedToken = await _tokenProvider.loadToken(userId);
      _cachedToken = updatedToken;
      return updatedToken;
    });
  }

  /// Expires the currently cached token.
  ///
  /// Clears the cached token, forcing the next call to [getToken] to
  /// load a fresh token from the provider. This is useful when a token
  /// becomes invalid or needs to be refreshed.
  void expireToken() => _cachedToken = null;
}
