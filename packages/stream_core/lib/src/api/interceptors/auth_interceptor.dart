import 'package:dio/dio.dart';

import '../../errors.dart';
import '../../errors/stream_error_code.dart';
import '../http_client.dart';
import '../stream_core_dio_error.dart';
import '../token_manager.dart';

/// Authentication interceptor that refreshes the token if
/// an auth error is received
class AuthInterceptor extends QueuedInterceptor {
  /// Initialize a new auth interceptor
  AuthInterceptor(this._client, this._tokenManager);

  final CoreHttpClient _client;

  /// The token manager used in the client
  final TokenManager _tokenManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenManager.loadToken();

      final params = {'user_id': _tokenManager.userId};
      final headers = {
        'Authorization': token,
        'stream-auth-type': _tokenManager.authType,
      };
      options
        ..queryParameters.addAll(params)
        ..headers.addAll(headers);
      return handler.next(options);
    } catch (e, stackTrace) {
      final error = ClientException(
        message: 'Failed to load auth token',
        stackTrace: stackTrace,
        error: e,
      );
      final dioError = StreamDioException(
        exception: error,
        requestOptions: options,
        stackTrace: StackTrace.current,
      );
      return handler.reject(dioError, true);
    }
  }

  @override
  Future<void> onError(
    DioException exception,
    ErrorInterceptorHandler handler,
  ) async {
    final data = exception.response?.data;
    if (data == null || data is! Map<String, dynamic>) {
      return handler.next(exception);
    }

    final error = StreamApiError.fromJson(data);
    if (error.isTokenExpiredError) {
      if (_tokenManager.isStatic) return handler.next(exception);
      await _tokenManager.loadToken(refresh: true);
      try {
        final options = exception.requestOptions;
        // ignore: inference_failure_on_function_invocation
        final response = await _client.fetch(options);
        return handler.resolve(response);
      } on DioException catch (exception) {
        return handler.next(exception);
      }
    }
    return handler.next(exception);
  }
}
