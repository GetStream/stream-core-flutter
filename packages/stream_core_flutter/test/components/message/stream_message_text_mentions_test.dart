import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

// Shows [text] and taps [displayText], returning the id the mention reported.
Future<String?> _tapMention(WidgetTester tester, String text, String displayText) async {
  String? tappedId;
  await tester.pumpWidget(
    MaterialApp(
      home: Theme(
        data: ThemeData(extensions: [StreamTheme()]),
        child: StreamMessageLayout(
          data: const StreamMessageLayoutData(),
          child: StreamMessageText(text, onTapMention: (_, id) => tappedId = id),
        ),
      ),
    ),
  );

  await tester.tapOnText(find.textRange.ofSubstring(displayText));
  return tappedId;
}

void main() {
  testWidgets('StreamMessageText reports the decoded id of a mention', (tester) async {
    expect(await _tapMention(tester, 'Hi [@Alice](mention:user%20123)', '@Alice'), 'user 123');
  });

  for (final rawId in ['%ZZ', '%', 'user%F', '%FF', '%C3']) {
    testWidgets('StreamMessageText shows a mention whose id is not valid percent-encoding: $rawId', (tester) async {
      expect(await _tapMention(tester, 'Hi [@Alice](mention:$rawId)', '@Alice'), rawId);
      expect(tester.takeException(), isNull);
    });
  }
}
