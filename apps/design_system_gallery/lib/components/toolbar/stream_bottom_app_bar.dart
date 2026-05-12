import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamBottomAppBar,
  path: '[Components]/Toolbar',
)
Widget buildStreamBottomAppBarPlayground(BuildContext context) {
  final title = context.knobs.stringOrNull(
    label: 'Title',
    initialValue: '1 of 9',
    description: 'The centered text. Typically a page counter. Clear to omit.',
  );

  final subtitle = context.knobs.stringOrNull(
    label: 'Subtitle',
    description: 'Optional second line below the title.',
  );

  final showLeading = context.knobs.boolean(
    label: 'Show leading',
    initialValue: true,
    description: 'Renders an action button at the start edge (e.g. share).',
  );

  final showTrailing = context.knobs.boolean(
    label: 'Show trailing',
    initialValue: true,
    description: 'Renders an action button at the end edge (e.g. gallery).',
  );

  final padding = context.knobs.double.slider(
    label: 'Padding',
    initialValue: 12,
    max: 32,
    description: 'Uniform padding around the content row.',
  );

  final spacing = context.knobs.double.slider(
    label: 'Spacing',
    initialValue: 12,
    max: 32,
    description: 'Horizontal gap between leading, heading, and trailing.',
  );

  final primary = context.knobs.boolean(
    label: 'Primary',
    initialValue: true,
    description: 'When true, wraps in SafeArea(top: false) so the bar clears '
        'the system bottom inset (home indicator).',
  );

  return Align(
    alignment: Alignment.bottomCenter,
    child: StreamBottomAppBar(
      primary: primary,
      style: StreamBottomAppBarStyle(
        padding: EdgeInsets.all(padding),
        spacing: spacing,
      ),
      leading: showLeading
          ? StreamButton.icon(
              icon: Icon(context.streamIcons.export),
              style: StreamButtonStyle.secondary,
              type: StreamButtonType.ghost,
              onPressed: () {},
            )
          : null,
      title: (title != null && title.isNotEmpty) ? Text(title) : null,
      subtitle: (subtitle != null && subtitle.isNotEmpty) ? Text(subtitle) : null,
      trailing: showTrailing
          ? StreamButton.icon(
              icon: Icon(context.streamIcons.gallery),
              style: StreamButtonStyle.secondary,
              type: StreamButtonType.ghost,
              onPressed: () {},
            )
          : null,
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamBottomAppBar,
  path: '[Components]/Toolbar',
)
Widget buildStreamBottomAppBarShowcase(BuildContext context) {
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
          _BarExample(
            label: 'Counter only',
            bar: StreamBottomAppBar(title: const Text('1 of 9')),
          ),
          SizedBox(height: spacing.md),
          _BarExample(
            label: 'Title and subtitle',
            bar: StreamBottomAppBar(
              title: const Text('1 of 9'),
              subtitle: const Text('Tap to share'),
            ),
          ),
          SizedBox(height: spacing.md),
          _BarExample(
            label: 'Leading only — trailing reserves a spacer',
            bar: StreamBottomAppBar(
              leading: StreamButton.icon(
                icon: Icon(context.streamIcons.export),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
              title: const Text('1 of 9'),
            ),
          ),
          SizedBox(height: spacing.md),
          _BarExample(
            label: 'Trailing only — leading reserves a spacer',
            bar: StreamBottomAppBar(
              title: const Text('1 of 9'),
              trailing: StreamButton.icon(
                icon: Icon(context.streamIcons.gallery),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _BarExample(
            label: 'Full layout — share, counter, gallery',
            bar: StreamBottomAppBar(
              leading: StreamButton.icon(
                icon: Icon(context.streamIcons.export),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
              title: const Text('1 of 9'),
              trailing: StreamButton.icon(
                icon: Icon(context.streamIcons.gallery),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _BarExample(
            label: 'Asymmetric slots — title stays geometrically centred',
            bar: StreamBottomAppBar(
              leading: StreamButton.icon(
                icon: Icon(context.streamIcons.export),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
              title: const Text('1 of 9'),
              trailing: StreamButton(
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.outline,
                size: StreamButtonSize.small,
                onPressed: () {},
                child: const Text('Done'),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _BarExample(
            label: 'Per-slot button style propagation via style.leadingStyle / trailingStyle',
            bar: StreamBottomAppBar(
              style: StreamBottomAppBarStyle(
                leadingStyle: StreamButtonThemeStyle.from(
                  backgroundColor: colorScheme.backgroundSurfaceSubtle,
                  foregroundColor: colorScheme.textPrimary,
                ),
                trailingStyle: StreamButtonThemeStyle.from(
                  backgroundColor: colorScheme.accentPrimary,
                  foregroundColor: colorScheme.textOnAccent,
                ),
              ),
              leading: StreamButton.icon(
                icon: Icon(context.streamIcons.export),
                onPressed: () {},
              ),
              title: const Text('Tap an action'),
              trailing: StreamButton.icon(
                icon: Icon(context.streamIcons.checkmark),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BarExample extends StatelessWidget {
  const _BarExample({required this.label, required this.bar});

  final String label;
  final Widget bar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.captionEmphasis.copyWith(
            color: colorScheme.textSecondary,
          ),
        ),
        SizedBox(height: spacing.xs),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: bar,
        ),
      ],
    );
  }
}
