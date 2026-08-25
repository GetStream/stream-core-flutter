import 'dart:convert';

import '../../stream_core.dart';

/// A [DioException] carrying the Stream [ClientException] that caused it.
class StreamDioException extends DioException {
  /// Creates a [StreamDioException] for [exception].
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
  /// The Stream API error this exception's response carried, or `null` when it carried something else.
  ///
  /// A Stream error is recognised whether the server sent it as JSON or as plain text. A body that is
  /// not one — a proxy or gateway answering with an error of its own — reads as `null` rather than
  /// throwing.
  StreamApiError? get apiError => runSafelySync(() {
    final data = response?.data;
    final json = data is String ? jsonDecode(data) : data;
    if (json is! Map<String, Object?>) return null;

    return StreamApiError.fromJson(json);
  }).getOrNull();

  /// This exception as an [HttpClientException].
  ///
  /// Takes its message, status code and cause from [apiError] when the response carried one, and
  /// from what the transport reported otherwise. A request the caller cancelled is marked as such.
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
