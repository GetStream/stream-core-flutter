import 'dart:async';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  group('InFlightCache', () {
    test('coalesces concurrent identical calls into a single invocation', () async {
      final cache = InFlightCache<String, int>();
      var invocations = 0;

      Future<int> work() async {
        invocations++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return 42;
      }

      // Fire 5 concurrent calls for the same key in the same tick.
      final results = await Future.wait(
        List.generate(5, (_) => cache.run('key', work)),
      );

      expect(invocations, 1);
      expect(results, everyElement(42));
    });

    test('different keys do not share', () async {
      final cache = InFlightCache<String, int>();
      var invocations = 0;

      Future<int> work() async {
        invocations++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return invocations;
      }

      await Future.wait([cache.run('a', work), cache.run('b', work)]);

      expect(invocations, 2);
    });

    test('frees the slot once the future settles', () async {
      final cache = InFlightCache<String, int>();
      var invocations = 0;

      Future<int> work() async => ++invocations;

      final first = await cache.run('key', work);
      final second = await cache.run('key', work);

      // Sequential calls each invoke the work — only concurrent callers share.
      expect(invocations, 2);
      expect(first, 1);
      expect(second, 2);
    });

    test('concurrent calls share the same error', () async {
      final cache = InFlightCache<String, int>();
      var invocations = 0;

      Future<int> work() async {
        invocations++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        throw StateError('boom');
      }

      final errors = await Future.wait(
        List.generate(5, (_) async {
          try {
            await cache.run('key', work);
            return null;
          } catch (e) {
            return e;
          }
        }),
      );

      expect(invocations, 1);
      expect(errors, hasLength(5));
      for (final error in errors) {
        expect(error, isA<StateError>());
      }
    });

    test('a sequential call after a failed call invokes work again', () async {
      final cache = InFlightCache<String, int>();
      var invocations = 0;

      Future<int> work() async {
        invocations++;
        if (invocations == 1) throw StateError('boom');
        return invocations;
      }

      await expectLater(cache.run('key', work), throwsStateError);
      final second = await cache.run('key', work);

      expect(invocations, 2);
      expect(second, 2);
    });

    test('inFlight returns the running future for its key only', () async {
      final cache = InFlightCache<String, int>();
      final gate = Completer<int>();

      final running = cache.run('key', () => gate.future);

      expect(cache.inFlight('key'), same(running));
      expect(cache.inFlight('other'), isNull);

      gate.complete(42);
      expect(await cache.inFlight('key'), 42);
    });

    test('inFlight is null before a call and once it settles', () async {
      final cache = InFlightCache<String, int>();
      var invocations = 0;

      expect(cache.inFlight('key'), isNull);

      await cache.run('key', () async => ++invocations);

      expect(cache.inFlight('key'), isNull);
      expect(invocations, 1);
    });

    test('inFlight is null once the call fails', () async {
      final cache = InFlightCache<String, int>();

      await expectLater(
        cache.run('key', () async => throw StateError('boom')),
        throwsStateError,
      );

      expect(cache.inFlight('key'), isNull);
    });

    test('synchronous throws inside work are wrapped as rejected futures', () async {
      final cache = InFlightCache<String, int>();

      Future<int> work() {
        throw StateError('sync throw');
      }

      await expectLater(cache.run('key', work), throwsStateError);
    });
  });
}
