import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

Widget _withStreamTheme(Widget child, {StreamTheme? streamTheme}) {
  return MaterialApp(
    theme: ThemeData(extensions: [streamTheme ?? StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

Finder _decorations() {
  return find.descendant(of: find.byType(DefaultStreamRadioIndicator), matching: find.byType(DecoratedBox));
}

/// The decoration of the outer circle.
BoxDecoration _ringOf(WidgetTester tester) {
  return tester.widget<DecoratedBox>(_decorations().at(0)).decoration as BoxDecoration;
}

/// The decoration of the dot inside the circle.
BoxDecoration _dotOf(WidgetTester tester) {
  return tester.widget<DecoratedBox>(_decorations().at(1)).decoration as BoxDecoration;
}

Size _dotSizeOf(WidgetTester tester) => tester.getSize(_decorations().at(1));

void main() {
  final colorScheme = StreamColorScheme.light();

  group('StreamRadioIndicator defaults', () {
    testWidgets('is a 16px circle with an 8px dot', (tester) async {
      await tester.pumpWidget(_withStreamTheme(StreamRadioIndicator(selected: true)));

      expect(tester.getSize(find.byType(StreamRadioIndicator)), const Size.square(16));
      expect(_dotSizeOf(tester), const Size.square(8));
      expect(_ringOf(tester).shape, BoxShape.circle);
      expect(_dotOf(tester).shape, BoxShape.circle);
    });

    testWidgets('fills with the accent color and a contrasting dot when selected', (tester) async {
      await tester.pumpWidget(_withStreamTheme(StreamRadioIndicator(selected: true)));

      expect(_ringOf(tester).color, colorScheme.accentPrimary);
      expect(_ringOf(tester).border, const Border.fromBorderSide(BorderSide.none));
      expect(_dotOf(tester).color, colorScheme.textOnAccent);
    });

    testWidgets('is outlined with no visible dot when unselected', (tester) async {
      await tester.pumpWidget(_withStreamTheme(StreamRadioIndicator(selected: false)));

      expect(_ringOf(tester).color, StreamColors.transparent);
      expect(_ringOf(tester).border, Border.fromBorderSide(BorderSide(color: colorScheme.borderDefault)));
      expect(_dotOf(tester).color, StreamColors.transparent);
    });

    testWidgets('adds no semantics of its own', (tester) async {
      // The row the indicator sits in owns the semantics of the entry, so the
      // indicator must not add a node that screen readers would focus on.
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_withStreamTheme(StreamRadioIndicator(selected: true)));

      expect(
        find.descendant(of: find.byType(StreamRadioIndicator), matching: find.byType(Semantics)),
        findsNothing,
      );
      expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
      handle.dispose();
    });
  });

  group('StreamRadioIndicator theming', () {
    testWidgets('applies the global theme from StreamTheme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioIndicator(selected: true),
          streamTheme: StreamTheme(
            radioIndicatorTheme: StreamRadioIndicatorThemeData(
              style: StreamRadioIndicatorStyle.from(
                size: 24,
                dotSize: 10,
                selectedFillColor: Colors.green,
                selectedDotColor: Colors.black,
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(StreamRadioIndicator)), const Size.square(24));
      expect(_dotSizeOf(tester), const Size.square(10));
      expect(_ringOf(tester).color, Colors.green);
      expect(_dotOf(tester).color, Colors.black);
    });

    testWidgets('applies the unselected values of a theme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioIndicatorTheme(
            data: StreamRadioIndicatorThemeData(
              style: StreamRadioIndicatorStyle.from(
                fillColor: Colors.yellow,
                side: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            child: StreamRadioIndicator(selected: false),
          ),
        ),
      );

      expect(_ringOf(tester).color, Colors.yellow);
      expect(_ringOf(tester).border, const Border.fromBorderSide(BorderSide(color: Colors.red, width: 2)));
    });

    testWidgets('a local theme beats the global theme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioIndicatorTheme(
            data: StreamRadioIndicatorThemeData(
              style: StreamRadioIndicatorStyle.from(selectedFillColor: Colors.blue),
            ),
            child: StreamRadioIndicator(selected: true),
          ),
          streamTheme: StreamTheme(
            radioIndicatorTheme: StreamRadioIndicatorThemeData(
              style: StreamRadioIndicatorStyle.from(selectedFillColor: Colors.green, size: 20),
            ),
          ),
        ),
      );

      expect(_ringOf(tester).color, Colors.blue);
      // Fields the local theme leaves unset still come from the global one.
      expect(tester.getSize(find.byType(StreamRadioIndicator)), const Size.square(20));
    });

    testWidgets('falls back to the defaults for fields the theme leaves unset', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioIndicatorTheme(
            data: const StreamRadioIndicatorThemeData(style: StreamRadioIndicatorStyle(size: 20)),
            child: StreamRadioIndicator(selected: true),
          ),
        ),
      );

      expect(tester.getSize(find.byType(StreamRadioIndicator)), const Size.square(20));
      expect(_dotSizeOf(tester), const Size.square(8));
      expect(_ringOf(tester).color, colorScheme.accentPrimary);
    });
  });

  group('StreamRadioIndicator factory', () {
    testWidgets('uses the radioIndicator builder from StreamComponentFactory', (tester) async {
      StreamRadioIndicatorProps? receivedProps;

      await tester.pumpWidget(
        _withStreamTheme(
          StreamComponentFactory(
            builders: StreamComponentBuilders(
              radioIndicator: (context, props) {
                receivedProps = props;
                return const Text('custom');
              },
            ),
            child: StreamRadioIndicator(selected: true),
          ),
        ),
      );

      expect(find.text('custom'), findsOneWidget);
      expect(find.byType(DefaultStreamRadioIndicator), findsNothing);
      expect(receivedProps?.selected, isTrue);
    });
  });
}
