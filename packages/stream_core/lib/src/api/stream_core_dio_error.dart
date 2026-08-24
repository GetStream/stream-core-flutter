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
  /// Read whether or not the response was typed as JSON, so an error sent as plain text is still
  /// recognised. Anything that is not a Stream error payload reads as `null` rather than throwing:
  /// a proxy or gateway can answer with a JSON body of its own.
  StreamApiError? get apiError {
    return runSafelySync(() {
      return switch (response?.data) {
        final Map<String, Object?> data => StreamApiError.fromJson(data),
        final String data => StreamApiError.fromJson(jsonDecode(data) as Map<String, Object?>),
        _ => null,
      };
    }).getOrNull();
  }

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
