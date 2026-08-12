import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';

import '../../config/component_theme_descriptors.dart';

/// A button that opens a picker over [available] component themes and calls
/// [onSelected] with the chosen one's name. Renders nothing when [available]
/// is empty (every component theme is already active).
///
/// Shared by the theme studio panel and the export page so "add a component
/// theme" looks and behaves identically in both places.
class AddComponentThemeButton extends StatelessWidget {
  const AddComponentThemeButton({super.key, required this.available, required this.onSelected});

  final List<ComponentThemeDescriptor> available;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (available.isEmpty) return const SizedBox.shrink();

    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    return Material(
      color: colorScheme.backgroundSurface,
      borderRadius: BorderRadius.all(radius.md),
      child: InkWell(
        onTap: () => _showAddComponentThemeDialog(context),
        borderRadius: BorderRadius.all(radius.md),
        child: Container(
          padding: EdgeInsets.all(spacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.md),
            border: Border.all(color: colorScheme.borderDefault),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: colorScheme.accentPrimary, size: 16),
              SizedBox(width: spacing.xs),
              Text(
                'Add component theme',
                style: textTheme.captionEmphasis.copyWith(color: colorScheme.accentPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddComponentThemeDialog(BuildContext context) async {
    final textTheme = context.streamTextTheme;

    final selected = await showDialog<ComponentThemeDescriptor>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Add component theme', style: textTheme.headingSm),
        children: [
          for (final descriptor in available)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(descriptor),
              child: Text('${descriptor.name} (${descriptor.properties.length} colors)'),
            ),
        ],
      ),
    );

    if (selected != null) onSelected(selected.name);
  }
}

/// The small "Remove component theme" row shown below an added component's
/// properties. Shared for the same reason as [AddComponentThemeButton].
class RemoveComponentThemeButton extends StatelessWidget {
  const RemoveComponentThemeButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(context.streamRadius.sm),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: colorScheme.textTertiary, size: 14),
            SizedBox(width: spacing.xs),
            Text(
              'Remove component theme',
              style: textTheme.captionDefault.copyWith(color: colorScheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
