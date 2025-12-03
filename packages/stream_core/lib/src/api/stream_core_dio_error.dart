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
    final apiErrorResult = runSafelySync(
      () => switch (response?.data) {
        final Map<String, Object?> data => StreamApiError.fromJson(data),
        final String data => StreamApiError.fromJson(jsonDecode(data)),
        _ => null,
      },
    );

    final apiError = apiErrorResult.getOrNull();

    return HttpClientException(
      message: apiError?.message ?? response?.statusMessage ?? message ?? '',
      error: apiError ?? this,
      statusCode: apiError?.statusCode ?? response?.statusCode,
      stackTrace: stackTrace,
      isRequestCancelledError: type == DioExceptionType.cancel,
    );
  }
}
