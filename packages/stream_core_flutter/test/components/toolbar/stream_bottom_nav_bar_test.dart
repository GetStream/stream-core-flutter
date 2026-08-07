import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

const _items = [
  StreamBottomNavBarItem(
    icon: Icon(Icons.chat_bubble_outline),
    selectedIcon: Icon(Icons.chat_bubble),
    label: 'Chats',
  ),
  StreamBottomNavBarItem(
    icon: Icon(Icons.bookmark_outline),
    selectedIcon: Icon(Icons.bookmark),
    label: 'Saved',
  ),
];

Widget _withStreamTheme(Widget child, {StreamSurfaceStyle surfaceStyle = StreamSurfaceStyle.regular}) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme(surfaceStyle: surfaceStyle)]),
    home: Scaffold(body: child),
  );
}

/// Whether the bar resolved to the floating style, detected by the presence of
/// the gradient fade (only the floating chrome paints one).
bool _isFloating(WidgetTester tester) {
  final boxes = tester.widgetList<DecoratedBox>(
    find.descendant(of: find.byType(StreamBottomNavBar), matching: find.byType(DecoratedBox)),
  );
  return boxes.any((box) => (box.decoration as BoxDecoration).gradient != null);
}

void main() {
  testWidgets('renders a label for every item', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        StreamBottomNavBar(items: _items, currentIndex: 0, onTap: (_) {}),
      ),
    );

    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('invokes onTap with the tapped index', (tester) async {
    int? tappedIndex;
    await tester.pumpWidget(
      _withStreamTheme(
        StreamBottomNavBar(items: _items, currentIndex: 0, onTap: (index) => tappedIndex = index),
      ),
    );

    await tester.tap(find.text('Saved'));

    expect(tappedIndex, equals(1));
  });

  testWidgets('throws when fewer than 2 items are provided', (tester) async {
    expect(
      () => StreamBottomNavBar(items: [_items.first], currentIndex: 0, onTap: (_) {}),
      throwsA(isA<AssertionError>()),
    );
  });

  group('item options', () {
    testWidgets('selectedIcon falls back to icon when null', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              StreamBottomNavBarItem(icon: Icon(Icons.home), label: 'Home'),
              StreamBottomNavBarItem(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
          ),
        ),
      );

      // Item 0 is selected but sets no selectedIcon → its plain icon is shown.
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('renders a Tooltip when an item sets tooltip', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              StreamBottomNavBarItem(icon: Icon(Icons.home), label: 'Home', tooltip: 'Go home'),
              StreamBottomNavBarItem(icon: Icon(Icons.search), label: 'Search'),
            ],
          ),
        ),
      );

      expect(find.byTooltip('Go home'), findsOneWidget);
    });

    testWidgets('shows no tooltip for an empty tooltip string', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              StreamBottomNavBarItem(icon: Icon(Icons.home), label: 'Home', tooltip: ''),
              StreamBottomNavBarItem(icon: Icon(Icons.search), label: 'Search'),
            ],
          ),
        ),
      );

      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('announces semanticsLabel in place of the visible label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              StreamBottomNavBarItem(icon: Icon(Icons.home), label: 'Home', semanticsLabel: 'Home screen'),
              StreamBottomNavBarItem(icon: Icon(Icons.search), label: 'Search'),
            ],
          ),
        ),
      );

      final tile = find.semantics.byPredicate((n) => n.label.contains('Tab 1 of 2'));
      final label = tile.evaluate().single.label;

      // The override is announced, and the visible "Home" label is excluded — so
      // it isn't spoken a second time (only the one inside "Home screen" remains).
      expect(label, contains('Home screen'));
      expect(RegExp('Home').allMatches(label), hasLength(1));

      handle.dispose();
    });

    testWidgets('forwards an item key to its tile', (tester) async {
      const homeKey = ValueKey('home-tile');
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              StreamBottomNavBarItem(key: homeKey, icon: Icon(Icons.home), label: 'Home'),
              StreamBottomNavBarItem(icon: Icon(Icons.search), label: 'Search'),
            ],
          ),
        ),
      );

      expect(find.byKey(homeKey), findsOneWidget);
    });
  });

  group('regular surfaceStyle', () {
    testWidgets('renders a docked bar with a top border and no gradient', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            items: _items,
            currentIndex: 0,
            onTap: (_) {},
            style: const StreamBottomNavBarStyle(surfaceStyle: .regular),
          ),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(StreamBottomNavBar),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = decoratedBox.decoration as BoxDecoration;
      expect(decoration.gradient, isNull);
      expect(decoration.border, isNotNull);
      expect(find.text('Chats'), findsOneWidget);
    });
  });

  group('floating surfaceStyle', () {
    testWidgets('renders a gradient background', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            items: _items,
            currentIndex: 0,
            onTap: (_) {},
            style: const StreamBottomNavBarStyle(surfaceStyle: .floating),
          ),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(StreamBottomNavBar),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = decoratedBox.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });

  group('surfaceStyle resolution', () {
    testWidgets('resolves surfaceStyle from StreamBottomNavBarTheme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBarTheme(
            data: const StreamBottomNavBarThemeData(
              style: StreamBottomNavBarStyle(surfaceStyle: .floating),
            ),
            child: StreamBottomNavBar(items: _items, currentIndex: 0, onTap: (_) {}),
          ),
        ),
      );

      expect(_isFloating(tester), isTrue);
    });

    testWidgets('is independent of StreamBottomAppBarTheme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomAppBarTheme(
            data: const StreamBottomAppBarThemeData(
              style: StreamBottomAppBarStyle(surfaceStyle: .floating),
            ),
            child: StreamBottomNavBar(items: _items, currentIndex: 0, onTap: (_) {}),
          ),
        ),
      );

      // The nav bar resolves only from its own theme and StreamSurfaceStyle, so a
      // floating StreamBottomAppBarTheme has no effect (defaults to regular).
      expect(_isFloating(tester), isFalse);
    });

    testWidgets('falls back to the ambient StreamSurfaceStyle when neither instance nor theme set a surfaceStyle', (
      tester,
    ) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(items: _items, currentIndex: 0, onTap: (_) {}),
          surfaceStyle: StreamSurfaceStyle.floating,
        ),
      );

      expect(_isFloating(tester), isTrue);
    });
  });

  group('StreamBottomNavBarTheme styling', () {
    testWidgets('applies the selected item color to the selected tile', (tester) async {
      const selectedColor = Color(0xFF123456);
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBarTheme(
            data: const StreamBottomNavBarThemeData(
              style: StreamBottomNavBarStyle(selectedItemColor: selectedColor),
            ),
            child: StreamBottomNavBar(items: _items, currentIndex: 0, onTap: (_) {}),
          ),
        ),
      );

      final selectedLabel = tester.widget<Text>(find.text('Chats'));
      expect(selectedLabel.style?.color, equals(selectedColor));
    });
  });

  group('semantics', () {
    testWidgets('marks each item as a button, flags the selected one, and labels tabs by index', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(items: _items, currentIndex: 0, onTap: (_) {}),
        ),
      );

      // Each tab announces its position (localized "Tab N of M"), merged onto
      // the tile alongside its label (e.g. "Chats\nTab 1 of 2").
      final selected = find.semantics.byPredicate((n) => n.label.contains('Tab 1 of 2'));
      final unselected = find.semantics.byPredicate((n) => n.label.contains('Tab 2 of 2'));

      expect(selected, findsOneWidget);
      expect(unselected, findsOneWidget);

      // The selected item is a selected button; the other an unselected button.
      expect(selected.evaluate().single, isSemantics(isButton: true, isSelected: true));
      expect(unselected.evaluate().single, isSemantics(isButton: true, isSelected: false));

      handle.dispose();
    });
  });

  group('floating pill margin', () {
    // The pill is the only Material carrying a RoundedRectangleBorder shape.
    final pillFinder = find.byWidgetPredicate(
      (widget) => widget is Material && widget.shape is RoundedRectangleBorder,
    );

    Future<void> pumpFloating(WidgetTester tester, {required double deviceBottom}) {
      return tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme(surfaceStyle: StreamSurfaceStyle.floating)]),
          home: Builder(
            builder: (context) {
              final base = MediaQuery.of(context);
              return MediaQuery(
                data: base.copyWith(
                  padding: EdgeInsets.only(bottom: deviceBottom),
                  viewPadding: EdgeInsets.only(bottom: deviceBottom),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: StreamBottomNavBar(
                    items: _items,
                    currentIndex: 0,
                    onTap: (_) {},
                    style: const StreamBottomNavBarStyle(surfaceStyle: .floating),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    double gapBelowPill(WidgetTester tester) {
      final barBottom = tester.getRect(find.byType(StreamBottomNavBar)).bottom;
      final pillBottom = tester.getRect(pillFinder).bottom;
      return barBottom - pillBottom;
    }

    // Representative bottom system insets (viewPadding.bottom) per navigation
    // mode. The pill floors each edge at spacing.xl (24) and adds spacing.xs (8)
    // only above an opaque bar (inset >= 40, i.e. 2-/3-button); thin overlays
    // (gesture 24, iOS indicator 34) sit flush. So gap = max(inset, 24) + extra.
    const navigationModes = <String, double>{
      'iOS home button / no inset': 0,
      'Android gesture (floating) nav': 24,
      'iOS home indicator': 34,
      'Android 2- and 3-button nav': 48,
    };

    for (final MapEntry(key: mode, value: inset) in navigationModes.entries) {
      testWidgets('gaps only above an opaque bar — $mode ($inset)', (tester) async {
        await pumpFloating(tester, deviceBottom: inset);

        final expected = math.max<double>(inset, 24) + (inset >= 40 ? 8 : 0);
        expect(gapBelowPill(tester), moreOrLessEquals(expected, epsilon: 0.5));
      });
    }
  });
}
