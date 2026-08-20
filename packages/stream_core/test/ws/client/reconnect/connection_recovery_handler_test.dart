import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _MockWebSocketChannel extends Mock implements WebSocketChannel {}

class _MockWebSocketSink extends Mock implements WebSocketSink {}

/// A stream whose subscription cancels without going through the event loop, so
/// a close under `fakeAsync` runs to completion as it does in production.
class _CancellableStream<T> extends Stream<T> {
  _CancellableStream(this._source);

  final Stream<T> _source;

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _CancellableSubscription(
      _source.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError),
    );
  }
}

class _CancellableSubscription<T> implements StreamSubscription<T> {
  _CancellableSubscription(this._delegate);

  final StreamSubscription<T> _delegate;

  @override
  Future<void> cancel() {
    _delegate.cancel().ignore();
    return Future.value();
  }

  @override
  void onData(void Function(T data)? handleData) => _delegate.onData(handleData);

  @override
  void onError(Function? handleError) => _delegate.onError(handleError);

  @override
  void onDone(void Function()? handleDone) => _delegate.onDone(handleDone);

  @override
  void pause([Future<void>? resumeSignal]) => _delegate.pause(resumeSignal);

  @override
  void resume() => _delegate.resume();

  @override
  bool get isPaused => _delegate.isPaused;

  @override
  Future<E> asFuture<E>([E? futureValue]) => _delegate.asFuture(futureValue);
}

class _NoopCodec implements WebSocketMessageCodec<WsEvent, WsRequest> {
  const _NoopCodec();

  @override
  Object encode(WsRequest message) => '';

  @override
  WsEvent decode(Object message) => const _HealthCheckEvent();
}

final class _HealthCheckEvent extends WsEvent {
  const _HealthCheckEvent();

  @override
  HealthCheckInfo? get healthCheckInfo => const HealthCheckInfo(connectionId: 'connection-id');
}

final class _PingRequest extends WsRequest {
  const _PingRequest();

  @override
  Map<String, Object?> toJson() => const {};

  @override
  List<Object?> get props => const [];
}

/// A client whose socket opens but answers nothing, with a handler attached and
/// a count of the attempts it has made.
({StreamWebSocketClient client, int Function() attempts}) _client() {
  final incoming = StreamController<Object?>.broadcast();
  addTearDown(incoming.close);

  final channel = _MockWebSocketChannel();
  when(() => channel.ready).thenAnswer((_) async {});
  when(() => channel.stream).thenAnswer((_) => _CancellableStream(incoming.stream));
  final sink = _MockWebSocketSink();
  when(() => channel.sink).thenReturn(sink);
  when(() => sink.close(any(), any())).thenAnswer((_) async {});

  var attempts = 0;
  final client = StreamWebSocketClient(
    optionsBuilder: () {
      attempts++;
      return const WebSocketOptions(url: 'wss://example.com');
    },
    wsProvider: (_) => channel,
    pingRequestBuilder: ([_]) => const _PingRequest(),
    messageCodec: const _NoopCodec(),
  );

  final handler = ConnectionRecoveryHandler(client: client);
  addTearDown(handler.dispose);

  return (client: client, attempts: () => attempts);
}

void main() {
  group('ConnectionRecoveryHandler', () {
    test('does not retry a first attempt that never connected', () {
      fakeAsync((async) {
        final (:client, :attempts) = _client();

        client.connect().ignore();
        async.flushMicrotasks();

        // The socket opened but the server never answers, so the attempt is
        // abandoned — the failure the caller of `connect` is handed.
        async.elapse(WebSocketOptions.defaultConnectTimeout);
        async.flushMicrotasks();
        expect(client.connectionState.value, isA<Disconnected>());

        // Retrying here would work behind a caller already told it failed, and
        // would race the retry that caller makes in response.
        async.elapse(const Duration(minutes: 1));
        expect(attempts(), 1);
      });
    });

    test('retries a connection that dropped after being established', () {
      fakeAsync((async) {
        final (:client, :attempts) = _client();

        client.connect().ignore();
        async.flushMicrotasks();
        client.onMessage(const _HealthCheckEvent());
        expect(client.connectionState.value, isA<Connected>());

        // The connection stops answering health checks — a drop rather than a
        // failure to connect, so recovering it is this handler's job. The first
        // retry carries no delay, so it is under way by the time this returns.
        async.elapse(const Duration(seconds: 29));
        async.flushMicrotasks();

        expect(attempts(), 2);
        expect(client.connectionState.value, isA<Authenticating>());
      });
    });

    test('does not retry a disconnect the caller asked for', () {
      fakeAsync((async) {
        final (:client, :attempts) = _client();

        client.connect().ignore();
        async.flushMicrotasks();
        client.onMessage(const _HealthCheckEvent());

        client.disconnect().ignore();
        async.flushMicrotasks();
        expect(client.connectionState.value, isA<Disconnected>());

        // Having been connected is not enough on its own: the source still says
        // this was deliberate.
        async.elapse(const Duration(minutes: 1));
        expect(attempts(), 1);
      });
    });
  });
}
