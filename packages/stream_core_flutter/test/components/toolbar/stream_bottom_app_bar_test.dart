import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: child,
  );
}

void main() {
  group('StreamBottomAppBar slots', () {
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

    testWidgets('preferredSize is kStreamToolbarHeight', (tester) async {
      final bar = StreamBottomAppBar(title: const Text('Title'));
      expect(bar.preferredSize, equals(const Size.fromHeight(kStreamToolbarHeight)));
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

  group('StreamBottomAppBar floating', () {
    testWidgets('regular uses solid background and top border', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Scaffold(bottomNavigationBar: StreamBottomAppBar(title: const Text('Title'))),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(StreamBottomAppBar),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = decoratedBox.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
      expect(decoration.gradient, isNull);
      expect(decoration.border, isNotNull);
    });

    testWidgets('floating uses gradient and no border', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Scaffold(
            bottomNavigationBar: StreamBottomAppBar(
              style: const StreamBottomAppBarStyle(surfaceStyle: StreamSurfaceStyle.floating),
              title: const Text('Title'),
            ),
          ),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(StreamBottomAppBar),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = decoratedBox.decoration as BoxDecoration;
      expect(decoration.color, isNull);
      expect(decoration.gradient, isA<LinearGradient>());
      expect(decoration.border, isNull);
    });
  });

  group('StreamBottomAppBar slot behaviour', () {
    // A slot resolves its behaviour from the ambient StreamToolbarScope.
    // The bar publishes its resolved behaviour so a `style` handed only to
    // the bar still reaches its slots.
    StreamSurfaceStyle? captured;

    Widget probe() {
      return Builder(
        builder: (context) {
          captured = StreamToolbarScope.of(context);
          return const SizedBox.shrink();
        },
      );
    }

    tearDown(() => captured = null);

    testWidgets('slot resolves floating when style is passed to the bar', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Scaffold(
            bottomNavigationBar: StreamBottomAppBar(
              style: const StreamBottomAppBarStyle(surfaceStyle: StreamSurfaceStyle.floating),
              title: const Text('Title'),
              trailing: probe(),
            ),
          ),
        ),
      );

      expect(captured, StreamSurfaceStyle.floating);
    });

    testWidgets('slot resolves regular by default', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Scaffold(
            bottomNavigationBar: StreamBottomAppBar(
              title: const Text('Title'),
              trailing: probe(),
            ),
          ),
        ),
      );

      expect(captured, StreamSurfaceStyle.regular);
    });

    testWidgets('slot resolves floating from the ambient app style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme(surfaceStyle: StreamSurfaceStyle.floating)]),
          home: Scaffold(
            bottomNavigationBar: StreamBottomAppBar(
              title: const Text('Title'),
              trailing: probe(),
            ),
          ),
        ),
      );

      expect(captured, StreamSurfaceStyle.floating);
    });

    testWidgets('bar style overrides the ambient app bar theme for slots', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamBottomAppBarTheme(
            data: const StreamBottomAppBarThemeData(
              style: StreamBottomAppBarStyle(surfaceStyle: StreamSurfaceStyle.floating),
            ),
            child: Scaffold(
              bottomNavigationBar: StreamBottomAppBar(
                style: const StreamBottomAppBarStyle(surfaceStyle: StreamSurfaceStyle.regular),
                title: const Text('Title'),
                trailing: probe(),
              ),
            ),
          ),
        ),
      );

      expect(captured, StreamSurfaceStyle.regular);
    });
  });
}
