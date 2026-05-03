import 'dart:async';

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
  group('StreamSheetHeader auto-implied leading', () {
    testWidgets('does nothing when route cannot pop', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Scaffold(body: StreamSheetHeader(title: const Text('Title'))),
        ),
      );

      // Root route of MaterialApp — canPop() is false, so no close button.
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

    testWidgets('inserts cross icon inside a modal bottom sheet', (tester) async {
      await tester.pumpWidget(_withStreamTheme(const _SheetLauncher()));
      await tester.tap(find.text('Open sheet'));
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

    testWidgets(
      'inserts cross icon at the root of a StreamSheetRoute',
      (tester) async {
        await tester.pumpWidget(_withStreamTheme(const _StreamSheetLauncher()));
        await tester.tap(find.text('Open stream sheet'));
        await tester.pumpAndSettle();

        expect(find.byIcon(StreamIconData.xmark), findsOneWidget);
        expect(find.byIcon(StreamIconData.chevronLeft), findsNothing);
      },
    );

    testWidgets(
      'inserts back chevron when a StreamSheetRoute covers another sheet',
      (tester) async {
        await tester.pumpWidget(_withStreamTheme(const _StreamSheetLauncher()));
        await tester.tap(find.text('Open stream sheet'));
        await tester.pumpAndSettle();

        // Open a second sheet from inside the first.
        final firstHeaderContext = tester.element(find.text('Sheet'));
        unawaited(
          showStreamSheet<void>(
            context: firstHeaderContext,
            builder: (_, _) => Scaffold(
              body: StreamSheetHeader(title: const Text('Stacked')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Both sheets are mounted; scope assertions to the stacked sheet.
        expect(find.text('Stacked'), findsOneWidget);
        final stackedHeader = find.ancestor(
          of: find.text('Stacked'),
          matching: find.byType(StreamSheetHeader),
        );
        expect(
          find.descendant(
            of: stackedHeader,
            matching: find.byIcon(StreamIconData.chevronLeft),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: stackedHeader,
            matching: find.byIcon(StreamIconData.xmark),
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'inserts cross at first nested route inside a StreamSheetRoute and '
      'back chevron at deeper nested routes',
      (tester) async {
        await tester.pumpWidget(
          _withStreamTheme(const _StreamSheetLauncher(useNestedNavigation: true)),
        );
        await tester.tap(find.text('Open stream sheet'));
        await tester.pumpAndSettle();

        // First nested route: cross (closes whole sheet).
        expect(find.byIcon(StreamIconData.xmark), findsOneWidget);
        expect(find.byIcon(StreamIconData.chevronLeft), findsNothing);

        await tester.tap(find.text('Push deeper'));
        await tester.pumpAndSettle();

        // Deeper nested route: back chevron.
        expect(find.byIcon(StreamIconData.chevronLeft), findsOneWidget);
        expect(find.byIcon(StreamIconData.xmark), findsNothing);
      },
    );

    testWidgets(
      'inserts back chevron on the first nested route of a stacked sheet '
      '(stacked + nested combo)',
      (tester) async {
        await tester.pumpWidget(
          _withStreamTheme(const _StreamSheetLauncher()),
        );
        await tester.tap(find.text('Open stream sheet'));
        await tester.pumpAndSettle();

        // From inside the first sheet, push a stacked sheet that itself
        // uses nested navigation. The stacked sheet's first nested
        // route should show a back chevron (popping reveals the parent
        // sheet) — *not* a cross.
        final firstHeaderContext = tester.element(find.text('Sheet'));
        unawaited(
          showStreamSheet<void>(
            context: firstHeaderContext,
            useNestedNavigation: true,
            builder: (_, _) => Scaffold(
              body: StreamSheetHeader(title: const Text('Stacked')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Stacked'), findsOneWidget);
        final stackedHeader = find.ancestor(
          of: find.text('Stacked'),
          matching: find.byType(StreamSheetHeader),
        );
        expect(
          find.descendant(
            of: stackedHeader,
            matching: find.byIcon(StreamIconData.chevronLeft),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: stackedHeader,
            matching: find.byIcon(StreamIconData.xmark),
          ),
          findsNothing,
        );
      },
    );
  });

  group('StreamSheetHeader tap actions', () {
    testWidgets(
      'tapping the cross on a standalone StreamSheetRoute pops the sheet',
      (tester) async {
        await tester.pumpWidget(_withStreamTheme(const _StreamSheetLauncher()));
        await tester.tap(find.text('Open stream sheet'));
        await tester.pumpAndSettle();
        expect(find.text('Sheet'), findsOneWidget);

        await tester.tap(find.byIcon(StreamIconData.xmark));
        await tester.pumpAndSettle();

        expect(find.text('Sheet'), findsNothing);
        expect(find.text('Open stream sheet'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping the chevron on a stacked StreamSheetRoute pops only itself; '
      'parent sheet stays mounted',
      (tester) async {
        await tester.pumpWidget(_withStreamTheme(const _StreamSheetLauncher()));
        await tester.tap(find.text('Open stream sheet'));
        await tester.pumpAndSettle();

        final firstHeaderContext = tester.element(find.text('Sheet'));
        unawaited(
          showStreamSheet<void>(
            context: firstHeaderContext,
            builder: (_, _) => Scaffold(
              body: StreamSheetHeader(title: const Text('Stacked')),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Stacked'), findsOneWidget);
        expect(find.text('Sheet'), findsOneWidget);

        // Tap the chevron on the stacked sheet's header.
        final stackedHeader = find.ancestor(
          of: find.text('Stacked'),
          matching: find.byType(StreamSheetHeader),
        );
        await tester.tap(
          find.descendant(
            of: stackedHeader,
            matching: find.byIcon(StreamIconData.chevronLeft),
          ),
        );
        await tester.pumpAndSettle();

        // Only the stacked sheet popped — the parent sheet is still mounted.
        expect(find.text('Stacked'), findsNothing);
        expect(find.text('Sheet'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping the chevron on a deeper nested route pops only that '
      'nested level; the sheet stays mounted',
      (tester) async {
        await tester.pumpWidget(
          _withStreamTheme(const _StreamSheetLauncher(useNestedNavigation: true)),
        );
        await tester.tap(find.text('Open stream sheet'));
        await tester.pumpAndSettle();
        expect(find.text('Sheet'), findsOneWidget);

        await tester.tap(find.text('Push deeper'));
        await tester.pumpAndSettle();
        expect(find.text('Deeper'), findsOneWidget);

        // Tap chevron on the deeper route's header.
        await tester.tap(find.byIcon(StreamIconData.chevronLeft));
        await tester.pumpAndSettle();

        // Only the deeper route popped — the sheet's first nested route
        // (with the cross) is back. The cross icon is now the only one
        // showing; the chevron from the deeper route is gone.
        expect(find.text('Deeper'), findsNothing);
        expect(find.text('Sheet'), findsOneWidget);
        expect(find.byIcon(StreamIconData.xmark), findsOneWidget);
      },
    );

    testWidgets(
      'tapping the chevron on the first nested route of a stacked sheet '
      'pops the entire stacked sheet (not just the nested route)',
      (tester) async {
        await tester.pumpWidget(_withStreamTheme(const _StreamSheetLauncher()));
        await tester.tap(find.text('Open stream sheet'));
        await tester.pumpAndSettle();

        final firstHeaderContext = tester.element(find.text('Sheet'));
        unawaited(
          showStreamSheet<void>(
            context: firstHeaderContext,
            useNestedNavigation: true,
            builder: (_, _) => Scaffold(
              body: StreamSheetHeader(title: const Text('Stacked')),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Stacked'), findsOneWidget);

        final stackedHeader = find.ancestor(
          of: find.text('Stacked'),
          matching: find.byType(StreamSheetHeader),
        );
        await tester.tap(
          find.descendant(
            of: stackedHeader,
            matching: find.byIcon(StreamIconData.chevronLeft),
          ),
        );
        await tester.pumpAndSettle();

        // The whole stacked sheet popped — parent sheet still mounted.
        expect(find.text('Stacked'), findsNothing);
        expect(find.text('Sheet'), findsOneWidget);
      },
    );
  });

  group('StreamSheetHeader style precedence', () {
    testWidgets(
      'props.style > theme.style > token defaults (three-level merge)',
      (tester) async {
        const propsPadding = EdgeInsets.all(7);
        const themeTitleStyle = TextStyle(fontSize: 99, color: Color(0xFF112233));

        // Theme provides only `titleTextStyle`. Props provide only
        // `padding`. Other fields must fall through to token defaults.
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: [StreamTheme()]),
            home: StreamSheetHeaderTheme(
              data: const StreamSheetHeaderThemeData(
                style: StreamSheetHeaderStyle(titleTextStyle: themeTitleStyle),
              ),
              child: Scaffold(
                body: StreamSheetHeader(
                  // Skip the SafeArea wrap so the inner Padding is the
                  // first one under the header — makes the assertion
                  // below straightforward.
                  primary: false,
                  automaticallyImplyLeading: false,
                  title: const Text('Title'),
                  subtitle: const Text('Subtitle'),
                  style: const StreamSheetHeaderStyle(padding: propsPadding),
                ),
              ),
            ),
          ),
        );

        // Props win for padding.
        final padding = tester.widget<Padding>(
          find
              .descendant(
                of: find.byType(StreamSheetHeader),
                matching: find.byType(Padding),
              )
              .first,
        );
        expect(padding.padding, equals(propsPadding));

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
        // Default subtitleTextStyle uses StreamTextTheme's captionDefault and
        // colorScheme.textTertiary — non-null, non-zero font size.
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

class _StreamSheetLauncher extends StatelessWidget {
  const _StreamSheetLauncher({this.useNestedNavigation = false});

  final bool useNestedNavigation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              showStreamSheet<void>(
                context: context,
                useNestedNavigation: useNestedNavigation,
                builder: (sheetContext, _) => Scaffold(
                  body: Column(
                    children: [
                      StreamSheetHeader(title: const Text('Sheet')),
                      Expanded(
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(sheetContext).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => Scaffold(
                                    body: StreamSheetHeader(
                                      title: const Text('Deeper'),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: const Text('Push deeper'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text('Open stream sheet'),
          ),
        ),
      ),
    );
  }
}

class _SheetLauncher extends StatelessWidget {
  const _SheetLauncher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (_) => StreamSheetHeader(title: const Text('Sheet')),
              );
            },
            child: const Text('Open sheet'),
          ),
        ),
      ),
    );
  }
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
                    body: StreamSheetHeader(
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
