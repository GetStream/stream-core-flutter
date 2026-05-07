import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageComposerReplyAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentReplyPlayground(BuildContext context) {
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Reply to John Doe',
    description: 'The title line, typically the author name.',
  );

  final subtitle = context.knobs.string(
    label: 'Subtitle',
    initialValue: 'We had a great time during our holiday.',
    description: 'The subtitle line, typically the message preview.',
  );

  final style = context.knobs.object.dropdown<StreamReplyDirection>(
    label: 'Style',
    options: StreamReplyDirection.values,
    initialOption: StreamReplyDirection.incoming,
    labelBuilder: (option) => option.name,
    description: 'Incoming uses left-hand bar and incoming colors; outgoing uses right-hand bar and outgoing colors.',
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
      child: StreamMessageComposerReplyAttachment(
        title: Text(title),
        subtitle: Text(subtitle),
        thumbnail: showThumbnail ? _Thumbnail() : null,
        onRemovePressed: showRemoveButton ? () {} : null,
        direction: style,
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMessageComposerReplyAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentReplyShowcase(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        _ReplyStyleSection(),
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

class _ReplyStyleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'REPLY STYLE',
      description: 'Incoming vs outgoing reply styling with different indicator colors and backgrounds.',
      children: [
        _ExampleCard(
          label: 'Incoming',
          child: StreamMessageComposerReplyAttachment(
            title: const Text('Reply to Alice'),
            subtitle: const Text('Did you see the sunset yesterday?'),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'Outgoing',
          child: StreamMessageComposerReplyAttachment(
            title: const Text('Reply to You'),
            subtitle: const Text('Sure, I can help with that!'),
            onRemovePressed: () {},
            direction: StreamReplyDirection.outgoing,
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
      description: 'A trailing thumbnail for replies to media messages.',
      children: [
        _ExampleCard(
          label: 'Incoming with image',
          child: StreamMessageComposerReplyAttachment(
            title: const Text('Reply to Bob'),
            subtitle: const Text('Check out this photo from our trip!'),
            thumbnail: _Thumbnail(),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'Outgoing with image',
          child: StreamMessageComposerReplyAttachment(
            title: const Text('Reply to You'),
            subtitle: const Text('Here is the document you requested.'),
            thumbnail: _Thumbnail(),
            onRemovePressed: () {},
            direction: StreamReplyDirection.outgoing,
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
      description: 'A file-type icon as the thumbnail for replies to non-media attachments.',
      children: [
        _ExampleCard(
          label: 'Incoming with PDF',
          child: StreamMessageComposerReplyAttachment(
            title: const Text('Reply to Alice'),
            subtitle: const Text('annual_report.pdf'),
            thumbnail: StreamFileTypeIcon(type: StreamFileType.pdf),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'Outgoing with spreadsheet',
          child: StreamMessageComposerReplyAttachment(
            title: const Text('Reply to You'),
            subtitle: const Text('project_budget.xlsx'),
            thumbnail: StreamFileTypeIcon(type: StreamFileType.spreadsheet),
            onRemovePressed: () {},
            direction: StreamReplyDirection.outgoing,
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
          'When a parent bounds the width, long titles and subtitles ellipsize on a '
          'single line rather than wrap.',
      children: [
        _ExampleCard(
          label: 'Bounded to 280',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: StreamMessageComposerReplyAttachment(
              title: const Text('Reply to Charlotte Bennett-Williams'),
              subtitle: const Text(
                'Here is a very long message that will not fit on a single line at this width.',
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
