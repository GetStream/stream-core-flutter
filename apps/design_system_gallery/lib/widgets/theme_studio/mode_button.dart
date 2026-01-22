import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A button for selecting light or dark mode in the theme studio.
class ThemeStudioModeButton extends StatelessWidget {
  const ThemeStudioModeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final StreamColorScheme colorScheme;
  final StreamTextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? colorScheme.accentPrimary.withValues(alpha: 0.1) : colorScheme.backgroundApp,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 4),
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
