import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A dropdown selector for choosing the text direction (LTR/RTL).
class TextDirectionSelector extends StatelessWidget {
  const TextDirectionSelector({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final TextDirection value;
  final List<TextDirection> options;
  final ValueChanged<TextDirection> onChanged;

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
        child: DropdownButton<TextDirection>(
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
          items: options.map((direction) {
            final isLtr = direction == TextDirection.ltr;
            return DropdownMenuItem(
              value: direction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLtr ? Icons.format_textdirection_l_to_r : Icons.format_textdirection_r_to_l,
                    size: 14,
                    color: colorScheme.textTertiary,
                  ),
                  SizedBox(width: spacing.sm),
                  Text(
                    isLtr ? 'LTR' : 'RTL',
                    style: textTheme.captionDefault,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (direction) {
            if (direction != null) onChanged(direction);
          },
        ),
      ),
    );
  }
}
