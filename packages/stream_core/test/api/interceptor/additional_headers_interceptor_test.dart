// // ignore_for_file: invalid_use_of_protected_member
//
// import 'package:dio/dio.dart';
// import 'package:stream_core/stream_core.dart';
// import 'package:test/test.dart';
//
// import '../../mocks.dart';
//
// void main() {
//   group('HeadersInterceptor tests', () {
//     group('with SystemEnvironmentManager', () {
//       late HeadersInterceptor headersInterceptor;
//
//       setUp(() {
//         final environmentManager = FakeSystemEnvironmentManager(
//           environment: environment,
//         );
//
//         headersInterceptor = HeadersInterceptor(
//           FakeSystemEnvironmentManager(
//             environment: systemEnvironmentManager.environment,
//           ),
//         );
//       });
//
//       test('should add user agent header when available', () async {
//         HeadersInterceptor.additionalHeaders = {
//           'test-header': 'test-value',
//         };
//         addTearDown(() => HeadersInterceptor.additionalHeaders = {});
//
//         final options = RequestOptions(path: 'test-path');
//         final handler = RequestInterceptorHandler();
//
//         await headersInterceptor.onRequest(options, handler);
//
//         final updatedOptions = (await handler.future).data as RequestOptions;
//         final updateHeaders = updatedOptions.headers;
//
//         expect(updateHeaders.containsKey('test-header'), isTrue);
//         expect(updateHeaders['test-header'], 'test-value');
//         expect(updateHeaders.containsKey('X-Stream-Client'), isTrue);
//         expect(updateHeaders['X-Stream-Client'], 'test-user-agent');
//       });
//     });
//   });
// }
//
// class FakeSystemEnvironmentManager extends SystemEnvironmentManager {
//   FakeSystemEnvironmentManager({required super.environment});
//
//   @override
//   String get userAgent => 'test-user-agent';
// }
