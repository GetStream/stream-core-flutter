import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('StreamContextMenuAction pops the popup route it is shown in with its value', (
    tester,
  ) async {
    var tapped = false;
    final results = await _openDialog(
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

  testWidgets('StreamContextMenuAction in an anchored menu closes the menu and leaves the dialog open', (
    tester,
  ) async {
    var tapped = false;
    final results = await _openDialog(
      tester,
      content: _anchorFor(
        StreamContextMenuAction(
          value: 'reply',
          label: const Text('Reply'),
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.text('anchor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    expect(find.text('Reply'), findsNothing);
    expect(find.text('anchor'), findsOneWidget);
    expect(results, isEmpty);
  });

  testWidgets('StreamContextMenuAction with closeOnActivate false leaves the menu open', (
    tester,
  ) async {
    var tapped = false;
    final results = await _openDialog(
      tester,
      content: _anchorFor(
        StreamContextMenuAction(
          value: 'reply',
          label: const Text('Reply'),
          closeOnActivate: false,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.text('anchor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    expect(find.text('Reply'), findsOneWidget);
    expect(results, isEmpty);
  });

  testWidgets('StreamContextMenuAction in a dialog inside a closed MenuAnchor still pops the dialog', (
    tester,
  ) async {
    final results = <Object?>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: MenuAnchor(
          menuChildren: const [Text('item')],
          // A navigator inside the anchor, so the dialog is in the anchor's
          // subtree and sees its controller.
          builder: (context, controller, _) => Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => TextButton(
                onPressed: () async {
                  results.add(
                    await showDialog<String>(
                      context: context,
                      useRootNavigator: false,
                      builder: (_) => Center(
                        child: StreamContextMenu(
                          children: [
                            StreamContextMenuAction(
                              value: 'reply',
                              label: const Text('Reply'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(results, ['reply']);
    expect(find.text('Reply'), findsNothing);
  });

  testWidgets('StreamContextMenuAction calls onTap after the route is popped', (
    tester,
  ) async {
    final events = <String>[];
    await _openDialog(
      tester,
      observer: _PopObserver(() => events.add('pop')),
      content: StreamContextMenu(
        children: [
          StreamContextMenuAction(
            value: 'reply',
            label: const Text('Reply'),
            onTap: () => events.add('tap'),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(events, ['pop', 'tap']);
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

/// Opens a dialog showing [content]. The returned list receives what the
/// dialog popped with once it closes.
Future<List<Object?>> _openDialog(
  WidgetTester tester, {
  required Widget content,
  NavigatorObserver? observer,
}) async {
  final results = <Object?>[];
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [StreamTheme()]),
      navigatorObservers: [?observer],
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

/// A dialog's content: a [MenuAnchor] that opens a [StreamContextMenu] of
/// [action] in an overlay.
///
/// The anchor's panel scrolls too, so the menu gets no primary scroll
/// controller of its own.
Widget _anchorFor(Widget action) => Material(
  child: MenuAnchor(
    menuChildren: [
      PrimaryScrollController.none(
        child: StreamContextMenu(children: [action]),
      ),
    ],
    builder: (context, controller, _) => TextButton(
      onPressed: controller.open,
      child: const Text('anchor'),
    ),
  ),
);

/// Calls [onPop] whenever a route is popped.
class _PopObserver extends NavigatorObserver {
  _PopObserver(this.onPop);

  final VoidCallback onPop;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => onPop();
}
