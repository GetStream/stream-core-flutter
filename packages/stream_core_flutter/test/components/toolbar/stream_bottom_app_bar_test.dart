import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: child,
  );
}

void main() {
  group('StreamBottomAppBar slots', () {
    testWidgets('renders title only — no leading or trailing', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Scaffold(bottomNavigationBar: StreamBottomAppBar(title: const Text('1 of 9'))),
        ),
      );

      expect(find.text('1 of 9'), findsOneWidget);
      expect(find.byType(StreamButton), findsNothing);
    });

    testWidgets('renders title, subtitle, leading and trailing', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Scaffold(
            bottomNavigationBar: StreamBottomAppBar(
              leading: StreamButton.icon(
                key: const ValueKey('leading'),
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
              title: const Text('1 of 9'),
              subtitle: const Text('Tap to share'),
              trailing: StreamButton.icon(
                key: const ValueKey('trailing'),
                icon: const Icon(Icons.grid_view),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('1 of 9'), findsOneWidget);
      expect(find.text('Tap to share'), findsOneWidget);
      expect(find.byKey(const ValueKey('leading')), findsOneWidget);
      expect(find.byKey(const ValueKey('trailing')), findsOneWidget);
    });

    testWidgets('preferredSize is kStreamHeaderHeight', (tester) async {
      final bar = StreamBottomAppBar(title: const Text('Title'));
      expect(bar.preferredSize, equals(const Size.fromHeight(kStreamHeaderHeight)));
    });
  });

  group('StreamBottomAppBar primary / SafeArea', () {
    testWidgets('primary: true wraps in SafeArea(top: false)', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Scaffold(bottomNavigationBar: StreamBottomAppBar(title: const Text('Title'))),
        ),
      );

      final safeArea = tester.widget<SafeArea>(
        find.descendant(
          of: find.byType(StreamBottomAppBar),
          matching: find.byType(SafeArea),
        ),
      );

      // top: false so the bar can sit flush at the top of its slot when
      // it isn't the topmost chrome; bottom: true (default) consumes the
      // system bottom inset (home indicator).
      expect(safeArea.top, isFalse);
      expect(safeArea.bottom, isTrue);
    });

    testWidgets('primary: false skips the SafeArea wrap', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Scaffold(
            bottomNavigationBar: StreamBottomAppBar(
              primary: false,
              title: const Text('Title'),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(StreamBottomAppBar),
          matching: find.byType(SafeArea),
        ),
        findsNothing,
      );
    });
  });

  group('StreamBottomAppBar style precedence', () {
    testWidgets(
      'props.style > theme.style > token defaults (three-level merge)',
      (tester) async {
        const propsPadding = EdgeInsets.all(7);
        const themeTitleStyle = TextStyle(fontSize: 18, color: Color(0xFF112233));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: [StreamTheme()]),
            home: StreamBottomAppBarTheme(
              data: const StreamBottomAppBarThemeData(
                style: StreamBottomAppBarStyle(titleTextStyle: themeTitleStyle),
              ),
              child: Scaffold(
                bottomNavigationBar: StreamBottomAppBar(
                  title: const Text('Title'),
                  subtitle: const Text('Subtitle'),
                  style: const StreamBottomAppBarStyle(padding: propsPadding),
                ),
              ),
            ),
          ),
        );

        // Props win for padding (the bar passes its resolved padding through
        // to the [StreamToolbar]'s `padding` property).
        final toolbar = tester.widget<StreamToolbar>(
          find.descendant(
            of: find.byType(StreamBottomAppBar),
            matching: find.byType(StreamToolbar),
          ),
        );
        expect(toolbar.padding, equals(propsPadding));

        // Theme wins for titleTextStyle (props didn't set it).
        final titleStyle = tester
            .widget<DefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text('Title'),
                    matching: find.byType(DefaultTextStyle),
                  )
                  .first,
            )
            .style;
        expect(titleStyle.fontSize, equals(themeTitleStyle.fontSize));
        expect(titleStyle.color, equals(themeTitleStyle.color));

        // Subtitle falls through to defaults (neither props nor theme set it).
        final subtitleStyle = tester
            .widget<DefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text('Subtitle'),
                    matching: find.byType(DefaultTextStyle),
                  )
                  .first,
            )
            .style;
        expect(subtitleStyle.fontSize, isNotNull);
        expect(subtitleStyle.fontSize, greaterThan(0));
      },
    );
  });
}
