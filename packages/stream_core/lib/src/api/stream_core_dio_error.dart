import 'dart:convert';

import 'package:dio/dio.dart';

import '../errors.dart';
import '../utils/standard.dart';

/// A [DioException] carrying the [StreamException] that caused it.
///
/// Internal plumbing: Dio's interceptor contract requires rejections to be
/// [DioException]s, so the mapped exception rides in [exception] until the
/// call layer unwraps it. Consumers never see this type — they see the
/// [StreamException] it carries.
class StreamDioException extends DioException {
  /// Creates a [StreamDioException] carrying [exception].
  StreamDioException({
    required this.exception,
    required super.requestOptions,
    super.response,
    super.type,
    StackTrace? stackTrace,
    super.message,
  }) : super(
         error: exception,
         stackTrace: stackTrace ?? StackTrace.current,
       );

  /// The Stream exception this Dio exception delivers.
  final StreamException exception;
}

/// Maps transport failures reported by Dio onto the Stream exception kinds.
///
/// This is the HTTP error boundary: the only place that reads
/// [DioExceptionType] and response bodies to decide what actually happened.
extension DioExceptionMapping on DioException {
  /// This failure as the [StreamException] it represents.
  ///
  /// A response from the server — parseable Stream error payload or bare
  /// status — becomes a [StreamApiException]. Everything that ended before a
  /// verdict (timeout, cancellation, socket failure) becomes a
  /// [StreamNetworkException].
  StreamException toStreamException() {
    if (this case StreamDioException(:final exception)) return exception;

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
