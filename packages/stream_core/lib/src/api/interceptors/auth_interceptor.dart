import 'package:dio/dio.dart';

import '../../errors.dart';
import '../../user.dart';
import '../stream_core_dio_error.dart';

/// Signs every request with the caller's token, and replaces one the server refused for having
/// expired before retrying the request once.
class AuthInterceptor extends Interceptor {
  /// Creates an [AuthInterceptor] that signs requests with the tokens `tokenManager` holds, and
  /// retries a refused one through `dio`.
  AuthInterceptor(this._dio, this._tokenManager);

  // Not a `QueuedInterceptor`: that frees a queue slot only once a handler completes, so the retry
  // sent from `onError` would wait behind the request still holding it and neither would finish.
  // `TokenManager` serialises the token loads, which is the part that needs serialising.

  // Marks a request that has already been retried with a replaced token.
  static const _retriedKey = 'stream_core.auth_token_retried';

  final Dio _dio;

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
    // Only an expired token is worth replacing.
    final error = err.apiError;
    if (error == null || !error.isTokenExpiredError) return handler.next(err);

    final options = err.requestOptions;

    // Nothing to refresh with when there is no user to load a token for, or when the provider
    // would only return the same one again.
    final canRefresh = _tokenManager.userId != null && !_tokenManager.usesStaticProvider;
    if (!canRefresh) return handler.next(err);

    // And only once per request: if the replacement token is refused too, the error is surfaced to
    // the caller.
    if (options.extra[_retriedKey] == true) return handler.next(err);

    // Expire only the token this request actually carried. Another request may have replaced it
    // already, and expiring the replacement would discard a valid token.
    if (options.headers['Authorization'] == _tokenManager.peekToken()?.rawValue) {
      _tokenManager.expireToken();
    }

    // The retry is a new request rather than the refused one modified, so the options the caller
    // holds are left as they were. A multipart body is cloned because the refused attempt has
    // already consumed its streams.
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
      return handler.next(exception);
    }
  }
}
