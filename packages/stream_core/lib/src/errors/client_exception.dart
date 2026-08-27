import 'stream_api_error.dart';

class ClientException implements Exception {
  ClientException({
    this.message,
    Object? error,
    this.stackTrace,
  }) : underlyingError = error;

  final String? message;

  final Object? underlyingError;
  final StackTrace? stackTrace;

  StreamApiError? get apiError {
    if (underlyingError case final StreamApiError error) return error;
    return null;
  }
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

// class WebSocketException extends ClientException {
//   WebSocketException(this.serverException, {super.error})
//       : super(
//           message:
//               (serverException ?? WebSocketEngineException.unknown()).reason,
//         );
//   final WebSocketEngineException? serverException;
// }
//
// class WebSocketEngineException extends ClientException {
//   WebSocketEngineException({
//     required this.reason,
//     required this.code,
//     this.engineError,
//   }) : super(message: reason);
//
//   WebSocketEngineException.unknown()
//       : this(
//           reason: 'Unknown',
//           code: 0,
//           engineError: null,
//         );
//
//   static const stopErrorCode = 1000;
//
//   final String reason;
//   final int code;
//   final Object? engineError;
// }
