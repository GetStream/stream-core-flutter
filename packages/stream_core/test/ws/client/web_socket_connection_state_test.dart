import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

StreamApiError _apiError(int code, {int statusCode = 401}) => StreamApiError(
  code: code,
  details: const [],
  duration: '0ms',
  message: 'error $code',
  moreInfo: '',
  statusCode: statusCode,
);

Disconnected _serverDisconnect(StreamApiError apiError) => Disconnected(
  source: ServerInitiated(
    error: WebSocketEngineException(reason: apiError.message, code: 4001, error: apiError),
  ),
);

const _healthCheck = HealthCheckInfo(connectionId: 'connection-id');

/// Every state a connection passes through, other than [except].
Iterable<WebSocketConnectionState> _everyStateBut(WebSocketConnectionState except) {
  return const <WebSocketConnectionState>[
    Initialized(),
    Connecting(),
    Authenticating(),
    Connected(healthCheck: _healthCheck),
    Disconnecting(source: UserInitiated()),
    Disconnected(source: UserInitiated()),
  ].where((it) => it != except);
}

void main() {
  test('automatic reconnection is enabled when the token has expired, since the next attempt loads another', () {
    // 40 is an expired token, the one token error that fixes itself, because a fresh token is
    // loaded before the next attempt authenticates.
    final state = _serverDisconnect(_apiError(40));

    expect(state.isAutomaticReconnectionEnabled, isTrue);
  });

  test('automatic reconnection is disabled when another token would be refused too', () {
    // 41 not valid yet, 42 used before issued, 43 wrong secret, 2 wrong API key. A fresh token
    // repairs none of them.
    for (final code in [41, 42, 43, 2]) {
      expect(_serverDisconnect(_apiError(code)).isAutomaticReconnectionEnabled, isFalse, reason: 'code $code');
    }
  });

  test('automatic reconnection is enabled when the request was rate limited', () {
    // 9 is a rate limit, sent as 429, which clears on its own without the caller doing anything.
    final state = _serverDisconnect(_apiError(9, statusCode: 429));

    expect(state.isAutomaticReconnectionEnabled, isTrue);
  });

  test('automatic reconnection is disabled for any other client error', () {
    // 17 is not allowed, and retrying does not change the answer.
    final state = _serverDisconnect(_apiError(17, statusCode: 403));

    expect(state.isAutomaticReconnectionEnabled, isFalse);
  });

  test('automatic reconnection is enabled for a server-side failure', () {
    // Stream error codes never fall in 400..499, so this is classified by the status code alone.
    final state = _serverDisconnect(_apiError(9, statusCode: 500));

    expect(state.isAutomaticReconnectionEnabled, isTrue);
  });

  test('automatic reconnection is disabled when the socket was closed deliberately', () {
    const state = Disconnected(
      source: ServerInitiated(error: WebSocketEngineException(code: CloseCode.normalClosure)),
    );

    expect(state.isAutomaticReconnectionEnabled, isFalse);
  });

  test('automatic reconnection is enabled when the server closed without saying why', () {
    const state = Disconnected(source: ServerInitiated());

    expect(state.isAutomaticReconnectionEnabled, isTrue);
  });

  test('automatic reconnection is disabled when a connection could not be authenticated, since the '
      'same credentials would fail again', () {
    const state = Disconnected(source: AuthenticationFailed(error: 'no token'));

    expect(state.isAutomaticReconnectionEnabled, isFalse);
  });

  test('automatic reconnection is enabled when a connected socket stops answering health checks', () {
    const state = Disconnected(source: UnHealthyConnection());

    expect(state.isAutomaticReconnectionEnabled, isTrue);
  });

  test('closeReason reads differently for every source', () {
    const sources = [
      UserInitiated(),
      ServerInitiated(),
      SystemInitiated(),
      UnHealthyConnection(),
      ConnectTimeout(),
      AuthenticationFailed(error: 'no token'),
    ];

    final reasons = sources.map((it) => it.closeReason).toSet();

    // A shared reason would report two different outcomes identically.
    expect(reasons, hasLength(sources.length));
  });

  test('a connection is active until it is closed', () {
    // A connection being made, or being closed, is still one an app must not open another over.
    for (final state in _everyStateBut(const Disconnected(source: UserInitiated()))) {
      expect(state.isActive, isTrue, reason: '$state');
    }

    expect(const Disconnected(source: UserInitiated()).isActive, isFalse);
  });

  test('a connection is connected only once it is established', () {
    expect(const Connected(healthCheck: _healthCheck).isConnected, isTrue);

    for (final state in _everyStateBut(const Connected(healthCheck: _healthCheck))) {
      expect(state.isConnected, isFalse, reason: '$state');
    }
  });
}
