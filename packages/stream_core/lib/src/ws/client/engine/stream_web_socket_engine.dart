import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../logger/logger.dart';
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
    String tag = 'StreamWebSocketEngine',
    WebSocketProvider? wsProvider,
    WebSocketEngineListener<Inc>? listener,
    required WebSocketMessageCodec<Inc, Out> messageCodec,
  })  : _logger = TaggedLogger(tag),
        _wsProvider = wsProvider ?? _createWebSocket,
        _messageCodec = messageCodec,
        _listener = listener;

  final TaggedLogger _logger;
  final WebSocketProvider _wsProvider;
  final WebSocketMessageCodec<Inc, Out> _messageCodec;

  /// Sets the listener for WebSocket events.
  ///
  /// The [l] parameter is the new listener that will receive connection events and messages.
  set listener(WebSocketEngineListener<Inc>? l) => _listener = l;
  WebSocketEngineListener<Inc>? _listener;

  WebSocketChannel? _ws;
  StreamSubscription<Object?>? _wsSubscription;

  @override
  Future<Result<void>> open(WebSocketOptions options) {
    return runSafely(() async {
      if (_ws != null) {
        throw StateError('Web socket is already open. Call close() first.');
      }

      _ws = _wsProvider.call(options);

      await _ws?.ready.then((_) => _listener?.onOpen());

      _wsSubscription = _ws?.stream.listen(
        _onData,
        onError: _listener?.onError,
        onDone: () => _listener?.onClose(_ws?.closeCode, _ws?.closeReason),
        cancelOnError: false,
      );
    });
  }

  void _onData(Object? data) {
    // If data is null, we ignore it.
    if (data == null) return;

    final result = runSafelySync(() => _messageCodec.decode(data));
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
      if (_ws == null) {
        throw StateError('WebSocket is not open. Call open() first.');
      }

      await _ws?.sink.close(closeCode, closeReason);
      _ws = null;

      await _wsSubscription?.cancel();
      _wsSubscription = null;
    });
  }

  @override
  Result<void> sendMessage(Out message) {
    return runSafelySync(() {
      final ws = _ws;
      if (ws == null) {
        throw StateError('WebSocket is not open. Call open() first.');
      }

      final data = _messageCodec.encode(message);
      return ws.sink.add(data);
    });
  }
}
