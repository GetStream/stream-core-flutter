import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  Widget wrap(Widget child) => Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );

  Widget buildShrinkWrappingList() => ListView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: const [
      SizedBox(height: 20, child: Text('item 1')),
      SizedBox(height: 20, child: Text('item 2')),
    ],
  );

  // Captures every FlutterErrorDetails reported through onError into a
  // local list and intentionally does *not* forward to the framework's
  // handler. That keeps the cascade of layout errors from being dumped to
  // the test console while still letting us inspect what fired.
  List<FlutterErrorDetails> captureErrors() {
    final caught = <FlutterErrorDetails>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = caught.add;
    addTearDown(() => FlutterError.onError = originalOnError);
    return caught;
  }

  group('StreamIntrinsicFlex bounded-cross-axis hint', () {
    testWidgets(
      'augments the layout failure with a StreamIntrinsicBoundedCrossAxis hint',
      (tester) async {
        final caught = captureErrors();

        await tester.pumpWidget(
          wrap(
            StreamIntrinsicColumn(
              children: [buildShrinkWrappingList()],
            ),
          ),
        );

        expect(caught, isNotEmpty);
        expect(caught.first.exception.toString(), contains('unbounded'));

        final info = caught.first.informationCollector?.call() ?? const [];
        final infoText = info.map((node) => node.toString()).join('\n');
        expect(infoText, contains('StreamIntrinsicBoundedCrossAxis'));
        expect(infoText, contains('flutter.dev/unbounded-constraints'));
      },
    );

    testWidgets(
      'lays out cleanly when the offending child is wrapped in '
      'StreamIntrinsicBoundedCrossAxis',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            StreamIntrinsicColumn(
              children: [
                StreamIntrinsicBoundedCrossAxis(child: buildShrinkWrappingList()),
              ],
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('item 1'), findsOneWidget);
        expect(find.text('item 2'), findsOneWidget);
      },
    );

    testWidgets(
      'hint is conditional and covers upstream culprits when the unbounded '
      'constraint originates above this widget',
      (tester) async {
        // Wrapping the column in an UnconstrainedBox makes the column
        // itself receive unbounded cross-axis constraints. The wrapper
        // can't tell whether the unbounded came from us or from above,
        // so the hint is phrased to cover both branches.
        final caught = captureErrors();

        await tester.pumpWidget(
          wrap(
            UnconstrainedBox(
              child: StreamIntrinsicColumn(
                children: [buildShrinkWrappingList()],
              ),
            ),
          ),
        );

        expect(caught, isNotEmpty);
        expect(caught.first.exception.toString(), contains('unbounded'));

        final info = caught.first.informationCollector?.call() ?? const [];
        final infoText = info.map((node) => node.toString()).join('\n');
        // Local fix and upstream possibility are both surfaced.
        expect(infoText, contains('StreamIntrinsicBoundedCrossAxis'));
        expect(infoText, contains('UnconstrainedBox'));
      },
    );
  });
}
