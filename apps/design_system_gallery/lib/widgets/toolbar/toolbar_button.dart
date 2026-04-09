import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A reusable toolbar button with icon and tooltip.
class ToolbarButton extends StatelessWidget {
  const ToolbarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive ? colorScheme.accentPrimary.withValues(alpha: 0.1) : colorScheme.backgroundApp,
        borderRadius: BorderRadius.all(radius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.all(radius.md),
          child: Container(
            padding: EdgeInsets.all(spacing.sm + spacing.xxs),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(radius.md),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.all(radius.md),
              border: Border.all(
                color: isActive ? colorScheme.accentPrimary : colorScheme.borderDefault,
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
