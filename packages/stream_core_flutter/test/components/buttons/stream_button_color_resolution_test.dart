// Repro for stream-chat-flutter issue #2786:
// "v10: composer / attachment-picker icons render white (invisible) in light
//  mode despite a light StreamColorScheme".
//
// The user supplies a light StreamTheme via ThemeData.extensions, then renders
// StreamButton.icon(style: secondary, type: outline) (the composer's leading +).
// Expected: the icon's IconTheme color resolves to the supplied light scheme's
// textPrimary (a dark color, ~0xFF1A1B25). Actually observed in the bug report:
// the icon is white.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamButton picks up StreamColorScheme from ThemeData extension', () {
    testWidgets(
      'secondary outline icon button uses light textPrimary when supplied',
      (tester) async {
        final lightStreamTheme = StreamTheme(
          brightness: Brightness.light,
          colorScheme: StreamColorScheme.light(),
        );
        final expectedTextPrimary = lightStreamTheme.colorScheme.textPrimary;

        Color? capturedIconColor;
        await tester.pumpWidget(
          MaterialApp(
            themeMode: ThemeMode.light,
            theme: ThemeData.light().copyWith(extensions: [lightStreamTheme]),
            home: Scaffold(
              body: Center(
                child: StreamButton.icon(
                  icon: Builder(
                    builder: (context) {
                      capturedIconColor = IconTheme.of(context).color;
                      return const Icon(Icons.add);
                    },
                  ),
                  style: StreamButtonStyle.secondary,
                  type: StreamButtonType.outline,
                  size: StreamButtonSize.large,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          capturedIconColor,
          expectedTextPrimary,
          reason:
              'StreamButton.icon should resolve its IconTheme color from the '
              'supplied light StreamColorScheme.textPrimary, but got '
              '$capturedIconColor.',
        );
      },
    );

    testWidgets(
      'secondary ghost icon button uses light textPrimary when supplied',
      (tester) async {
        final lightStreamTheme = StreamTheme(
          brightness: Brightness.light,
          colorScheme: StreamColorScheme.light(),
        );
        final expectedTextPrimary = lightStreamTheme.colorScheme.textPrimary;

        Color? capturedIconColor;
        await tester.pumpWidget(
          MaterialApp(
            themeMode: ThemeMode.light,
            theme: ThemeData.light().copyWith(extensions: [lightStreamTheme]),
            home: Scaffold(
              body: Center(
                child: StreamButton.icon(
                  icon: Builder(
                    builder: (context) {
                      capturedIconColor = IconTheme.of(context).color;
                      return const Icon(Icons.send);
                    },
                  ),
                  style: StreamButtonStyle.secondary,
                  type: StreamButtonType.ghost,
                  size: StreamButtonSize.small,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          capturedIconColor,
          expectedTextPrimary,
          reason:
              'StreamButton.icon (secondary/ghost) should resolve its IconTheme '
              'color from the supplied light StreamColorScheme.textPrimary, but '
              'got $capturedIconColor.',
        );
      },
    );
  });
}
