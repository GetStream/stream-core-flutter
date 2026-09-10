import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('StreamErrorBadge draws a border by default', (tester) async {
    await tester.pumpWidget(_wrap(StreamErrorBadge()));

    final border = _borderOf(tester)!;
    expect(border.top.color, _colorSchemeOf(tester).borderOnInverse);
    expect(border.top.width, 2);
    expect(border.top.strokeAlign, BorderSide.strokeAlignOutside);
  });

  testWidgets('StreamErrorBadge draws no border when showBorder is false', (tester) async {
    await tester.pumpWidget(_wrap(StreamErrorBadge(showBorder: false)));

    expect(_borderOf(tester), isNull);
  });

  testWidgets('StreamErrorBadge keeps its layout size when the border is dropped', (tester) async {
    const size = StreamErrorBadgeSize.sm;

    await tester.pumpWidget(_wrap(StreamErrorBadge(size: size)));
    final withBorder = tester.getSize(find.byType(StreamErrorBadge));

    await tester.pumpWidget(_wrap(StreamErrorBadge(size: size, showBorder: false)));
    final withoutBorder = tester.getSize(find.byType(StreamErrorBadge));

    expect(withBorder, Size.square(size.value));
    expect(withoutBorder, withBorder);
  });

  testWidgets('StreamErrorBadge uses the error colors by default', (tester) async {
    await tester.pumpWidget(_wrap(StreamErrorBadge()));

    final colorScheme = _colorSchemeOf(tester);
    expect(_backgroundColorOf(tester), colorScheme.accentError);
    expect(_iconColorOf(tester), colorScheme.textOnAccent);
  });

  testWidgets('StreamErrorBadge uses the warning colors for the warning style', (tester) async {
    await tester.pumpWidget(_wrap(StreamErrorBadge(style: StreamErrorBadgeStyle.warning)));

    expect(_backgroundColorOf(tester), _colorSchemeOf(tester).accentWarning);
    expect(_iconColorOf(tester), StreamColors.black);
  });

  testWidgets('StreamErrorBadgeTheme overrides the resolved style colors', (tester) async {
    const themeData = StreamErrorBadgeThemeData(
      errorBackgroundColor: Color(0xFF111111),
      errorForegroundColor: Color(0xFF222222),
      warningBackgroundColor: Color(0xFF333333),
      warningForegroundColor: Color(0xFF444444),
    );

    await tester.pumpWidget(
      _wrap(
        StreamErrorBadgeTheme(data: themeData, child: StreamErrorBadge()),
      ),
    );

    expect(_backgroundColorOf(tester), themeData.errorBackgroundColor);
    expect(_iconColorOf(tester), themeData.errorForegroundColor);

    await tester.pumpWidget(
      _wrap(
        StreamErrorBadgeTheme(
          data: themeData,
          child: StreamErrorBadge(style: StreamErrorBadgeStyle.warning),
        ),
      ),
    );

    expect(_backgroundColorOf(tester), themeData.warningBackgroundColor);
    expect(_iconColorOf(tester), themeData.warningForegroundColor);
  });

  testWidgets('StreamErrorBadgeTheme leaves the other style untouched', (tester) async {
    const themeData = StreamErrorBadgeThemeData(warningBackgroundColor: Color(0xFF333333));

    await tester.pumpWidget(
      _wrap(
        StreamErrorBadgeTheme(data: themeData, child: StreamErrorBadge()),
      ),
    );

    final colorScheme = _colorSchemeOf(tester);
    expect(_backgroundColorOf(tester), colorScheme.accentError);
    expect(_iconColorOf(tester), colorScheme.textOnAccent);
  });

  testWidgets('StreamErrorBadgeTheme falls back per property', (tester) async {
    // Only the background is overridden — the icon color must still resolve.
    const themeData = StreamErrorBadgeThemeData(warningBackgroundColor: Color(0xFF333333));

    await tester.pumpWidget(
      _wrap(
        StreamErrorBadgeTheme(
          data: themeData,
          child: StreamErrorBadge(style: StreamErrorBadgeStyle.warning),
        ),
      ),
    );

    expect(_backgroundColorOf(tester), const Color(0xFF333333));
    expect(_iconColorOf(tester), StreamColors.black);
  });

  testWidgets('StreamErrorBadgeTheme overrides the border and default size', (tester) async {
    final themeData = StreamErrorBadgeThemeData(
      size: StreamErrorBadgeSize.md,
      border: Border.all(width: 4, color: const Color(0xFF555555)),
    );

    await tester.pumpWidget(
      _wrap(
        StreamErrorBadgeTheme(data: themeData, child: StreamErrorBadge()),
      ),
    );

    expect(tester.getSize(find.byType(StreamErrorBadge)), Size.square(StreamErrorBadgeSize.md.value));
    expect(_borderOf(tester)!.top.width, 4);
    expect(_borderOf(tester)!.top.color, const Color(0xFF555555));
  });

  testWidgets('StreamErrorBadge.size wins over the theme default', (tester) async {
    const themeData = StreamErrorBadgeThemeData(size: StreamErrorBadgeSize.md);

    await tester.pumpWidget(
      _wrap(
        StreamErrorBadgeTheme(
          data: themeData,
          child: StreamErrorBadge(size: StreamErrorBadgeSize.xs),
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamErrorBadge)), Size.square(StreamErrorBadgeSize.xs.value));
  });

  testWidgets('StreamErrorBadgeTheme border is ignored when showBorder is false', (tester) async {
    final themeData = StreamErrorBadgeThemeData(
      border: Border.all(width: 4, color: const Color(0xFF555555)),
    );

    await tester.pumpWidget(
      _wrap(
        StreamErrorBadgeTheme(
          data: themeData,
          child: StreamErrorBadge(showBorder: false),
        ),
      ),
    );

    expect(_borderOf(tester), isNull);
  });

  testWidgets('StreamErrorBadge pins the warning icon to black in both brightnesses', (tester) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        _wrap(
          StreamErrorBadge(style: StreamErrorBadgeStyle.warning),
          brightness: brightness,
        ),
      );

      expect(_iconColorOf(tester), StreamColors.black, reason: 'brightness: ${brightness.name}');
    }
  });
}

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      extensions: [StreamTheme(brightness: brightness)],
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

StreamColorScheme _colorSchemeOf(WidgetTester tester) {
  final context = tester.element(find.byType(StreamErrorBadge));
  return StreamTheme.of(context).colorScheme;
}

// The badge paints its border into `foregroundDecoration` with
// `strokeAlignOutside`, so it separates the badge without growing it.
BoxBorder? _borderOf(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
  return (container.foregroundDecoration! as BoxDecoration).border;
}

Color? _backgroundColorOf(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
  return (container.decoration! as BoxDecoration).color;
}

Color? _iconColorOf(WidgetTester tester) {
  return tester.widget<Icon>(find.byType(Icon)).color ?? IconTheme.of(tester.element(find.byType(Icon))).color;
}
