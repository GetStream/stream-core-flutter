import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageBubble,
  path: '[Components]/Message',
)
Widget buildStreamMessageBubblePlayground(BuildContext context) {
  final text = context.knobs.string(
    label: 'Text',
    initialValue: 'Hello, world!',
    description: 'The text content inside the bubble.',
  );

  final borderRadius = context.knobs.double.slider(
    label: 'Border Radius',
    initialValue: 24,
    max: 32,
    divisions: 32,
    description: 'Corner radius of the bubble shape.',
  );

  final horizontalPadding = context.knobs.double.slider(
    label: 'Horizontal Padding',
    initialValue: 12,
    max: 32,
    divisions: 32,
    description: 'Horizontal content padding inside the bubble.',
  );

  final verticalPadding = context.knobs.double.slider(
    label: 'Vertical Padding',
    initialValue: 8,
    max: 32,
    divisions: 32,
    description: 'Vertical content padding inside the bubble.',
  );

  final showBorder = context.knobs.boolean(
    label: 'Show Border',
    initialValue: true,
    description: 'Whether to show a border on the bubble.',
  );

  final useOutgoingColor = context.knobs.boolean(
    label: 'Outgoing Style',
    description: 'Use outgoing (brand) colors instead of incoming.',
  );

  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;

  final backgroundColor = useOutgoingColor
      ? colorScheme.brand.shade100
      : colorScheme.backgroundSurface;

  final borderColor = useOutgoingColor
      ? colorScheme.brand.shade100
      : colorScheme.borderSubtle;

  final textColor = useOutgoingColor
      ? colorScheme.brand.shade900
      : colorScheme.textPrimary;

  return Center(
    child: StreamMessageBubble(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      side: showBorder
          ? BorderSide(color: borderColor)
          : BorderSide.none,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      backgroundColor: backgroundColor,
      child: Text(
        text,
        style: textTheme.bodyDefault.copyWith(color: textColor),
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMessageBubble,
  path: '[Components]/Message',
)
Widget buildStreamMessageBubbleShowcase(BuildContext context) {
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
          _IncomingOutgoingSection(),
          _GroupPositionsSection(),
          _RealWorldSection(),
          _ThemeOverrideSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Showcase Sections
// =============================================================================

class _IncomingOutgoingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;

    return _Section(
      label: 'INCOMING VS OUTGOING',
      description: 'Bubbles use different background and border colors based '
          'on message direction.',
      children: [
        _ExampleCard(
          label: 'Incoming message',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: StreamMessageBubble(
              backgroundColor: colorScheme.backgroundSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(radius.xxl),
              ),
              side: BorderSide(color: colorScheme.borderSubtle),
              child: const Text('Has anyone tried the new Flutter update?'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Outgoing message',
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: StreamMessageBubble(
              backgroundColor: colorScheme.brand.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(radius.xxl),
              ),
              side: BorderSide.none,
              child: Text(
                'Sure, I can help with that!',
                style: TextStyle(color: colorScheme.brand.shade900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupPositionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;

    const tailRadius = Radius.circular(4);

    return _Section(
      label: 'GROUP POSITIONS',
      description: 'Corner radii change based on position within a '
          'consecutive message group.',
      children: [
        _ExampleCard(
          label: 'Single (standalone)',
          subtitle: 'All corners rounded',
          child: StreamMessageBubble(
            backgroundColor: colorScheme.backgroundSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(radius.xxl),
            ),
            side: BorderSide(color: colorScheme.borderSubtle),
            child: const Text('A standalone message'),
          ),
        ),
        _ExampleCard(
          label: 'Grouped messages (top → middle → bottom)',
          subtitle: 'Inner corners tighten on the sender side',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              StreamMessageBubble(
                backgroundColor: colorScheme.backgroundSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: radius.xxl,
                    topRight: radius.xxl,
                    bottomLeft: tailRadius,
                    bottomRight: radius.xxl,
                  ),
                ),
                side: BorderSide(color: colorScheme.borderSubtle),
                child: const Text('First message in group'),
              ),
              StreamMessageBubble(
                backgroundColor: colorScheme.backgroundSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: tailRadius,
                    topRight: radius.xxl,
                    bottomLeft: tailRadius,
                    bottomRight: radius.xxl,
                  ),
                ),
                side: BorderSide(color: colorScheme.borderSubtle),
                child: const Text('Middle message'),
              ),
              StreamMessageBubble(
                backgroundColor: colorScheme.backgroundSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: tailRadius,
                    topRight: radius.xxl,
                    bottomLeft: radius.xxl,
                    bottomRight: radius.xxl,
                  ),
                ),
                side: BorderSide(color: colorScheme.borderSubtle),
                child: const Text('Last message in group'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RealWorldSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;

    return _Section(
      label: 'REAL-WORLD EXAMPLES',
      description: 'Bubbles composed with metadata and reactions.',
      children: [
        _ExampleCard(
          label: 'Incoming with metadata',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              StreamMessageBubble(
                backgroundColor: colorScheme.backgroundSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(radius.xxl),
                ),
                side: BorderSide(color: colorScheme.borderSubtle),
                child: const Text('Has anyone tried the new Flutter update?'),
              ),
              StreamMessageMetadata(
                timestamp: const Text('09:41'),
                username: const Text('Alice'),
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Outgoing with status',
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 4,
              children: [
                StreamMessageBubble(
                  backgroundColor: colorScheme.brand.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(radius.xxl),
                  ),
                  side: BorderSide.none,
                  child: Text(
                    'Sure, I can help with that!',
                    style: TextStyle(color: colorScheme.brand.shade900),
                  ),
                ),
                StreamMessageMetadata(
                  timestamp: const Text('09:42'),
                  status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
                ),
              ],
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
    final colorScheme = context.streamColorScheme;

    return _Section(
      label: 'STYLE OVERRIDE',
      description: 'Pass a custom StreamMessageBubbleStyle to override '
          'individual properties.',
      children: [
        _ExampleCard(
          label: 'Stadium shape with large padding',
          child: StreamMessageBubble(
            backgroundColor: colorScheme.backgroundSurface,
            shape: const StadiumBorder(),
            side: const BorderSide(color: Colors.deepPurple, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: const Text('Custom shape!'),
          ),
        ),
        _ExampleCard(
          label: 'Beveled rectangle',
          child: StreamMessageBubble(
            backgroundColor: colorScheme.backgroundSurface,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            side: const BorderSide(color: Colors.teal),
            padding: const EdgeInsets.all(16),
            child: const Text('Beveled corners'),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

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
                style: TextStyle(
                  fontSize: 13,
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
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
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
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.textSecondary,
                ),
              ),
              if (subtitle case final sub?)
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12,
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
