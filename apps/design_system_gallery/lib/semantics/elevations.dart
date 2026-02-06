import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(
  name: 'All Elevations',
  type: StreamBoxShadow,
  path: '[App Foundation]/Semantics/Elevations',
)
Widget buildStreamBoxShadowShowcase(BuildContext context) {
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
          // 3D Stacked visualization
          const _StackedElevationDemo(),
          SizedBox(height: spacing.xl),

          // Elevation cards
          const _ElevationGrid(),
          SizedBox(height: spacing.xl),

          // Quick reference
          const _QuickReference(),
        ],
      ),
    ),
  );
}

class _StackedElevationDemo extends StatelessWidget {
  const _StackedElevationDemo();

  @override
  Widget build(BuildContext context) {
    final boxShadow = context.streamBoxShadow;
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'DEPTH HIERARCHY'),
        SizedBox(height: spacing.md),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(spacing.lg),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.backgroundSurface,
                colorScheme.backgroundSurfaceSubtle,
              ],
            ),
            borderRadius: BorderRadius.all(radius.lg),
            boxShadow: boxShadow.elevation1,
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base layer
                    Positioned(
                      bottom: 0,
                      child: _buildLayer(
                        context,
                        'elevation1',
                        boxShadow.elevation1,
                        180,
                        colorScheme.backgroundSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    // elevation2
                    Positioned(
                      bottom: 35,
                      child: _buildLayer(
                        context,
                        'elevation2',
                        boxShadow.elevation2,
                        155,
                        colorScheme.backgroundSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    // elevation3
                    Positioned(
                      bottom: 70,
                      child: _buildLayer(
                        context,
                        'elevation3',
                        boxShadow.elevation3,
                        130,
                        colorScheme.backgroundSurface.withValues(alpha: 0.85),
                      ),
                    ),
                    // elevation4
                    Positioned(
                      bottom: 105,
                      child: _buildLayer(
                        context,
                        'elevation4',
                        boxShadow.elevation4,
                        105,
                        colorScheme.backgroundSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.md + spacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward,
                    size: 14,
                    color: colorScheme.textTertiary,
                  ),
                  SizedBox(width: spacing.sm),
                  Text(
                    'Further from viewer',
                    style: textTheme.metadataDefault.copyWith(
                      color: colorScheme.textTertiary,
                    ),
                  ),
                  SizedBox(width: spacing.lg),
                  Icon(
                    Icons.arrow_upward,
                    size: 14,
                    color: colorScheme.textTertiary,
                  ),
                  SizedBox(width: spacing.sm),
                  Text(
                    'Closer to viewer',
                    style: textTheme.metadataDefault.copyWith(
                      color: colorScheme.textTertiary,
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

  Widget _buildLayer(
    BuildContext context,
    String label,
    List<BoxShadow> shadow,
    double width,
    Color color,
  ) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;

    return Container(
      width: width,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(radius.md),
        boxShadow: shadow,
        border: Border.all(
          color: colorScheme.borderSubtle.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.textSecondary,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

class _ElevationGrid extends StatelessWidget {
  const _ElevationGrid();

  @override
  Widget build(BuildContext context) {
    final boxShadow = context.streamBoxShadow;
    final spacing = context.streamSpacing;

    final elevations = [
      _ElevationData(
        name: 'elevation1',
        shadow: boxShadow.elevation1,
        level: '1',
        description: 'Subtle lift for resting state',
        useCases: ['Cards', 'List items', 'Input fields'],
      ),
      _ElevationData(
        name: 'elevation2',
        shadow: boxShadow.elevation2,
        level: '2',
        description: 'Moderate lift for hover/focus',
        useCases: ['Dropdowns', 'Menus', 'Popovers'],
      ),
      _ElevationData(
        name: 'elevation3',
        shadow: boxShadow.elevation3,
        level: '3',
        description: 'High lift for prominent UI',
        useCases: ['Modals', 'Dialogs', 'Drawers'],
      ),
      _ElevationData(
        name: 'elevation4',
        shadow: boxShadow.elevation4,
        level: '4',
        description: 'Highest lift for alerts',
        useCases: ['Toasts', 'Notifications', 'Snackbars'],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'ELEVATION LEVELS'),
        SizedBox(height: spacing.md),
        ...elevations.map(
          (e) => _ElevationCard(data: e),
        ),
      ],
    );
  }
}

class _ElevationCard extends StatelessWidget {
  const _ElevationCard({required this.data});

  final _ElevationData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: InkWell(
        onTap: () {
          Clipboard.setData(
            ClipboardData(text: 'boxShadow.${data.name}'),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied: boxShadow.${data.name}'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.all(radius.lg),
        child: Container(
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
          child: Row(
            children: [
              // Level indicator
              Container(
                width: 48,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.backgroundSurfaceSubtle,
                ),
                child: Center(
                  child: Text(
                    data.level,
                    style: textTheme.headingLg.copyWith(
                      color: colorScheme.textTertiary,
                    ),
                  ),
                ),
              ),
              // Preview box with shadow
              Padding(
                padding: EdgeInsets.all(spacing.md),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.backgroundSurface,
                    borderRadius: BorderRadius.all(radius.lg),
                    boxShadow: data.shadow,
                  ),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.name,
                            style: textTheme.captionEmphasis.copyWith(
                              color: colorScheme.accentPrimary,
                              fontFamily: 'monospace',
                            ),
                          ),
                          SizedBox(width: spacing.xs + spacing.xxs),
                          Icon(
                            Icons.copy,
                            size: 11,
                            color: colorScheme.textTertiary,
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        data.description,
                        style: textTheme.captionDefault.copyWith(
                          color: colorScheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      Wrap(
                        spacing: spacing.xs + spacing.xxs,
                        runSpacing: spacing.xs,
                        children: data.useCases.map((use) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.xs + spacing.xxs,
                              vertical: spacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.backgroundSurfaceSubtle,
                              borderRadius: BorderRadius.all(radius.xs),
                            ),
                            child: Text(
                              use,
                              style: textTheme.metadataDefault.copyWith(
                                color: colorScheme.textTertiary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick reference for elevation usage
class _QuickReference extends StatelessWidget {
  const _QuickReference();

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
        const _SectionLabel(label: 'QUICK REFERENCE'),
        SizedBox(height: spacing.md),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(spacing.md),
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
              Text(
                'Usage Pattern',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.backgroundSurfaceSubtle,
                  borderRadius: BorderRadius.all(radius.md),
                ),
                child: Text(
                  'boxShadow: context.streamBoxShadow.elevation{1-4}',
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.accentPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: spacing.md),
              Divider(color: colorScheme.borderSubtle),
              SizedBox(height: spacing.md),
              Text(
                'Best Practices',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              const _BestPractice(
                icon: Icons.check_circle_outline,
                text: 'Use consistent elevation for same-level components',
              ),
              SizedBox(height: spacing.sm),
              const _BestPractice(
                icon: Icons.check_circle_outline,
                text: 'Increase elevation for overlapping/modal content',
              ),
              SizedBox(height: spacing.sm),
              const _BestPractice(
                icon: Icons.check_circle_outline,
                text: 'Reserve higher elevations for temporary UI',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BestPractice extends StatelessWidget {
  const _BestPractice({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: colorScheme.accentSuccess,
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            text,
            style: textTheme.captionDefault.copyWith(
              color: colorScheme.textSecondary,
            ),
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

class _ElevationData {
  const _ElevationData({
    required this.name,
    required this.shadow,
    required this.level,
    required this.description,
    required this.useCases,
  });

  final String name;
  final List<BoxShadow> shadow;
  final String level;
  final String description;
  final List<String> useCases;
}
