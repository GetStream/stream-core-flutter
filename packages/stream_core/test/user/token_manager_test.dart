import 'dart:async';
import 'dart:convert';

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

/// Builds a JWT [UserToken] carrying [userId] as its 'user_id' claim.
UserToken _generateTestUserToken(String userId) {
  String b64UrlNoPad(Object jsonObj) {
    final bytes = utf8.encode(jsonEncode(jsonObj));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  final header = {'alg': 'none', 'typ': 'JWT'};
  final payload = {'user_id': userId};

  // Trailing dot = empty signature, which is what alg=none means.
  return UserToken('${b64UrlNoPad(header)}.${b64UrlNoPad(payload)}.');
}

void main() {
  group('TokenManager', () {
    group('getToken', () {
      test('loads from the provider and caches the result', () async {
        final provider = _CountingProvider((_) async => _generateTestUserToken('token-1'));
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        final first = await manager.getToken();
        final second = await manager.getToken();

        expect(first, _generateTestUserToken('token-1'));
        expect(second, _generateTestUserToken('token-1'));
        expect(provider.loadCount, 1);
        expect(manager.peekToken(), _generateTestUserToken('token-1'));
      });

      test('passes the manager userId to the provider', () async {
        String? requestedUserId;
        final provider = _CountingProvider((userId) async {
          requestedUserId = userId;
          return _generateTestUserToken('token-1');
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
        completer.complete(_generateTestUserToken('token-1'));
        final tokens = await Future.wait(futures);

        expect(tokens, everyElement(_generateTestUserToken('token-1')));
        expect(provider.loadCount, 1);
      });

      test('does not cache a failed load', () async {
        var attempts = 0;
        final provider = _CountingProvider((_) async {
          attempts++;
          if (attempts == 1) throw StateError('load failed');
          return _generateTestUserToken('token-2');
        });
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        await expectLater(manager.getToken(), throwsStateError);
        expect(manager.peekToken(), isNull);

        final token = await manager.getToken();
        expect(token, _generateTestUserToken('token-2'));
        expect(provider.loadCount, 2);
      });
    });

    group('expireToken', () {
      test('clears the cache and forces a reload', () async {
        var version = 0;
        final provider = _CountingProvider((_) async => _generateTestUserToken('v${++version}'));
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
        );

        expect(await manager.getToken(), _generateTestUserToken('v1'));

        manager.expireToken();
        expect(manager.peekToken(), isNull);

        expect(await manager.getToken(), _generateTestUserToken('v2'));
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
          slowLoad.complete(_generateTestUserToken('user-1'));
          await pending;

          expect(manager.peekToken(), isNull);
        },
      );
    });

    group('setTokenProvider', () {
      test('points the manager at another user', () async {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(_generateTestUserToken('user-1')),
        );

        expect((await manager.getToken()).userId, 'user-1');

        manager.setTokenProvider(
          'user-2',
          tokenProvider: TokenProvider.static(_generateTestUserToken('user-2')),
        );

        expect(manager.userId, 'user-2');
        expect((await manager.getToken()).userId, 'user-2');
      });

      test('expires the token cached for the previous user', () async {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(_generateTestUserToken('user-1')),
        );

        await manager.getToken();
        expect(manager.peekToken(), _generateTestUserToken('user-1'));

        manager.setTokenProvider(
          'user-2',
          tokenProvider: TokenProvider.static(_generateTestUserToken('user-2')),
        );

        expect(manager.peekToken(), isNull);
      });

      test(
        'adopts a user id and token that were not known up front',
        () async {
          const serverId = 'guest-abc-guest-123';

          final manager = TokenManager(
            userId: UserToken.anonymousUserId,
            tokenProvider: TokenProvider.static(UserToken.anonymous()),
          );

          final anonymous = await manager.getToken();
          expect(anonymous.authType, AuthType.anonymous);
          expect(anonymous.rawValue, isEmpty);

          manager.setTokenProvider(
            serverId,
            tokenProvider: TokenProvider.static(_generateTestUserToken(serverId)),
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
          tokenProvider: TokenProvider.static(_generateTestUserToken('user-2')),
        );
        slowLoad.complete(_generateTestUserToken('user-1'));
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
            tokenProvider: TokenProvider.static(_generateTestUserToken('user-1')),
          );
          slowLoad.complete(_generateTestUserToken('user-1'));
          await pending;

          expect(manager.peekToken(), isNull);
        },
      );

      test('usesStaticProvider reflects the new provider', () {
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(_generateTestUserToken('user-1')),
        );

        expect(manager.usesStaticProvider, isTrue);

        manager.setTokenProvider(
          'user-1',
          tokenProvider: _CountingProvider((_) async => _generateTestUserToken('user-1')),
        );

        expect(manager.usesStaticProvider, isFalse);
      });
    });

    group('usesStaticProvider', () {
      test('reflects the provider type', () {
        final staticManager = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.static(_generateTestUserToken('user-1')),
        );
        final dynamicManager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) async => _generateTestUserToken('t')),
        );

        expect(staticManager.usesStaticProvider, isTrue);
        expect(dynamicManager.usesStaticProvider, isFalse);
      });
    });

    group('onTokenUpdated', () {
      test('fires once per load with the loaded token', () async {
        final updates = <UserToken>[];
        var version = 0;
        final provider = _CountingProvider((_) async => _generateTestUserToken('v${++version}'));
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: provider,
          onTokenUpdated: updates.add,
        );

        await manager.getToken();
        await manager.getToken(); // served from cache

        manager.expireToken();
        await manager.getToken();

        expect(updates, [_generateTestUserToken('v1'), _generateTestUserToken('v2')]);
      });

      test('is invoked before the token is returned', () async {
        UserToken? notified;
        final manager = TokenManager(
          userId: 'user-1',
          tokenProvider: _CountingProvider((_) async => _generateTestUserToken('token-1')),
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
          tokenProvider: _CountingProvider((_) async => _generateTestUserToken('token-1')),
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
