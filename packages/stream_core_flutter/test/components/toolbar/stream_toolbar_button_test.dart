import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child, {StreamAppStyle appStyle = StreamAppStyle.regular}) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme(appStyle: appStyle)]),
    home: Scaffold(body: child),
  );
}

Widget _scoped(StreamToolbarBehavior behavior, Widget child) {
  return StreamToolbarScope(behavior: behavior, child: child);
}

void main() {
  group('StreamToolbarScope', () {
    testWidgets('maybeOf returns null with no scope in the tree', (tester) async {
      StreamToolbarBehavior? captured = StreamToolbarBehavior.floating;
      await tester.pumpWidget(
        _withStreamTheme(
          Builder(
            builder: (context) {
              captured = StreamToolbarScope.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, isNull);
    });

    testWidgets('of throws a FlutterError with no scope in the tree', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Builder(
            builder: (context) {
              StreamToolbarScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('of and maybeOf return the published behavior inside a scope', (tester) async {
      late StreamToolbarBehavior fromOf;
      StreamToolbarBehavior? fromMaybeOf;
      await tester.pumpWidget(
        _withStreamTheme(
          _scoped(
            StreamToolbarBehavior.floating,
            Builder(
              builder: (context) {
                fromOf = StreamToolbarScope.of(context);
                fromMaybeOf = StreamToolbarScope.maybeOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(fromOf, StreamToolbarBehavior.floating);
      expect(fromMaybeOf, StreamToolbarBehavior.floating);
    });
  });

  group('StreamToolbarButton', () {
    testWidgets('renders an outlined, floating button inside a floating toolbar', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          _scoped(
            StreamToolbarBehavior.floating,
            StreamToolbarButton(onPressed: () {}, child: const Text('Edit')),
          ),
        ),
      );

      final button = tester.widget<StreamButton>(find.byType(StreamButton));
      expect(button.props.type, StreamButtonType.outline);
      expect(button.props.isFloating, isTrue);
    });

    testWidgets('renders a ghost, docked button inside a regular toolbar', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          _scoped(
            StreamToolbarBehavior.regular,
            StreamToolbarButton(onPressed: () {}, child: const Text('Edit')),
          ),
        ),
      );

      final button = tester.widget<StreamButton>(find.byType(StreamButton));
      expect(button.props.type, StreamButtonType.ghost);
      expect(button.props.isFloating, isFalse);
    });
  });
}
