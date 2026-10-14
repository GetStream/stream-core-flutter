import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('StreamTypingIndicatorDots animates while it is shown', (tester) async {
    await tester.pumpWidget(_wrap(StreamTypingIndicatorDots()));

    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('StreamTypingIndicatorDots brings the first dot to full opacity halfway through a cycle', (tester) async {
    const themeData = StreamTypingIndicatorDotsThemeData(period: Duration(seconds: 1));
    await tester.pumpWidget(_wrap(StreamTypingIndicatorDotsTheme(data: themeData, child: StreamTypingIndicatorDots())));

    await tester.pump(const Duration(milliseconds: 500));

    final color = _colorSchemeOf(tester).textPrimary;
    expect(_painterOf(tester), paints..circle(x: 2.5, color: color));
  });

  testWidgets('StreamTypingIndicatorDots moves the highlight to the next dot in reading order', (tester) async {
    const themeData = StreamTypingIndicatorDotsThemeData(period: Duration(seconds: 3));
    await tester.pumpWidget(_wrap(StreamTypingIndicatorDotsTheme(data: themeData, child: StreamTypingIndicatorDots())));

    await tester.pump(const Duration(milliseconds: 2500));

    final opacities = _dotOpacitiesOf(tester);
    expect(opacities[1], greaterThan(opacities[0]));
    expect(opacities[1], greaterThan(opacities[2]));
  });

  testWidgets('StreamTypingIndicatorDots does not animate when animations are disabled', (tester) async {
    await tester.pumpWidget(_wrap(StreamTypingIndicatorDots(), disableAnimations: true));

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('StreamTypingIndicatorDots holds a static frame when animations are disabled', (tester) async {
    await tester.pumpWidget(_wrap(StreamTypingIndicatorDots(), disableAnimations: true));

    final color = _colorSchemeOf(tester).textPrimary;
    expect(
      _painterOf(tester),
      paints
        ..circle(x: 2.5, y: 2.5, radius: 2.5, color: color)
        ..circle(x: 11.5, y: 2.5, radius: 2.5, color: color.withValues(alpha: 0.75))
        ..circle(x: 20.5, y: 2.5, radius: 2.5, color: color.withValues(alpha: 0.5)),
    );
  });

  testWidgets('StreamTypingIndicatorDots stops animating when Reduce Motion turns on', (tester) async {
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(_wrap(StreamTypingIndicatorDots()));

    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(reduceMotion: true);
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('StreamTypingIndicatorDots resumes animating when Reduce Motion turns off', (tester) async {
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(reduceMotion: true);
    await tester.pumpWidget(_wrap(StreamTypingIndicatorDots()));

    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures();
    await tester.pump();

    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('StreamTypingIndicatorDots leads from the right in RTL', (tester) async {
    await tester.pumpWidget(
      _wrap(StreamTypingIndicatorDots(), disableAnimations: true, textDirection: .rtl),
    );

    final color = _colorSchemeOf(tester).textPrimary;
    expect(
      _painterOf(tester),
      paints
        ..circle(x: 20.5, color: color)
        ..circle(x: 11.5, color: color.withValues(alpha: 0.75))
        ..circle(x: 2.5, color: color.withValues(alpha: 0.5)),
    );
  });

  testWidgets('StreamTypingIndicatorDotsTheme overrides the dot color, size and spacing', (tester) async {
    const themeData = StreamTypingIndicatorDotsThemeData(color: Color(0xFF112233), dotSize: 8, spacing: 6);

    await tester.pumpWidget(
      _wrap(
        StreamTypingIndicatorDotsTheme(data: themeData, child: StreamTypingIndicatorDots()),
        disableAnimations: true,
      ),
    );

    expect(
      _painterOf(tester),
      paints
        ..circle(x: 4, y: 4, radius: 4, color: const Color(0xFF112233))
        ..circle(x: 18, y: 4, radius: 4)
        ..circle(x: 32, y: 4, radius: 4),
    );
  });

  testWidgets('StreamTypingIndicatorDots props take precedence over StreamTypingIndicatorDotsTheme', (tester) async {
    const themeData = StreamTypingIndicatorDotsThemeData(color: Color(0xFF112233), dotSize: 8, spacing: 6);
    final indicator = StreamTypingIndicatorDots(color: const Color(0xFF445566), dotSize: 10, spacing: 2);

    await tester.pumpWidget(
      _wrap(StreamTypingIndicatorDotsTheme(data: themeData, child: indicator), disableAnimations: true),
    );

    expect(
      _painterOf(tester),
      paints
        ..circle(x: 5, y: 5, radius: 5, color: const Color(0xFF445566))
        ..circle(x: 17, y: 5, radius: 5)
        ..circle(x: 29, y: 5, radius: 5),
    );
  });

  testWidgets('StreamTypingIndicatorDots runs at the new speed when period changes', (tester) async {
    await tester.pumpWidget(_wrap(StreamTypingIndicatorDots(period: const Duration(seconds: 3))));
    await tester.pumpWidget(_wrap(StreamTypingIndicatorDots(period: const Duration(seconds: 1))));

    await tester.pump(const Duration(milliseconds: 500));

    final color = _colorSchemeOf(tester).textPrimary;
    expect(_painterOf(tester), paints..circle(x: 2.5, color: color));
  });

  testWidgets('StreamTypingIndicatorDots animates without rebuilding', (tester) async {
    await tester.pumpWidget(_wrap(StreamTypingIndicatorDots()));

    var rebuilds = 0;
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is DefaultStreamTypingIndicatorDots) rebuilds += 1;
      if (element.findAncestorWidgetOfExactType<DefaultStreamTypingIndicatorDots>() != null) rebuilds += 1;
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);
    for (var frame = 0; frame < 10; frame += 1) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(rebuilds, 0);
  });

  testWidgets('StreamTypingIndicatorDots animates without repainting its surroundings', (tester) async {
    var surroundingPaints = 0;
    await tester.pumpWidget(
      _wrap(
        CustomPaint(
          painter: _PaintCounter(() => surroundingPaints += 1),
          child: StreamTypingIndicatorDots(),
        ),
      ),
    );

    surroundingPaints = 0;
    for (var frame = 0; frame < 10; frame += 1) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(surroundingPaints, 0);
  });

  testWidgets('StreamTypingIndicatorDots exposes its semanticsLabel to screen readers', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_wrap(StreamTypingIndicatorDots(semanticsLabel: 'Ada is typing')));

    expect(find.bySemanticsLabel('Ada is typing'), findsOneWidget);
    handle.dispose();
  });
}

Widget _wrap(
  Widget child, {
  bool disableAnimations = false,
  TextDirection textDirection = .ltr,
}) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
      child: child!,
    ),
    home: Directionality(
      textDirection: textDirection,
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

StreamColorScheme _colorSchemeOf(WidgetTester tester) {
  final context = tester.element(find.byType(StreamTypingIndicatorDots));
  return StreamTheme.of(context).colorScheme;
}

// The opacity of each painted dot, ordered left to right.
List<double> _dotOpacitiesOf(WidgetTester tester) {
  final dots = <(double, double)>[];
  expect(
    _painterOf(tester),
    paints..everything((method, arguments) {
      if (method != #drawCircle) return true;
      final [Offset center, _, Paint paint] = arguments;
      dots.add((center.dx, paint.color.a));
      return true;
    }),
  );
  dots.sort((a, b) => a.$1.compareTo(b.$1));
  return [for (final (_, opacity) in dots) opacity];
}

RenderObject _painterOf(WidgetTester tester) {
  final customPaint = find.descendant(
    of: find.byType(StreamTypingIndicatorDots),
    matching: find.byType(CustomPaint),
  );
  return tester.renderObject(customPaint);
}

class _PaintCounter extends CustomPainter {
  _PaintCounter(this.onPaint);

  final VoidCallback onPaint;

  @override
  void paint(Canvas canvas, Size size) => onPaint();

  @override
  bool shouldRepaint(_PaintCounter oldDelegate) => false;
}
