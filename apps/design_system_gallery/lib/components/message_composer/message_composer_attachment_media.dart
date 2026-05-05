import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageComposerMediaAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentMediaPlayground(BuildContext context) {
  final size = context.knobs.double.slider(
    label: 'Thumbnail Size',
    initialValue: 72,
    min: 48,
    max: 160,
    description: 'The square thumbnail edge length, in logical pixels.',
  );

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
    child: StreamMessageComposerMediaAttachment(
      onRemovePressed: showRemoveButton ? () {} : null,
      mediaBadge: badgeType != null
          ? StreamMediaBadge(type: badgeType, duration: const Duration(minutes: 2, seconds: 34))
          : null,
      style: StreamMessageComposerMediaAttachmentThemeData(size: Size.square(size)),
      child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMessageComposerMediaAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentMediaShowcase(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        _BasicSection(),
        _SizeSection(),
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
          child: StreamMessageComposerMediaAttachment(
            onRemovePressed: () {},
            child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
          ),
        ),
        _ExampleCard(
          label: 'Without remove button',
          child: StreamMessageComposerMediaAttachment(
            child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}

class _SizeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return _Section(
      label: 'SIZE',
      description: 'Override the thumbnail size via the per-instance style.',
      children: [
        _ExampleCard(
          label: 'Small (56), Default (72), Medium (96), Large (128)',
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              StreamMessageComposerMediaAttachment(
                onRemovePressed: () {},
                style: const StreamMessageComposerMediaAttachmentThemeData(size: Size.square(56)),
                child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
              ),
              StreamMessageComposerMediaAttachment(
                onRemovePressed: () {},
                child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
              ),
              StreamMessageComposerMediaAttachment(
                onRemovePressed: () {},
                style: const StreamMessageComposerMediaAttachmentThemeData(size: Size.square(96)),
                child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
              ),
              StreamMessageComposerMediaAttachment(
                onRemovePressed: () {},
                style: const StreamMessageComposerMediaAttachmentThemeData(size: Size.square(128)),
                child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
              ),
            ],
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
          child: StreamMessageComposerMediaAttachment(
            onRemovePressed: () {},
            mediaBadge: const StreamMediaBadge(
              type: MediaBadgeType.video,
              duration: Duration(minutes: 1, seconds: 42),
            ),
            child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
          ),
        ),
        _ExampleCard(
          label: 'Audio badge',
          child: StreamMessageComposerMediaAttachment(
            onRemovePressed: () {},
            mediaBadge: const StreamMediaBadge(
              type: MediaBadgeType.audio,
              duration: Duration(seconds: 30),
            ),
            child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
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
                StreamMessageComposerMediaAttachment(
                  onRemovePressed: () {},
                  child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
                ),
                SizedBox(width: spacing.xxs),
                StreamMessageComposerMediaAttachment(
                  onRemovePressed: () {},
                  mediaBadge: const StreamMediaBadge(
                    type: MediaBadgeType.video,
                    duration: Duration(minutes: 3, seconds: 15),
                  ),
                  child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
                ),
                SizedBox(width: spacing.xxs),
                StreamMessageComposerMediaAttachment(
                  onRemovePressed: () {},
                  child: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
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
