import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A tile for editing a single avatar color pair (background and foreground).
class AvatarColorPairTile extends StatelessWidget {
  const AvatarColorPairTile({
    super.key,
    required this.index,
    required this.pair,
    required this.colorScheme,
    required this.onBackgroundChanged,
    required this.onForegroundChanged,
    this.onRemove,
  });

  final int index;
  final StreamAvatarColorPair pair;
  final StreamColorScheme colorScheme;
  final ValueChanged<Color> onBackgroundChanged;
  final ValueChanged<Color> onForegroundChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.backgroundApp,
          borderRadius: BorderRadius.circular(8),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.borderSurfaceSubtle),
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
                      style: TextStyle(
                        color: pair.foregroundColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Palette ${index + 1}',
                    style: TextStyle(
                      color: colorScheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SmallColorButton(
                    label: 'backgroundColor',
                    color: pair.backgroundColor,
                    colorScheme: colorScheme,
                    onTap: () => _showColorPicker(
                      context,
                      'backgroundColor',
                      pair.backgroundColor,
                      onBackgroundChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SmallColorButton(
                    label: 'foregroundColor',
                    color: pair.foregroundColor,
                    colorScheme: colorScheme,
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

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          label,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
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
    required this.colorScheme,
    required this.onTap,
  });

  final String label;
  final Color color;
  final StreamColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.backgroundSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colorScheme.borderSurfaceSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: colorScheme.borderSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: colorScheme.textSecondary,
                  fontSize: 9,
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
    required this.colorScheme,
    required this.onTap,
  });

  final StreamColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.borderSurfaceSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: colorScheme.accentPrimary, size: 16),
            const SizedBox(width: 6),
            Text(
              'Add Palette Entry',
              style: TextStyle(
                color: colorScheme.accentPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
