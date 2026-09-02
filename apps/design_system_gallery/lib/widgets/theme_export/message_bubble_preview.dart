import 'package:flutter/material.dart';
import 'package:stream_core_flutter/chat.dart';

/// A minimal incoming/outgoing message pair.
///
/// Shows how the color scheme being edited affects [StreamMessageBubble] in
/// practice. Renders under whatever [Theme] wraps it — the export page wraps
/// one instance per brightness.
class MessageBubblePreview extends StatelessWidget {
  const MessageBubblePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: StreamMessageBubble(
            child: StreamMessageText('Has anyone tried the new Flutter update?'),
          ),
        ),
        SizedBox(height: spacing.sm),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: StreamMessageLayout(
            data: const StreamMessageLayoutData(alignment: StreamMessageAlignment.end),
            child: StreamMessageBubble(
              child: StreamMessageText('Sure, I can help with that!'),
            ),
          ),
        ),
      ],
    );
  }
}
