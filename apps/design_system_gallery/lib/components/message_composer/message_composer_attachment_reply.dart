import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: MessageComposerAttachmentReply,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentReplyPlayground(BuildContext context) {
  final style = context.knobs.object.dropdown<ReplyStyle>(
    label: 'Style',
    options: ReplyStyle.values,
    initialOption: ReplyStyle.incoming,
    labelBuilder: (option) => option.name,
    description: 'Incoming uses left-hand bar and incoming colors; outgoing uses right-hand bar and outgoing colors.',
  );

  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: MessageComposerAttachmentReply(
        title: 'Reply to John Doe',
        subtitle: 'We had a great time during our holiday.',
        image: const AssetImage('assets/attachment_image.png'),
        onRemovePressed: () {},
        style: style,
      ),
    ),
  );
}
