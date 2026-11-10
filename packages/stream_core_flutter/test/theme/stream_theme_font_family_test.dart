import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

Widget _app({required ThemeData theme, required Widget child}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: Center(child: child)),
  );
}

// The style the text is painted with, after every DefaultTextStyle above it.
String? _familyOf(WidgetTester tester, String text) {
  final richText = find.descendant(of: find.text(text), matching: find.byType(RichText));
  return tester.widget<RichText>(richText).text.style?.fontFamily;
}

void main() {
  group('StreamTheme(fontFamily:)', () {
    test('applies the family to the default text theme', () {
      final theme = StreamTheme(fontFamily: 'AppFont', fontFamilyFallback: const ['Fallback']);

      expect(theme.textTheme.bodyDefault.fontFamily, 'AppFont');
      expect(theme.textTheme.headingLg.fontFamilyFallback, ['Fallback']);
    });

    test('leaves an explicit text theme alone', () {
      final textTheme = StreamTextTheme().apply(fontFamily: 'TextThemeFont');

      final theme = StreamTheme(fontFamily: 'AppFont', textTheme: textTheme);

      expect(theme.textTheme.bodyDefault.fontFamily, 'TextThemeFont');
    });

    test('is kept by applyPlatform', () {
      final theme = StreamTheme(platform: TargetPlatform.android, fontFamily: 'AppFont');

      final iosTheme = theme.applyPlatform(TargetPlatform.iOS);

      expect(iosTheme.typography.fontSize, StreamFontSize.ios);
      expect(iosTheme.textTheme.bodyDefault.fontFamily, 'AppFont');
    });
  });

  group('StreamTheme.of', () {
    testWidgets("takes ThemeData's font family when the text theme sets none", (tester) async {
      late StreamTheme resolved;
      await tester.pumpWidget(
        _app(
          theme: ThemeData(fontFamily: 'AppFont', extensions: [StreamTheme()]),
          child: Builder(
            builder: (context) {
              resolved = StreamTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved.textTheme.bodyDefault.fontFamily, 'AppFont');
    });

    testWidgets("takes ThemeData's font family without a StreamTheme extension", (tester) async {
      late StreamTheme resolved;
      await tester.pumpWidget(
        _app(
          theme: ThemeData(fontFamily: 'AppFont'),
          child: Builder(
            builder: (context) {
              resolved = StreamTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved.textTheme.bodyDefault.fontFamily, 'AppFont');
    });

    testWidgets("prefers StreamTheme's font family over ThemeData's", (tester) async {
      late StreamTheme resolved;
      await tester.pumpWidget(
        _app(
          theme: ThemeData(
            fontFamily: 'AppFont',
            extensions: [StreamTheme(fontFamily: 'StreamFont')],
          ),
          child: Builder(
            builder: (context) {
              resolved = StreamTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved.textTheme.bodyDefault.fontFamily, 'StreamFont');
    });

    testWidgets('returns the same theme on every lookup', (tester) async {
      final lookups = <StreamTheme>[];
      await tester.pumpWidget(
        _app(
          theme: ThemeData(fontFamily: 'AppFont', extensions: [StreamTheme()]),
          child: Builder(
            builder: (context) {
              lookups
                ..add(StreamTheme.of(context))
                ..add(StreamTheme.of(context));
              return const SizedBox();
            },
          ),
        ),
      );

      expect(identical(lookups[0], lookups[1]), isTrue);
    });
  });

  group("components with ThemeData's font family", () {
    final theme = ThemeData(fontFamily: 'AppFont', extensions: [StreamTheme()]);

    testWidgets('StreamButton', (tester) async {
      await tester.pumpWidget(
        _app(
          theme: theme,
          child: StreamButton(onPressed: () {}, child: const Text('Label')),
        ),
      );

      expect(_familyOf(tester, 'Label'), 'AppFont');
    });

    testWidgets('StreamListTile', (tester) async {
      await tester.pumpWidget(
        _app(
          theme: theme,
          child: StreamListTile(title: const Text('Title')),
        ),
      );

      expect(_familyOf(tester, 'Title'), 'AppFont');
    });

    testWidgets('StreamContextMenuAction', (tester) async {
      await tester.pumpWidget(
        _app(
          theme: theme,
          child: StreamContextMenuAction<void>(label: const Text('Action'), onTap: () {}),
        ),
      );

      expect(_familyOf(tester, 'Action'), 'AppFont');
    });

    testWidgets('StreamAppBar', (tester) async {
      await tester.pumpWidget(
        _app(
          theme: theme,
          child: StreamAppBar(title: const Text('App bar')),
        ),
      );

      expect(_familyOf(tester, 'App bar'), 'AppFont');
    });

    testWidgets('StreamPlaybackSpeedToggle', (tester) async {
      await tester.pumpWidget(
        _app(
          theme: theme,
          child: StreamPlaybackSpeedToggle(value: StreamPlaybackSpeed.x1, onChanged: (_) {}),
        ),
      );

      expect(_familyOf(tester, StreamPlaybackSpeed.x1.label), 'AppFont');
    });
  });
}
