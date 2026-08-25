import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../../helpers/logger.dart';
import '../../../helpers/web_socket.dart';

/// A codec that passes strings through untouched.
class _StringCodec implements WebSocketMessageCodec<String, String> {
  const _StringCodec();

  @override
  Object encode(String message) => message;

  @override
  String decode(Object message) => message.toString();
}

/// Records what the engine reported, in the order it reported it.
class _RecordingListener implements WebSocketEngineListener<String> {
  final closures = <({int? code, String? reason})>[];
  final messages = <String>[];
  int get opened => _opened;
  var _opened = 0;

  @override
  void onOpen() => _opened++;

  @override
  void onMessage(String message) => messages.add(message);

  @override
  void onError(Object error, [StackTrace? stackTrace]) {}

  @override
  void onClose([int? closeCode, String? closeReason]) {
    closures.add((code: closeCode, reason: closeReason));
  }
}

/// Builds an engine over a socket a test drives.
///
/// Pass [closeFails] for a socket that refuses to close.
({
  StreamWebSocketEngine<String, String> engine,
  _RecordingListener listener,
  FakeWebSocketChannel socket,
})
_subject({bool closeFails = false}) {
  final socket = FakeWebSocketChannel(
    closeError: closeFails ? Exception('close failed') : null,
  );
  addTearDown(socket.endStream);

  final listener = _RecordingListener();
  final engine = StreamWebSocketEngine<String, String>(
    wsProvider: (_) => socket,
    listener: listener,
    messageCodec: const _StringCodec(),
  );

  return (engine: engine, listener: listener, socket: socket);
}

/// Builds an engine that opens a fresh socket each time, for a test about more than one of them.
///
/// [_subject] reuses one socket, so a second `open` there fails on a stream already listened to
/// rather than on anything the engine decided.
({
  StreamWebSocketEngine<String, String> engine,
  _RecordingListener listener,
  List<FakeWebSocketChannel> sockets,
})
_subjectWithFreshSockets({bool holdFirstClose = false}) {
  final sockets = <FakeWebSocketChannel>[];
  final listener = _RecordingListener();

  final engine = StreamWebSocketEngine<String, String>(
    listener: listener,
    messageCodec: const _StringCodec(),
    wsProvider: (_) {
      final socket = FakeWebSocketChannel(holdClose: holdFirstClose && sockets.isEmpty);
      sockets.add(socket);
      return socket;
    },
  );

  addTearDown(() {
    for (final socket in sockets) {
      socket.endStream();
    }
  });

  return (engine: engine, listener: listener, sockets: sockets);
}

const _options = WebSocketOptions(url: 'wss://example.com');

void main() {
  test('reports the closure with the code and reason it was asked for', () async {
    final (:engine, :listener, socket: _) = _subject();
    await engine.open(_options);

    final result = await engine.close(CloseCode.normalClosure, 'done');

    expect(result.isSuccess, isTrue);
    expect(listener.closures, [(code: CloseCode.normalClosure, reason: 'done')]);
  });

  test('refuses to send once closed', () async {
    final (:engine, listener: _, socket: _) = _subject();
    await engine.open(_options);

    await engine.close();

    expect(engine.sendMessage('ping').isFailure, isTrue);
  });

  test('reports the closure once, however many ways it hears about it', () async {
    final (:engine, :listener, socket: _) = _subject();
    await engine.open(_options);

    await engine.close(CloseCode.normalClosure, 'done');
    // Long enough for a stream that ended to have reported it.
    await pumpEventQueue();

    // The socket ending is the same closure, not a second one: a listener told twice would treat
    // the echo as a fresh disconnection.
    expect(listener.closures, hasLength(1));
  });

  test('reports a socket that failed to close as a failure, not a closure', () async {
    final (:engine, :listener, socket: _) = _subject(closeFails: true);
    await engine.open(_options);

    final result = await engine.close(CloseCode.normalClosure, 'done');

    // Nothing closed, so nothing is announced. The caller hears the failure instead and decides
    // what to tell anyone waiting.
    expect(result.isFailure, isTrue);
    expect(listener.closures, isEmpty);
  });

  test('delivers nothing from a socket it has closed', () async {
    // A close that fails leaves the socket's stream running, which is what a message arriving after
    // the closure needs to come from.
    final (:engine, :listener, :socket) = _subject(closeFails: true);
    await engine.open(_options);

    await engine.close();
    socket.emit('late');
    await pumpEventQueue();

    // Delivered, it would arrive on a connection its listener has already been told is closed.
    expect(listener.messages, isEmpty);
  });

  test('lets go of a socket that failed to close', () async {
    final (:engine, listener: _, socket: _) = _subject(closeFails: true);
    await engine.open(_options);

    await engine.close();

    // A socket that refuses to close is not one this engine can use. Held on to, it would refuse
    // every later open, leaving no way to replace it.
    expect(engine.sendMessage('ping').isFailure, isTrue);
  });

  test('reports the closure when there was no connection to close', () async {
    final (:engine, :listener, socket: _) = _subject();

    final result = await engine.close(CloseCode.normalClosure, 'done');

    // The caller asked for a closed connection and has one. Staying silent would leave whoever is
    // waiting on the closure waiting for a report that never comes.
    expect(result.isSuccess, isTrue);
    expect(listener.closures, [(code: CloseCode.normalClosure, reason: 'done')]);
  });

  test('does not report the closure of a socket that has already been replaced', () async {
    // Only the first socket holds its close, so it is still closing when the next one opens.
    final (:engine, :listener, :sockets) = _subjectWithFreshSockets(holdFirstClose: true);

    await engine.open(_options);
    final closing = engine.close();
    await pumpEventQueue();
    await engine.open(_options);

    sockets.first.sink.completeClose();
    await closing;
    await pumpEventQueue();

    // Closing yields, so the second socket is already open by the time the first one finishes.
    // Reported now, its closure would bring down a connection that is being established.
    expect(listener.opened, 2);
    expect(listener.closures, isEmpty);
  });

  test('reports the closure for every close it is asked for', () async {
    final (:engine, :listener, socket: _) = _subject();
    await engine.open(_options);

    await engine.close(CloseCode.normalClosure, 'first');
    await engine.close(CloseCode.normalClosure, 'second');

    expect(listener.closures, [
      (code: CloseCode.normalClosure, reason: 'first'),
      (code: CloseCode.normalClosure, reason: 'second'),
    ]);
  });

  test('reports the socket as open', () async {
    final (:engine, :listener, socket: _) = _subject();

    final result = await engine.open(_options);

    expect(result.isSuccess, isTrue);
    expect(listener.opened, 1);
  });

  test('refuses to open a socket while one is still open', () async {
    final (:engine, :listener, :sockets) = _subjectWithFreshSockets();
    await engine.open(_options);

    final result = await engine.open(_options);

    // Closing the live socket to make room would hide a caller opening a second connection over a
    // connection it still has. Refused before a second socket is even created.
    expect(result.isFailure, isTrue);
    expect(sockets, hasLength(1));
    expect(sockets.single.sink.closedWith, isNull);
    expect(listener.closures, isEmpty);
  });

  test('reports a socket that ends on its own as closed', () async {
    final (:engine, :listener, :socket) = _subject();
    await engine.open(_options);

    socket.endStream();
    await pumpEventQueue();

    // A server that hangs up produces no close call, only a stream that ends.
    expect(listener.closures, hasLength(1));
  });

  test('refuses to send before a socket is open', () {
    final (:engine, listener: _, socket: _) = _subject();

    expect(engine.sendMessage('ping').isFailure, isTrue);
  });

  test('encodes what it sends', () async {
    final (:engine, listener: _, :socket) = _subject();
    await engine.open(_options);

    final result = engine.sendMessage('ping');

    expect(result.isSuccess, isTrue);
    expect(socket.sink.sent, ['ping']);
  });

  test('decodes what it receives', () async {
    final (:engine, :listener, :socket) = _subject();
    await engine.open(_options);

    socket.emit('pong');
    await pumpEventQueue();

    expect(listener.messages, ['pong']);
  });

  test('drops a message it cannot decode, rather than reporting it', () async {
    final socket = FakeWebSocketChannel();
    addTearDown(socket.endStream);

    final listener = _RecordingListener();
    final engine = StreamWebSocketEngine<String, String>(
      wsProvider: (_) => socket,
      listener: listener,
      messageCodec: const _ThrowingCodec(),
    );
    await engine.open(_options);

    socket.emit('garbage');
    await pumpEventQueue();

    // A frame the codec rejects says nothing about the connection, so it is not worth ending one
    // over.
    expect(listener.messages, isEmpty);
    expect(listener.closures, isEmpty);
  });

  test('reports a message it cannot decode to the logger, which is the only trace it arrived', () async {
    final socket = FakeWebSocketChannel();
    addTearDown(socket.endStream);

    final handler = RecordingLogHandler();
    final engine = StreamWebSocketEngine<String, String>(
      wsProvider: (_) => socket,
      listener: _RecordingListener(),
      messageCodec: const _ThrowingCodec(),
    );
    await engine.open(_options);

    await withStreamLogger(handler: handler, () async {
      socket.emit('garbage');
      await pumpEventQueue();
    });

    expect(handler.records.single.priority, StreamLogPriority.warning);
    expect(handler.records.single.tag, 'SC:WsEngine');
    expect(handler.records.single.error, isA<FormatException>());
  });

  test('says nothing when no handler is installed', () async {
    final socket = FakeWebSocketChannel();
    addTearDown(socket.endStream);

    final engine = StreamWebSocketEngine<String, String>(
      wsProvider: (_) => socket,
      listener: _RecordingListener(),
      messageCodec: const _ThrowingCodec(),
    );
    await engine.open(_options);

    final printed = capturePrints(() => socket.emit('garbage'));
    await pumpEventQueue();

    expect(printed, isEmpty);
  });
}

/// A codec that cannot decode anything, as one meeting an unknown frame cannot.
class _ThrowingCodec implements WebSocketMessageCodec<String, String> {
  const _ThrowingCodec();

  @override
  Object encode(String message) => message;

  @override
  String decode(Object message) => throw const FormatException('undecodable');
}
