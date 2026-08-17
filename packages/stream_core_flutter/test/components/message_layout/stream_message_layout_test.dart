import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stream_core_flutter/chat.dart';

void main() {
  group('StreamMessageLayoutData', () {
    test('defaults to a standard presentation', () {
      const data = StreamMessageLayoutData();
      expect(data.presentation, StreamMessagePresentation.standard);
    });

    test('copyWith replaces only the given fields', () {
      const data = StreamMessageLayoutData(
        alignment: StreamMessageAlignment.end,
        stackPosition: StreamMessageStackPosition.middle,
        channelKind: StreamMessageChannelKind.direct,
        listKind: StreamMessageListKind.thread,
        contentKind: StreamMessageContentKind.jumbomoji,
      );

      final copy = data.copyWith(presentation: StreamMessagePresentation.preview);

      expect(copy.presentation, StreamMessagePresentation.preview);
      expect(copy.alignment, data.alignment);
      expect(copy.stackPosition, data.stackPosition);
      expect(copy.channelKind, data.channelKind);
      expect(copy.listKind, data.listKind);
      expect(copy.contentKind, data.contentKind);
    });

    test('copyWith without arguments returns an equal value', () {
      const data = StreamMessageLayoutData(presentation: StreamMessagePresentation.preview);
      expect(data.copyWith(), data);
    });

    test('presentation participates in equality and hashCode', () {
      const standard = StreamMessageLayoutData();
      const preview = StreamMessageLayoutData(presentation: StreamMessagePresentation.preview);

      expect(standard, isNot(preview));
      expect(standard.hashCode, isNot(preview.hashCode));
      expect(preview, const StreamMessageLayoutData(presentation: StreamMessagePresentation.preview));
    });

    test('toString includes the presentation', () {
      const data = StreamMessageLayoutData(presentation: StreamMessagePresentation.preview);
      expect(data.toString(), contains('presentation: StreamMessagePresentation.preview'));
    });
  });

  group('StreamMessageLayout.presentationOf', () {
    testWidgets('returns standard when no layout is in scope', (tester) async {
      late StreamMessagePresentation presentation;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            presentation = StreamMessageLayout.presentationOf(context);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(presentation, StreamMessagePresentation.standard);
    });

    testWidgets('returns the presentation of the nearest layout', (tester) async {
      late StreamMessagePresentation presentation;

      await tester.pumpWidget(
        StreamMessageLayout(
          data: const StreamMessageLayoutData(presentation: StreamMessagePresentation.preview),
          child: Builder(
            builder: (context) {
              presentation = StreamMessageLayout.presentationOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(presentation, StreamMessagePresentation.preview);
    });

    testWidgets('does not rebuild dependents when an unrelated field changes', (tester) async {
      // The child is const so the only thing that can trigger a rebuild is the
      // InheritedModel aspect, which is what this test is about.
      Widget buildSubject(StreamMessageLayoutData data) {
        return StreamMessageLayout(data: data, child: const _PresentationProbe());
      }

      _probeBuildCount = 0;
      addTearDown(() => _probeBuildCount = 0);

      await tester.pumpWidget(buildSubject(const StreamMessageLayoutData()));
      expect(_probeBuildCount, 1);

      // Changing the alignment must not rebuild a presentation-only dependent.
      await tester.pumpWidget(
        buildSubject(const StreamMessageLayoutData(alignment: StreamMessageAlignment.end)),
      );
      expect(_probeBuildCount, 1);

      await tester.pumpWidget(
        buildSubject(
          const StreamMessageLayoutData(
            alignment: StreamMessageAlignment.end,
            presentation: StreamMessagePresentation.preview,
          ),
        ),
      );
      expect(_probeBuildCount, 2);
    });
  });
}

// How often [_PresentationProbe] has rebuilt.
var _probeBuildCount = 0;

// Counts how often it rebuilds while depending only on the presentation aspect.
class _PresentationProbe extends StatelessWidget {
  const _PresentationProbe();

  @override
  Widget build(BuildContext context) {
    StreamMessageLayout.presentationOf(context);
    _probeBuildCount++;
    return const SizedBox.shrink();
  }
}
