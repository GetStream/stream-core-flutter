import 'dart:convert';

import '../../stream_core.dart';

/// Error class specific to StreamChat and Dio
class StreamDioException extends DioException {
  /// Initialize a stream chat dio error
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

  final ClientException exception;
}

extension StreamDioExceptionExtension on DioException {
  /// The Stream API error the response carried, or `null` when it carried something else.
  ///
  /// Recognised whether the server sent it as JSON or as plain text. A body that is not a Stream
  /// error — a proxy or gateway answering with one of its own — reads as `null` rather than throwing.
  StreamApiError? get apiError {
    return runSafelySync(() {
      return switch (response?.data) {
        final Map<String, Object?> data => StreamApiError.fromJson(data),
        final String data => StreamApiError.fromJson(jsonDecode(data) as Map<String, Object?>),
        _ => null,
      };
    }).getOrNull();
  }

  /// This exception as an [HttpClientException].
  ///
  /// The message and status code come from the [apiError] the response carried, falling back to what
  /// the transport reported when there was none. The cause is that error, or this exception when the
  /// response carried none. A request the caller cancelled is marked as such.
  HttpClientException toClientException() {
    final apiError = this.apiError;

    return HttpClientException(
      message: apiError?.message ?? response?.statusMessage ?? message ?? '',
      error: apiError ?? this,
      statusCode: apiError?.statusCode ?? response?.statusCode,
      stackTrace: stackTrace,
      isRequestCancelledError: type == DioExceptionType.cancel,
    );
  }
}
