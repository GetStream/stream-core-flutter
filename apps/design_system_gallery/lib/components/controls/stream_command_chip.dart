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
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  var _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.object.dropdown(
      label: 'Label',
      options: _commonCommands,
      initialOption: 'GIPHY',
      labelBuilder: (l) => l,
      description: 'A common slash command label.',
    );

    final dismissible = context.knobs.boolean(
      label: 'Dismissible',
      initialValue: true,
      description: 'Whether tapping the chip dismisses it.',
    );

    if (_dismissed) {
      return Center(
        child: TextButton(
          onPressed: () => setState(() => _dismissed = false),
          child: const Text('Tap to bring back the chip'),
        ),
      );
    }

    return Center(
      child: StreamCommandChip(
        label: label,
        onDismiss: dismissible ? () => setState(() => _dismissed = true) : null,
      ),
    );
  }
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
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xl,
        children: const [
          _CommonCommandsSection(),
          _DismissStatesSection(),
          _LabelLengthSection(),
          _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Common Commands Section
// =============================================================================

class _CommonCommandsSection extends StatelessWidget {
  const _CommonCommandsSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'COMMON COMMANDS'),
        _Card(
          description:
              'Command chips surface the active slash command — labels are '
              'typically short, uppercase, and map to a single action.',
          child: Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              for (final label in _commonCommands) StreamCommandChip(label: label, onDismiss: () {}),
            ],
          ),
        ),
        Text(
          'Labels are rendered in the ${'`metadataEmphasis`'} text style '
          "and don't respond to OS text scaling so the chip stays compact.",
          style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
        ),
      ],
    );
  }
}

// =============================================================================
// Dismiss States Section
// =============================================================================

class _DismissStatesSection extends StatelessWidget {
  const _DismissStatesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'DISMISS STATES'),
        _Card(
          description:
              'Tapping anywhere on a dismissible chip invokes ${'`onDismiss`'}; '
              'the × icon is a visual affordance. When ${'`onDismiss`'} is null '
              'the chip is inert and the × is hidden.',
          child: Wrap(
            spacing: spacing.lg,
            runSpacing: spacing.md,
            children: [
              _Labeled(
                label: 'Dismissible',
                child: StreamCommandChip(label: 'GIPHY', onDismiss: () {}),
              ),
              _Labeled(
                label: 'Inert',
                child: StreamCommandChip(label: 'GIPHY'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Label Length Section
// =============================================================================

class _LabelLengthSection extends StatelessWidget {
  const _LabelLengthSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'LABEL LENGTH'),
        _Card(
          description:
              'The chip wraps its label in a single line with ellipsis — '
              'parent width constrains how wide the chip can grow.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.sm,
            children: [
              for (final width in [120.0, 200.0, 320.0])
                _Labeled(
                  label: 'max width ${width.toInt()}',
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width),
                    child: StreamCommandChip(
                      label: 'VERY LONG COMMAND NAME',
                      onDismiss: () {},
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Real-World Section
// =============================================================================

class _RealWorldSection extends StatelessWidget {
  const _RealWorldSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'REAL-WORLD EXAMPLES'),
        _ExampleCard(
          title: 'Attachment Overlay',
          description:
              'Command chip overlaid on an attachment thumbnail, indicating '
              'the attachment was produced by a slash command.',
          child: _AttachmentOverlayExample(),
        ),
        _ExampleCard(
          title: 'Composer Header',
          description:
              'Command chip rendered inline inside the message composer, '
              'tagging the draft as a GIPHY command.',
          child: _ComposerHeaderExample(),
        ),
      ],
    );
  }
}

class _AttachmentOverlayExample extends StatelessWidget {
  const _AttachmentOverlayExample();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Stack(
        children: [
          Container(
            width: 220,
            height: 140,
            decoration: BoxDecoration(
              color: colorScheme.backgroundSurfaceSubtle,
              borderRadius: BorderRadius.all(radius.md),
              border: Border.all(color: colorScheme.borderSubtle),
            ),
            child: Center(
              child: Icon(
                Icons.gif_box_outlined,
                size: 56,
                color: colorScheme.textDisabled,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(spacing.xs),
            child: StreamCommandChip(
              label: 'GIPHY',
              onDismiss: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerHeaderExample extends StatelessWidget {
  const _ComposerHeaderExample();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.backgroundElevation1,
        borderRadius: BorderRadius.all(radius.xxxl),
        border: Border.all(color: colorScheme.borderDefault),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: spacing.xs),
            child: StreamCommandChip(
              label: 'GIPHY',
              onDismiss: () {},
            ),
          ),
          Expanded(
            child: Text(
              'cat',
              style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
            ),
          ),
          Icon(
            context.streamIcons.send,
            color: colorScheme.accentPrimary,
            size: 24,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _Card extends StatelessWidget {
  const _Card({required this.description, required this.child});

  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.lg),
        boxShadow: boxShadow.elevation1,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.md,
        children: [
          Text(
            description,
            style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
          ),
          child,
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.lg),
        boxShadow: boxShadow.elevation1,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.captionEmphasis.copyWith(color: colorScheme.textPrimary),
                ),
                Text(
                  description,
                  style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.md),
            color: colorScheme.backgroundSurfaceSubtle,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xs,
      children: [
        child,
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
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

// =============================================================================
// Helpers
// =============================================================================

const _commonCommands = [
  'GIPHY',
  'IMGUR',
  'BAN',
  'UNBAN',
  'MUTE',
  'UNMUTE',
  'FLAG',
];
