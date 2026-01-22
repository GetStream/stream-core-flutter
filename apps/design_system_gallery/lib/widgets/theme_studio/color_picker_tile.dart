import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A tile that displays a color and opens a color picker when tapped.
class ColorPickerTile extends StatelessWidget {
  const ColorPickerTile({
    super.key,
    required this.label,
    required this.color,
    required this.colorScheme,
    required this.boxShadow,
    required this.onColorChanged,
  });

  final String label;
  final Color color;
  final StreamColorScheme colorScheme;
  final StreamBoxShadow boxShadow;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _showColorPicker(context),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.backgroundApp,
            borderRadius: BorderRadius.circular(6),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
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
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: boxShadow.elevation1,
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: colorScheme.borderSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Text(
                _colorToHex(color),
                style: TextStyle(
                  color: colorScheme.textTertiary,
                  fontSize: 9,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 6),
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
