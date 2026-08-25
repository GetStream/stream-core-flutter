import 'dart:convert';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

/// The body the API returns when it refuses a request.
Map<String, Object?> _errorBody({int code = 40, int statusCode = 401, String message = 'token expired'}) => {
  'code': code,
  'details': <int>[],
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
            data: body,
          ),
  );
}

void main() {
  group('DioException.apiError', () {
    test('reads the Stream error from a decoded body', () {
      final error = _failure(body: _errorBody(), statusCode: 401).apiError;

      expect(error?.code, 40);
      expect(error?.statusCode, 401);
    });

    test('reads the Stream error from a body the server sent as text', () {
      // Without a JSON content type Dio hands the body over as a string, and the refusal is the
      // same one either way.
      final error = _failure(body: jsonEncode(_errorBody()), statusCode: 401).apiError;

      expect(error?.code, 40);
    });

    test('reads null from a body that is not a Stream error', () {
      // A proxy or gateway can answer with JSON of its own, which must not throw on the way out.
      expect(_failure(body: {'error': 'gateway timeout'}, statusCode: 504).apiError, isNull);
      expect(_failure(body: 'not json at all', statusCode: 502).apiError, isNull);
      expect(_failure(statusCode: 500).apiError, isNull);
      expect(_failure().apiError, isNull);
    });
  });

  group('DioException.toClientException', () {
    test('takes its message, status code and cause from the Stream error', () {
      // The error and the response deliberately disagree, so each assertion says which one won.
      // Given the same values, either source would satisfy them.
      final exception = _failure(
        body: _errorBody(statusCode: 429),
        statusCode: 500,
        statusMessage: 'Internal Server Error',
      ).toClientException();

      // The API's own account of the failure says more than the transport's, so it wins.
      expect(exception.message, 'token expired');
      expect(exception.statusCode, 429);
      expect(exception.apiError?.code, 40);
    });

    test('falls back to what the transport reported when the response carried no Stream error', () {
      final dioException = _failure(
        body: {'error': 'gateway timeout'},
        statusCode: 504,
        statusMessage: 'Gateway Timeout',
      );

      final exception = dioException.toClientException();

      expect(exception.message, 'Gateway Timeout');
      expect(exception.statusCode, 504);
      // Nothing better to blame, so the transport failure is the cause.
      expect(exception.underlyingError, same(dioException));
      expect(exception.apiError, isNull);
    });

    test('falls back to the exception message when there is no response at all', () {
      final exception = _failure(message: 'connection refused').toClientException();

      expect(exception.message, 'connection refused');
      expect(exception.statusCode, isNull);
    });

    test('never leaves the message null, so a caller always has something to show', () {
      final exception = _failure().toClientException();

      expect(exception.message, isEmpty);
    });

    test('marks a request the caller cancelled as such', () {
      final cancelled = _failure(type: DioExceptionType.cancel).toClientException();
      final refused = _failure(body: _errorBody(), statusCode: 401).toClientException();

      // A caller that called the request off should not be shown it as a failure.
      expect(cancelled.isRequestCancelledError, isTrue);
      expect(refused.isRequestCancelledError, isFalse);
    });
  });
}
