import 'package:dio/dio.dart';

import '../connection_id_provider.dart';

/// Interceptor that injects the connection id in the request params
class ConnectionIdInterceptor extends Interceptor {
  ///
  ConnectionIdInterceptor(this.connectionIdProvider);

  ///
  final ConnectionIdProvider connectionIdProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connectionId = connectionIdProvider();
    if (connectionId != null) {
      options.queryParameters.addAll({
        'connection_id': connectionId,
      });
    }
    handler.next(options);
  }
}
