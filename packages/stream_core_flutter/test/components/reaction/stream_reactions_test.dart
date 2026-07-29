import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Theme(
        data: ThemeData(extensions: [StreamTheme()]),
        child: Scaffold(body: child),
      ),
    );
  }

  group('StreamReactions.onReactionPressed', () {
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
  });
}
