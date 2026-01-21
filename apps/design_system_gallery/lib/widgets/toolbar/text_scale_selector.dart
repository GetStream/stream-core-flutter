import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A dropdown selector for choosing the text scale factor.
class TextScaleSelector extends StatelessWidget {
  const TextScaleSelector({
    super.key,
    required this.value,
    required this.options,
    required this.colorScheme,
    required this.textTheme,
    required this.onChanged,
  });

  final double value;
  final List<double> options;
  final StreamColorScheme colorScheme;
  final StreamTextTheme textTheme;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.backgroundApp,
        borderRadius: BorderRadius.circular(8),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.borderSurfaceSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
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
          items: options.map((scale) {
            return DropdownMenuItem(
              value: scale,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.text_fields,
                    size: 14,
                    color: colorScheme.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(scale * 100).toInt()}%',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (scale) {
            if (scale != null) onChanged(scale);
          },
        ),
      ),
    );
  }
}
