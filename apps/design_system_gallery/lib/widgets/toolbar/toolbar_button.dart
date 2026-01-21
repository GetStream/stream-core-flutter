import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A reusable toolbar button with icon and tooltip.
class ToolbarButton extends StatelessWidget {
  const ToolbarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final StreamColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive ? colorScheme.accentPrimary.withValues(alpha: 0.1) : colorScheme.backgroundApp,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? colorScheme.accentPrimary : colorScheme.borderSurfaceSubtle,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? colorScheme.accentPrimary : colorScheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
