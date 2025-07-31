import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../errors/client_exception.dart';
import '../../utils.dart';
import '../events/sendable_event.dart';

import 'web_socket_channel_factory/web_socket_channel_factory.dart'
    if (dart.library.html) 'web_socket_channel_factory/web_socket_channel_factory_html.dart'
    if (dart.library.io) 'web_socket_channel_factory/web_socket_channel_factory_io.dart'
    as ws_platform;

abstract interface class WebSocketEngine {
  String get url;
  Future<void> connect();
  Future<void> disconnect([int? closeCode, String? closeReason]);
  void send({required SendableEvent message});
  Future<void> sendPing();
}

abstract interface class WebSocketEngineListener {
  void webSocketDidConnect();
  void webSocketDidDisconnect(WebSocketEngineException? exception);
  void webSocketDidReceiveMessage(Object message);
  void webSocketDidReceiveError(Object error, StackTrace stackTrace);
}

class URLSessionWebSocketEngine implements WebSocketEngine {
  URLSessionWebSocketEngine({
    required this.url,
    required this.listener,
    this.protocols,
    this.wsChannelFactory = const ws_platform.WebSocketChannelFactory(),
  });

  /// The URI to connect to.
  final String url;

  /// The protocols to use.
  final Iterable<String>? protocols;

  final WebSocketEngineListener listener;
  final ws_platform.WebSocketChannelFactory wsChannelFactory;

  var _connectRequestInProgress = false;

  WebSocketChannel? _ws;
  StreamSubscription<dynamic>? _wsSubscription;

  @override
  Future<Result<void>> connect() async {
    print(
      '[connect] connectRequestInProgress: '
      '$_connectRequestInProgress, url: $url',
    );
    try {
      if (_connectRequestInProgress) {
        print('Connect request already in progress');
        return Result.failure(
          WebSocketEngineException(
            reason: 'Connect request already in progress',
            code: 0,
          ),
        );
      }
      _connectRequestInProgress = true;

      final uri = Uri.parse(url);
      _ws = await wsChannelFactory.connect(uri, protocols: protocols);

      listener.webSocketDidConnect();

      _wsSubscription = _ws!.stream.listen(
        (message) => listener.webSocketDidReceiveMessage(message as Object),
        onError: listener.webSocketDidReceiveError,
        onDone: () => listener.webSocketDidDisconnect(
          WebSocketEngineException(
            code: _ws?.closeCode ?? 0,
            reason: _ws?.closeReason ?? 'Unknown',
          ),
        ),
      );
      return const Result.success(null);
    } catch (error, stackTrace) {
      print(() => '[connect] failed: $error');
      listener.webSocketDidReceiveError(error, stackTrace);
      return Result.failure(error, stackTrace);
    } finally {
      _connectRequestInProgress = false;
    }
  }

  @override
  Future<Result<void>> disconnect([int? closeCode, String? closeReason]) async {
    try {
      print(
        '[disconnect] connectRequestInProgress: '
        '$_connectRequestInProgress, url: $url',
      );
      await _ws?.sink.close(closeCode, closeReason);
      _ws = null;
      await _wsSubscription?.cancel();
      _wsSubscription = null;
      return const Result.success(null);
    } catch (error, stackTrace) {
      print(() => '[disconnect] failed: $error');
      return Result.failure(error, stackTrace);
    }
  }

  @override
  void send({required SendableEvent message}) {
    print('[send] hasWS: ${_ws != null}');
    _ws?.sink.add(message.toSerializedData());
  }

  @override
  Future<void> sendPing() {
    // TODO: implement sendPing
    throw UnimplementedError();
  }
}
