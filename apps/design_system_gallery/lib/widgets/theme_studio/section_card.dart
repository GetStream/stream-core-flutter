import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A card container for theme customization sections.
///
/// Provides consistent styling for grouping related theme controls.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.all(spacing.sm),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        borderRadius: BorderRadius.all(radius.md),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.textTertiary, size: 14),
              SizedBox(width: spacing.xs + spacing.xxs),
              Text(
                title,
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(width: spacing.xs + spacing.xxs),
              Container(
                padding: EdgeInsets.symmetric(horizontal: spacing.xs, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.backgroundSurfaceSubtle,
                  borderRadius: BorderRadius.all(radius.xs),
                ),
                child: Text(
                  subtitle,
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm + spacing.xxs),
          child,
        ],
      ),
    );
  }
}
