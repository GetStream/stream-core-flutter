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
// counting how many times it is hit so a retry can be detected. [onFetch], if
// provided, runs when the request is dispatched — used to simulate a token
// manager being swapped in mid-flight.
class _TokenExpiredHttpClientAdapter implements HttpClientAdapter {
  _TokenExpiredHttpClientAdapter({this.onFetch});

  final void Function()? onFetch;

  var _requestCount = 0;
  int get requestCount => _requestCount;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _requestCount++;
    onFetch?.call();
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
      'uses the TokenManager passed to the positional constructor, setting the '
      'Authorization header and user_id query parameter (backwards-compatible '
      'API)',
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
        expect(
          adapter.lastRequest?.headers['Authorization'],
          isNotNull,
        );
        expect(
          adapter.lastRequest?.headers['stream-auth-type'],
          isNotNull,
        );
      },
    );

    test(
      'sends the user id a guest exchange returned, once the token manager is '
      'pointed at it',
      () async {
        // Simulates the guest flow: the exchange is authenticated anonymously,
        // then the manager is pointed at the id the exchange returned. The user
        // id and the token change together, so the `user_id` query parameter
        // always describes the token in the `Authorization` header.
        const serverId = 'server-assigned-id';

        final tokenManager = TokenManager(
          userId: UserToken.anonymousUserId,
          tokenProvider: TokenProvider.static(UserToken.anonymous()),
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        final adapter = _CapturingHttpClientAdapter();
        dio.httpClientAdapter = adapter;
        dio.interceptors.add(AuthInterceptor(dio, tokenManager));

        tokenManager.setTokenProvider(
          serverId,
          tokenProvider: TokenProvider.static(_generateTestUserToken(serverId)),
        );

        await dio.get<void>('/test');

        expect(adapter.lastRequest?.queryParameters['user_id'], serverId);
        expect(
          adapter.lastRequest?.headers['stream-auth-type'],
          AuthType.jwt.headerValue,
        );
      },
    );

    test(
      'uses the current TokenManager userId when nothing swaps it',
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
        dio.interceptors.add(AuthInterceptor.withProvider(dio, tokenManagerProvider: () => tokenManager));

        await dio.get<void>('/test');

        expect(adapter.lastRequest?.queryParameters['user_id'], 'user-123');
      },
    );

    test(
      'sends an anonymous token as an empty Authorization header with the '
      'anonymous auth type',
      () async {
        final tokenManager = TokenManager(
          userId: UserToken.anonymousUserId,
          tokenProvider: TokenProvider.static(UserToken.anonymous()),
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        final adapter = _CapturingHttpClientAdapter();
        dio.httpClientAdapter = adapter;
        dio.interceptors.add(AuthInterceptor(dio, tokenManager));

        await dio.get<void>('/test');

        expect(adapter.lastRequest?.headers['Authorization'], isEmpty);
        expect(
          adapter.lastRequest?.headers['stream-auth-type'],
          AuthType.anonymous.headerValue,
        );
        expect(
          adapter.lastRequest?.queryParameters['user_id'],
          UserToken.anonymousUserId,
        );
      },
    );

    test(
      'sends a restricted anonymous token as the Authorization header',
      () async {
        final restricted = _generateTestUserToken(UserToken.anonymousUserId);
        final tokenManager = TokenManager(
          userId: UserToken.anonymousUserId,
          tokenProvider: TokenProvider.static(
            UserToken.anonymous(rawValue: restricted.rawValue),
          ),
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        final adapter = _CapturingHttpClientAdapter();
        dio.httpClientAdapter = adapter;
        dio.interceptors.add(AuthInterceptor(dio, tokenManager));

        await dio.get<void>('/test');

        expect(adapter.lastRequest?.headers['Authorization'], restricted.rawValue);
        expect(
          adapter.lastRequest?.headers['stream-auth-type'],
          AuthType.anonymous.headerValue,
        );
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
        dio.interceptors.add(AuthInterceptor.withProvider(dio, tokenManagerProvider: () => tokenManager));

        await expectLater(
          dio.get<void>('/test'),
          throwsA(isA<DioException>()),
        );

        // A static provider must not trigger the refresh-and-retry path, so
        // the request is attempted exactly once.
        expect(adapter.requestCount, 1);
      },
    );

    test(
      'forwards a token-expired error without retrying when the token manager '
      'is swapped to a static provider after the request was dispatched '
      '(guest exchange resolving mid-flight)',
      () async {
        // Starts on a dynamic manager and swaps to a static one carrying the
        // exchanged id once the request is already in flight, mirroring the
        // guest flow. onError observes the swapped-in (static) manager and must
        // forward the error rather than expire + retry.
        var tokenManager = TokenManager(
          userId: 'requested-id',
          tokenProvider: TokenProvider.dynamic(
            (_) async => _generateTestUserToken('requested-id'),
          ),
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        final adapter = _TokenExpiredHttpClientAdapter(
          onFetch: () {
            tokenManager = TokenManager(
              userId: 'server-assigned-id',
              tokenProvider: TokenProvider.static(
                _generateTestUserToken('server-assigned-id'),
              ),
            );
          },
        );
        dio.httpClientAdapter = adapter;
        dio.interceptors.add(AuthInterceptor.withProvider(dio, tokenManagerProvider: () => tokenManager));

        await expectLater(
          dio.get<void>('/test'),
          throwsA(isA<DioException>()),
        );

        // The swapped-in manager is static, so the error is surfaced without a
        // refresh-and-retry: the request is attempted exactly once.
        expect(adapter.requestCount, 1);
      },
    );
  });
}
