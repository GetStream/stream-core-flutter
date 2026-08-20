import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

StreamApiError _apiError(int code) => StreamApiError(
  code: code,
  details: const [],
  duration: '0ms',
  message: 'error $code',
  moreInfo: '',
  statusCode: 401,
);

Disconnected _serverDisconnect(StreamApiError apiError) => Disconnected(
  source: ServerInitiated(
    error: WebSocketEngineException(
      reason: apiError.message,
      code: 4001,
      error: apiError,
    ),
  ),
);

void main() {
  group('WebSocketConnectionState.isAutomaticReconnectionEnabled', () {
    test(
      'is enabled when the server closes with a token-expired error, since the '
      'product replaces the credential before the attempt is made',
      () {
        // Token-invalid error codes are 40..42; 40 = token expired.
        final state = _serverDisconnect(_apiError(40));

        expect(state.isAutomaticReconnectionEnabled, isTrue);
      },
    );

    test('is enabled for a generic, retryable server-initiated disconnection', () {
      // A server error that is neither a normal closure (1000), a token error
      // (40..42), nor a client error (400..499) should still reconnect.
      final state = _serverDisconnect(_apiError(43));

      expect(state.isAutomaticReconnectionEnabled, isTrue);
    });

    test(
      'is enabled when a connection attempt timed out, since a handshake that '
      'did not complete in time is the same failure as one that stopped',
      () {
        const state = Disconnected(source: ConnectTimeout());

        expect(state.isAutomaticReconnectionEnabled, isTrue);
      },
    );

    test(
      'is disabled when a connection could not be authenticated, since the '
      'same credentials would fail again',
      () {
        const state = Disconnected(source: AuthenticationFailed(error: 'no token'));

        expect(state.isAutomaticReconnectionEnabled, isFalse);
      },
    );

    test('is enabled when a connected socket stops answering health checks', () {
      const state = Disconnected(source: UnHealthyConnection());

      expect(state.isAutomaticReconnectionEnabled, isTrue);
    });
  });

  group('DisconnectionSource.closeReason', () {
    test('reads differently for every source', () {
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
  });

  group('WebSocketOptions.defaultConnectTimeout', () {
    test('is the timeout used when the options do not say', () {
      const options = WebSocketOptions(url: 'wss://example.com');

      expect(options.connectTimeout, WebSocketOptions.defaultConnectTimeout);
      expect(WebSocketOptions.defaultConnectTimeout, const Duration(seconds: 30));
    });
  });
}
