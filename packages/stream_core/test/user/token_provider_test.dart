import 'dart:convert';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

/// Builds an unsigned JWT with the given [userId] claim, sufficient for
/// [UserToken]'s unverified parsing.
String _fakeJwt(String userId) {
  String encode(Map<String, dynamic> json) => base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final header = encode({'alg': 'HS256', 'typ': 'JWT'});
  final payload = encode({'user_id': userId});
  final signature = encode({'sig': 'fake'});
  return '$header.$payload.$signature';
}

void main() {
  group('UserToken.anonymous', () {
    test('defaults to !anon with no raw value', () {
      final token = UserToken.anonymous();

      expect(token.userId, '!anon');
      expect(token.rawValue, isEmpty);
      expect(token.authType, AuthType.anonymous);
    });

    test('carries an optional raw value for restricted access', () {
      final restricted = _fakeJwt(UserToken.anonymousUserId);
      final token = UserToken.anonymous(rawValue: restricted);

      expect(token.userId, '!anon');
      expect(token.rawValue, restricted);
      expect(token.authType, AuthType.anonymous);
    });

    test(
      'rejects a raw value claiming a real user, so an anonymous token cannot '
      'stand in for someone else',
      () {
        expect(
          () => UserToken.anonymous(rawValue: _fakeJwt('alice')),
          throwsArgumentError,
        );
      },
    );

    test('rejects a raw value that is not a JWT at all', () {
      expect(
        () => UserToken.anonymous(rawValue: 'not-a-jwt'),
        throwsArgumentError,
      );
    });

    test('rejects a raw value whose segments are not valid base64', () {
      // Shaped like a JWT, so parsing gets further before failing.
      expect(
        () => UserToken.anonymous(rawValue: 'a.b.c'),
        throwsFormatException,
      );
    });
  });

  group('StaticTokenProvider', () {
    test('returns the token when the user ID matches', () async {
      final token = UserToken(_fakeJwt('user-1'));
      final provider = TokenProvider.static(token);

      expect(await provider.loadToken('user-1'), token);
    });

    test('throws when the user ID does not match', () {
      final token = UserToken(_fakeJwt('user-1'));
      final provider = TokenProvider.static(token);

      expect(() => provider.loadToken('user-2'), throwsArgumentError);
    });
  });

  group('DynamicTokenProvider', () {
    test('returns JWT tokens from the loader', () async {
      final provider = TokenProvider.dynamic(
        (userId) async => UserToken(_fakeJwt(userId)),
      );

      final token = await provider.loadToken('user-1');

      expect(token.userId, 'user-1');
      expect(token.authType, AuthType.jwt);
    });

    test('throws when the loader returns a non-JWT token', () {
      final provider = TokenProvider.dynamic(
        (_) async => UserToken.anonymous(),
      );

      // Reported as the wrong type, not the wrong user: an anonymous token
      // also carries a user id that cannot match the one requested.
      expect(
        () => provider.loadToken('user-1'),
        throwsA(
          isArgumentError.having(
            (it) => it.message,
            'message',
            contains('Token type mismatch'),
          ),
        ),
      );
    });

    test(
      'throws when the loader returns a token for a different user, which would '
      'otherwise authenticate every later request as that user',
      () {
        final provider = TokenProvider.dynamic(
          (_) async => UserToken(_fakeJwt('someone-else')),
        );

        expect(() => provider.loadToken('user-1'), throwsArgumentError);
      },
    );
  });
}
