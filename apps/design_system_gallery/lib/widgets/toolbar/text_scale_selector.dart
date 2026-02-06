import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A dropdown selector for choosing the text scale factor.
class TextScaleSelector extends StatelessWidget {
  const TextScaleSelector({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final double value;
  final List<double> options;
  final ValueChanged<double> onChanged;

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
                  SizedBox(width: spacing.sm),
                  Text(
                    '${(scale * 100).toInt()}%',
                    style: textTheme.captionDefault,
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
