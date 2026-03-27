import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: MessageComposerLinkPreviewAttachment,
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
    label: 'Show Image',
    initialValue: true,
    description: 'Toggle the link preview thumbnail image.',
  );
  final showRemoveButton = context.knobs.boolean(
    label: 'Show Remove Button',
    initialValue: true,
    description: 'Toggle the remove attachment control.',
  );

  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: MessageComposerLinkPreviewAttachment(
        title: title.isEmpty ? null : title,
        subtitle: subtitle.isEmpty ? null : subtitle,
        url: url.isEmpty ? null : url,
        image: showImage ? const AssetImage('assets/attachment_image.png') : null,
        onRemovePressed: showRemoveButton ? () {} : null,
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: MessageComposerLinkPreviewAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentLinkPreviewShowcase(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        _FullPreviewSection(),
        _PartialPreviewSection(),
      ],
    ),
  );
}

// =============================================================================
// Showcase Sections
// =============================================================================

class _FullPreviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'FULL PREVIEW',
      description: 'All fields populated: image, title, subtitle, and URL.',
      children: [
        _ExampleCard(
          label: 'Complete link preview',
          child: MessageComposerLinkPreviewAttachment(
            title: 'Stream Chat Flutter SDK',
            subtitle: 'Build real-time chat with our powerful Flutter SDK.',
            url: 'https://getstream.io/chat/sdk/flutter/',
            image: AssetImage('assets/attachment_image.png'),
          ),
        ),
      ],
    );
  }
}

class _PartialPreviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'PARTIAL PREVIEWS',
      description: 'Each field is optional. The layout adapts to available content.',
      children: [
        _ExampleCard(
          label: 'Title + URL only',
          child: MessageComposerLinkPreviewAttachment(
            title: 'Flutter Documentation',
            url: 'https://docs.flutter.dev',
          ),
        ),
        _ExampleCard(
          label: 'URL only',
          child: MessageComposerLinkPreviewAttachment(
            url: 'https://getstream.io',
          ),
        ),
        _ExampleCard(
          label: 'Image + title + subtitle (no URL)',
          child: MessageComposerLinkPreviewAttachment(
            title: 'Beautiful Landscapes',
            subtitle: 'A collection of stunning nature photography.',
            image: AssetImage('assets/attachment_image.png'),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.children,
    this.description,
  });

  final String label;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: colorScheme.accentPrimary,
              ),
            ),
            if (description case final desc?)
              Text(desc, style: TextStyle(fontSize: 13, color: colorScheme.textTertiary)),
          ],
        ),
        ...children,
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.backgroundApp,
        borderRadius: BorderRadius.all(radius.md),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.textSecondary),
          ),
          child,
        ],
      ),
    );
  }
}
