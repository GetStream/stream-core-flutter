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

  final withChild = context.knobs.boolean(
    label: 'With Child',
    description: 'Wrap an avatar as child (Badge-like behavior).',
  );

  final alignment = context.knobs.object.dropdown<AlignmentDirectional>(
    label: 'Alignment',
    options: const [
      AlignmentDirectional.topStart,
      AlignmentDirectional.topCenter,
      AlignmentDirectional.topEnd,
      AlignmentDirectional.centerStart,
      AlignmentDirectional.center,
      AlignmentDirectional.centerEnd,
      AlignmentDirectional.bottomStart,
      AlignmentDirectional.bottomCenter,
      AlignmentDirectional.bottomEnd,
    ],
    initialOption: AlignmentDirectional.topEnd,
    labelBuilder: (option) => switch (option) {
      AlignmentDirectional.topStart => 'Top Start',
      AlignmentDirectional.topCenter => 'Top Center',
      AlignmentDirectional.topEnd => 'Top End',
      AlignmentDirectional.centerStart => 'Center Start',
      AlignmentDirectional.center => 'Center',
      AlignmentDirectional.centerEnd => 'Center End',
      AlignmentDirectional.bottomStart => 'Bottom Start',
      AlignmentDirectional.bottomCenter => 'Bottom Center',
      AlignmentDirectional.bottomEnd => 'Bottom End',
      _ => option.toString(),
    },
    description: 'Alignment of indicator relative to child (directional for RTL support).',
  );

  final offsetX = context.knobs.double.slider(
    label: 'Offset X',
    min: -10,
    max: 10,
    description: 'Horizontal offset for fine-tuning position.',
  );

  final offsetY = context.knobs.double.slider(
    label: 'Offset Y',
    min: -10,
    max: 10,
    description: 'Vertical offset for fine-tuning position.',
  );

  if (withChild) {
    return Center(
      child: StreamOnlineIndicator(
        isOnline: isOnline,
        size: size,
        alignment: alignment,
        offset: Offset(offsetX, offsetY),
        child: StreamAvatar(
          size: StreamAvatarSize.lg,
          placeholder: (context) => const Text('AB'),
        ),
      ),
    );
  }

  return Center(
    child: StreamOnlineIndicator(
      isOnline: isOnline,
      size: size,
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamOnlineIndicator,
  path: '[Components]/Indicator',
)
Widget buildStreamOnlineIndicatorShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size variants
          const _SizeVariantsSection(),
          SizedBox(height: spacing.xl),

          // Alignment variants
          const _AlignmentVariantsSection(),
          SizedBox(height: spacing.xl),

          // Usage patterns
          const _UsagePatternsSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Size Variants Section
// =============================================================================

class _SizeVariantsSection extends StatelessWidget {
  const _SizeVariantsSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'SIZE VARIANTS'),
        SizedBox(height: spacing.md),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
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
              // Online states
              Text(
                'Online',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: [
                  for (final size in StreamOnlineIndicatorSize.values) ...[
                    _SizeDemo(size: size, isOnline: true),
                    if (size != StreamOnlineIndicatorSize.values.last) SizedBox(width: spacing.xl),
                  ],
                ],
              ),
              SizedBox(height: spacing.md),
              Divider(color: colorScheme.borderSubtle),
              SizedBox(height: spacing.md),
              // Offline states
              Text(
                'Offline',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: [
                  for (final size in StreamOnlineIndicatorSize.values) ...[
                    _SizeDemo(size: size, isOnline: false),
                    if (size != StreamOnlineIndicatorSize.values.last) SizedBox(width: spacing.xl),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SizeDemo extends StatelessWidget {
  const _SizeDemo({required this.size, required this.isOnline});

  final StreamOnlineIndicatorSize size;
  final bool isOnline;

  String _getPixelSize(StreamOnlineIndicatorSize size) {
    return switch (size) {
      StreamOnlineIndicatorSize.sm => '8px',
      StreamOnlineIndicatorSize.md => '12px',
      StreamOnlineIndicatorSize.lg => '14px',
      StreamOnlineIndicatorSize.xl => '16px',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: StreamOnlineIndicator(
              isOnline: isOnline,
              size: size,
            ),
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          size.name.toUpperCase(),
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          _getPixelSize(size),
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
            fontFamily: 'monospace',
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Alignment Variants Section
// =============================================================================

class _AlignmentVariantsSection extends StatelessWidget {
  const _AlignmentVariantsSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'ALIGNMENT VARIANTS'),
        SizedBox(height: spacing.md),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
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
              Text(
                'Badge-like positioning with child',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.xl,
                runSpacing: spacing.lg,
                children: const [
                  _AlignmentDemo(
                    alignment: AlignmentDirectional.topStart,
                    label: 'topStart',
                  ),
                  _AlignmentDemo(
                    alignment: AlignmentDirectional.topEnd,
                    label: 'topEnd',
                  ),
                  _AlignmentDemo(
                    alignment: AlignmentDirectional.bottomStart,
                    label: 'bottomStart',
                  ),
                  _AlignmentDemo(
                    alignment: AlignmentDirectional.bottomEnd,
                    label: 'bottomEnd',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlignmentDemo extends StatelessWidget {
  const _AlignmentDemo({required this.alignment, required this.label});

  final AlignmentGeometry alignment;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        StreamOnlineIndicator(
          isOnline: true,
          size: StreamOnlineIndicatorSize.lg,
          alignment: alignment,
          child: StreamAvatar(
            size: StreamAvatarSize.lg,
            placeholder: (context) => const Text('AB'),
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Usage Patterns Section
// =============================================================================

class _UsagePatternsSection extends StatelessWidget {
  const _UsagePatternsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'USAGE PATTERNS'),
        SizedBox(height: spacing.md),

        // Avatar with indicator
        const _ExampleCard(
          title: 'Avatar with Status',
          description: 'Indicator positioned on avatar corner',
          child: Row(
            spacing: 24,
            children: [
              _AvatarWithIndicator(
                name: 'Sarah Chen',
                isOnline: true,
              ),
              _AvatarWithIndicator(
                name: 'Alex Kim',
                isOnline: true,
              ),
              _AvatarWithIndicator(
                name: 'Jordan Lee',
                isOnline: false,
              ),
              _AvatarWithIndicator(
                name: 'Taylor Park',
                isOnline: true,
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.sm),

        // Inline status
        const _ExampleCard(
          title: 'Inline Status',
          description: 'Indicator next to user name',
          child: _InlineStatusGroup(),
        ),
      ],
    );
  }
}

class _AvatarWithIndicator extends StatelessWidget {
  const _AvatarWithIndicator({
    required this.name,
    required this.isOnline,
  });

  final String name;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;
    final initials = name.split(' ').map((n) => n[0]).join();

    return Column(
      children: [
        // Using the new child parameter (Badge-like behavior)
        StreamOnlineIndicator(
          isOnline: isOnline,
          size: StreamOnlineIndicatorSize.lg,
          child: StreamAvatar(
            size: StreamAvatarSize.lg,
            placeholder: (context) => Text(initials),
          ),
        ),
        SizedBox(height: spacing.sm),
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

class _InlineStatusGroup extends StatelessWidget {
  const _InlineStatusGroup();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _InlineStatus(name: 'Online User', isOnline: true),
        SizedBox(height: spacing.sm),
        const _InlineStatus(name: 'Away User', isOnline: false),
      ],
    );
  }
}

class _InlineStatus extends StatelessWidget {
  const _InlineStatus({
    required this.name,
    required this.isOnline,
  });

  final String name;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamOnlineIndicator(
          isOnline: isOnline,
          size: StreamOnlineIndicatorSize.sm,
        ),
        SizedBox(width: spacing.sm),
        Text(
          name,
          style: textTheme.captionDefault.copyWith(
            color: colorScheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
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
        color: colorScheme.backgroundSurfaceSubtle,
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
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.captionEmphasis.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.borderSubtle,
          ),
          // Content
          Container(
            padding: EdgeInsets.all(spacing.md),
            color: colorScheme.backgroundSurface,
            child: child,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

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
      padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
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
