import 'package:equatable/equatable.dart';
import 'package:jose/jose.dart';

/// A function that loads user tokens.
///
/// Takes a [userId] and returns a [Future] that resolves to a [UserToken].
/// This loader can return either JWT tokens or anonymous tokens depending
/// on the authentication requirements. Typically used to fetch tokens from
/// a backend service or authentication provider.
typedef UserTokenLoader = Future<UserToken> Function(String userId);

/// A user authentication token for Stream Core API access.
///
/// Represents user authentication credentials that can be either JWT-based
/// or anonymous. The token encapsulates the authentication type, user identity,
/// and raw token value needed for API requests.
///
/// ## Usage
///
/// Create a JWT token:
/// ```dart
/// final token = UserToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
/// print(token.userId); // Extracted from JWT claims
/// ```
///
/// Create an anonymous token:
/// ```dart
/// final token = UserToken.anonymous();
/// print(token.authType); // AuthType.anonymous
/// ```
class UserToken extends Equatable {
  /// Creates a JWT-based user token from the provided [rawValue].
  ///
  /// Parses the JWT token to extract the user ID from the 'user_id' claim.
  /// The token is validated for structure but not for signature verification.
  ///
  /// Returns a [UserToken] configured for JWT authentication.
  ///
  /// Throws an [ArgumentError] if the [rawValue] is not a valid JWT token
  /// or if the 'user_id' claim is missing or empty.
  factory UserToken(String rawValue) {
    final jwtBody = JsonWebToken.unverified(rawValue);
    final userId = jwtBody.claims.getTyped<String>('user_id');
    if (userId == null || userId.isEmpty) {
      throw ArgumentError.value(
        rawValue,
        'rawValue',
        'Invalid JWT token: missing or empty user_id claim',
      );
    }

    return UserToken._(
      rawValue: rawValue,
      userId: userId,
      authType: AuthType.jwt,
    );
  }

  /// Creates an anonymous user token.
  ///
  /// Anonymous tokens always use [anonymousUserId] as their user id.
  ///
  /// An optional [rawValue] can carry a JWT that is sent along with anonymous
  /// requests, granting the caller access to the specific resources its claims
  /// name. When omitted, the token carries no raw value and requests are sent
  /// without credentials.
  ///
  /// Returns a [UserToken] configured for anonymous access.
  ///
  /// Throws an [ArgumentError] if [rawValue] is given and its 'user_id' claim
  /// is not [anonymousUserId], and a [FormatException] if it cannot be parsed
  /// as a JWT.
  factory UserToken.anonymous({String rawValue = ''}) {
    if (rawValue.isNotEmpty) {
      final jwtBody = JsonWebToken.unverified(rawValue);
      final claim = jwtBody.claims.getTyped<String>('user_id');
      if (claim != anonymousUserId) {
        throw ArgumentError.value(
          rawValue,
          'rawValue',
          'Invalid anonymous JWT token: user_id claim must be "$anonymousUserId", got "$claim"',
        );
      }
    }

    return UserToken._(
      rawValue: rawValue,
      userId: anonymousUserId,
      authType: AuthType.anonymous,
    );
  }

  const UserToken._({
    required this.rawValue,
    required this.userId,
    required this.authType,
  });

  /// The user id used for anonymous authentication.
  static const anonymousUserId = '!anon';

  /// The raw token value.
  ///
  /// For JWT tokens, contains the complete JWT string. For anonymous tokens,
  /// it is empty unless one was supplied to grant restricted access.
  final String rawValue;

  /// The unique identifier of the user.
  ///
  /// For JWT tokens, this value is extracted from the 'user_id' claim.
  /// For anonymous tokens, it is always [anonymousUserId].
  final String userId;

  /// The authentication type of this token.
  ///
  /// Indicates whether this token uses JWT authentication or anonymous access.
  final AuthType authType;

  @override
  List<Object?> get props => [rawValue, userId, authType];
}

/// Represents the types of authentication available for API access.
///
/// Defines the authentication methods supported by the Stream Core SDK
/// for securing API requests and establishing user identity.
enum AuthType {
  /// JSON Web Token authentication.
  ///
  /// Uses JWT tokens for authenticated requests with user identity verification.
  /// The token contains user claims and is validated by the server.
  jwt('jwt'),

  /// Anonymous authentication.
  ///
  /// Allows unauthenticated access with limited permissions.
  /// Used for public content access or guest user scenarios.
  anonymous('anonymous');

  /// Constructs an [AuthType] with the associated header value.
  const AuthType(this.headerValue);

  /// The string value used in authentication headers.
  ///
  /// This value is sent in HTTP headers to identify the authentication
  /// method being used for API requests.
  final String headerValue;
}
