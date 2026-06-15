import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

Widget _withTheme(Widget child, {StreamMessageTextStyle? text}) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(
      body: StreamMessageItemTheme(
        data: StreamMessageItemThemeData(text: text),
        child: child,
      ),
    ),
  );
}

Color? _colorOf(WidgetTester tester, String text) {
  return tester.widget<Text>(find.text(text)).style?.color;
}

void main() {
  group('mention color resolution', () {
    testWidgets('with NO theme customization, mentions render with the default mentionColor', (tester) async {
      await tester.pumpWidget(
        _withTheme(
          StreamMessageText(
            '[@Alice](mention:alice) '
            '[@channel](mention-channel:c)',
          ),
        ),
      );

      final aliceColor = _colorOf(tester, '@Alice');
      final channelColor = _colorOf(tester, '@channel');

      // Bug symptom was pure black leaking through from the systemText color
      // baked into bodyLink. Both should match defaults.mentionColor (textLink).
      expect(
        aliceColor,
        isNot(equals(const Color(0xFF000000))),
        reason: 'user mention should not be raw black (systemText leakage)',
      );
      expect(
        channelColor,
        isNot(equals(const Color(0xFF000000))),
        reason: 'channel mention should not be raw black either',
      );
      expect(aliceColor, equals(channelColor), reason: 'all unconfigured variants should resolve to the same default');
    });

    testWidgets('all kinds inherit base mentionColor when no variant override', (tester) async {
      await tester.pumpWidget(
        _withTheme(
          StreamMessageText(
            '[@Alice](mention:alice) '
            '[@channel](mention-channel:c) '
            '[@here](mention-here:h) '
            '[@admin](mention-role:r) '
            '[@frontend](mention-group:g)',
          ),
          text: StreamMessageTextStyle.from(mentionColor: Colors.red),
        ),
      );

      expect(_colorOf(tester, '@Alice'), Colors.red);
      expect(_colorOf(tester, '@channel'), Colors.red);
      expect(_colorOf(tester, '@here'), Colors.red);
      expect(_colorOf(tester, '@admin'), Colors.red);
      expect(_colorOf(tester, '@frontend'), Colors.red);
    });

    testWidgets('variant color override wins over base mentionColor', (tester) async {
      await tester.pumpWidget(
        _withTheme(
          StreamMessageText(
            '[@Alice](mention:alice) '
            '[@channel](mention-channel:c) '
            '[@admin](mention-role:r)',
          ),
          text: StreamMessageTextStyle.from(
            mentionColor: Colors.red,
            mentionUserColor: Colors.blue,
            mentionRoleColor: Colors.purple,
          ),
        ),
      );

      expect(_colorOf(tester, '@Alice'), Colors.blue, reason: 'user override wins');
      expect(_colorOf(tester, '@channel'), Colors.red, reason: 'no broadcast override, fall back to base');
      expect(_colorOf(tester, '@admin'), Colors.purple, reason: 'role override wins');
    });

    testWidgets('@channel and @here share the broadcast color', (tester) async {
      await tester.pumpWidget(
        _withTheme(
          StreamMessageText(
            '[@channel](mention-channel:c) '
            '[@here](mention-here:h)',
          ),
          text: StreamMessageTextStyle.from(
            mentionBroadcastColor: Colors.orange,
          ),
        ),
      );

      expect(_colorOf(tester, '@channel'), Colors.orange);
      expect(_colorOf(tester, '@here'), Colors.orange);
    });
  });
}
