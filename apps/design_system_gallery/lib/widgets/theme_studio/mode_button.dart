import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A button for selecting light or dark mode in the theme studio.
class ThemeStudioModeButton extends StatelessWidget {
  const ThemeStudioModeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Material(
      color: isSelected ? colorScheme.accentPrimary.withValues(alpha: 0.1) : colorScheme.backgroundApp,
      borderRadius: BorderRadius.all(radius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(radius.md),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: spacing.sm + spacing.xxs, horizontal: spacing.sm),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.md),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.md),
            border: Border.all(
              color: isSelected ? colorScheme.accentPrimary : colorScheme.borderSurfaceSubtle,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? colorScheme.accentPrimary : colorScheme.textTertiary,
                size: 20,
              ),
              SizedBox(height: spacing.xs),
              Text(
                label,
                style: textTheme.captionEmphasis.copyWith(
                  color: isSelected ? colorScheme.accentPrimary : colorScheme.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
