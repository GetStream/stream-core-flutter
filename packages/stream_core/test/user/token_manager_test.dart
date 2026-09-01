import 'dart:async';

import 'package:clock/clock.dart';
import 'package:meta/meta.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/user_token.dart';

/// A token provider whose instances all compare equal, as an implementation is free to define.
@immutable
class _AlwaysEqualProvider implements TokenProvider {
  const _AlwaysEqualProvider(this._token);

  final UserToken _token;

  @override
  Future<UserToken> loadToken(String userId) async => _token;

  @override
  bool operator ==(Object other) => other is _AlwaysEqualProvider;

  @override
  int get hashCode => 0;
}

/// A token provider that counts loads and delegates to a configurable loader.
class _CountingProvider implements TokenProvider {
  _CountingProvider(this._load);

  final Future<UserToken> Function(String userId) _load;

  var _loadCount = 0;
  int get loadCount => _loadCount;

  @override
  Future<UserToken> loadToken(String userId) {
    _loadCount++;
    return _load(userId);
  }
}

void main() {
  group('TokenManager', () {
    group('getToken', () {
      test('loads from the provider and caches the result', () async {
        final provider = _CountingProvider((_) async => generateTestUserToken('user-1'));
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);

        final first = await manager.getToken();
        final second = await manager.getToken();

        expect(first, generateTestUserToken('user-1'));
        expect(second, generateTestUserToken('user-1'));
        expect(provider.loadCount, 1);
        expect(manager.peekToken(), generateTestUserToken('user-1'));
      });

      test('replaces a cached token that has expired', () async {
        final expiry = DateTime.utc(2030);
        final provider = _CountingProvider((id) async => generateTestUserToken(id, expiresAt: expiry));
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);

        await withClock(Clock.fixed(expiry.subtract(const Duration(hours: 1))), manager.getToken);
        expect(provider.loadCount, 1);

        // Past its expiry the server would refuse it, so presenting it costs a request to find out
        // what the token already said.
        await withClock(Clock.fixed(expiry.add(const Duration(seconds: 1))), manager.getToken);

        expect(provider.loadCount, 2);
      });

      test('keeps a cached token that has not expired yet', () async {
        final expiry = DateTime.utc(2030);
        final provider = _CountingProvider((id) async => generateTestUserToken(id, expiresAt: expiry));
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);

        await withClock(Clock.fixed(expiry.subtract(const Duration(hours: 1))), manager.getToken);
        await withClock(Clock.fixed(expiry.subtract(const Duration(seconds: 1))), manager.getToken);

        // A second of life left is still life: a margin ahead of the expiry would throw it away.
        expect(provider.loadCount, 1);
      });

      test('contacts the provider once for a token that is short-lived, not once per call', () async {
        // A backend issuing tokens that live for seconds. Treating anything near its expiry as spent
        // makes every call a load, which is the caching this manager exists for, undone.
        final issued = DateTime.utc(2030);
        var loads = 0;
        final provider = _CountingProvider(
          (id) async => generateTestUserToken(id, expiresAt: issued.add(Duration(seconds: 30 + ++loads))),
        );
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);

        await withClock(Clock.fixed(issued), () async {
          for (var i = 0; i < 5; i++) {
            await manager.getToken();
          }
        });

        expect(provider.loadCount, 1);
      });

      test('hands out a static provider token that has expired, rather than asking again', () async {
        final expiry = DateTime.utc(2030);
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1', expiresAt: expiry)),
        );

        // A static provider has nothing fresher to give. The server refusing it is what tells a
        // guest to exchange for a new identity, and asking again only produces the same token.
        final token = await withClock(
          Clock.fixed(expiry.add(const Duration(hours: 1))),
          manager.getToken,
        );

        expect(token.expiresAt, expiry);
        expect(manager.peekToken(), isNotNull);
      });

      test('notifies once per load, not once per call for a token near its expiry', () async {
        final expiry = DateTime.utc(2030);
        final updated = <UserToken>[];
        final provider = _CountingProvider((id) async => generateTestUserToken(id, expiresAt: expiry));
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
          onTokenUpdated: updated.add,
        );

        await withClock(Clock.fixed(expiry.subtract(const Duration(seconds: 1))), () async {
          for (var i = 0; i < 4; i++) {
            await manager.getToken();
          }
        });

        // A notification per call would have every listener re-running for a token that never moved.
        expect(updated, hasLength(1));
      });

      test('passes the manager userId to the provider', () async {
        String? requestedUserId;
        final provider = _CountingProvider((userId) async {
          requestedUserId = userId;
          return generateTestUserToken(userId);
        });
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);

        await manager.getToken();

        expect(requestedUserId, 'user-1');
      });

      test('coalesces concurrent calls into a single load', () async {
        final completer = Completer<UserToken>();
        final provider = _CountingProvider((_) => completer.future);
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);

        final futures = [manager.getToken(), manager.getToken()];
        completer.complete(generateTestUserToken('user-1'));
        final tokens = await Future.wait(futures);

        expect(tokens, everyElement(generateTestUserToken('user-1')));
        expect(provider.loadCount, 1);
      });

      test('concurrent calls share a failed load', () async {
        final failedLoad = Completer<UserToken>();
        final provider = _CountingProvider((_) => failedLoad.future);
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);

        final futures = List.generate(5, (_) => manager.getToken());
        failedLoad.completeError(StateError('load failed'));

        // A provider refusing one caller refuses all five, so asking it five times over would
        // hammer a token endpoint that has already said no.
        for (final future in futures) {
          await expectLater(future, throwsA(isA<StreamAuthenticationException>()));
        }

        expect(provider.loadCount, 1);
      });

      test('a caller arriving after the load is invalidated does not join it', () async {
        final slowLoad = Completer<UserToken>();
        var loads = 0;
        final provider = _CountingProvider((userId) {
          if (++loads == 1) return slowLoad.future;
          return Future.value(generateTestUserToken(userId, nonce: 'fresh'));
        });
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);

        final stale = manager.getToken();
        manager.expireToken();

        // The load `expireToken` discarded must not be the one this caller is served from.
        expect(await manager.getToken(), generateTestUserToken('user-1', nonce: 'fresh'));

        slowLoad.complete(generateTestUserToken('user-1', nonce: 'stale'));
        await stale;
        expect(provider.loadCount, 2);
      });

      test('does not cache a failed load', () async {
        var attempts = 0;
        final provider = _CountingProvider((_) async {
          attempts++;
          if (attempts == 1) throw StateError('load failed');
          return generateTestUserToken('user-1');
        });
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);

        // Whatever the provider threw arrives as an authentication failure,
        // with the original error preserved as its cause.
        await expectLater(
          manager.getToken(),
          throwsA(isA<StreamAuthenticationException>().having((it) => it.cause, 'cause', isStateError)),
        );
        expect(manager.peekToken(), isNull);

        final token = await manager.getToken();
        expect(token, generateTestUserToken('user-1'));
        expect(provider.loadCount, 2);
      });

      test('keeps a failure the provider already classified', () async {
        const failure = StreamNetworkException(message: 'The token endpoint was unreachable');
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) async => throw failure),
        );

        // A provider saying "this was the moment" must stay a network failure: wrapped as an
        // authentication one it would read as "fix the credentials" and stop the reconnect.
        await expectLater(manager.getToken(), throwsA(same(failure)));
      });

      test('reads a provider timeout as a network failure', () async {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) async => throw TimeoutException('took too long')),
        );

        await expectLater(
          manager.getToken(),
          throwsA(
            isA<StreamNetworkException>()
                .having((it) => it.isTimeout, 'isTimeout', isTrue)
                .having((it) => it.cause, 'cause', isA<TimeoutException>()),
          ),
        );
      });
    });

    group('expireToken', () {
      test('clears the cache and forces a reload', () async {
        var version = 0;
        final provider = _CountingProvider((userId) async => generateTestUserToken(userId, nonce: 'v${++version}'));
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);

        expect(await manager.getToken(), generateTestUserToken('user-1', nonce: 'v1'));

        manager.expireToken();
        expect(manager.peekToken(), isNull);

        expect(await manager.getToken(), generateTestUserToken('user-1', nonce: 'v2'));
        expect(provider.loadCount, 2);
      });

      test('discards a load in flight', () async {
        final slowLoad = Completer<UserToken>();
        final manager = TokenManager(userId: 'user-1', tokenProvider: _CountingProvider((_) => slowLoad.future));

        final pending = manager.getToken();

        manager.expireToken();
        slowLoad.complete(generateTestUserToken('user-1'));
        await pending;

        expect(manager.peekToken(), isNull);
      });
    });

    group('setTokenProvider', () {
      test('points the manager at another user', () async {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
        );

        expect((await manager.getToken()).userId, 'user-1');

        manager.setTokenProvider('user-2', tokenProvider: TokenProvider.static(generateTestUserToken('user-2')));

        expect(manager.userId, 'user-2');
        expect((await manager.getToken()).userId, 'user-2');
      });

      test('expires the token cached for the previous user', () async {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
        );

        await manager.getToken();
        expect(manager.peekToken(), generateTestUserToken('user-1'));

        manager.setTokenProvider('user-2', tokenProvider: TokenProvider.static(generateTestUserToken('user-2')));

        expect(manager.peekToken(), isNull);
      });

      test('adopts a user id and token that were not known up front', () async {
        const serverId = 'guest-abc-guest-123';

        final manager = TokenManager(
          userId: User.anonymousUserId,
          tokenProvider: TokenProvider.static(UserToken.anonymous()),
        );

        final anonymous = await manager.getToken();
        expect(anonymous.authType, AuthType.anonymous);
        expect(anonymous.rawValue, isEmpty);

        manager.setTokenProvider(serverId, tokenProvider: TokenProvider.static(generateTestUserToken(serverId)));

        final guest = await manager.getToken();
        expect(manager.userId, serverId);
        expect(guest.authType, AuthType.jwt);
        expect(guest.userId, serverId);
      });

      test('a load in flight does not cache its token over the new user', () async {
        final slowLoad = Completer<UserToken>();
        final manager = TokenManager(userId: 'user-1', tokenProvider: _CountingProvider((_) => slowLoad.future));

        final pending = manager.getToken();

        manager.setTokenProvider('user-2', tokenProvider: TokenProvider.static(generateTestUserToken('user-2')));
        slowLoad.complete(generateTestUserToken('user-1'));
        await pending;

        // The token for user-1 must not be waiting in the cache for user-2 to send.
        expect(manager.peekToken(), isNull);
        expect((await manager.getToken()).userId, 'user-2');
      });

      test('discards a load in flight when only the provider changes', () async {
        final slowLoad = Completer<UserToken>();
        final manager = TokenManager(userId: 'user-1', tokenProvider: _CountingProvider((_) => slowLoad.future));

        final pending = manager.getToken();

        // Same user, different provider: the user id guard alone would let the replaced provider's
        // token through.
        manager.setTokenProvider('user-1', tokenProvider: TokenProvider.static(generateTestUserToken('user-1')));
        slowLoad.complete(generateTestUserToken('user-1'));
        await pending;

        expect(manager.peekToken(), isNull);
      });

      test('usesStaticProvider reflects the new provider', () {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
        );

        expect(manager.usesStaticProvider, isTrue);

        manager.setTokenProvider(
          'user-1',
          tokenProvider: _CountingProvider((_) async => generateTestUserToken('user-1')),
        );

        expect(manager.usesStaticProvider, isFalse);
      });
    });

    group('unconfigured', () {
      test('has no user and fails to load a token', () async {
        final manager = TokenManager.unconfigured();

        expect(manager.userId, isNull);
        expect(manager.peekToken(), isNull);
        expect(manager.usesStaticProvider, isFalse);
        await expectLater(manager.getToken(), throwsA(isA<StreamAuthenticationException>()));
      });

      test('loads once an identity is supplied', () async {
        final manager = TokenManager.unconfigured();

        manager.setTokenProvider('user-1', tokenProvider: TokenProvider.static(generateTestUserToken('user-1')));

        expect(manager.userId, 'user-1');
        expect((await manager.getToken()).userId, 'user-1');
      });
    });

    group('reset', () {
      test('drops the identity and the cached token', () async {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
        );

        await manager.getToken();
        expect(manager.peekToken(), isNotNull);

        manager.reset();

        expect(manager.userId, isNull);
        expect(manager.peekToken(), isNull);
        await expectLater(manager.getToken(), throwsA(isA<StreamAuthenticationException>()));
      });

      test('leaves the manager reusable for another user', () async {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
        )..reset();

        manager.setTokenProvider('user-2', tokenProvider: TokenProvider.static(generateTestUserToken('user-2')));

        expect((await manager.getToken()).userId, 'user-2');
      });

      test('discards a load already in flight', () async {
        final completer = Completer<UserToken>();
        final manager = TokenManager(userId: 'user-1', tokenProvider: _CountingProvider((_) => completer.future));

        final inFlight = manager.getToken();
        manager.reset();
        completer.complete(generateTestUserToken('user-1'));

        // A reset is a logout, so the token is neither cached nor handed to the caller.
        await expectLater(inFlight, throwsA(isA<StreamAuthenticationException>()));
        expect(manager.peekToken(), isNull);
      });
    });

    group('setTokenProvider', () {
      test('keeps the cached token when re-set with the same identity', () async {
        final provider = _CountingProvider((userId) async => generateTestUserToken(userId));
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);
        await manager.getToken();

        manager.setTokenProvider('user-1', tokenProvider: provider);

        // A defensive re-set on reconnect does this routinely, and must not cost a load.
        expect(manager.peekToken(), isNotNull);
        await manager.getToken();
        expect(provider.loadCount, 1);
      });

      test('keeps the cached token when the provider says it is unchanged', () async {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _AlwaysEqualProvider(generateTestUserToken('user-1', nonce: 'first')),
        );
        expect(await manager.getToken(), generateTestUserToken('user-1', nonce: 'first'));

        manager.setTokenProvider(
          'user-1',
          tokenProvider: _AlwaysEqualProvider(generateTestUserToken('user-1', nonce: 'second')),
        );

        // The provider declares the replacement equal, so the cached token stands.
        expect(manager.peekToken(), generateTestUserToken('user-1', nonce: 'first'));
      });
    });

    group('_loadAndNotify', () {
      test('rejects a token a custom provider issued for another user', () async {
        // Neither built-in provider can do this, but `TokenProvider` is an interface, and caching
        // such a token would authenticate later requests as the wrong user.
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) async => generateTestUserToken('someone-else')),
        );

        await expectLater(manager.getToken(), throwsA(isA<StreamAuthenticationException>()));
        expect(manager.peekToken(), isNull);
      });
    });

    group('usesStaticProvider', () {
      test('reflects the provider type', () {
        final staticManager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
        );
        final dynamicManager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) async => generateTestUserToken('t')),
        );

        expect(staticManager.usesStaticProvider, isTrue);
        expect(dynamicManager.usesStaticProvider, isFalse);
      });
    });

    group('onTokenUpdated', () {
      test('fires once per load with the loaded token', () async {
        final updates = <UserToken>[];
        var version = 0;
        final provider = _CountingProvider((userId) async => generateTestUserToken(userId, nonce: 'v${++version}'));
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider, onTokenUpdated: updates.add);

        await manager.getToken();
        await manager.getToken(); // served from cache

        manager.expireToken();
        await manager.getToken();

        expect(updates, [generateTestUserToken('user-1', nonce: 'v1'), generateTestUserToken('user-1', nonce: 'v2')]);
      });

      test('is invoked before the token is returned', () async {
        UserToken? notified;
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((userId) async => generateTestUserToken(userId)),
          onTokenUpdated: (token) => notified = token,
        );

        final token = await manager.getToken();

        expect(notified, token);
      });

      test('can safely call back into the manager', () async {
        late TokenManager manager;
        Future<UserToken>? reentrantCall;
        manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((userId) async => generateTestUserToken(userId)),
          onTokenUpdated: (_) {
            reentrantCall = manager.getToken();
          },
        );

        final token = await manager.getToken();

        expect(await reentrantCall, token);
      });
    });
  });
}
