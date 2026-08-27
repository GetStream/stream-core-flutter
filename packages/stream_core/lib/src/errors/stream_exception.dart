import 'package:equatable/equatable.dart';

import 'stream_api_error.dart';
import 'stream_error_code.dart';

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
/// [StateError] or [ArgumentError], which signal a programming error rather
/// than a condition to handle at runtime.
sealed class StreamException extends Equatable implements Exception {
  /// Creates a [StreamException].
  const StreamException({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// What went wrong.
  ///
  /// Always present and developer-readable, but not localized and possibly
  /// carrying server-internal detail. For user-facing UI, consider keying
  /// localized strings off [StreamApiException.code] rather than displaying
  /// this verbatim.
  final String message;

  /// The failure underneath this one, when this exception wraps another.
  final Object? cause;

  /// Where the failure was raised.
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, cause];

  @override
  String toString() => _toString('StreamException');

  // Builds the log line, headed by the exact runtime type in debug mode and
  // by [fallbackName] in release mode, where type names may be minified.
  String _toString(String fallbackName) {
    final buffer = StringBuffer('${_typeName(this, fallbackName)}: $message');
    if (cause case final cause?) buffer.write('\n  caused by: $cause');
    return buffer.toString();
  }
}

// The pattern behind Flutter's `objectRuntimeType`: asserts run only in debug
// mode, so release builds pay nothing and print [fallbackName] instead of a
// possibly minified type name.
String _typeName(Object object, String fallbackName) {
  var name = fallbackName;
  assert(() {
    name = object.runtimeType.toString();
    return true;
  }());
  return name;
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
  factory StreamApiException.fromApiError(
    StreamApiError error, {
    Duration? retryAfter,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return StreamApiException(
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
  }

  /// The HTTP status the server answered with.
  ///
  /// Independent of [code]: the same code can arrive with different statuses,
  /// so neither can be derived from the other.
  final int statusCode;

  /// Stream's stable error code.
  ///
  /// The machine-readable discriminator — the value to branch on, where
  /// [message] is not stable. [StreamErrorCode] names the known values;
  /// a code without a named constant still carries its number.
  ///
  /// `null` when the response carried no Stream error payload, as when an
  /// intermediary answered with an error of its own.
  final StreamErrorCode? code;

  /// A documentation URL for this error, when the server sent one.
  ///
  /// Populated on REST errors; WebSocket errors carry none.
  final String? moreInfo;

  /// Whether the server declared that retrying will not help.
  ///
  /// Authoritative when `true`. `false` only means the server said nothing —
  /// it must not be read as "retrying will help".
  final bool unrecoverable;

  /// How long the server asked to wait before retrying, when it named a wait.
  ///
  /// Rate-limited requests can carry one; errors reported over a WebSocket
  /// never do.
  final Duration? retryAfter;

  /// The server's error payload, when the failure carried a parseable one.
  ///
  /// `null` when only a bare status was available, as when an intermediary
  /// answered with an error of its own.
  final StreamApiError? apiError;

  /// Whether the token this request carried has expired
  /// ([StreamErrorCode.tokenExpired]).
  ///
  /// A freshly issued token fixes it. The SDK refreshes expired tokens
  /// automatically, so this surfaces only when a refresh could not help.
  bool get isTokenExpired => code?.isTokenExpired ?? false;

  /// Whether the token is not valid yet ([StreamErrorCode.tokenNotValidYet] and
  /// [StreamErrorCode.tokenUsedBeforeIssuedAt]).
  ///
  /// A clock-skew condition on the token's `nbf`/`iat` claims: waiting fixes
  /// it, a fresh token minted by the same skewed clock does not.
  bool get isTokenNotYetValid => code?.isTokenNotYetValid ?? false;

  /// Whether the token's signature cannot be accepted
  /// ([StreamErrorCode.tokenSignatureInvalid]).
  ///
  /// A configuration problem — signed with the wrong secret. Neither waiting
  /// nor a fresh token from the same signer fixes it.
  bool get isTokenSignatureInvalid => code?.isTokenSignatureInvalid ?? false;

  /// Whether the API key cannot be accepted
  /// ([StreamErrorCode.apiKeyInvalid]).
  ///
  /// The key is unknown, or the product it addresses is not enabled for the
  /// app. A configuration problem no token fixes.
  bool get isApiKeyInvalid => code?.isApiKeyInvalid ?? false;

  /// Whether the request was rate limited (HTTP 429).
  ///
  /// [retryAfter] carries the server's suggested wait when one was sent.
  bool get isRateLimited => statusCode == 429;

  @override
  List<Object?> get props => [...super.props, statusCode, code, moreInfo, unrecoverable, retryAfter];

  @override
  String toString() {
    final facts = [
      if (code case final code?) 'code: $code',
      'statusCode: $statusCode',
      if (unrecoverable) 'unrecoverable',
      if (retryAfter case final retryAfter?) 'retryAfter: ${retryAfter.inSeconds}s',
    ];

    final name = _typeName(this, 'StreamApiException');
    final buffer = StringBuffer('$name(${facts.join(', ')}): $message');
    if (moreInfo case final moreInfo?) buffer.write('\n  more info: $moreInfo');
    if (cause case final cause?) buffer.write('\n  caused by: $cause');
    return buffer.toString();
  }
}

/// A request or connection that never got a verdict from the server.
///
/// The outcome is **unknown**: the server may have received and performed the
/// operation before the connection failed. Consider retrying a write only
/// through an idempotent path.
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
  /// Carries little signal on its own: a connection can close with a normal
  /// code even when something went wrong, with the reason reported separately
  /// as a [StreamApiException]. The exception kind and its code are the
  /// reliable classifiers; the close code is not.
  final int? closeCode;

  @override
  List<Object?> get props => [...super.props, isCancelled, isTimeout, closeCode];

  @override
  String toString() {
    final name = _typeName(this, 'StreamNetworkException');
    final closure = switch (closeCode) {
      final closeCode? => '(closeCode: $closeCode)',
      _ => '',
    };

    final buffer = StringBuffer('$name$closure: $message');
    if (cause case final cause?) buffer.write('\n  caused by: $cause');
    return buffer.toString();
  }
}

/// Credentials that could not be produced or sent.
///
/// Raised before anything reaches the server: the token provider failed (its
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

  @override
  String toString() => _toString('StreamAuthenticationException');
}

/// A failure inside the SDK itself.
///
/// Wire data that would not decode, an invariant that did not hold, or an
/// error thrown by app-supplied code the SDK ran on the caller's behalf. Not
/// the end user's problem — worth reporting to a crash tracker rather than
/// showing in UI.
base class StreamClientException extends StreamException {
  /// Creates a [StreamClientException].
  const StreamClientException({
    required super.message,
    super.cause,
    super.stackTrace,
  });

  @override
  String toString() => _toString('StreamClientException');
}
