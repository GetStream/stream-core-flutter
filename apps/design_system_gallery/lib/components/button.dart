import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamButton,
  path: '[Components]/Button',
)
Widget buildStreamButtonPlayground(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Click me',
    description: 'The text displayed on the button.',
  );

  final type = context.knobs.object.dropdown(
    label: 'Type',
    options: StreamButtonType.values,
    initialOption: StreamButtonType.primary,
    labelBuilder: (option) => option.name,
    description: 'Button visual style variant.',
  );

  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: StreamButtonSize.values,
    initialOption: StreamButtonSize.large,
    labelBuilder: (option) => option.name,
    description: 'Button size preset (affects padding and font size).',
  );

  final isDisabled = context.knobs.boolean(
    label: 'Disabled',
    description: 'Whether the button is disabled (non-interactive).',
  );

  final showLeadingIcon = context.knobs.boolean(
    label: 'Leading Icon',
    description: 'Show an icon before the label.',
  );

  final showTrailingIcon = context.knobs.boolean(
    label: 'Trailing Icon',
    description: 'Show an icon after the label.',
  );

  return Center(
    child: StreamButton(
      label: label,
      type: type,
      size: size,
      onTap: isDisabled
          ? null
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Button tapped!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
      iconLeft: showLeadingIcon ? const Icon(Icons.add) : null,
      iconRight: showTrailingIcon ? const Icon(Icons.arrow_forward) : null,
    ),
  );
}

// =============================================================================
// Type Variants
// =============================================================================

@widgetbook.UseCase(
  name: 'Type Variants',
  type: StreamButton,
  path: '[Components]/Button',
)
Widget buildStreamButtonTypes(BuildContext context) {
  final theme = StreamTheme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final type in StreamButtonType.values) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    type.name,
                    style: textTheme.captionDefault.copyWith(
                      color: colorScheme.textSecondary,
                    ),
                  ),
                ),
                StreamButton(
                  label: 'Button',
                  type: type,
                  onTap: () {},
                ),
              ],
            ),
            if (type != StreamButtonType.values.last) const SizedBox(height: 16),
          ],
        ],
      ),
    ),
  );
}

// =============================================================================
// Size Variants
// =============================================================================

@widgetbook.UseCase(
  name: 'Size Variants',
  type: StreamButton,
  path: '[Components]/Button',
)
Widget buildStreamButtonSizes(BuildContext context) {
  final theme = StreamTheme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final size in StreamButtonSize.values) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    size.name,
                    style: textTheme.captionDefault.copyWith(
                      color: colorScheme.textSecondary,
                    ),
                  ),
                ),
                StreamButton(
                  label: 'Button',
                  size: size,
                  onTap: () {},
                ),
              ],
            ),
            if (size != StreamButtonSize.values.last) const SizedBox(height: 16),
          ],
        ],
      ),
    ),
  );
}

// =============================================================================
// With Icons
// =============================================================================

@widgetbook.UseCase(
  name: 'With Icons',
  type: StreamButton,
  path: '[Components]/Button',
)
Widget buildStreamButtonWithIcons(BuildContext context) {
  final theme = StreamTheme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  'Leading',
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.textSecondary,
                  ),
                ),
              ),
              StreamButton(
                label: 'Add Item',
                iconLeft: const Icon(Icons.add),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  'Trailing',
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.textSecondary,
                  ),
                ),
              ),
              StreamButton(
                label: 'Continue',
                iconRight: const Icon(Icons.arrow_forward),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  'Both',
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.textSecondary,
                  ),
                ),
              ),
              StreamButton(
                label: 'Upload',
                iconLeft: const Icon(Icons.cloud_upload),
                iconRight: const Icon(Icons.arrow_forward),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// Real-world Example
// =============================================================================

@widgetbook.UseCase(
  name: 'Real-world Example',
  type: StreamButton,
  path: '[Components]/Button',
)
Widget buildStreamButtonExample(BuildContext context) {
  final theme = StreamTheme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Common Patterns',
            style: textTheme.headingSm.copyWith(
              color: colorScheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Dialog actions
          Container(
            padding: const EdgeInsets.all(16),
            width: 280,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Delete conversation?',
                  style: textTheme.bodyEmphasis.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This action cannot be undone.',
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StreamButton(
                      label: 'Cancel',
                      type: StreamButtonType.secondary,
                      size: StreamButtonSize.small,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    StreamButton(
                      label: 'Delete',
                      type: StreamButtonType.destructive,
                      size: StreamButtonSize.small,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Form submit
          Container(
            padding: const EdgeInsets.all(16),
            width: 280,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ready to send?',
                  style: textTheme.bodyEmphasis.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                StreamButton(
                  label: 'Send Message',
                  iconRight: const Icon(Icons.send),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
