import 'dart:async';
import 'dart:convert';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../helpers/user_token.dart';

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

void main() {
  group('AuthInterceptor', () {
    test(
      'sets the Authorization header, the auth type, and the user_id query '
      'parameter',
      () async {
        final tokenManager = TokenManager(
          userId: 'user-123',
          tokenProvider: TokenProvider.static(
            generateTestUserToken('user-123'),
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
        // then the manager is pointed at the id the exchange returned before
        // the next request goes out, so nothing is in flight across the swap.
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
          tokenProvider: TokenProvider.static(generateTestUserToken(serverId)),
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
        final restricted = generateTestUserToken(UserToken.anonymousUserId);
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
      'sends the token manager user id, not the loaded token user id',
      () async {
        // The mismatch is deliberate: a request carrying someone else's token
        // is rejected, where deriving `user_id` from the token would make it
        // self-consistent and silently act as the token's owner.
        final slowLoad = Completer<UserToken>();
        final tokenManager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.dynamic((_) => slowLoad.future),
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        final adapter = _CapturingHttpClientAdapter();
        dio.httpClientAdapter = adapter;
        dio.interceptors.add(AuthInterceptor(dio, tokenManager));

        final pending = dio.get<void>('/test');
        await pumpEventQueue();

        // The load is already running for user-1 when the manager moves on.
        final userTwoToken = generateTestUserToken('user-2');
        tokenManager.setTokenProvider(
          'user-2',
          tokenProvider: TokenProvider.static(userTwoToken),
        );
        slowLoad.complete(generateTestUserToken('user-1'));
        await pending;

        expect(adapter.lastRequest?.queryParameters['user_id'], 'user-2');
        expect(
          adapter.lastRequest?.headers['Authorization'],
          isNot(userTwoToken.rawValue),
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
          tokenProvider: TokenProvider.static(generateTestUserToken('guest-1')),
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        final adapter = _TokenExpiredHttpClientAdapter();
        dio.httpClientAdapter = adapter;
        dio.interceptors.add(AuthInterceptor(dio, tokenManager));

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
      'is pointed at a static provider after the request was dispatched '
      '(guest exchange resolving mid-flight)',
      () async {
        // Starts on a dynamic provider and adopts a static one carrying the
        // exchanged id once the request is already in flight, mirroring the
        // guest flow. onError sees the static provider and must forward the
        // error rather than expire + retry.
        final tokenManager = TokenManager(
          userId: 'requested-id',
          tokenProvider: TokenProvider.dynamic(
            (_) async => generateTestUserToken('requested-id'),
          ),
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
        final adapter = _TokenExpiredHttpClientAdapter(
          onFetch: () {
            tokenManager.setTokenProvider(
              'server-assigned-id',
              tokenProvider: TokenProvider.static(
                generateTestUserToken('server-assigned-id'),
              ),
            );
          },
        );
        dio.httpClientAdapter = adapter;
        dio.interceptors.add(AuthInterceptor(dio, tokenManager));

        await expectLater(
          dio.get<void>('/test'),
          throwsA(isA<DioException>()),
        );

        // The adopted provider is static, so the error is surfaced without a
        // refresh-and-retry: the request is attempted exactly once.
        expect(adapter.requestCount, 1);
      },
    );
  });
}
