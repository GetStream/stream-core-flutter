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
  /// Throws an [ArgumentError] if the token does not belong to [userId], or if
  /// it is not valid for the provider's authentication type.
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
  /// Creates a static token provider with the given `token`.
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
    if (_rawToken.userId != userId) {
      throw ArgumentError.value(
        _rawToken.userId,
        'userId',
        'Expected "$userId"',
      );
    }

    return _rawToken;
  }
}

/// A token provider that dynamically loads fresh JWT tokens using a custom function.
///
/// This implementation uses a [UserTokenLoader] function to fetch fresh JWT tokens
/// for users when needed. The loader function is called with the user ID
/// and must return a fresh JWT token, typically used for token refresh scenarios.
class DynamicTokenProvider implements TokenProvider {
  /// Creates a dynamic token provider with the given `loader` function.
  const DynamicTokenProvider(this._loader);

  // The function used to load tokens for users.
  final UserTokenLoader _loader;

  /// Loads a fresh JWT token for the specified [userId] using the configured loader.
  ///
  /// Calls the loader with [userId] to fetch a fresh JWT token and returns the
  /// [UserToken] instance from the result.
  ///
  /// Returns a [Future] that resolves to a [UserToken] configured for JWT authentication.
  ///
  /// Throws an [ArgumentError] if the token returned by the loader is not a JWT
  /// token, or if its 'user_id' claim is not [userId].
  @override
  Future<UserToken> loadToken(String userId) async {
    final token = await _loader.call(userId);

    // Validate the type before the user id, so a non-JWT token is reported as
    // the wrong type rather than as belonging to the wrong user: an anonymous
    // token always carries `UserToken.anonymousUserId`, so it would otherwise
    // fail the user id check first.
    if (token.authType != AuthType.jwt) {
      throw ArgumentError.value(
        token.authType.headerValue,
        'authType',
        'Expected ${AuthType.jwt.headerValue}',
      );
    }

    // Validate that the token's user_id matches the requested userId
    if (token.userId != userId) {
      throw ArgumentError.value(
        token.userId,
        'userId',
        'Expected "$userId"',
      );
    }

    return token;
  }
}
