import 'package:dio/dio.dart';

import '../system_environment_manager.dart';

/// Interceptor that sets additional headers for all requests.
class HeadersInterceptor extends Interceptor {
  /// Initialize a new [HeadersInterceptor].
  const HeadersInterceptor(this._systemEnvironmentManager);

  final SystemEnvironmentManager _systemEnvironmentManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final userAgent = _systemEnvironmentManager.userAgent;
    options.headers['X-Stream-Client'] = userAgent;
    return handler.next(options);
  }
}
