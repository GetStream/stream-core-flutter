import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A toggle button for switching between light and dark theme modes.
class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({
    super.key,
    required this.isDark,
    required this.colorScheme,
    required this.onLightTap,
    required this.onDarkTap,
  });

  final bool isDark;
  final StreamColorScheme colorScheme;
  final VoidCallback onLightTap;
  final VoidCallback onDarkTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _ModeButton(
            icon: Icons.light_mode,
            isSelected: !isDark,
            colorScheme: colorScheme,
            onTap: onLightTap,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
          ),
          ColoredBox(
            color: colorScheme.borderSurfaceSubtle,
            child: const SizedBox(width: 1, height: 28),
          ),
          _ModeButton(
            icon: Icons.dark_mode,
            isSelected: isDark,
            colorScheme: colorScheme,
            onTap: onDarkTap,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
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
    required this.colorScheme,
    required this.onTap,
    required this.borderRadius,
  });

  final IconData icon;
  final bool isSelected;
  final StreamColorScheme colorScheme;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? colorScheme.accentPrimary.withValues(alpha: 0.1) : Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(10),
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
