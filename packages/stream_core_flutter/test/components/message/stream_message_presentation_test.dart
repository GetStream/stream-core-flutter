import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

/// Verifies that the metadata, annotation and replies defaults switch their
/// secondary foreground to [StreamColorScheme.textOnAccent] when the message is
/// presented as a preview — i.e. drawn on top of the modal scrim.
void main() {
  Widget wrap({
    required Widget child,
    required StreamMessagePresentation presentation,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      home: Theme(
        data: ThemeData(
          brightness: brightness,
          extensions: [StreamTheme(brightness: brightness)],
        ),
        child: Scaffold(
          body: StreamMessageLayout(
            data: StreamMessageLayoutData(presentation: presentation),
            child: child,
          ),
        ),
      ),
    );
  }

  // The color a Text actually paints with, after the ambient DefaultTextStyle.
  Color? textColorOf(WidgetTester tester, String text) {
    final context = tester.element(find.text(text));
    return DefaultTextStyle.of(context).style.color;
  }

  // The color an Icon actually paints with, after the ambient IconTheme.
  Color? iconColorOf(WidgetTester tester, IconData icon) {
    final context = tester.element(find.byIcon(icon));
    return IconTheme.of(context).color;
  }

  StreamColorScheme colorSchemeOf(WidgetTester tester) {
    return StreamTheme.of(tester.element(find.byType(Scaffold))).colorScheme;
  }

  group('StreamMessageMetadata', () {
    Widget subject(StreamMessagePresentation presentation, {Brightness brightness = Brightness.light}) {
      return wrap(
        presentation: presentation,
        brightness: brightness,
        child: StreamMessageMetadata(
          username: const Text('Alice'),
          status: const Icon(Icons.done_all),
          timestamp: const Text('09:41'),
          edited: const Text('Edited'),
        ),
      );
    }

    testWidgets('uses muted colors for a standard presentation', (tester) async {
      await tester.pumpWidget(subject(StreamMessagePresentation.standard));
      final colorScheme = colorSchemeOf(tester);

      expect(textColorOf(tester, 'Alice'), colorScheme.textSecondary);
      expect(textColorOf(tester, '09:41'), colorScheme.textTertiary);
      expect(textColorOf(tester, 'Edited'), colorScheme.textTertiary);
      expect(iconColorOf(tester, Icons.done_all), colorScheme.textTertiary);
    });

    testWidgets('uses the on-scrim color for a preview presentation', (tester) async {
      await tester.pumpWidget(subject(StreamMessagePresentation.preview));
      final colorScheme = colorSchemeOf(tester);

      expect(textColorOf(tester, 'Alice'), colorScheme.textOnAccent);
      expect(textColorOf(tester, '09:41'), colorScheme.textOnAccent);
      expect(textColorOf(tester, 'Edited'), colorScheme.textOnAccent);
      expect(iconColorOf(tester, Icons.done_all), colorScheme.textOnAccent);
    });

    testWidgets('uses the on-scrim color for a preview presentation in dark mode', (tester) async {
      await tester.pumpWidget(subject(StreamMessagePresentation.preview, brightness: Brightness.dark));
      final colorScheme = colorSchemeOf(tester);

      // textOnAccent stays white in dark mode, unlike textOnInverse.
      expect(colorScheme.textOnAccent, const Color(0xFFFFFFFF));
      expect(textColorOf(tester, '09:41'), colorScheme.textOnAccent);
      expect(iconColorOf(tester, Icons.done_all), colorScheme.textOnAccent);
    });

    testWidgets('an explicit style still wins over the preview default', (tester) async {
      const green = Color(0xFF4CAF50);

      await tester.pumpWidget(
        wrap(
          presentation: StreamMessagePresentation.preview,
          child: StreamMessageMetadata(
            timestamp: const Text('09:41'),
            style: StreamMessageMetadataStyle.from(timestampColor: green),
          ),
        ),
      );

      expect(textColorOf(tester, '09:41'), green);
    });
  });

  group('StreamMessageAnnotation', () {
    Widget subject(StreamMessagePresentation presentation) {
      return wrap(
        presentation: presentation,
        child: StreamMessageAnnotation(
          leading: const Icon(Icons.push_pin),
          label: const Text('Pinned by You'),
          trailing: const Text('View'),
        ),
      );
    }

    testWidgets('uses primary text colors for a standard presentation', (tester) async {
      await tester.pumpWidget(subject(StreamMessagePresentation.standard));
      final colorScheme = colorSchemeOf(tester);

      expect(textColorOf(tester, 'Pinned by You'), colorScheme.textPrimary);
      expect(textColorOf(tester, 'View'), colorScheme.textPrimary);
      expect(iconColorOf(tester, Icons.push_pin), colorScheme.textPrimary);
    });

    testWidgets('uses the on-scrim color for a preview presentation', (tester) async {
      await tester.pumpWidget(subject(StreamMessagePresentation.preview));
      final colorScheme = colorSchemeOf(tester);

      expect(textColorOf(tester, 'Pinned by You'), colorScheme.textOnAccent);
      expect(textColorOf(tester, 'View'), colorScheme.textOnAccent);
      expect(iconColorOf(tester, Icons.push_pin), colorScheme.textOnAccent);
    });
  });

  group('StreamMessageReplies', () {
    Widget subject(StreamMessagePresentation presentation) {
      return wrap(
        presentation: presentation,
        child: StreamMessageReplies(label: const Text('2 replies')),
      );
    }

    testWidgets('uses the link color for a standard presentation', (tester) async {
      await tester.pumpWidget(subject(StreamMessagePresentation.standard));
      expect(textColorOf(tester, '2 replies'), colorSchemeOf(tester).textLink);
    });

    testWidgets('uses the on-scrim color for a preview presentation', (tester) async {
      await tester.pumpWidget(subject(StreamMessagePresentation.preview));
      expect(textColorOf(tester, '2 replies'), colorSchemeOf(tester).textOnAccent);
    });
  });
}
