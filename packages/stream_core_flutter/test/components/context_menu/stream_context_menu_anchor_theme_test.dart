import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  testWidgets('StreamContextMenuAnchorTheme constraints bound the panel', (tester) async {
    await tester.pumpWidget(
      _app(
        child: StreamContextMenuAnchorTheme(
          data: const StreamContextMenuAnchorThemeData(
            constraints: BoxConstraints.tightFor(width: 260),
          ),
          child: _anchor(),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(StreamContextMenu)).width, 260);
  });

  testWidgets('StreamContextMenuAnchor constraints win over the theme', (tester) async {
    await tester.pumpWidget(
      _app(
        child: StreamContextMenuAnchorTheme(
          data: const StreamContextMenuAnchorThemeData(
            constraints: BoxConstraints.tightFor(width: 260),
          ),
          child: _anchor(constraints: const BoxConstraints.tightFor(width: 220)),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(StreamContextMenu)).width, 220);
  });

  testWidgets('StreamContextMenuAnchorTheme alignmentOffset offsets the menu', (tester) async {
    await tester.pumpWidget(
      _app(
        child: StreamContextMenuAnchorTheme(
          data: const StreamContextMenuAnchorThemeData(alignmentOffset: Offset(0, 12)),
          child: _anchor(),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(_gapBelowAnchor(tester), 12);
  });

  testWidgets('StreamContextMenuAnchor alignmentOffset wins over the theme', (tester) async {
    await tester.pumpWidget(
      _app(
        child: StreamContextMenuAnchorTheme(
          data: const StreamContextMenuAnchorThemeData(alignmentOffset: Offset(0, 12)),
          child: _anchor(alignmentOffset: const Offset(0, 4)),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(_gapBelowAnchor(tester), 4);
  });

  testWidgets('StreamContextMenuAnchorTheme actionStyle is merged over the design row', (tester) async {
    await tester.pumpWidget(
      _app(
        child: StreamContextMenuAnchorTheme(
          data: const StreamContextMenuAnchorThemeData(
            actionStyle: StreamContextMenuActionStyle(
              minimumSize: WidgetStatePropertyAll(Size(200, 44)),
            ),
          ),
          child: _anchor(),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(StreamContextMenuAction<void>).first).height, 44);

    final context = tester.element(find.text('Speaker'));
    expect(
      DefaultTextStyle.of(context).style.fontSize,
      context.streamTextTheme.captionEmphasis.fontSize,
    );
  });

  testWidgets('StreamContextMenuAnchor actionStyle wins over the theme', (tester) async {
    await tester.pumpWidget(
      _app(
        child: StreamContextMenuAnchorTheme(
          data: const StreamContextMenuAnchorThemeData(
            actionStyle: StreamContextMenuActionStyle(
              minimumSize: WidgetStatePropertyAll(Size(200, 44)),
            ),
          ),
          child: _anchor(
            actionStyle: const StreamContextMenuActionStyle(
              minimumSize: WidgetStatePropertyAll(Size(200, 56)),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(StreamContextMenuAction<void>).first).height, 56);
  });

  testWidgets('StreamContextMenuAnchor.defaultActionStyle carries the theme actionStyle', (tester) async {
    const themeSize = WidgetStatePropertyAll(Size(200, 44));
    late StreamContextMenuActionStyle style;

    await tester.pumpWidget(
      _app(
        child: StreamContextMenuAnchorTheme(
          data: const StreamContextMenuAnchorThemeData(
            actionStyle: StreamContextMenuActionStyle(minimumSize: themeSize),
          ),
          child: Builder(
            builder: (context) {
              style = StreamContextMenuAnchor.defaultActionStyle(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(style.minimumSize, themeSize);
    expect(style.iconSize?.resolve({}), 16);
  });

  testWidgets('StreamTheme contextMenuAnchorTheme applies app-wide', (tester) async {
    await tester.pumpWidget(
      _app(
        streamTheme: StreamTheme(
          contextMenuAnchorTheme: const StreamContextMenuAnchorThemeData(alignmentOffset: Offset(0, 6)),
        ),
        child: _anchor(),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(_gapBelowAnchor(tester), 6);
  });

  // Elevation belongs to the menu surface, so it is themed once, through
  // StreamContextMenuTheme, for anchored and inline menus alike.
  testWidgets('StreamContextMenuTheme elevation reaches the anchored menu', (tester) async {
    await tester.pumpWidget(
      _app(
        child: StreamContextMenuTheme(
          data: const StreamContextMenuThemeData(style: StreamContextMenuStyle(elevation: 8)),
          child: _anchor(),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final material = tester.widget<Material>(
      find.descendant(of: find.byType(StreamContextMenu), matching: find.byType(Material)).first,
    );
    expect(material.elevation, 8);
  });
}

double _gapBelowAnchor(WidgetTester tester) {
  final anchor = tester.getRect(find.widgetWithText(TextButton, 'open'));
  final menu = tester.getRect(find.byType(StreamContextMenu));
  return menu.top - anchor.bottom;
}

StreamContextMenuAnchor _anchor({
  BoxConstraints? constraints,
  Offset? alignmentOffset,
  StreamContextMenuActionStyle? actionStyle,
}) {
  return StreamContextMenuAnchor(
    constraints: constraints,
    alignmentOffset: alignmentOffset,
    actionStyle: actionStyle,
    menuChildren: [
      StreamContextMenuAction<void>(onTap: () {}, label: const Text('Microphone')),
      StreamContextMenuAction<void>(onTap: () {}, label: const Text('Speaker')),
    ],
    builder: (context, controller, child) => TextButton(
      onPressed: controller.open,
      child: const Text('open'),
    ),
  );
}

Widget _app({required Widget child, StreamTheme? streamTheme}) {
  return MaterialApp(
    theme: ThemeData(platform: TargetPlatform.macOS, extensions: [streamTheme ?? StreamTheme()]),
    home: Scaffold(
      body: Align(alignment: Alignment.topLeft, child: child),
    ),
  );
}
