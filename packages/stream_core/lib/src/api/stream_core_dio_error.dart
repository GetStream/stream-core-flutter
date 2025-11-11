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
  HttpClientException toClientException() {
    final response = this.response;
    StreamApiError? apiError;
    final data = response?.data;

    try {
      if (data is Map<String, Object?>) {
        apiError = StreamApiError.fromJson(data);
      } else if (data is String) {
        apiError = StreamApiError.fromJson(jsonDecode(data));
      }
    } catch (e) {
      apiError = null;
    }
    return HttpClientException(
      message: apiError?.message ?? response?.statusMessage ?? message ?? '',
      error: apiError ?? this,
      statusCode: apiError?.statusCode ?? response?.statusCode,
      stackTrace: stackTrace,
      isRequestCancelledError: type == DioExceptionType.cancel,
    );
  }
}
