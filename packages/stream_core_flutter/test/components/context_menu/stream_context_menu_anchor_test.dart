import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  testWidgets('StreamContextMenuAnchor opens the menu on the anchor press', (tester) async {
    await tester.pumpWidget(_app(child: _anchor()));

    expect(find.text('Microphone'), findsNothing);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Microphone'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
  });

  testWidgets('StreamContextMenuAnchor closes the menu when an action is tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_app(child: _anchor(onTap: () => tapped = true)));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speaker'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    expect(find.text('Speaker'), findsNothing);
  });

  testWidgets('StreamContextMenuAnchor reports opening and closing', (tester) async {
    final events = <String>[];
    await tester.pumpWidget(
      _app(
        child: _anchor(
          onOpen: () => events.add('open'),
          onClose: () => events.add('close'),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speaker'));
    await tester.pumpAndSettle();

    expect(events, ['open', 'close']);
  });

  testWidgets('StreamContextMenuAnchor opens through the given controller', (tester) async {
    final controller = MenuController();
    await tester.pumpWidget(_app(child: _anchor(controller: controller)));

    controller.open();
    await tester.pumpAndSettle();

    expect(find.text('Microphone'), findsOneWidget);
  });

  testWidgets('StreamContextMenuAnchor sizes menu items to the design row', (tester) async {
    await tester.pumpWidget(_app(child: _anchor()));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // The design's `Web / Menu Item` is a 32px tall row with a 200px minimum
    // width, against the 40px and 242px plain context menu defaults.
    final row = tester.getSize(find.byType(StreamContextMenuAction<void>).first);
    expect(row.height, 32);
    expect(row.width, greaterThanOrEqualTo(200));
    expect(row.width, lessThan(242));
  });

  testWidgets('StreamContextMenuAnchor labels rows in the caption emphasis style', (tester) async {
    await tester.pumpWidget(_app(child: _anchor()));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Speaker'));
    expect(
      DefaultTextStyle.of(context).style.fontSize,
      context.streamTextTheme.captionEmphasis.fontSize,
    );
  });

  testWidgets('StreamContextMenuAnchor keeps the panel within its max width', (tester) async {
    await tester.pumpWidget(
      _app(
        child: _anchor(
          labels: const ['Studio Display Microphone (Conference Room, 4th floor, east wing)'],
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final row = tester.getSize(find.byType(StreamContextMenuAction<void>).first);
    expect(row.width, lessThanOrEqualTo(StreamContextMenuAnchor.defaultConstraints.maxWidth));
  });

  testWidgets('StreamContextMenuAnchor scrolls a menu taller than its max height', (tester) async {
    await tester.pumpWidget(
      _app(child: _anchor(labels: [for (var i = 0; i < 30; i += 1) 'Device $i'])),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final menu = tester.getSize(find.byType(StreamContextMenu));
    expect(menu.height, lessThanOrEqualTo(StreamContextMenuAnchor.defaultConstraints.maxHeight));
    expect(tester.takeException(), isNull);
  });

  // On mobile the panel's scroll view and the menu's own would both attach to
  // the PrimaryScrollController, and the panel's Scrollbar asserts on a
  // controller with more than one position.
  testWidgets('StreamContextMenuAnchor opens a scrolling menu on a mobile platform', (tester) async {
    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.iOS,
        child: _anchor(labels: [for (var i = 0; i < 30; i += 1) 'Device $i']),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Device 0'), findsOneWidget);
  });

  // MenuAnchor clips its panel to the panel's own bounds by default, which
  // cuts off the shadow the menu draws outside them: the shadow stops dead
  // along the bottom edge, and raising the elevation changes nothing.
  testWidgets('StreamContextMenuAnchor does not let the panel clip the menu shadow', (tester) async {
    await tester.pumpWidget(_app(child: _anchor()));

    expect(tester.widget<MenuAnchor>(find.byType(MenuAnchor)).clipBehavior, Clip.none);
  });

  testWidgets('StreamContextMenuAnchor hides the MenuAnchor panel behind the menu surface', (tester) async {
    await tester.pumpWidget(_app(child: _anchor()));

    expect(tester.widget<MenuAnchor>(find.byType(MenuAnchor)).style, StreamContextMenuAnchor.menuStyle);
  });

  testWidgets('StreamContextMenuAnchor passes elevation to the menu', (tester) async {
    await tester.pumpWidget(_app(child: _anchor(elevation: 0)));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.widget<StreamContextMenu>(find.byType(StreamContextMenu)).elevation, 0);
  });

  testWidgets('StreamContextMenuAnchor merges actionStyle over the design row', (tester) async {
    await tester.pumpWidget(
      _app(
        child: _anchor(
          actionStyle: const StreamContextMenuActionStyle(
            minimumSize: WidgetStatePropertyAll(Size(200, 48)),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final row = tester.getSize(find.byType(StreamContextMenuAction<void>).first);
    expect(row.height, 48);

    final context = tester.element(find.text('Speaker'));
    expect(
      DefaultTextStyle.of(context).style.fontSize,
      context.streamTextTheme.captionEmphasis.fontSize,
    );
  });

  testWidgets('StreamContextMenuAnchor gives a tight width priority over the row minimum', (tester) async {
    await tester.pumpWidget(
      _app(
        child: _anchor(
          constraints: StreamContextMenuAnchor.defaultConstraints.copyWith(minWidth: 150, maxWidth: 150),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(StreamContextMenu)).width, 150);
  });

  testWidgets('StreamContextMenuAnchor offsets the menu by alignmentOffset', (tester) async {
    await tester.pumpWidget(_app(child: _anchor(alignmentOffset: const Offset(0, 8))));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final anchor = tester.getRect(find.widgetWithText(TextButton, 'open'));
    final menu = tester.getRect(find.byType(StreamContextMenu));
    expect(menu.top - anchor.bottom, 8);
  });

  testWidgets('StreamContextMenuAnchor in a dialog closes only the menu on Escape', (tester) async {
    await tester.pumpWidget(
      _app(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => Dialog(child: _anchor()),
            ),
            child: const Text('show dialog'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('show dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Microphone'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Microphone'), findsNothing);
    expect(find.byType(Dialog), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('StreamContextMenuAnchor defers to a StreamComponentFactory builder', (tester) async {
    await tester.pumpWidget(
      _app(
        child: StreamComponentFactory(
          builders: StreamComponentBuilders(
            contextMenuAnchor: (context, props) => Text('custom ${props.menuChildren.length}'),
          ),
          child: _anchor(),
        ),
      ),
    );

    expect(find.text('custom 2'), findsOneWidget);
    expect(find.byType(DefaultStreamContextMenuAnchor), findsNothing);
  });
}

StreamContextMenuAnchor _anchor({
  List<String> labels = const ['Microphone', 'Speaker'],
  MenuController? controller,
  BoxConstraints? constraints,
  Offset? alignmentOffset,
  StreamContextMenuActionStyle? actionStyle,
  double? elevation,
  VoidCallback? onTap,
  VoidCallback? onOpen,
  VoidCallback? onClose,
}) {
  return StreamContextMenuAnchor(
    controller: controller,
    constraints: constraints,
    alignmentOffset: alignmentOffset,
    actionStyle: actionStyle,
    elevation: elevation,
    onOpen: onOpen,
    onClose: onClose,
    menuChildren: [
      for (final label in labels)
        StreamContextMenuAction<void>(
          onTap: onTap ?? () {},
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
    ],
    builder: (context, controller, child) => TextButton(
      onPressed: controller.open,
      child: const Text('open'),
    ),
  );
}

// The anchor sits top-left with loose constraints, so the menu below it has
// room to open and its size is its own.
Widget _app({required Widget child, TargetPlatform platform = TargetPlatform.macOS}) {
  return MaterialApp(
    theme: ThemeData(platform: platform, extensions: [StreamTheme()]),
    home: Scaffold(
      body: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
}
