import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/user_token.dart';

void main() {
  group('UserToken.expiresAt', () {
    test('is read from the exp claim', () {
      // 'exp' has no room for milliseconds, so a finer-grained moment comes back truncated.
      final expiry = DateTime.utc(2030, 1, 1, 12);

      final token = generateTestUserToken('user-id', expiresAt: expiry);

      expect(token.expiresAt, expiry);
    });

    test('is null for a token that names no expiry', () {
      final token = generateTestUserToken('user-id');

      // With no expiry there is nothing to compare against, so the token never expires.
      expect(token.expiresAt, isNull);
      expect(token.isExpired(), isFalse);
    });

    test('is null for an anonymous token carrying no raw value', () {
      final token = UserToken.anonymous();

      expect(token.expiresAt, isNull);
      expect(token.isExpired(), isFalse);
    });

    test('is read from an anonymous token that carries one', () {
      final expiry = DateTime.utc(2030, 1, 1, 12);
      final rawValue = generateTestJwt(User.anonymousUserId, expiresAt: expiry);

      final token = UserToken.anonymous(rawValue: rawValue);

      expect(token.expiresAt, expiry);
    });
  });

  group('UserToken.isExpired', () {
    test('is false while the token still has life left', () {
      final token = generateTestUserToken('user-id', expiresAt: DateTime.timestamp().add(const Duration(hours: 1)));

      expect(token.isExpired(), isFalse);
    });

    test('is true once the expiry has passed', () {
      final token = generateTestUserToken(
        'user-id',
        expiresAt: DateTime.timestamp().subtract(const Duration(seconds: 1)),
      );

      expect(token.isExpired(), isTrue);
    });

    test('is true for a token expiring within the leeway', () {
      final token = generateTestUserToken('user-id', expiresAt: DateTime.timestamp().add(const Duration(seconds: 10)));

      // Still valid, but not for longer than the leeway.
      expect(token.isExpired(), isFalse);
      expect(token.isExpired(leeway: const Duration(seconds: 30)), isTrue);
    });

    test('is false for a token outliving the leeway', () {
      final token = generateTestUserToken('user-id', expiresAt: DateTime.timestamp().add(const Duration(minutes: 5)));

      expect(token.isExpired(leeway: const Duration(seconds: 30)), isFalse);
    });

    test('is true for a token expiring at exactly this moment', () {
      final expiry = DateTime.utc(2030, 1, 1, 12);
      final token = generateTestUserToken('user-id', expiresAt: expiry);

      // A token stops being valid at its expiry, not after it.
      withClock(Clock.fixed(expiry), () {
        expect(token.isExpired(), isTrue);
      });
    });

    test('is answered against the ambient clock, not the wall clock', () {
      final token = generateTestUserToken('user-id', expiresAt: DateTime.utc(2030, 1, 1, 12));

      withClock(Clock.fixed(DateTime.utc(2030, 1, 1, 11, 59)), () {
        expect(token.isExpired(), isFalse);
      });

      withClock(Clock.fixed(DateTime.utc(2030, 1, 1, 12, 1)), () {
        expect(token.isExpired(), isTrue);
      });
    });

    test('expires as time passes under fakeAsync', () {
      fakeAsync((async) {
        final token = generateTestUserToken('user-id', expiresAt: clock.now().add(const Duration(hours: 1)));
        expect(token.isExpired(), isFalse);

        // The same elapse that drives backoff and health checks moves token expiry too.
        async.elapse(const Duration(hours: 2));

        expect(token.isExpired(), isTrue);
      });
    });

    test('leaves a token with no expiry alone whatever the leeway', () {
      final token = generateTestUserToken('user-id');

      expect(token.isExpired(leeway: const Duration(days: 365)), isFalse);
    });
  });
}
