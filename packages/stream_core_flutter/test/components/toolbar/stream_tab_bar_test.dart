import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

Widget _withStreamTheme(Widget child, {StreamTheme? streamTheme}) {
  return MaterialApp(
    theme: ThemeData(extensions: [streamTheme ?? StreamTheme()]),
    home: Scaffold(
      body: Center(child: SizedBox(width: 400, child: child)),
    ),
  );
}

StreamTabBar _tabBar({
  int? selectedIndex = 0,
  ValueChanged<int>? onTap,
  Widget? icon,
  bool windowEnabled = true,
}) {
  return StreamTabBar(
    selectedIndex: selectedIndex,
    onTap: onTap ?? (_) {},
    tabs: [
      StreamTabBarItem(label: 'Entire Screen', icon: icon),
      StreamTabBarItem(label: 'Window', enabled: windowEnabled),
    ],
  );
}

Color _labelColorOf(WidgetTester tester, String label) => tester.widget<Text>(find.text(label)).style!.color!;

Finder _tab(String label) => find.ancestor(of: find.text(label), matching: find.byType(InkWell));

// The underline below the selected tab.
Finder get _indicator => find.descendant(of: find.byType(AnimatedAlign), matching: find.byType(ColoredBox));

Color _indicatorColorOf(WidgetTester tester) => tester.widget<ColoredBox>(_indicator).color;

// Whether the underline spans the tab whose label is [label].
void _expectIndicatorUnder(WidgetTester tester, String label) {
  final indicator = tester.getRect(_indicator);
  final tab = tester.getRect(_tab(label));
  expect(indicator.left, tab.left);
  expect(indicator.right, tab.right);
}

// The divider along the bottom of the whole bar.
BorderSide _dividerOf(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(DefaultStreamTabBar),
          matching: find.byWidgetPredicate((widget) => widget is DecoratedBox && widget.decoration is BoxDecoration),
        )
        .first,
  );
  return ((box.decoration as BoxDecoration).border! as Border).bottom;
}

// The pill drawn over the tab whose label is [label] while it is hovered, pressed or focused.
Finder _overlay(String label) => find.descendant(
  of: _tab(label),
  matching: find.byWidgetPredicate((widget) => widget is DecoratedBox && widget.decoration is ShapeDecoration),
);

ShapeDecoration _overlayOf(WidgetTester tester, String label) {
  return tester.widget<DecoratedBox>(_overlay(label)).decoration as ShapeDecoration;
}

BorderSide _overlaySideOf(WidgetTester tester, String label) => (_overlayOf(tester, label).shape as StadiumBorder).side;

Future<void> _hover(WidgetTester tester, String label) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: tester.getCenter(find.text(label)));
  addTearDown(gesture.removePointer);
  await tester.pumpAndSettle();
}

StreamColorScheme _colorSchemeOf(WidgetTester tester) {
  return StreamTheme.of(tester.element(find.byType(StreamTabBar))).colorScheme;
}

void main() {
  testWidgets('marks the selected tab with the accent color', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar()));

    final colorScheme = _colorSchemeOf(tester);
    expect(_labelColorOf(tester, 'Entire Screen'), colorScheme.accentPrimary);
    expect(_labelColorOf(tester, 'Window'), colorScheme.textSecondary);
  });

  testWidgets('underlines only the selected tab, over the divider', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar(selectedIndex: 1)));

    final colorScheme = _colorSchemeOf(tester);
    expect(_indicatorColorOf(tester), colorScheme.accentPrimary);
    expect(tester.getSize(_indicator).height, 2);
    expect(tester.getRect(_indicator).bottom, tester.getRect(find.byType(StreamTabBar)).bottom);
    expect(_indicator, findsOneWidget);
    _expectIndicatorUnder(tester, 'Window');
    expect(_dividerOf(tester), BorderSide(color: colorScheme.borderDefault));
  });

  testWidgets('applies the theme divider', (tester) async {
    const dividerColor = Color(0xFF0000FF);
    await tester.pumpWidget(
      _withStreamTheme(
        streamTheme: StreamTheme(
          tabBarTheme: const StreamTabBarThemeData(dividerColor: dividerColor, dividerHeight: 3),
        ),
        _tabBar(),
      ),
    );

    expect(_dividerOf(tester), const BorderSide(color: dividerColor, width: 3));
  });

  testWidgets('tints the icon with the label color', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar(icon: const Icon(Icons.monitor))));

    final iconTheme = IconTheme.of(tester.element(find.byIcon(Icons.monitor)));
    expect(iconTheme.color, _colorSchemeOf(tester).accentPrimary);
  });

  testWidgets('reports the index of the tapped tab', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(_withStreamTheme(_tabBar(onTap: tapped.add)));

    await tester.tap(find.text('Window'));
    await tester.pumpAndSettle();

    expect(tapped, [1]);
  });

  testWidgets('reports the tab that is already selected too', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(_withStreamTheme(_tabBar(onTap: tapped.add)));

    await tester.tap(find.text('Entire Screen'));
    await tester.pumpAndSettle();

    expect(tapped, [0]);
  });

  testWidgets('gives every tab an equal share of the width', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar()));

    Rect tabRect(String label) => tester.getRect(find.ancestor(of: find.text(label), matching: find.byType(InkWell)));
    expect(tabRect('Entire Screen').width, 200);
    expect(tabRect('Window').width, 200);
    expect(tabRect('Window').left, tabRect('Entire Screen').right);
  });

  testWidgets('leaves every tab unselected without a selected index', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_withStreamTheme(_tabBar(selectedIndex: null)));

    final colorScheme = _colorSchemeOf(tester);
    for (final label in ['Entire Screen', 'Window']) {
      expect(_labelColorOf(tester, label), colorScheme.textSecondary);
      expect(tester.semantics.find(find.text(label)), isSemantics(hasSelectedState: true, isSelected: false));
    }
    expect(_indicator, findsNothing);
    handle.dispose();
  });

  test('rejects empty tabs and a selected index outside them', () {
    void onTap(int _) {}
    const tabs = [StreamTabBarItem(label: 'Only')];

    expect(() => StreamTabBarProps(tabs: const [], onTap: onTap), throwsAssertionError);
    expect(() => StreamTabBarProps(tabs: tabs, selectedIndex: 1, onTap: onTap), throwsAssertionError);
    expect(() => StreamTabBarProps(tabs: tabs, selectedIndex: -1, onTap: onTap), throwsAssertionError);
  });

  testWidgets('draws a disabled tab in the disabled colors and ignores taps on it', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(_withStreamTheme(_tabBar(onTap: tapped.add, windowEnabled: false)));

    expect(_labelColorOf(tester, 'Window'), _colorSchemeOf(tester).textDisabled);
    _expectIndicatorUnder(tester, 'Entire Screen');

    await tester.tap(find.text('Window'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(tapped, isEmpty);
  });

  testWidgets('underlines a selected disabled tab in the disabled border color', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar(selectedIndex: 1, windowEnabled: false)));

    expect(_indicatorColorOf(tester), _colorSchemeOf(tester).borderDisabled);
  });

  testWidgets('announces a disabled tab and skips it with the keyboard', (tester) async {
    final handle = tester.ensureSemantics();
    final tapped = <int>[];
    await tester.pumpWidget(_withStreamTheme(_tabBar(onTap: tapped.add, windowEnabled: false)));

    expect(
      tester.semantics.find(find.text('Window')),
      isSemantics(role: SemanticsRole.tab, hasEnabledState: true, isEnabled: false, hasTapAction: false),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Entire Screen'))).hasPrimaryFocus, isTrue);

    // The next stop wraps back to the first tab, passing over the disabled one.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Window'))).hasFocus, isFalse);
    expect(Focus.of(tester.element(find.text('Entire Screen'))).hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(tapped, [0]);
    handle.dispose();
  });

  testWidgets('centers the label vertically in the tab', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar()));

    expect(tester.getCenter(find.text('Window')).dy, tester.getCenter(_tab('Window')).dy);
  });

  testWidgets('gives every tab the height of the tallest one', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        Column(children: [_tabBar(icon: const SizedBox(width: 16, height: 80))]),
      ),
    );

    Rect tabRect(String label) => tester.getRect(find.ancestor(of: find.text(label), matching: find.byType(InkWell)));
    expect(tabRect('Entire Screen').height, greaterThan(80));
    expect(tabRect('Window').height, tabRect('Entire Screen').height);
    expect(tabRect('Window').bottom, tabRect('Entire Screen').bottom);
  });

  testWidgets('lays out an icon that cannot report its intrinsic size', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        _tabBar(icon: LayoutBuilder(builder: (context, constraints) => const SizedBox.square(dimension: 16))),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(StreamTabBar)).height, 48);
  });

  testWidgets('grows past its height when the text is scaled up', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(4)),
          child: _tabBar(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(StreamTabBar)).height, greaterThan(48));
  });

  testWidgets('grows when the text scale changes after the first layout', (tester) async {
    Widget scaled(double scale) => _withStreamTheme(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: _tabBar(),
      ),
    );

    await tester.pumpWidget(scaled(1));
    expect(tester.getSize(find.byType(StreamTabBar)).height, 48);

    await tester.pumpWidget(scaled(4));
    final grown = tester.getSize(find.byType(StreamTabBar)).height;
    expect(grown, greaterThan(48));
    expect(
      tester.getRect(find.text('Window')).bottom,
      lessThanOrEqualTo(tester.getRect(find.byType(StreamTabBar)).bottom),
    );

    await tester.pumpWidget(scaled(1));
    expect(tester.getSize(find.byType(StreamTabBar)).height, 48, reason: 'it shrinks back too');
  });

  testWidgets('lays the icon out after the label in RTL', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        Directionality(
          textDirection: TextDirection.rtl,
          child: _tabBar(icon: const Icon(Icons.monitor)),
        ),
      ),
    );

    expect(
      tester.getCenter(find.byIcon(Icons.monitor)).dx,
      greaterThan(tester.getCenter(find.text('Entire Screen')).dx),
    );
  });

  testWidgets('announces a tab bar of tabs with their selected state', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_withStreamTheme(_tabBar()));

    expect(tester.takeException(), isNull, reason: 'the tab and tab bar roles are configured correctly');
    expect(
      tester.semantics.find(find.byType(DefaultStreamTabBar)),
      isSemantics(role: SemanticsRole.tabBar),
    );
    expect(
      tester.semantics.find(find.text('Entire Screen')),
      isSemantics(
        role: SemanticsRole.tab,
        label: 'Entire Screen\nTab 1 of 2',
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
        isFocusable: true,
      ),
    );
    expect(
      tester.semantics.find(find.text('Window')),
      isSemantics(
        role: SemanticsRole.tab,
        label: 'Window\nTab 2 of 2',
        hasSelectedState: true,
        isSelected: false,
        hasTapAction: true,
      ),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('selects a tab from the keyboard', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(_withStreamTheme(_tabBar(onTap: tapped.add)));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(tapped, [1]);
  });

  testWidgets('applies the tab bar theme from StreamTheme', (tester) async {
    const selected = Color(0xFF00FF00);
    const unselected = Color(0xFFFF0000);
    final bySelection = WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? selected : unselected,
    );

    await tester.pumpWidget(
      _withStreamTheme(
        streamTheme: StreamTheme(
          tabBarTheme: StreamTabBarThemeData(
            indicatorWeight: 4,
            indicatorColor: bySelection,
            labelStyle: const TextStyle(fontSize: 20),
            foregroundColor: bySelection,
          ),
        ),
        _tabBar(),
      ),
    );

    expect(tester.getSize(_indicator).height, 4);
    expect(_indicatorColorOf(tester), selected);
    expect(_labelColorOf(tester, 'Entire Screen'), selected);
    expect(_labelColorOf(tester, 'Window'), unselected);

    final labelStyle = tester.widget<Text>(find.text('Window')).style!;
    final defaultStyle = StreamTheme.of(tester.element(find.byType(StreamTabBar))).textTheme.captionEmphasis;
    expect(labelStyle.fontSize, 20);
    expect(labelStyle.fontWeight, defaultStyle.fontWeight, reason: 'the theme label style merges over the default');
  });

  testWidgets('falls back to the default color for states the theme leaves null', (tester) async {
    const selected = Color(0xFF00FF00);
    final onlySelected = WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.selected) ? selected : null,
    );

    await tester.pumpWidget(
      _withStreamTheme(
        streamTheme: StreamTheme(
          tabBarTheme: StreamTabBarThemeData(
            indicatorColor: onlySelected,
            foregroundColor: onlySelected,
            overlayColor: onlySelected,
          ),
        ),
        _tabBar(icon: const Icon(Icons.monitor), selectedIndex: 1),
      ),
    );

    final colorScheme = _colorSchemeOf(tester);
    expect(_labelColorOf(tester, 'Window'), selected);
    expect(_indicatorColorOf(tester), selected);
    expect(_labelColorOf(tester, 'Entire Screen'), colorScheme.textSecondary);
    expect(IconTheme.of(tester.element(find.byIcon(Icons.monitor))).color, colorScheme.textSecondary);

    await _hover(tester, 'Entire Screen');
    expect(_overlayOf(tester, 'Entire Screen').color, colorScheme.backgroundHover);
  });

  testWidgets('fills a pill inset from the top and bottom of a hovered tab', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar()));
    await _hover(tester, 'Window');

    final colorScheme = _colorSchemeOf(tester);
    expect(_overlayOf(tester, 'Window').color, colorScheme.backgroundHover);
    expect(_overlayOf(tester, 'Entire Screen').color, StreamColors.transparent);

    final tab = tester.getRect(_tab('Window'));
    final pill = tester.getRect(_overlay('Window'));
    expect(pill.top - tab.top, 8);
    expect(tab.bottom - pill.bottom, 8);
    expect(pill.width, tab.width);
  });

  testWidgets('fills the pill in the pressed color while a tab is pressed', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar()));

    final gesture = await tester.startGesture(tester.getCenter(find.text('Window')));
    await tester.pump(kPressTimeout);
    await tester.pump(const Duration(milliseconds: 200));
    expect(_overlayOf(tester, 'Window').color, _colorSchemeOf(tester).backgroundPressed);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_overlayOf(tester, 'Window').color, StreamColors.transparent);
  });

  testWidgets('rings a keyboard-focused tab without filling it', (tester) async {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
    await tester.pumpWidget(_withStreamTheme(_tabBar()));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final colorScheme = _colorSchemeOf(tester);
    expect(_overlaySideOf(tester, 'Entire Screen'), BorderSide(width: 2, color: colorScheme.borderFocus));
    expect(_overlayOf(tester, 'Entire Screen').color, StreamColors.transparent);
    expect(_overlaySideOf(tester, 'Window'), BorderSide.none);
  });

  testWidgets('works without a Material ancestor', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(
      Theme(
        data: ThemeData(extensions: [StreamTheme()]),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(width: 400, child: _tabBar(onTap: tapped.add)),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Window'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(tapped, [1]);
  });

  testWidgets('underlines the selected tab on its own side in RTL', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        Directionality(textDirection: TextDirection.rtl, child: _tabBar()),
      ),
    );

    _expectIndicatorUnder(tester, 'Entire Screen');
    expect(tester.getRect(_tab('Entire Screen')).left, greaterThan(tester.getRect(_tab('Window')).left));
  });

  testWidgets('slides the underline and blends the label colors to a newly selected tab', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar()));
    final colorScheme = _colorSchemeOf(tester);
    final start = tester.getRect(_indicator).left;

    await tester.pumpWidget(_withStreamTheme(_tabBar(selectedIndex: 1)));
    await tester.pump(kTabScrollDuration ~/ 2);

    final halfway = tester.getRect(_indicator).left;
    expect(halfway, greaterThan(start));
    expect(halfway, lessThan(tester.getRect(_tab('Window')).left));
    expect(_labelColorOf(tester, 'Window'), isNot(anyOf(colorScheme.textSecondary, colorScheme.accentPrimary)));
    expect(_labelColorOf(tester, 'Entire Screen'), isNot(anyOf(colorScheme.textSecondary, colorScheme.accentPrimary)));

    await tester.pumpAndSettle();
    _expectIndicatorUnder(tester, 'Window');
    expect(_labelColorOf(tester, 'Window'), colorScheme.accentPrimary);
    expect(_labelColorOf(tester, 'Entire Screen'), colorScheme.textSecondary);
  });

  testWidgets('fades the hover pill in', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar()));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(find.text('Window')));
    addTearDown(gesture.removePointer);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 25));

    final hover = _colorSchemeOf(tester).backgroundHover;
    expect(_overlayOf(tester, 'Window').color, isNot(anyOf(hover, StreamColors.transparent)));

    await tester.pumpAndSettle();
    expect(_overlayOf(tester, 'Window').color, hover);
  });

  testWidgets('fits under an AppBar as its bottom', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: Scaffold(
          appBar: AppBar(title: const Text('Share'), bottom: _tabBar()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(StreamTabBar)).bottom, tester.getRect(find.byType(AppBar)).bottom);
    expect(tester.getRect(find.byType(StreamTabBar)).top, kToolbarHeight + tester.getTopLeft(find.byType(AppBar)).dy);
  });

  testWidgets('applies the theme padding and icon spacing', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        streamTheme: StreamTheme(
          tabBarTheme: const StreamTabBarThemeData(labelPadding: EdgeInsets.all(3), spacing: 13),
        ),
        _tabBar(icon: const Icon(Icons.monitor)),
      ),
    );

    final row = tester.widget<Row>(
      find.ancestor(of: find.text('Entire Screen'), matching: find.byType(Row)).first,
    );
    expect(row.spacing, 13);

    final padding = tester.widget<Padding>(find.ancestor(of: row.asFinder, matching: find.byType(Padding)).first);
    expect(padding.padding, const EdgeInsets.all(3));
  });

  testWidgets('resolves the theme overlay color with the selected state', (tester) async {
    const selectedOverlay = Color(0x3300FF00);
    const otherOverlay = Color(0x33FF0000);

    await tester.pumpWidget(
      _withStreamTheme(
        streamTheme: StreamTheme(
          tabBarTheme: StreamTabBarThemeData(
            overlayColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? selectedOverlay : otherOverlay,
            ),
          ),
        ),
        _tabBar(),
      ),
    );

    await _hover(tester, 'Entire Screen');
    expect(_overlayOf(tester, 'Entire Screen').color, selectedOverlay);
    expect(_overlayOf(tester, 'Window').color, otherOverlay);
  });

  testWidgets('a local StreamTabBarTheme beats the one on StreamTheme', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        streamTheme: StreamTheme(tabBarTheme: const StreamTabBarThemeData(dividerHeight: 3, indicatorWeight: 4)),
        StreamTabBarTheme(
          data: const StreamTabBarThemeData(dividerHeight: 5),
          child: _tabBar(),
        ),
      ),
    );

    expect(_dividerOf(tester).width, 5);
    expect(
      tester.getSize(find.byType(StreamTabBar)).height,
      48,
      reason: 'the underline and divider are drawn inside the bar',
    );
    expect(
      tester.getSize(_indicator).height,
      4,
      reason: 'unset local fields fall back to StreamTheme',
    );
  });

  testWidgets('builds from the component factory when it provides a tab bar', (tester) async {
    StreamTabBarProps? received;

    await tester.pumpWidget(
      _withStreamTheme(
        StreamComponentFactory(
          builders: StreamComponentBuilders(
            tabBar: (context, props) {
              received = props;
              return const Text('custom');
            },
          ),
          child: _tabBar(selectedIndex: 1),
        ),
      ),
    );

    expect(find.text('custom'), findsOneWidget);
    expect(find.byType(DefaultStreamTabBar), findsNothing);
    expect(received!.selectedIndex, 1);
    expect(received!.tabs.map((tab) => tab.label), ['Entire Screen', 'Window']);
  });
}

extension on Widget {
  Finder get asFinder => find.byWidget(this);
}
