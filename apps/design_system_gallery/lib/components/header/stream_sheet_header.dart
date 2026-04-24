import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamSheetHeader,
  path: '[Components]/Header',
)
Widget buildStreamSheetHeaderPlayground(BuildContext context) {
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
        'Renders a close-style icon button before the title. '
        'When off, auto-implied leading only appears if the header is '
        'inside a poppable route (see Showcase).',
  );

  final showTrailing = context.knobs.boolean(
    label: 'Show trailing',
    initialValue: true,
    description: 'Renders a confirm-style icon button after the title.',
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
    child: StreamSheetHeader(
      padding: EdgeInsets.all(padding),
      spacing: spacing,
      leading: showLeading
          ? StreamButton.icon(
              icon: context.streamIcons.xmark,
              style: StreamButtonStyle.secondary,
              type: StreamButtonType.outline,
              onTap: () {},
            )
          : null,
      title: (title != null && title.isNotEmpty) ? Text(title) : null,
      subtitle: (subtitle != null && subtitle.isNotEmpty) ? Text(subtitle) : null,
      trailing: showTrailing
          ? StreamButton.icon(
              icon: context.streamIcons.checkmark,
              onTap: () {},
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
  type: StreamSheetHeader,
  path: '[Components]/Header',
)
Widget buildStreamSheetHeaderShowcase(BuildContext context) {
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
          _HeaderExample(
            label: 'Title only',
            header: StreamSheetHeader(title: const Text('Details')),
          ),
          SizedBox(height: spacing.md),
          _HeaderExample(
            label: 'Title and subtitle',
            header: StreamSheetHeader(
              title: const Text('Details'),
              subtitle: const Text('Additional information'),
            ),
          ),
          SizedBox(height: spacing.md),
          _HeaderExample(
            label: 'Leading only — trailing reserves a spacer',
            header: StreamSheetHeader(
              leading: StreamButton.icon(
                icon: context.streamIcons.xmark,
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.outline,
                onTap: () {},
              ),
              title: const Text('Details'),
            ),
          ),
          SizedBox(height: spacing.md),
          _HeaderExample(
            label: 'Trailing only — leading reserves a spacer',
            header: StreamSheetHeader(
              title: const Text('Details'),
              trailing: StreamButton.icon(
                icon: context.streamIcons.checkmark,
                onTap: () {},
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _HeaderExample(
            label: 'Full layout with subtitle',
            header: StreamSheetHeader(
              leading: StreamButton.icon(
                icon: context.streamIcons.xmark,
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.outline,
                onTap: () {},
              ),
              title: const Text('Edit profile'),
              subtitle: const Text('Tap save to apply changes'),
              trailing: StreamButton.icon(
                icon: context.streamIcons.checkmark,
                onTap: () {},
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _HeaderExample(
            label: 'Long title truncates gracefully',
            header: StreamSheetHeader(
              leading: StreamButton.icon(
                icon: context.streamIcons.xmark,
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.outline,
                onTap: () {},
              ),
              title: const Text(
                'A rather long title that should ellipsize gracefully',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: StreamButton.icon(
                icon: context.streamIcons.checkmark,
                onTap: () {},
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _HeaderExample(
            label: 'Theme-level leadingStyle/trailingStyle propagates to plain StreamButtons',
            header: StreamSheetHeader(
              leadingStyle: StreamButtonThemeStyle.from(
                backgroundColor: colorScheme.backgroundSurfaceSubtle,
                foregroundColor: colorScheme.textPrimary,
              ),
              trailingStyle: StreamButtonThemeStyle.from(
                backgroundColor: colorScheme.accentError,
                foregroundColor: colorScheme.textOnAccent,
              ),
              leading: StreamButton.icon(
                icon: context.streamIcons.xmark,
                onTap: () {},
              ),
              title: const Text('Discard changes?'),
              trailing: StreamButton.icon(
                icon: context.streamIcons.delete,
                onTap: () {},
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

// Demonstrates the auto-implied leading button. Tapping each launcher pushes
// a route containing a StreamSheetHeader with no explicit `leading`. On a
// fullscreen dialog the header shows a cross; on a normal page it shows a
// back chevron. Pressing either dismisses the route.
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
          'Auto-implied leading — tap to see the pushed header',
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
                  label: 'Push page',
                  style: StreamButtonStyle.secondary,
                  type: StreamButtonType.outline,
                  onTap: () => _push(context, fullscreenDialog: false),
                ),
              ),
              Expanded(
                child: StreamButton(
                  label: 'Push fullscreen dialog',
                  onTap: () => _push(context, fullscreenDialog: true),
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
          body: SafeArea(
            child: Column(
              children: [
                StreamSheetHeader(
                  title: Text(fullscreenDialog ? 'Fullscreen dialog' : 'Pushed page'),
                ),
                const Expanded(child: Center(child: Text('Pop via the auto-implied leading button.'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderExample extends StatelessWidget {
  const _HeaderExample({required this.label, required this.header});

  final String label;
  final Widget header;

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
          child: header,
        ),
      ],
    );
  }
}
