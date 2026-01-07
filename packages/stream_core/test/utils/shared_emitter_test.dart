import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  group('SharedEmitter', () {
    group('basic functionality', () {
      test('emits values to listeners', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        final values = <int>[];

        emitter.listen(values.add);

        emitter.emit(1);
        emitter.emit(2);
        emitter.emit(3);

        await pumpEventQueue();

        expect(values, [1, 2, 3]);
      });

      test('supports multiple listeners', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        final values1 = <int>[];
        final values2 = <int>[];

        emitter.listen(values1.add);
        emitter.listen(values2.add);

        emitter.emit(1);
        emitter.emit(2);

        await pumpEventQueue();

        expect(values1, [1, 2]);
        expect(values2, [1, 2]);
      });

      test('close stops emissions', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        final values = <int>[];
        var isDone = false;

        emitter.listen(
          values.add,
          onDone: () => isDone = true,
        );

        emitter.emit(1);
        await emitter.close();

        await pumpEventQueue();

        expect(values, [1]);
        expect(isDone, isTrue);
      });

      test('tryEmit returns false after close', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        expect(emitter.tryEmit(1), isTrue);

        await emitter.close();

        expect(emitter.tryEmit(2), isFalse);
      });

      test('emit throws when called after close', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        await emitter.close();

        expect(() => emitter.emit(1), throwsStateError);
      });

      test('tryEmit catches errors and returns false instead of throwing',
          () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        await emitter.close();

        // emit would throw, but tryEmit should catch the error
        expect(() => emitter.emit(1), throwsStateError);
        expect(emitter.tryEmit(1), isFalse); // Does not throw
      });
    });

    group('type filtering', () {
      test('on<E>() filters by type', () async {
        final emitter = MutableSharedEmitter<Object>();
        addTearDown(emitter.close);

        final strings = <String>[];
        final ints = <int>[];

        emitter.on<String>(strings.add);
        emitter.on<int>(ints.add);

        emitter.emit('hello');
        emitter.emit(42);
        emitter.emit('world');
        emitter.emit(100);

        await pumpEventQueue();

        expect(strings, ['hello', 'world']);
        expect(ints, [42, 100]);
      });

      test('waitFor<E>() waits for specific type', () async {
        final emitter = MutableSharedEmitter<Object>();
        addTearDown(emitter.close);

        final futureString = emitter.waitFor<String>();

        emitter.emit(1);
        emitter.emit(2);
        emitter.emit('found');

        final result = await futureString;

        expect(result, 'found');
      });

      test('waitFor<E>() times out when event not received', () async {
        final emitter = MutableSharedEmitter<Object>();
        addTearDown(emitter.close);

        // Start waiting for a String that will never come
        final future = emitter.waitFor<String>(
          timeLimit: const Duration(milliseconds: 50),
        );

        // Emit non-matching types
        emitter.emit(1);
        emitter.emit(2);

        // Should timeout since no String was emitted
        await expectLater(future, throwsA(isA<TimeoutException>()));
      });
    });

    group('stream interface', () {
      test('can be used with where()', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        final evenValues = <int>[];

        emitter.where((v) => v.isEven).listen(evenValues.add);

        emitter.emit(1);
        emitter.emit(2);
        emitter.emit(3);
        emitter.emit(4);

        await pumpEventQueue();

        expect(evenValues, [2, 4]);
      });

      test('can be used with map()', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        final doubled = <int>[];

        emitter.map((v) => v * 2).listen(doubled.add);

        emitter.emit(1);
        emitter.emit(2);
        emitter.emit(3);

        await pumpEventQueue();

        expect(doubled, [2, 4, 6]);
      });

      test('can be used with take()', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        final values = <int>[];

        emitter.take(2).listen(values.add);

        emitter.emit(1);
        emitter.emit(2);
        emitter.emit(3);

        await pumpEventQueue();

        expect(values, [1, 2]);
      });

      test('can be used with skip()', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        final values = <int>[];

        emitter.skip(2).listen(values.add);

        emitter.emit(1);
        emitter.emit(2);
        emitter.emit(3);
        emitter.emit(4);

        await pumpEventQueue();

        expect(values, [3, 4]);
      });

      test('can be used with distinct()', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        final values = <int>[];

        emitter.distinct().listen(values.add);

        emitter.emit(1);
        emitter.emit(1);
        emitter.emit(2);
        emitter.emit(2);
        emitter.emit(1);

        await pumpEventQueue();

        expect(values, [1, 2, 1]);
      });

      test('can be used with first', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        final futureFirst = emitter.first;

        emitter.emit(42);
        emitter.emit(100);

        final result = await futureFirst;

        expect(result, 42);
      });

      test('can be used with firstWhere()', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        final futureFirst = emitter.firstWhere((v) => v > 10);

        emitter.emit(1);
        emitter.emit(5);
        emitter.emit(15);
        emitter.emit(20);

        final result = await futureFirst;

        expect(result, 15);
      });

      test('isBroadcast returns true', () {
        final emitter = MutableSharedEmitter<int>();

        expect(emitter.isBroadcast, isTrue);

        emitter.close();
      });

      test('emitter can be used directly as a stream', () async {
        final emitter = MutableSharedEmitter<int>();
        addTearDown(emitter.close);

        final values = <int>[];

        // Emitter implements Stream, so it can be used directly
        emitter.listen(values.add);

        emitter.emit(1);
        emitter.emit(2);

        await pumpEventQueue();

        expect(values, [1, 2]);
      });
    });

    group('replay functionality', () {
      test('replay emitter replays last N values to new subscribers', () async {
        final emitter = MutableSharedEmitter<int>(replay: 2);
        addTearDown(emitter.close);

        emitter.emit(1);
        emitter.emit(2);
        emitter.emit(3);

        final values = <int>[];
        emitter.listen(values.add);

        await pumpEventQueue();

        // Should receive last 2 values (2, 3)
        expect(values, [2, 3]);
      });

      test('replay 0 does not replay values', () async {
        final emitter = MutableSharedEmitter<int>(replay: 0);
        addTearDown(emitter.close);

        emitter.emit(1);
        emitter.emit(2);

        final values = <int>[];
        emitter.listen(values.add);

        emitter.emit(3);

        await pumpEventQueue();

        // Should only receive value emitted after subscribing
        expect(values, [3]);
      });

      test('negative replay throws ArgumentError', () {
        expect(
          () => MutableSharedEmitter<int>(replay: -1),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('sync mode', () {
      test('sync mode emits values synchronously', () {
        final emitter = MutableSharedEmitter<int>(sync: true);
        addTearDown(emitter.close);

        final values = <int>[];

        emitter.listen(values.add);

        emitter.emit(1);
        expect(values, [1]); // Synchronous - value immediately available

        emitter.emit(2);
        expect(values, [1, 2]);

        emitter.close();
      });
    });

    group('properties', () {
      test('hasListener returns true when listeners exist', () async {
        final emitter = MutableSharedEmitter<int>();

        expect(emitter.hasListener, isFalse);

        final subscription = emitter.listen((_) {});

        expect(emitter.hasListener, isTrue);

        await subscription.cancel();
        expect(emitter.hasListener, isFalse);
      });

      test('isClosed returns true after close', () async {
        final emitter = MutableSharedEmitter<int>();

        expect(emitter.isClosed, isFalse);

        await emitter.close();

        expect(emitter.isClosed, isTrue);
      });
    });

    group('extensions', () {
      test('asSharedEmitter returns SharedEmitter type', () async {
        final mutableEmitter = MutableSharedEmitter<int>();
        addTearDown(mutableEmitter.close);

        final readOnlyEmitter = mutableEmitter.asSharedEmitter();

        // Should be able to use as SharedEmitter
        expect(readOnlyEmitter, isA<SharedEmitter<int>>());

        // Should be able to listen
        final values = <int>[];
        readOnlyEmitter.listen(values.add);

        // Can still emit through mutableEmitter
        mutableEmitter.emit(42);
        await pumpEventQueue();
        expect(values, [42]);
      });
    });
  });

  group('SharedEmitter vs StateEmitter behavior', () {
    test('SharedEmitter does not emit to late subscribers by default',
        () async {
      final emitter = MutableSharedEmitter<int>();
      addTearDown(emitter.close);

      emitter.emit(1);
      emitter.emit(2);

      final values = <int>[];
      emitter.listen(values.add);

      emitter.emit(3);

      await pumpEventQueue();

      // Only receives value emitted after subscribing
      expect(values, [3]);
    });

    test('StateEmitter always emits current value to new subscribers',
        () async {
      final emitter = MutableStateEmitter<int>(0);
      addTearDown(emitter.close);

      emitter.emit(1);
      emitter.emit(2);

      final values = <int>[];
      emitter.listen(values.add);

      emitter.emit(3);

      await pumpEventQueue();

      // Receives current value (2) + new value (3)
      expect(values, [2, 3]);
    });
  });

  group('Emitter stream operations', () {
    test('can merge two SharedEmitters', () async {
      final emitter1 = MutableSharedEmitter<int>();
      final emitter2 = MutableSharedEmitter<int>();

      final values = <int>[];
      final merged = Rx.merge([emitter1, emitter2]);
      merged.listen(values.add);

      emitter1.emit(1);
      emitter2.emit(2);
      emitter1.emit(3);
      emitter2.emit(4);

      await pumpEventQueue();

      expect(values, [1, 2, 3, 4]);

      await emitter1.close();
      await emitter2.close();
    });

    test('can merge two StateEmitters', () async {
      final emitter1 = MutableStateEmitter<int>(0);
      final emitter2 = MutableStateEmitter<int>(100);

      final values = <int>[];
      final merged = Rx.merge([emitter1, emitter2]);
      merged.listen(values.add);

      await pumpEventQueue();

      // Both initial values are emitted
      expect(values, contains(0));
      expect(values, contains(100));

      values.clear();

      emitter1.value = 1;
      emitter2.value = 101;

      await pumpEventQueue();

      expect(values, [1, 101]);

      await emitter1.close();
      await emitter2.close();
    });

    test('can merge SharedEmitter and StateEmitter', () async {
      final sharedEmitter = MutableSharedEmitter<String>();
      final stateEmitter = MutableStateEmitter<String>('initial');

      final values = <String>[];
      final merged = Rx.merge([sharedEmitter, stateEmitter]);
      merged.listen(values.add);

      await pumpEventQueue();

      // StateEmitter emits initial value immediately
      expect(values, ['initial']);

      values.clear();

      sharedEmitter.emit('from shared');
      stateEmitter.value = 'from state';

      await pumpEventQueue();

      expect(values, ['from shared', 'from state']);

      await sharedEmitter.close();
      await stateEmitter.close();
    });
  });
}
