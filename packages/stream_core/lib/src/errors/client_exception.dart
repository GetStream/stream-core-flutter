import 'package:equatable/equatable.dart';

import 'http_api_error.dart';

class ClientException extends Equatable {
  final String? message;

  late final Object? underlyingError;
  late final HttpApiError? apiError;

  ClientException({
    this.message,
    Object? error,
  }) {
    underlyingError = error;
    if (error is HttpApiError) {
      apiError = error;
    }
  }

  @override
  List<Object?> get props => [message, underlyingError, apiError];
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
