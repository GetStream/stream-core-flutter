import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamImageSourceBadge,
  path: '[Components]/Badge',
)
Widget buildStreamImageSourceBadgePlayground(BuildContext context) {
  final variant = context.knobs.object.dropdown(
    label: 'Variant',
    options: _BadgeVariant.values,
    initialOption: _BadgeVariant.giphy,
    labelBuilder: (v) => v.label,
    description: 'Use a pre-built variant or customize your own.',
  );

  final icons = context.streamIcons;
  final spacing = context.streamSpacing;

  // Pre-built variants short-circuit all other knobs.
  if (variant != _BadgeVariant.custom) {
    final badge = switch (variant) {
      _BadgeVariant.giphy => StreamImageSourceBadge.giphy,
      _BadgeVariant.imgur => StreamImageSourceBadge.imgur,
      _ => StreamImageSourceBadge.giphy,
    };

    return Center(
      child: StreamMessageAttachment(
        child: Stack(
          children: [
            const _PlaceholderAttachment(),
            PositionedDirectional(
              start: spacing.xs,
              bottom: spacing.xs,
              child: badge,
            ),
          ],
        ),
      ),
    );
  }

  // -- Custom variant knobs ---------------------------------------------------

  final leadingIcon = context.knobs.object.dropdown(
    label: 'Leading Icon',
    options: _LeadingOption.values,
    initialOption: _LeadingOption.giphy,
    labelBuilder: (v) => v.label,
    description: 'The leading icon to display.',
  );

  final labelText = context.knobs.string(
    label: 'Label',
    initialValue: 'GIPHY',
    description: 'The source name displayed in the badge.',
  );

  final backgroundColor = context.knobs.object.dropdown<_ColorOption>(
    label: 'Background Color',
    options: _ColorOption.values,
    labelBuilder: (v) => v.label,
    description: 'Override the badge background color.',
  );

  final foregroundColor = context.knobs.object.dropdown<_ColorOption>(
    label: 'Foreground Color',
    options: _ColorOption.values,
    labelBuilder: (v) => v.label,
    description: 'Override the label and icon color.',
  );

  final leading = switch (leadingIcon) {
    _LeadingOption.giphy => SvgIcon(icons.giphy),
    _LeadingOption.imgur => SvgIcon(icons.imgur),
    _LeadingOption.file => Icon(icons.file),
    _LeadingOption.playFill => Icon(icons.playFill),
    _LeadingOption.video => Icon(icons.video),
  };

  final badge = StreamImageSourceBadge(
    leading: leading,
    label: Text(labelText),
    backgroundColor: backgroundColor.color,
    foregroundColor: foregroundColor.color,
  );

  return Center(
    child: StreamMessageAttachment(
      child: Stack(
        children: [
          const _PlaceholderAttachment(),
          PositionedDirectional(
            start: spacing.xs,
            bottom: spacing.xs,
            child: badge,
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// Playground Knob Options
// =============================================================================

enum _BadgeVariant {
  giphy('Giphy'),
  imgur('Imgur'),
  custom('Custom')
  ;

  const _BadgeVariant(this.label);
  final String label;
}

enum _LeadingOption {
  giphy('Giphy (SVG)'),
  imgur('Imgur (SVG)'),
  file('File Icon'),
  playFill('Play Icon'),
  video('Video Icon')
  ;

  const _LeadingOption(this.label);
  final String label;
}

enum _ColorOption {
  none('Default', null),
  red('Red', Colors.red),
  blue('Blue', Colors.blue),
  green('Green', Colors.green),
  white('White', Colors.white),
  black('Black', Colors.black)
  ;

  const _ColorOption(this.label, this.color);
  final String label;
  final Color? color;
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamImageSourceBadge,
  path: '[Components]/Badge',
)
Widget buildStreamImageSourceBadgeShowcase(BuildContext context) {
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
          const _SourcesSection(),
          SizedBox(height: spacing.xl),
          const _CompositionSection(),
          SizedBox(height: spacing.xl),
          const _UsageSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Sources Section
// =============================================================================

class _SourcesSection extends StatelessWidget {
  const _SourcesSection();

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
        const _SectionLabel(label: 'SOURCES'),
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
                'Pre-built badges for common content providers',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  _SourceDemo(label: 'Giphy', badge: StreamImageSourceBadge.giphy),
                  SizedBox(width: spacing.xl),
                  _SourceDemo(label: 'Imgur', badge: StreamImageSourceBadge.imgur),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SourceDemo extends StatelessWidget {
  const _SourceDemo({required this.label, required this.badge});

  final String label;
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        badge,
        SizedBox(height: spacing.sm),
        Text(
          label,
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
// Composition Section
// =============================================================================

class _CompositionSection extends StatelessWidget {
  const _CompositionSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final icons = context.streamIcons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'COMPOSITION'),
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
                'Badge displays a leading icon alongside a label',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  _CompositionDemo(
                    label: 'Icon + Label',
                    badge: StreamImageSourceBadge(
                      leading: SvgIcon(icons.giphy),
                      label: const Text('GIPHY'),
                    ),
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

class _CompositionDemo extends StatelessWidget {
  const _CompositionDemo({required this.label, required this.badge});

  final String label;
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        badge,
        SizedBox(height: spacing.sm),
        Text(
          label,
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
// Usage Section
// =============================================================================

class _UsageSection extends StatelessWidget {
  const _UsageSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'USAGE'),
        SizedBox(height: spacing.md),
        const _ExampleCard(
          title: 'Attachment Overlay',
          description: 'Badge positioned on media content',
          child: _AttachmentOverlayExample(),
        ),
      ],
    );
  }
}

class _AttachmentOverlayExample extends StatelessWidget {
  const _AttachmentOverlayExample();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Wrap(
      spacing: spacing.md,
      runSpacing: spacing.md,
      children: [
        _AttachmentWithBadge(badge: StreamImageSourceBadge.giphy),
        _AttachmentWithBadge(badge: StreamImageSourceBadge.imgur),
      ],
    );
  }
}

class _AttachmentWithBadge extends StatelessWidget {
  const _AttachmentWithBadge({required this.badge});

  final Widget badge;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return StreamMessageAttachment(
      child: Stack(
        children: [
          const _PlaceholderAttachment(),
          PositionedDirectional(
            start: spacing.xs,
            bottom: spacing.xs,
            child: badge,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _PlaceholderAttachment extends StatelessWidget {
  const _PlaceholderAttachment();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: 480,
      child: StreamNetworkImage(
        'https://picsum.photos/seed/source-badge/960/480',
        fit: BoxFit.cover,
      ),
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
            padding: EdgeInsets.fromLTRB(
              spacing.md,
              spacing.sm,
              spacing.md,
              spacing.sm,
            ),
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
          Divider(height: 1, color: colorScheme.borderSubtle),
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
