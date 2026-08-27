import 'package:dio/dio.dart';

import '../../errors.dart';
import '../../logger.dart';
import '../../user.dart';
import '../stream_core_dio_exception.dart';

/// Interceptor that signs every request with the caller's token.
///
/// A request the server refuses for an expired token is retried once, carrying a replacement.
///
/// Reports what it decided under `SC:HttpAuth`, including every reason it left a refused request
/// refused. Nothing is written until an app installs a [StreamLogHandler].
class AuthInterceptor extends Interceptor {
  /// Creates a new [AuthInterceptor].
  AuthInterceptor(this._dio, this._tokenManager, {String tag = 'SC:HttpAuth'}) : _logger = StreamLogger(tag);

  final Dio _dio;
  final TokenManager _tokenManager;
  final StreamLogger _logger;

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
      _logger.w(() => 'no token to sign ${options.uri} with', error: e, stackTrace: stackTrace);

      // Caught in full: a rejection must deliver a StreamException whatever
      // the app's token code threw.
      var exception = StreamException.tryFrom(e);
      exception ??= StreamAuthenticationException(
        message: 'Failed to load an auth token',
        cause: e,
        stackTrace: stackTrace,
      );

      final dioError = StreamDioException(
        exception: exception,
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
    // Only an expired token (code 40) is fixed by loading another one; the
    // other token codes are clock or configuration problems a refresh cannot
    // help.
    final error = err.toStreamException();
    if (error is! StreamApiException || !error.isTokenExpired) return handler.next(err);

    final options = err.requestOptions;

    // A retry after a user switch would perform this request as the new user.
    final signedFor = options.queryParameters['user_id'];
    final canRefresh = signedFor == _tokenManager.userId && !_tokenManager.usesStaticProvider;
    if (!canRefresh) {
      _logger.d(() {
        final reason = switch (_tokenManager.usesStaticProvider) {
          true => 'the token provider is static and has nothing fresher to give',
          false => 'it was signed for $signedFor, and the user is now ${_tokenManager.userId}',
        };

        return 'not refreshing the token behind ${options.uri}: $reason';
      });

      return handler.next(err);
    }

    if (options.extra[_retriedKey] == true) {
      _logger.w(() => 'the replacement token was refused too, leaving ${options.uri} failed');
      return handler.next(err);
    }

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

    _logger.d(() => 'retrying ${options.uri} with a replacement token');

    try {
      // ignore: inference_failure_on_function_invocation
      final response = await _dio.fetch(retry);
      return handler.resolve(response);
    } on DioException catch (exception) {
      _logger.w(() => 'the retry of ${options.uri} failed too', error: exception);
      return handler.reject(exception);
    }
  }
}
