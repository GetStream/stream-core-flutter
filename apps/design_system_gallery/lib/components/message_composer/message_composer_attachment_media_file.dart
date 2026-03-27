import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: MessageComposerMediaFileAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentMediaFilePlayground(BuildContext context) {
  final showBadge = context.knobs.boolean(
    label: 'Show Media Badge',
    description: 'Toggle a source badge overlay (e.g. Giphy).',
  );

  final badgeType = showBadge
      ? context.knobs.object.dropdown<MediaBadgeType>(
          label: 'Badge Type',
          options: MediaBadgeType.values,
          labelBuilder: (v) => v.name,
          description: 'Video or audio badge type.',
        )
      : null;

  final showRemoveButton = context.knobs.boolean(
    label: 'Show Remove Button',
    initialValue: true,
    description: 'Toggle the remove attachment control.',
  );

  return Center(
    child: MessageComposerMediaFileAttachment.image(
      image: const AssetImage('assets/attachment_image.png'),
      onRemovePressed: showRemoveButton ? () {} : null,
      mediaBadge: badgeType != null
          ? StreamMediaBadge(type: badgeType, duration: const Duration(minutes: 2, seconds: 34))
          : null,
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: MessageComposerMediaFileAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentMediaFileShowcase(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        _BasicSection(),
        _BadgeSection(),
        _CompositionSection(),
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
      description: 'A 72x72 thumbnail with a remove control.',
      children: [
        _ExampleCard(
          label: 'Image attachment',
          child: MessageComposerMediaFileAttachment.image(
            image: const AssetImage('assets/attachment_image.png'),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'Without remove button',
          child: MessageComposerMediaFileAttachment.image(
            image: const AssetImage('assets/attachment_image.png'),
            onRemovePressed: null,
          ),
        ),
      ],
    );
  }
}

class _BadgeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'MEDIA BADGE',
      description: 'An optional media badge overlay at the bottom-start corner.',
      children: [
        _ExampleCard(
          label: 'Video badge',
          child: MessageComposerMediaFileAttachment.image(
            image: const AssetImage('assets/attachment_image.png'),
            onRemovePressed: () {},
            mediaBadge: const StreamMediaBadge(
              type: MediaBadgeType.video,
              duration: Duration(minutes: 1, seconds: 42),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Audio badge',
          child: MessageComposerMediaFileAttachment.image(
            image: const AssetImage('assets/attachment_image.png'),
            onRemovePressed: () {},
            mediaBadge: const StreamMediaBadge(
              type: MediaBadgeType.audio,
              duration: Duration(seconds: 30),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompositionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return _Section(
      label: 'HORIZONTAL LIST',
      description: 'Multiple media attachments in a scrollable row, as seen in the composer.',
      children: [
        _ExampleCard(
          label: 'Mixed attachments',
          child: SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                MessageComposerMediaFileAttachment.image(
                  image: const AssetImage('assets/attachment_image.png'),
                  onRemovePressed: () {},
                ),
                SizedBox(width: spacing.xxs),
                MessageComposerMediaFileAttachment.image(
                  image: const AssetImage('assets/attachment_image.png'),
                  onRemovePressed: () {},
                  mediaBadge: const StreamMediaBadge(
                    type: MediaBadgeType.video,
                    duration: Duration(minutes: 3, seconds: 15),
                  ),
                ),
                SizedBox(width: spacing.xxs),
                MessageComposerMediaFileAttachment.image(
                  image: const AssetImage('assets/attachment_image.png'),
                  onRemovePressed: () {},
                ),
              ],
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
