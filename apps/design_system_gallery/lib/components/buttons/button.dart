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
  path: '[Components]/Buttons',
)
Widget buildStreamButtonPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  var _isSelected = false;

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.string(
      label: 'Label',
      initialValue: 'Click me',
      description: 'The text displayed on the button.',
    );

    final style = context.knobs.object.dropdown(
      label: 'Style',
      options: StreamButtonStyle.values,
      initialOption: StreamButtonStyle.primary,
      labelBuilder: (option) => option.name,
      description: 'Button visual style variant.',
    );

    final type = context.knobs.object.dropdown(
      label: 'Type',
      options: StreamButtonType.values,
      initialOption: StreamButtonType.solid,
      labelBuilder: (option) => option.name,
      description: 'Button type variant.',
    );

    final size = context.knobs.object.dropdown(
      label: 'Size',
      options: StreamButtonSize.values,
      initialOption: StreamButtonSize.large,
      labelBuilder: (option) => option.name,
      description: 'Button size preset (affects padding and font size).',
    );

    final isIconOnly = context.knobs.boolean(
      label: 'Icon Only',
      description: 'Render as a circular icon-only button.',
    );

    final isDisabled = context.knobs.boolean(
      label: 'Disabled',
      description: 'Whether the button is disabled (non-interactive).',
    );

    final isFloating =
        isIconOnly &&
        context.knobs.boolean(
          label: 'Floating',
          description: 'Whether the button has a floating (elevated) appearance.',
        );

    final isSelectable = context.knobs.boolean(
      label: 'Selectable',
      description: 'Whether the button toggles its selected state on tap.',
    );

    final showLeadingIcon =
        !isIconOnly &&
        context.knobs.boolean(
          label: 'Leading Icon',
          description: 'Show an icon before the label.',
        );

    final showTrailingIcon =
        !isIconOnly &&
        context.knobs.boolean(
          label: 'Trailing Icon',
          description: 'Show an icon after the label.',
        );

    void onTap() {
      if (isSelectable) {
        setState(() => _isSelected = !_isSelected);
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isSelectable ? 'Button ${_isSelected ? 'selected' : 'deselected'}' : 'Button tapped!',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
    }

    return Center(
      child: isIconOnly
          ? StreamButton.icon(
              icon: Icons.add,
              style: style,
              type: type,
              size: size,
              isFloating: isFloating ? true : null,
              isSelected: isSelectable ? _isSelected : null,
              onTap: isDisabled ? null : onTap,
            )
          : StreamButton(
              label: label,
              style: style,
              type: type,
              size: size,
              isSelected: isSelectable ? _isSelected : null,
              onTap: isDisabled ? null : onTap,
              iconLeft: showLeadingIcon ? Icons.add : null,
              iconRight: showTrailingIcon ? Icons.arrow_forward : null,
            ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamButton,
  path: '[Components]/Buttons',
)
Widget buildStreamButtonShowcase(BuildContext context) {
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
          _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Style × Type Matrix Section
// =============================================================================

class _StyleTypeMatrixSection extends StatelessWidget {
  const _StyleTypeMatrixSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'STYLE × TYPE'),
        Column(
          spacing: spacing.sm,
          children: [
            for (final style in StreamButtonStyle.values) _StyleMatrixCard(style: style),
          ],
        ),
      ],
    );
  }
}

/// A card showing one style's full type matrix, mirroring the Figma layout:
///
/// ```text
///            ┌── Label ──┐  ┌── Icon ──┐
///            default  off   default  off
///   solid    [btn]  [btn]   [+]    [+]
///   outline  [btn]  [btn]   [+]    [+]
///   ghost    [btn]  [btn]   [+]    [+]
/// ```
class _StyleMatrixCard extends StatelessWidget {
  const _StyleMatrixCard({required this.style});

  final StreamButtonStyle style;

  static String _description(StreamButtonStyle style) {
    return switch (style) {
      StreamButtonStyle.primary => 'Brand/accent color scheme',
      StreamButtonStyle.secondary => 'Neutral/surface color scheme',
      StreamButtonStyle.destructive => 'Error/danger color scheme',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
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
          // Header
          Row(
            spacing: spacing.sm,
            children: [
              Text(
                style.name,
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                  fontFamily: 'monospace',
                ),
              ),
              Expanded(
                child: Text(
                  _description(style),
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          // Matrix: column headers + type rows
          Column(
            spacing: spacing.sm,
            children: [
              _MatrixHeaderRow(spacing: spacing, textTheme: textTheme, colorScheme: colorScheme),
              for (final type in StreamButtonType.values) _MatrixTypeRow(style: style, type: type),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatrixHeaderRow extends StatelessWidget {
  const _MatrixHeaderRow({
    required this.spacing,
    required this.textTheme,
    required this.colorScheme,
  });

  final StreamSpacing spacing;
  final StreamTextTheme textTheme;
  final StreamColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final headerStyle = textTheme.metadataDefault.copyWith(
      color: colorScheme.textTertiary,
      fontSize: 10,
    );

    return Row(
      children: [
        const SizedBox(width: 56),
        Expanded(
          child: Center(child: Text('default', style: headerStyle)),
        ),
        Expanded(
          child: Center(child: Text('disabled', style: headerStyle)),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Center(child: Text('default', style: headerStyle)),
        ),
        Expanded(
          child: Center(child: Text('disabled', style: headerStyle)),
        ),
      ],
    );
  }
}

class _MatrixTypeRow extends StatelessWidget {
  const _MatrixTypeRow({required this.style, required this.type});

  final StreamButtonStyle style;
  final StreamButtonType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Row(
      children: [
        // Row label
        SizedBox(
          width: 56,
          child: Text(
            type.name,
            style: textTheme.metadataEmphasis.copyWith(
              color: colorScheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
        // Label button — default
        Expanded(
          child: Center(
            child: StreamButton(
              label: 'Label',
              style: style,
              type: type,
              size: StreamButtonSize.small,
              onTap: () {},
            ),
          ),
        ),
        // Label button — disabled
        Expanded(
          child: Center(
            child: StreamButton(
              label: 'Label',
              style: style,
              type: type,
              size: StreamButtonSize.small,
            ),
          ),
        ),
        SizedBox(width: spacing.md),
        // Icon button — default
        Expanded(
          child: Center(
            child: StreamButton.icon(
              icon: Icons.add,
              style: style,
              type: type,
              size: StreamButtonSize.small,
              onTap: () {},
            ),
          ),
        ),
        // Icon button — disabled
        Expanded(
          child: Center(
            child: StreamButton.icon(
              icon: Icons.add,
              style: style,
              type: type,
              size: StreamButtonSize.small,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Size Scale Section
// =============================================================================

class _SizeScaleSection extends StatelessWidget {
  const _SizeScaleSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'SIZE SCALE'),
        Container(
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
            spacing: spacing.lg,
            children: [
              // Label buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final size in StreamButtonSize.values) _SizeDemo(size: size, isIconOnly: false),
                ],
              ),
              Divider(color: colorScheme.borderSubtle),
              // Icon-only buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final size in StreamButtonSize.values) _SizeDemo(size: size, isIconOnly: true),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SizeDemo extends StatelessWidget {
  const _SizeDemo({required this.size, required this.isIconOnly});

  final StreamButtonSize size;
  final bool isIconOnly;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isIconOnly)
          StreamButton.icon(icon: Icons.add, size: size, onTap: () {})
        else
          StreamButton(label: 'Button', size: size, onTap: () {}),
        SizedBox(height: spacing.sm),
        Text(
          size.name,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          '${size.value.toInt()}px',
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
            fontFamily: 'monospace',
            fontSize: 10,
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
      children: [
        const _SectionLabel(label: 'REAL-WORLD EXAMPLES'),
        Column(
          spacing: spacing.sm,
          children: const [
            _ExampleCard(
              title: 'Delete Dialog',
              description: 'Destructive confirmation with visual hierarchy',
              child: _DeleteDialogExample(),
            ),
            _ExampleCard(
              title: 'Chat Composer',
              description: 'Icon actions alongside a text field',
              child: _ChatComposerExample(),
            ),
            _ExampleCard(
              title: 'Empty State',
              description: 'CTA with leading icon on a blank screen',
              child: _EmptyStateExample(),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeleteDialogExample extends StatelessWidget {
  const _DeleteDialogExample();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon badge
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.accentError.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.delete_outline,
            color: colorScheme.accentError,
            size: 24,
          ),
        ),
        SizedBox(height: spacing.md),
        Text(
          'Delete this conversation?',
          style: textTheme.headingXs.copyWith(
            color: colorScheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing.xs),
        Text(
          'This will permanently remove all messages and attachments. This action cannot be undone.',
          style: textTheme.captionDefault.copyWith(
            color: colorScheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing.lg),
        // Buttons — full width, stacked
        SizedBox(
          width: double.infinity,
          child: StreamButton(
            label: 'Delete Conversation',
            style: StreamButtonStyle.destructive,
            size: StreamButtonSize.large,
            iconLeft: Icons.delete_outline,
            onTap: () {},
          ),
        ),
        SizedBox(height: spacing.sm),
        SizedBox(
          width: double.infinity,
          child: StreamButton(
            label: 'Cancel',
            style: StreamButtonStyle.secondary,
            type: StreamButtonType.outline,
            size: StreamButtonSize.large,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ChatComposerExample extends StatelessWidget {
  const _ChatComposerExample();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderDefault),
      ),
      child: Row(
        children: [
          StreamButton.icon(
            icon: Icons.add_circle_outline,
            style: StreamButtonStyle.secondary,
            type: StreamButtonType.ghost,
            size: StreamButtonSize.small,
            onTap: () {},
          ),
          SizedBox(width: spacing.xs),
          Expanded(
            child: Text(
              'Type a message…',
              style: textTheme.bodyDefault.copyWith(
                color: colorScheme.textTertiary,
              ),
            ),
          ),
          SizedBox(width: spacing.xs),
          StreamButton.icon(
            icon: Icons.emoji_emotions_outlined,
            style: StreamButtonStyle.secondary,
            type: StreamButtonType.ghost,
            size: StreamButtonSize.small,
            onTap: () {},
          ),
          SizedBox(width: spacing.xxs),
          StreamButton.icon(
            icon: Icons.send,
            size: StreamButtonSize.small,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _EmptyStateExample extends StatelessWidget {
  const _EmptyStateExample();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: colorScheme.textTertiary,
          ),
          SizedBox(height: spacing.md),
          Text(
            'No conversations yet',
            style: textTheme.headingSm.copyWith(
              color: colorScheme.textPrimary,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Start a new conversation to begin chatting.',
            style: textTheme.captionDefault.copyWith(
              color: colorScheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.lg),
          StreamButton(
            label: 'New Conversation',
            iconLeft: Icons.add,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

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
            padding: EdgeInsets.fromLTRB(
              spacing.md,
              spacing.sm,
              spacing.md,
              spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.captionEmphasis.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
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
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
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
