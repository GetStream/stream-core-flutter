import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamCommandChip,
  path: '[Components]/Controls',
)
Widget buildStreamCommandChipPlayground(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: '/giphy',
    description: 'The command label displayed inside the chip.',
  );

  final enableDismiss = context.knobs.boolean(
    label: 'On Dismiss',
    initialValue: true,
    description: 'Whether the dismiss callback is active.',
  );

  return Center(
    child: StreamCommandChip(
      label: label,
      onDismiss: enableDismiss
          ? () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Command dismissed'),
                    duration: Duration(seconds: 1),
                  ),
                );
            }
          : null,
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamCommandChip,
  path: '[Components]/Controls',
)
Widget buildStreamCommandChipShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final spacing = context.streamSpacing;
  final radius = context.streamRadius;

  return SingleChildScrollView(
    padding: EdgeInsets.all(spacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xl,
      children: [
        const _SectionLabel(label: 'COMMAND CHIP — IMAGE OVERLAY'),
        // Simulated attachment overlay
        Stack(
          alignment: Alignment.topLeft,
          children: [
            Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.backgroundSurfaceSubtle,
                borderRadius: BorderRadius.all(radius.md),
                border: Border.all(color: colorScheme.borderSubtle),
              ),
              child: Center(
                child: Icon(Icons.image, size: 48, color: colorScheme.textDisabled),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(spacing.xs),
              child: StreamCommandChip(
                label: '/giphy',
                onDismiss: () {},
              ),
            ),
          ],
        ),
        const _SectionLabel(label: 'LABEL VARIANTS'),
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            StreamCommandChip(label: '/giphy', onDismiss: () {}),
            StreamCommandChip(label: '/img', onDismiss: () {}),
            StreamCommandChip(label: '/ban', onDismiss: () {}),
            StreamCommandChip(label: '/very-long-command-name', onDismiss: () {}),
          ],
        ),
        const _SectionLabel(label: 'WITHOUT DISMISS'),
        StreamCommandChip(label: '/giphy'),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.accentPrimary,
        borderRadius: BorderRadius.all(radius.xs),
      ),
      child: Text(
        label,
        style: textTheme.metadataEmphasis.copyWith(
          color: colorScheme.textOnAccent,
          letterSpacing: 1,
          fontSize: 9,
        ),
      ),
    );
  }
}
