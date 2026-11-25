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

  testWidgets('StreamContextMenuAnchor passes child to the builder', (tester) async {
    await tester.pumpWidget(
      _app(
        child: StreamContextMenuAnchor(
          menuChildren: const [],
          child: const Text('anchor child'),
          builder: (context, controller, child) => child!,
        ),
      ),
    );

    expect(find.text('anchor child'), findsOneWidget);
  });

  testWidgets('StreamContextMenuAnchor returns focus to the childFocusNode after Escape', (tester) async {
    final buttonFocusNode = FocusNode();
    addTearDown(buttonFocusNode.dispose);
    await tester.pumpWidget(_app(child: _anchor(childFocusNode: buttonFocusNode)));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Microphone'), findsNothing);
    expect(buttonFocusNode.hasFocus, isTrue);
  });

  testWidgets('StreamContextMenuAnchor keeps an enclosing MenuTheme border and maximum size off the panel', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        child: MenuTheme(
          data: const MenuThemeData(
            style: MenuStyle(
              side: WidgetStatePropertyAll(BorderSide(width: 12)),
              shape: WidgetStatePropertyAll(StadiumBorder()),
              maximumSize: WidgetStatePropertyAll(Size(600, 40)),
              visualDensity: VisualDensity(horizontal: 4, vertical: 4),
            ),
          ),
          child: _anchor(),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.getRect(_panel()), tester.getRect(find.byType(StreamContextMenu)));
    expect(tester.widget<Material>(_panel()).shape, const RoundedRectangleBorder());
  });

  testWidgets('StreamContextMenuAnchor keeps an enclosing MenuTheme minimum size off the panel', (tester) async {
    await tester.pumpWidget(
      _app(
        child: MenuTheme(
          data: const MenuThemeData(style: MenuStyle(minimumSize: WidgetStatePropertyAll(Size(0, 300)))),
          child: _anchor(),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.getRect(_panel()), tester.getRect(find.byType(StreamContextMenu)));
  });

  testWidgets('StreamContextMenuAnchor fits the menu panel inside reservedPadding', (tester) async {
    await tester.pumpWidget(
      _app(
        child: _anchor(
          labels: [for (var i = 0; i < 30; i += 1) 'Device $i'],
          reservedPadding: const EdgeInsets.symmetric(vertical: 200),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final panel = find.ancestor(of: find.byType(StreamContextMenu), matching: find.byType(SingleChildScrollView));
    expect(tester.getSize(panel).height, lessThanOrEqualTo(screenHeight - 400));
  });

  testWidgets('StreamContextMenuAnchor with consumeOutsideTap keeps the closing tap from the page', (tester) async {
    var pageTapped = false;
    await tester.pumpWidget(
      _app(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _anchor(consumeOutsideTap: true),
            const SizedBox(height: 400),
            TextButton(onPressed: () => pageTapped = true, child: const Text('page')),
          ],
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('page'));
    await tester.pumpAndSettle();

    expect(find.text('Microphone'), findsNothing);
    expect(pageTapped, isFalse);
  });

  testWidgets('StreamContextMenuAnchor rows follow an enclosing StreamContextMenuActionTheme', (tester) async {
    await tester.pumpWidget(
      _app(
        child: StreamContextMenuActionTheme(
          data: const StreamContextMenuActionThemeData(
            style: StreamContextMenuActionStyle(minimumSize: WidgetStatePropertyAll(Size(200, 44))),
          ),
          child: _anchor(),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(StreamContextMenuAction<void>).first).height, 44);
  });

  testWidgets('StreamContextMenuAnchor actionStyle wins over an enclosing StreamContextMenuActionTheme', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        child: StreamContextMenuActionTheme(
          data: const StreamContextMenuActionThemeData(
            style: StreamContextMenuActionStyle(minimumSize: WidgetStatePropertyAll(Size(200, 44))),
          ),
          child: _anchor(
            actionStyle: const StreamContextMenuActionStyle(minimumSize: WidgetStatePropertyAll(Size(200, 56))),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(StreamContextMenuAction<void>).first).height, 56);
  });

  testWidgets('StreamContextMenuAnchor rings the focused row in the focus color', (tester) async {
    await tester.pumpWidget(_app(child: _anchor()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    Focus.of(tester.element(find.text('Microphone'))).requestFocus();
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Microphone'));
    expect(_rowBorder(tester, 'Microphone').side.color, context.streamColorScheme.borderFocus);
    expect(_rowBorder(tester, 'Speaker').side, BorderSide.none);
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

// The Material that MenuAnchor draws its own panel with, around the menu.
Finder _panel() => find.ancestor(of: find.byType(StreamContextMenu), matching: find.byType(Material)).first;

OutlinedBorder _rowBorder(WidgetTester tester, String label) {
  final row = find.widgetWithText(StreamContextMenuAction<void>, label);
  final material = tester.widget<Material>(find.descendant(of: row, matching: find.byType(Material)).first);
  return material.shape! as OutlinedBorder;
}

StreamContextMenuAnchor _anchor({
  List<String> labels = const ['Microphone', 'Speaker'],
  MenuController? controller,
  FocusNode? childFocusNode,
  EdgeInsetsGeometry? reservedPadding,
  bool consumeOutsideTap = false,
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
    childFocusNode: childFocusNode,
    reservedPadding: reservedPadding,
    consumeOutsideTap: consumeOutsideTap,
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
      focusNode: childFocusNode,
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
