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

  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Saved for later',
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
    initialOption: _IconOption.bookmark,
    labelBuilder: (v) => v.label,
    description: 'The leading icon to display.',
  );

  final spacing = context.knobs.double.slider(
    label: 'Spacing',
    initialValue: 4,
    max: 16,
    divisions: 16,
    description: 'Gap between icon and label. Overrides theme when set.',
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

  return Center(
    child: StreamMessageAnnotation(
      leading: showLeading ? Icon(leadingIcon.resolve(icons)) : null,
      label: Text(label),
      style: StreamMessageAnnotationStyle.from(
        spacing: spacing,
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
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
              leading: Icon(icons.save20),
              label: const Text('Saved for later'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Pinned',
          child: StreamMessageAnnotation(
            leading: Icon(icons.pin20),
            label: const Text('Pinned by Alice'),
          ),
        ),
        _ExampleCard(
          label: 'Reminder (.rich)',
          subtitle: 'Bold label + regular timestamp via .rich constructor.',
          child: StreamMessageAnnotation.rich(
            leading: Icon(icons.bell20),
            label: 'Reminder set · ',
            spans: const [TextSpan(text: 'In 2 hours')],
          ),
        ),
        _ExampleCard(
          label: 'Translated (.rich)',
          subtitle: 'Bold label + regular action text via .rich constructor.',
          child: StreamMessageAnnotation.rich(
            leading: const Icon(Icons.translate),
            label: 'Translated · ',
            spans: const [TextSpan(text: 'Show original')],
          ),
        ),
        _ExampleCard(
          label: 'Also sent in channel (.rich)',
          subtitle: 'Bold label + link-colored span override.',
          child: StreamMessageAnnotation.rich(
            leading: Icon(icons.arrowUp20),
            label: 'Also sent in channel · ',
            spans: [
              TextSpan(
                text: 'View',
                style: TextStyle(color: colorScheme.textLink),
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Replied to a thread (.rich)',
          subtitle: 'Bold label + link-colored span override.',
          child: StreamMessageAnnotation.rich(
            leading: Icon(icons.arrowUp20),
            label: 'Replied to a thread · ',
            spans: [
              TextSpan(
                text: 'View',
                style: TextStyle(color: colorScheme.textLink),
              ),
            ],
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
              leading: Icon(icons.save20),
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
              leading: Icon(icons.pin20),
              label: const Text('Pinned by Alice'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Custom spacing',
          subtitle: 'Wider gap (12px) between icon and label.',
          child: StreamMessageAnnotation(
            leading: Icon(icons.save20),
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
                  leading: Icon(icons.save20),
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
                leading: Icon(icons.pin20),
                label: const Text('Pinned by Alice'),
              ),
              StreamMessageBubble(
                child: StreamMessageText('Meeting at 3 PM today.'),
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Reminder message (.rich)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              StreamMessageAnnotation.rich(
                leading: Icon(icons.bell20),
                label: 'Reminder set · ',
                spans: const [TextSpan(text: 'In 30 minutes')],
              ),
              StreamMessageBubble(
                child: StreamMessageText('Remember to review the PR.'),
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Also sent in channel (.rich)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              StreamMessageAnnotation.rich(
                leading: Icon(icons.arrowUp20),
                label: 'Also sent in channel · ',
                spans: [
                  TextSpan(
                    text: 'View',
                    style: TextStyle(color: colorScheme.textLink),
                  ),
                ],
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
    bookmark => icons.save20,
    pin => icons.pin20,
    bellNotification => icons.bell20,
    arrowUp => icons.arrowUp20,
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
