import 'stream_error_code.dart';
import 'stream_exception.dart';

/// Decides whether a failed operation is worth attempting again.
///
/// A retry decision has three inputs: what happened (the exception), what the
/// caller was doing, and how many attempts have been spent. The exception
/// knows only the first, which is why this is a policy the caller owns rather
/// than a property of the error.
///
/// [RetryPolicy.standard] answers for the common case; products with their
/// own rules implement this interface.
abstract interface class RetryPolicy {
  /// The default policy: retries what [StreamExceptionRetry.isRetriable]
  /// allows, up to [StandardRetryPolicy.maxAttempts] attempts.
  ///
  /// Safe only for operations that can be re-sent without side effects — a
  /// read, or a write carrying an idempotency key. A non-idempotent write
  /// that fails without a verdict may already have been performed.
  const factory RetryPolicy.standard({int maxAttempts}) = StandardRetryPolicy;

  /// Whether the operation that failed with [error] should be attempted
  /// again.
  ///
  /// The [attempt] is the number of the attempt that just failed, starting
  /// at 1. When the answer is yes, [StreamApiException.retryAfter] names the
  /// wait when the server sent one.
  bool shouldRetry(StreamException error, int attempt);
}

/// The [RetryPolicy] used when a caller does not bring their own.
final class StandardRetryPolicy implements RetryPolicy {
  /// Creates a [StandardRetryPolicy] allowing [maxAttempts] attempts.
  const StandardRetryPolicy({this.maxAttempts = 3});

  /// How many attempts an operation is given in total, the first included.
  final int maxAttempts;

  @override
  bool shouldRetry(StreamException error, int attempt) {
    return attempt < maxAttempts && error.isRetriable;
  }
}

/// The retry judgment that can be made from a failure alone.
extension StreamExceptionRetry on StreamException {
  /// Whether this failure is about the moment rather than about the request
  /// or the setup, so a later attempt can end differently.
  ///
  /// True for rate limits, server-side faults and timeouts, tokens not valid
  /// yet, and transport failures that were not cancelled. False for every
  /// verdict a resend reproduces — validation, permissions, refused
  /// signatures and keys — for credentials that never went out, and for
  /// failures inside the SDK.
  ///
  /// Necessary, but not on its own sufficient: whether re-sending is *safe*
  /// depends on the operation. A transport failure leaves the outcome
  /// unknown, so a write is worth re-sending only through an idempotent
  /// path. That knowledge is the caller's, which is why this getter feeds a
  /// [RetryPolicy] rather than replacing one.
  bool get isRetriable => switch (this) {
    StreamApiException(unrecoverable: true) => false,
    StreamApiException(isRateLimited: true) => true,
    StreamApiException(isTokenNotYetValid: true) => true,
    StreamApiException(code: StreamErrorCode.requestTimeout) => true,
    StreamApiException(:final statusCode) => statusCode >= 500,
    StreamNetworkException(isCancelled: true) => false,
    StreamNetworkException() => true,
    StreamAuthenticationException() => false,
    StreamClientException() => false,
  };
}
