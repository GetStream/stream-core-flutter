import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamSkeletonLoading,
  path: '[Components]/Common',
)
Widget buildStreamSkeletonLoadingPlayground(BuildContext context) {
  final enabled = context.knobs.boolean(
    label: 'Enabled',
    initialValue: true,
    description: 'Whether the shimmer animation is running.',
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: StreamSkeletonLoading(
        enabled: enabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + text row
            Row(
              children: [
                const StreamSkeletonBox.circular(radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamSkeletonBox(width: 120, height: 12, borderRadius: BorderRadius.circular(4)),
                      const SizedBox(height: 8),
                      StreamSkeletonBox(width: 80, height: 10, borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Content lines
            StreamSkeletonBox(
              width: double.infinity,
              height: 12,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            StreamSkeletonBox(
              width: double.infinity,
              height: 12,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            StreamSkeletonBox(width: 200, height: 12, borderRadius: BorderRadius.circular(4)),
          ],
        ),
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamSkeletonLoading,
  path: '[Components]/Common',
)
Widget buildStreamSkeletonLoadingShowcase(BuildContext context) {
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
          const _MessagePlaceholderSection(),
          SizedBox(height: spacing.xl),
          const _ListPlaceholderSection(),
          SizedBox(height: spacing.xl),
          const _ImagePlaceholderSection(),
          SizedBox(height: spacing.xl),
          const _EnabledStateSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Message Placeholder Section
// =============================================================================

class _MessagePlaceholderSection extends StatelessWidget {
  const _MessagePlaceholderSection();

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
        const _SectionLabel(label: 'MESSAGE PLACEHOLDER'),
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
                'Simulates a loading message bubble',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              StreamSkeletonLoading(
                child: Row(
                  children: [
                    const StreamSkeletonBox.circular(radius: 18),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreamSkeletonBox(width: 100, height: 10, borderRadius: BorderRadius.circular(4)),
                          const SizedBox(height: 8),
                          StreamSkeletonBox(
                            width: double.infinity,
                            height: 10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          StreamSkeletonBox(width: 160, height: 10, borderRadius: BorderRadius.circular(4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// List Placeholder Section
// =============================================================================

class _ListPlaceholderSection extends StatelessWidget {
  const _ListPlaceholderSection();

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
        const _SectionLabel(label: 'LIST PLACEHOLDER'),
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
                'Simulates a loading list of items',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              StreamSkeletonLoading(
                child: Column(
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) SizedBox(height: spacing.md),
                      Row(
                        children: [
                          const StreamSkeletonBox.circular(radius: 22),
                          SizedBox(width: spacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamSkeletonBox(
                                  width: [140.0, 100.0, 120.0][i],
                                  height: 12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 6),
                                StreamSkeletonBox(
                                  width: double.infinity,
                                  height: 10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Image Placeholder Section
// =============================================================================

class _ImagePlaceholderSection extends StatelessWidget {
  const _ImagePlaceholderSection();

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
        const _SectionLabel(label: 'IMAGE PLACEHOLDER'),
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
                'Simulates an image gallery loading state',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              StreamSkeletonLoading(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large hero image placeholder
                    StreamSkeletonBox(
                      width: double.infinity,
                      height: 180,
                      borderRadius: BorderRadius.all(radius.md),
                    ),
                    SizedBox(height: spacing.sm),
                    // Thumbnail row
                    Row(
                      children: [
                        Expanded(
                          child: StreamSkeletonBox(
                            height: 80,
                            borderRadius: BorderRadius.all(radius.sm),
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        Expanded(
                          child: StreamSkeletonBox(
                            height: 80,
                            borderRadius: BorderRadius.all(radius.sm),
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        Expanded(
                          child: StreamSkeletonBox(
                            height: 80,
                            borderRadius: BorderRadius.all(radius.sm),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.md),
                    // Caption lines below images
                    StreamSkeletonBox(
                      width: 160,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    StreamSkeletonBox(
                      width: 100,
                      height: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Enabled State Section
// =============================================================================

class _EnabledStateSection extends StatelessWidget {
  const _EnabledStateSection();

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
        const _SectionLabel(label: 'ENABLED VS DISABLED'),
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
                'Animation can be paused with enabled: false',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  const Expanded(
                    child: _EnabledDemo(label: 'Enabled', enabled: true),
                  ),
                  SizedBox(width: spacing.md),
                  const Expanded(
                    child: _EnabledDemo(label: 'Disabled', enabled: false),
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

// =============================================================================
// Shared Widgets
// =============================================================================

class _EnabledDemo extends StatelessWidget {
  const _EnabledDemo({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        StreamSkeletonLoading(
          enabled: enabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamSkeletonBox(width: double.infinity, height: 12, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 8),
              StreamSkeletonBox(width: 100, height: 12, borderRadius: BorderRadius.circular(4)),
            ],
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
