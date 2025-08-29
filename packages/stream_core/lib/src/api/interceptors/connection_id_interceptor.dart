import 'package:dio/dio.dart';

typedef ConnectionIdGetter = String? Function();

/// Interceptor that injects the connection id in the request params
class ConnectionIdInterceptor extends Interceptor {
  /// Initialize a new [ConnectionIdInterceptor].
  const ConnectionIdInterceptor(this._connectionId);

  /// The getter for the connection id.
  final ConnectionIdGetter _connectionId;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connectionId = _connectionId.call();
    if (connectionId != null && connectionId.isNotEmpty) {
      // Add the connection id to the query parameters
      options.queryParameters['connection_id'] = connectionId;
    }

    return handler.next(options);
  }
}
