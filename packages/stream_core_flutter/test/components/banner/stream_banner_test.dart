import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('StreamBanner renders the title', (tester) async {
    await tester.pumpWidget(_wrap(StreamBanner(title: const Text('Waiting for network…'))));

    expect(find.text('Waiting for network…'), findsOneWidget);
  });

  for (final type in StreamBannerType.values) {
    testWidgets('StreamBanner paints the surface background for the ${type.name} type', (tester) async {
      await tester.pumpWidget(_wrap(StreamBanner(type: type, title: const Text('Title'))));

      expect(_backgroundColorOf(tester), _colorSchemeOf(tester).backgroundSurface);
    });
  }

  final expectedIconColors = <StreamBannerType, Color Function(StreamColorScheme)>{
    .neutral: (colorScheme) => colorScheme.textSecondary,
    .loading: (colorScheme) => colorScheme.textSecondary,
    .error: (colorScheme) => colorScheme.textTertiary,
  };
  for (final type in StreamBannerType.values) {
    testWidgets('StreamBanner colors the ${type.name} icon', (tester) async {
      await tester.pumpWidget(_wrap(StreamBanner(type: type, title: const Text('Title'))));

      expect(_leadingIconColorOf(tester), expectedIconColors[type]!(_colorSchemeOf(tester)));
    });
  }

  testWidgets('StreamBanner centers its content', (tester) async {
    await tester.pumpWidget(_wrap(StreamBanner(title: const Text('Title'))));

    final bannerCenter = tester.getCenter(find.byType(StreamBanner));
    final contentLeft = tester.getTopLeft(find.byType(Icon)).dx;
    final contentRight = tester.getTopRight(find.text('Title')).dx;
    expect((contentLeft + contentRight) / 2, moreOrLessEquals(bannerCenter.dx, epsilon: 0.5));
  });

  testWidgets('StreamBanner keeps the icon beside a wrapped title', (tester) async {
    // Two 10-glyph words wrap onto two equal lines, well short of the 200px
    // the title is offered beside the icon.
    const title = 'WWWWWWWWWW WWWWWWWWWW';

    await tester.pumpWidget(_wrap(SizedBox(width: 244, child: StreamBanner(title: const Text(title)))));

    final paragraph = tester.renderObject<RenderParagraph>(find.text(title));
    final boxes = paragraph.getBoxesForSelection(const TextSelection(baseOffset: 0, extentOffset: title.length));
    final firstGlyphLeft = paragraph.localToGlobal(Offset(boxes.map((box) => box.left).reduce(math.min), 0)).dx;
    final iconRight = tester.getTopRight(find.byType(Icon)).dx;
    expect(firstGlyphLeft - iconRight, moreOrLessEquals(8, epsilon: 0.5));
  });

  testWidgets('StreamBanner hugs the default icon with its padding', (tester) async {
    await tester.pumpWidget(_wrap(SizedBox(width: 320, child: StreamBanner(title: const Text('Title')))));

    expect(tester.getSize(find.byType(StreamBanner)).height, 12 + 20 + 12);
  });

  testWidgets('StreamBanner hugs the title with its padding when the icon is hidden', (tester) async {
    await tester.pumpWidget(
      _wrap(SizedBox(width: 320, child: StreamBanner(showIcon: false, title: const Text('Title')))),
    );

    final titleHeight = tester.getSize(find.text('Title')).height;
    final bannerHeight = tester.getSize(find.byType(StreamBanner)).height;
    expect(bannerHeight, 12 + titleHeight + 12);
  });

  testWidgets('StreamBanner sizes to its content in an unbounded parent', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SingleChildScrollView(
          child: Column(children: [StreamBanner(title: const Text('Title'))]),
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamBanner)).height, 12 + 20 + 12);
  });

  // A 10-glyph word and a 5-glyph word wrap onto lines of different lengths in
  // the 156px the title is offered beside the icon.
  const unevenTitle = 'WWWWWWWWWW WWWWW';

  testWidgets('StreamBanner aligns the lines of a wrapped title to the start edge', (tester) async {
    await tester.pumpWidget(_wrap(SizedBox(width: 200, child: StreamBanner(title: const Text(unevenTitle)))));

    final (firstLine, secondLine) = _lineBoxesOf(tester, unevenTitle);
    expect(secondLine.right, lessThan(firstLine.right));
    expect(secondLine.left, firstLine.left);
  });

  group('when textDirection is RTL', () {
    testWidgets('StreamBanner aligns the lines of a wrapped title to the right edge', (tester) async {
      await tester.pumpWidget(
        _wrap(SizedBox(width: 200, child: StreamBanner(title: const Text(unevenTitle))), rtl: true),
      );

      final (firstLine, secondLine) = _lineBoxesOf(tester, unevenTitle);
      expect(secondLine.left, greaterThan(firstLine.left));
      expect(secondLine.right, firstLine.right);
    });

    testWidgets('StreamBanner places the icon after the title on the right', (tester) async {
      await tester.pumpWidget(_wrap(StreamBanner(title: const Text('Title')), rtl: true));

      final iconLeft = tester.getTopLeft(find.byType(Icon)).dx;
      final titleRight = tester.getTopRight(find.text('Title')).dx;
      expect(iconLeft, greaterThan(titleRight));
    });
  });

  testWidgets('StreamBanner shows the refresh icon for the neutral type', (tester) async {
    await tester.pumpWidget(_wrap(StreamBanner(title: const Text('Title'))));

    expect(find.byIcon(StreamIconData.refresh), findsOneWidget);
  });

  testWidgets('StreamBanner shows the exclamation circle icon for the error type', (tester) async {
    await tester.pumpWidget(_wrap(StreamBanner(type: .error, title: const Text('Title'))));

    expect(find.byIcon(StreamIconData.exclamationCircle), findsOneWidget);
  });

  testWidgets('StreamBanner shows a spinner for the loading type', (tester) async {
    await tester.pumpWidget(_wrap(StreamBanner(type: .loading, title: const Text('Title'))));

    expect(find.byType(StreamLoadingSpinner), findsOneWidget);
  });

  testWidgets('StreamBanner replaces the default icon with a custom one', (tester) async {
    await tester.pumpWidget(
      _wrap(StreamBanner(type: .error, icon: const Icon(Icons.wifi_off), title: const Text('Title'))),
    );

    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(find.byIcon(StreamIconData.exclamationCircle), findsNothing);
  });

  testWidgets('StreamBanner replaces the spinner with a custom icon for the loading type', (tester) async {
    await tester.pumpWidget(
      _wrap(StreamBanner(type: .loading, icon: const Icon(Icons.wifi_off), title: const Text('Title'))),
    );

    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(find.byType(StreamLoadingSpinner), findsNothing);
  });

  testWidgets('StreamBannerTheme colors the loading spinner', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamBannerTheme(
          data: const StreamBannerThemeData(loading: StreamBannerThemeStyle(iconColor: Color(0xFF222222))),
          child: StreamBanner(type: .loading, title: const Text('Title')),
        ),
      ),
    );

    expect(_leadingIconColorOf(tester), const Color(0xFF222222));
  });

  testWidgets('StreamBanner tints a custom icon with the icon color', (tester) async {
    await tester.pumpWidget(
      _wrap(StreamBanner(type: .error, icon: const Icon(Icons.wifi_off), title: const Text('Title'))),
    );

    final iconTheme = IconTheme.of(tester.element(find.byIcon(Icons.wifi_off)));
    expect(iconTheme.color, _colorSchemeOf(tester).textTertiary);
  });

  testWidgets('StreamBanner hides the icon when showIcon is false', (tester) async {
    await tester.pumpWidget(_wrap(StreamBanner(showIcon: false, title: const Text('Title'))));

    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('StreamBanner grows taller without overflowing at a large text scale', (tester) async {
    const title = 'A long title that wraps over several lines once the text is scaled up';
    final banner = SizedBox(width: 320, child: StreamBanner(title: const Text(title)));

    await tester.pumpWidget(_wrap(banner));
    final unscaledHeight = tester.getSize(find.byType(StreamBanner)).height;

    await tester.pumpWidget(_wrap(banner, textScale: 2));

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(StreamBanner)).height, greaterThan(unscaledHeight));
  });

  testWidgets('StreamBanner announces its title as a live region', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_wrap(StreamBanner(title: const Text('Waiting for network…'))));

    expect(
      tester.semantics.find(find.byType(DefaultStreamBanner)),
      isSemantics(label: 'Waiting for network…', isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('StreamBannerTheme overrides the style of one type', (tester) async {
    const themeData = StreamBannerThemeData(
      error: StreamBannerThemeStyle(backgroundColor: Color(0xFF111111), iconColor: Color(0xFF222222)),
    );

    await tester.pumpWidget(
      _wrap(
        StreamBannerTheme(
          data: themeData,
          child: StreamBanner(type: .error, title: const Text('Title')),
        ),
      ),
    );

    expect(_backgroundColorOf(tester), const Color(0xFF111111));
    expect(_leadingIconColorOf(tester), const Color(0xFF222222));
  });

  testWidgets('StreamBannerTheme leaves the other types untouched', (tester) async {
    const themeData = StreamBannerThemeData(error: StreamBannerThemeStyle(backgroundColor: Color(0xFF111111)));

    await tester.pumpWidget(
      _wrap(
        StreamBannerTheme(
          data: themeData,
          child: StreamBanner(title: const Text('Title')),
        ),
      ),
    );

    expect(_backgroundColorOf(tester), _colorSchemeOf(tester).backgroundSurface);
  });

  testWidgets('StreamBannerTheme overrides the title style of one type only', (tester) async {
    const themeData = StreamBannerThemeData(
      error: StreamBannerThemeStyle(titleTextStyle: TextStyle(color: Color(0xFF444444))),
    );

    await tester.pumpWidget(
      _wrap(
        StreamBannerTheme(
          data: themeData,
          child: Column(
            children: [
              StreamBanner(type: .error, title: const Text('Error')),
              StreamBanner(title: const Text('Neutral')),
            ],
          ),
        ),
      ),
    );

    final colorScheme = StreamTheme.of(tester.element(find.text('Error'))).colorScheme;
    expect(tester.renderObject<RenderParagraph>(find.text('Error')).text.style?.color, const Color(0xFF444444));
    expect(tester.renderObject<RenderParagraph>(find.text('Neutral')).text.style?.color, colorScheme.textSecondary);
  });

  for (final type in StreamBannerType.values) {
    testWidgets('StreamBannerTheme applies a shared padding to the ${type.name} type', (tester) async {
      const themeData = StreamBannerThemeData(padding: EdgeInsets.all(20));

      await tester.pumpWidget(
        _wrap(
          StreamBannerTheme(
            data: themeData,
            child: StreamBanner(type: type, title: const Text('Title')),
          ),
        ),
      );

      // The 20px icon is the tallest child, so it sits right against the padding.
      final leading = find.descendant(
        of: find.byType(DefaultStreamBanner),
        matching: find.byWidgetPredicate((widget) => widget is Icon || widget is StreamLoadingSpinner),
      );
      expect(tester.getTopLeft(leading).dy - tester.getTopLeft(find.byType(StreamBanner)).dy, 20);
      expect(tester.getBottomLeft(find.byType(StreamBanner)).dy - tester.getBottomLeft(leading).dy, 20);
    });
  }

  testWidgets('StreamBannerTheme applies themed constraints', (tester) async {
    const themeData = StreamBannerThemeData(constraints: BoxConstraints(minHeight: 60));

    await tester.pumpWidget(
      _wrap(
        StreamBannerTheme(
          data: themeData,
          child: SizedBox(width: 320, child: StreamBanner(title: const Text('Title'))),
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamBanner)).height, 60);
  });

  testWidgets('StreamBannerTheme applies a themed shape', (tester) async {
    const shape = StadiumBorder();

    await tester.pumpWidget(
      _wrap(
        StreamBannerTheme(
          data: const StreamBannerThemeData(shape: shape),
          child: StreamBanner(title: const Text('Title')),
        ),
      ),
    );

    expect(_surfaceOf(tester).shape, shape);
  });

  testWidgets('StreamBanner is a rectangle when no shape is themed', (tester) async {
    await tester.pumpWidget(_wrap(StreamBanner(title: const Text('Title'))));

    expect(_surfaceOf(tester).shape, isNull);
  });

  testWidgets('StreamBannerTheme applies a themed spacing between the icon and the title', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamBannerTheme(
          data: const StreamBannerThemeData(spacing: 16),
          child: StreamBanner(title: const Text('Title')),
        ),
      ),
    );

    final iconRight = tester.getTopRight(find.byType(Icon)).dx;
    expect(tester.getTopLeft(find.text('Title')).dx - iconRight, 16);
  });

  testWidgets('StreamBannerTheme merges over the root StreamTheme', (tester) async {
    const rootTheme = StreamBannerThemeData(
      neutral: StreamBannerThemeStyle(backgroundColor: Color(0xFF111111), iconColor: Color(0xFF222222)),
    );
    const localTheme = StreamBannerThemeData(neutral: StreamBannerThemeStyle(backgroundColor: Color(0xFF333333)));

    await tester.pumpWidget(
      _wrap(
        StreamBannerTheme(
          data: localTheme,
          child: StreamBanner(title: const Text('Title')),
        ),
        streamTheme: StreamTheme(bannerTheme: rootTheme),
      ),
    );

    expect(_backgroundColorOf(tester), const Color(0xFF333333));
    expect(_leadingIconColorOf(tester), const Color(0xFF222222));
  });

  testWidgets('StreamComponentFactory replaces the default banner', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamComponentFactory(
          builders: StreamComponentBuilders(banner: (context, props) => const Text('custom')),
          child: StreamBanner(title: const Text('Title')),
        ),
      ),
    );

    expect(find.text('custom'), findsOneWidget);
    expect(find.byType(DefaultStreamBanner), findsNothing);
  });
}

Widget _wrap(Widget child, {bool rtl = false, double textScale = 1, StreamTheme? streamTheme}) {
  return MaterialApp(
    theme: ThemeData(extensions: [streamTheme ?? StreamTheme()]),
    home: Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

StreamColorScheme _colorSchemeOf(WidgetTester tester) {
  final context = tester.element(find.byType(StreamBanner));
  return StreamTheme.of(context).colorScheme;
}

Material _surfaceOf(WidgetTester tester) {
  final finder = find.descendant(of: find.byType(DefaultStreamBanner), matching: find.byType(Material));
  return tester.widget<Material>(finder.first);
}

Color? _backgroundColorOf(WidgetTester tester) => _surfaceOf(tester).color;

// The spinner paints its own color and ignores the IconTheme, so it is read
// from the spinner itself.
Color? _leadingIconColorOf(WidgetTester tester) {
  final banner = find.byType(DefaultStreamBanner);
  final spinner = find.descendant(of: banner, matching: find.byType(StreamLoadingSpinner));
  if (spinner.evaluate().isNotEmpty) return tester.widget<StreamLoadingSpinner>(spinner).props.color;
  return IconTheme.of(tester.element(find.descendant(of: banner, matching: find.byType(Icon)).first)).color;
}

// The text boxes of the first and second word, which wrap onto their own lines.
(TextBox, TextBox) _lineBoxesOf(WidgetTester tester, String title) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(title));
  final firstWordEnd = title.indexOf(' ');
  final firstLine = paragraph.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: firstWordEnd)).single;
  final secondLine = paragraph
      .getBoxesForSelection(TextSelection(baseOffset: firstWordEnd + 1, extentOffset: title.length))
      .single;
  return (firstLine, secondLine);
}
