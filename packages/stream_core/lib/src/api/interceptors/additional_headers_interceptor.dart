import 'package:dio/dio.dart';

import '../system_environment_manager.dart';

/// Interceptor that sets additional headers for all requests.
class AdditionalHeadersInterceptor extends Interceptor {
  /// Initialize a new [AdditionalHeadersInterceptor].
  const AdditionalHeadersInterceptor(this._systemEnvironmentManager);

  final SystemEnvironmentManager _systemEnvironmentManager;

  /// Additional headers for all requests
  static Map<String, Object?> additionalHeaders = {};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final userAgent = _systemEnvironmentManager.userAgent;

    options.headers = {
      ...options.headers,
      ...additionalHeaders,
      'X-Stream-Client': userAgent,
    };
    return handler.next(options);
  }
}
