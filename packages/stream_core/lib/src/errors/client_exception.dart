import 'package:equatable/equatable.dart';

import 'stream_api_error.dart';

class ClientException extends Equatable implements Exception {
  final String? message;

  late final Object? underlyingError;
  late final StreamApiError? apiError;
  final StackTrace? stackTrace;

  ClientException({
    this.message,
    Object? error,
    this.stackTrace,
  }) {
    underlyingError = error;
    if (error is StreamApiError) {
      apiError = error;
    }
  }

  @override
  List<Object?> get props => [message, underlyingError, apiError];
}

class HttpClientException extends ClientException {
  HttpClientException({
    super.message,
    super.error,
    super.stackTrace,
    required this.statusCode,
    required this.isRequestCancelledError,
  });
  final int? statusCode;
  final bool isRequestCancelledError;
}

class WebSocketException extends ClientException {
  WebSocketException(this.serverException, {super.error})
      : super(
          message:
              (serverException ?? WebSocketEngineException.unknown()).reason,
        );
  final WebSocketEngineException? serverException;
}

class WebSocketEngineException extends ClientException {
  static const stopErrorCode = 1000;

  final String reason;
  final int code;
  final Object? engineError;

  WebSocketEngineException({
    required this.reason,
    required this.code,
    this.engineError,
  }) : super(message: reason);

  WebSocketEngineException.unknown()
      : this(
          reason: 'Unknown',
          code: 0,
          engineError: null,
        );
}
