import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

StreamApiError _apiError({required int code}) => StreamApiError(
  code: code,
  details: const [],
  duration: '0ms',
  message: 'error $code',
  moreInfo: '',
  statusCode: 401,
);

void main() {
  group('WebSocketEngineException', () {
    test('reads the API error out of a closure the server explained', () {
      final apiError = _apiError(code: 40);

      // This is what decides whether a closure is reconnected, so it has to survive being wrapped.
      expect(WebSocketEngineException(error: apiError).apiError, apiError);
    });

    test('has no API error for a closure that carried something else', () {
      // A socket that gave out carries the failure it hit, which says nothing about credentials.
      expect(WebSocketEngineException(error: StateError('socket died')).apiError, isNull);
    });

    test('stands in for a code and reason it was not given', () {
      const exception = WebSocketEngineException();

      // A closure with no code is not the same as one closed normally, which is never reconnected.
      expect(exception.code, 0);
      expect(exception.code, isNot(CloseCode.normalClosure));
      expect(exception.reason, 'Unknown');
    });

    test('stands in for a code given as null', () {
      // The engine reads this off a socket, which reports null for a closure it never saw. Unlike
      // the reason, the code has a non-null default, so passing null has to be handled too.
      expect(const WebSocketEngineException(code: null).code, 0);
    });

    test('compares by what it carries', () {
      final apiError = _apiError(code: 40);

      expect(
        WebSocketEngineException(code: 1000, reason: 'bye', error: apiError),
        WebSocketEngineException(code: 1000, reason: 'bye', error: apiError),
      );
      expect(
        const WebSocketEngineException(code: 1000),
        isNot(const WebSocketEngineException(code: 1011)),
      );
    });
  });
}
