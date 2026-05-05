import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamAppBar,
  path: '[Components]/Header',
)
Widget buildStreamAppBarPlayground(BuildContext context) {
  final title = context.knobs.stringOrNull(
    label: 'Title',
    initialValue: 'Details',
    description: 'The primary header text. Clear to omit the title.',
  );

  final subtitle = context.knobs.stringOrNull(
    label: 'Subtitle',
    description: 'Optional second line below the title.',
  );

  final showLeading = context.knobs.boolean(
    label: 'Show leading',
    initialValue: true,
    description:
        'Renders a back-style icon button before the title. '
        'When off, auto-implied leading only appears if the bar is '
        'inside a poppable route (see Showcase).',
  );

  final showTrailing = context.knobs.boolean(
    label: 'Show trailing',
    initialValue: true,
    description: 'Renders a primary-action button after the title.',
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

  return Align(
    alignment: Alignment.topCenter,
    child: StreamAppBar(
      style: StreamAppBarStyle(
        padding: EdgeInsets.all(padding),
        spacing: spacing,
      ),
      leading: showLeading
          ? StreamButton.icon(
              icon: Icon(context.streamIcons.chevronLeft),
              style: StreamButtonStyle.secondary,
              type: StreamButtonType.ghost,
              onPressed: () {},
            )
          : null,
      title: (title != null && title.isNotEmpty) ? Text(title) : null,
      subtitle: (subtitle != null && subtitle.isNotEmpty) ? Text(subtitle) : null,
      trailing: showTrailing
          ? StreamButton.icon(
              icon: Icon(context.streamIcons.plus),
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
  type: StreamAppBar,
  path: '[Components]/Header',
)
Widget buildStreamAppBarShowcase(BuildContext context) {
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
          _AppBarExample(
            label: 'Title only',
            bar: StreamAppBar(title: const Text('Details')),
          ),
          SizedBox(height: spacing.md),
          _AppBarExample(
            label: 'Title and subtitle',
            bar: StreamAppBar(
              title: const Text('Details'),
              subtitle: const Text('Additional information'),
            ),
          ),
          SizedBox(height: spacing.md),
          _AppBarExample(
            label: 'Leading only — trailing reserves a spacer',
            bar: StreamAppBar(
              leading: StreamButton.icon(
                icon: Icon(context.streamIcons.chevronLeft),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
              title: const Text('Details'),
            ),
          ),
          SizedBox(height: spacing.md),
          _AppBarExample(
            label: 'Trailing only — leading reserves a spacer',
            bar: StreamAppBar(
              title: const Text('Details'),
              trailing: StreamButton.icon(
                icon: Icon(context.streamIcons.plus),
                onPressed: () {},
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _AppBarExample(
            label: 'Full layout with subtitle',
            bar: StreamAppBar(
              leading: StreamButton.icon(
                icon: Icon(context.streamIcons.chevronLeft),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
              title: const Text('Group chat'),
              subtitle: const Text('5 members, 3 online'),
              trailing: StreamButton.icon(
                icon: Icon(context.streamIcons.plus),
                onPressed: () {},
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _AppBarExample(
            label: 'Long title truncates gracefully',
            bar: StreamAppBar(
              leading: StreamButton.icon(
                icon: Icon(context.streamIcons.chevronLeft),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
              title: const Text(
                'A rather long title that should ellipsize gracefully',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: StreamButton.icon(
                icon: Icon(context.streamIcons.plus),
                onPressed: () {},
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          // Demonstrates the layout's centred-title behaviour: a narrow icon
          // leading and a wide text-button trailing have very different
          // intrinsic widths, but [StreamHeaderToolbar] reserves symmetric
          // space around the middle so the title stays geometrically
          // centred in the bar's full width.
          _AppBarExample(
            label: 'Asymmetric leading / trailing — title stays centred',
            bar: StreamAppBar(
              leading: StreamButton.icon(
                icon: Icon(context.streamIcons.chevronLeft),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
              title: const Text('Group Info'),
              trailing: StreamButton(
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.outline,
                size: StreamButtonSize.small,
                onPressed: () {},
                child: const Text('Edit'),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _AppBarExample(
            label: 'Style leadingStyle/trailingStyle propagates to plain StreamButtons',
            bar: StreamAppBar(
              style: StreamAppBarStyle(
                leadingStyle: StreamButtonThemeStyle.from(
                  backgroundColor: colorScheme.backgroundSurfaceSubtle,
                  foregroundColor: colorScheme.textPrimary,
                ),
                trailingStyle: StreamButtonThemeStyle.from(
                  backgroundColor: colorScheme.accentError,
                  foregroundColor: colorScheme.textOnAccent,
                ),
              ),
              leading: StreamButton.icon(
                icon: Icon(context.streamIcons.chevronLeft),
                onPressed: () {},
              ),
              title: const Text('Discard changes?'),
              trailing: StreamButton.icon(
                icon: Icon(context.streamIcons.delete),
                onPressed: () {},
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          const _AutoImplyLeadingDemo(),
        ],
      ),
    ),
  );
}

// Demonstrates the auto-implied leading button. Each launcher pushes a route
// whose Scaffold uses a StreamAppBar with no explicit `leading`. On a regular
// pushed page the icon adapts to the host platform — chevron on iOS / macOS,
// arrow-left on Android / web / desktop. On a fullscreen dialog the icon is
// always a cross. Pressing the auto-inserted button pops the route.
class _AutoImplyLeadingDemo extends StatelessWidget {
  const _AutoImplyLeadingDemo();

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
          'Auto-implied leading — tap to see the pushed app bar',
          style: textTheme.captionEmphasis.copyWith(color: colorScheme.textSecondary),
        ),
        SizedBox(height: spacing.xs),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          padding: EdgeInsets.all(spacing.sm),
          child: Row(
            spacing: spacing.sm,
            children: [
              Expanded(
                child: StreamButton(
                  style: StreamButtonStyle.secondary,
                  type: StreamButtonType.outline,
                  onPressed: () => _push(context, fullscreenDialog: false),
                  child: const Text('Push page'),
                ),
              ),
              Expanded(
                child: StreamButton(
                  onPressed: () => _push(context, fullscreenDialog: true),
                  child: const Text('Push fullscreen dialog'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _push(BuildContext context, {required bool fullscreenDialog}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: fullscreenDialog,
        builder: (_) => Scaffold(
          appBar: StreamAppBar(
            title: Text(fullscreenDialog ? 'Fullscreen dialog' : 'Pushed page'),
          ),
          body: const Center(child: Text('Pop via the auto-implied leading button.')),
        ),
      ),
    );
  }
}

class _AppBarExample extends StatelessWidget {
  const _AppBarExample({required this.label, required this.bar});

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
