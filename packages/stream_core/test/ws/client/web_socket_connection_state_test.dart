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
      'is disabled when the server closes with a token-expired error, so an '
      'expired (e.g. guest) token does not trigger a silent reconnect loop',
      () {
        // Token-invalid error codes are 40..42; 40 = token expired.
        final state = _serverDisconnect(_apiError(40));

        expect(state.isAutomaticReconnectionEnabled, isFalse);
      },
    );

    test('is enabled for a generic, retryable server-initiated disconnection', () {
      // A server error that is neither a normal closure (1000), a token error
      // (40..42), nor a client error (400..499) should still reconnect.
      final state = _serverDisconnect(_apiError(43));

      expect(state.isAutomaticReconnectionEnabled, isTrue);
    });
  });
}
