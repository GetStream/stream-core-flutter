import 'dart:convert';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

/// The body the API returns when it refuses a request.
Map<String, Object?> _errorBody({
  int code = 40,
  int statusCode = 401,
  String message = 'token expired',
  Object? details = const <int>[],
}) => {
  'code': code,
  'details': details,
  'duration': '0ms',
  'message': message,
  'more_info': '',
  'StatusCode': statusCode,
};

DioException _failure({
  Object? body,
  int? statusCode,
  String? statusMessage,
  String? message,
  Map<String, List<String>>? headers,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    type: type,
    message: message,
    response: statusCode == null
        ? null
        : Response<Object?>(
            requestOptions: options,
            statusCode: statusCode,
            statusMessage: statusMessage,
            headers: Headers.fromMap(headers ?? const {}),
            data: body,
          ),
  );
}

void main() {
  group('DioException.toStreamException', () {
    test('reads the Stream error from a decoded body', () {
      final exception = _failure(body: _errorBody(), statusCode: 401).toStreamException();

      expect(
        exception,
        isA<StreamApiException>()
            .having((it) => it.code, 'code', 40)
            .having((it) => it.statusCode, 'statusCode', 401)
            .having((it) => it.message, 'message', 'token expired')
            .having((it) => it.isTokenExpired, 'isTokenExpired', isTrue),
      );
    });

    test('reads the Stream error from a body the server sent as text', () {
      // Without a JSON content type Dio hands the body over as a string, and the refusal is the
      // same one either way.
      final exception = _failure(body: jsonEncode(_errorBody()), statusCode: 401).toStreamException();

      expect(exception, isA<StreamApiException>().having((it) => it.code, 'code', 40));
    });

    test('survives a body whose details is an object rather than a list', () {
      // The backend serializes `details` as either a list or an object; the object variant must
      // not fail the whole error on the way out.
      final body = _errorBody(details: {'test': true});
      final exception = _failure(body: body, statusCode: 401).toStreamException();

      expect(
        exception,
        isA<StreamApiException>()
            .having((it) => it.code, 'code', 40)
            .having((it) => it.apiError?.details, 'apiError.details', isEmpty),
      );
    });

    test('reports a verdict even when the body is not a Stream error', () {
      // A proxy or gateway can answer with an error of its own: still a verdict, just one without
      // a Stream code.
      final dioException = _failure(
        body: {'error': 'gateway timeout'},
        statusCode: 504,
        statusMessage: 'Gateway Timeout',
      );

      final exception = dioException.toStreamException();

      expect(
        exception,
        isA<StreamApiException>()
            .having((it) => it.message, 'message', 'Gateway Timeout')
            .having((it) => it.statusCode, 'statusCode', 504)
            .having((it) => it.code, 'code', isNull)
            .having((it) => it.apiError, 'apiError', isNull)
            // Nothing better to blame, so the transport failure is the cause.
            .having((it) => it.cause, 'cause', same(dioException)),
      );
    });

    test('reads the Retry-After header on a rate limited response', () {
      final rateLimited = _failure(
        body: _errorBody(code: 9, statusCode: 429, message: 'Too many requests'),
        statusCode: 429,
        headers: {
          'retry-after': ['7'],
        },
      ).toStreamException();

      expect(
        rateLimited,
        isA<StreamApiException>()
            .having((it) => it.isRateLimited, 'isRateLimited', isTrue)
            .having((it) => it.retryAfter, 'retryAfter', const Duration(seconds: 7)),
      );
    });

    test('drops a Retry-After that is not a non-negative number of seconds', () {
      StreamException withHeader(String value) => _failure(
        body: _errorBody(code: 9, statusCode: 429, message: 'Too many requests'),
        statusCode: 429,
        headers: {
          'retry-after': [value],
        },
      ).toStreamException();

      expect(withHeader('-7'), isA<StreamApiException>().having((it) => it.retryAfter, 'retryAfter', isNull));
      expect(withHeader('soon'), isA<StreamApiException>().having((it) => it.retryAfter, 'retryAfter', isNull));
    });

    test('reports no verdict when there is no response at all', () {
      final exception = _failure(message: 'connection refused').toStreamException();

      expect(
        exception,
        isA<StreamNetworkException>()
            .having((it) => it.message, 'message', 'connection refused')
            .having((it) => it.isCancelled, 'isCancelled', isFalse),
      );
    });

    test('marks a timeout as such', () {
      final exception = _failure(type: DioExceptionType.receiveTimeout).toStreamException();

      expect(exception, isA<StreamNetworkException>().having((it) => it.isTimeout, 'isTimeout', isTrue));
    });

    test('marks a request the caller cancelled as such', () {
      final cancelled = _failure(type: DioExceptionType.cancel).toStreamException();
      final refused = _failure(body: _errorBody(), statusCode: 401).toStreamException();

      // A caller that called the request off should not be shown it as a failure.
      expect(cancelled, isA<StreamNetworkException>().having((it) => it.isCancelled, 'isCancelled', isTrue));
      expect(refused, isA<StreamApiException>());
    });

    test('never leaves the message empty of meaning, so a caller always has something to show', () {
      final exception = _failure().toStreamException();

      expect(exception.message, isNotEmpty);
    });

    test('passes an already mapped exception through untouched', () {
      const mapped = StreamAuthenticationException(message: 'no token');
      final dioException = StreamDioException(
        exception: mapped,
        requestOptions: RequestOptions(path: '/test'),
      );

      expect(dioException.toStreamException(), same(mapped));
    });

    test('keeps the classification of a Stream exception thrown loose in the chain', () {
      // An exception thrown inside an interceptor arrives wrapped in a plain
      // DioException; re-diagnosing it from the wrapper would read an
      // authentication failure as a network one.
      const loose = StreamAuthenticationException(message: 'no token');
      final wrapped = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: loose,
      );

      expect(wrapped.toStreamException(), same(loose));
    });
  });

  group('runApiSafely', () {
    test('returns the call result on success', () async {
      final result = await runApiSafely(() => 'ok');

      expect(result, const Result.success('ok'));
    });

    test('maps a transport failure onto the exception it represents', () async {
      final result = await runApiSafely<void>(
        () => throw _failure(body: _errorBody(), statusCode: 401),
      );

      expect(
        result.exceptionOrNull(),
        isA<StreamApiException>().having((it) => it.code, 'code', 40),
      );
    });

    test('keeps a Stream exception as it was raised', () async {
      const raised = StreamAuthenticationException(message: 'no token');
      final result = await runApiSafely<void>(() => throw raised);

      expect(result.exceptionOrNull(), same(raised));
    });

    test('reports a response that would not decode as an SDK failure', () async {
      // The call closure decodes wire data; a server that renamed a field
      // throws a TypeError there, which must surface as a handleable failure.
      final result = await runApiSafely<int>(() {
        const Object renamed = 'not an int';
        return renamed as int;
      });

      expect(
        result.exceptionOrNull(),
        isA<StreamClientException>().having((it) => it.cause, 'cause', isA<TypeError>()),
      );
    });

    test('reports a bug under the seam as an SDK failure carrying the Error', () async {
      final result = await runApiSafely<void>(() => throw StateError('misuse under the seam'));

      expect(
        result.exceptionOrNull(),
        isA<StreamClientException>().having((it) => it.cause, 'cause', isA<StateError>()),
      );
    });
  });
}
