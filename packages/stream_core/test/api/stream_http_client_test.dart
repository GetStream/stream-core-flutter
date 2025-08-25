// // ignore_for_file: inference_failure_on_function_invocation
//
// import 'package:dio/dio.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:stream_core/src/api/interceptors/additional_headers_interceptor.dart';
// import 'package:stream_core/src/api/interceptors/auth_interceptor.dart';
// import 'package:stream_core/src/api/interceptors/connection_id_interceptor.dart';
// import 'package:stream_core/src/api/interceptors/logging_interceptor.dart';
// import 'package:stream_core/src/logger/logger.dart';
// import 'package:stream_core/stream_core.dart';
// import 'package:test/test.dart';
//
// import '../mocks.dart';
//
// const testUser = User(
//   id: 'user-id',
//   name: 'test-user',
//   imageUrl: 'https://example.com/image.png',
// );
//
// void main() {
//   Response<dynamic> successResponse(String path) => Response(
//         requestOptions: RequestOptions(path: path),
//         statusCode: 200,
//       );
//
//   DioException throwableError(
//     String path, {
//     ClientException? error,
//     bool streamDioError = false,
//   }) {
//     if (streamDioError) assert(error != null, '');
//     final options = RequestOptions(path: path);
//     final data = StreamApiError(
//       code: 0,
//       statusCode: error is HttpClientException ? error.statusCode ?? 0 : 0,
//       message: error?.message ?? '',
//       details: [],
//       duration: '',
//       moreInfo: '',
//     );
//     DioException? dioError;
//     if (streamDioError) {
//       dioError = StreamDioException(exception: error!, requestOptions: options);
//     } else {
//       dioError = DioException(
//         error: error,
//         requestOptions: options,
//         response: Response(
//           requestOptions: options,
//           statusCode: data.statusCode,
//           data: data.toJson(),
//         ),
//       );
//     }
//     return dioError;
//   }
//
//   test('UserAgentInterceptor should be added', () {
//     const apiKey = 'api-key';
//     final client = CoreHttpClient(
//       apiKey,
//       systemEnvironmentManager: systemEnvironmentManager,
//     );
//
//     expect(
//       client.httpClient.interceptors
//           .whereType<AdditionalHeadersInterceptor>()
//           .length,
//       1,
//     );
//   });
//
//   test('AuthInterceptor should be added if tokenManager is provided', () {
//     const apiKey = 'api-key';
//     final client = CoreHttpClient(
//       apiKey,
//       tokenManager: TokenManager.static(token: 'token', user: testUser),
//       systemEnvironmentManager: systemEnvironmentManager,
//     );
//
//     expect(
//       client.httpClient.interceptors.whereType<AuthInterceptor>().length,
//       1,
//     );
//   });
//
//   test(
//     '''connectionIdInterceptor should be added if connectionIdManager is provided''',
//     () {
//       const apiKey = 'api-key';
//       final client = CoreHttpClient(
//         apiKey,
//         connectionIdProvider: () => null,
//         systemEnvironmentManager: systemEnvironmentManager,
//       );
//
//       expect(
//         client.httpClient.interceptors
//             .whereType<ConnectionIdInterceptor>()
//             .length,
//         1,
//       );
//     },
//   );
//
//   group('loggingInterceptor', () {
//     test('should be added if logger is provided', () {
//       const apiKey = 'api-key';
//       final client = CoreHttpClient(
//         apiKey,
//         systemEnvironmentManager: systemEnvironmentManager,
//         logger: const SilentStreamLogger(),
//       );
//
//       expect(
//         client.httpClient.interceptors.whereType<LoggingInterceptor>().length,
//         1,
//       );
//     });
//
//     test('should log requests', () async {
//       const apiKey = 'api-key';
//       final logger = MockLogger();
//       final client = CoreHttpClient(
//         apiKey,
//         systemEnvironmentManager: systemEnvironmentManager,
//         logger: logger,
//       );
//
//       try {
//         await client.get('path');
//       } catch (_) {}
//
//       verify(() => logger.log(Priority.info, any(), any()))
//           .called(greaterThan(0));
//     });
//
//     test('should log error', () async {
//       const apiKey = 'api-key';
//       final logger = MockLogger();
//       final client = CoreHttpClient(
//         apiKey,
//         systemEnvironmentManager: systemEnvironmentManager,
//         logger: logger,
//       );
//
//       try {
//         await client.get('path');
//       } catch (_) {}
//
//       verify(() => logger.log(Priority.error, any(), any()))
//           .called(greaterThan(0));
//     });
//   });
//
//   test('`.close` should close the dio client', () async {
//     final client = CoreHttpClient(
//       'api-key',
//       systemEnvironmentManager: systemEnvironmentManager,
//     )..close(force: true);
//     try {
//       await client.get('path');
//       fail('Expected an exception to be thrown');
//     } catch (e) {
//       expect(e, isA<ClientException>());
//       expect(
//         (e as ClientException).message,
//         "The connection errored: Dio can't establish a new connection"
//         ' after it was closed. This indicates an error which most likely'
//         ' cannot be solved by the library.',
//       );
//     }
//   });
//
//   test('`.get` should return response successfully', () async {
//     final dio = MockDio();
//     final client = CoreHttpClient(
//       'api-key',
//       systemEnvironmentManager: systemEnvironmentManager,
//       dio: dio,
//     );
//
//     const path = 'test-get-api-path';
//     when(
//       () => dio.get(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).thenAnswer((_) async => successResponse(path));
//
//     final res = await client.get(path);
//
//     expect(res, isNotNull);
//     expect(res.statusCode, 200);
//     expect(res.requestOptions.path, path);
//
//     verify(
//       () => dio.get(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).called(1);
//     verifyNoMoreInteractions(dio);
//   });
//
//   test('`.get` should throw an instance of `ClientException`', () async {
//     final dio = MockDio();
//     final client = CoreHttpClient(
//       'api-key',
//       systemEnvironmentManager: systemEnvironmentManager,
//       dio: dio,
//     );
//
//     const path = 'test-get-api-path';
//     final error = throwableError(
//       path,
//       error: ClientException(error: createStreamApiError()),
//     );
//     when(
//       () => dio.get(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).thenThrow(error);
//
//     try {
//       await client.get(path);
//       fail('Expected an exception to be thrown');
//     } catch (e) {
//       expect(e, isA<ClientException>());
//     }
//
//     verify(
//       () => dio.get(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).called(1);
//     verifyNoMoreInteractions(dio);
//   });
//
//   test('`.post` should return response successfully', () async {
//     final dio = MockDio();
//     final client = CoreHttpClient(
//       'api-key',
//       systemEnvironmentManager: systemEnvironmentManager,
//       dio: dio,
//     );
//
//     const path = 'test-post-api-path';
//     when(
//       () => dio.post(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).thenAnswer((_) async => successResponse(path));
//
//     final res = await client.post(path);
//
//     expect(res, isNotNull);
//     expect(res.statusCode, 200);
//     expect(res.requestOptions.path, path);
//
//     verify(
//       () => dio.post(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).called(1);
//     verifyNoMoreInteractions(dio);
//   });
//
//   test(
//     '`.post` should throw an instance of `ClientException`',
//     () async {
//       final dio = MockDio();
//       final client = CoreHttpClient(
//         'api-key',
//         systemEnvironmentManager: systemEnvironmentManager,
//         dio: dio,
//       );
//
//       const path = 'test-post-api-path';
//       final error = throwableError(
//         path,
//         error: ClientException(error: createStreamApiError()),
//       );
//       when(
//         () => dio.post(
//           path,
//           options: any(named: 'options'),
//         ),
//       ).thenThrow(error);
//
//       try {
//         await client.post(path);
//         fail('Expected an exception to be thrown');
//       } catch (e) {
//         expect(e, isA<ClientException>());
//       }
//
//       verify(
//         () => dio.post(
//           path,
//           options: any(named: 'options'),
//         ),
//       ).called(1);
//       verifyNoMoreInteractions(dio);
//     },
//   );
//
//   test('`.delete` should return response successfully', () async {
//     final dio = MockDio();
//     final client = CoreHttpClient(
//       'api-key',
//       systemEnvironmentManager: systemEnvironmentManager,
//       dio: dio,
//     );
//
//     const path = 'test-delete-api-path';
//     when(
//       () => dio.delete(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).thenAnswer((_) async => successResponse(path));
//
//     final res = await client.delete(path);
//
//     expect(res, isNotNull);
//     expect(res.statusCode, 200);
//     expect(res.requestOptions.path, path);
//
//     verify(
//       () => dio.delete(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).called(1);
//     verifyNoMoreInteractions(dio);
//   });
//
//   test(
//     '`.delete` should throw an instance of `ClientException`',
//     () async {
//       final dio = MockDio();
//       final client = CoreHttpClient(
//         'api-key',
//         systemEnvironmentManager: systemEnvironmentManager,
//         dio: dio,
//       );
//
//       const path = 'test-delete-api-path';
//       final error = throwableError(
//         path,
//         error: ClientException(error: createStreamApiError()),
//       );
//       when(
//         () => dio.delete(
//           path,
//           options: any(named: 'options'),
//         ),
//       ).thenThrow(error);
//
//       try {
//         await client.delete(path);
//         fail('Expected an exception to be thrown');
//       } catch (e) {
//         expect(e, isA<ClientException>());
//       }
//
//       verify(
//         () => dio.delete(
//           path,
//           options: any(named: 'options'),
//         ),
//       ).called(1);
//       verifyNoMoreInteractions(dio);
//     },
//   );
//
//   test('`.patch` should return response successfully', () async {
//     final dio = MockDio();
//     final client = CoreHttpClient(
//       'api-key',
//       systemEnvironmentManager: systemEnvironmentManager,
//       dio: dio,
//     );
//
//     const path = 'test-patch-api-path';
//     when(
//       () => dio.patch(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).thenAnswer((_) async => successResponse(path));
//
//     final res = await client.patch(path);
//
//     expect(res, isNotNull);
//     expect(res.statusCode, 200);
//     expect(res.requestOptions.path, path);
//
//     verify(
//       () => dio.patch(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).called(1);
//     verifyNoMoreInteractions(dio);
//   });
//
//   test(
//     '`.patch` should throw an instance of `ClientException`',
//     () async {
//       final dio = MockDio();
//       final client = CoreHttpClient(
//         'api-key',
//         systemEnvironmentManager: systemEnvironmentManager,
//         dio: dio,
//       );
//
//       const path = 'test-patch-api-path';
//       final error = throwableError(
//         path,
//         error: ClientException(error: createStreamApiError()),
//       );
//       when(
//         () => dio.patch(
//           path,
//           options: any(named: 'options'),
//         ),
//       ).thenThrow(error);
//
//       try {
//         await client.patch(path);
//         fail('Expected an exception to be thrown');
//       } catch (e) {
//         expect(e, isA<ClientException>());
//       }
//
//       verify(
//         () => dio.patch(
//           path,
//           options: any(named: 'options'),
//         ),
//       ).called(1);
//       verifyNoMoreInteractions(dio);
//     },
//   );
//
//   test('`.put` should return response successfully', () async {
//     final dio = MockDio();
//     final client = CoreHttpClient(
//       'api-key',
//       systemEnvironmentManager: systemEnvironmentManager,
//       dio: dio,
//     );
//
//     const path = 'test-put-api-path';
//     when(
//       () => dio.put(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).thenAnswer((_) async => successResponse(path));
//
//     final res = await client.put(path);
//
//     expect(res, isNotNull);
//     expect(res.statusCode, 200);
//     expect(res.requestOptions.path, path);
//
//     verify(
//       () => dio.put(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).called(1);
//     verifyNoMoreInteractions(dio);
//   });
//
//   test(
//     '`.put` should throw an instance of `ClientException`',
//     () async {
//       final dio = MockDio();
//       final client = CoreHttpClient(
//         'api-key',
//         systemEnvironmentManager: systemEnvironmentManager,
//         dio: dio,
//       );
//
//       const path = 'test-put-api-path';
//       final error = throwableError(
//         path,
//         error: ClientException(error: createStreamApiError()),
//       );
//       when(
//         () => dio.put(
//           path,
//           options: any(named: 'options'),
//         ),
//       ).thenThrow(error);
//
//       try {
//         await client.put(path);
//         fail('Expected an exception to be thrown');
//       } catch (e) {
//         expect(e, isA<ClientException>());
//       }
//
//       verify(
//         () => dio.put(
//           path,
//           options: any(named: 'options'),
//         ),
//       ).called(1);
//       verifyNoMoreInteractions(dio);
//     },
//   );
//
//   test('`.postFile` should return response successfully', () async {
//     final dio = MockDio();
//     final client = CoreHttpClient(
//       'api-key',
//       systemEnvironmentManager: systemEnvironmentManager,
//       dio: dio,
//     );
//
//     const path = 'test-delete-api-path';
//     final file = MultipartFile.fromBytes([]);
//
//     when(
//       () => dio.post(
//         path,
//         data: any(named: 'data'),
//         options: any(named: 'options'),
//       ),
//     ).thenAnswer((_) async => successResponse(path));
//
//     final res = await client.postFile(path, file);
//
//     expect(res, isNotNull);
//     expect(res.statusCode, 200);
//     expect(res.requestOptions.path, path);
//
//     verify(
//       () => dio.post(
//         path,
//         data: any(named: 'data'),
//         options: any(named: 'options'),
//       ),
//     ).called(1);
//     verifyNoMoreInteractions(dio);
//   });
//
//   test(
//     '`.postFile` should throw an instance of `ClientException`',
//     () async {
//       final dio = MockDio();
//       final client = CoreHttpClient(
//         'api-key',
//         systemEnvironmentManager: systemEnvironmentManager,
//         dio: dio,
//       );
//
//       const path = 'test-post-file-api-path';
//       final file = MultipartFile.fromBytes([]);
//
//       final error = throwableError(
//         path,
//         error: ClientException(error: createStreamApiError()),
//       );
//       when(
//         () => dio.post(
//           path,
//           data: any(named: 'data'),
//           options: any(named: 'options'),
//         ),
//       ).thenThrow(error);
//
//       try {
//         await client.postFile(path, file);
//         fail('Expected an exception to be thrown');
//       } catch (e) {
//         expect(e, isA<ClientException>());
//       }
//
//       verify(
//         () => dio.post(
//           path,
//           data: any(named: 'data'),
//           options: any(named: 'options'),
//         ),
//       ).called(1);
//       verifyNoMoreInteractions(dio);
//     },
//   );
//
//   test('`.request` should return response successfully', () async {
//     final dio = MockDio();
//     final client = CoreHttpClient(
//       'api-key',
//       systemEnvironmentManager: systemEnvironmentManager,
//       dio: dio,
//     );
//
//     const path = 'test-request-api-path';
//     when(
//       () => dio.request(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).thenAnswer((_) async => successResponse(path));
//
//     final res = await client.request(path);
//
//     expect(res, isNotNull);
//     expect(res.statusCode, 200);
//     expect(res.requestOptions.path, path);
//
//     verify(
//       () => dio.request(
//         path,
//         options: any(named: 'options'),
//       ),
//     ).called(1);
//     verifyNoMoreInteractions(dio);
//   });
//
//   test(
//     '`.request` should throw an instance of `ClientException`',
//     () async {
//       final dio = MockDio();
//       final client = CoreHttpClient(
//         'api-key',
//         systemEnvironmentManager: systemEnvironmentManager,
//         dio: dio,
//       );
//
//       const path = 'test-put-api-path';
//       final error = throwableError(
//         path,
//         streamDioError: true,
//         error: ClientException(error: createStreamApiError()),
//       );
//       when(
//         () => dio.request(
//           path,
//           options: any(named: 'options'),
//         ),
//       ).thenThrow(error);
//
//       try {
//         await client.request(path);
//         fail('Expected an exception to be thrown');
//       } catch (e) {
//         expect(e, isA<ClientException>());
//       }
//
//       verify(
//         () => dio.request(
//           path,
//           options: any(named: 'options'),
//         ),
//       ).called(1);
//       verifyNoMoreInteractions(dio);
//     },
//   );
// }
