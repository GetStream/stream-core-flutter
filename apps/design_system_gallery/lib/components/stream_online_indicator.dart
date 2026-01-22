import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamOnlineIndicator,
  path: '[Components]/Indicator',
)
Widget buildStreamOnlineIndicatorPlayground(BuildContext context) {
  final isOnline = context.knobs.boolean(
    label: 'Is Online',
    initialValue: true,
    description: 'Whether the user is currently online.',
  );

  final size = context.knobs.object.dropdown<StreamOnlineIndicatorSize>(
    label: 'Size',
    options: StreamOnlineIndicatorSize.values,
    initialOption: StreamOnlineIndicatorSize.lg,
    labelBuilder: (option) => option.name.toUpperCase(),
    description: 'The size of the indicator.',
  );

  return Center(
    child: StreamOnlineIndicator(
      isOnline: isOnline,
      size: size,
    ),
  );
}

// =============================================================================
// Size Variants
// =============================================================================

@widgetbook.UseCase(
  name: 'Size Variants',
  type: StreamOnlineIndicator,
  path: '[Components]/Indicator',
)
Widget buildStreamOnlineIndicatorSizes(BuildContext context) {
  final streamTheme = StreamTheme.of(context);
  final textTheme = streamTheme.textTheme;
  final colorScheme = streamTheme.colorScheme;

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SizeVariant(
          label: 'Small (8px)',
          size: StreamOnlineIndicatorSize.sm,
          isOnline: true,
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 24),
        _SizeVariant(
          label: 'Medium (12px)',
          size: StreamOnlineIndicatorSize.md,
          isOnline: true,
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 24),
        _SizeVariant(
          label: 'Large (14px)',
          size: StreamOnlineIndicatorSize.lg,
          isOnline: true,
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 32),
        Divider(color: colorScheme.borderSurfaceSubtle),
        const SizedBox(height: 32),
        _SizeVariant(
          label: 'Small (8px)',
          size: StreamOnlineIndicatorSize.sm,
          isOnline: false,
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 24),
        _SizeVariant(
          label: 'Medium (12px)',
          size: StreamOnlineIndicatorSize.md,
          isOnline: false,
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 24),
        _SizeVariant(
          label: 'Large (14px)',
          size: StreamOnlineIndicatorSize.lg,
          isOnline: false,
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
      ],
    ),
  );
}

class _SizeVariant extends StatelessWidget {
  const _SizeVariant({
    required this.label,
    required this.size,
    required this.isOnline,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final StreamOnlineIndicatorSize size;
  final bool isOnline;
  final StreamTextTheme textTheme;
  final StreamColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamOnlineIndicator(
          isOnline: isOnline,
          size: size,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.captionEmphasis.copyWith(
                color: colorScheme.textPrimary,
              ),
            ),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: textTheme.metadataDefault.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// Real-world Example
// =============================================================================

@widgetbook.UseCase(
  name: 'Real-world Example',
  type: StreamOnlineIndicator,
  path: '[Components]/Indicator',
)
Widget buildStreamOnlineIndicatorExample(BuildContext context) {
  final streamTheme = StreamTheme.of(context);
  final textTheme = streamTheme.textTheme;
  final colorScheme = streamTheme.colorScheme;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Online Status Indicators',
            style: textTheme.headingSm.copyWith(
              color: colorScheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Indicators positioned on avatars to show presence',
            style: textTheme.captionDefault.copyWith(
              color: colorScheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _AvatarWithIndicator(
                name: 'Sarah Chen',
                isOnline: true,
                textTheme: textTheme,
                colorScheme: colorScheme,
              ),
              _AvatarWithIndicator(
                name: 'Alex Kim',
                isOnline: true,
                textTheme: textTheme,
                colorScheme: colorScheme,
              ),
              _AvatarWithIndicator(
                name: 'Jordan Lee',
                isOnline: false,
                textTheme: textTheme,
                colorScheme: colorScheme,
              ),
              _AvatarWithIndicator(
                name: 'Taylor Park',
                isOnline: true,
                textTheme: textTheme,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _AvatarWithIndicator extends StatelessWidget {
  const _AvatarWithIndicator({
    required this.name,
    required this.isOnline,
    required this.textTheme,
    required this.colorScheme,
  });

  final String name;
  final bool isOnline;
  final StreamTextTheme textTheme;
  final StreamColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').map((n) => n[0]).join();

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            StreamAvatar(
              size: StreamAvatarSize.lg,
              placeholder: (context) => Text(
                initials,
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textOnAccent,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: StreamOnlineIndicator(
                isOnline: isOnline,
                size: StreamOnlineIndicatorSize.lg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: textTheme.captionDefault.copyWith(
            color: colorScheme.textPrimary,
          ),
        ),
        Text(
          isOnline ? 'Online' : 'Offline',
          style: textTheme.metadataDefault.copyWith(
            color: isOnline ? colorScheme.accentSuccess : colorScheme.textTertiary,
          ),
        ),
      ],
    );
  }
}
