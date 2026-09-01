import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../errors.dart';
import '../utils/result.dart';

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
  /// An answer from the server becomes a [StreamApiException], a transport
  /// failure a [StreamNetworkException], and data that could not be read a
  /// [StreamClientException].
  StreamException toStreamException() {
    if (this case StreamDioException(:final exception)) return exception;

    // A Stream exception thrown loose inside the interceptor chain arrives
    // wrapped in a plain DioException; its classification is kept rather
    // than re-diagnosed from a wrapper that has no response to read.
    if (error case final StreamException exception) return exception;

    if (type == .cancel) {
      return StreamNetworkException(
        message: 'The request was cancelled',
        isCancelled: true,
        cause: this,
      );
    }

    if (type case .connectionTimeout || .sendTimeout || .receiveTimeout) {
      return StreamNetworkException(
        message: 'The request timed out before the server answered',
        isTimeout: true,
        cause: this,
      );
    }

    // A response means the server reached a verdict, even when its body is
    // not a Stream error payload — an edge or proxy answering on its own.
    if (response case final response?) {
      final retryAfter = _parseRetryAfter(response);

      if (_parseApiError(response.data) case final apiError?) {
        return StreamApiException.fromApiError(
          apiError,
          retryAfter: retryAfter,
          cause: this,
        );
      }

      return StreamApiException(
        message: response.statusMessage ?? message ?? 'The server responded with an error',
        statusCode: response.statusCode ?? 0,
        retryAfter: retryAfter,
        cause: this,
      );
    }

    // Dio reports transport trouble under its own types, so a failure carrying
    // neither a response nor one of those came out of its own pipeline: a body
    // it could not decode, or a request it could not build.
    if (error case FormatException() || TypeError()) {
      return StreamClientException(
        message: 'The request could not be completed',
        cause: error,
      );
    }

    return StreamNetworkException(
      message: message ?? 'The request failed before the server answered',
      cause: this,
    );
  }
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
  final values = response.headers['retry-after'];
  if (values == null || values.isEmpty) return null;

  // Only the delta-seconds form is read; RFC 9110 also allows an HTTP date.
  final seconds = int.tryParse(values.first);
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
    final exception = e.toStreamException();
    return Result.failure(exception, stackTrace);
  } on StreamException catch (e, stackTrace) {
    return Result.failure(e, stackTrace);
  } catch (e, stackTrace) {
    final exception = StreamClientException(
      message: 'The API call failed unexpectedly',
      cause: e,
    );

    return Result.failure(exception, stackTrace);
  }
}
