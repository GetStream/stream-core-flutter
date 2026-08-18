import 'dart:async';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

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

UserToken _token(String value) => UserToken.anonymous(userId: value);

void main() {
  group('TokenManager', () {
    group('getToken', () {
      test('loads from the provider and caches the result', () async {
        final provider = _CountingProvider((_) async => _token('token-1'));
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        final first = await manager.getToken();
        final second = await manager.getToken();

        expect(first, _token('token-1'));
        expect(second, _token('token-1'));
        expect(provider.loadCount, 1);
        expect(manager.peekToken(), _token('token-1'));
      });

      test('passes the manager userId to the provider', () async {
        String? requestedUserId;
        final provider = _CountingProvider((userId) async {
          requestedUserId = userId;
          return _token('token-1');
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
        completer.complete(_token('token-1'));
        final tokens = await Future.wait(futures);

        expect(tokens, everyElement(_token('token-1')));
        expect(provider.loadCount, 1);
      });

      test('does not cache a failed load', () async {
        var attempts = 0;
        final provider = _CountingProvider((_) async {
          attempts++;
          if (attempts == 1) throw StateError('load failed');
          return _token('token-2');
        });
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        await expectLater(manager.getToken(), throwsStateError);
        expect(manager.peekToken(), isNull);

        final token = await manager.getToken();
        expect(token, _token('token-2'));
        expect(provider.loadCount, 2);
      });
    });

    group('expireToken', () {
      test('clears the cache and forces a reload', () async {
        var version = 0;
        final provider = _CountingProvider((_) async => _token('v${++version}'));
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        expect(await manager.getToken(), _token('v1'));

        manager.expireToken();
        expect(manager.peekToken(), isNull);

        expect(await manager.getToken(), _token('v2'));
        expect(provider.loadCount, 2);
      });
    });

    group('refreshToken', () {
      test('bypasses the cache and loads a fresh token', () async {
        var version = 0;
        final provider = _CountingProvider((_) async => _token('v${++version}'));
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        expect(await manager.getToken(), _token('v1'));
        expect(await manager.refreshToken(), _token('v2'));
        expect(manager.peekToken(), _token('v2'));
        expect(provider.loadCount, 2);
      });

      test('coalesces concurrent refreshes into a single load', () async {
        var version = 0;
        final completer = Completer<UserToken>();
        final provider = _CountingProvider((_) {
          version++;
          return completer.future;
        });
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        final futures = [manager.refreshToken(), manager.refreshToken()];
        completer.complete(_token('v$version'));
        final tokens = await Future.wait(futures);

        expect(tokens, everyElement(_token('v1')));
        expect(provider.loadCount, 1);
      });

      test('sequential refreshes each load a fresh token', () async {
        var version = 0;
        final provider = _CountingProvider((_) async => _token('v${++version}'));
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        expect(await manager.refreshToken(), _token('v1'));
        expect(await manager.refreshToken(), _token('v2'));
        expect(provider.loadCount, 2);
      });
    });

    group('tokenProvider setter', () {
      test('swaps the provider and expires the cached token', () async {
        final oldProvider = _CountingProvider((_) async => _token('old'));
        final newProvider = _CountingProvider((_) async => _token('new'));
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: oldProvider,
        );

        expect(await manager.getToken(), _token('old'));

        manager.tokenProvider = newProvider;

        expect(manager.peekToken(), isNull);
        expect(await manager.getToken(), _token('new'));
        expect(oldProvider.loadCount, 1);
        expect(newProvider.loadCount, 1);
      });

      test('keeps the cached token when the provider is unchanged', () async {
        final provider = _CountingProvider((_) async => _token('token-1'));
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        await manager.getToken();
        manager.tokenProvider = provider;

        expect(manager.peekToken(), _token('token-1'));
      });

      test('usesStaticProvider reflects the swapped provider', () {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(_token('user-1')),
        );

        expect(manager.usesStaticProvider, isTrue);

        manager.tokenProvider = _CountingProvider((_) async => _token('t'));

        expect(manager.usesStaticProvider, isFalse);
      });
    });

    group('usesStaticProvider', () {
      test('reflects the provider type', () {
        final staticManager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(_token('user-1')),
        );
        final dynamicManager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) async => _token('t')),
        );

        expect(staticManager.usesStaticProvider, isTrue);
        expect(dynamicManager.usesStaticProvider, isFalse);
      });
    });

    group('onTokenUpdated', () {
      test('fires once per load with the loaded token', () async {
        final updates = <UserToken>[];
        var version = 0;
        final provider = _CountingProvider((_) async => _token('v${++version}'));
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
          onTokenUpdated: updates.add,
        );

        await manager.getToken();
        await manager.getToken(); // served from cache
        await manager.refreshToken();

        expect(updates, [_token('v1'), _token('v2')]);
      });

      test('is awaited before the token is returned', () async {
        final completer = Completer<void>();
        var callbackCompleted = false;
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) async => _token('token-1')),
          onTokenUpdated: (_) async {
            await completer.future;
            callbackCompleted = true;
          },
        );

        final tokenFuture = manager.getToken();
        expect(callbackCompleted, isFalse);

        completer.complete();
        await tokenFuture;

        expect(callbackCompleted, isTrue);
      });

      test('can safely call back into the manager', () async {
        late TokenManager manager;
        UserToken? reentrantToken;
        manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) async => _token('token-1')),
          onTokenUpdated: (_) async {
            reentrantToken = await manager.getToken();
          },
        );

        final token = await manager.getToken();

        expect(reentrantToken, token);
      });
    });
  });
}
