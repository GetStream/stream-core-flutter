// ignore_for_file: invalid_use_of_protected_member

import 'package:dio/dio.dart';
import 'package:stream_core/src/api/interceptors/additional_headers_interceptor.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../mocks.dart';

void main() {
  group('AdditionalHeadersInterceptor tests', () {
    group('with SystemEnvironmentManager', () {
      late AdditionalHeadersInterceptor additionalHeadersInterceptor;

      setUp(() {
        additionalHeadersInterceptor = AdditionalHeadersInterceptor(
          FakeSystemEnvironmentManager(
            environment: systemEnvironmentManager.environment,
          ),
        );
      });

      test('should add user agent header when available', () async {
        AdditionalHeadersInterceptor.additionalHeaders = {
          'test-header': 'test-value',
        };
        addTearDown(() => AdditionalHeadersInterceptor.additionalHeaders = {});

        final options = RequestOptions(path: 'test-path');
        final handler = RequestInterceptorHandler();

        await additionalHeadersInterceptor.onRequest(options, handler);

        final updatedOptions = (await handler.future).data as RequestOptions;
        final updateHeaders = updatedOptions.headers;

        expect(updateHeaders.containsKey('test-header'), isTrue);
        expect(updateHeaders['test-header'], 'test-value');
        expect(updateHeaders.containsKey('X-Stream-Client'), isTrue);
        expect(updateHeaders['X-Stream-Client'], 'test-user-agent');
      });
    });
  });
}

class FakeSystemEnvironmentManager extends SystemEnvironmentManager {
  FakeSystemEnvironmentManager({required super.environment});

  @override
  String get userAgent => 'test-user-agent';
}
