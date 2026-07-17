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
    testWidgets('renders a docked BottomNavigationBar', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomNavBar(
            items: _items,
            currentIndex: 0,
            onTap: (_) {},
            behavior: StreamBottomAppBarBehavior.regular,
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
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
            behavior: StreamBottomAppBarBehavior.floating,
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
            behavior: StreamBottomAppBarBehavior.floating,
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
            behavior: StreamBottomAppBarBehavior.floating,
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
    testWidgets('falls back to StreamBottomAppBarTheme when the instance behavior is unset', (tester) async {
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

      expect(find.byType(BottomNavigationBar), findsNothing);
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

      expect(find.byType(BottomNavigationBar), findsNothing);
    });
  });
}
