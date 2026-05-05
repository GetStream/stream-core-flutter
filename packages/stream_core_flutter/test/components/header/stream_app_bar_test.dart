import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: child,
  );
}

void main() {
  group('StreamAppBar auto-implied leading', () {
    testWidgets('does nothing when route cannot pop', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(Scaffold(appBar: StreamAppBar(title: const Text('Title')))),
      );

      // Root route of MaterialApp — canPop() is false, so no back button.
      expect(find.byType(StreamButton), findsNothing);
    });

    testWidgets('inserts arrow-left on a regular pushed route on Android', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await tester.pumpWidget(_withStreamTheme(const _LauncherScreen()));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(StreamButton), findsOneWidget);
        expect(find.byIcon(StreamIconData.arrowLeft), findsOneWidget);
        expect(find.byIcon(StreamIconData.chevronLeft), findsNothing);
        expect(find.byIcon(StreamIconData.xmark), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('inserts back chevron on a regular pushed route on iOS', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await tester.pumpWidget(_withStreamTheme(const _LauncherScreen()));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(StreamButton), findsOneWidget);
        expect(find.byIcon(StreamIconData.chevronLeft), findsOneWidget);
        expect(find.byIcon(StreamIconData.arrowLeft), findsNothing);
        expect(find.byIcon(StreamIconData.xmark), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('inserts cross icon on a fullscreen dialog', (tester) async {
      await tester.pumpWidget(_withStreamTheme(const _LauncherScreen(fullscreenDialog: true)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(StreamButton), findsOneWidget);
      expect(find.byIcon(StreamIconData.xmark), findsOneWidget);
      expect(find.byIcon(StreamIconData.chevronLeft), findsNothing);
    });

    testWidgets('caller-provided leading suppresses the default', (tester) async {
      await tester.pumpWidget(_withStreamTheme(const _LauncherScreen(customLeading: true)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // One, not two — the caller's widget replaces the default.
      expect(find.byKey(const ValueKey('custom-leading')), findsOneWidget);
      expect(find.byType(StreamButton), findsNothing);
    });

    testWidgets('automaticallyImplyLeading: false suppresses the default', (tester) async {
      await tester.pumpWidget(_withStreamTheme(const _LauncherScreen(implyLeading: false)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(StreamButton), findsNothing);
    });
  });

  group('StreamAppBar style precedence', () {
    testWidgets(
      'props.style > theme.style > token defaults (three-level merge)',
      (tester) async {
        const propsPadding = EdgeInsets.all(7);
        const themeTitleStyle = TextStyle(fontSize: 18, color: Color(0xFF112233));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: [StreamTheme()]),
            home: StreamAppBarTheme(
              data: const StreamAppBarThemeData(
                style: StreamAppBarStyle(titleTextStyle: themeTitleStyle),
              ),
              child: Scaffold(
                appBar: StreamAppBar(
                  automaticallyImplyLeading: false,
                  title: const Text('Title'),
                  subtitle: const Text('Subtitle'),
                  style: const StreamAppBarStyle(padding: propsPadding),
                ),
              ),
            ),
          ),
        );

        // Props win for padding (the bar passes its resolved padding through
        // to the [StreamHeaderToolbar]'s `padding` property).
        final toolbar = tester.widget<StreamHeaderToolbar>(
          find.descendant(
            of: find.byType(StreamAppBar),
            matching: find.byType(StreamHeaderToolbar),
          ),
        );
        expect(toolbar.padding, equals(propsPadding));

        // Theme wins for titleTextStyle (props didn't set it).
        final titleStyle = tester
            .widget<DefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text('Title'),
                    matching: find.byType(DefaultTextStyle),
                  )
                  .first,
            )
            .style;
        expect(titleStyle.fontSize, equals(themeTitleStyle.fontSize));
        expect(titleStyle.color, equals(themeTitleStyle.color));

        // Subtitle falls through to defaults (neither props nor theme set it).
        final subtitleStyle = tester
            .widget<DefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text('Subtitle'),
                    matching: find.byType(DefaultTextStyle),
                  )
                  .first,
            )
            .style;
        expect(subtitleStyle.fontSize, isNotNull);
        expect(subtitleStyle.fontSize, greaterThan(0));
      },
    );
  });
}

class _LauncherScreen extends StatelessWidget {
  const _LauncherScreen({
    this.customLeading = false,
    this.implyLeading = true,
    this.fullscreenDialog = false,
  });

  final bool customLeading;
  final bool implyLeading;
  final bool fullscreenDialog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  fullscreenDialog: fullscreenDialog,
                  builder: (_) => Scaffold(
                    appBar: StreamAppBar(
                      automaticallyImplyLeading: implyLeading,
                      leading: customLeading
                          ? const SizedBox(key: ValueKey('custom-leading'), width: 40, height: 40)
                          : null,
                      title: const Text('Pushed'),
                    ),
                  ),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }
}
