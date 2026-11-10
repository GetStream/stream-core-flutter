import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamInlineNotification,
  path: '[Components]/Inline Notification',
)
Widget buildStreamInlineNotificationPlayground(BuildContext context) {
  final type = context.knobs.object.dropdown<StreamInlineNotificationType>(
    label: 'Type',
    options: StreamInlineNotificationType.values,
    initialOption: StreamInlineNotificationType.info,
    labelBuilder: (option) => option.name.toUpperCase(),
    description: 'The kind of message, which picks the icon and colors.',
  );

  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Changes are saved automatically',
    description: 'The primary message.',
  );

  final showDescription = context.knobs.boolean(
    label: 'Show Description',
    description: 'Whether to show supporting text under the title.',
  );

  final description = context.knobs.string(
    label: 'Description',
    initialValue: 'Edits sync across your devices.',
    description: 'The supporting text.',
  );

  final showIcon = context.knobs.boolean(
    label: 'Show Icon',
    initialValue: true,
    description: 'Whether to show the leading icon for the type.',
  );

  final customIcon = context.knobs.boolean(
    label: 'Custom Icon',
    description: 'Whether to replace the default icon for the type.',
  );

  final spacing = context.streamSpacing;

  return Center(
    child: Padding(
      padding: EdgeInsets.all(spacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 370),
        child: StreamInlineNotification(
          type: type,
          title: Text(title),
          description: showDescription ? Text(description) : null,
          icon: customIcon ? Icon(context.streamIcons.clockFill) : null,
          showIcon: showIcon,
        ),
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamInlineNotification,
  path: '[Components]/Inline Notification',
)
Widget buildStreamInlineNotificationShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (label, caption, withDescription) in const [
            ('TITLE ONLY', 'One per type, title only', false),
            ('WITH DESCRIPTION', 'Supporting text under the title', true),
          ]) ...[
            _Section(
              label: label,
              caption: caption,
              children: [
                for (final type in StreamInlineNotificationType.values)
                  StreamInlineNotification(
                    type: type,
                    title: Text('${type.name} notification'),
                    description: withDescription ? const Text('Supporting text that explains the message.') : null,
                  ),
              ],
            ),
            SizedBox(height: spacing.xl),
          ],
          _Section(
            label: 'IN CONTEXT',
            caption: 'A confirmation after saving, and an error explaining what went wrong',
            children: [
              StreamInlineNotification(
                type: StreamInlineNotificationType.success,
                title: const Text('Changes saved'),
              ),
              StreamInlineNotification(
                type: StreamInlineNotificationType.error,
                title: const Text("Couldn't load content"),
                description: const Text('Check your connection and try again.'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.caption, required this.children});

  final String label;
  final String caption;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: label),
        SizedBox(height: spacing.md),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colorScheme.backgroundElevation1,
            borderRadius: BorderRadius.all(radius.lg),
            boxShadow: boxShadow.elevation1,
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.sm,
            children: [
              Text(caption, style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary)),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 370),
                child: Column(spacing: spacing.sm, children: children),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
