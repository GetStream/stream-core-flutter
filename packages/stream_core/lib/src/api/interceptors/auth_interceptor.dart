import 'package:dio/dio.dart';

import '../../errors.dart';
import '../../user.dart';
import '../stream_core_dio_error.dart';

/// Provides the [TokenManager] currently in use by an [AuthInterceptor].
///
/// A getter rather than a fixed reference so the caller can swap the underlying
/// [TokenManager] at runtime — e.g. after a guest token exchange resolves a
/// server-assigned user id — and have the interceptor pick up the new instance.
typedef TokenManagerProvider = TokenManager Function();

/// Authentication interceptor that refreshes the token if
/// an auth error is received
class AuthInterceptor extends QueuedInterceptor {
  /// Initialize a new auth interceptor.
  ///
  /// [tokenManagerProvider] is a getter rather than a fixed reference so the
  /// caller can swap the underlying [TokenManager] — e.g. after a guest token
  /// exchange resolves a server-assigned user id — and have this interceptor
  /// pick up the new instance on its next request.
  AuthInterceptor(this._dio, this._tokenManagerProvider);

  final Dio _dio;

  /// Provides the token manager currently in use.
  final TokenManagerProvider _tokenManagerProvider;

  /// The token manager currently in use.
  TokenManager get _tokenManager => _tokenManagerProvider();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenManager.getToken();

      // Re-read the token manager after awaiting the token: loading it may
      // have swapped in a new manager carrying a server-resolved user id
      // (e.g. a guest exchange). Reading `userId` here keeps the `user_id`
      // query parameter consistent with the identity in the `Authorization`
      // header below.
      options.queryParameters['user_id'] = _tokenManager.userId;
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
      final tokenManager = _tokenManager;
      // Don't try to refresh the token if we're using a static provider
      if (tokenManager.usesStaticProvider) return handler.next(err);
      // Otherwise, mark the current token as expired.
      tokenManager.expireToken();

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
