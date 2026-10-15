import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  /// Opens a dialog showing [content]. The returned list receives what the
  /// dialog popped with once it closes.
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

  /// A dialog's content: a [MenuAnchor] that opens [menu] in an overlay.
  ///
  /// The anchor's panel scrolls too, so the menu gets no primary scroll
  /// controller of its own.
  Widget anchorFor(StreamContextMenu menu) => Material(
    child: MenuAnchor(
      menuChildren: [PrimaryScrollController.none(child: menu)],
      builder: (context, controller, _) => TextButton(
        onPressed: controller.open,
        child: const Text('anchor'),
      ),
    ),
  );

  testWidgets('StreamContextMenuAction pops the popup route it is shown in with its value', (
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

  testWidgets('StreamContextMenuAction outside a StreamContextMenu pops the popup route', (
    tester,
  ) async {
    final results = await openDialog(
      tester,
      content: Material(
        child: StreamContextMenuAction(
          value: 'reply',
          label: const Text('Reply'),
        ),
      ),
    );

    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(results, ['reply']);
  });

  testWidgets('StreamContextMenuAction in an anchored menu leaves the dialog open when it does not dismiss', (
    tester,
  ) async {
    var tapped = false;
    final results = await openDialog(
      tester,
      content: anchorFor(
        StreamContextMenu(
          dismissesRoute: false,
          children: [
            StreamContextMenuAction(
              value: 'reply',
              label: const Text('Reply'),
              onTap: () => tapped = true,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('anchor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    expect(results, isEmpty);
    expect(find.text('anchor'), findsOneWidget);
  });

  testWidgets('StreamContextMenuAction in an anchored menu pops the dialog by default', (
    tester,
  ) async {
    final results = await openDialog(
      tester,
      content: anchorFor(
        StreamContextMenu(
          children: [
            StreamContextMenuAction(
              value: 'reply',
              label: const Text('Reply'),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('anchor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(results, ['reply']);
    expect(find.text('anchor'), findsNothing);
  });

  testWidgets('StreamContextMenuAction only calls onTap outside a popup route', (
    tester,
  ) async {
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
}
