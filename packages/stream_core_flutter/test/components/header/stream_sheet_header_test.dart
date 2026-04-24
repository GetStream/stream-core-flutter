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

    testWidgets('inserts back chevron on a regular pushed route', (tester) async {
      await tester.pumpWidget(_withStreamTheme(const _LauncherScreen()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(StreamButton), findsOneWidget);
      expect(find.byIcon(StreamIconData.chevronLeft), findsOneWidget);
      expect(find.byIcon(StreamIconData.xmark), findsNothing);
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
  });
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
