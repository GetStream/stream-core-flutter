/// A strongly-typed wrapper around a Stream API error code.
///
/// The named constants cover the codes the API is known to send, across every
/// Stream product — the registry is one shared space, so a chat and a video
/// error draw from the same numbers. The type behaves like an `int` at
/// runtime, so a code the SDK does not know yet still compares and prints as
/// its number rather than failing to decode.
///
/// A code identifies the *condition*; the HTTP status it arrives with can
/// vary, so neither is derivable from the other.
extension type const StreamErrorCode(int code) implements int {
  /// Create a new instance from a json number.
  ///
  /// Accepts any [num] the way every int field does, so an integral double
  /// reads as its number instead of failing the whole error.
  static StreamErrorCode fromJson(num code) => StreamErrorCode(code.toInt());

  /// Serialize to json number.
  static int toJson(StreamErrorCode code) => code;

  /// `-1` – An unexpected server-side failure.
  static const internalError = StreamErrorCode(-1);

  /// `2` – The API key cannot be accepted: unknown, or the product it
  /// addresses is not enabled for the app.
  static const apiKeyInvalid = StreamErrorCode(2);

  /// `4` – The request input failed validation.
  static const inputError = StreamErrorCode(4);

  /// `5` – Authentication failed for a reason other than the token codes
  /// below.
  static const authenticationFailed = StreamErrorCode(5);

  /// `6` – The username is already taken.
  static const duplicateUsername = StreamErrorCode(6);

  /// `9` – The request was rate limited.
  static const rateLimited = StreamErrorCode(9);

  /// `16` – The requested resource does not exist.
  static const notFound = StreamErrorCode(16);

  /// `17` – The caller lacks permission for this operation.
  static const notAllowed = StreamErrorCode(17);

  /// `18` – The event type is not supported.
  static const eventNotSupported = StreamErrorCode(18);

  /// `19` – The channel does not support this feature.
  static const channelFeatureNotSupported = StreamErrorCode(19);

  /// `20` – The message is longer than the allowed maximum.
  static const messageTooLong = StreamErrorCode(20);

  /// `21` – Threads cannot be nested further.
  static const multipleNestingLevel = StreamErrorCode(21);

  /// `22` – The request payload is too big.
  static const payloadTooBig = StreamErrorCode(22);

  /// `40` – The token has expired, or has been revoked. Either way a fresh
  /// token fixes it.
  static const tokenExpired = StreamErrorCode(40);

  /// `41` – The token is not valid yet (its `nbf` claim is in the future).
  /// Waiting fixes it.
  static const tokenNotValidYet = StreamErrorCode(41);

  /// `42` – The token was used before it was issued (its `iat` claim is in
  /// the future). Waiting fixes it.
  static const tokenUsedBeforeIssuedAt = StreamErrorCode(42);

  /// `43` – The token's signature cannot be accepted. A configuration
  /// problem no token or wait fixes.
  static const tokenSignatureInvalid = StreamErrorCode(43);

  /// `44` – The custom command has no endpoint configured.
  static const customCommandEndpointMissing = StreamErrorCode(44);

  /// `45` – Calling the custom command endpoint failed.
  static const customCommandEndpointCallError = StreamErrorCode(45);

  /// `46` – The connection id is not known to the server.
  static const connectionIdNotFound = StreamErrorCode(46);

  /// `48` – The server timed the request out.
  static const requestTimeout = StreamErrorCode(48);

  /// `60` – The user must wait out the channel's cooldown before sending
  /// another message.
  static const cooldown = StreamErrorCode(60);

  /// `70` – Channels matching the query were withheld because the user lacks
  /// access to them.
  static const queryChannelPermissionsMismatch = StreamErrorCode(70);

  /// `71` – The client has too many concurrent connections.
  static const tooManyConnections = StreamErrorCode(71);

  /// `72` – The operation is not supported in push v1.
  static const notSupportedInPushV1 = StreamErrorCode(72);

  /// `73` – Message moderation failed, or the moderation provider failed.
  static const moderationFailed = StreamErrorCode(73);

  /// `80` – No video provider is configured.
  static const videoProviderNotConfigured = StreamErrorCode(80);

  /// `81` – The call id is not valid.
  static const videoInvalidCallId = StreamErrorCode(81);

  /// `82` – Creating the call failed.
  static const videoCreateCallFailed = StreamErrorCode(82);

  /// `99` – The app is suspended.
  static const appSuspended = StreamErrorCode(99);

  /// `100` – No video datacenters are available.
  static const videoNoDatacentersAvailable = StreamErrorCode(100);

  /// `101` – Joining the call failed.
  static const videoJoinCallFailure = StreamErrorCode(101);

  /// `102` – Calls matching the query were withheld because the user lacks
  /// access to them.
  static const queryCallsPermissionsMismatch = StreamErrorCode(102);

  /// `103` – The call being accepted or rejected is gone.
  static const acceptRejectCallIsGone = StreamErrorCode(103);

  /// `104` – Call stats matching the query were withheld because the user
  /// lacks access to them.
  static const queryCallStatsPermissionsMismatch = StreamErrorCode(104);

  /// `105` – The operation is supported only in push v3.
  static const supportedInPushV3 = StreamErrorCode(105);

  /// `106` – The call is restricted in the caller's region.
  static const videoRestrictedRegion = StreamErrorCode(106);

  /// `107` – The product is suspended for the app.
  static const productSuspended = StreamErrorCode(107);

  /// `108` – The caller cancelled the request before the server finished.
  static const requestCancelled = StreamErrorCode(108);

  /// `109` – Joining this call requires requesting end-to-end encryption.
  static const videoJoinMustRequestE2ee = StreamErrorCode(109);

  /// `110` – End-to-end encryption is not available for this call.
  static const videoJoinE2eeNotAvailable = StreamErrorCode(110);

  /// `111` – The moderation service is overloaded.
  static const moderationOverloaded = StreamErrorCode(111);

  /// `112` – Feeds storage is unavailable.
  static const feedsStorageUnavailable = StreamErrorCode(112);
}

/// Convenience predicates grouping the codes that share a remedy.
extension StreamErrorCodePredicates on StreamErrorCode {
  /// Whether this code says the token has expired
  /// ([StreamErrorCode.tokenExpired]).
  ///
  /// A fresh token fixes it.
  bool get isTokenExpired => this == .tokenExpired;

  /// Whether this code says the token is not valid yet
  /// ([StreamErrorCode.tokenNotValidYet] and
  /// [StreamErrorCode.tokenUsedBeforeIssuedAt]).
  ///
  /// A clock-skew condition on the token's `nbf`/`iat` claims: waiting fixes
  /// it, a fresh token minted by the same skewed clock does not.
  bool get isTokenNotYetValid => this == .tokenNotValidYet || this == .tokenUsedBeforeIssuedAt;

  /// Whether this code says the token's signature cannot be accepted
  /// ([StreamErrorCode.tokenSignatureInvalid]).
  ///
  /// A configuration problem — signed with the wrong secret. Neither waiting
  /// nor a fresh token from the same signer fixes it.
  bool get isTokenSignatureInvalid => this == .tokenSignatureInvalid;

  /// Whether this code says the API key cannot be accepted
  /// ([StreamErrorCode.apiKeyInvalid]).
  ///
  /// The key is unknown, or the product it addresses is not enabled for the
  /// app. A configuration problem no token fixes.
  bool get isApiKeyInvalid => this == .apiKeyInvalid;
}
