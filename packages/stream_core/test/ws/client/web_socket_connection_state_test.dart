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
      'is enabled when the token has expired, which another token replaces',
      () {
        // 40 = expired; the server returns 401 with it, so the client-error rule
        // has to make room for this one.
        expect(_serverDisconnect(_apiError(40)).isAutomaticReconnectionEnabled, isTrue);
      },
    );

    test('is disabled when another token would be refused too', () {
      // 41 not valid yet, 42 used before issued, 43 signed with the wrong
      // secret, 2 wrong API key — none of which a fresh token repairs.
      for (final code in [41, 42, 43, 2]) {
        expect(
          _serverDisconnect(_apiError(code)).isAutomaticReconnectionEnabled,
          isFalse,
          reason: 'code $code',
        );
      }
    });

    test('is disabled for any other client error', () {
      // 17 = not allowed. Nothing about retrying changes the answer.
      final state = _serverDisconnect(_apiError(17, statusCode: 403));

      expect(state.isAutomaticReconnectionEnabled, isFalse);
    });

    test('is enabled for a server-side failure', () {
      // Stream error codes never fall in 400..499, so this is classified by the
      // status code alone — which is what the ported rule got wrong.
      final state = _serverDisconnect(_apiError(9, statusCode: 500));

      expect(state.isAutomaticReconnectionEnabled, isTrue);
    });

    test('is disabled when the socket was closed deliberately', () {
      const state = Disconnected(
        source: ServerInitiated(
          error: WebSocketEngineException(
            code: CloseCode.normalClosure,
          ),
        ),
      );

      expect(state.isAutomaticReconnectionEnabled, isFalse);
    });

    test('is enabled when the server closed without saying why', () {
      const state = Disconnected(source: ServerInitiated());

      expect(state.isAutomaticReconnectionEnabled, isTrue);
    });

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
