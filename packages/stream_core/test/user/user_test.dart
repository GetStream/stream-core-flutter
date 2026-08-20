import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  group('User.anonymous', () {
    test('carries the id every anonymous user has', () {
      const user = User.anonymous();

      expect(user.id, User.anonymousUserId);
      expect(user.type, UserType.anonymous);
    });
  });

  group('User', () {
    test('rejects an anonymous user built with any other id', () {
      // Not `const`: a const context evaluates the assert at compile time.
      expect(
        () => User(id: 'someone-else', type: UserType.anonymous),
        throwsA(isA<AssertionError>()),
      );
    });

    test('allows the anonymous id for a user of another type', () {
      // The invariant runs one way: anonymous implies the id, not the reverse.
      const user = User(id: User.anonymousUserId);

      expect(user.type, UserType.regular);
    });

    test('reports the id as the name when none was given', () {
      const user = User.guest('bob');

      expect(user.originalName, isNull);
      expect(user.name, 'bob');
    });

    test('keeps the name it was given', () {
      const user = User.guest('bob', name: 'Bob');

      expect(user.originalName, 'Bob');
      expect(user.name, 'Bob');
    });
  });
}
