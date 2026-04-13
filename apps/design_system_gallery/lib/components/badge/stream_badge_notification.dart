import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamBadgeNotification,
  path: '[Components]/Badge',
)
Widget buildStreamBadgeNotificationPlayground(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: '1',
    description: 'The text to display in the badge.',
  );

  final type = context.knobs.object.dropdown<StreamBadgeNotificationType>(
    label: 'Type',
    options: StreamBadgeNotificationType.values,
    initialOption: StreamBadgeNotificationType.primary,
    labelBuilder: (option) => option.name[0].toUpperCase() + option.name.substring(1),
    description: 'The visual type of the badge.',
  );

  final size = context.knobs.object.dropdown<StreamBadgeNotificationSize>(
    label: 'Size',
    options: StreamBadgeNotificationSize.values,
    initialOption: StreamBadgeNotificationSize.sm,
    labelBuilder: (option) => '${option.name.toUpperCase()} (${option.value.toInt()}px)',
    description: 'The size of the badge.',
  );

  final withChild = context.knobs.boolean(
    label: 'With Child',
    description: 'Wrap an icon as child (Badge-like behavior).',
  );

  if (withChild) {
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
      description: 'Alignment of badge relative to child (directional for RTL support).',
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

    return Center(
      child: StreamBadgeNotification(
        label: label,
        type: type,
        size: size,
        alignment: alignment,
        offset: Offset(offsetX, offsetY),
        child: const Icon(Icons.chat_bubble_outline, size: 36),
      ),
    );
  }

  return Center(
    child: StreamBadgeNotification(
      label: label,
      type: type,
      size: size,
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamBadgeNotification,
  path: '[Components]/Badge',
)
Widget buildStreamBadgeNotificationShowcase(BuildContext context) {
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
          const _TypeVariantsSection(),
          SizedBox(height: spacing.xl),
          const _SizeVariantsSection(),
          SizedBox(height: spacing.xl),
          const _AlignmentVariantsSection(),
          SizedBox(height: spacing.xl),
          const _CountVariantsSection(),
          SizedBox(height: spacing.xl),
          const _UsagePatternsSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Type Variants Section
// =============================================================================

class _TypeVariantsSection extends StatelessWidget {
  const _TypeVariantsSection();

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
        const _SectionLabel(label: 'TYPE VARIANTS'),
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
                'Badge types determine background color',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  for (final type in StreamBadgeNotificationType.values) ...[
                    _TypeDemo(type: type),
                    if (type != StreamBadgeNotificationType.values.last) SizedBox(width: spacing.xl),
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

class _TypeDemo extends StatelessWidget {
  const _TypeDemo({required this.type});

  final StreamBadgeNotificationType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        SizedBox(
          width: 48,
          height: 32,
          child: Center(
            child: StreamBadgeNotification(
              label: '1',
              type: type,
            ),
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          type.name[0].toUpperCase() + type.name.substring(1),
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
              Text(
                'Two sizes for different contexts',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  for (final size in StreamBadgeNotificationSize.values) ...[
                    _SizeDemo(size: size),
                    if (size != StreamBadgeNotificationSize.values.last) SizedBox(width: spacing.xl),
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
  const _SizeDemo({required this.size});

  final StreamBadgeNotificationSize size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        SizedBox(
          width: 48,
          height: 32,
          child: Center(
            child: StreamBadgeNotification(
              label: '5',
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
          '${size.value.toInt()}px',
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
// Count Variants Section
// =============================================================================

class _CountVariantsSection extends StatelessWidget {
  const _CountVariantsSection();

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
        const _SectionLabel(label: 'COUNT VARIANTS'),
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
                'Badge adapts width based on count',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.md,
                runSpacing: spacing.md,
                children: const [
                  _CountDemo(count: 1),
                  _CountDemo(count: 9),
                  _CountDemo(count: 25),
                  _CountDemo(count: 99),
                  _CountDemo(count: 100),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountDemo extends StatelessWidget {
  const _CountDemo({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    final displayText = count > 99 ? '99+' : '$count';

    return Column(
      children: [
        StreamBadgeNotification(label: displayText),
        SizedBox(height: spacing.xs),
        Text(
          displayText,
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
            fontFamily: 'monospace',
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
        StreamBadgeNotification(
          label: '3',
          size: StreamBadgeNotificationSize.xs,
          alignment: alignment,
          child: Icon(
            Icons.chat_bubble_outline,
            size: 36,
            color: colorScheme.textSecondary,
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

        const _ExampleCard(
          title: 'Icon with Notification',
          description: 'Badge positioned on icon using child',
          child: _IconWithNotificationGroup(),
        ),
      ],
    );
  }
}

class _IconWithNotificationGroup extends StatelessWidget {
  const _IconWithNotificationGroup();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return Row(
      children: [
        _IconWithNotification(
          icon: Icons.chat_bubble_outline,
          label: 'Chat',
          count: 3,
          color: colorScheme.textSecondary,
        ),
        SizedBox(width: spacing.xl),
        _IconWithNotification(
          icon: Icons.notifications_outlined,
          label: 'Alerts',
          count: 12,
          color: colorScheme.textSecondary,
        ),
        SizedBox(width: spacing.xl),
        _IconWithNotification(
          icon: Icons.inbox_outlined,
          label: 'Inbox',
          count: 99,
          color: colorScheme.textSecondary,
        ),
        SizedBox(width: spacing.xl),
        _IconWithNotification(
          icon: Icons.mail_outline,
          label: 'Mail',
          count: 150,
          color: colorScheme.textSecondary,
        ),
      ],
    );
  }
}

class _IconWithNotification extends StatelessWidget {
  const _IconWithNotification({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;
    final displayText = count > 99 ? '99+' : '$count';

    return Column(
      children: [
        StreamBadgeNotification(
          label: displayText,
          size: StreamBadgeNotificationSize.xs,
          child: Icon(icon, size: 36, color: color),
        ),
        SizedBox(height: spacing.sm),
        Text(
          label,
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
