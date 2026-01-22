import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _sampleImages = [
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
  'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200',
];

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamAvatarStack,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarStackPlayground(BuildContext context) {
  final avatarCount = context.knobs.int.slider(
    label: 'Avatar Count',
    initialValue: 4,
    min: 1,
    max: 10,
    description: 'Total number of avatars in the stack.',
  );

  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: StreamAvatarSize.values,
    initialOption: StreamAvatarSize.md,
    labelBuilder: (option) => '${option.name.toUpperCase()} (${option.value.toInt()}px)',
    description: 'Size of each avatar in the stack.',
  );

  final overlap = context.knobs.double.slider(
    label: 'Overlap',
    initialValue: 0.3,
    max: 0.8,
    description: 'How much avatars overlap (0 = none, 0.8 = 80%).',
  );

  final maxAvatars = context.knobs.int.slider(
    label: 'Max Visible',
    initialValue: 5,
    min: 2,
    max: 10,
    description: 'Max avatars shown before "+N" indicator.',
  );

  final showImages = context.knobs.boolean(
    label: 'Show Images',
    initialValue: true,
    description: 'Use images or show initials placeholder.',
  );

  final colorScheme = StreamTheme.of(context).colorScheme;
  final palette = colorScheme.avatarPalette;

  return Center(
    child: StreamAvatarStack(
      size: size,
      overlap: overlap,
      max: maxAvatars,
      children: [
        for (var i = 0; i < avatarCount; i++)
          StreamAvatar(
            imageUrl: showImages ? _sampleImages[i % _sampleImages.length] : null,
            backgroundColor: palette[i % palette.length].backgroundColor,
            foregroundColor: palette[i % palette.length].foregroundColor,
            placeholder: (context) => Text(_getInitials(i)),
          ),
      ],
    ),
  );
}

// =============================================================================
// Real-world Example
// =============================================================================

@widgetbook.UseCase(
  name: 'Real-world Example',
  type: StreamAvatarStack,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarStackExample(BuildContext context) {
  final theme = StreamTheme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;
  final palette = colorScheme.avatarPalette;

  return Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Common Patterns',
            style: textTheme.headingSm.copyWith(
              color: colorScheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Group chat
          Container(
            padding: const EdgeInsets.all(12),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colorScheme.backgroundApp,
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.borderSurfaceSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamAvatarStack(
                  size: StreamAvatarSize.sm,
                  children: [
                    for (var i = 0; i < 3; i++)
                      StreamAvatar(
                        imageUrl: _sampleImages[i],
                        backgroundColor: palette[i % palette.length].backgroundColor,
                        foregroundColor: palette[i % palette.length].foregroundColor,
                        placeholder: (context) => Text(_getInitials(i)),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'John, Sarah, Mike',
                      style: textTheme.bodyEmphasis.copyWith(
                        color: colorScheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Active now',
                      style: textTheme.captionDefault.copyWith(
                        color: colorScheme.accentSuccess,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Team with overflow
          Container(
            padding: const EdgeInsets.all(12),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colorScheme.backgroundApp,
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.borderSurfaceSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamAvatarStack(
                  size: StreamAvatarSize.sm,
                  max: 4,
                  children: [
                    for (var i = 0; i < 8; i++)
                      StreamAvatar(
                        imageUrl: _sampleImages[i % _sampleImages.length],
                        backgroundColor: palette[i % palette.length].backgroundColor,
                        foregroundColor: palette[i % palette.length].foregroundColor,
                        placeholder: (context) => Text(_getInitials(i)),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Design Team',
                      style: textTheme.bodyEmphasis.copyWith(
                        color: colorScheme.textPrimary,
                      ),
                    ),
                    Text(
                      '8 members',
                      style: textTheme.captionDefault.copyWith(
                        color: colorScheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

String _getInitials(int index) {
  const names = ['AB', 'CD', 'EF', 'GH', 'IJ', 'KL', 'MN', 'OP'];
  return names[index % names.length];
}
