import 'dart:convert';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

/// Builds an unsigned JWT with the given [userId] claim, sufficient for
/// [UserToken]'s unverified parsing.
String _fakeJwt(String userId) {
  String encode(Map<String, dynamic> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
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
      final token = UserToken.anonymous(rawValue: 'restricted-jwt');

      expect(token.userId, '!anon');
      expect(token.rawValue, 'restricted-jwt');
      expect(token.authType, AuthType.anonymous);
    });
  });

  group('StaticTokenProvider', () {
    test('returns the token when the user ID matches', () async {
      final token = UserToken.anonymous(userId: 'user-1');
      final provider = TokenProvider.static(token);

      expect(await provider.loadToken('user-1'), token);
    });

    test('throws when the user ID does not match', () {
      final token = UserToken.anonymous(userId: 'user-1');
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
        (userId) async => UserToken.anonymous(userId: userId),
      );

      expect(() => provider.loadToken('user-1'), throwsArgumentError);
    });
  });
}
