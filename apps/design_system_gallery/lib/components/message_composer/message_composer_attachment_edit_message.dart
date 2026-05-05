import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageComposerEditMessageAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentEditMessagePlayground(BuildContext context) {
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Edit message',
    description: 'The title line, typically a localized "Edit message" label.',
  );

  final subtitle = context.knobs.string(
    label: 'Subtitle',
    initialValue: 'See you at 9!',
    description: 'The subtitle line, typically the body of the message being edited.',
  );

  final showThumbnail = context.knobs.boolean(
    label: 'Show Thumbnail',
    description: 'Toggle a trailing image thumbnail.',
  );

  final showRemoveButton = context.knobs.boolean(
    label: 'Show Remove Button',
    initialValue: true,
    description: 'Toggle the remove attachment control.',
  );

  final maxWidth = context.knobs.double.slider(
    label: 'Parent Max Width',
    initialValue: 360,
    min: 200,
    max: 600,
    description: 'Bounds the parent width. The preview fills this width.',
  );

  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: StreamMessageComposerEditMessageAttachment(
        title: Text(title),
        subtitle: Text(subtitle),
        thumbnail: showThumbnail ? _Thumbnail() : null,
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
  type: StreamMessageComposerEditMessageAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentEditMessageShowcase(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        _BasicSection(),
        _ThumbnailSection(),
        _FileThumbnailSection(),
        _ConstrainedSection(),
      ],
    ),
  );
}

// =============================================================================
// Showcase Sections
// =============================================================================

class _BasicSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'BASIC',
      description: 'Edit-message preview with brand-tinted background and indicator.',
      children: [
        _ExampleCard(
          label: 'Short message',
          child: StreamMessageComposerEditMessageAttachment(
            title: const Text('Edit message'),
            subtitle: const Text('See you at 9!'),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'Long message',
          child: StreamMessageComposerEditMessageAttachment(
            title: const Text('Edit message'),
            subtitle: const Text('We had a great time during our holiday and the views were stunning all week.'),
            onRemovePressed: () {},
          ),
        ),
      ],
    );
  }
}

class _ThumbnailSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'WITH THUMBNAIL',
      description: 'A trailing thumbnail for edits to messages with attached media.',
      children: [
        _ExampleCard(
          label: 'With image thumbnail',
          child: StreamMessageComposerEditMessageAttachment(
            title: const Text('Edit message'),
            subtitle: const Text('Here is the document you requested.'),
            thumbnail: _Thumbnail(),
            onRemovePressed: () {},
          ),
        ),
      ],
    );
  }
}

class _FileThumbnailSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'WITH FILE ICON',
      description: 'A file-type icon as the thumbnail for editing non-media attachments.',
      children: [
        _ExampleCard(
          label: 'With PDF',
          child: StreamMessageComposerEditMessageAttachment(
            title: const Text('Edit message'),
            subtitle: const Text('annual_report.pdf'),
            thumbnail: StreamFileTypeIcon(type: StreamFileType.pdf),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'With spreadsheet',
          child: StreamMessageComposerEditMessageAttachment(
            title: const Text('Edit message'),
            subtitle: const Text('project_budget.xlsx'),
            thumbnail: StreamFileTypeIcon(type: StreamFileType.spreadsheet),
            onRemovePressed: () {},
          ),
        ),
      ],
    );
  }
}

class _ConstrainedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'CONSTRAINED MAX WIDTH',
      description:
          'When a parent bounds the width, the message body ellipsizes on a single '
          'line rather than wrap.',
      children: [
        _ExampleCard(
          label: 'Bounded to 280',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: StreamMessageComposerEditMessageAttachment(
              title: const Text('Edit message'),
              subtitle: const Text(
                'A long message body that exceeds the available width and ellipsizes.',
              ),
              onRemovePressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

class _Thumbnail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(context.streamRadius.md),
        image: const DecorationImage(
          image: AssetImage('assets/attachment_image.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

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
              style: context.streamTextTheme.metadataEmphasis.copyWith(
                letterSpacing: 1.2,
                color: colorScheme.accentPrimary,
              ),
            ),
            if (description case final desc?)
              Text(desc, style: context.streamTextTheme.metadataDefault.copyWith(color: colorScheme.textTertiary)),
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
            style: context.streamTextTheme.metadataEmphasis.copyWith(color: colorScheme.textSecondary),
          ),
          child,
        ],
      ),
    );
  }
}
