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
  /// Initialize a new auth interceptor backed by a fixed [tokenManager].
  ///
  /// Use this when the [TokenManager] never changes for the lifetime of the
  /// interceptor. If you need to swap the manager at runtime — e.g. after a
  /// guest token exchange resolves a server-assigned user id — use
  /// [AuthInterceptor.withProvider] instead.
  AuthInterceptor(
    this._dio,
    TokenManager tokenManager,
  ) : _tokenManager = tokenManager,
      _tokenManagerProvider = null;

  /// Initialize a new auth interceptor backed by a [tokenManagerProvider].
  ///
  /// The provider is a getter rather than a fixed reference so the caller can
  /// swap the underlying [TokenManager] — e.g. after a guest token exchange
  /// resolves a server-assigned user id — and have this interceptor pick up
  /// the new instance on its next request.
  AuthInterceptor.withProvider(
    this._dio, {
    required TokenManagerProvider tokenManagerProvider,
  }) : _tokenManager = null,
       _tokenManagerProvider = tokenManagerProvider;

  final Dio _dio;

  final TokenManager? _tokenManager;

  /// Provides the token manager currently in use.
  final TokenManagerProvider? _tokenManagerProvider;

  /// The token manager currently in use.
  TokenManager get _effectiveTokenManager => _tokenManager ?? _tokenManagerProvider!.call();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _effectiveTokenManager.getToken();

      // Re-read the token manager after awaiting the token: loading it may
      // have swapped in a new manager carrying a server-resolved user id
      // (e.g. a guest exchange). Reading `userId` here keeps the `user_id`
      // query parameter consistent with the identity in the `Authorization`
      // header below.
      options.queryParameters['user_id'] = _effectiveTokenManager.userId;
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
      final tokenManager = _effectiveTokenManager;
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
