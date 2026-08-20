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
  // A socket that closes cleanly; tests that need otherwise re-stub this.
  when(() => sink.close(any(), any())).thenAnswer((_) async {});

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
  group('StreamWebSocketClient.disconnect', () {
    test('leaves the connection closed, not closing, once it returns', () async {
      final (:client, :sink, incoming: _, optionsBuilt: _) = _client();
      await client.connect();

      await client.disconnect();

      // A caller that reconnects straight away would otherwise race the close
      // and see the connection go down again.
      expect(client.connectionState.value, isA<Disconnected>());
    });

    test('reports the connection closed even when the socket close fails', () async {
      final (:client, :sink, incoming: _, optionsBuilt: _) = _client();
      when(() => sink.close(any(), any())).thenThrow(Exception('close failed'));
      await client.connect();

      await client.disconnect();

      // The engine swallows the failure and never notifies its listener, which
      // used to leave the connection disconnecting for good.
      expect(
        client.connectionState.value,
        isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()),
      );
    });

    test('does not open a socket while the previous one is still closing', () async {
      final (:client, :sink, incoming: _, :optionsBuilt) = _client();
      // Held open so the connection is still closing when connect is called.
      final closing = Completer<void>();
      when(() => sink.close(any(), any())).thenAnswer((_) => closing.future);
      await client.connect();

      client.disconnect().ignore();
      expect(client.connectionState.value, isA<Disconnecting>());
      await client.connect();

      // The old socket's close event would otherwise bring the new connection
      // down and disarm the timeout meant to be watching it.
      expect(optionsBuilt(), 1);
      expect(client.connectionState.value, isA<Disconnecting>());
      closing.complete();
    });

    test('can be followed by another connect', () async {
      final (:client, :sink, incoming: _, :optionsBuilt) = _client();
      await client.connect();
      await client.disconnect();

      await client.connect();

      expect(client.connectionState.value, isA<Authenticating>());
      expect(optionsBuilt(), 2);
    });
  });

  group('StreamWebSocketClient.dispose', () {
    test('closes the connection and both emitters', () async {
      final (:client, :sink, incoming: _, optionsBuilt: _) = _client();
      await client.connect();

      await client.dispose();

      expect(client.isDisposed, isTrue);
      expect(client.events.isClosed, isTrue);
      expect(client.connectionState.isClosed, isTrue);
    });

    test('does nothing when called again', () async {
      final (:client, :sink, incoming: _, optionsBuilt: _) = _client();
      await client.connect();
      await client.dispose();

      await expectLater(client.dispose(), completes);
    });

    test('refuses to connect again', () async {
      final (:client, :sink, incoming: _, :optionsBuilt) = _client();
      await client.connect();
      await client.dispose();

      // Asserts rather than throws: a reconnect can come from the recovery
      // handler, which does not await it and cannot report an error.
      await expectLater(client.connect(), throwsA(isA<AssertionError>()));
      expect(optionsBuilt(), 1);
    });

    test('ignores a socket event arriving after it', () async {
      final (:client, :sink, incoming: _, optionsBuilt: _) = _client();
      await client.connect();
      await client.dispose();

      // The state emitter is closed, so a late event must not be reported into
      // it rather than throwing.
      expect(() => client.onClose(1000, 'late'), returnsNormally);
    });
  });

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
        isA<Disconnected>().having(
          (it) => it.source,
          'source',
          isA<AuthenticationFailed>().having((it) => it.error, 'error', isStateError),
        ),
      );
    });

    test('closes the connection when the authenticator throws', () async {
      // The natural authenticator awaits a token, and loading one throws rather
      // than returning a failure. Left unguarded the error escapes unhandled and
      // the connection waits for the timeout, which knows no cause.
      final (:client, :sink, incoming: _, optionsBuilt: _) = _client(
        onAuthenticate: (_) async => throw StateError('token load failed'),
      );

      await client.connect();
      await pumpEventQueue();

      expect(
        client.connectionState.value,
        isA<Disconnected>().having(
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
        // Only the source can be observed here: `disconnect` awaits the
        // subscription cancel, which `fakeAsync` never completes, so the state
        // settles at 'disconnecting'. The reached state is covered by the
        // `StreamWebSocketClient.disconnect` group.
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

        // Only the source can be observed here: `disconnect` awaits the
        // subscription cancel, which `fakeAsync` never completes, so the state
        // settles at 'disconnecting'. The reached state is covered by the
        // `StreamWebSocketClient.disconnect` group.
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

        // Only the source can be observed here: `disconnect` awaits the
        // subscription cancel, which `fakeAsync` never completes, so the state
        // settles at 'disconnecting'. The reached state is covered by the
        // `StreamWebSocketClient.disconnect` group.
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

        // Only the source can be observed here: `disconnect` awaits the
        // subscription cancel, which `fakeAsync` never completes, so the state
        // settles at 'disconnecting'. The reached state is covered by the
        // `StreamWebSocketClient.disconnect` group.
        expect(
          client.connectionState.value,
          isA<Disconnecting>().having((it) => it.source, 'source', isA<ConnectTimeout>()),
        );
      });
    });

    test('does not fire once the connection is established', () {
      fakeAsync((async) {
        // A timeout of its own, well short of the health monitor: the default
        // one outlives the monitor's first missed pong, so elapsing past it
        // would report an unhealthy connection instead.
        final (:client, :incoming, optionsBuilt: _, sink: _) = _client(
          connectTimeout: const Duration(seconds: 5),
        );

        client.connect().ignore();
        async.flushMicrotasks();
        client.onMessage(const _HealthCheckEvent());
        expect(client.connectionState.value, isA<Connected>());

        async.elapse(const Duration(seconds: 6));

        expect(client.connectionState.value, isA<Connected>());
      });
    });

    test('does not replace the source of a socket error that came first', () {
      fakeAsync((async) {
        final (:client, incoming: _, optionsBuilt: _, sink: _) = _client();

        client.connect().ignore();
        async.flushMicrotasks();

        // A socket error closes the connection without cancelling the timer.
        client.onError(StateError('socket died'));
        expect(client.connectionState.value, isA<Disconnecting>());

        async.elapse(WebSocketOptions.defaultConnectTimeout * 2);

        // Replacing this with `ConnectTimeout` would have made a reconnectable
        // failure permanent, since `ServerInitiated` is eligible and the
        // timeout used not to be.
        expect(
          client.connectionState.value,
          isA<Disconnecting>().having((it) => it.source, 'source', isA<ServerInitiated>()),
        );
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
        // Only the source can be observed here: `disconnect` awaits the
        // subscription cancel, which `fakeAsync` never completes, so the state
        // settles at 'disconnecting'. The reached state is covered by the
        // `StreamWebSocketClient.disconnect` group.
        expect(
          client.connectionState.value,
          isA<Disconnecting>().having((it) => it.source, 'source', isA<UserInitiated>()),
        );
      });
    });
  });

  group('StreamWebSocketClient health check while disconnecting', () {
    test('does not report the connection as established again', () async {
      final (:client, :sink, incoming: _, optionsBuilt: _) = _client();
      // Held open so the connection is still closing when the pong arrives.
      final closing = Completer<void>();
      when(() => sink.close(any(), any())).thenAnswer((_) => closing.future);

      await client.connect();
      client.onMessage(const _HealthCheckEvent());
      expect(client.connectionState.value, isA<Connected>());

      client.disconnect().ignore();
      expect(client.connectionState.value, isA<Disconnecting>());

      // Arrives before the socket finished closing.
      client.onMessage(const _HealthCheckEvent(connectionId: 'late'));

      expect(client.connectionState.value, isA<Disconnecting>());
      closing.complete();
    });

    test('leaves the disconnection source intact once the socket closes', () async {
      final (:client, :sink, incoming: _, optionsBuilt: _) = _client();
      final closing = Completer<void>();
      when(() => sink.close(any(), any())).thenAnswer((_) => closing.future);

      await client.connect();
      client.onMessage(const _HealthCheckEvent());
      client.disconnect().ignore();
      client.onMessage(const _HealthCheckEvent(connectionId: 'late'));

      closing.complete();
      await pumpEventQueue();

      // Without the guard the late health check moves the state back to
      // connected, and `onClose` then reports a server-initiated disconnect,
      // which is eligible for an automatic reconnect.
      final state = client.connectionState.value;
      expect(state, isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()));
      expect(state.isAutomaticReconnectionEnabled, isFalse);
    });
  });
}
