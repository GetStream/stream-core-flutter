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

  final alignment = context.knobs.object.dropdown<StreamMessageAlignment>(
    label: 'Alignment',
    options: StreamMessageAlignment.values,
    labelBuilder: (v) => v.name,
    description: 'Start (incoming) or end (outgoing).',
  );

  final stackPosition = context.knobs.object.dropdown<StreamMessageStackPosition>(
    label: 'Stack Position',
    options: StreamMessageStackPosition.values,
    labelBuilder: (v) => v.name,
    description: 'Position within a consecutive message group.',
  );

  final layout = StreamMessageLayoutData(
    alignment: alignment,
    stackPosition: stackPosition,
  );

  return Center(
    child: StreamMessageLayout(
      data: layout,
      child: StreamMessageBubble(
        child: StreamMessageText(text),
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
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        _AlignmentSection(),
        _StackPositionsSection(),
        _ConversationSection(),
        _StyleOverrideSection(),
      ],
    ),
  );
}

// =============================================================================
// Showcase Sections
// =============================================================================

class _AlignmentSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'ALIGNMENT',
      description:
          'Bubbles resolve background, border, and shape from the '
          'placement alignment (start = incoming, end = outgoing).',
      children: [
        _ExampleCard(
          label: 'Start (incoming)',
          child: _PlacedBubble(
            alignment: StreamMessageAlignment.start,
            crossAlign: CrossAxisAlignment.start,
            text: 'Has anyone tried the new Flutter update?',
          ),
        ),
        _ExampleCard(
          label: 'End (outgoing)',
          child: _PlacedBubble(
            alignment: StreamMessageAlignment.end,
            crossAlign: CrossAxisAlignment.end,
            text: 'Sure, I can help with that!',
          ),
        ),
      ],
    );
  }
}

class _StackPositionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'STACK POSITIONS',
      description:
          'Corner radii change based on position within a '
          'consecutive message stack.',
      children: [
        _ExampleCard(
          label: 'Single (standalone)',
          child: _PlacedBubble(
            alignment: StreamMessageAlignment.start,
            crossAlign: CrossAxisAlignment.start,
            text: 'A standalone message',
          ),
        ),
        _ExampleCard(
          label: 'Incoming stack (top → middle → bottom)',
          child: Column(
            spacing: 2,
            children: [
              _PlacedBubble(
                alignment: StreamMessageAlignment.start,
                stackPosition: StreamMessageStackPosition.top,
                crossAlign: CrossAxisAlignment.start,
                text: 'First message in group',
              ),
              _PlacedBubble(
                alignment: StreamMessageAlignment.start,
                stackPosition: StreamMessageStackPosition.middle,
                crossAlign: CrossAxisAlignment.start,
                text: 'Middle message',
              ),
              _PlacedBubble(
                alignment: StreamMessageAlignment.start,
                stackPosition: StreamMessageStackPosition.bottom,
                crossAlign: CrossAxisAlignment.start,
                text: 'Last message in group',
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Outgoing stack (top → middle → bottom)',
          child: Column(
            spacing: 2,
            children: [
              _PlacedBubble(
                alignment: StreamMessageAlignment.end,
                stackPosition: StreamMessageStackPosition.top,
                crossAlign: CrossAxisAlignment.end,
                text: 'First outgoing message',
              ),
              _PlacedBubble(
                alignment: StreamMessageAlignment.end,
                stackPosition: StreamMessageStackPosition.middle,
                crossAlign: CrossAxisAlignment.end,
                text: 'Middle outgoing',
              ),
              _PlacedBubble(
                alignment: StreamMessageAlignment.end,
                stackPosition: StreamMessageStackPosition.bottom,
                crossAlign: CrossAxisAlignment.end,
                text: 'Last outgoing message',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConversationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'CONVERSATION',
      description: 'A realistic exchange showing how alignment and stack position combine.',
      children: [
        _ExampleCard(
          label: 'Mixed thread',
          child: Column(
            spacing: 2,
            children: [
              _PlacedBubble(
                alignment: StreamMessageAlignment.start,
                stackPosition: StreamMessageStackPosition.top,
                crossAlign: CrossAxisAlignment.start,
                text: 'Hey, are you free this weekend?',
              ),
              _PlacedBubble(
                alignment: StreamMessageAlignment.start,
                stackPosition: StreamMessageStackPosition.bottom,
                crossAlign: CrossAxisAlignment.start,
                text: 'We could go hiking 🏔️',
              ),
              SizedBox(height: 8),
              _PlacedBubble(
                alignment: StreamMessageAlignment.end,
                crossAlign: CrossAxisAlignment.end,
                text: 'Sounds great! Let me check my schedule.',
              ),
              SizedBox(height: 8),
              _PlacedBubble(
                alignment: StreamMessageAlignment.start,
                crossAlign: CrossAxisAlignment.start,
                text: 'Perfect, let me know! 👍',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StyleOverrideSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'STYLE OVERRIDE',
      description:
          'Pass a custom StreamMessageBubbleStyle to override '
          'individual properties while still using placement scope.',
      children: [
        _ExampleCard(
          label: 'Stadium shape with large padding',
          child: StreamMessageBubble(
            style: StreamMessageBubbleStyle.from(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            ),
            child: StreamMessageText('Custom shape!'),
          ),
        ),
        _ExampleCard(
          label: 'Beveled rectangle',
          child: StreamMessageLayout(
            data: const StreamMessageLayoutData(
              alignment: StreamMessageAlignment.end,
            ),
            child: StreamMessageBubble(
              style: StreamMessageBubbleStyle.from(
                shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                padding: const EdgeInsets.all(16),
              ),
              child: StreamMessageText('Beveled corners'),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

class _PlacedBubble extends StatelessWidget {
  const _PlacedBubble({
    required this.alignment,
    this.stackPosition = StreamMessageStackPosition.single,
    required this.crossAlign,
    required this.text,
  });

  final StreamMessageAlignment alignment;
  final StreamMessageStackPosition stackPosition;
  final CrossAxisAlignment crossAlign;
  final String text;

  @override
  Widget build(BuildContext context) {
    final layout = StreamMessageLayoutData(
      alignment: alignment,
      stackPosition: stackPosition,
    );
    final isDefault = layout == const StreamMessageLayoutData();

    Widget child = StreamMessageBubble(child: StreamMessageText(text));
    if (!isDefault) {
      child = StreamMessageLayout(data: layout, child: child);
    }

    return Align(
      alignment: crossAlign == CrossAxisAlignment.end
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: child,
    );
  }
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
  });

  final String label;
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
          Text(
            label,
            style: textTheme.metadataEmphasis.copyWith(
              color: colorScheme.textSecondary,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
