import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../errors.dart';
import '../utils/result.dart';
import '../utils/standard.dart';

/// A [DioException] carrying the [StreamException] that caused it.
///
/// Dio requires rejections to be [DioException]s, so the mapped exception
/// rides in [exception] until [runApiSafely] unwraps it at the call seam.
class StreamDioException extends DioException {
  /// Creates a [StreamDioException] carrying [exception].
  ///
  /// A null [stackTrace] is left for Dio to fill in, which substitutes the
  /// stack captured where the request was made — more useful than one
  /// captured here.
  StreamDioException({
    required this.exception,
    required super.requestOptions,
    super.response,
    super.type,
    super.stackTrace,
    super.message,
  }) : super(error: exception);

  /// The Stream exception this Dio exception delivers.
  final StreamException exception;
}

/// Maps failures reported by Dio onto the Stream exception kinds.
extension DioExceptionMapping on DioException {
  /// This failure as the [StreamException] it represents.
  ///
  /// A response from the server — parseable Stream error payload or bare
  /// status — becomes a [StreamApiException]. Everything that ended before a
  /// verdict (timeout, cancellation, socket failure) becomes a
  /// [StreamNetworkException].
  StreamException toStreamException() {
    if (this case StreamDioException(:final exception)) return exception;

    // A Stream exception thrown loose inside the interceptor chain arrives
    // wrapped in a plain DioException; its classification is kept rather
    // than re-diagnosed from a wrapper that has no response to read.
    if (error case final StreamException exception) return exception;

    if (type == DioExceptionType.cancel) {
      return StreamNetworkException(
        message: 'The request was cancelled',
        isCancelled: true,
        cause: this,
        stackTrace: stackTrace,
      );
    }

    if (_isTimeout) {
      return StreamNetworkException(
        message: 'The request timed out before the server answered',
        isTimeout: true,
        cause: this,
        stackTrace: stackTrace,
      );
    }

    // A response means the server reached a verdict, even when its body is
    // not a Stream error payload — an edge or proxy answering on its own.
    if (response case final response?) {
      if (_parseApiError(response.data) case final apiError?) {
        return StreamApiException.fromApiError(
          apiError,
          retryAfter: _parseRetryAfter(response),
          cause: this,
          stackTrace: stackTrace,
        );
      }

      return StreamApiException(
        message: response.statusMessage ?? message ?? 'The server responded with an error',
        statusCode: response.statusCode ?? 0,
        retryAfter: _parseRetryAfter(response),
        cause: this,
        stackTrace: stackTrace,
      );
    }

    return StreamNetworkException(
      message: message ?? 'The request failed before the server answered',
      cause: this,
      stackTrace: stackTrace,
    );
  }

  bool get _isTimeout => switch (type) {
    DioExceptionType.connectionTimeout || DioExceptionType.sendTimeout || DioExceptionType.receiveTimeout => true,
    _ => false,
  };
}

// An interpretation seam: decoding wire data catches everything, `Error`
// included — a `TypeError` thrown while reading a response body indicts the
// data, not the program.
StreamApiError? _parseApiError(Object? data) {
  try {
    final json = data is String ? jsonDecode(data) : data;
    if (json is! Map<String, Object?>) return null;
    return StreamApiError.fromJson(json);
  } catch (_) {
    return null;
  }
}

Duration? _parseRetryAfter(Response<Object?> response) {
  final seconds = response.headers.value('retry-after')?.let(int.tryParse);
  if (seconds == null || seconds < 0) return null;
  return Duration(seconds: seconds);
}

/// Runs a block of API code and returns a [Result] containing the outcome.
///
/// If the block completes successfully, the result is a success with the value
/// returned by the block. Otherwise, the failure is always a [StreamException]:
/// a [DioException] is mapped through [DioExceptionMapping.toStreamException],
/// a [StreamException] is kept as it was raised, and anything else — a
/// response body that would not decode included — is wrapped in a
/// [StreamClientException] with the original error preserved as its cause.
Future<Result<R>> runApiSafely<R>(FutureOr<R> Function() block) async {
  try {
    final result = await block();
    return Result.success(result);
  } on DioException catch (e, stackTrace) {
    return Result.failure(e.toStreamException(), stackTrace);
  } on StreamException catch (e, stackTrace) {
    return Result.failure(e, stackTrace);
  } catch (e, stackTrace) {
    final exception = StreamClientException(
      message: 'The API call failed unexpectedly',
      cause: e,
      stackTrace: stackTrace,
    );

    return Result.failure(exception, stackTrace);
  }
}
