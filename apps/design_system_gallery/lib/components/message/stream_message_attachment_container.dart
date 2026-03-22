import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageAttachmentContainer,
  path: '[Components]/Message',
)
Widget buildStreamMessageAttachmentContainerPlayground(BuildContext context) {
  final text = context.knobs.string(
    label: 'Text',
    initialValue: 'Check out this photo!',
    description: 'Caption text below the attachment.',
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

  final showBubble = context.knobs.boolean(
    label: 'Wrap in bubble',
    initialValue: true,
    description: 'Toggle the surrounding bubble to see the container in isolation.',
  );

  final placement = StreamMessagePlacementData(
    alignment: alignment,
    stackPosition: stackPosition,
  );

  return Center(
    child: StreamMessagePlacement(
      data: placement,
      child: showBubble
          ? _MessageWithAttachment(text: text)
          : const StreamMessageAttachmentContainer(
              child: _PlaceholderAttachment(),
            ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMessageAttachmentContainer,
  path: '[Components]/Message',
)
Widget buildStreamMessageAttachmentContainerShowcase(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        _BubbleContrastSection(),
        _ConversationSection(),
        _StyleOverrideSection(),
      ],
    ),
  );
}

// =============================================================================
// Showcase Sections
// =============================================================================

class _BubbleContrastSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'BUBBLE VS ATTACHMENT',
      description:
          'The attachment container uses a distinct background from the '
          'surrounding bubble, making embedded content stand out.',
      children: [
        _ExampleCard(
          label: 'Incoming',
          child: _PlacedMessage(
            alignment: StreamMessageAlignment.start,
            crossAlign: CrossAxisAlignment.start,
            text: 'Look what I found!',
          ),
        ),
        _ExampleCard(
          label: 'Outgoing',
          child: _PlacedMessage(
            alignment: StreamMessageAlignment.end,
            crossAlign: CrossAxisAlignment.end,
            text: 'Sharing a photo 📸',
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
      description:
          'A realistic exchange showing how attachment containers '
          'look across different placements in a message thread.',
      children: [
        _ExampleCard(
          label: 'Mixed thread',
          child: Column(
            spacing: 2,
            children: [
              _PlacedMessage(
                alignment: StreamMessageAlignment.start,
                stackPosition: StreamMessageStackPosition.top,
                crossAlign: CrossAxisAlignment.start,
                text: 'Hey, check out this sunset!',
              ),
              _PlacedMessage(
                alignment: StreamMessageAlignment.start,
                stackPosition: StreamMessageStackPosition.bottom,
                crossAlign: CrossAxisAlignment.start,
                text: 'Took it yesterday evening 🌅',
              ),
              SizedBox(height: 8),
              _PlacedMessage(
                alignment: StreamMessageAlignment.end,
                crossAlign: CrossAxisAlignment.end,
                text: 'Wow, that looks amazing!',
              ),
              SizedBox(height: 8),
              _PlacedMessage(
                alignment: StreamMessageAlignment.start,
                crossAlign: CrossAxisAlignment.start,
                text: 'Thanks! Here is another one',
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
      description: 'Custom attachment styles nested inside a bubble.',
      children: [
        _ExampleCard(
          label: 'Stadium shape',
          child: _StyledMessage(
            style: StreamMessageAttachmentStyle.from(
              shape: const StadiumBorder(),
            ),
            text: 'Rounded attachment',
          ),
        ),
        _ExampleCard(
          label: 'With border',
          child: _StyledMessage(
            alignment: StreamMessageAlignment.end,
            style: StreamMessageAttachmentStyle.from(
              side: const BorderSide(width: 2, color: Colors.deepPurple),
              shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            text: 'Beveled with border',
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

class _MessageWithAttachment extends StatelessWidget {
  const _MessageWithAttachment({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return StreamMessageBubble(
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: .symmetric(horizontal: 8),
            child: StreamMessageAttachmentContainer(
              child: _PlaceholderAttachment(),
            ),
          ),
          SizedBox(height: spacing.xxs),
          StreamMessageText(text),
        ],
      ),
    );
  }
}

class _PlaceholderAttachment extends StatelessWidget {
  const _PlaceholderAttachment();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    return SizedBox(
      height: 120,
      width: 240,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: colorScheme.textTertiary,
        ),
      ),
    );
  }
}

class _StyledMessage extends StatelessWidget {
  const _StyledMessage({
    this.alignment = StreamMessageAlignment.start,
    required this.style,
    required this.text,
  });

  final StreamMessageAlignment alignment;
  final StreamMessageAttachmentStyle style;
  final String text;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final isEnd = alignment == StreamMessageAlignment.end;

    return Align(
      alignment: isEnd ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: StreamMessagePlacement(
        data: StreamMessagePlacementData(alignment: alignment),
        child: StreamMessageBubble(
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const .symmetric(horizontal: 8),
                child: StreamMessageAttachmentContainer(
                  style: style,
                  child: const _PlaceholderAttachment(),
                ),
              ),
              SizedBox(height: spacing.xxs),
              StreamMessageText(text),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlacedMessage extends StatelessWidget {
  const _PlacedMessage({
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
    final placement = StreamMessagePlacementData(
      alignment: alignment,
      stackPosition: stackPosition,
    );
    final isDefault = placement == const StreamMessagePlacementData();

    Widget child = _MessageWithAttachment(text: text);
    if (!isDefault) {
      child = StreamMessagePlacement(data: placement, child: child);
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
  });

  final String label;
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
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.textSecondary,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
