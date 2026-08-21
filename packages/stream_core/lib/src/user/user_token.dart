import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:jose/jose.dart';

import 'user.dart';

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
  /// Throws an [ArgumentError] if the 'user_id' claim is missing or empty, and
  /// a [FormatException] if [rawValue] cannot be parsed as a JWT.
  factory UserToken(String rawValue) {
    final claims = JsonWebToken.unverified(rawValue).claims;
    final userId = claims.getTyped<String>('user_id');
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
      expiresAt: claims.expiry?.toUtc(),
    );
  }

  /// Creates an anonymous user token.
  ///
  /// Anonymous tokens always use [User.anonymousUserId] as their user id.
  ///
  /// An optional [rawValue] can carry a JWT that is sent along with anonymous
  /// requests, granting access to the specific resources its claims name. When omitted, the token
  /// carries no raw value and requests are sent without credentials.
  ///
  /// Returns a [UserToken] configured for anonymous access.
  ///
  /// Throws an [ArgumentError] if [rawValue] is given and its 'user_id' claim
  /// is not [User.anonymousUserId], and a [FormatException] if it cannot be parsed
  /// as a JWT.
  factory UserToken.anonymous({String rawValue = ''}) {
    DateTime? expiresAt;
    if (rawValue.isNotEmpty) {
      final claims = JsonWebToken.unverified(rawValue).claims;
      expiresAt = claims.expiry?.toUtc();
      final userId = claims.getTyped<String>('user_id');
      if (userId != User.anonymousUserId) {
        throw ArgumentError.value(
          userId,
          'rawValue',
          'Expected a JWT claiming user_id "${User.anonymousUserId}"',
        );
      }
    }

    return UserToken._(
      rawValue: rawValue,
      userId: User.anonymousUserId,
      authType: AuthType.anonymous,
      expiresAt: expiresAt,
    );
  }

  const UserToken._({
    required this.rawValue,
    required this.userId,
    required this.authType,
    this.expiresAt,
  });

  /// The raw token value.
  ///
  /// For JWT tokens, contains the complete JWT string. For anonymous tokens,
  /// it is empty unless one was supplied to grant restricted access.
  final String rawValue;

  /// The unique identifier of the user.
  ///
  /// For JWT tokens, this value is extracted from the 'user_id' claim.
  /// For anonymous tokens, it is always [User.anonymousUserId].
  final String userId;

  /// The authentication type of this token.
  ///
  /// Indicates whether this token uses JWT authentication or anonymous access.
  final AuthType authType;

  /// The moment this token stops being valid, from its 'exp' claim, in UTC.
  ///
  /// `null` when the token names no expiry, including an anonymous token carrying no raw value.
  /// Such a token is never considered expired.
  final DateTime? expiresAt;

  /// Whether this token has expired, or expires within [leeway].
  ///
  /// A [leeway] covers the gap between the check and the token being used, so one that would run
  /// out mid-request counts as expired before it is sent. It also absorbs a client clock running
  /// behind.
  bool isExpired({Duration leeway = Duration.zero}) {
    final expiresAt = this.expiresAt;
    if (expiresAt == null) return false;

    // Not `isAfter`: a token expiring at exactly this moment has expired.
    return !clock.now().add(leeway).isBefore(expiresAt);
  }

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
