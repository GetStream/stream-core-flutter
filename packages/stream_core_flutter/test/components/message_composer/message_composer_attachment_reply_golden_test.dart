// ignore_for_file: avoid_redundant_argument_values

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('MessageComposerAttachmentReply Golden Tests', () {
    goldenTest(
      'renders light theme style matrix',
      fileName: 'message_composer_attachment_reply_light_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 360),
        children: [
          for (final style in ReplyStyle.values)
            GoldenTestScenario(
              name: '${style.name}_no_remove',
              child: _buildReplyInTheme(
                MessageComposerAttachmentReply(
                  title: 'Reply to John Doe',
                  subtitle: 'We had a great time during our holiday.',
                  onRemovePressed: null,
                  style: style,
                ),
              ),
            ),
          for (final style in ReplyStyle.values)
            GoldenTestScenario(
              name: '${style.name}_with_remove',
              child: _buildReplyInTheme(
                MessageComposerAttachmentReply(
                  title: 'Reply to John Doe',
                  subtitle: 'We had a great time during our holiday.',
                  onRemovePressed: () {},
                  style: style,
                ),
              ),
            ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme style matrix',
      fileName: 'message_composer_attachment_reply_dark_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 360),
        children: [
          for (final style in ReplyStyle.values)
            GoldenTestScenario(
              name: '${style.name}_no_remove',
              child: _buildReplyInTheme(
                MessageComposerAttachmentReply(
                  title: 'Reply to John Doe',
                  subtitle: 'We had a great time during our holiday.',
                  onRemovePressed: null,
                  style: style,
                ),
                brightness: Brightness.dark,
              ),
            ),
          for (final style in ReplyStyle.values)
            GoldenTestScenario(
              name: '${style.name}_with_remove',
              child: _buildReplyInTheme(
                MessageComposerAttachmentReply(
                  title: 'Reply to John Doe',
                  subtitle: 'We had a great time during our holiday.',
                  onRemovePressed: () {},
                  style: style,
                ),
                brightness: Brightness.dark,
              ),
            ),
        ],
      ),
    );
  });
}

Widget _buildReplyInTheme(
  Widget reply, {
  Brightness brightness = Brightness.light,
}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(
      brightness: brightness,
      extensions: [streamTheme],
    ),
    child: Builder(
      builder: (context) => Material(
        color: StreamTheme.of(context).colorScheme.backgroundApp,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: reply,
        ),
      ),
    ),
  );
}
