import 'package:dio/dio.dart';

import '../../errors.dart';
import '../../user.dart';
import '../stream_core_dio_error.dart';

/// Authentication interceptor that refreshes the token if
/// an auth error is received
class AuthInterceptor extends QueuedInterceptor {
  /// Initialize a new auth interceptor
  AuthInterceptor(this._dio, this._tokenManager);

  final Dio _dio;

  /// The token manager used in the client
  final TokenManager _tokenManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenManager.getToken();

      options.queryParameters['user_id'] = token.userId;
      options.headers['Authorization'] = token.rawValue;
      options.headers['stream-auth-type'] = token.authType.headerValue;

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
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final data = err.response?.data;
    if (data == null || data is! Map<String, dynamic>) {
      return handler.next(err);
    }

    final error = StreamApiError.fromJson(data);
    if (error.isTokenExpiredError) {
      // Don't try to refresh the token when there is no user to load one for,
      // or when the provider would return the same token again.
      final canRefresh = _tokenManager.userId != null && !_tokenManager.usesStaticProvider;
      if (!canRefresh) return handler.next(err);
      // Otherwise, mark the current token as expired.
      _tokenManager.expireToken();

      try {
        final options = err.requestOptions;
        // ignore: inference_failure_on_function_invocation
        final response = await _dio.fetch(options);
        return handler.resolve(response);
      } on DioException catch (exception) {
        return handler.next(exception);
      }
    }

    return handler.next(err);
  }
}
