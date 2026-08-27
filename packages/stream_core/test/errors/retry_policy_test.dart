import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

StreamApiException _api(
  int code, {
  int statusCode = 400,
  bool unrecoverable = false,
}) => StreamApiException(
  message: 'error $code',
  statusCode: statusCode,
  code: StreamErrorCode(code),
  unrecoverable: unrecoverable,
);

void main() {
  group('isRetriable', () {
    test('never retries what the server declared unrecoverable', () {
      // A 500 would otherwise retry; the server's own verdict overrides it.
      expect(_api(17, statusCode: 500, unrecoverable: true).isRetriable, isFalse);
    });

    test('retries a rate limit, which clears on its own', () {
      expect(_api(9, statusCode: 429).isRetriable, isTrue);
    });

    test('retries a token that is not valid yet, since waiting is the fix', () {
      for (final code in [41, 42]) {
        expect(_api(code, statusCode: 401).isRetriable, isTrue, reason: 'code $code');
      }
    });

    test('retries a server-side request timeout, which is not a verdict on the request', () {
      expect(_api(48, statusCode: 408).isRetriable, isTrue);
    });

    test('retries a server-side failure', () {
      expect(_api(-1, statusCode: 500).isRetriable, isTrue);
      expect(_api(112, statusCode: 503).isRetriable, isTrue);
    });

    test('does not retry an expired token, since the refresh already happened', () {
      // The SDK refreshes and retries code 40 once on its own; one that still
      // surfaced means a fresh token could not help.
      expect(_api(40, statusCode: 401).isRetriable, isFalse);
    });

    test('does not retry a verdict a resend reproduces', () {
      expect(_api(4).isRetriable, isFalse, reason: 'validation');
      expect(_api(17, statusCode: 403).isRetriable, isFalse, reason: 'permission');
      expect(_api(43, statusCode: 401).isRetriable, isFalse, reason: 'signature');
      expect(_api(2, statusCode: 401).isRetriable, isFalse, reason: 'api key');
    });

    test('does not retry a request the caller cancelled', () {
      const cancelled = StreamNetworkException(message: 'cancelled', isCancelled: true);

      expect(cancelled.isRetriable, isFalse);
    });

    test('retries a transport failure, whose outcome a later attempt can settle', () {
      const timeout = StreamNetworkException(message: 'timed out', isTimeout: true);
      const dropped = StreamNetworkException(message: 'gone', closeCode: CloseCode.abnormalClosure);

      expect(timeout.isRetriable, isTrue);
      expect(dropped.isRetriable, isTrue);
    });

    test('does not retry credentials that never went out', () {
      const auth = StreamAuthenticationException(message: 'no token');

      expect(auth.isRetriable, isFalse);
    });

    test('does not retry a failure inside the SDK', () {
      const client = StreamClientException(message: 'undecodable');

      expect(client.isRetriable, isFalse);
    });
  });

  group('RetryPolicy.standard', () {
    test('retries a retriable failure until the attempts run out', () {
      const policy = RetryPolicy.standard();
      final rateLimited = _api(9, statusCode: 429);

      expect(policy.shouldRetry(rateLimited, 1), isTrue);
      expect(policy.shouldRetry(rateLimited, 2), isTrue);
      expect(policy.shouldRetry(rateLimited, 3), isFalse);
    });

    test('never retries a verdict, however many attempts remain', () {
      const policy = RetryPolicy.standard();

      expect(policy.shouldRetry(_api(17, statusCode: 403), 1), isFalse);
    });
  });
}
