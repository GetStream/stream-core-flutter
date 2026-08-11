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

// An adapter that always responds with a token-expired API error (code 40),
// counting how many times it is hit so a retry can be detected.
class _TokenExpiredHttpClientAdapter implements HttpClientAdapter {
  var _requestCount = 0;
  int get requestCount => _requestCount;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _requestCount++;
    return ResponseBody.fromString(
      jsonEncode({
        'code': 40, // token expired
        'details': <int>[],
        'duration': '0ms',
        'message': 'token expired',
        'more_info': '',
        'StatusCode': 401,
      }),
      401,
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
      'picks up a TokenManager swapped in while the token is loading, so the '
      'user_id query parameter reflects a server-resolved id (guest exchange)',
      () async {
        // Simulates the guest flow: the token provider resolves to a
        // server-assigned id and swaps in a new TokenManager carrying that id
        // before the request headers are written. The interceptor reads the
        // manager through the getter, so it observes the swapped instance.
        late TokenManager tokenManager;
        tokenManager = TokenManager(
          userId: 'requested-id',
          tokenProvider: TokenProvider.dynamic((_) async {
            final token = _generateTestUserToken('server-assigned-id');
            tokenManager = TokenManager(
              userId: token.userId,
              tokenProvider: TokenProvider.static(token),
            );
            return token;
          }),
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        final adapter = _CapturingHttpClientAdapter();
        dio.httpClientAdapter = adapter;
        dio.interceptors.add(AuthInterceptor(dio, () => tokenManager));

        await dio.get<void>('/test');

        expect(
          adapter.lastRequest?.queryParameters['user_id'],
          'server-assigned-id',
        );
      },
    );

    test(
      'uses the current TokenManager userId when nothing swaps it '
      '(regular/anonymous users)',
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
        dio.interceptors.add(AuthInterceptor(dio, () => tokenManager));

        await dio.get<void>('/test');

        expect(adapter.lastRequest?.queryParameters['user_id'], 'user-123');
      },
    );

    test(
      'does not retry a token-expired response when using a static provider '
      '(e.g. a guest token): the error is surfaced to the caller instead of '
      'silently re-minting the token',
      () async {
        final tokenManager = TokenManager(
          userId: 'guest-1',
          tokenProvider: TokenProvider.static(_generateTestUserToken('guest-1')),
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        final adapter = _TokenExpiredHttpClientAdapter();
        dio.httpClientAdapter = adapter;
        dio.interceptors.add(AuthInterceptor(dio, () => tokenManager));

        await expectLater(
          dio.get<void>('/test'),
          throwsA(isA<DioException>()),
        );

        // A static provider must not trigger the refresh-and-retry path, so
        // the request is attempted exactly once.
        expect(adapter.requestCount, 1);
      },
    );
  });
}
