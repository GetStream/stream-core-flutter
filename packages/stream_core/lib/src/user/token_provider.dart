import 'user_token.dart';

/// A provider for loading user authentication tokens.
///
/// Defines the interface for token providers that can load [UserToken] instances
/// for users. Supports static tokens (pre-defined JWT or anonymous tokens) and
/// dynamic JWT tokens (loaded via custom functions).
///
/// ## Usage
///
/// Create a static token provider:
/// ```dart
/// final jwtToken = UserToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
/// final provider = TokenProvider.static(jwtToken);
/// final token = await provider.loadToken('user-123');
/// ```
///
/// Create a dynamic token provider:
/// ```dart
/// final provider = TokenProvider.dynamic((userId) async {
///   return await fetchTokenFromServer(userId);
/// });
/// final token = await provider.loadToken('user-456');
/// ```
abstract interface class TokenProvider {
  /// Creates a static token provider with a pre-defined [token].
  ///
  /// The [token] can be either a JWT token or an anonymous token that will be
  /// used for a specific user. This is useful for scenarios where tokens don't
  /// expire or for testing purposes.
  factory TokenProvider.static(UserToken token) = StaticTokenProvider;

  /// Creates a dynamic token provider with a custom [loader] function.
  ///
  /// The [loader] function will be called with a user ID to fetch a fresh
  /// JWT token for that user. This is useful for scenarios where JWT tokens
  /// expire and need to be refreshed from external services.
  factory TokenProvider.dynamic(UserTokenLoader loader) = DynamicTokenProvider;

  /// Loads a [UserToken] for the specified [userId].
  ///
  /// Returns a [Future] that resolves to a [UserToken] configured for either
  /// JWT authentication or anonymous access, depending on the provider type.
  ///
  /// Throws an [ArgumentError] if the loaded token is not valid (for JWT providers)
  /// or if the 'user_id' claim is missing or empty (for JWT tokens).
  Future<UserToken> loadToken(String userId);
}

/// A token provider that uses a static token for a specific user.
///
/// This implementation returns the same pre-configured token and validates
/// that the token's user ID matches the requested user ID. This ensures
/// consistent behavior for both JWT and anonymous tokens.
///
/// Useful for scenarios where tokens don't expire, long-lived tokens,
/// or for testing purposes.
class StaticTokenProvider implements TokenProvider {
  /// Creates a static token provider with the given [_rawToken].
  const StaticTokenProvider(this._rawToken);

  // The pre-configured token.
  final UserToken _rawToken;

  /// Loads the static token for the specified [userId].
  ///
  /// Returns a [Future] that resolves to the pre-configured [UserToken].
  /// Validates that the token's user ID matches the requested [userId]
  /// for consistent behavior across both JWT and anonymous tokens.
  ///
  /// Throws an [ArgumentError] if the token's user ID does not match
  /// the requested [userId].
  @override
  Future<UserToken> loadToken(String userId) async {
    // Validate that the token's user_id matches the requested userId
    if (_rawToken.userId == userId) return _rawToken;

    throw ArgumentError(
      'User ID mismatch: expected "${_rawToken.userId}", got "$userId"',
    );
  }
}

/// A token provider that dynamically loads fresh JWT tokens using a custom function.
///
/// This implementation uses a [UserTokenLoader] function to fetch fresh JWT tokens
/// for users when needed. The loader function is called with the user ID
/// and must return a fresh JWT token, typically used for token refresh scenarios.
class DynamicTokenProvider implements TokenProvider {
  /// Creates a dynamic token provider with the given [_loader] function.
  const DynamicTokenProvider(this._loader);

  // The function used to load tokens for users.
  final UserTokenLoader _loader;

  /// Loads a fresh JWT token for the specified [userId] using the configured loader.
  ///
  /// Calls the [_loader] function with the [userId] to fetch a fresh JWT token
  /// and returns the [UserToken] instance from the result.
  ///
  /// Returns a [Future] that resolves to a [UserToken] configured for JWT authentication.
  ///
  /// Throws an [ArgumentError] if the token returned by the loader is not a JWT token
  /// or if the 'user_id' claim is missing or empty.
  @override
  Future<UserToken> loadToken(String userId) async {
    final token = await _loader.call(userId);
    // Validate that the returned token is a JWT token
    if (token.authType == AuthType.jwt) return token;

    throw ArgumentError(
      'Token type mismatch: expected jwt, got ${token.authType.headerValue}',
    );
  }
}
