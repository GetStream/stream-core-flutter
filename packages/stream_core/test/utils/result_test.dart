import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  group('Result.getOrElse', () {
    test('returns the value when the fallback only throws', () {
      const result = Result.success(42);

      // The value used to be cast to the fallback's return type, here `Never`.
      final value = result.getOrElse((_, _) => throw StateError('unreachable'));

      expect(value, 42);
    });

    test('throws what the fallback throws, so an error can be reworded', () {
      final result = Result<int>.failure(Exception('original'));

      expect(() => result.getOrElse((error, _) => throw StateError('$error')), throwsA(isA<StateError>()));
    });

    test('returns what the fallback returns', () {
      final result = Result<int>.failure(Exception('original'));

      expect(result.getOrElse((_, _) => 0), 0);
    });

    test('hands the fallback the error and its stack trace', () {
      final stackTrace = StackTrace.current;
      final error = Exception('original');
      final result = Result<int>.failure(error, stackTrace);

      Object? seenError;
      StackTrace? seenStackTrace;
      result.getOrElse((error, stackTrace) {
        seenError = error;
        seenStackTrace = stackTrace;
        return 0;
      });

      expect(seenError, error);
      expect(seenStackTrace, stackTrace);
    });
  });

  group('Result widening', () {
    test('falls back to a supertype when the result is widened', () {
      // Naming the wider type on the result widens the fallback with it, because `Result` is
      // covariant.
      final Result<num> widened = Result<int>.failure(Exception('failed'));

      expect(widened.getOrElse((_, _) => 0.5), 0.5);
      expect(widened.getOrDefault(0.5), 0.5);
      expect(widened.recover((_, _) => 0.5).getOrNull(), 0.5);
    });
  });

  group('Result.getOrDefault', () {
    test('returns the value when there is one', () {
      const result = Result.success(42);

      expect(result.getOrDefault(0), 42);
    });

    test('returns the default when there is not', () {
      final result = Result<int>.failure(Exception('failed'));

      expect(result.getOrDefault(0), 0);
    });
  });

  group('Result.recover', () {
    test('keeps the value when the transform only throws', () {
      const result = Result.success(42);

      // Same cast as `getOrElse`.
      final recovered = result.recover((_, _) => throw StateError('unreachable'));

      expect(recovered.getOrNull(), 42);
    });

    test('turns a failure into the value the transform returns', () {
      final result = Result<int>.failure(Exception('failed'));

      expect(result.recover((_, _) => 0).getOrNull(), 0);
    });

    test('rethrows an error from the transform', () {
      final result = Result<int>.failure(Exception('failed'));

      expect(() => result.recover((_, _) => throw StateError('while recovering')), throwsA(isA<StateError>()));
    });
  });

  group('Result.recoverCatching', () {
    test('keeps the value when the transform only throws', () {
      const result = Result.success(42);

      final recovered = result.recoverCatching((_, _) => throw StateError('unreachable'));

      expect(recovered.getOrNull(), 42);
    });

    test('reports an error from the transform as a failure', () {
      final result = Result<int>.failure(Exception('failed'));

      final recovered = result.recoverCatching((_, _) => throw StateError('while recovering'));

      // Unlike `recover`, the error replaces the original rather than escaping.
      expect(recovered.exceptionOrNull(), isA<StateError>());
    });
  });

  group('runSafely', () {
    test('captures whatever was thrown untouched, Error included', () async {
      // The generic capture stores raw truth; classification belongs to the
      // boundary above it.
      final bug = StateError('a bug under the capture');
      final result = await runSafely<void>(() => throw bug);

      expect(result.exceptionOrNull(), same(bug));
    });
  });
}
