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
  type: StreamAvatar,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarPlayground(BuildContext context) {
  final imageUrl = context.knobs.stringOrNull(
    label: 'Image URL',
    initialValue: _sampleImageUrl,
    description: 'URL for the avatar image. Leave empty to show placeholder.',
  );

  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: StreamAvatarSize.values,
    initialOption: StreamAvatarSize.lg,
    labelBuilder: (option) => '${option.name.toUpperCase()} (${option.value.toInt()}px)',
    description: 'Avatar diameter size preset.',
  );

  final showBorder = context.knobs.boolean(
    label: 'Show Border',
    initialValue: true,
    description: 'Whether to show a border around the avatar.',
  );

  final initials = context.knobs.string(
    label: 'Initials',
    initialValue: 'JD',
    description: 'Text shown when no image is available (max 2 chars).',
  );

  return Center(
    child: StreamAvatar(
      imageUrl: (imageUrl?.isNotEmpty ?? false) ? imageUrl : null,
      size: size,
      showBorder: showBorder,
      placeholder: (context) => Text(
        initials.substring(0, initials.length.clamp(0, 2)).toUpperCase(),
      ),
    ),
  );
}

// =============================================================================
// Size Variants
// =============================================================================

@widgetbook.UseCase(
  name: 'Size Variants',
  type: StreamAvatar,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarSizes(BuildContext context) {
  final theme = StreamTheme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final size in StreamAvatarSize.values) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamAvatar(
                  imageUrl: _sampleImageUrl,
                  size: size,
                  placeholder: (context) => const Text('AB'),
                ),
                const SizedBox(height: 8),
                Text(
                  size.name.toUpperCase(),
                  style: textTheme.captionEmphasis.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
                Text(
                  '${size.value.toInt()}px',
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                ),
              ],
            ),
            if (size != StreamAvatarSize.values.last) const SizedBox(width: 24),
          ],
        ],
      ),
    ),
  );
}

// =============================================================================
// Color Palette
// =============================================================================

@widgetbook.UseCase(
  name: 'Color Palette',
  type: StreamAvatar,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarPalette(BuildContext context) {
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
        children: [
          Text(
            'Theme Avatar Palette',
            style: textTheme.headingSm.copyWith(
              color: colorScheme.textPrimary,
            ),
          ),
          Text(
            'Automatically assigned based on user ID',
            style: textTheme.captionDefault.copyWith(
              color: colorScheme.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (var i = 0; i < palette.length; i++)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamAvatar(
                      size: StreamAvatarSize.lg,
                      backgroundColor: palette[i].backgroundColor,
                      foregroundColor: palette[i].foregroundColor,
                      placeholder: (context) => Text(_getInitials(i)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Palette ${i + 1}',
                      style: textTheme.metadataDefault.copyWith(
                        color: colorScheme.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// Real-world Example
// =============================================================================

@widgetbook.UseCase(
  name: 'Real-world Example',
  type: StreamAvatar,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarExample(BuildContext context) {
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
          // User profile header
          Container(
            padding: const EdgeInsets.all(16),
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
                StreamAvatar(
                  imageUrl: _sampleImageUrl,
                  size: StreamAvatarSize.lg,
                  placeholder: (context) => const Text('JD'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Jane Doe',
                      style: textTheme.headingSm.copyWith(
                        color: colorScheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Product Designer',
                      style: textTheme.bodyDefault.copyWith(
                        color: colorScheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Message list item
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
                StreamAvatar(
                  size: StreamAvatarSize.md,
                  backgroundColor: palette[0].backgroundColor,
                  foregroundColor: palette[0].foregroundColor,
                  placeholder: (context) => const Text('JD'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'John Doe',
                      style: textTheme.bodyEmphasis.copyWith(
                        color: colorScheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Hey! Are you free for a call?',
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
  const names = ['AB', 'CD', 'EF', 'GH', 'IJ'];
  return names[index % names.length];
}
