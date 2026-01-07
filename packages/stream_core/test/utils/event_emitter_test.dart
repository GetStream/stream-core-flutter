import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

// Test event classes
class BaseEvent implements StreamEvent {
  const BaseEvent(this.data);

  final String data;
}

class SpecificEvent extends BaseEvent {
  const SpecificEvent(super.data);
}

class TransformedEvent extends BaseEvent {
  const TransformedEvent(super.data);
}

class AnotherEvent extends BaseEvent {
  const AnotherEvent(super.data, this.value);

  final int value;
}

void main() {
  group('MutableEventEmitter', () {
    group('resolver functionality', () {
      test('transforms event when resolver returns non-null', () async {
        final emitter = MutableEventEmitter<BaseEvent>(
          resolvers: [
            (event) => TransformedEvent('transformed: ${event.data}'),
          ],
        );
        addTearDown(emitter.close);

        final values = <BaseEvent>[];
        emitter.listen(values.add);

        emitter.emit(const BaseEvent('test'));

        await pumpEventQueue();

        expect(values.length, 1);
        expect(values.first, isA<TransformedEvent>());
        expect(values.first.data, 'transformed: test');
      });

      test('emits event as-is when no resolver matches', () async {
        final emitter = MutableEventEmitter<BaseEvent>(
          resolvers: [
            (event) => null, // No resolver matches
          ],
        );
        addTearDown(emitter.close);

        final values = <BaseEvent>[];
        emitter.listen(values.add);

        const originalEvent = BaseEvent('test');
        emitter.emit(originalEvent);

        await pumpEventQueue();

        expect(values.length, 1);
        expect(values.first, originalEvent);
        expect(values.first.data, 'test');
      });

      test('emits event as-is when no resolvers provided', () async {
        final emitter = MutableEventEmitter<BaseEvent>();
        addTearDown(emitter.close);

        final values = <BaseEvent>[];
        emitter.listen(values.add);

        const originalEvent = BaseEvent('test');
        emitter.emit(originalEvent);

        await pumpEventQueue();

        expect(values.length, 1);
        expect(values.first, originalEvent);
      });

      test('first resolver that returns non-null wins', () async {
        final emitter = MutableEventEmitter<BaseEvent>(
          resolvers: [
            (event) => null, // First resolver doesn't match
            // Second resolver matches
            (event) => TransformedEvent('first-match: ${event.data}'),
            // Should not be called
            (event) => TransformedEvent('should-not-reach: ${event.data}'),
          ],
        );
        addTearDown(emitter.close);

        final values = <BaseEvent>[];
        emitter.listen(values.add);

        emitter.emit(const BaseEvent('test'));

        await pumpEventQueue();

        expect(values.length, 1);
        expect(values.first, isA<TransformedEvent>());
        expect(values.first.data, 'first-match: test');
      });

      test('resolver can transform to different event type', () async {
        final emitter = MutableEventEmitter<BaseEvent>(
          resolvers: [
            (event) => AnotherEvent(event.data, event.data.length),
          ],
        );
        addTearDown(emitter.close);

        final values = <BaseEvent>[];
        emitter.listen(values.add);

        emitter.emit(const BaseEvent('hello'));

        await pumpEventQueue();

        expect(values.length, 1);
        expect(values.first, isA<AnotherEvent>());
        expect((values.first as AnotherEvent).value, 5);
      });

      test('resolver can conditionally transform based on event properties',
          () async {
        final emitter = MutableEventEmitter<BaseEvent>(
          resolvers: [
            (event) => event.data.startsWith('transform:')
                ? TransformedEvent(event.data.replaceFirst('transform:', ''))
                : null,
          ],
        );
        addTearDown(emitter.close);

        final transformedValues = <TransformedEvent>[];
        final baseValues = <BaseEvent>[];

        emitter.on<TransformedEvent>(transformedValues.add);
        emitter.on<BaseEvent>(baseValues.add);

        emitter.emit(const BaseEvent('transform:hello'));
        emitter.emit(const BaseEvent('keep-as-is'));

        await pumpEventQueue();

        expect(transformedValues.length, 1);
        expect(transformedValues.first.data, 'hello');
        // BaseEvent listeners will also receive TransformedEvent since it extends BaseEvent
        expect(baseValues.length, 2);
      });
    });

    group('inherited SharedEmitter functionality', () {
      test('supports multiple listeners', () async {
        final emitter = MutableEventEmitter<BaseEvent>();
        addTearDown(emitter.close);

        final values1 = <BaseEvent>[];
        final values2 = <BaseEvent>[];

        emitter.listen(values1.add);
        emitter.listen(values2.add);

        emitter.emit(const BaseEvent('test'));

        await pumpEventQueue();

        expect(values1.length, 1);
        expect(values2.length, 1);
      });

      test('supports type filtering with on<E>()', () async {
        final emitter = MutableEventEmitter<StreamEvent>(
          resolvers: [
            (event) => event is BaseEvent ? SpecificEvent(event.data) : null,
          ],
        );
        addTearDown(emitter.close);

        final specificEvents = <SpecificEvent>[];
        emitter.on<SpecificEvent>(specificEvents.add);

        emitter.emit(const BaseEvent('test'));

        await pumpEventQueue();

        expect(specificEvents.length, 1);
        expect(specificEvents.first.data, 'test');
      });

      test('supports waitFor<E>()', () async {
        final emitter = MutableEventEmitter<StreamEvent>(
          resolvers: [
            (event) => event is BaseEvent ? SpecificEvent(event.data) : null,
          ],
        );
        addTearDown(emitter.close);

        final future = emitter.waitFor<SpecificEvent>();

        emitter.emit(const BaseEvent('test'));

        final result = await future;

        expect(result, isA<SpecificEvent>());
        expect(result.data, 'test');
      });

      test('supports replay functionality', () async {
        final emitter = MutableEventEmitter<BaseEvent>(replay: 2);
        addTearDown(emitter.close);

        emitter.emit(const BaseEvent('first'));
        emitter.emit(const BaseEvent('second'));
        emitter.emit(const BaseEvent('third'));

        final values = <BaseEvent>[];
        emitter.listen(values.add);

        await pumpEventQueue();

        expect(values.length, 2);
        expect(values[0].data, 'second');
        expect(values[1].data, 'third');
      });

      test('supports sync mode', () {
        final emitter = MutableEventEmitter<BaseEvent>(sync: true);
        addTearDown(emitter.close);

        final values = <BaseEvent>[];

        emitter.listen(values.add);

        emitter.emit(const BaseEvent('test'));

        expect(values.length, 1); // Synchronous - value immediately available

        emitter.close();
      });

      test(
        'tryEmit catches errors and returns false instead of throwing',
        () async {
          final emitter = MutableEventEmitter<BaseEvent>();
          addTearDown(emitter.close);

          await emitter.close();

          expect(emitter.tryEmit(const BaseEvent('test')), isFalse);
        },
      );
    });
  });
}
