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

Widget _withStreamTheme(Widget child, {StreamAppStyle appStyle = StreamAppStyle.regular}) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme(appStyle: appStyle)]),
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

  group('regular behavior', () {
    testWidgets('renders a docked bar with a top border and no gradient', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            items: _items,
            currentIndex: 0,
            onTap: (_) {},
            behavior: StreamBottomNavBarBehavior.regular,
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

  group('floating behavior', () {
    testWidgets('renders a pill container instead of a BottomNavigationBar', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            items: _items,
            currentIndex: 0,
            onTap: (_) {},
            behavior: StreamBottomNavBarBehavior.floating,
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.text('Chats'), findsOneWidget);
    });

    testWidgets('invokes onTap with the tapped index', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            items: _items,
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
            behavior: StreamBottomNavBarBehavior.floating,
          ),
        ),
      );

      await tester.tap(find.text('Saved'));

      expect(tappedIndex, equals(1));
    });

    testWidgets('renders a gradient background', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            items: _items,
            currentIndex: 0,
            onTap: (_) {},
            behavior: StreamBottomNavBarBehavior.floating,
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

  group('behavior resolution', () {
    testWidgets('resolves behavior from StreamBottomNavBarTheme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBarTheme(
            data: const StreamBottomNavBarThemeData(
              style: StreamBottomNavBarStyle(behavior: StreamBottomNavBarBehavior.floating),
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
              style: StreamBottomAppBarStyle(behavior: StreamBottomAppBarBehavior.floating),
            ),
            child: StreamBottomNavBar(items: _items, currentIndex: 0, onTap: (_) {}),
          ),
        ),
      );

      // The nav bar resolves only from its own theme and StreamAppStyle, so a
      // floating StreamBottomAppBarTheme has no effect (defaults to regular).
      expect(_isFloating(tester), isFalse);
    });

    testWidgets('falls back to the ambient StreamAppStyle when neither instance nor theme set a behavior', (
      tester,
    ) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(items: _items, currentIndex: 0, onTap: (_) {}),
          appStyle: StreamAppStyle.floating,
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
}
