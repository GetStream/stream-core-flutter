import 'dart:convert';

import 'package:stream_core/stream_core.dart';

import 'web_socket.dart';

/// The events the fake server sends, decoded from the wire the way a real client decodes them.
///
/// A consumer of `stream_core` brings its own event types, so these stand in for them: the shapes
/// the client itself reacts to, and nothing else.
sealed class TestEvent extends WsEvent {
  const TestEvent();

  /// Decodes a frame the server sent.
  ///
  /// Anything unrecognised becomes a [PlainEvent], which the client passes through to its
  /// listeners untouched.
  factory TestEvent.fromJson(Map<String, Object?> json) {
    return switch (json['type']) {
      'connection.ok' || 'health.check' => HealthCheck(
        connectionId: json['connection_id'] as String?,
      ),
      'connection.error' => ConnectionError(
        StreamApiError.fromJson(json['error']! as Map<String, Object?>),
      ),
      _ => PlainEvent(json['type']! as String),
    };
  }
}

/// The reply that establishes a connection, and the pong that keeps it alive.
final class HealthCheck extends TestEvent {
  const HealthCheck({this.connectionId = 'connection-id'});

  final String? connectionId;

  @override
  HealthCheckInfo? get healthCheckInfo => HealthCheckInfo(connectionId: connectionId);
}

/// The refusal a server sends before closing a connection it will not serve.
final class ConnectionError extends TestEvent {
  const ConnectionError(this.apiError);

  final StreamApiError apiError;

  @override
  Object? get error => apiError;
}

/// Anything the client has no special handling for, and emits to its listeners.
final class PlainEvent extends TestEvent {
  const PlainEvent(this.type);

  final String type;
}

/// The codec a client uses on the wire, so requests are really serialised and events really parsed.
class JsonCodec implements WebSocketMessageCodec<WsEvent, WsRequest> {
  const JsonCodec();

  @override
  Object encode(WsRequest message) => jsonEncode(message.toJson());

  @override
  WsEvent decode(Object message) {
    final json = jsonDecode(message as String) as Map<String, Object?>;
    return TestEvent.fromJson(json);
  }
}

/// Builds the error payload a server sends, in the shape the API returns it.
Map<String, Object?> connectionErrorFrame({required int code, int statusCode = 401}) {
  return {
    'type': 'connection.error',
    'connection_id': 'connection-id',
    'error': {
      'code': code,
      'message': 'error $code',
      'StatusCode': statusCode,
      'details': <int>[],
      'duration': '0ms',
      'more_info': '',
    },
  };
}

/// The refusal that another token repairs, which is why it is reconnected.
Map<String, Object?> expiredTokenFrame() => connectionErrorFrame(code: 40);

/// The refusal no other token repairs, which is why it is not.
Map<String, Object?> invalidSignatureFrame() => connectionErrorFrame(code: 43);

/// A server a test drives, which answers what the client actually sent.
///
/// Every frame the client puts on the socket is decoded and handed to [onFrame], whose reply goes
/// back over the same socket. Nothing is scripted in advance: a handshake succeeds because the
/// server accepted the credentials it was given, and a ping is answered because a ping arrived.
///
/// The default behaviour is a healthy server for [user]: it accepts a token issued to them,
/// refuses anyone else's with an invalid-signature error, and answers every ping.
class FakeServer {
  FakeServer({this.user = 'luke_skywalker'});

  /// The user whose token this server accepts.
  final String user;

  /// Called with each decoded frame the client sent, in place of the default behaviour.
  ///
  /// Return the frames to reply with, or an empty list to say nothing. Set this to model a server
  /// that refuses, goes quiet, or answers out of order.
  List<Map<String, Object?>> Function(Map<String, Object?> frame)? onFrame;

  /// Every frame the client has sent, decoded, in order.
  final received = <Map<String, Object?>>[];

  /// The socket of the attempt in flight, which is the one a reply is sent over.
  FakeWebSocketChannel get socket => _socket!;
  FakeWebSocketChannel? _socket;

  /// Every socket this server has handed out, in the order they were opened.
  final sockets = <FakeWebSocketChannel>[];

  /// Hands out a socket wired to this server, for a client's `wsProvider`.
  FakeWebSocketChannel connect({
    bool handshakeFails = false,
    bool handshakeHangs = false,
    bool holdClose = false,
    Object? closeError,
  }) {
    final socket = FakeWebSocketChannel(
      holdClose: holdClose,
      closeError: closeError,
      readyError: handshakeFails ? Exception('upgrade refused') : null,
      holdReady: handshakeHangs,
    );

    socket.sink.onSent = _onSent;
    sockets.add(socket);
    return _socket = socket;
  }

  void _onSent(Object? frame) {
    final json = jsonDecode(frame! as String) as Map<String, Object?>;
    received.add(json);

    final replies = onFrame?.call(json) ?? _defaultReply(json);
    replies.forEach(send);
  }

  List<Map<String, Object?>> _defaultReply(Map<String, Object?> frame) {
    // A ping is answered whatever else is going on: a live connection is one that keeps answering.
    if (frame['type'] == 'health.check') return [_connectionOk()];

    // Anything carrying a token is a client presenting credentials.
    if (frame['token'] case final String token) {
      if (_userOf(token) != user) return [invalidSignatureFrame()];
      return [_connectionOk()];
    }

    return const [];
  }

  Map<String, Object?> _connectionOk() {
    return {'type': 'connection.ok', 'connection_id': 'connection-id'};
  }

  /// Sends [frame] to the client, as a server pushing an event does.
  void send(Map<String, Object?> frame) => _socket?.emit(jsonEncode(frame));

  /// Hangs up without saying why, as a server dropping a connection does.
  void hangUp() => _socket?.endStream();

  /// Breaks the connection with a socket error, as a network failing mid-stream does.
  ///
  /// Distinct from [send]ing a `connection.error`: that is the server explaining itself over a
  /// working socket, this is the socket itself giving out.
  void fail(Object error) => _socket?.emitError(error);

  /// Closes every socket this server handed out.
  void dispose() {
    for (final socket in sockets) {
      socket.endStream();
    }
  }
}

// Reads the user a token was issued to, or null for anything that is not a readable JWT — which a
// real server treats the same way it treats a token naming the wrong user.
String? _userOf(String token) {
  final parts = token.split('.');
  if (parts.length < 2) return null;

  try {
    final payload = parts[1];
    final padded = payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');
    final claims = jsonDecode(utf8.decode(base64Url.decode(padded))) as Map<String, Object?>;
    return claims['user_id'] as String?;
  } on Object {
    return null;
  }
}
