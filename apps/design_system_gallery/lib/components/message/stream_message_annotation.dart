import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageAnnotation,
  path: '[Components]/Message',
)
Widget buildStreamMessageAnnotationPlayground(BuildContext context) {
  final icons = context.streamIcons;
  final colorScheme = context.streamColorScheme;

  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Also sent in channel ·',
    description: 'The annotation label text.',
  );

  final showLeading = context.knobs.boolean(
    label: 'Show Leading',
    initialValue: true,
    description: 'Whether to show a leading icon.',
  );

  final leadingIcon = context.knobs.object.dropdown<_IconOption>(
    label: 'Leading Icon',
    options: _IconOption.values,
    initialOption: _IconOption.arrowUp,
    labelBuilder: (v) => v.label,
    description: 'The leading icon to display.',
  );

  final showTrailing = context.knobs.boolean(
    label: 'Show Trailing',
    initialValue: true,
    description: 'Whether to show the trailing widget (e.g., a link or timestamp).',
  );

  final trailingText = context.knobs.string(
    label: 'Trailing Text',
    initialValue: 'View',
    description: 'The text shown inside the trailing slot.',
  );

  final trailingAsLink = context.knobs.boolean(
    label: 'Trailing as Link',
    initialValue: true,
    description:
        'Color the trailing text with the theme link color '
        '(instead of the default primary text color).',
  );

  final spacing = context.knobs.double.slider(
    label: 'Spacing',
    initialValue: 4,
    max: 16,
    divisions: 16,
    description: 'Gap between icon, label and trailing. Overrides theme when set.',
  );

  final verticalPadding = context.knobs.double.slider(
    label: 'Vertical Padding',
    initialValue: 4,
    max: 16,
    divisions: 16,
    description: 'Vertical padding around the row content.',
  );

  final horizontalPadding = context.knobs.double.slider(
    label: 'Horizontal Padding',
    max: 16,
    divisions: 16,
    description: 'Horizontal padding around the row content.',
  );

  final isActionable = showTrailing && trailingAsLink;

  return Center(
    child: StreamMessageAnnotation(
      onTap: isActionable
          ? () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Tapped'),
                    duration: Duration(seconds: 1),
                  ),
                );
            }
          : null,
      leading: showLeading ? Icon(leadingIcon.resolve(icons)) : null,
      label: Text(label),
      trailing: showTrailing ? Text(trailingText) : null,
      style: StreamMessageAnnotationStyle.from(
        spacing: spacing,
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        trailingTextColor: trailingAsLink ? colorScheme.textLink : null,
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMessageAnnotation,
  path: '[Components]/Message',
)
Widget buildStreamMessageAnnotationShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 32,
        children: [
          _AnnotationTypesSection(),
          _ThemeOverrideSection(),
          _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Showcase Sections
// =============================================================================

class _AnnotationTypesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final colorScheme = context.streamColorScheme;

    return _Section(
      label: 'ANNOTATION TYPES',
      description: 'All annotation variants from the design system.',
      children: [
        _ExampleCard(
          label: 'Saved',
          subtitle: 'Accent color for icon and text.',
          child: StreamMessageItemTheme(
            data: StreamMessageItemThemeData(
              annotation: StreamMessageAnnotationStyle.from(
                textColor: colorScheme.accentPrimary,
                iconColor: colorScheme.accentPrimary,
              ),
            ),
            child: StreamMessageAnnotation(
              leading: Icon(icons.save),
              label: const Text('Saved for later'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Pinned',
          child: StreamMessageAnnotation(
            leading: Icon(icons.pin),
            label: const Text('Pinned by Alice'),
          ),
        ),
        _ExampleCard(
          label: 'Reminder',
          subtitle: 'Bold label + regular-weight informational trailing timestamp.',
          child: StreamMessageAnnotation(
            leading: Icon(icons.bell),
            label: const Text('Reminder set ·'),
            trailing: const Text('In 2 hours'),
          ),
        ),
        _ExampleCard(
          label: 'Translated (row-level tap)',
          subtitle: 'Entire row is tappable via onTap; trailing uses link color.',
          child: StreamMessageAnnotation(
            onTap: () {},
            leading: const Icon(Icons.translate),
            label: const Text('Translated ·'),
            trailing: const Text('Show original'),
            style: StreamMessageAnnotationStyle.from(
              trailingTextColor: colorScheme.textLink,
            ),
          ),
        ),
        _ExampleCard(
          label: 'Also sent in channel (row-level tap)',
          subtitle: 'onTap wraps the whole row; trailing styled as a link.',
          child: StreamMessageAnnotation(
            onTap: () {},
            leading: Icon(icons.arrowUp),
            label: const Text('Also sent in channel ·'),
            trailing: const Text('View'),
            style: StreamMessageAnnotationStyle.from(
              trailingTextColor: colorScheme.textLink,
            ),
          ),
        ),
        _ExampleCard(
          label: 'Replied to a thread (row-level tap)',
          subtitle: 'onTap wraps the whole row; trailing styled as a link.',
          child: StreamMessageAnnotation(
            onTap: () {},
            leading: Icon(icons.arrowUp),
            label: const Text('Replied to a thread ·'),
            trailing: const Text('View'),
            style: StreamMessageAnnotationStyle.from(
              trailingTextColor: colorScheme.textLink,
            ),
          ),
        ),
        _ExampleCard(
          label: 'Trailing-only gesture',
          subtitle:
              'For a narrower tap target, wrap the trailing widget in its '
              'own GestureDetector and leave onTap null.',
          child: StreamMessageAnnotation(
            leading: const Icon(Icons.translate),
            label: const Text('Translated ·'),
            trailing: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: const Text('Show original'),
            ),
            style: StreamMessageAnnotationStyle.from(
              trailingTextColor: colorScheme.textLink,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeOverrideSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;

    return _Section(
      label: 'THEME OVERRIDES',
      description: 'Per-instance overrides via StreamMessageItemTheme.',
      children: [
        _ExampleCard(
          label: 'Custom colors',
          subtitle: 'Purple icon and text color.',
          child: StreamMessageItemTheme(
            data: StreamMessageItemThemeData(
              annotation: StreamMessageAnnotationStyle.from(
                textColor: Colors.purple,
                iconColor: Colors.purple,
              ),
            ),
            child: StreamMessageAnnotation(
              leading: Icon(icons.save),
              label: const Text('Saved for later'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Custom icon size',
          subtitle: 'Larger icon (20px).',
          child: StreamMessageItemTheme(
            data: StreamMessageItemThemeData(
              annotation: StreamMessageAnnotationStyle.from(
                iconSize: 20,
              ),
            ),
            child: StreamMessageAnnotation(
              leading: Icon(icons.pin),
              label: const Text('Pinned by Alice'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Custom spacing',
          subtitle: 'Wider gap (12px) between icon and label.',
          child: StreamMessageAnnotation(
            leading: Icon(icons.save),
            label: const Text('Saved for later'),
            style: StreamMessageAnnotationStyle.from(spacing: 12),
          ),
        ),
        _ExampleCard(
          label: 'Label only',
          subtitle: 'No leading icon.',
          child: StreamMessageAnnotation(
            label: const Text('Saved for later'),
          ),
        ),
      ],
    );
  }
}

class _RealWorldSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final colorScheme = context.streamColorScheme;

    return _Section(
      label: 'REAL-WORLD EXAMPLES',
      description: 'Annotations displayed above message bubbles.',
      children: [
        _ExampleCard(
          label: 'Saved message',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              StreamMessageItemTheme(
                data: StreamMessageItemThemeData(
                  annotation: StreamMessageAnnotationStyle.from(
                    textColor: colorScheme.accentPrimary,
                    iconColor: colorScheme.accentPrimary,
                  ),
                ),
                child: StreamMessageAnnotation(
                  leading: Icon(icons.save),
                  label: const Text('Saved for later'),
                ),
              ),
              StreamMessageBubble(
                child: StreamMessageText('Check out this new design system!'),
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Pinned message',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              StreamMessageAnnotation(
                leading: Icon(icons.pin),
                label: const Text('Pinned by Alice'),
              ),
              StreamMessageBubble(
                child: StreamMessageText('Meeting at 3 PM today.'),
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Reminder message',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              StreamMessageAnnotation(
                leading: Icon(icons.bell),
                label: const Text('Reminder set ·'),
                trailing: const Text('In 30 minutes'),
              ),
              StreamMessageBubble(
                child: StreamMessageText('Remember to review the PR.'),
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Also sent in channel (row-level tap)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              StreamMessageAnnotation(
                onTap: () {},
                leading: Icon(icons.arrowUp),
                label: const Text('Also sent in channel ·'),
                trailing: const Text('View'),
                style: StreamMessageAnnotationStyle.from(
                  trailingTextColor: colorScheme.textLink,
                ),
              ),
              StreamMessageBubble(
                child: StreamMessageText('This was also sent to the main channel.'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Helper Widgets & Data
// =============================================================================

enum _IconOption {
  bookmark('Bookmark'),
  pin('Pin'),
  bellNotification('Bell'),
  arrowUp('Arrow Up'),
  translate('Translate')
  ;

  const _IconOption(this.label);

  final String label;

  IconData resolve(StreamIcons icons) => switch (this) {
    bookmark => icons.save,
    pin => icons.pin,
    bellNotification => icons.bell,
    arrowUp => icons.arrowUp,
    translate => Icons.translate,
  };
}

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.children,
    this.description,
  });

  final String label;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            _SectionLabel(label: label),
            if (description case final desc?)
              Text(
                desc,
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textTertiary,
                ),
              ),
          ],
        ),
        ...children,
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
    return Text(
      label,
      style: textTheme.metadataEmphasis.copyWith(
        letterSpacing: 1.2,
        color: colorScheme.accentPrimary,
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.label,
    required this.child,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;
    final textTheme = context.streamTextTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.backgroundApp,
        borderRadius: BorderRadius.all(radius.md),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                label,
                style: textTheme.metadataEmphasis.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              if (subtitle case final sub?)
                Text(
                  sub,
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
