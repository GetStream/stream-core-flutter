import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

StreamApiError _apiError({
  int code = 40,
  int statusCode = 401,
  String message = 'token expired',
  String moreInfo = '',
  bool? unrecoverable,
}) => StreamApiError(
  code: StreamErrorCode(code),
  details: const [],
  duration: '0ms',
  message: message,
  moreInfo: moreInfo,
  statusCode: statusCode,
  unrecoverable: unrecoverable,
);

void main() {
  group('StreamException', () {
    test('every kind can be caught as one', () {
      const exceptions = <StreamException>[
        StreamApiException(message: 'refused', statusCode: 400, code: StreamErrorCode.inputError),
        StreamNetworkException(message: 'offline'),
        StreamAuthenticationException(message: 'no token'),
        StreamClientException(message: 'broken'),
      ];

      for (final exception in exceptions) {
        // The point of one root: `on StreamException` always means "a Stream problem".
        expect(exception, isA<Exception>(), reason: '$exception');
        expect(() => throw exception, throwsA(isA<StreamException>()), reason: '$exception');
      }
    });

    test('compares by what it carries', () {
      const cause = FormatException('bad json');

      expect(
        const StreamClientException(message: 'broken', cause: cause),
        const StreamClientException(message: 'broken', cause: cause),
      );
      expect(
        const StreamClientException(message: 'broken'),
        isNot(const StreamNetworkException(message: 'broken')),
      );
    });

    test('tryFrom keeps one of ours, lifts a payload, and reads null otherwise', () {
      const ours = StreamAuthenticationException(message: 'no token');
      final payload = _apiError();

      expect(StreamException.tryFrom(ours), same(ours));
      expect(
        StreamException.tryFrom(payload),
        isA<StreamApiException>().having((it) => it.apiError, 'apiError', same(payload)),
      );
      expect(StreamException.tryFrom(StateError('bug')), isNull);
    });

    test('prints its kind, its message and its cause', () {
      const exception = StreamClientException(
        message: 'the event would not decode',
        cause: FormatException('bad json'),
      );

      final printed = exception.toString();

      // A log line has to say what happened without anyone unwrapping the object.
      expect(printed, contains('StreamClientException'));
      expect(printed, contains('the event would not decode'));
      expect(printed, contains('bad json'));
    });
  });

  group('StreamApiException', () {
    test('is built from the server payload, carrying it whole', () {
      final apiError = _apiError(moreInfo: 'https://getstream.io/docs');
      final exception = StreamApiException.fromApiError(apiError);

      expect(exception.message, 'token expired');
      expect(exception.code, 40);
      expect(exception.statusCode, 401);
      expect(exception.moreInfo, 'https://getstream.io/docs');
      expect(exception.apiError, same(apiError));
    });

    test('reads an empty moreInfo as absent', () {
      // WebSocket errors carry an empty string where REST errors carry a URL.
      expect(StreamApiException.fromApiError(_apiError()).moreInfo, isNull);
    });

    test('reads an absent unrecoverable as false, never as "retryable"', () {
      expect(StreamApiException.fromApiError(_apiError()).unrecoverable, isFalse);
      expect(StreamApiException.fromApiError(_apiError(unrecoverable: true)).unrecoverable, isTrue);
    });

    test('tells the token conditions apart, since each has a different fix', () {
      // 40 expired: a fresh token fixes it. 41/42 not valid yet: waiting fixes it. 43 wrong
      // secret and 2 wrong API key: configuration, nothing at runtime fixes them.
      StreamApiException forCode(int code) => StreamApiException.fromApiError(_apiError(code: code));

      expect(forCode(40).isTokenExpired, isTrue);
      expect(forCode(41).isTokenNotYetValid, isTrue);
      expect(forCode(42).isTokenNotYetValid, isTrue);
      expect(forCode(43).isTokenSignatureInvalid, isTrue);
      expect(forCode(2).isApiKeyInvalid, isTrue);

      // Each condition is exactly one of the four.
      for (final code in [40, 41, 42, 43, 2]) {
        final it = forCode(code);
        final holds = [it.isTokenExpired, it.isTokenNotYetValid, it.isTokenSignatureInvalid, it.isApiKeyInvalid];
        expect(holds.where((held) => held), hasLength(1), reason: 'code $code');
      }
    });

    test('carries a code the SDK does not know as its number', () {
      // The registry grows server-side; an unnamed code must survive decoding
      // and compare as a plain number.
      final exception = StreamApiException.fromApiError(_apiError(code: 999));

      expect(exception.code, 999);
      expect(exception.isTokenExpired, isFalse);
    });

    test('reads a rate limit off the status, not the code', () {
      expect(StreamApiException.fromApiError(_apiError(code: 9, statusCode: 429)).isRateLimited, isTrue);
      expect(StreamApiException.fromApiError(_apiError(code: 9, statusCode: 500)).isRateLimited, isFalse);
    });

    test('carries no code for a verdict that was not a Stream error', () {
      // An edge or proxy answers with a status and no Stream payload. No sentinel stands in for
      // the missing code, because any number would collide with a real one.
      const exception = StreamApiException(message: 'Gateway Timeout', statusCode: 504);

      expect(exception.code, isNull);
      expect(exception.apiError, isNull);
      expect(exception.toString(), isNot(contains('code:')));
      expect(exception.toString(), contains('(statusCode: 504)'));
    });

    test('prints the facts that change what a caller does next', () {
      const exception = StreamApiException(
        message: 'Too many requests',
        statusCode: 429,
        code: StreamErrorCode.rateLimited,
        unrecoverable: true,
        retryAfter: Duration(seconds: 7),
      );

      final printed = exception.toString();

      expect(printed, contains('unrecoverable'));
      expect(printed, contains('retryAfter: 7s'));
    });

    test('prints the facts a support ticket needs', () {
      final exception = StreamApiException.fromApiError(
        _apiError(moreInfo: 'https://getstream.io/docs/errors'),
      );

      final printed = exception.toString();

      expect(printed, contains('code: 40'));
      expect(printed, contains('statusCode: 401'));
      expect(printed, contains('token expired'));
      expect(printed, contains('https://getstream.io/docs/errors'));
    });
  });

  group('StreamNetworkException', () {
    test('defaults to a plain unexplained failure', () {
      const exception = StreamNetworkException(message: 'gone');

      expect(exception.isCancelled, isFalse);
      expect(exception.isTimeout, isFalse);
      expect(exception.closeCode, isNull);
    });

    test('prints the close code when the failure was a socket closure', () {
      const closed = StreamNetworkException(
        message: 'The connection was closed unexpectedly',
        closeCode: CloseCode.abnormalClosure,
      );

      expect(closed.toString(), contains('(closeCode: 1006)'));
      expect(const StreamNetworkException(message: 'offline').toString(), isNot(contains('closeCode')));
    });

    test('a different fact is a different failure', () {
      // `props` must see every field, or two failures that behave differently compare equal.
      expect(
        const StreamNetworkException(message: 'gone', isCancelled: true),
        isNot(const StreamNetworkException(message: 'gone')),
      );
      expect(
        const StreamNetworkException(message: 'gone', isTimeout: true),
        isNot(const StreamNetworkException(message: 'gone')),
      );
      expect(
        const StreamNetworkException(message: 'gone', closeCode: CloseCode.normalClosure),
        isNot(const StreamNetworkException(message: 'gone')),
      );
    });
  });
}
