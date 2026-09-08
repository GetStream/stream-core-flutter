import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

void main() {
  Widget buildSubject({
    StreamEmojiChipThemeData? emojiChipTheme,
    StreamReactionsThemeData? reactionsTheme,
    StreamReactionsThemeData? localReactionsTheme,
  }) {
    Widget reactions = StreamReactions.segmented(
      items: const [
        StreamReactionsItem(emoji: StreamUnicodeEmoji('👍'), count: 3),
        StreamReactionsItem(emoji: StreamUnicodeEmoji('❤️'), count: 2),
      ],
    );

    if (localReactionsTheme case final data?) {
      reactions = StreamReactionsTheme(data: data, child: reactions);
    }

    return MaterialApp(
      home: Theme(
        data: ThemeData(
          extensions: [
            StreamTheme(
              emojiChipTheme: emojiChipTheme ?? const StreamEmojiChipThemeData(),
              reactionsTheme: reactionsTheme ?? const StreamReactionsThemeData(),
            ),
          ],
        ),
        child: Scaffold(body: reactions),
      ),
    );
  }

  ButtonStyle chipStyle(WidgetTester tester) {
    final button = tester.widgetList<IconButton>(find.byType(IconButton)).first;
    return button.style!;
  }

  Color? resolvedChipBackground(WidgetTester tester) {
    return chipStyle(tester).backgroundColor?.resolve(<WidgetState>{});
  }

  group('reaction chip background resolution', () {
    testWidgets('falls back to the elevated reaction default', (tester) async {
      await tester.pumpWidget(buildSubject());

      final context = tester.element(find.byType(DefaultStreamReactions));
      expect(
        resolvedChipBackground(tester),
        context.streamColorScheme.backgroundElevation2,
      );
    });

    testWidgets('honors a reactionsTheme.chipStyle override', (tester) async {
      const green = Color(0xFF4CAF50);
      await tester.pumpWidget(
        buildSubject(
          reactionsTheme: const StreamReactionsThemeData(
            chipStyle: StreamEmojiChipThemeStyle(
              backgroundColor: WidgetStatePropertyAll(green),
            ),
          ),
        ),
      );

      expect(resolvedChipBackground(tester), green);
    });

    testWidgets('does not leak a generic emoji chip background into reactions', (
      tester,
    ) async {
      const amber = Color(0xFFFFC107);
      await tester.pumpWidget(
        buildSubject(
          emojiChipTheme: const StreamEmojiChipThemeData(
            style: StreamEmojiChipThemeStyle(
              backgroundColor: WidgetStatePropertyAll(amber),
            ),
          ),
        ),
      );

      // Reaction chips are themed only via reactionsTheme, so a generic emoji
      // chip theme must not leak into their background.
      final context = tester.element(find.byType(DefaultStreamReactions));
      expect(
        resolvedChipBackground(tester),
        context.streamColorScheme.backgroundElevation2,
      );
    });

    testWidgets('merges a partial override over the reaction defaults', (
      tester,
    ) async {
      const green = Color(0xFF4CAF50);
      await tester.pumpWidget(
        buildSubject(
          reactionsTheme: const StreamReactionsThemeData(
            chipStyle: StreamEmojiChipThemeStyle(
              backgroundColor: WidgetStatePropertyAll(green),
            ),
          ),
        ),
      );

      // Background is overridden, but the reaction-specific sizing default
      // survives because chipStyle is merged, not replaced.
      expect(resolvedChipBackground(tester), green);
      expect(
        chipStyle(tester).minimumSize?.resolve(<WidgetState>{}),
        const Size(32, 24),
      );
    });

    testWidgets('honors a chipStyle override from a wrapping StreamReactionsTheme', (
      tester,
    ) async {
      const blue = Color(0xFF2196F3);
      await tester.pumpWidget(
        buildSubject(
          localReactionsTheme: const StreamReactionsThemeData(
            chipStyle: StreamEmojiChipThemeStyle(
              backgroundColor: WidgetStatePropertyAll(blue),
            ),
          ),
        ),
      );

      expect(resolvedChipBackground(tester), blue);
    });

    testWidgets('local StreamReactionsTheme wins over the global reactionsTheme', (
      tester,
    ) async {
      const green = Color(0xFF4CAF50);
      const blue = Color(0xFF2196F3);
      await tester.pumpWidget(
        buildSubject(
          reactionsTheme: const StreamReactionsThemeData(
            chipStyle: StreamEmojiChipThemeStyle(
              backgroundColor: WidgetStatePropertyAll(green),
            ),
          ),
          localReactionsTheme: const StreamReactionsThemeData(
            chipStyle: StreamEmojiChipThemeStyle(
              backgroundColor: WidgetStatePropertyAll(blue),
            ),
          ),
        ),
      );

      expect(resolvedChipBackground(tester), blue);
    });
  });

  group('StreamReactions.onReactionPressed', () {
    Widget wrap(Widget child) {
      return MaterialApp(
        home: Theme(
          data: ThemeData(extensions: [StreamTheme()]),
          child: Scaffold(body: child),
        ),
      );
    }

    testWidgets('segmented reports the pressed item', (tester) async {
      StreamReactionsItem? pressed;
      var callCount = 0;
      await tester.pumpWidget(
        wrap(
          StreamReactions.segmented(
            items: const [
              StreamReactionsItem(emoji: StreamUnicodeEmoji('👍'), count: 3, key: 'like'),
              StreamReactionsItem(emoji: StreamUnicodeEmoji('❤️'), count: 2, key: 'love'),
            ],
            onReactionPressed: (item) {
              pressed = item;
              callCount++;
            },
          ),
        ),
      );

      await tester.tap(find.byType(IconButton).first);
      expect(callCount, 1);
      expect(pressed?.key, 'like');
    });

    testWidgets('segmented overflow chip reports null', (tester) async {
      StreamReactionsItem? pressed;
      var called = false;
      await tester.pumpWidget(
        wrap(
          StreamReactions.segmented(
            // Force an overflow chip by limiting visible segments to one.
            max: 1,
            items: const [
              StreamReactionsItem(emoji: StreamUnicodeEmoji('👍'), count: 1, key: 'like'),
              StreamReactionsItem(emoji: StreamUnicodeEmoji('❤️'), count: 1, key: 'love'),
            ],
            onReactionPressed: (item) {
              pressed = item;
              called = true;
            },
          ),
        ),
      );

      // The overflow "+N" chip is the trailing chip.
      await tester.tap(find.byType(IconButton).last);
      expect(called, isTrue);
      expect(pressed, isNull);
    });

    testWidgets('clustered chip reports null', (tester) async {
      StreamReactionsItem? pressed;
      var called = false;
      await tester.pumpWidget(
        wrap(
          StreamReactions.clustered(
            items: const [
              StreamReactionsItem(emoji: StreamUnicodeEmoji('👍'), count: 3, key: 'like'),
              StreamReactionsItem(emoji: StreamUnicodeEmoji('❤️'), count: 2, key: 'love'),
            ],
            onReactionPressed: (item) {
              pressed = item;
              called = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(IconButton).first);
      expect(called, isTrue);
      expect(pressed, isNull);
    });

    testWidgets('chips are non-interactive when onReactionPressed is null', (tester) async {
      await tester.pumpWidget(
        wrap(
          StreamReactions.segmented(
            items: const [
              StreamReactionsItem(emoji: StreamUnicodeEmoji('👍'), count: 3, key: 'like'),
            ],
          ),
        ),
      );

      final button = tester.widget<IconButton>(find.byType(IconButton).first);
      expect(button.onPressed, isNull);
    });

    testWidgets('deprecated onPressed still fires when tapped', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        wrap(
          StreamReactions.segmented(
            items: const [
              StreamReactionsItem(emoji: StreamUnicodeEmoji('👍'), count: 3, key: 'like'),
            ],
            // ignore: deprecated_member_use_from_same_package
            onPressed: () => count++,
          ),
        ),
      );

      await tester.tap(find.byType(IconButton).first);
      expect(count, 1);
    });
  });

  group('StreamReactions.onReactionLongPressed', () {
    Widget wrap(Widget child) {
      return MaterialApp(
        home: Theme(
          data: ThemeData(extensions: [StreamTheme()]),
          child: Scaffold(body: child),
        ),
      );
    }

    testWidgets('segmented reports the long-pressed item', (tester) async {
      StreamReactionsItem? longPressed;
      var callCount = 0;
      await tester.pumpWidget(
        wrap(
          StreamReactions.segmented(
            items: const [
              StreamReactionsItem(emoji: StreamUnicodeEmoji('👍'), count: 3, key: 'like'),
              StreamReactionsItem(emoji: StreamUnicodeEmoji('❤️'), count: 2, key: 'love'),
            ],
            onReactionPressed: (_) {},
            onReactionLongPressed: (item) {
              longPressed = item;
              callCount++;
            },
          ),
        ),
      );

      await tester.longPress(find.byType(IconButton).first);
      expect(callCount, 1);
      expect(longPressed?.key, 'like');
    });

    testWidgets('segmented overflow chip reports null', (tester) async {
      StreamReactionsItem? longPressed;
      var called = false;
      await tester.pumpWidget(
        wrap(
          StreamReactions.segmented(
            // Force an overflow chip by limiting visible segments to one.
            max: 1,
            items: const [
              StreamReactionsItem(emoji: StreamUnicodeEmoji('👍'), count: 1, key: 'like'),
              StreamReactionsItem(emoji: StreamUnicodeEmoji('❤️'), count: 1, key: 'love'),
            ],
            onReactionPressed: (_) {},
            onReactionLongPressed: (item) {
              longPressed = item;
              called = true;
            },
          ),
        ),
      );

      // The overflow "+N" chip is the trailing chip.
      await tester.longPress(find.byType(IconButton).last);
      expect(called, isTrue);
      expect(longPressed, isNull);
    });

    testWidgets('clustered chip reports null', (tester) async {
      StreamReactionsItem? longPressed;
      var called = false;
      await tester.pumpWidget(
        wrap(
          StreamReactions.clustered(
            items: const [
              StreamReactionsItem(emoji: StreamUnicodeEmoji('👍'), count: 3, key: 'like'),
              StreamReactionsItem(emoji: StreamUnicodeEmoji('❤️'), count: 2, key: 'love'),
            ],
            onReactionPressed: (_) {},
            onReactionLongPressed: (item) {
              longPressed = item;
              called = true;
            },
          ),
        ),
      );

      await tester.longPress(find.byType(IconButton).first);
      expect(called, isTrue);
      expect(longPressed, isNull);
    });

    testWidgets('registers no long-press gesture when onReactionLongPressed is null', (tester) async {
      await tester.pumpWidget(
        wrap(
          StreamReactions.segmented(
            items: const [
              StreamReactionsItem(emoji: StreamUnicodeEmoji('👍'), count: 3, key: 'like'),
            ],
            onReactionPressed: (_) {},
          ),
        ),
      );

      final button = tester.widget<IconButton>(find.byType(IconButton).first);
      expect(button.onLongPress, isNull);
    });

    testWidgets('does not fire on a chip left disabled by a null press callback', (tester) async {
      var called = false;
      await tester.pumpWidget(
        wrap(
          StreamReactions.segmented(
            items: const [
              StreamReactionsItem(emoji: StreamUnicodeEmoji('👍'), count: 3, key: 'like'),
            ],
            onReactionLongPressed: (_) => called = true,
          ),
        ),
      );

      await tester.longPress(find.byType(IconButton).first);
      expect(called, isFalse);
    });
  });
}
