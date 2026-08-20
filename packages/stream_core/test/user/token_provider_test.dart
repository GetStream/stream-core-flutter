import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/user_token.dart';

void main() {
  group('UserToken.anonymous', () {
    test('defaults to !anon with no raw value', () {
      final token = UserToken.anonymous();

      expect(token.userId, '!anon');
      expect(token.rawValue, isEmpty);
      expect(token.authType, AuthType.anonymous);
    });

    test('carries an optional raw value for restricted access', () {
      final restricted = generateTestJwt(User.anonymousUserId);
      final token = UserToken.anonymous(rawValue: restricted);

      expect(token.userId, '!anon');
      expect(token.rawValue, restricted);
      expect(token.authType, AuthType.anonymous);
    });

    test(
      'rejects a raw value claiming a real user',
      () {
        // An anonymous token must not be able to stand in for someone else.
        expect(
          () => UserToken.anonymous(rawValue: generateTestJwt('alice')),
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
      final token = generateTestUserToken('user-1');
      final provider = TokenProvider.static(token);

      expect(await provider.loadToken('user-1'), token);
    });

    test('throws when the user ID does not match', () {
      final token = generateTestUserToken('user-1');
      final provider = TokenProvider.static(token);

      expect(() => provider.loadToken('user-2'), throwsArgumentError);
    });
  });

  group('DynamicTokenProvider', () {
    test('returns JWT tokens from the loader', () async {
      final provider = TokenProvider.dynamic(
        (userId) async => generateTestUserToken(userId),
      );

      final token = await provider.loadToken('user-1');

      expect(token.userId, 'user-1');
      expect(token.authType, AuthType.jwt);
    });

    test('throws when the loader returns a non-JWT token', () {
      final provider = TokenProvider.dynamic(
        (_) async => UserToken.anonymous(),
      );

      // The type is checked first, so this reports the wrong type rather than
      // the id an anonymous token happens to carry.
      expect(
        () => provider.loadToken('user-1'),
        throwsA(
          isA<ArgumentError>().having(
            (it) => it.message,
            'message',
            contains('Token type mismatch'),
          ),
        ),
      );
    });

    test(
      'throws when the loader returns a token for a different user',
      () {
        // Caching it would authenticate every later request as that user.
        final provider = TokenProvider.dynamic(
          (_) async => generateTestUserToken('someone-else'),
        );

        expect(() => provider.loadToken('user-1'), throwsArgumentError);
      },
    );
  });
}
