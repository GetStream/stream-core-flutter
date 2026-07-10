import 'dart:convert';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

// A minimal HttpClientAdapter that captures the outgoing RequestOptions and
// always responds with an empty successful response.
class _CapturingHttpClientAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

UserToken _generateTestUserToken(String userId) {
  String b64UrlNoPad(Object jsonObj) {
    final bytes = utf8.encode(jsonEncode(jsonObj));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  final header = {'alg': 'none', 'typ': 'JWT'};
  final payload = {'user_id': userId};

  final jwt = '${b64UrlNoPad(header)}.${b64UrlNoPad(payload)}.';
  return UserToken(jwt);
}

void main() {
  group('AuthInterceptor', () {
    test(
      "uses the resolved token's own user id for the user_id query "
      'parameter, not the id the TokenManager was constructed with',
      () async {
        // Simulates a token provider (e.g. a guest exchange) that resolves
        // to a different id than the one originally requested.
        final tokenManager = TokenManager(
          userId: 'requested-id',
          tokenProvider: TokenProvider.dynamic(
            (_) async => _generateTestUserToken('server-assigned-id'),
          ),
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        final adapter = _CapturingHttpClientAdapter();
        dio.httpClientAdapter = adapter;
        dio.interceptors.add(AuthInterceptor(dio, tokenManager));

        await dio.get<void>('/test');

        expect(
          adapter.lastRequest?.queryParameters['user_id'],
          'server-assigned-id',
        );
      },
    );

    test(
      'matches the TokenManager userId when the token resolves to the '
      'same id (regular/anonymous users)',
      () async {
        final tokenManager = TokenManager(
          userId: 'user-123',
          tokenProvider: TokenProvider.static(
            _generateTestUserToken('user-123'),
          ),
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        final adapter = _CapturingHttpClientAdapter();
        dio.httpClientAdapter = adapter;
        dio.interceptors.add(AuthInterceptor(dio, tokenManager));

        await dio.get<void>('/test');

        expect(adapter.lastRequest?.queryParameters['user_id'], 'user-123');
      },
    );
  });
}
