import 'package:dio/dio.dart';

class ApiKeyInterceptor extends Interceptor {
  /// Initialize a new API key interceptor
  const ApiKeyInterceptor(this.apiKey);

  /// The API key to be added to the request headers
  final String apiKey;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['api_key'] = apiKey;
    return handler.next(options);
  }
}
