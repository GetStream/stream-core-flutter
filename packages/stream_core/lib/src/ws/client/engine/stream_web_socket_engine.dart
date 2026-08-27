import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../errors.dart' show StreamNetworkException;
import '../../../logger.dart';
import '../../../utils.dart';
import 'web_socket_engine.dart';

/// Signature for a function that creates a [WebSocketChannel] based on [WebSocketOptions].
typedef WebSocketProvider = WebSocketChannel Function(WebSocketOptions options);

// Creates a [WebSocketChannel] based on the provided [WebSocketOptions].
//
// Parses the URL from [options] and establishes a WebSocket connection with the specified
// query parameters and protocols.
WebSocketChannel _createWebSocket(WebSocketOptions options) {
  final baseUrl = options.url.trim();

  final uri = Uri.parse(baseUrl).replace(
    queryParameters: options.queryParameters,
  );

  return WebSocketChannel.connect(uri, protocols: options.protocols);
}

/// A WebSocket engine implementation that handles low-level WebSocket operations.
///
/// Manages the WebSocket connection lifecycle, message encoding/decoding, and event notification.
/// This engine provides the foundation for higher-level WebSocket client functionality by handling
/// the transport layer concerns.
///
/// The engine supports both text and binary message formats through the [WebSocketMessageCodec]
/// and provides callbacks through [WebSocketEngineListener] for connection events.
class StreamWebSocketEngine<Inc, Out> implements WebSocketEngine<Out> {
  /// Creates a new instance of [StreamWebSocketEngine].
  StreamWebSocketEngine({
    WebSocketProvider? wsProvider,
    this._listener,
    required this._messageCodec,
    String tag = 'SC:WsEngine',
  }) : _logger = StreamLogger(tag),
       _wsProvider = wsProvider ?? _createWebSocket;

  final StreamLogger _logger;
  final WebSocketProvider _wsProvider;
  final WebSocketMessageCodec<Inc, Out> _messageCodec;

  /// Sets the listener for WebSocket events.
  ///
  /// The [l] parameter is the new listener that will receive connection events and messages.
  set listener(WebSocketEngineListener<Inc>? l) => _listener = l;
  WebSocketEngineListener<Inc>? _listener;

  WebSocketChannel? _ws;
  // ignore: cancel_subscriptions
  StreamSubscription<Object?>? _wsSubscription;

  @override
  Future<Result<void>> open(WebSocketOptions options) {
    return runSafely(() async {
      if (_ws != null) {
        throw StateError('WebSocket is already open. Call close() first.');
      }

      // Create a new WebSocket connection.
      final ws = _ws = _wsProvider.call(options);
      _wsSubscription = ws.stream.listen(
        _onData,
        onDone: _onDone,
        cancelOnError: false,
        onError: _listener?.onError,
      );

      await ws.ready;

      // A handshake already in flight outlives `close`, so a late one must not report a stale socket.
      if (_ws == ws) _listener?.onOpen();
    });
  }

  void _onDone() {
    // Capture the close code and reason before closing.
    final closeCode = _ws?.closeCode;
    final closeReason = _ws?.closeReason;

    // Close the connection and notify the listener.
    unawaited(close(closeCode, closeReason));
  }

  void _onData(Object? data) {
    // If data is null, we ignore it.
    if (data == null) return;

    final result = runSafelySync(() => _messageCodec.decode(data));
    if (result case Failure(:final error, :final stackTrace)) {
      return _logger.w(() => 'dropped an undecodable message', error: error, stackTrace: stackTrace);
    }

    final message = result.getOrNull();

    // If decoding failed, we ignore the message.
    if (message == null) return;

    // Otherwise, we notify the listener.
    return _listener?.onMessage(message);
  }

  @override
  Future<Result<void>> close([
    int? closeCode = CloseCode.normalClosure,
    String? closeReason = 'Closed by client',
  ]) {
    return runSafely(() async {
      final ws = _ws;
      final subscription = _wsSubscription;

      _ws = null;
      _wsSubscription = null;

      await subscription?.cancel();
      await ws?.sink.close(closeCode, closeReason);

      // A new socket can open while this one closes, and must not be brought down by its closure.
      if (_ws == null) _listener?.onClose(closeCode, closeReason);
    });
  }

  @override
  Result<void> sendMessage(Out message) {
    return runSafelySync(() {
      final ws = _ws;
      if (ws == null) {
        // A condition, not misuse: a correct caller can race a connection
        // that dropped between deciding to send and sending.
        throw const StreamNetworkException(message: 'The connection is not open, so nothing was sent');
      }

      final data = _messageCodec.encode(message);
      return ws.sink.add(data);
    });
  }
}
