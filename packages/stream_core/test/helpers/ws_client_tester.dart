import 'dart:async';

import 'package:meta/meta.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart' as test;

import 'fake_server.dart';
import 'user_token.dart';

/// A network provider a test drives, in place of one watching a real interface.
class TestNetworkStateProvider implements NetworkStateProvider {
  TestNetworkStateProvider([NetworkState initial = NetworkState.connected]) : _state = MutableStateEmitter(initial);

  @override
  NetworkStateEmitter get state => _state;
  final MutableStateEmitter<NetworkState> _state;

  /// Reports the network as available, as regaining a connection does.
  void connect() => _state.value = NetworkState.connected;

  /// Reports the network as gone, as losing a connection does.
  void disconnect() => _state.value = NetworkState.disconnected;

  Future<void> close() => _state.close();
}

/// A lifecycle provider a test drives, in place of one watching the real app.
class TestLifecycleStateProvider implements LifecycleStateProvider {
  TestLifecycleStateProvider([LifecycleState initial = LifecycleState.foreground])
    : _state = MutableStateEmitter(initial);

  @override
  LifecycleStateEmitter get state => _state;
  final MutableStateEmitter<LifecycleState> _state;

  /// Reports the app as in use, as returning to it does.
  void foreground() => _state.value = LifecycleState.foreground;

  /// Reports the app as put away, as leaving it does.
  void background() => _state.value = LifecycleState.background;

  Future<void> close() => _state.close();
}

/// Everything a test drives a client through, and the signals it asserts on.
class WsClientTester {
  WsClientTester._({
    required this.client,
    required this.server,
    required this.network,
    required this.lifecycle,
    required this.states,
    required this._attempts,
    required this._tokenLoads,
    required this._subscription,
    required this._recovery,
    required this.tokens,
  });

  /// The client under test, driven through its public surface alone.
  final StreamWebSocketClient client;

  /// The server it is talking to.
  final FakeServer server;

  /// The manager the default authenticator loads credentials from.
  ///
  /// Point it at another user with `setTokenProvider` to model an app signing a different one in.
  final TokenManager tokens;

  /// The network the recovery handler is watching.
  final TestNetworkStateProvider network;

  /// The app lifecycle the recovery handler is watching.
  final TestLifecycleStateProvider lifecycle;

  /// Every connection state the client has reported, in order.
  ///
  /// An app can observe these, which is what makes them worth asserting on: a reconnection shows
  /// up as another [Connecting], and nothing else needs to be reached into to see it.
  final List<WebSocketConnectionState> states;

  final int Function() _attempts;
  final int Function() _tokenLoads;
  final StreamSubscription<WebSocketConnectionState> _subscription;
  final ConnectionRecoveryHandler? _recovery;

  /// How many connection attempts have been made, counted as the options were built for each.
  int get attempts => _attempts();

  /// How many times credentials have been loaded from the token provider.
  ///
  /// A reconnection that presents a token issued after a refusal shows up here as another load.
  int get tokenLoads => _tokenLoads();

  /// The current connection state.
  WebSocketConnectionState get connectionState => client.connectionState.value;

  /// Sends [frame] from the server and lets the client react to it.
  Future<void> emit(Map<String, Object?> frame) async {
    server.send(frame);
    await pumpEventQueue();
  }

  /// Waits for the work an action set off to finish.
  Future<void> pumpEventQueue({int times = 20}) => test.pumpEventQueue(times: times);

  /// Releases everything this tester holds.
  ///
  /// [wsClientTest] calls this. A test driving `fakeAsync` must not: these futures were
  /// created inside the fake zone, and awaiting them once it has been discarded never returns.
  /// Nothing outlives that zone, so there is nothing left to release.
  Future<void> dispose() async {
    await _subscription.cancel();
    await _recovery?.dispose();
    await client.dispose();
    await network.close();
    await lifecycle.close();
    server.dispose();
  }
}

/// Runs a test against a fully wired [StreamWebSocketClient].
///
/// Only the socket is stood in for: the engine, codec, authentication handler, health monitor and
/// recovery handler are the real ones, so a test drives the client the way an app does and the
/// server answers what the client actually sent.
///
/// [user] is who the client authenticates as, and who the server accepts by default. [tokenLoader]
/// replaces the default token, for a test that cares how often credentials are loaded or what is
/// presented the second time. [authenticator] replaces the whole handshake, for a client that sends
/// something else. Pass `authenticates: false` for a connection that needs nothing sent.
///
/// [recover] wires the recovery handler in, so a drop is reconnected as it is in an app. It is off
/// by default, because most tests are about what a single attempt does.
///
/// [connect] runs before [body] and defaults to connecting and asserting the connection was
/// established. Pass a callback of your own for a test that starts from somewhere else, or
/// `(_) {}` to start from a client that has never connected.
@isTest
void wsClientTest(
  String description, {
  String user = 'luke_skywalker',
  Future<UserToken> Function(String userId)? tokenLoader,
  WebSocketAuthenticator? authenticator,
  bool authenticates = true,
  TokenManager? tokens,
  bool recover = false,
  Duration? connectTimeout,
  bool handshakeFails = false,
  bool handshakeHangs = false,
  bool holdClose = false,
  Object? closeError,
  FutureOr<void> Function(WsClientTester tester)? connect,
  required FutureOr<void> Function(WsClientTester tester) body,
  Iterable<String> tags = const ['ws-client'],
}) {
  return test.test(
    description,
    tags: tags,
    () async {
      final tester = buildTester(
        user: user,
        tokenLoader: tokenLoader,
        authenticator: authenticator,
        authenticates: authenticates,
        tokens: tokens,
        recover: recover,
        connectTimeout: connectTimeout,
        handshakeFails: handshakeFails,
        handshakeHangs: handshakeHangs,
        holdClose: holdClose,
        closeError: closeError,
      );
      test.addTearDown(tester.dispose);

      await (connect ?? _defaultConnect)(tester);
      await body(tester);
    },
  );
}

// Connects and checks the connection was established, so a test body starts from a client that
// completed a handshake rather than one that merely tried.
Future<void> _defaultConnect(WsClientTester tester) async {
  await tester.client.connect();
  await tester.pumpEventQueue();

  test.expect(tester.connectionState, test.isA<Connected>());
}

/// Builds a tester without running a test around it, for a body that needs to control time.
///
/// A test that drives timers wraps its own `fakeAsync` and cannot await a connect across it, so it
/// calls this and connects by hand. Everything else should use [wsClientTest].
///
/// [handshakeFailsWhen] is asked before each attempt, for a test where only some of them fail. It
/// takes precedence over [handshakeFails], which applies to every attempt alike.
WsClientTester buildTester({
  String user = 'luke_skywalker',
  Future<UserToken> Function(String userId)? tokenLoader,
  WebSocketAuthenticator? authenticator,
  bool authenticates = true,
  TokenManager? tokens,
  bool recover = false,
  Duration? connectTimeout,
  bool handshakeFails = false,
  bool Function()? handshakeFailsWhen,
  bool handshakeHangs = false,
  bool holdClose = false,
  Object? closeError,
  String tag = 'SC:WsClient',
}) {
  final server = FakeServer(user: user);

  var tokenLoads = 0;
  final tokenManager =
      tokens ??
      TokenManager(
        userId: user,
        tokenProvider: TokenProvider.dynamic((userId) async {
          tokenLoads++;
          return tokenLoader?.call(userId) ?? generateTestUserToken(userId);
        }),
      );

  var attempts = 0;
  final client = StreamWebSocketClient(
    optionsBuilder: () {
      attempts++;
      return switch (connectTimeout) {
        final it? => WebSocketOptions(url: 'wss://example.com', connectTimeout: it),
        // Left to the class default, so the attempts that rely on it really go through it.
        null => const WebSocketOptions(url: 'wss://example.com'),
      };
    },
    wsProvider: (_) => server.connect(
      handshakeFails: handshakeFailsWhen?.call() ?? handshakeFails,
      handshakeHangs: handshakeHangs,
      holdClose: holdClose,
      closeError: closeError,
    ),
    onAuthenticate: switch (authenticates) {
      true => authenticator ?? _authenticatorFor(tokenManager),
      false => null,
    },
    messageCodec: const JsonCodec(),
    tag: tag,
  );

  final network = TestNetworkStateProvider();
  final lifecycle = TestLifecycleStateProvider();

  final recovery = switch (recover) {
    true => ConnectionRecoveryHandler(
      client: client,
      networkStateProvider: network,
      lifecycleStateProvider: lifecycle,
    ),
    false => null,
  };

  final states = <WebSocketConnectionState>[];
  // Cancelled by `WsClientTester.dispose`, which a `fakeAsync` test deliberately skips.
  // ignore: cancel_subscriptions
  final subscription = client.connectionState.listen(states.add);

  return WsClientTester._(
    client: client,
    server: server,
    network: network,
    lifecycle: lifecycle,
    states: states,
    attempts: () => attempts,
    tokenLoads: () => tokenLoads,
    subscription: subscription,
    recovery: recovery,
    tokens: tokenManager,
  );
}

// The handshake a consuming SDK performs: present a token, and replace one the server refused for
// having expired before presenting another.
WebSocketAuthenticator _authenticatorFor(TokenManager tokens) {
  return (send, previousError) async {
    // The refusal another token repairs. Left cached, the same token would be offered again.
    if (previousError?.isTokenExpiredError ?? false) tokens.expireToken();

    final token = await tokens.getToken();
    send(WsAuthMessageRequest(token: token.rawValue)).getOrThrow();
  };
}
