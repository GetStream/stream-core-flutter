import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child, {StreamSurfaceStyle appStyle = StreamSurfaceStyle.regular}) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme(appStyle: appStyle)]),
    home: Scaffold(body: child),
  );
}

Widget _scoped(StreamSurfaceStyle behavior, Widget child) {
  return StreamToolbarScope(behavior: behavior, child: child);
}

void main() {
  group('StreamToolbarScope', () {
    testWidgets('maybeOf returns null with no scope in the tree', (tester) async {
      StreamSurfaceStyle? captured = StreamSurfaceStyle.floating;
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
      late StreamSurfaceStyle fromOf;
      StreamSurfaceStyle? fromMaybeOf;
      await tester.pumpWidget(
        _withStreamTheme(
          _scoped(
            StreamSurfaceStyle.floating,
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

      expect(fromOf, StreamSurfaceStyle.floating);
      expect(fromMaybeOf, StreamSurfaceStyle.floating);
    });
  });

  group('StreamToolbarButton', () {
    testWidgets('renders an outlined, floating button inside a floating toolbar', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          _scoped(
            StreamSurfaceStyle.floating,
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
            StreamSurfaceStyle.regular,
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
