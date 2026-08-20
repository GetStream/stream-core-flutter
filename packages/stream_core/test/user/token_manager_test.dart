import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:meta/meta.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/user_token.dart';

/// A token provider that reports itself equal to any other of its kind, the way
/// a provider with value equality can.
@immutable
class _EquatableProvider implements TokenProvider {
  const _EquatableProvider(this._token);

  final UserToken _token;

  @override
  Future<UserToken> loadToken(String userId) async => _token;

  @override
  bool operator ==(Object other) => other is _EquatableProvider;

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
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        final first = await manager.getToken();
        final second = await manager.getToken();

        expect(first, generateTestUserToken('user-1'));
        expect(second, generateTestUserToken('user-1'));
        expect(provider.loadCount, 1);
        expect(manager.peekToken(), generateTestUserToken('user-1'));
      });

      test('passes the manager userId to the provider', () async {
        String? requestedUserId;
        final provider = _CountingProvider((userId) async {
          requestedUserId = userId;
          return generateTestUserToken(userId);
        });
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        await manager.getToken();

        expect(requestedUserId, 'user-1');
      });

      test('coalesces concurrent calls into a single load', () async {
        final completer = Completer<UserToken>();
        final provider = _CountingProvider((_) => completer.future);
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        final futures = [manager.getToken(), manager.getToken()];
        completer.complete(generateTestUserToken('user-1'));
        final tokens = await Future.wait(futures);

        expect(tokens, everyElement(generateTestUserToken('user-1')));
        expect(provider.loadCount, 1);
      });

      test('does not cache a failed load', () async {
        var attempts = 0;
        final provider = _CountingProvider((_) async {
          attempts++;
          if (attempts == 1) throw StateError('load failed');
          return generateTestUserToken('user-1');
        });
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        await expectLater(manager.getToken(), throwsStateError);
        expect(manager.peekToken(), isNull);

        final token = await manager.getToken();
        expect(token, generateTestUserToken('user-1'));
        expect(provider.loadCount, 2);
      });
    });

    group('expireToken', () {
      test('clears the cache and forces a reload', () async {
        var version = 0;
        final provider = _CountingProvider(
          (userId) async => generateTestUserToken(userId, nonce: 'v${++version}'),
        );
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        expect(await manager.getToken(), generateTestUserToken('user-1', nonce: 'v1'));

        manager.expireToken();
        expect(manager.peekToken(), isNull);

        expect(await manager.getToken(), generateTestUserToken('user-1', nonce: 'v2'));
        expect(provider.loadCount, 2);
      });

      test(
        'discards a load in flight',
        () async {
          final slowLoad = Completer<UserToken>();
          final manager = TokenManager(
            userId: 'user-1',
            tokenProvider: _CountingProvider((_) => slowLoad.future),
          );

          final pending = manager.getToken();

          manager.expireToken();
          slowLoad.complete(generateTestUserToken('user-1'));
          await pending;

          expect(manager.peekToken(), isNull);
        },
      );
    });

    group('setTokenProvider', () {
      test('points the manager at another user', () async {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
        );

        expect((await manager.getToken()).userId, 'user-1');

        manager.setTokenProvider(
          'user-2',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-2')),
        );

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

        manager.setTokenProvider(
          'user-2',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-2')),
        );

        expect(manager.peekToken(), isNull);
      });

      test(
        'adopts a user id and token that were not known up front',
        () async {
          const serverId = 'guest-abc-guest-123';

          final manager = TokenManager(
            userId: User.anonymousUserId,
            tokenProvider: TokenProvider.static(UserToken.anonymous()),
          );

          final anonymous = await manager.getToken();
          expect(anonymous.authType, AuthType.anonymous);
          expect(anonymous.rawValue, isEmpty);

          manager.setTokenProvider(
            serverId,
            tokenProvider: TokenProvider.static(generateTestUserToken(serverId)),
          );

          final guest = await manager.getToken();
          expect(manager.userId, serverId);
          expect(guest.authType, AuthType.jwt);
          expect(guest.userId, serverId);
        },
      );

      test('a load in flight does not cache its token over the new user', () async {
        final slowLoad = Completer<UserToken>();
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) => slowLoad.future),
        );

        final pending = manager.getToken();

        manager.setTokenProvider(
          'user-2',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-2')),
        );
        slowLoad.complete(generateTestUserToken('user-1'));
        await pending;

        // user-1's token must not be waiting in the cache for user-2 to send.
        expect(manager.peekToken(), isNull);
        expect((await manager.getToken()).userId, 'user-2');
      });

      test(
        'discards a load in flight when only the provider changes',
        () async {
          final slowLoad = Completer<UserToken>();
          final manager = TokenManager(
            userId: 'user-1',
            tokenProvider: _CountingProvider((_) => slowLoad.future),
          );

          final pending = manager.getToken();

          // Same user, fresh provider — the user id guard alone would let the
          // replaced provider's token through.
          manager.setTokenProvider(
            'user-1',
            tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
          );
          slowLoad.complete(generateTestUserToken('user-1'));
          await pending;

          expect(manager.peekToken(), isNull);
        },
      );

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
        await expectLater(manager.getToken(), throwsA(isA<ClientException>()));
      });

      test('loads once an identity is supplied', () async {
        final manager = TokenManager.unconfigured();

        manager.setTokenProvider(
          'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
        );

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
        await expectLater(manager.getToken(), throwsA(isA<ClientException>()));
      });

      test('leaves the manager reusable for another user', () async {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
        )..reset();

        manager.setTokenProvider(
          'user-2',
          tokenProvider: TokenProvider.static(generateTestUserToken('user-2')),
        );

        expect((await manager.getToken()).userId, 'user-2');
      });

      test('discards a load already in flight', () async {
        final completer = Completer<UserToken>();
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) => completer.future),
        );

        final inFlight = manager.getToken();
        manager.reset();
        completer.complete(generateTestUserToken('user-1'));

        // A reset is a logout: the token is neither cached nor handed to the
        // caller, so no request goes out as a user the manager no longer has.
        await expectLater(inFlight, throwsA(isA<ClientException>()));
        expect(manager.peekToken(), isNull);
      });
    });

    group('setTokenProvider', () {
      test('keeps the cached token when re-set with the same identity', () async {
        final provider = _CountingProvider((userId) async => generateTestUserToken(userId));
        final manager = TokenManager(userId: 'user-1', tokenProvider: provider);
        await manager.getToken();

        manager.setTokenProvider('user-1', tokenProvider: provider);

        // Expiring here would send a caller to the provider for an identity it
        // already has, which a defensive re-set on reconnect does routinely.
        expect(manager.peekToken(), isNotNull);
        await manager.getToken();
        expect(provider.loadCount, 1);
      });

      test('replaces a provider that merely compares equal to the previous one', () async {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _EquatableProvider(generateTestUserToken('user-1', nonce: 'first')),
        );
        expect(await manager.getToken(), generateTestUserToken('user-1', nonce: 'first'));

        manager.setTokenProvider(
          'user-1',
          tokenProvider: _EquatableProvider(generateTestUserToken('user-1', nonce: 'second')),
        );

        // A provider defines its own equality, so keeping the cached token
        // because the replacement called itself equal would serve a token the
        // previous provider issued.
        expect(manager.peekToken(), isNull);
        expect(await manager.getToken(), generateTestUserToken('user-1', nonce: 'second'));
      });
    });

    group('loadTimeout', () {
      test('fails a load that never returns and lets later callers through', () {
        fakeAsync((async) {
          final manager = TokenManager(
            userId: 'user-1',
            tokenProvider: _CountingProvider((_) => Completer<UserToken>().future),
            loadTimeout: const Duration(seconds: 5),
          );

          Object? error;
          manager.getToken().onError<Object>((it, _) {
            error = it;
            return generateTestUserToken('user-1');
          });

          async.elapse(const Duration(seconds: 5));
          async.flushMicrotasks();

          expect(error, isA<ClientException>());

          // The point of failing rather than waiting: the lock is free, so a
          // working provider can serve the next caller.
          UserToken? served;
          manager.setTokenProvider(
            'user-1',
            tokenProvider: _CountingProvider((userId) async => generateTestUserToken(userId)),
          );
          manager.getToken().then((it) => served = it);
          async.flushMicrotasks();

          expect(served, generateTestUserToken('user-1'));
        });
      });

      test('discards a token the load it gave up on returns later', () {
        fakeAsync((async) {
          final slow = Completer<UserToken>();
          final manager = TokenManager(
            userId: 'user-1',
            tokenProvider: _CountingProvider((_) => slow.future),
            loadTimeout: const Duration(seconds: 5),
          );

          manager.getToken().ignore();
          async.elapse(const Duration(seconds: 5));
          async.flushMicrotasks();

          slow.complete(generateTestUserToken('user-1'));
          async.flushMicrotasks();

          // Caching it would hand a caller a token from a load already reported
          // as failed.
          expect(manager.peekToken(), isNull);
        });
      });
    });

    group('_loadAndNotify', () {
      test('rejects a token a custom provider issued for another user', () async {
        // Neither built-in provider can do this, but `TokenProvider` is an
        // interface: caching it would authenticate later requests as them.
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) async => generateTestUserToken('someone-else')),
        );

        await expectLater(manager.getToken(), throwsArgumentError);
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
        final provider = _CountingProvider(
          (userId) async => generateTestUserToken(userId, nonce: 'v${++version}'),
        );
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
          onTokenUpdated: updates.add,
        );

        await manager.getToken();
        await manager.getToken(); // served from cache

        manager.expireToken();
        await manager.getToken();

        expect(updates, [
          generateTestUserToken('user-1', nonce: 'v1'),
          generateTestUserToken('user-1', nonce: 'v2'),
        ]);
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
