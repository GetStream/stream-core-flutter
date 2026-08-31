import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

StreamApiError _apiError(int code, {int statusCode = 401}) => StreamApiError(
  code: StreamErrorCode(code),
  details: const [],
  duration: '0ms',
  message: 'error $code',
  moreInfo: '',
  statusCode: statusCode,
);

Disconnected _serverDisconnect(StreamApiError apiError) => Disconnected(
  source: ServerInitiated(error: StreamApiException.fromApiError(apiError)),
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
    // 40 is an expired token, the token error that fixes itself, because a fresh token is
    // loaded before the next attempt authenticates.
    final state = _serverDisconnect(_apiError(40));

    expect(state.isAutomaticReconnectionEnabled, isTrue);
  });

  test('automatic reconnection is enabled when the token is not valid yet, since waiting is the fix', () {
    // 41 not valid yet and 42 used before issued are clock-skew conditions: the token becomes
    // valid on its own, so a later attempt can get past them where a fresh token cannot.
    for (final code in [41, 42]) {
      expect(_serverDisconnect(_apiError(code)).isAutomaticReconnectionEnabled, isTrue, reason: 'code $code');
    }
  });

  test('automatic reconnection is disabled when another attempt would be refused too', () {
    // 43 wrong secret, 2 wrong API key: configuration problems every retry reproduces.
    for (final code in [43, 2]) {
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

  test('automatic reconnection is disabled when the server said retrying will not help', () {
    const unrecoverable = StreamApiError(
      code: StreamErrorCode.notAllowed,
      details: [],
      duration: '0ms',
      message: 'not allowed',
      moreInfo: '',
      statusCode: 500,
      unrecoverable: true,
    );

    // A 500 would otherwise reconnect; the server's own verdict overrides the status.
    final state = Disconnected(
      source: ServerInitiated(error: StreamApiException.fromApiError(unrecoverable)),
    );

    expect(state.isAutomaticReconnectionEnabled, isFalse);
  });

  test('automatic reconnection is enabled for a server-side failure', () {
    // Stream error codes never fall in 400..499, so this is classified by the status code alone.
    final state = _serverDisconnect(_apiError(9, statusCode: 500));

    expect(state.isAutomaticReconnectionEnabled, isTrue);
  });

  test('automatic reconnection is disabled when the socket was closed deliberately', () {
    const state = Disconnected(
      source: ServerInitiated(
        error: StreamNetworkException(message: 'bye', closeCode: CloseCode.normalClosure),
      ),
    );

    expect(state.isAutomaticReconnectionEnabled, isFalse);
  });

  test('automatic reconnection is enabled when the socket was lost without a verdict', () {
    const state = Disconnected(
      source: ServerInitiated(
        error: StreamNetworkException(message: 'gone', closeCode: CloseCode.abnormalClosure),
      ),
    );

    expect(state.isAutomaticReconnectionEnabled, isTrue);
  });

  test('automatic reconnection is enabled when the server closed without saying why', () {
    const state = Disconnected(source: ServerInitiated());

    expect(state.isAutomaticReconnectionEnabled, isTrue);
  });

  test('automatic reconnection is disabled when a connection could not be authenticated, since the '
      'same credentials would fail again', () {
    const state = Disconnected(
      source: AuthenticationFailed(error: StreamAuthenticationException(message: 'no token')),
    );

    expect(state.isAutomaticReconnectionEnabled, isFalse);
  });

  test('automatic reconnection is enabled when authentication failed on the network, since the '
      'moment is at fault rather than the credentials', () {
    // A token endpoint that was briefly unreachable classifies as a network
    // failure and passes through the token manager as itself.
    const transient = Disconnected(
      source: AuthenticationFailed(error: StreamNetworkException(message: 'endpoint unreachable')),
    );
    const cancelled = Disconnected(
      source: AuthenticationFailed(error: StreamNetworkException(message: 'stopped', isCancelled: true)),
    );

    expect(transient.isAutomaticReconnectionEnabled, isTrue);
    expect(cancelled.isAutomaticReconnectionEnabled, isFalse);
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
      AuthenticationFailed(error: StreamAuthenticationException(message: 'no token')),
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

  group('cause', () {
    test('is the exception the server closed the connection with', () {
      final exception = StreamApiException.fromApiError(_apiError(40));
      final source = ServerInitiated(error: exception);

      // The exception is the caller-facing account of the closure; a caller matches on the
      // exception kind, and reads the raw payload off `apiError` when they need it.
      expect(source.cause, same(exception));
    });

    test('is null for a server closure that named no reason at all', () {
      expect(const ServerInitiated().cause, isNull);
    });

    test('is what authentication failed with', () {
      const error = StreamAuthenticationException(message: 'the token was refused');
      const source = AuthenticationFailed(error: error);

      expect(source.cause, same(error));
    });

    test('is null for the sources that carry none', () {
      // Nothing went wrong in these, or nothing that the source was told about.
      expect(const UserInitiated().cause, isNull);
      expect(const SystemInitiated().cause, isNull);
      expect(const UnHealthyConnection().cause, isNull);
      expect(const ConnectTimeout().cause, isNull);
    });
  });
}
