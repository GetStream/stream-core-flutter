import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamEmptyState,
  path: '[Components]/Common',
)
Widget buildStreamEmptyStatePlayground(BuildContext context) {
  final showTitle = context.knobs.boolean(
    label: 'Show Title',
    initialValue: true,
    description: 'Whether to show a title. Leave it out for a single line of text under the icon.',
  );

  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'No recordings yet',
    description: 'What is missing.',
  );

  final showDescription = context.knobs.boolean(
    label: 'Show Description',
    initialValue: true,
    description: 'Whether to show a description under the title.',
  );

  final description = context.knobs.string(
    label: 'Description',
    initialValue: 'Recordings you make show up here.',
    description: 'Why it is missing, or what would fill it.',
  );

  final showAction = context.knobs.boolean(
    label: 'Show Action',
    description: 'Whether to show a button under the text.',
  );

  final actionLabel = context.knobs.string(
    label: 'Action Label',
    initialValue: 'Try again',
    description: 'The label of the button under the text.',
  );

  return Center(
    child: StreamEmptyState(
      icon: Icon(context.streamIcons.recordLibraryFill),
      // An empty state needs a title or a description, so the description stays when both are switched off.
      title: showTitle ? Text(title) : null,
      description: showDescription || !showTitle ? Text(description) : null,
      action: showAction
          ? StreamButton(
              style: StreamButtonStyle.secondary,
              type: StreamButtonType.outline,
              onPressed: () {},
              child: Text(actionLabel),
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
  type: StreamEmptyState,
  path: '[Components]/Common',
)
Widget buildStreamEmptyStateShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;
  final icons = context.streamIcons;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xl,
        children: [
          _Section(
            label: 'DESCRIPTION ONLY',
            caption: 'A single line of secondary text under the icon',
            child: StreamEmptyState(
              icon: Icon(icons.search),
              description: const Text('No results'),
            ),
          ),
          _Section(
            label: 'TITLE ONLY',
            caption: 'An icon over a title',
            child: StreamEmptyState(
              icon: Icon(icons.search),
              title: const Text('No results'),
            ),
          ),
          _Section(
            label: 'WITH DESCRIPTION',
            caption: 'The description says why, or what would fill the place',
            child: StreamEmptyState(
              icon: Icon(icons.recordLibraryFill),
              title: const Text('No recordings yet'),
              description: const Text('Recordings you make show up here.'),
            ),
          ),
          _Section(
            label: 'WITH ACTION',
            caption: 'A failure, with a button to try again',
            child: StreamEmptyState(
              icon: Icon(icons.exclamationCircleFill),
              title: const Text("Couldn't load recordings"),
              description: const Text('Check your connection and try again.'),
              action: StreamButton(
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.outline,
                onPressed: () {},
                child: const Text('Try again'),
              ),
            ),
          ),
          _Section(
            label: 'LONG DESCRIPTION',
            caption: 'The text wraps at the available width and stays centred',
            child: StreamEmptyState(
              icon: Icon(icons.folder),
              title: const Text('No files in this folder'),
              description: const Text(
                'Files shared in this conversation show up here, newest first, once they have finished uploading.',
              ),
            ),
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
  const _Section({required this.label, required this.caption, required this.child});

  final String label;
  final String caption;
  final Widget child;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(spacing.md, spacing.md, spacing.md, 0),
                child: Text(caption, style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary)),
              ),
              child,
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
