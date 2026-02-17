import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A dropdown selector for choosing the target platform override.
///
/// Displays the current platform with an icon and allows the user to switch
/// between system default, Android, iOS, macOS, Windows, and Linux.
class PlatformSelector extends StatelessWidget {
  const PlatformSelector({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final TargetPlatform? value;
  final List<TargetPlatform?> options;
  final ValueChanged<TargetPlatform?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.backgroundApp,
        borderRadius: BorderRadius.all(radius.md),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.borderDefault),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TargetPlatform?>(
          value: value,
          icon: Icon(
            Icons.unfold_more,
            color: colorScheme.textTertiary,
            size: 16,
          ),
          style: textTheme.captionDefault.copyWith(
            color: colorScheme.textPrimary,
          ),
          dropdownColor: colorScheme.backgroundSurface,
          items: options.map((platform) {
            return DropdownMenuItem(
              value: platform,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _iconFor(platform),
                    size: 14,
                    color: colorScheme.textTertiary,
                  ),
                  SizedBox(width: spacing.sm),
                  Text(
                    _labelFor(platform),
                    style: textTheme.captionDefault,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  static String _labelFor(TargetPlatform? platform) => switch (platform) {
        null => 'System',
        TargetPlatform.android => 'Android',
        TargetPlatform.iOS => 'iOS',
        TargetPlatform.macOS => 'macOS',
        TargetPlatform.windows => 'Windows',
        TargetPlatform.linux => 'Linux',
        TargetPlatform.fuchsia => 'Fuchsia',
      };

  static IconData _iconFor(TargetPlatform? platform) => switch (platform) {
        null => Icons.settings_suggest,
        TargetPlatform.android => Icons.android,
        TargetPlatform.iOS => Icons.phone_iphone,
        TargetPlatform.macOS => Icons.laptop_mac,
        TargetPlatform.windows => Icons.desktop_windows,
        TargetPlatform.linux => Icons.terminal,
        TargetPlatform.fuchsia => Icons.all_inclusive,
      };
}
