import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamSplitButton,
  path: '[Components]/Buttons',
)
Widget buildStreamSplitButtonPlayground(BuildContext context) {
  final icons = context.streamIcons;

  final style = context.knobs.object.dropdown(
    label: 'Style',
    options: StreamButtonStyle.values,
    initialOption: StreamButtonStyle.secondary,
    labelBuilder: (option) => option.name,
    description: 'Split button visual style variant.',
  );

  final type = context.knobs.object.dropdown(
    label: 'Type',
    options: StreamButtonType.values,
    initialOption: StreamButtonType.solid,
    labelBuilder: (option) => option.name,
    description: 'Split button type variant. Outline draws one border around both halves.',
  );

  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: StreamButtonSize.values,
    initialOption: StreamButtonSize.small,
    labelBuilder: (option) => option.name,
    description: 'Painted area of each half. The tap target stays accessible regardless.',
  );

  final caretUp = context.knobs.boolean(
    label: 'Caret Up',
    description: 'Point the trailing caret up, as when the menu it opens is already showing.',
  );

  final leadingEnabled = context.knobs.boolean(
    label: 'Leading Enabled',
    initialValue: true,
    description: 'Whether the primary half accepts taps.',
  );

  final trailingEnabled = context.knobs.boolean(
    label: 'Trailing Enabled',
    initialValue: true,
    description: 'Whether the trailing half accepts taps.',
  );

  final showErrorBadge = context.knobs.boolean(
    label: 'Error Badge',
    description: 'Overlay a StreamErrorBadge, as a call control does when the mic fails.',
  );

  return Center(
    child: _MaybeBadged(
      showErrorBadge: showErrorBadge,
      child: StreamSplitButton.icon(
        icon: Icon(icons.voiceFill),
        trailingIcon: Icon(caretUp ? icons.caretUp : icons.caretDown),
        style: style,
        type: type,
        size: size,
        tooltip: 'Mute',
        trailingTooltip: 'Audio settings',
        onPressed: leadingEnabled ? () {} : null,
        onTrailingPressed: trailingEnabled ? () {} : null,
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamSplitButton,
  path: '[Components]/Buttons',
)
Widget buildStreamSplitButtonShowcase(BuildContext context) {
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
          _StyleTypeMatrixSection(),
          _SizeScaleSection(),
          _DisabledSection(),
          _CallControlSection(),
        ],
      ),
    ),
  );
}

class _StyleTypeMatrixSection extends StatelessWidget {
  const _StyleTypeMatrixSection();

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'Style × type',
      description: 'The surface resolves from the same button style the halves use, so the two never drift apart.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.md,
        children: [
          for (final style in StreamButtonStyle.values)
            Row(
              spacing: spacing.md,
              children: [
                SizedBox(width: 88, child: Text(style.name)),
                for (final type in StreamButtonType.values)
                  StreamSplitButton.icon(
                    icon: Icon(icons.voiceFill),
                    trailingIcon: Icon(icons.caretDown),
                    style: style,
                    type: type,
                    size: StreamButtonSize.small,
                    tooltip: 'Mute',
                    trailingTooltip: 'Audio settings',
                    onPressed: () {},
                    onTrailingPressed: () {},
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SizeScaleSection extends StatelessWidget {
  const _SizeScaleSection();

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'Sizes',
      description:
          'Size sets the area a half highlights on hover and press — press one to see it. '
          'The surface itself always hugs the tap targets.',
      child: Row(
        spacing: spacing.md,
        children: [
          for (final size in StreamButtonSize.values)
            StreamSplitButton.icon(
              icon: Icon(icons.voiceFill),
              trailingIcon: Icon(icons.caretDown),
              style: StreamButtonStyle.secondary,
              size: size,
              tooltip: size.name,
              trailingTooltip: 'Audio settings',
              onPressed: () {},
              onTrailingPressed: () {},
            ),
        ],
      ),
    );
  }
}

class _DisabledSection extends StatelessWidget {
  const _DisabledSection();

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'Disabled halves',
      description: 'Each half disables on its own. The surface only goes disabled once both halves are.',
      child: Row(
        spacing: spacing.md,
        children: [
          for (final (label, leading, trailing) in const [
            ('leading', false, true),
            ('trailing', true, false),
            ('both', false, false),
          ])
            Column(
              spacing: spacing.xs,
              children: [
                StreamSplitButton.icon(
                  icon: Icon(icons.voiceFill),
                  trailingIcon: Icon(icons.caretDown),
                  style: StreamButtonStyle.secondary,
                  size: StreamButtonSize.small,
                  onPressed: leading ? () {} : null,
                  onTrailingPressed: trailing ? () {} : null,
                ),
                Text(label),
              ],
            ),
        ],
      ),
    );
  }
}

class _CallControlSection extends StatefulWidget {
  const _CallControlSection();

  @override
  State<_CallControlSection> createState() => _CallControlSectionState();
}

class _CallControlSectionState extends State<_CallControlSection> {
  var _isMuted = false;
  var _isSettingsOpen = false;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;

    return _ExampleCard(
      title: 'Call control',
      description:
          'A microphone toggle paired with a caret that opens the audio settings, '
          'badged when the device fails.',
      child: Center(
        child: _MaybeBadged(
          showErrorBadge: true,
          child: StreamSplitButton.icon(
            icon: Icon(_isMuted ? icons.voiceOffFill : icons.voiceFill),
            trailingIcon: Icon(_isSettingsOpen ? icons.caretUp : icons.caretDown),
            style: _isMuted ? StreamButtonStyle.destructive : StreamButtonStyle.secondary,
            size: StreamButtonSize.small,
            tooltip: _isMuted ? 'Unmute' : 'Mute',
            trailingTooltip: 'Audio settings',
            onPressed: () => setState(() => _isMuted = !_isMuted),
            onTrailingPressed: () => setState(() => _isSettingsOpen = !_isSettingsOpen),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

/// Overlays a [StreamErrorBadge] on the trailing top corner of [child].
///
/// The badge is not part of [StreamSplitButton] — call controls compose the
/// two, and this shows what that looks like.
class _MaybeBadged extends StatelessWidget {
  const _MaybeBadged({required this.showErrorBadge, required this.child});

  final bool showErrorBadge;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!showErrorBadge) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(top: -4, end: -4, child: StreamErrorBadge(size: StreamErrorBadgeSize.sm)),
      ],
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
            padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.captionEmphasis.copyWith(color: colorScheme.textPrimary)),
                Text(description, style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary)),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          Padding(padding: EdgeInsets.all(spacing.md), child: child),
        ],
      ),
    );
  }
}
