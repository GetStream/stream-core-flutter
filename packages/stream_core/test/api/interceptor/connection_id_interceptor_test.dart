// ignore_for_file: invalid_use_of_protected_member, unawaited_futures

import 'package:dio/dio.dart';
import 'package:stream_core/src/api/interceptors/connection_id_interceptor.dart';
import 'package:test/test.dart';

void main() {
  late ConnectionIdInterceptor connectionIdInterceptor;

  String? connectionId;
  String? connectionIdProvider() {
    return connectionId;
  }

  setUp(() {
    connectionIdInterceptor = ConnectionIdInterceptor(connectionIdProvider);
  });

  test(
    '`onRequest` should add connectionId in the request',
    () async {
      final options = RequestOptions(path: 'test-path');
      final handler = RequestInterceptorHandler();

      final queryParams = options.queryParameters;
      expect(queryParams.containsKey('connection_id'), isFalse);

      connectionId = 'test-connection-id';

      connectionIdInterceptor.onRequest(options, handler);

      final updatedOptions = (await handler.future).data as RequestOptions;
      final updatedQueryParams = updatedOptions.queryParameters;

      expect(updatedQueryParams.containsKey('connection_id'), isTrue);
    },
  );

  test(
    '`onRequest` should not add connectionId if `hasConnectionId` is false',
    () async {
      final options = RequestOptions(path: 'test-path');
      final handler = RequestInterceptorHandler();

      final queryParams = options.queryParameters;
      expect(queryParams.containsKey('connection_id'), isFalse);
      connectionId = null;

      connectionIdInterceptor.onRequest(options, handler);

      final updatedOptions = (await handler.future).data as RequestOptions;
      final updatedQueryParams = updatedOptions.queryParameters;

      expect(updatedQueryParams.containsKey('connection_id'), isFalse);
    },
  );
}
