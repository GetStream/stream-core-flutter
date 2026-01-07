import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  group('StateEmitter', () {
    group('state-specific functionality', () {
      test('has initial value', () {
        final emitter = MutableStateEmitter<int>(42);

        expect(emitter.value, 42);

        emitter.close();
      });

      test('emits initial value to new subscribers', () async {
        final emitter = MutableStateEmitter<int>(42);
        addTearDown(emitter.close);

        final values = <int>[];

        emitter.listen(values.add);

        await pumpEventQueue();

        expect(values, [42]);
      });

      test('updates value on emit', () async {
        final emitter = MutableStateEmitter<int>(0);
        addTearDown(emitter.close);

        emitter.emit(42);

        expect(emitter.value, 42);
      });

      test('value setter works like emit', () async {
        final emitter = MutableStateEmitter<int>(0);
        addTearDown(emitter.close);

        emitter.value = 42;

        expect(emitter.value, 42);
      });

      test('skips duplicate values (conflation)', () async {
        final emitter = MutableStateEmitter<int>(0);
        addTearDown(emitter.close);

        final values = <int>[];

        emitter.listen(values.add);

        emitter.emit(1);
        emitter.emit(1); // duplicate - should be skipped
        emitter.emit(2);
        emitter.emit(2); // duplicate - should be skipped

        await pumpEventQueue();

        expect(values, [0, 1, 2]);
      });

      test('value setter throws when called after close', () async {
        final emitter = MutableStateEmitter<int>(0);

        await emitter.close();

        expect(() => emitter.value = 1, throwsStateError);
      });

      test('tryEmit returns false after close', () async {
        final emitter = MutableStateEmitter<int>(0);

        expect(emitter.tryEmit(1), isTrue);

        await emitter.close();

        expect(emitter.tryEmit(2), isFalse);
      });

      test(
        'tryEmit catches errors and returns false instead of throwing',
        () async {
          final emitter = MutableStateEmitter<int>(0);

          await emitter.close();

          // emit would throw, but tryEmit should catch the error
          expect(() => emitter.emit(1), throwsStateError);
          expect(emitter.tryEmit(1), isFalse); // Does not throw
        },
      );
    });

    group('late subscribers', () {
      test('late subscribers receive current value', () async {
        final emitter = MutableStateEmitter<int>(0);
        addTearDown(emitter.close);

        emitter.emit(1);
        emitter.emit(2);
        emitter.emit(3);

        // Subscribe after emissions
        final values = <int>[];
        emitter.listen(values.add);

        await pumpEventQueue();

        // Should receive current value (3)
        expect(values, [3]);
        expect(emitter.value, 3);
      });
    });

    group('atomic update methods', () {
      test('update applies function to current value', () async {
        final emitter = MutableStateEmitter<int>(10);
        addTearDown(emitter.close);

        emitter.update((current) => current * 2);

        expect(emitter.value, 20);
      });

      test('getAndUpdate returns previous value and updates', () async {
        final emitter = MutableStateEmitter<int>(10);
        addTearDown(emitter.close);

        final previous = emitter.getAndUpdate((current) => current + 5);

        expect(previous, 10);
        expect(emitter.value, 15);
      });

      test('updateAndGet returns new value after update', () async {
        final emitter = MutableStateEmitter<int>(10);
        addTearDown(emitter.close);

        final newValue = emitter.updateAndGet((current) => current + 5);

        expect(newValue, 15);
        expect(emitter.value, 15);
      });
    });

    group('sync mode', () {
      test('sync mode emits new values synchronously', () async {
        final emitter = MutableStateEmitter<int>(0, sync: true);
        addTearDown(emitter.close);

        final values = <int>[];

        emitter.listen(values.add);

        // Wait for initial value to be emitted
        await pumpEventQueue();
        expect(values, [0]);

        // New emissions are synchronous
        emitter.emit(1);
        expect(values, [0, 1]); // Synchronous - value immediately available

        emitter.emit(2);
        expect(values, [0, 1, 2]);
      });
    });

    group('properties', () {
      test('hasListener returns true when listeners exist', () async {
        final emitter = MutableStateEmitter<int>(0);
        addTearDown(emitter.close);

        expect(emitter.hasListener, isFalse);

        final subscription = emitter.listen((_) {});

        expect(emitter.hasListener, isTrue);

        await subscription.cancel();
        expect(emitter.hasListener, isFalse);
      });

      test('isClosed returns true after close', () async {
        final emitter = MutableStateEmitter<int>(0);

        expect(emitter.isClosed, isFalse);

        await emitter.close();

        expect(emitter.isClosed, isTrue);
      });
    });

    group('extensions', () {
      test('asStateEmitter returns StateEmitter type', () {
        final mutableEmitter = MutableStateEmitter<int>(0);
        addTearDown(mutableEmitter.close);

        final readOnlyEmitter = mutableEmitter.asStateEmitter();

        // Should be able to use as StateEmitter
        expect(readOnlyEmitter, isA<StateEmitter<int>>());

        // Should be able to read the latest value
        expect(readOnlyEmitter.value, 0);

        // Updates through mutableEmitter are reflected in read-only view
        mutableEmitter.value = 42;
        expect(readOnlyEmitter.value, 42);

        mutableEmitter.value = 100;
        expect(readOnlyEmitter.value, 100);
      });
    });
  });
}
