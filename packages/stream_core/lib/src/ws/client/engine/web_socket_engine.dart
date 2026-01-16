import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../errors.dart';
import '../../../utils.dart';
import 'web_socket_options.dart';

export 'dart:typed_data';
export 'web_socket_options.dart';

/// Interface for WebSocket engine implementations.
///
/// Defines the core operations that a WebSocket engine must support for managing
/// WebSocket connections, including opening, closing, and sending messages.
abstract interface class WebSocketEngine<Outgoing> {
  /// Opens a WebSocket connection with the specified options.
  ///
  /// Creates a new WebSocket connection using the provided [options] and sets up
  /// event listeners.
  ///
  /// Returns a [Result] indicating success or failure of the connection attempt.
  Future<Result<void>> open(WebSocketOptions options);

  /// Closes the WebSocket connection.
  ///
  /// Closes the active WebSocket connection with the specified [closeCode] and [closeReason].
  ///
  /// Returns a [Result] indicating success or failure of the close operation.
  Future<Result<void>> close([int? closeCode, String? closeReason]);

  /// Sends a message through the WebSocket connection.
  ///
  /// Encodes and sends the [message] through the WebSocket connection.
  ///
  /// Returns a [Result] indicating success or failure of the send operation.
  Result<void> sendMessage(Outgoing message);
}

/// Interface for WebSocket message encoding and decoding.
///
/// Handles the serialization and deserialization of messages between WebSocket
/// transport format and application-specific types. Supports both text and binary formats.
abstract interface class WebSocketMessageCodec<Incoming, Outgoing> {
  /// Encodes an outgoing message for WebSocket transmission.
  ///
  /// Converts the [message] to either a [String] or [Uint8List] for transmission
  /// over the WebSocket connection. The encoding format depends on the implementation.
  ///
  /// Returns the encoded message as either a [String] or [Uint8List].
  Object /*String|Uint8List*/ encode(Outgoing message);

  /// Decodes an incoming WebSocket message.
  ///
  /// Converts the [message] received from the WebSocket (either [String] or [Uint8List])
  /// to the application-specific incoming message type.
  ///
  /// Returns the decoded message of type [Incoming].
  Incoming decode(Object /*String|Uint8List*/ message);
}

/// Interface for receiving WebSocket engine events.
///
/// Implementations of this interface receive callbacks for WebSocket connection
/// lifecycle events and message handling from the [WebSocketEngine].
abstract interface class WebSocketEngineListener<Incoming> {
  /// Called when the WebSocket connection is successfully opened.
  ///
  /// This indicates that the WebSocket connection has been established and is ready
  /// for message transmission. Implementations should update their connection state
  /// and perform any necessary initialization.
  void onOpen();

  /// Called when a message is received from the WebSocket.
  ///
  /// The [message] is the decoded incoming message that should be processed by
  /// the implementation. The message type depends on the configured message codec.
  void onMessage(Incoming message);

  /// Called when an error occurs on the WebSocket connection.
  ///
  /// The [error] contains the error details and [stackTrace] provides debugging
  /// information. Implementations should handle the error appropriately, typically
  /// by updating connection state and potentially triggering reconnection logic.
  void onError(Object error, [StackTrace? stackTrace]);

  /// Called when the WebSocket connection is closed.
  ///
  /// The [closeCode] and [closeReason] provide details about why the connection
  /// was closed. Implementations should update their connection state and determine
  /// whether reconnection is appropriate based on the close reason.
  void onClose([int? closeCode, String? closeReason]);
}

/// A strongly-typed wrapper around an integer WebSocket close code, as defined
/// by the [RFC 6455 WebSocket Protocol](https://datatracker.ietf.org/doc/html/rfc6455#section-7.4).
///
/// This type behaves like an `int` at runtime, but gives you named constants for
/// the standard codes while remaining open-ended for custom codes.
///
/// Example:
/// ```dart
/// socket.close(CloseCode.normalClosure);
/// if (closeCode == CloseCode.goingAway) {
///   print('Server is shutting down.');
/// }
/// ```
extension type const CloseCode(int code) implements int {
  /// `0` – The connection was closed without a specific reason.
  static const invalid = CloseCode(0);

  /// `1000` – The purpose for which the connection was established
  /// has been fulfilled.
  static const normalClosure = CloseCode(1000);

  /// `1001` – An endpoint is "going away", such as:
  /// - a server going down,
  /// - a browser navigating away from a page.
  static const goingAway = CloseCode(1001);

  /// `1002` – An endpoint is terminating the connection due to a protocol error.
  static const protocolError = CloseCode(1002);

  /// `1003` – An endpoint is terminating the connection because it has received
  /// a type of data it cannot accept.
  ///
  /// For example: an endpoint that only accepts text data may send this if it
  /// receives a binary message.
  static const unsupportedData = CloseCode(1003);

  /// `1005` – No status code was present.
  ///
  /// This **must not** be set explicitly by an endpoint.
  static const noStatusReceived = CloseCode(1005);

  /// `1006` – The connection was closed abnormally, without sending or receiving
  /// a Close control frame.
  ///
  /// This **must not** be set explicitly by an endpoint.
  static const abnormalClosure = CloseCode(1006);

  /// `1007` – An endpoint is terminating the connection because it has received
  /// data within a message that was not consistent with the type of the message.
  ///
  /// For example: receiving non-UTF-8 data in a text message.
  static const invalidFramePayloadData = CloseCode(1007);

  /// `1008` – An endpoint is terminating the connection because it has received
  /// a message that violates its policy.
  ///
  /// This is a generic status code that can be returned when no other more
  /// suitable code applies (such as [unsupportedData] or [messageTooBig]), or if
  /// details must be hidden.
  static const policyViolation = CloseCode(1008);

  /// `1009` – An endpoint is terminating the connection because it has received
  /// a message that is too big to process.
  static const messageTooBig = CloseCode(1009);

  /// `1010` – The client is terminating the connection because it expected the
  /// server to negotiate one or more extensions, but the server did not return
  /// them in the handshake response.
  ///
  /// The list of required extensions should appear in the close reason.
  /// **Note:** This is not used by servers (they can fail the handshake instead).
  static const mandatoryExtensionMissing = CloseCode(1010);

  /// `1011` – The server is terminating the connection because it encountered an
  /// unexpected condition that prevented it from fulfilling the request.
  static const internalServerError = CloseCode(1011);

  /// `1015` – The connection was closed due to a failure to perform a TLS handshake.
  ///
  /// For example: the server certificate could not be verified.
  /// This **must not** be set explicitly by an endpoint.
  static const tlsHandshakeFailure = CloseCode(1015);
}

class WebSocketEngineException with EquatableMixin implements Exception {
  const WebSocketEngineException({
    String? reason,
    int? code = 0,
    this.error,
  }) : reason = reason ?? 'Unknown',
       code = code ?? 0;

  final String reason;
  final int code;
  final Object? error;

  /// Returns the error as a StreamApiError if it is of that type or
  /// null otherwise.
  StreamApiError? get apiError {
    if (error case final StreamApiError error) return error;
    return null;
  }

  static const stopErrorCode = 1000;

  @override
  List<Object?> get props => [reason, code, error];
}
