import 'package:dio/dio.dart';

import '../../errors.dart';
import '../../user.dart';
import '../stream_core_dio_error.dart';

/// Interceptor that signs every request with the caller's token.
///
/// A request the server refuses for an expired token is retried once, carrying a replacement.
class AuthInterceptor extends Interceptor {
  /// Creates a new [AuthInterceptor].
  AuthInterceptor(this._dio, this._tokenManager);

  final Dio _dio;
  final TokenManager _tokenManager;

  // Not a `QueuedInterceptor`: it frees a slot only once a handler completes, so the retry sent from
  // `onError` would wait behind the request holding it. `TokenManager` serialises the token loads.

  static const _retriedKey = 'stream_core.auth_token_retried';

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
        stackTrace: stackTrace,
      );

      return handler.reject(dioError, true);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final error = err.apiError;
    if (error == null || !error.isTokenExpiredError) return handler.next(err);

    final options = err.requestOptions;

    // A retry after a user switch would perform this request as the new user.
    final signedFor = options.queryParameters['user_id'];
    final canRefresh = signedFor == _tokenManager.userId && !_tokenManager.usesStaticProvider;
    if (!canRefresh) return handler.next(err);

    if (options.extra[_retriedKey] == true) return handler.next(err);

    // Another request may have replaced it already, and expiring that would discard a valid token.
    if (options.headers['Authorization'] == _tokenManager.peekToken()?.rawValue) {
      _tokenManager.expireToken();
    }

    // The multipart body is cloned because the refused attempt already consumed its streams.
    final data = options.data;
    final retry = options.copyWith(
      extra: {...options.extra, _retriedKey: true},
      data: data is FormData ? data.clone() : data,
    );

    try {
      // ignore: inference_failure_on_function_invocation
      final response = await _dio.fetch(retry);
      return handler.resolve(response);
    } on DioException catch (exception) {
      return handler.reject(exception);
    }
  }
}
