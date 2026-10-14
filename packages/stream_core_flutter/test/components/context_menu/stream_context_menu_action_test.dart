import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  /// Opens a dialog showing [content], and returns what the dialog popped with.
  Future<List<Object?>> openDialog(
    WidgetTester tester, {
    required Widget content,
  }) async {
    final results = <Object?>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              results.add(
                await showDialog<String>(
                  context: context,
                  builder: (_) => Center(child: content),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  group('StreamContextMenuAction', () {
    testWidgets('pops the popup route it is shown in with its value', (
      tester,
    ) async {
      var tapped = false;
      final results = await openDialog(
        tester,
        content: StreamContextMenu(
          children: [
            StreamContextMenuAction(
              value: 'reply',
              label: const Text('Reply'),
              onTap: () => tapped = true,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Reply'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      expect(results, ['reply']);
      expect(find.text('Reply'), findsNothing);
    });

    testWidgets('leaves the popup route open in a menu that does not dismiss it', (
      tester,
    ) async {
      var tapped = false;
      final results = await openDialog(
        tester,
        content: StreamContextMenu(
          dismissesRoute: false,
          children: [
            StreamContextMenuAction(
              value: 'reply',
              label: const Text('Reply'),
              onTap: () => tapped = true,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Reply'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      expect(results, isEmpty);
      expect(find.text('Reply'), findsOneWidget);
    });

    testWidgets('only calls onTap outside a popup route', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme()]),
          home: Scaffold(
            body: StreamContextMenu(
              children: [
                StreamContextMenuAction<void>(
                  label: const Text('Reply'),
                  onTap: () => tapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reply'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      expect(find.text('Reply'), findsOneWidget);
    });
  });
}
