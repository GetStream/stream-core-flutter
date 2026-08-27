import 'package:equatable/equatable.dart';

import 'stream_api_error.dart';

/// The root of every failure a Stream SDK reports.
///
/// There are exactly four kinds, named for what the caller should do about
/// them:
///
/// - [StreamApiException] — the server answered, and the answer was an error.
/// - [StreamNetworkException] — the server was never heard from; the outcome
///   of the request is unknown.
/// - [StreamAuthenticationException] — credentials could not be produced or
///   sent.
/// - [StreamClientException] — the SDK itself failed.
///
/// The root is sealed, so a `switch` over the four kinds is exhaustive.
/// Product SDKs extend a kind (`StreamChatApiException extends
/// StreamApiException`) rather than adding a fifth.
///
/// Programmer mistakes are not part of this hierarchy: misusing the SDK —
/// sending before connecting, using a disposed client — throws Dart's own
/// [StateError] or [ArgumentError], which mean *fix your code*, not *handle at
/// runtime*.
sealed class StreamException extends Equatable implements Exception {
  /// Creates a [StreamException].
  const StreamException({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// What went wrong.
  ///
  /// Always present and developer-readable. It is not localized and may
  /// contain server-internal detail — for user-facing UI, key your own
  /// strings off [StreamApiException.code] instead of displaying it verbatim.
  final String message;

  /// The failure underneath this one, when this exception wraps another.
  final Object? cause;

  /// Where the failure was raised.
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, cause];

  @override
  String toString() {
    // The runtime type is the point here: it names the category (or the
    // product subclass) in logs and crash reports.
    // ignore: no_runtimetype_tostring
    final buffer = StringBuffer('$runtimeType: $message');
    if (cause case final cause?) buffer.write('\n  caused by: $cause');
    return buffer.toString();
  }
}

/// A request that reached a Stream server and was answered with an error.
///
/// The server's verdict is final for this attempt: the request was received,
/// understood, and rejected. What to do next is described by the facts
/// carried here — [code], [statusCode], [unrecoverable], [retryAfter] — not
/// by the transport that delivered them: a WebSocket connection refused by
/// the server reports the same exception as a rejected REST call.
base class StreamApiException extends StreamException {
  /// Creates a [StreamApiException].
  const StreamApiException({
    required super.message,
    required this.statusCode,
    this.code,
    this.moreInfo,
    this.unrecoverable = false,
    this.retryAfter,
    this.apiError,
    super.cause,
    super.stackTrace,
  });

  /// Creates a [StreamApiException] from the server's error payload.
  StreamApiException.fromApiError(
    StreamApiError error, {
    Duration? retryAfter,
    Object? cause,
    StackTrace? stackTrace,
  }) : this(
         message: error.message,
         statusCode: error.statusCode,
         code: error.code,
         moreInfo: error.moreInfo.isEmpty ? null : error.moreInfo,
         unrecoverable: error.unrecoverable ?? false,
         retryAfter: retryAfter,
         apiError: error,
         cause: cause,
         stackTrace: stackTrace,
       );

  /// The HTTP status the server answered with.
  ///
  /// Independent of [code]: the backend maps some codes to more than one
  /// status, so never derive one from the other.
  final int statusCode;

  /// Stream's stable error code.
  ///
  /// The machine-readable discriminator — branch on this, never on [message].
  ///
  /// `null` when the response carried no Stream error payload — an edge or
  /// proxy answering with an error of its own. Deliberately not a sentinel
  /// value: the backend's registry includes low and negative codes, so any
  /// stand-in number would collide with a real one.
  final int? code;

  /// A documentation URL for this error, when the server sent one.
  ///
  /// Populated on REST errors; WebSocket errors carry none.
  final String? moreInfo;

  /// Whether the server declared that retrying will not help.
  ///
  /// Authoritative when `true`. Absence means nothing: today only Video
  /// endpoints set it — Chat and Feeds errors never carry it — so `false`
  /// must not be read as "retryable".
  final bool unrecoverable;

  /// How long the server asked to wait before retrying, when it said.
  ///
  /// Parsed from the `Retry-After` header on rate-limited REST calls; absent
  /// on WebSocket rate limits, which send no headers.
  final Duration? retryAfter;

  /// The server's error payload, when the failure carried a parseable one.
  ///
  /// `null` when only a bare status was available — an edge or proxy
  /// answering with an error of its own.
  final StreamApiError? apiError;

  /// Whether the token this request carried has expired (code 40).
  ///
  /// A freshly issued token fixes it. The SDK refreshes expired tokens
  /// automatically, so this surfaces only when a refresh could not help.
  bool get isTokenExpired => code == _codeTokenExpired;

  /// Whether the token is not valid yet (codes 41 and 42).
  ///
  /// A clock-skew condition on the token's `nbf`/`iat` claims: waiting fixes
  /// it, a fresh token minted by the same skewed clock does not.
  bool get isTokenNotYetValid => code == _codeTokenNotValidYet || code == _codeTokenUsedBeforeIssuedAt;

  /// Whether the token's signature cannot be accepted (code 43).
  ///
  /// A configuration problem — signed with the wrong secret. Neither waiting
  /// nor a fresh token from the same signer fixes it.
  bool get isTokenSignatureInvalid => code == _codeTokenSignatureInvalid;

  /// Whether the API key cannot be accepted (code 2).
  ///
  /// The key is unknown, or the product it addresses is not enabled for the
  /// app. A configuration problem no token fixes.
  bool get isApiKeyInvalid => code == _codeApiKeyInvalid;

  /// Whether the request was rate limited (HTTP 429).
  ///
  /// [retryAfter] carries the server's suggested wait when one was sent.
  bool get isRateLimited => statusCode == 429;

  static const _codeApiKeyInvalid = 2;
  static const _codeTokenExpired = 40;
  static const _codeTokenNotValidYet = 41;
  static const _codeTokenUsedBeforeIssuedAt = 42;
  static const _codeTokenSignatureInvalid = 43;

  @override
  List<Object?> get props => [...super.props, statusCode, code, moreInfo, unrecoverable, retryAfter];

  @override
  String toString() {
    final code = this.code?.toString() ?? 'none';
    // ignore: no_runtimetype_tostring
    final buffer = StringBuffer('$runtimeType(code: $code, statusCode: $statusCode): $message');
    if (moreInfo case final moreInfo?) buffer.write('\n  more info: $moreInfo');
    if (cause case final cause?) buffer.write('\n  caused by: $cause');
    return buffer.toString();
  }
}

/// A request or connection that never got a verdict from the server.
///
/// The outcome is **unknown**: the server may have received and performed the
/// operation before the connection failed. Retry a write only through an
/// idempotent path.
base class StreamNetworkException extends StreamException {
  /// Creates a [StreamNetworkException].
  const StreamNetworkException({
    required super.message,
    this.isCancelled = false,
    this.isTimeout = false,
    this.closeCode,
    super.cause,
    super.stackTrace,
  });

  /// Whether the caller cancelled the request.
  ///
  /// A cancellation is usually the app navigating away — something to ignore,
  /// not to surface.
  final bool isCancelled;

  /// Whether the request or connection attempt timed out.
  final bool isTimeout;

  /// The WebSocket close code, when the failure was a socket closure.
  ///
  /// Carries little signal on its own — the server closes with 1000 even for
  /// refused credentials, and the reason travels in an error event sent
  /// before the close. Classify from that event's code where one exists.
  final int? closeCode;

  @override
  List<Object?> get props => [...super.props, isCancelled, isTimeout, closeCode];
}

/// Credentials that could not be produced or sent.
///
/// Fires before anything reached the server: the token provider failed (its
/// error is preserved in [cause]), no user is configured, or the WebSocket
/// authentication message could not go out. A server that *rejected*
/// credentials has answered — that is a [StreamApiException], see
/// [StreamApiException.isTokenExpired] and its siblings.
base class StreamAuthenticationException extends StreamException {
  /// Creates a [StreamAuthenticationException].
  const StreamAuthenticationException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// A failure inside the SDK itself.
///
/// Wire data that would not decode, an invariant that did not hold, or an
/// error thrown by app-supplied code the SDK ran on the caller's behalf. Not
/// the end user's problem — report it to a crash tracker.
base class StreamClientException extends StreamException {
  /// Creates a [StreamClientException].
  const StreamClientException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}
