import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: MessageComposerAttachmentLinkPreview,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentLinkPreviewPlayground(BuildContext context) {
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Getting started with Stream',
    description: 'Optional title of the link preview.',
  );
  final subtitle = context.knobs.string(
    label: 'Subtitle',
    initialValue: 'Build in-app messaging with our flexible SDKs and APIs.',
    description: 'Optional subtitle or description of the link.',
  );
  final url = context.knobs.string(
    label: 'URL',
    initialValue: 'https://getstream.io/chat/docs/',
    description: 'The link URL displayed in the preview.',
  );
  final showImage = context.knobs.boolean(
    label: 'Show image',
    initialValue: true,
    description: 'Whether to show the link preview thumbnail image.',
  );
  final showRemoveButton = context.knobs.boolean(
    label: 'Show remove button',
    initialValue: true,
    description: 'Whether to show the remove attachment control.',
  );

  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: MessageComposerAttachmentLinkPreview(
        title: title.isEmpty ? null : title,
        subtitle: subtitle.isEmpty ? null : subtitle,
        url: url.isEmpty ? null : url,
        image: showImage ? const AssetImage('assets/attachment_image.png') : null,
        onRemovePressed: showRemoveButton ? () {} : null,
      ),
    ),
  );
}
