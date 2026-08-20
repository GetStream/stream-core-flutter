import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _MockWebSocketChannel extends Mock implements WebSocketChannel {}

class _MockWebSocketSink extends Mock implements WebSocketSink {}

/// A codec that is never exercised: these tests drive the client through its
/// engine listener callbacks rather than through encoded frames.
class _NoopCodec implements WebSocketMessageCodec<WsEvent, WsRequest> {
  const _NoopCodec();

  @override
  Object encode(WsRequest message) => '';

  @override
  WsEvent decode(Object message) => const _HealthCheckEvent();
}

final class _HealthCheckEvent extends WsEvent {
  const _HealthCheckEvent({this.connectionId = 'connection-id'});

  final String? connectionId;

  @override
  HealthCheckInfo? get healthCheckInfo {
    return HealthCheckInfo(connectionId: connectionId);
  }
}

final class _PingRequest extends WsRequest {
  const _PingRequest();

  @override
  Map<String, Object?> toJson() => const {};

  @override
  List<Object?> get props => const [];
}

/// Builds a client whose socket opens successfully but sends nothing, so the
/// handshake only progresses when a test drives it.
({
  StreamWebSocketClient client,
  StreamController<Object?> incoming,
  int Function() optionsBuilt,
  WebSocketSink sink,
})
_client({
  Duration connectTimeout = WebSocketOptions.defaultConnectTimeout,
  WebSocketAuthenticator? onAuthenticate,
}) {
  final incoming = StreamController<Object?>.broadcast();
  addTearDown(incoming.close);

  final channel = _MockWebSocketChannel();
  when(() => channel.ready).thenAnswer((_) async {});
  when(() => channel.stream).thenAnswer((_) => incoming.stream);
  final sink = _MockWebSocketSink();
  when(() => channel.sink).thenReturn(sink);

  var built = 0;
  final client = StreamWebSocketClient(
    optionsBuilder: () {
      built++;
      return WebSocketOptions(
        url: 'wss://example.com',
        connectTimeout: connectTimeout,
      );
    },
    onAuthenticate: onAuthenticate,
    wsProvider: (_) => channel,
    pingRequestBuilder: ([_]) => const _PingRequest(),
    messageCodec: const _NoopCodec(),
  );

  return (client: client, incoming: incoming, optionsBuilt: () => built, sink: sink);
}

void main() {
  group('StreamWebSocketClient.optionsBuilder', () {
    test('is called for every connection attempt, not once per client', () async {
      final (:client, :incoming, :optionsBuilt, sink: _) = _client();

      await client.connect();
      expect(optionsBuilt(), 1);

      await client.disconnect();
      client.onClose();

      await client.connect();
      expect(optionsBuilt(), 2);
    });
  });

  group('StreamWebSocketClient.onAuthenticate', () {
    test('is called once the socket is open, while authenticating', () async {
      WebSocketConnectionState? stateWhenCalled;
      late StreamWebSocketClient client;
      final built = _client(
        onAuthenticate: (_) async {
          stateWhenCalled = client.connectionState.value;
          return const Result.success(null);
        },
      );
      client = built.client;

      await client.connect();
      await pumpEventQueue();

      expect(stateWhenCalled, isA<Authenticating>());
    });

    test('is called once per connection attempt', () async {
      var calls = 0;
      final (:client, :incoming, optionsBuilt: _, sink: _) = _client(
        onAuthenticate: (_) async {
          calls++;
          return const Result.success(null);
        },
      );

      await client.connect();
      await pumpEventQueue();
      expect(calls, 1);

      await client.disconnect();
      client.onClose();

      await client.connect();
      await pumpEventQueue();
      expect(calls, 2);
    });

    test('is handed a sender that puts the request on the socket', () async {
      Result<void>? sent;
      final (:client, incoming: _, optionsBuilt: _, :sink) = _client(
        onAuthenticate: (send) async => sent = send(const _PingRequest()),
      );

      await client.connect();
      await pumpEventQueue();

      // The sender is only useful if it reaches the socket: an authenticator
      // that cannot send has nothing to report but failure.
      expect(sent, isA<Success<void>>());
      verify(() => sink.add(any<Object>())).called(1);
    });

    test('leaves the connection authenticating when it succeeds', () async {
      final (:client, :incoming, optionsBuilt: _, sink: _) = _client(
        onAuthenticate: (_) async => const Result.success(null),
      );

      await client.connect();
      await pumpEventQueue();

      // Sending the credentials does not establish the connection; the server
      // answering does.
      expect(client.connectionState.value, isA<Authenticating>());

      client.onMessage(const _HealthCheckEvent());
      expect(client.connectionState.value, isA<Connected>());
    });

    test('leaves the connection authenticating when there is no authenticator', () async {
      // A socket that has nothing to send before it is usable, such as one whose
      // protocol authenticates elsewhere.
      final (:client, :incoming, optionsBuilt: _, sink: _) = _client();

      await client.connect();
      await pumpEventQueue();

      expect(client.connectionState.value, isA<Authenticating>());

      client.onMessage(const _HealthCheckEvent());
      expect(client.connectionState.value, isA<Connected>());
    });
  });

  group('StreamWebSocketClient authentication failure', () {
    test('closes the connection instead of waiting for a reply', () async {
      final (:client, :incoming, optionsBuilt: _, sink: _) = _client(
        onAuthenticate: (_) async => Result.failure(StateError('no token')),
      );

      await client.connect();
      await pumpEventQueue();

      final state = client.connectionState.value;
      expect(
        state,
        isA<Disconnecting>().having(
          (it) => it.source,
          'source',
          isA<AuthenticationFailed>().having((it) => it.error, 'error', isStateError),
        ),
      );
    });

    test('is not retried, since the same credentials would fail again', () async {
      final (:client, :incoming, optionsBuilt: _, sink: _) = _client(
        onAuthenticate: (_) async => Result.failure(StateError('no token')),
      );

      await client.connect();
      await pumpEventQueue();
      client.onClose();

      final state = client.connectionState.value;
      expect(state, isA<Disconnected>());
      expect(state.isAutomaticReconnectionEnabled, isFalse);
    });
  });

  group('StreamWebSocketClient connect timeout', () {
    test('abandons an attempt that never becomes connected', () {
      fakeAsync((async) {
        final (:client, :incoming, optionsBuilt: _, sink: _) = _client();

        client.connect().ignore();
        async.flushMicrotasks();

        // The socket opened, so the client is authenticating with nothing else
        // watching it.
        expect(client.connectionState.value, isA<Authenticating>());

        // Still waiting a tick before the timeout is due.
        async.elapse(WebSocketOptions.defaultConnectTimeout - const Duration(seconds: 1));
        expect(client.connectionState.value, isA<Authenticating>());

        async.elapse(const Duration(seconds: 1));
        expect(
          client.connectionState.value,
          isA<Disconnecting>().having((it) => it.source, 'source', isA<ConnectTimeout>()),
        );
      });
    });

    test('abandons an attempt whose authenticator never returns', () {
      fakeAsync((async) {
        // The realistic hang: an authenticator awaiting something that never
        // resolves. Nothing else watches 'authenticating', so only this fires.
        final (:client, incoming: _, optionsBuilt: _, sink: _) = _client(
          onAuthenticate: (_) => Completer<Result<void>>().future,
        );

        client.connect().ignore();
        async.flushMicrotasks();
        expect(client.connectionState.value, isA<Authenticating>());

        async.elapse(WebSocketOptions.defaultConnectTimeout);

        expect(
          client.connectionState.value,
          isA<Disconnecting>().having((it) => it.source, 'source', isA<ConnectTimeout>()),
        );
      });
    });

    test('is armed again for a later attempt', () {
      fakeAsync((async) {
        final (:client, incoming: _, optionsBuilt: _, sink: _) = _client();

        client.connect().ignore();
        async.flushMicrotasks();
        async.elapse(WebSocketOptions.defaultConnectTimeout);
        client.onClose();
        expect(client.connectionState.value, isA<Disconnected>());

        client.connect().ignore();
        async.flushMicrotasks();
        async.elapse(WebSocketOptions.defaultConnectTimeout);

        expect(
          client.connectionState.value,
          isA<Disconnecting>().having((it) => it.source, 'source', isA<ConnectTimeout>()),
        );
      });
    });

    test('honours a timeout given in the options', () {
      fakeAsync((async) {
        final (:client, :incoming, optionsBuilt: _, sink: _) = _client(
          connectTimeout: const Duration(seconds: 2),
        );

        client.connect().ignore();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 2));

        expect(
          client.connectionState.value,
          isA<Disconnecting>().having((it) => it.source, 'source', isA<ConnectTimeout>()),
        );
      });
    });

    test('does not fire once the connection is established', () {
      fakeAsync((async) {
        final (:client, :incoming, optionsBuilt: _, sink: _) = _client();

        client.connect().ignore();
        async.flushMicrotasks();
        client.onMessage(const _HealthCheckEvent());
        expect(client.connectionState.value, isA<Connected>());

        // Past when the timeout would have fired, but before the health
        // monitor's first ping is due.
        async.elapse(WebSocketOptions.defaultConnectTimeout + const Duration(seconds: 1));

        expect(client.connectionState.value, isA<Connected>());
      });
    });

    test('does not replace the source of a disconnect that came first', () {
      fakeAsync((async) {
        final (:client, :incoming, optionsBuilt: _, sink: _) = _client();

        client.connect().ignore();
        async.flushMicrotasks();
        client.disconnect().ignore();
        async.flushMicrotasks();

        async.elapse(WebSocketOptions.defaultConnectTimeout * 2);

        // The timeout would otherwise report this deliberate disconnect as a
        // timed-out attempt, which reconnects differently.
        expect(
          client.connectionState.value,
          isA<Disconnecting>().having((it) => it.source, 'source', isA<UserInitiated>()),
        );
      });
    });
  });

  group('StreamWebSocketClient health check while disconnecting', () {
    test('does not report the connection as established again', () async {
      final (:client, :incoming, optionsBuilt: _, sink: _) = _client();

      await client.connect();
      client.onMessage(const _HealthCheckEvent());
      expect(client.connectionState.value, isA<Connected>());

      await client.disconnect();
      expect(client.connectionState.value, isA<Disconnecting>());

      // Arrives before the socket finished closing.
      client.onMessage(const _HealthCheckEvent(connectionId: 'late'));

      expect(client.connectionState.value, isA<Disconnecting>());
    });

    test('leaves the disconnection source intact once the socket closes', () async {
      final (:client, :incoming, optionsBuilt: _, sink: _) = _client();

      await client.connect();
      client.onMessage(const _HealthCheckEvent());
      await client.disconnect();
      client.onMessage(const _HealthCheckEvent(connectionId: 'late'));
      client.onClose();

      // Without the guard the late health check moves the state back to
      // connected, and `onClose` then reports a server-initiated disconnect,
      // which is eligible for an automatic reconnect.
      final state = client.connectionState.value;
      expect(state, isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()));
      expect(state.isAutomaticReconnectionEnabled, isFalse);
    });
  });
}
