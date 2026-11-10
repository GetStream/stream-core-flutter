import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  testWidgets('StreamEmptyState draws the icon, title and description', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamEmptyState(
          icon: const Icon(Icons.inbox),
          title: const Text('Nothing here'),
          description: const Text('Things show up here.'),
        ),
      ),
    );

    expect(find.byIcon(Icons.inbox), findsOneWidget);
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Things show up here.'), findsOneWidget);
  });

  testWidgets('StreamEmptyState draws the action under the text', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamEmptyState(
          icon: const Icon(Icons.inbox),
          title: const Text('Title'),
          description: const Text('Description'),
          action: const Text('Action'),
        ),
      ),
    );

    final descriptionBottom = tester.getBottomLeft(find.text('Description')).dy;
    expect(tester.getTopLeft(find.text('Action')).dy - descriptionBottom, 12);
  });

  testWidgets('StreamEmptyState stacks the icon, title and description with the default gaps', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamEmptyState(
          icon: const Icon(Icons.inbox),
          title: const Text('Title'),
          description: const Text('Description'),
        ),
      ),
    );

    final iconBottom = tester.getBottomLeft(find.byIcon(Icons.inbox)).dy;
    final titleTop = tester.getTopLeft(find.text('Title')).dy;
    final titleBottom = tester.getBottomLeft(find.text('Title')).dy;
    final descriptionTop = tester.getTopLeft(find.text('Description')).dy;
    expect(titleTop - iconBottom, 12);
    expect(descriptionTop - titleBottom, 4);
  });

  testWidgets('StreamEmptyState leaves no gap for a missing description and action', (tester) async {
    await tester.pumpWidget(_wrap(StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Title'))));

    final titleHeight = tester.getSize(find.text('Title')).height;
    // 40px vertical padding on each side, a 32px icon and a 12px gap.
    expect(tester.getSize(find.byType(StreamEmptyState)).height, 40 + 32 + 12 + titleHeight + 40);
  });

  testWidgets('StreamEmptyState pads its content with the default padding', (tester) async {
    await tester.pumpWidget(_wrap(StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Title'))));

    final emptyStateTop = tester.getTopLeft(find.byType(StreamEmptyState)).dy;
    expect(tester.getTopLeft(find.byIcon(Icons.inbox)).dy - emptyStateTop, 40);
  });

  testWidgets('StreamEmptyState centres its content horizontally', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 400,
          child: StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Title')),
        ),
      ),
    );

    final centre = tester.getCenter(find.byType(StreamEmptyState)).dx;
    expect(tester.getCenter(find.byIcon(Icons.inbox)).dx, moreOrLessEquals(centre, epsilon: 0.5));
    expect(tester.getCenter(find.text('Title')).dx, moreOrLessEquals(centre, epsilon: 0.5));
  });

  testWidgets('StreamEmptyState draws the icon at 32px in the secondary text color', (tester) async {
    await tester.pumpWidget(_wrap(StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Title'))));

    final iconTheme = IconTheme.of(tester.element(find.byIcon(Icons.inbox)));
    expect(iconTheme.size, 32);
    expect(iconTheme.color, _colorSchemeOf(tester).textSecondary);
  });

  testWidgets('StreamEmptyState styles the title as headingXs in the primary text color', (tester) async {
    await tester.pumpWidget(_wrap(StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Title'))));

    final style = _textStyleOf(tester, 'Title');
    final textTheme = _streamThemeOf(tester).textTheme;
    expect(style?.fontSize, textTheme.headingXs.fontSize);
    expect(style?.fontWeight, textTheme.headingXs.fontWeight);
    expect(style?.color, _colorSchemeOf(tester).textPrimary);
  });

  testWidgets('StreamEmptyState styles the description as captionDefault in the secondary text color', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        StreamEmptyState(
          icon: const Icon(Icons.inbox),
          title: const Text('Title'),
          description: const Text('Description'),
        ),
      ),
    );

    final style = _textStyleOf(tester, 'Description');
    final textTheme = _streamThemeOf(tester).textTheme;
    expect(style?.fontSize, textTheme.captionDefault.fontSize);
    expect(style?.fontWeight, textTheme.captionDefault.fontWeight);
    expect(style?.color, _colorSchemeOf(tester).textSecondary);
  });

  testWidgets('StreamEmptyState centres the lines of a wrapped description', (tester) async {
    const description = 'A description long enough to wrap over more than one line of text';

    await tester.pumpWidget(
      _wrap(
        StreamEmptyState(
          icon: const Icon(Icons.inbox),
          title: const Text('Title'),
          description: const Text(description),
        ),
      ),
    );

    expect(tester.renderObject<RenderParagraph>(find.text(description)).textAlign, TextAlign.center);
  });

  testWidgets('StreamEmptyState wraps the text at 320px when given more room', (tester) async {
    const description = 'A description long enough to need far more than three hundred and twenty pixels';

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 800,
          child: StreamEmptyState(
            icon: const Icon(Icons.inbox),
            title: const Text('Title'),
            description: const Text(description),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.text(description)).width, lessThanOrEqualTo(320));
  });

  testWidgets('StreamEmptyState grows taller without overflowing at a large text scale', (tester) async {
    // Scrollable so that only an overflow inside the empty state fails the test.
    final emptyState = SingleChildScrollView(
      child: SizedBox(
        width: 320,
        child: StreamEmptyState(
          icon: const Icon(Icons.inbox),
          title: const Text('A title that wraps once the text is scaled up'),
          description: const Text('A description that wraps over several lines once the text is scaled up'),
          action: const Text('Try again'),
        ),
      ),
    );

    await tester.pumpWidget(_wrap(emptyState));
    final unscaledHeight = tester.getSize(find.byType(StreamEmptyState)).height;

    await tester.pumpWidget(_wrap(emptyState, textScale: 2));

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(StreamEmptyState)).height, greaterThan(unscaledHeight));
  });

  testWidgets('StreamEmptyState marks the title as a heading', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_wrap(StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Nothing here'))));

    expect(tester.semantics.find(find.text('Nothing here')), isSemantics(label: 'Nothing here', isHeader: true));
    handle.dispose();
  });

  testWidgets('StreamEmptyState does not mark the description as a heading', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      _wrap(
        StreamEmptyState(
          icon: const Icon(Icons.inbox),
          title: const Text('Nothing here'),
          description: const Text('Things show up here.'),
        ),
      ),
    );

    expect(tester.semantics.find(find.text('Things show up here.')), isSemantics(isHeader: false));
    handle.dispose();
  });

  group('when textDirection is RTL', () {
    testWidgets('StreamEmptyState keeps its content centred', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 400,
            child: StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Title')),
          ),
          rtl: true,
        ),
      );

      final centre = tester.getCenter(find.byType(StreamEmptyState)).dx;
      expect(tester.getCenter(find.byIcon(Icons.inbox)).dx, moreOrLessEquals(centre, epsilon: 0.5));
      expect(tester.getCenter(find.text('Title')).dx, moreOrLessEquals(centre, epsilon: 0.5));
    });

    testWidgets('StreamEmptyState applies a directional padding to the start on the right', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamEmptyStateTheme(
            data: const StreamEmptyStateThemeData(padding: EdgeInsetsDirectional.only(start: 40)),
            child: SizedBox(
              width: 400,
              child: StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Title')),
            ),
          ),
          rtl: true,
        ),
      );

      // The 40px start padding sits on the right, so the content centres in the left 360px.
      final left = tester.getTopLeft(find.byType(StreamEmptyState)).dx;
      expect(tester.getCenter(find.byIcon(Icons.inbox)).dx - left, moreOrLessEquals(180, epsilon: 0.5));
    });
  });

  testWidgets('StreamEmptyStateTheme overrides the icon size and color', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamEmptyStateTheme(
          data: const StreamEmptyStateThemeData(iconSize: 48, iconColor: Color(0xFF111111)),
          child: StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Title')),
        ),
      ),
    );

    final iconTheme = IconTheme.of(tester.element(find.byIcon(Icons.inbox)));
    expect(iconTheme.size, 48);
    expect(iconTheme.color, const Color(0xFF111111));
  });

  testWidgets('StreamEmptyState lets an icon size passed to the icon win over the theme', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamEmptyStateTheme(
          data: const StreamEmptyStateThemeData(iconSize: 48),
          child: StreamEmptyState(icon: const Icon(Icons.inbox, size: 20), title: const Text('Title')),
        ),
      ),
    );

    expect(tester.getSize(find.byIcon(Icons.inbox)), const Size.square(20));
  });

  testWidgets('StreamEmptyStateTheme overrides the title and description styles', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamEmptyStateTheme(
          data: const StreamEmptyStateThemeData(
            titleTextStyle: TextStyle(color: Color(0xFF222222)),
            descriptionTextStyle: TextStyle(color: Color(0xFF333333)),
          ),
          child: StreamEmptyState(
            icon: const Icon(Icons.inbox),
            title: const Text('Title'),
            description: const Text('Description'),
          ),
        ),
      ),
    );

    expect(_textStyleOf(tester, 'Title')?.color, const Color(0xFF222222));
    expect(_textStyleOf(tester, 'Description')?.color, const Color(0xFF333333));
  });

  testWidgets('StreamEmptyState lets a style passed to the text win over the theme', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamEmptyStateTheme(
          data: const StreamEmptyStateThemeData(titleTextStyle: TextStyle(color: Color(0xFF222222))),
          child: StreamEmptyState(
            icon: const Icon(Icons.inbox),
            title: const Text('Title', style: TextStyle(color: Color(0xFF444444))),
          ),
        ),
      ),
    );

    expect(_textStyleOf(tester, 'Title')?.color, const Color(0xFF444444));
  });

  testWidgets('StreamEmptyStateTheme overrides the padding', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamEmptyStateTheme(
          data: const StreamEmptyStateThemeData(padding: EdgeInsets.all(8)),
          child: StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Title')),
        ),
      ),
    );

    final emptyStateTop = tester.getTopLeft(find.byType(StreamEmptyState)).dy;
    expect(tester.getTopLeft(find.byIcon(Icons.inbox)).dy - emptyStateTop, 8);
  });

  testWidgets('StreamEmptyStateTheme overrides the gaps', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamEmptyStateTheme(
          data: const StreamEmptyStateThemeData(spacing: 20, textSpacing: 10),
          child: StreamEmptyState(
            icon: const Icon(Icons.inbox),
            title: const Text('Title'),
            description: const Text('Description'),
            action: const Text('Action'),
          ),
        ),
      ),
    );

    final iconBottom = tester.getBottomLeft(find.byIcon(Icons.inbox)).dy;
    final titleBottom = tester.getBottomLeft(find.text('Title')).dy;
    final descriptionBottom = tester.getBottomLeft(find.text('Description')).dy;
    expect(tester.getTopLeft(find.text('Title')).dy - iconBottom, 20);
    expect(tester.getTopLeft(find.text('Description')).dy - titleBottom, 10);
    expect(tester.getTopLeft(find.text('Action')).dy - descriptionBottom, 20);
  });

  testWidgets('StreamEmptyStateTheme overrides the width the text wraps at', (tester) async {
    const description = 'A description long enough to need more than two hundred pixels';

    await tester.pumpWidget(
      _wrap(
        StreamEmptyStateTheme(
          data: const StreamEmptyStateThemeData(maxTextWidth: 200),
          child: SizedBox(
            width: 800,
            child: StreamEmptyState(
              icon: const Icon(Icons.inbox),
              title: const Text('Title'),
              description: const Text(description),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.text(description)).width, lessThanOrEqualTo(200));
  });

  testWidgets('StreamEmptyStateTheme merges over the root StreamTheme', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamEmptyStateTheme(
          data: const StreamEmptyStateThemeData(iconColor: Color(0xFF333333)),
          child: StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Title')),
        ),
        streamTheme: StreamTheme(
          emptyStateTheme: const StreamEmptyStateThemeData(iconSize: 48, iconColor: Color(0xFF111111)),
        ),
      ),
    );

    final iconTheme = IconTheme.of(tester.element(find.byIcon(Icons.inbox)));
    expect(iconTheme.size, 48);
    expect(iconTheme.color, const Color(0xFF333333));
  });

  testWidgets('StreamComponentFactory replaces the default empty state', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamComponentFactory(
          builders: StreamComponentBuilders(emptyState: (context, props) => const Text('custom')),
          child: StreamEmptyState(icon: const Icon(Icons.inbox), title: const Text('Title')),
        ),
      ),
    );

    expect(find.text('custom'), findsOneWidget);
    expect(find.byType(DefaultStreamEmptyState), findsNothing);
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

StreamTheme _streamThemeOf(WidgetTester tester) => StreamTheme.of(tester.element(find.byType(StreamEmptyState)));

StreamColorScheme _colorSchemeOf(WidgetTester tester) => _streamThemeOf(tester).colorScheme;

TextStyle? _textStyleOf(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style;
