// ignore_for_file: invalid_use_of_protected_member, unawaited_futures

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_core/src/api/interceptors/auth_interceptor.dart';
import 'package:stream_core/src/errors/stream_error_code.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../mocks.dart';

void main() {
  late CoreHttpClient client;
  late TokenManager tokenManager;
  late AuthInterceptor authInterceptor;

  setUp(() {
    client = MockHttpClient();
    tokenManager = MockTokenManager();
    authInterceptor = AuthInterceptor(client, tokenManager);
  });

  test(
    '`onRequest` should add userId, authToken, authType in the request',
    () async {
      final options = RequestOptions(path: 'test-path');
      final handler = RequestInterceptorHandler();

      final headers = options.headers;
      final queryParams = options.queryParameters;
      expect(headers.containsKey('Authorization'), isFalse);
      expect(headers.containsKey('stream-auth-type'), isFalse);
      expect(queryParams.containsKey('user_id'), isFalse);

      const token = 'test-user-token';
      const userId = 'test-user-id';
      const user = User(id: userId, name: 'test-user-name');
      when(() => tokenManager.loadToken(refresh: any(named: 'refresh')))
          .thenAnswer((_) async => token);

      when(() => tokenManager.userId).thenReturn(user.id);
      when(() => tokenManager.authType).thenReturn('jwt');

      authInterceptor.onRequest(options, handler);

      final updatedOptions = (await handler.future).data as RequestOptions;
      final updateHeaders = updatedOptions.headers;
      final updatedQueryParams = updatedOptions.queryParameters;

      expect(updateHeaders.containsKey('Authorization'), isTrue);
      expect(updateHeaders['Authorization'], token);
      expect(updateHeaders.containsKey('stream-auth-type'), isTrue);
      expect(updateHeaders['stream-auth-type'], 'jwt');
      expect(updatedQueryParams.containsKey('user_id'), isTrue);
      expect(updatedQueryParams['user_id'], userId);

      verify(() => tokenManager.loadToken(refresh: any(named: 'refresh')))
          .called(1);
      verify(() => tokenManager.userId).called(1);
      verify(() => tokenManager.authType).called(1);
      verifyNoMoreInteractions(tokenManager);
    },
  );

  test(
    '`onRequest` should reject with error if `tokenManager.loadToken` throws',
    () async {
      final options = RequestOptions(path: 'test-path');
      final handler = RequestInterceptorHandler();

      authInterceptor.onRequest(options, handler);

      try {
        await handler.future;
      } catch (e) {
        // need to cast it as the type is private in dio
        final error = (e as dynamic).data;
        expect(error, isA<StreamDioException>());
        final clientException = (error as StreamDioException).error;
        expect(clientException, isA<ClientException>());
        expect(
          (clientException! as ClientException).message,
          'Failed to load auth token',
        );
      }
    },
  );

  test('`onError` should retry the request with refreshed token', () async {
    const path = 'test-request-path';
    final options = RequestOptions(path: path);
    const code = StreamErrorCode.tokenExpired;
    final errorResponse = createStreamApiError(
      code: codeFromStreamErrorCode(code),
      message: messageFromStreamErrorCode(code),
    );

    final response = Response(
      requestOptions: options,
      data: errorResponse.toJson(),
    );
    final err = DioException(requestOptions: options, response: response);
    final handler = ErrorInterceptorHandler();

    when(() => tokenManager.isStatic).thenReturn(false);

    const token = 'test-user-token';
    when(() => tokenManager.loadToken(refresh: true))
        .thenAnswer((_) async => token);

    when(() => client.fetch<dynamic>(options)).thenAnswer(
      (_) async => Response(
        requestOptions: options,
        statusCode: 200,
      ),
    );

    authInterceptor.onError(err, handler);

    final res = await handler.future;

    var data = res.data;
    expect(data, isA<Response<dynamic>>());
    data = data as Response;
    expect(data, isNotNull);
    expect(data.statusCode, 200);
    expect(data.requestOptions.path, path);

    verify(() => tokenManager.isStatic).called(1);

    verify(() => tokenManager.loadToken(refresh: true)).called(1);
    verifyNoMoreInteractions(tokenManager);

    verify(() => client.fetch<dynamic>(options)).called(1);
    verifyNoMoreInteractions(client);
  });

  test(
    '`onError` should reject with error if retried request throws',
    () async {
      const path = 'test-request-path';
      final options = RequestOptions(path: path);
      const code = StreamErrorCode.tokenExpired;
      final errorResponse = createStreamApiError(
        code: codeFromStreamErrorCode(code),
        message: messageFromStreamErrorCode(code),
      );
      final response = Response(
        requestOptions: options,
        data: errorResponse.toJson(),
      );
      final err = DioException(requestOptions: options, response: response);
      final handler = ErrorInterceptorHandler();

      when(() => tokenManager.isStatic).thenReturn(false);

      const token = 'test-user-token';
      when(() => tokenManager.loadToken(refresh: true))
          .thenAnswer((_) async => token);

      when(() => client.fetch<dynamic>(options)).thenThrow(err);

      authInterceptor.onError(err, handler);

      try {
        await handler.future;
      } catch (e) {
        // need to cast it as the type is private in dio
        final error = (e as dynamic).data;
        expect(error, isA<DioException>());
      }

      verify(() => tokenManager.isStatic).called(1);

      verify(() => tokenManager.loadToken(refresh: true)).called(1);
      verifyNoMoreInteractions(tokenManager);

      verify(() => client.fetch<dynamic>(options)).called(1);
      verifyNoMoreInteractions(client);
    },
  );

  test(
    '`onError` should reject with error if `tokenManager.isStatic` is true',
    () async {
      const path = 'test-request-path';
      final options = RequestOptions(path: path);
      const code = StreamErrorCode.tokenExpired;
      final errorResponse = createStreamApiError(
        code: codeFromStreamErrorCode(code),
        message: messageFromStreamErrorCode(code),
      );
      final response = Response(
        requestOptions: options,
        data: errorResponse.toJson(),
      );
      final err = DioException(requestOptions: options, response: response);
      final handler = ErrorInterceptorHandler();

      when(() => tokenManager.isStatic).thenReturn(true);

      authInterceptor.onError(err, handler);

      try {
        await handler.future;
      } catch (e) {
        // need to cast it as the type is private in dio
        final error = (e as dynamic).data;
        expect(error, isA<DioException>());
        final response = (error as DioException).toClientException();
        expect(response.apiError?.code, codeFromStreamErrorCode(code));
      }

      verify(() => tokenManager.isStatic).called(1);
      verifyNoMoreInteractions(tokenManager);
    },
  );

  test(
    '`onError` should reject with error if error is not a `tokenExpired error`',
    () async {
      const path = 'test-request-path';
      final options = RequestOptions(path: path);
      final response = Response<dynamic>(requestOptions: options);
      final err = DioException(requestOptions: options, response: response);
      final handler = ErrorInterceptorHandler();

      authInterceptor.onError(err, handler);

      try {
        await handler.future;
      } catch (e) {
        // need to cast it as the type is private in dio
        final error = (e as dynamic).data;
        expect(error, isA<DioException>());
      }
    },
  );
}
