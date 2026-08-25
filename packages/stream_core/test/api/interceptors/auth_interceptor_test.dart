import 'dart:async';
import 'dart:convert';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../helpers/logger.dart';
import '../../helpers/user_token.dart';

/// The body the API returns when the token it was given has run out.
Map<String, Object?> _expiredTokenBody() => {
  'code': 40,
  'details': <int>[],
  'duration': '0ms',
  'message': 'token expired',
  'more_info': '',
  'StatusCode': 401,
};

ResponseBody _json(Object? body, int statusCode) => ResponseBody.fromString(
  jsonEncode(body),
  statusCode,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// A backend a test drives, in place of a real one.
///
/// Answers the first [refusals] requests with an expired-token error and accepts every one after
/// that, so a refresh that works and one that never does share a harness. Set [reply] to answer
/// something else entirely, or [overlap] to answer nothing until that many requests are in flight
/// at once.
class _FakeApi implements HttpClientAdapter {
  _FakeApi({
    this.refusals = 0,
    this.refusalDelay,
    this.onRequest,
    this.reply,
    this.overlap,
  });

  /// How many of the first requests are refused.
  final int refusals;

  /// How long the nth refusal is held, for a rejection that has to land after an earlier one has
  /// already replaced the token.
  final Duration? Function(int attempt)? refusalDelay;

  /// Called as each request is dispatched, for a test that moves the manager mid-flight.
  final void Function()? onRequest;

  /// Replaces the reply entirely, for a backend answering something other than a Stream error.
  final ResponseBody Function(int attempt)? reply;

  /// Holds every request until this many are in flight at once.
  ///
  /// A caller that runs its requests one at a time never gets there, and the wait never finishes,
  /// which is what makes serialising them visible.
  final int? overlap;

  /// The most requests that were in flight at once.
  int get peakInFlight => _peakInFlight;
  var _peakInFlight = 0;

  final _reachedOverlap = Completer<void>();
  var _inFlight = 0;

  /// Every request that reached this backend, in order.
  final requests = <RequestOptions>[];

  /// The `Authorization` header each request carried, in order.
  final sentTokens = <String?>[];

  int get count => requests.length;
  RequestOptions? get lastRequest => requests.isEmpty ? null : requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    sentTokens.add(options.headers['Authorization'] as String?);
    final attempt = requests.length;

    onRequest?.call();

    if (reply case final reply?) return reply(attempt);

    if (attempt > refusals) {
      if (overlap case final overlap?) await _awaitOverlap(overlap);
      return _json(const <String, Object?>{}, 200);
    }

    if (refusalDelay?.call(attempt) case final delay?) {
      await Future<void>.delayed(delay);
    }

    return _json(_expiredTokenBody(), 401);
  }

  Future<void> _awaitOverlap(int overlap) async {
    _inFlight++;
    if (_inFlight > _peakInFlight) _peakInFlight = _inFlight;
    if (_inFlight >= overlap && !_reachedOverlap.isCompleted) _reachedOverlap.complete();

    await _reachedOverlap.future;
    _inFlight--;
  }

  @override
  void close({bool force = false}) {}
}

/// Builds a Dio carrying the interceptor under test, over a backend the test drives.
///
/// Defaults to the dynamic provider a real app has, issuing a token that can be told apart from the
/// last one. Pass [tokenProvider] for a static one, or [loader] to control when a load finishes and
/// what it returns; [loader] is given the number of the load, counting from one.
({
  Dio dio,
  _FakeApi api,
  TokenManager tokens,
  int Function() loads,
})
_subject({
  String userId = 'user-1',
  TokenProvider? tokenProvider,
  Future<UserToken> Function(String userId, int load)? loader,
  _FakeApi? api,
}) {
  var loads = 0;

  final tokens = TokenManager(
    userId: userId,
    tokenProvider:
        tokenProvider ??
        TokenProvider.dynamic((id) {
          loads++;
          return loader?.call(id, loads) ?? Future.value(generateTestUserToken(id, nonce: '$loads'));
        }),
  );

  final backend = api ?? _FakeApi();
  final dio = Dio(BaseOptions(baseUrl: 'https://example.com'))..httpClientAdapter = backend;
  dio.interceptors.add(AuthInterceptor(dio, tokens));

  return (dio: dio, api: backend, tokens: tokens, loads: () => loads);
}

/// Matches the token-expired error the backend refuses with, as the caller receives it.
final _expiredTokenError = isA<DioException>()
    .having((it) => it.response?.statusCode, 'response.statusCode', 401)
    .having((it) => (it.response?.data as Map?)?['code'], 'response.data.code', 40);

void main() {
  group('AuthInterceptor', () {
    test('sends the token, its auth type and its user as the request credentials', () async {
      final token = generateTestUserToken('user-123');
      final (:dio, :api, tokens: _, loads: _) = _subject(
        userId: 'user-123',
        tokenProvider: TokenProvider.static(token),
      );

      await dio.get<void>('/test');

      // The exact values, not merely that something was set: a header carrying the wrong token
      // authenticates as the wrong user, or not at all.
      expect(api.lastRequest?.headers['Authorization'], token.rawValue);
      expect(api.lastRequest?.headers['stream-auth-type'], AuthType.jwt.headerValue);
      expect(api.lastRequest?.queryParameters['user_id'], 'user-123');
    });

    test('sends an anonymous token as an empty Authorization header with the anonymous auth type', () async {
      final (:dio, :api, tokens: _, loads: _) = _subject(
        userId: User.anonymousUserId,
        tokenProvider: TokenProvider.static(UserToken.anonymous()),
      );

      await dio.get<void>('/test');

      expect(api.lastRequest?.headers['Authorization'], isEmpty);
      expect(api.lastRequest?.headers['stream-auth-type'], AuthType.anonymous.headerValue);
      expect(api.lastRequest?.queryParameters['user_id'], User.anonymousUserId);
    });

    test('sends a restricted anonymous token as the Authorization header', () async {
      final restricted = generateTestUserToken(User.anonymousUserId);
      final (:dio, :api, tokens: _, loads: _) = _subject(
        userId: User.anonymousUserId,
        tokenProvider: TokenProvider.static(UserToken.anonymous(rawValue: restricted.rawValue)),
      );

      await dio.get<void>('/test');

      // An anonymous token may still carry a JWT granting restricted access, which has to go out.
      expect(api.lastRequest?.headers['Authorization'], restricted.rawValue);
      expect(api.lastRequest?.headers['stream-auth-type'], AuthType.anonymous.headerValue);
    });

    test('sends the user id of the token it actually sent', () async {
      // A load already running for one user can finish after the manager has moved to another, and
      // its token still goes to the request that triggered it. Taking `user_id` from the token keeps
      // the pair consistent.
      final slowLoad = Completer<UserToken>();
      final (:dio, :api, :tokens, loads: _) = _subject(loader: (_, _) => slowLoad.future);

      final pending = dio.get<void>('/test');
      await pumpEventQueue();

      final userOneToken = generateTestUserToken('user-1');
      tokens.setTokenProvider('user-2', tokenProvider: TokenProvider.static(generateTestUserToken('user-2')));
      slowLoad.complete(userOneToken);
      await pending;

      expect(api.lastRequest?.queryParameters['user_id'], 'user-1');
      expect(api.lastRequest?.headers['Authorization'], userOneToken.rawValue);
    });

    test('fails a request whose token could not be loaded, rather than sending it unauthenticated', () async {
      final (:dio, :api, tokens: _, loads: _) = _subject(
        tokenProvider: TokenProvider.dynamic((_) async => throw StateError('token endpoint down')),
      );

      await expectLater(
        dio.get<void>('/test'),
        throwsA(
          isA<DioException>().having(
            (it) => it.error,
            'error',
            isA<ClientException>()
                .having((it) => it.message, 'message', 'Failed to load auth token')
                .having((it) => it.underlyingError, 'underlyingError', isStateError),
          ),
        ),
      );

      // Sent without credentials it would come back 401, which reads as a token the server refused
      // rather than one that was never loaded.
      expect(api.count, 0);
    });

    group('the refresh-and-retry', () {
      test('retries a token-expired response once with the token the provider issued next', () async {
        final (:dio, :api, tokens: _, :loads) = _subject(api: _FakeApi(refusals: 1));

        final response = await dio.get<void>('/test');

        expect(response.statusCode, 200);
        expect(api.count, 2);
        expect(loads(), 2);
        expect(api.sentTokens.first, isNot(api.sentTokens.last));
      });

      test('retries a multipart request without re-sending a consumed body', () async {
        final (:dio, :api, tokens: _, loads: _) = _subject(api: _FakeApi(refusals: 1));

        // A file's bytes are a stream, and the refused attempt has already read it. Without a clone
        // the retry fails with "The FormData has already been finalized".
        final body = FormData()..files.add(MapEntry('file', MultipartFile.fromString('contents')));

        final response = await dio.post<void>('/upload', data: body);

        expect(response.statusCode, 200);
        expect(api.count, 2);
      });

      test('reports a replacement the server refuses too, rather than leaving the caller waiting', () async {
        // The provider keeps issuing tokens that are refused. Retrying the retry would re-enter this
        // interceptor from inside itself, so the retry happens exactly once.
        final (:dio, :api, tokens: _, :loads) = _subject(api: _FakeApi(refusals: 10));

        await expectLater(
          dio.get<void>('/test').timeout(const Duration(seconds: 5)),
          throwsA(_expiredTokenError),
        );

        expect(api.count, 2);
        expect(loads(), 2);
      });

      test('leaves the token alone for a rejection that arrives after it was already replaced', () async {
        // Both requests carry the same token. The first is refused and replaces it, so by the time
        // the second is refused it is no longer the cached one, and expiring then would discard a
        // good replacement.
        final (:dio, :api, tokens: _, :loads) = _subject(
          api: _FakeApi(
            refusals: 2,
            refusalDelay: (attempt) => attempt == 2 ? const Duration(milliseconds: 200) : null,
          ),
        );

        await Future.wait([dio.get<void>('/a'), dio.get<void>('/b')]);

        expect(loads(), 2);
        expect(api.count, 4);
        expect(api.sentTokens.toSet(), hasLength(2));
      });

      test('sends a burst of rejected requests to the provider once between them', () async {
        // Every request in flight is rejected carrying the same spent token, and each expires it in
        // turn. The manager serialises the loads, so all three share one replacement.
        final replacementLoading = Completer<void>();
        final (:dio, :api, tokens: _, :loads) = _subject(
          api: _FakeApi(refusals: 3),
          loader: (id, load) async {
            // Held so all three refusals are handled at once.
            if (load > 1) await replacementLoading.future;
            return generateTestUserToken(id, nonce: '$load');
          },
        );

        final requests = Future.wait([dio.get<void>('/a'), dio.get<void>('/b'), dio.get<void>('/c')]);

        await pumpEventQueue();
        replacementLoading.complete();
        await requests;

        expect(loads(), 2);
        expect(api.count, 6);
        expect(api.sentTokens.skip(3).toSet(), hasLength(1));
      });
    });

    group('while a token load is in flight', () {
      test('holds a burst of requests until the first load finishes', () async {
        final loadStarted = Completer<void>();
        final loadGate = Completer<void>();
        final (:dio, :api, tokens: _, :loads) = _subject(
          loader: (id, load) async {
            if (!loadStarted.isCompleted) loadStarted.complete();
            await loadGate.future;
            return generateTestUserToken(id, nonce: '$load');
          },
        );

        final requests = Future.wait(List.generate(10, (i) => dio.get<void>('/r$i')));

        await loadStarted.future;
        await pumpEventQueue();
        expect(api.count, 0);
        expect(loads(), 1);

        loadGate.complete();
        await requests;

        // One load shared by all ten, rather than ten loads racing each other.
        expect(loads(), 1);
        expect(api.count, 10);
        expect(api.sentTokens.toSet(), hasLength(1));
      });

      test('does not hold requests behind one another', () async {
        // The reason this is an `Interceptor` and not a `QueuedInterceptor`: a queue would run these
        // one at a time, and the retry sent from `onError` would wait behind the request still
        // holding the handler, so neither would ever finish.
        final (:dio, :api, tokens: _, loads: _) = _subject(api: _FakeApi(overlap: 5));

        final requests = Future.wait(List.generate(5, (i) => dio.get<void>('/r$i')));
        await requests.timeout(const Duration(seconds: 5));

        expect(api.peakInFlight, 5);
      });

      test('does not hold the retries of a burst that was all refused behind one another', () async {
        // Every request is refused for its token, so every one retries. The token load is shared,
        // but the retries themselves must still go out together.
        final (:dio, :api, tokens: _, :loads) = _subject(api: _FakeApi(refusals: 3, overlap: 3));

        final requests = Future.wait([dio.get<void>('/a'), dio.get<void>('/b'), dio.get<void>('/c')]);
        await requests.timeout(const Duration(seconds: 5));

        expect(api.peakInFlight, 3);
        expect(loads(), 2);
      });

      test('holds a new request until an in-flight refresh finishes', () async {
        final refreshGate = Completer<void>();
        final (:dio, :api, tokens: _, :loads) = _subject(
          api: _FakeApi(refusals: 1),
          loader: (id, load) async {
            // Hold the replacement, not the token the first request carries.
            if (load > 1) await refreshGate.future;
            return generateTestUserToken(id, nonce: '$load');
          },
        );

        final first = dio.get<void>('/a');
        await pumpEventQueue();
        expect(loads(), 2);
        expect(api.count, 1);

        // A request arriving during the refresh waits for the replacement rather than going out with
        // the token that was just refused.
        final second = dio.get<void>('/b');
        await pumpEventQueue();
        expect(api.count, 1);

        refreshGate.complete();
        await Future.wait([first, second]);

        expect(loads(), 2);
        expect(api.sentTokens.first, isNot(api.sentTokens.last));
        expect(api.sentTokens.skip(1).toSet(), hasLength(1));
      });
    });

    group('when no other token could be presented', () {
      test('does not retry when the provider has only the token that was refused', () async {
        final (:dio, :api, tokens: _, loads: _) = _subject(
          userId: 'guest-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('guest-1')),
          api: _FakeApi(refusals: 10),
        );

        // A static provider reissues what was refused, so the retry would present it again.
        await expectLater(dio.get<void>('/test'), throwsA(_expiredTokenError));

        expect(api.count, 1);
      });

      test('does not retry when a static provider is adopted mid-flight', () async {
        // Starts on a dynamic provider and adopts a static one carrying the exchanged id once the
        // request is in flight, mirroring the guest flow. `onError` sees the static provider and
        // must forward the error rather than expire and retry.
        late TokenManager tokens;
        final subject = _subject(
          userId: 'requested-id',
          api: _FakeApi(
            refusals: 10,
            onRequest: () => tokens.setTokenProvider(
              'server-assigned-id',
              tokenProvider: TokenProvider.static(generateTestUserToken('server-assigned-id')),
            ),
          ),
        );
        tokens = subject.tokens;

        await expectLater(subject.dio.get<void>('/test'), throwsA(_expiredTokenError));

        expect(subject.api.count, 1);
      });

      test('does not retry a request signed for a user the manager has moved on from', () async {
        // The manager is pointed at another user while the request is in flight. Retrying would sign
        // it with their token and perform one user's request as another, and answer the caller as
        // though their own had succeeded.
        late TokenManager tokens;
        final subject = _subject(
          userId: 'user-a',
          api: _FakeApi(
            refusals: 10,
            onRequest: () => tokens.setTokenProvider(
              'user-b',
              tokenProvider: TokenProvider.dynamic((id) async => generateTestUserToken(id)),
            ),
          ),
        );
        tokens = subject.tokens;

        await expectLater(subject.dio.get<void>('/test'), throwsA(_expiredTokenError));

        expect(subject.api.count, 1);
        expect(subject.api.sentTokens.single, isNot(contains('user-b')));
      });

      test('forwards the error when the manager has no identity left to load a token for', () async {
        late TokenManager tokens;
        final subject = _subject(api: _FakeApi(refusals: 10, onRequest: () => tokens.reset()));
        tokens = subject.tokens;

        // Retrying would replace this with the less useful failure to load a token for a user the
        // manager no longer has.
        await expectLater(subject.dio.get<void>('/test'), throwsA(_expiredTokenError));

        expect(subject.api.count, 1);
      });
    });

    test('retries a token-expired response the server sent as text rather than JSON', () async {
      // A proxy or gateway can answer without a JSON content type, and Dio then hands the body over
      // as a string. It is the same refusal, so it deserves the same replacement.
      var attempt = 0;
      final (:dio, :api, tokens: _, :loads) = _subject(
        api: _FakeApi(
          reply: (_) => switch (++attempt) {
            1 => ResponseBody.fromString(
              jsonEncode(_expiredTokenBody()),
              401,
              headers: {
                Headers.contentTypeHeader: ['text/plain'],
              },
            ),
            _ => _json(const <String, Object?>{}, 200),
          },
        ),
      );

      final response = await dio.get<void>('/test');

      expect(response.statusCode, 200);
      expect(api.count, 2);
      expect(loads(), 2);
    });

    group('an error that is not a Stream token error', () {
      test('is forwarded when its JSON body belongs to something else', () async {
        // A proxy or gateway answers with a JSON body of its own. Parsing it as a Stream error
        // throws, and an error thrown in `onError` never reaches the caller: the request used to
        // hang for good instead of failing.
        final (:dio, :api, tokens: _, loads: _) = _subject(
          api: _FakeApi(reply: (_) => _json({'error': 'gateway timeout'}, 504)),
        );

        await expectLater(
          dio.get<void>('/test'),
          throwsA(isA<DioException>().having((it) => it.response?.statusCode, 'response.statusCode', 504)),
        );

        expect(api.count, 1);
      });

      test('is forwarded when it carries no JSON at all', () async {
        // A gateway answering HTML, which is the shape of most failures that are not the API's.
        final (:dio, :api, tokens: _, :loads) = _subject(
          api: _FakeApi(
            reply: (_) => ResponseBody.fromString(
              '<html><body>502 Bad Gateway</body></html>',
              502,
              headers: {
                Headers.contentTypeHeader: ['text/html'],
              },
            ),
          ),
        );

        await expectLater(
          dio.get<void>('/test'),
          throwsA(isA<DioException>().having((it) => it.response?.statusCode, 'response.statusCode', 502)),
        );

        // Nothing here says the token is spent, so it is neither expired nor reloaded.
        expect(api.count, 1);
        expect(loads(), 1);
      });
    });

    group('what the logger sees', () {
      test('reports the retry and the token behind it', () async {
        final handler = RecordingLogHandler();
        final (:dio, api: _, tokens: _, loads: _) = _subject(api: _FakeApi(refusals: 1));

        await withStreamLogger(handler: handler, () => dio.get<void>('/test'));

        expect(handler.tags, everyElement('SC:HttpAuth'));
        expect(handler.messages.join(), contains('retrying'));
      });

      test('reports a refusal it will not retry, and why', () async {
        final handler = RecordingLogHandler();
        final (:dio, api: _, tokens: _, loads: _) = _subject(
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
          api: _FakeApi(refusals: 1),
        );

        await withStreamLogger(
          handler: handler,
          () => expectLater(dio.get<void>('/test'), throwsA(_expiredTokenError)),
        );

        // A refused request left refused is what someone debugging a stuck login is looking at, so
        // the reason it was not retried has to be somewhere.
        expect(handler.messages.join(), contains('static'));
      });

      test('reports a replacement that was refused too', () async {
        final handler = RecordingLogHandler();
        final (:dio, api: _, tokens: _, loads: _) = _subject(api: _FakeApi(refusals: 2));

        await withStreamLogger(
          handler: handler,
          () => expectLater(dio.get<void>('/test'), throwsA(_expiredTokenError)),
        );

        expect(handler.messages.join(), contains('refused too'));
      });

      test('says nothing when no handler is installed', () async {
        final (:dio, api: _, tokens: _, loads: _) = _subject(api: _FakeApi(refusals: 1));

        final printed = capturePrints(() => dio.get<void>('/test'));
        await pumpEventQueue();

        expect(printed, isEmpty);
      });
    });
  });
}
