import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../../helpers/user_token.dart';

StreamApiError _apiError(int code) => StreamApiError(
  code: code,
  details: const [],
  duration: '0ms',
  message: 'error $code',
  moreInfo: '',
  statusCode: 401,
);

ConnectionStateEmitter _stateOf(WebSocketConnectionState state) {
  return MutableConnectionStateEmitter(state);
}

WebSocketConnectionState _refused(StreamApiError apiError) {
  return WebSocketConnectionState.disconnected(
    source: DisconnectionSource.serverInitiated(
      error: WebSocketEngineException(error: apiError),
    ),
  );
}

void main() {
  group('TokenRefreshReconnectionPolicy', () {
    test('refuses to reconnect when the provider has only one token', () {
      final policy = TokenRefreshReconnectionPolicy(
        // Token-invalid error codes are 40..42; 40 = token expired.
        connectionState: _stateOf(_refused(_apiError(40))),
        tokenManager: TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
        ),
      );

      // Reconnecting would present the token the server just refused, over and
      // over — the loop this policy exists to prevent.
      expect(policy.canBeReconnected(), isFalse);
    });

    test('reconnects when the provider can issue another token', () {
      final policy = TokenRefreshReconnectionPolicy(
        connectionState: _stateOf(_refused(_apiError(40))),
        tokenManager: TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.dynamic(
            (userId) async => generateTestUserToken(userId),
          ),
        ),
      );

      expect(policy.canBeReconnected(), isTrue);
    });

    test('leaves every other disconnection to the other policies', () {
      final policy = TokenRefreshReconnectionPolicy(
        // A static provider, so this passes only because the disconnection has
        // nothing to do with the token.
        connectionState: _stateOf(
          const WebSocketConnectionState.disconnected(
            source: DisconnectionSource.unHealthyConnection(),
          ),
        ),
        tokenManager: TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
        ),
      );

      expect(policy.canBeReconnected(), isTrue);
    });
  });
}
