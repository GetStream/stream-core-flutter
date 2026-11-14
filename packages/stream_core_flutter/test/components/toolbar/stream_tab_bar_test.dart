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

StreamTabBar _tabBar({int selectedIndex = 0, ValueChanged<int>? onSelected, Widget? icon}) {
  return StreamTabBar(
    selectedIndex: selectedIndex,
    onSelected: onSelected ?? (_) {},
    tabs: [
      StreamTabBarItem(label: 'Entire Screen', icon: icon),
      const StreamTabBarItem(label: 'Window'),
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

  testWidgets('gives every tab an equal share of the width', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar()));

    expect(tester.getSize(find.text('Entire Screen')).width, lessThan(200));
    expect(tester.getTopLeft(find.text('Window')).dx, greaterThanOrEqualTo(200));
  });

  testWidgets('is 48 tall by default', (tester) async {
    await tester.pumpWidget(_withStreamTheme(_tabBar()));

    expect(tester.getSize(find.byType(StreamTabBar)).height, StreamTabBar.height);
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
    expect(tester.getSize(find.byType(StreamTabBar)).height, greaterThan(StreamTabBar.height));
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

    await tester.pumpWidget(
      _withStreamTheme(
        streamTheme: StreamTheme(
          tabBarTheme: StreamTabBarThemeData(
            height: 64,
            indicatorWeight: 4,
            indicatorColor: const WidgetStatePropertyAll(selected),
            labelStyle: const TextStyle(fontSize: 20),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? selected : unselected,
            ),
          ),
        ),
        _tabBar(),
      ),
    );

    expect(tester.getSize(find.byType(StreamTabBar)).height, 64);
    expect(_indicatorOf(tester, 'Window').width, 4);
    expect(_indicatorOf(tester, 'Window').color, selected);
    expect(_labelColorOf(tester, 'Entire Screen'), selected);
    expect(_labelColorOf(tester, 'Window'), unselected);
    expect(tester.widget<Text>(find.text('Window')).style!.fontSize, 20);
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

    InkWell inkWellOf(String label) =>
        tester.widget<InkWell>(find.ancestor(of: find.text(label), matching: find.byType(InkWell)));

    expect(inkWellOf('Entire Screen').overlayColor!.resolve({WidgetState.pressed}), selectedOverlay);
    expect(inkWellOf('Window').overlayColor!.resolve({WidgetState.pressed}), otherOverlay);
  });

  testWidgets('a local StreamTabBarTheme beats the one on StreamTheme', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        streamTheme: StreamTheme(tabBarTheme: const StreamTabBarThemeData(height: 64, indicatorWeight: 4)),
        StreamTabBarTheme(
          data: const StreamTabBarThemeData(height: 56),
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
