import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A toggle button for switching between light and dark theme modes.
class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({
    super.key,
    required this.isDark,
    required this.onLightTap,
    required this.onDarkTap,
  });

  final bool isDark;
  final VoidCallback onLightTap;
  final VoidCallback onDarkTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.backgroundApp,
        borderRadius: BorderRadius.all(radius.md),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeButton(
            icon: Icons.light_mode,
            isSelected: !isDark,
            onTap: onLightTap,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(radius.md.x - 1)),
          ),
          ColoredBox(
            color: colorScheme.borderDefault,
            child: const SizedBox(width: 1, height: 28),
          ),
          _ModeButton(
            icon: Icons.dark_mode,
            isSelected: isDark,
            onTap: onDarkTap,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(radius.md.x - 1)),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.borderRadius,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return Material(
      color: isSelected ? colorScheme.accentPrimary.withValues(alpha: 0.1) : StreamColors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: EdgeInsets.all(spacing.sm + spacing.xxs),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? colorScheme.accentPrimary : colorScheme.textTertiary,
          ),
        ),
      ),
    );
  }
}
