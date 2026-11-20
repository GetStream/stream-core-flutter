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
  ValueChanged<int>? onSelected,
  Widget? icon,
  bool windowEnabled = true,
}) {
  return StreamTabBar(
    selectedIndex: selectedIndex,
    onSelected: onSelected ?? (_) {},
    tabs: [
      StreamTabBarItem(label: 'Entire Screen', icon: icon),
      StreamTabBarItem(label: 'Window', enabled: windowEnabled),
    ],
  );
}

Color _labelColorOf(WidgetTester tester, String label) => tester.widget<Text>(find.text(label)).style!.color!;

// The underline of the tab whose label is [label].
BorderSide _indicatorOf(WidgetTester tester, String label) {
  final box = tester.widget<DecoratedBox>(
    find.ancestor(of: find.text(label), matching: find.byType(DecoratedBox)).first,
  );
  return ((box.decoration as BoxDecoration).border! as Border).bottom;
}

InkWell _inkWellOf(WidgetTester tester, String label) {
  return tester.widget<InkWell>(find.ancestor(of: find.text(label), matching: find.byType(InkWell)));
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

  testWidgets('underlines the selected tab in the accent and the others in the border color', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar(selectedIndex: 1)));

    final colorScheme = _colorSchemeOf(tester);
    expect(_indicatorOf(tester, 'Window').color, colorScheme.accentPrimary);
    expect(_indicatorOf(tester, 'Entire Screen').color, colorScheme.borderDefault);
    expect(_indicatorOf(tester, 'Window').width, 2);
  });

  testWidgets('tints the icon with the label color', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar(icon: const Icon(Icons.monitor))));

    final iconTheme = IconTheme.of(tester.element(find.byIcon(Icons.monitor)));
    expect(iconTheme.color, _colorSchemeOf(tester).accentPrimary);
  });

  testWidgets('reports the index of the tapped tab', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(_withStreamTheme(_tabBar(onSelected: tapped.add)));

    await tester.tap(find.text('Window'));
    await tester.pumpAndSettle();

    expect(tapped, [1]);
  });

  testWidgets('reports the tab that is already selected too', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(_withStreamTheme(_tabBar(onSelected: tapped.add)));

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

  testWidgets('is 48 tall by default', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar()));

    expect(tester.getSize(find.byType(StreamTabBar)).height, 48);
  });

  testWidgets('leaves every tab unselected without a selected index', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_withStreamTheme(_tabBar(selectedIndex: null)));

    final colorScheme = _colorSchemeOf(tester);
    for (final label in ['Entire Screen', 'Window']) {
      expect(_labelColorOf(tester, label), colorScheme.textSecondary);
      expect(_indicatorOf(tester, label).color, colorScheme.borderDefault);
      expect(tester.semantics.find(find.text(label)), isSemantics(hasSelectedState: true, isSelected: false));
    }
    handle.dispose();
  });

  test('rejects empty tabs and a selected index outside them', () {
    void onSelected(int _) {}
    const tabs = [StreamTabBarItem(label: 'Only')];

    expect(() => StreamTabBarProps(tabs: const [], onSelected: onSelected), throwsAssertionError);
    expect(() => StreamTabBarProps(tabs: tabs, selectedIndex: 1, onSelected: onSelected), throwsAssertionError);
    expect(() => StreamTabBarProps(tabs: tabs, selectedIndex: -1, onSelected: onSelected), throwsAssertionError);
  });

  testWidgets('draws a disabled tab in the disabled colors and ignores taps on it', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(_withStreamTheme(_tabBar(onSelected: tapped.add, windowEnabled: false)));

    final colorScheme = _colorSchemeOf(tester);
    expect(_labelColorOf(tester, 'Window'), colorScheme.textDisabled);
    expect(_indicatorOf(tester, 'Window').color, colorScheme.borderDisabled);

    await tester.tap(find.text('Window'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(tapped, isEmpty);
  });

  testWidgets('announces a disabled tab and skips it with the keyboard', (tester) async {
    final handle = tester.ensureSemantics();
    final tapped = <int>[];
    await tester.pumpWidget(_withStreamTheme(_tabBar(onSelected: tapped.add, windowEnabled: false)));

    expect(
      tester.semantics.find(find.text('Window')),
      isSemantics(role: SemanticsRole.tab, hasEnabledState: true, isEnabled: false, hasTapAction: false),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(tapped, isNot(contains(1)));
    handle.dispose();
  });

  testWidgets('keeps the underline below the label', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        streamTheme: StreamTheme(
          tabBarTheme: const StreamTabBarThemeData(tabPadding: EdgeInsets.zero, indicatorWeight: 6),
        ),
        _tabBar(),
      ),
    );

    final tabBottom = tester.getRect(find.ancestor(of: find.text('Window'), matching: find.byType(InkWell))).bottom;
    expect(tester.getRect(find.text('Window')).bottom, lessThanOrEqualTo(tabBottom - 6));
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
    await tester.pumpWidget(_withStreamTheme(_tabBar(onSelected: tapped.add)));

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
            minHeight: 64,
            indicatorWeight: 4,
            indicatorColor: bySelection,
            labelStyle: const TextStyle(fontSize: 20),
            foregroundColor: bySelection,
          ),
        ),
        _tabBar(),
      ),
    );

    expect(tester.getSize(find.byType(StreamTabBar)).height, 64);
    expect(_indicatorOf(tester, 'Window').width, 4);
    expect(_indicatorOf(tester, 'Entire Screen').color, selected);
    expect(_indicatorOf(tester, 'Window').color, unselected);
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
    expect(_indicatorOf(tester, 'Window').color, selected);
    expect(_labelColorOf(tester, 'Entire Screen'), colorScheme.textSecondary);
    expect(IconTheme.of(tester.element(find.byIcon(Icons.monitor))).color, colorScheme.textSecondary);
    expect(_indicatorOf(tester, 'Entire Screen').color, colorScheme.borderDefault);
    expect(
      _inkWellOf(tester, 'Entire Screen').overlayColor!.resolve({WidgetState.pressed}),
      colorScheme.backgroundPressed,
    );
  });

  testWidgets('paints the default overlay for interaction states only', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar()));

    final colorScheme = _colorSchemeOf(tester);
    for (final label in ['Entire Screen', 'Window']) {
      final overlay = _inkWellOf(tester, label).overlayColor!;
      expect(overlay.resolve({WidgetState.pressed}), colorScheme.backgroundPressed, reason: label);
      expect(overlay.resolve({WidgetState.hovered}), colorScheme.backgroundHover, reason: label);
      expect(overlay.resolve({WidgetState.focused}), colorScheme.backgroundHover, reason: label);
      expect(overlay.resolve({}), StreamColors.transparent, reason: label);
    }
  });

  testWidgets('applies the theme padding and icon spacing', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        streamTheme: StreamTheme(
          tabBarTheme: const StreamTabBarThemeData(tabPadding: EdgeInsets.all(3), spacing: 13),
        ),
        _tabBar(icon: const Icon(Icons.monitor)),
      ),
    );

    final row = tester.widget<Row>(
      find.ancestor(of: find.text('Entire Screen'), matching: find.byType(Row)).first,
    );
    expect(row.spacing, 13);

    final padding = tester.widget<Padding>(find.ancestor(of: row.asFinder, matching: find.byType(Padding)).first);
    expect(padding.padding, const EdgeInsets.fromLTRB(3, 3, 3, 5), reason: 'the underline is added below the padding');
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

    expect(_inkWellOf(tester, 'Entire Screen').overlayColor!.resolve({WidgetState.pressed}), selectedOverlay);
    expect(_inkWellOf(tester, 'Window').overlayColor!.resolve({WidgetState.pressed}), otherOverlay);
  });

  testWidgets('a local StreamTabBarTheme beats the one on StreamTheme', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        streamTheme: StreamTheme(tabBarTheme: const StreamTabBarThemeData(minHeight: 64, indicatorWeight: 4)),
        StreamTabBarTheme(
          data: const StreamTabBarThemeData(minHeight: 56),
          child: _tabBar(),
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamTabBar)).height, 56);
    expect(_indicatorOf(tester, 'Window').width, 4, reason: 'unset local fields fall back to StreamTheme');
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
