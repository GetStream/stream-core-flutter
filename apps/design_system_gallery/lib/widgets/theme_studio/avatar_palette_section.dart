import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A tile for editing a single avatar color pair (background and foreground).
class AvatarColorPairTile extends StatelessWidget {
  const AvatarColorPairTile({
    super.key,
    required this.index,
    required this.pair,
    required this.onBackgroundChanged,
    required this.onForegroundChanged,
    this.onRemove,
  });

  final int index;
  final StreamAvatarColorPair pair;
  final ValueChanged<Color> onBackgroundChanged;
  final ValueChanged<Color> onForegroundChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Container(
        padding: EdgeInsets.all(spacing.sm + spacing.xxs),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.backgroundApp,
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
                // Preview avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: pair.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'AB',
                      style: textTheme.captionEmphasis.copyWith(
                        color: pair.foregroundColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacing.sm + spacing.xxs),
                Expanded(
                  child: Text(
                    'Palette ${index + 1}',
                    style: textTheme.captionEmphasis.copyWith(
                      color: colorScheme.textPrimary,
                    ),
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: colorScheme.accentError,
                      size: 18,
                    ),
                    tooltip: 'Remove',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
              ],
            ),
            SizedBox(height: spacing.sm),
            Row(
              children: [
                Expanded(
                  child: _SmallColorButton(
                    label: 'backgroundColor',
                    color: pair.backgroundColor,
                    onTap: () => _showColorPicker(
                      context,
                      'backgroundColor',
                      pair.backgroundColor,
                      onBackgroundChanged,
                    ),
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: _SmallColorButton(
                    label: 'foregroundColor',
                    color: pair.foregroundColor,
                    onTap: () => _showColorPicker(
                      context,
                      'foregroundColor',
                      pair.foregroundColor,
                      onForegroundChanged,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showColorPicker(
    BuildContext context,
    String label,
    Color initialColor,
    ValueChanged<Color> onChanged,
  ) async {
    var pickerColor = initialColor;
    final textTheme = context.streamTextTheme;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          label,
          style: textTheme.bodyEmphasis.copyWith(
            fontFamily: 'monospace',
          ),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onChanged(pickerColor);
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _SmallColorButton extends StatelessWidget {
  const _SmallColorButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(radius.sm),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs + spacing.xxs),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.backgroundSurface,
          borderRadius: BorderRadius.all(radius.sm),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius.sm),
          border: Border.all(color: colorScheme.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(radius.xxs),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.all(radius.xxs),
                border: Border.all(
                  color: colorScheme.borderDefault.withValues(alpha: 0.3),
                ),
              ),
            ),
            SizedBox(width: spacing.xs + spacing.xxs),
            Expanded(
              child: Text(
                label,
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textSecondary,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A button to add a new palette entry.
class AddPaletteButton extends StatelessWidget {
  const AddPaletteButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(radius.md),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: spacing.sm + spacing.xxs),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius.md),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius.md),
          border: Border.all(color: colorScheme.borderDefault),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: colorScheme.accentPrimary, size: 16),
            SizedBox(width: spacing.xs + spacing.xxs),
            Text(
              'Add Palette Entry',
              style: textTheme.captionDefault.copyWith(
                color: colorScheme.accentPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
