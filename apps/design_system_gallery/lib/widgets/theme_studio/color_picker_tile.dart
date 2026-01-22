import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A tile that displays a color and opens a color picker when tapped.
class ColorPickerTile extends StatelessWidget {
  const ColorPickerTile({
    super.key,
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs + spacing.xxs),
      child: InkWell(
        onTap: () => _showColorPicker(context),
        borderRadius: BorderRadius.all(radius.sm),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: spacing.sm + spacing.xxs, vertical: spacing.sm),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.backgroundApp,
            borderRadius: BorderRadius.all(radius.sm),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.sm),
            border: Border.all(color: colorScheme.borderSurfaceSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(radius.xs),
                  boxShadow: boxShadow.elevation1,
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.all(radius.xs),
                  border: Border.all(
                    color: colorScheme.borderSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
              SizedBox(width: spacing.sm + spacing.xxs),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.textPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Text(
                _colorToHex(color),
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textTertiary,
                  fontFamily: 'monospace',
                ),
              ),
              SizedBox(width: spacing.xs + spacing.xxs),
              Icon(Icons.edit, color: colorScheme.textTertiary, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  String _colorToHex(Color color) {
    final hex = color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0');
    return color.a < 1.0 ? '#$hex' : '#${hex.substring(2)}';
  }

  Future<void> _showColorPicker(BuildContext context) async {
    var pickerColor = color;
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
              onColorChanged(pickerColor);
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
