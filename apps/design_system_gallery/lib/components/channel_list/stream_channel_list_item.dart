import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _sampleImageUrl = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200';

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamChannelListItem,
  path: '[Components]/Channel List',
)
Widget buildStreamChannelListItemPlayground(BuildContext context) {
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Design Team',
    description: 'The channel name.',
  );

  final subtitle = context.knobs.stringOrNull(
    label: 'Subtitle',
    initialValue: 'New mockups ready for review',
    description: 'The message preview text.',
  );

  final timestamp = context.knobs.stringOrNull(
    label: 'Timestamp',
    initialValue: '9:41',
    description: 'The formatted timestamp.',
  );

  final unreadCount = context.knobs.int.slider(
    label: 'Unread Count',
    initialValue: 3,
    max: 99,
    description: 'Number of unread messages. Shows a badge when > 0.',
  );

  final showMuteIcon = context.knobs.boolean(
    label: 'Show Mute Icon',
    description: 'Display a mute icon after the title.',
  );

  final colorScheme = context.streamColorScheme;

  return ColoredBox(
    color: colorScheme.backgroundApp,
    child: Center(
      child: StreamChannelListItem(
        avatar: StreamOnlineIndicator(
          isOnline: true,
          child: StreamAvatar(
            imageUrl: _sampleImageUrl,
            size: StreamAvatarSize.xl,
            placeholder: (context) => const Text('DT'),
          ),
        ),
        title: Text(title),
        isMuted: showMuteIcon,
        subtitle: subtitle != null ? Text(subtitle) : null,
        timestamp: timestamp != null ? Text(timestamp) : null,
        unreadCount: unreadCount,
        onTap: () => print('onTap'),
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamChannelListItem,
  path: '[Components]/Channel List',
)
Widget buildStreamChannelListItemShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: ColoredBox(
      color: colorScheme.backgroundApp,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DirectMessageSection(),
            SizedBox(height: spacing.xl),
            const _GroupChannelSection(),
            SizedBox(height: spacing.xl),
            const _EdgeCasesSection(),
          ],
        ),
      ),
    ),
  );
}

// =============================================================================
// Direct Message Section
// =============================================================================

class _DirectMessageSection extends StatelessWidget {
  const _DirectMessageSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'DIRECT MESSAGES'),
        SizedBox(height: spacing.md),
        _ShowcaseCard(
          description: 'One-on-one conversations with online indicator',
          child: Column(
            children: [
              StreamChannelListItem(
                avatar: StreamOnlineIndicator(
                  isOnline: true,
                  child: StreamAvatar(
                    imageUrl: _sampleImageUrl,
                    size: StreamAvatarSize.xl,
                    placeholder: (context) => const Text('JD'),
                  ),
                ),
                title: const Text('Jane Doe'),
                subtitle: const Text('Hey! Are you free for a call?'),
                timestamp: const Text('9:41'),
                unreadCount: 3,
              ),
              StreamChannelListItem(
                avatar: StreamOnlineIndicator(
                  isOnline: false,
                  child: StreamAvatar(
                    size: StreamAvatarSize.xl,
                    placeholder: (context) => const Text('BS'),
                  ),
                ),
                title: const Text('Bob Smith'),
                subtitle: const Text('Thanks for the update!'),
                timestamp: const Text('Yesterday'),
              ),
              StreamChannelListItem(
                avatar: StreamOnlineIndicator(
                  isOnline: true,
                  child: StreamAvatar(
                    size: StreamAvatarSize.xl,
                    backgroundColor: colorScheme.avatarPalette[2].backgroundColor,
                    foregroundColor: colorScheme.avatarPalette[2].foregroundColor,
                    placeholder: (context) => const Text('CW'),
                  ),
                ),
                title: const Text('Carol White'),
                subtitle: const Text('See you tomorrow!'),
                timestamp: const Text('Saturday'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Group Channel Section
// =============================================================================

class _GroupChannelSection extends StatelessWidget {
  const _GroupChannelSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'GROUP CHANNELS'),
        SizedBox(height: spacing.md),
        _ShowcaseCard(
          description: 'Group conversations with sender prefix and mute icon',
          child: Column(
            children: [
              StreamChannelListItem(
                avatar: StreamAvatarGroup(
                  size: StreamAvatarGroupSize.xl,
                  children: [
                    StreamAvatar(placeholder: (context) => const Text('JD')),
                    StreamAvatar(
                      imageUrl: _sampleImageUrl,
                      placeholder: (context) => const Text('AB'),
                    ),
                    StreamAvatar(
                      backgroundColor: colorScheme.avatarPalette[1].backgroundColor,
                      foregroundColor: colorScheme.avatarPalette[1].foregroundColor,
                      placeholder: (context) => const Text('CW'),
                    ),
                  ],
                ),
                title: const Text('Design Team'),
                subtitle: const Text('Alice: New mockups ready for review'),
                timestamp: const Text('9:41'),
                unreadCount: 5,
              ),
              StreamChannelListItem(
                avatar: StreamAvatarGroup(
                  size: StreamAvatarGroupSize.xl,
                  children: [
                    StreamAvatar(placeholder: (context) => const Text('EF')),
                    StreamAvatar(placeholder: (context) => const Text('GH')),
                  ],
                ),
                title: const Text('Engineering'),
                subtitle: const Text('Bob: PR merged successfully'),
                timestamp: const Text('10:15'),
                unreadCount: 12,
              ),
              StreamChannelListItem(
                avatar: StreamAvatarGroup(
                  size: StreamAvatarGroupSize.xl,
                  children: [
                    StreamAvatar(placeholder: (context) => const Text('IJ')),
                    StreamAvatar(placeholder: (context) => const Text('KL')),
                    StreamAvatar(placeholder: (context) => const Text('MN')),
                  ],
                ),
                title: const Text('Muted Group'),
                isMuted: true,
                subtitle: const Text('Carol: Meeting notes attached'),
                timestamp: const Text('Yesterday'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Edge Cases Section
// =============================================================================

class _EdgeCasesSection extends StatelessWidget {
  const _EdgeCasesSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'EDGE CASES'),
        SizedBox(height: spacing.md),
        _ShowcaseCard(
          description: 'Long text, no unread, and minimal content',
          child: Column(
            children: [
              StreamChannelListItem(
                avatar: StreamAvatar(
                  size: StreamAvatarSize.xl,
                  placeholder: (context) => const Text('LT'),
                ),
                title: const Text('Very Long Channel Name That Should Be Truncated Properly'),
                subtitle: const Text(
                  'This is a very long message preview that should be truncated with an ellipsis when it overflows',
                ),
                timestamp: const Text('01/15/2026'),
                unreadCount: 99,
              ),
              StreamChannelListItem(
                avatar: StreamAvatar(
                  size: StreamAvatarSize.xl,
                  backgroundColor: colorScheme.avatarPalette[3].backgroundColor,
                  foregroundColor: colorScheme.avatarPalette[3].foregroundColor,
                  placeholder: (context) => const Text('NR'),
                ),
                title: const Text('No Unread'),
                subtitle: const Text('All caught up!'),
                timestamp: const Text('3:00'),
              ),
              StreamChannelListItem(
                avatar: StreamAvatar(
                  size: StreamAvatarSize.xl,
                  placeholder: (context) => const Text('MN'),
                ),
                title: const Text('Minimal'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.description,
    required this.child,
  });

  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        borderRadius: BorderRadius.all(radius.lg),
        boxShadow: boxShadow.elevation1,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.md,
              spacing.sm,
              spacing.md,
              spacing.sm,
            ),
            child: Text(
              description,
              style: textTheme.captionDefault.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          ColoredBox(
            color: colorScheme.backgroundApp,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.accentPrimary,
        borderRadius: BorderRadius.all(radius.xs),
      ),
      child: Text(
        label,
        style: textTheme.metadataEmphasis.copyWith(
          color: colorScheme.textOnAccent,
          letterSpacing: 1,
          fontSize: 9,
        ),
      ),
    );
  }
}
