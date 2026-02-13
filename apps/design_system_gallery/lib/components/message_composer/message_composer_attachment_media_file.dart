import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: MessageComposerAttachmentMediaFile,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentMediaFilePlayground(BuildContext context) {
  return Center(
    child: MessageComposerAttachmentMediaFile.image(
      image: const AssetImage('assets/attachment_image.png'),
      onRemovePressed: () {},
    ),
  );
}
