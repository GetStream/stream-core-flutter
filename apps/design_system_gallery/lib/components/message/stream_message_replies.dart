import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageReplies,
  path: '[Components]/Message',
)
Widget buildStreamMessageRepliesPlayground(BuildContext context) {
  final showLabel = context.knobs.boolean(
    label: 'Show Label',
    initialValue: true,
    description: 'Whether to show the reply count label.',
  );

  final labelText = context.knobs.string(
    label: 'Label Text',
    initialValue: '3 replies',
    description: 'The reply count text.',
  );

  final avatarCount = context.knobs.double.slider(
    label: 'Avatar Count',
    initialValue: 3,
    max: 6,
    divisions: 6,
    description: 'Number of participant avatars.',
  );

  final maxAvatars = context.knobs.double.slider(
    label: 'Max Avatars',
    initialValue: 3,
    min: 2,
    max: 5,
    divisions: 3,
    description: 'Max visible avatars before +N overflow badge.',
  );

  final avatarSize = context.knobs.object.dropdown<StreamAvatarStackSize>(
    label: 'Avatar Size',
    options: StreamAvatarStackSize.values,
    initialOption: StreamAvatarStackSize.sm,
    labelBuilder: (v) => v.name,
    description: 'Size of each avatar in the stack.',
  );

  final showConnector = context.knobs.boolean(
    label: 'Show Connector',
    initialValue: true,
    description: 'Whether to show the connector widget.',
  );

  final alignment = context.knobs.object.dropdown<StreamMessageAlignment>(
    label: 'Alignment',
    options: StreamMessageAlignment.values,
    initialOption: StreamMessageAlignment.start,
    labelBuilder: (v) => v.name,
    description: 'Semantic element order in the row.',
  );

  final spacing = context.knobs.double.slider(
    label: 'Spacing',
    initialValue: 8,
    max: 24,
    divisions: 24,
    description: 'Gap between elements. Overrides theme when set.',
  );

  final verticalPadding = context.knobs.double.slider(
    label: 'Vertical Padding',
    initialValue: 4,
    max: 24,
    divisions: 24,
    description: 'Vertical padding around the row content.',
  );

  final clipBehavior = context.knobs.object.dropdown<Clip>(
    label: 'Clip Behavior',
    options: Clip.values,
    initialOption: Clip.none,
    labelBuilder: (v) => v.name,
    description: 'How to clip overflow (e.g. connector).',
  );

  final palette = context.streamColorScheme.avatarPalette;

  return Center(
    child: StreamMessageReplies(
      label: showLabel ? Text(labelText) : null,
      avatars: _sampleAvatars(avatarCount.toInt(), palette),
      avatarSize: avatarSize,
      maxAvatars: maxAvatars.toInt(),
      showConnector: showConnector,
      alignment: alignment,
      spacing: spacing,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      clipBehavior: clipBehavior,
      onTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Tapped'),
              duration: Duration(seconds: 1),
            ),
          );
      },
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMessageReplies,
  path: '[Components]/Message',
)
Widget buildStreamMessageRepliesShowcase(BuildContext context) {
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
          _SlotCombinationsSection(),
          _AlignmentSection(),
          _ConnectorOverflowSection(),
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

class _SlotCombinationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.streamColorScheme.avatarPalette;

    return _Section(
      label: 'SLOT COMBINATIONS',
      description: 'Each slot can be shown or hidden independently.',
      children: [
        _ExampleCard(
          label: 'Label only',
          child: StreamMessageReplies(label: const Text('3 replies')),
        ),
        _ExampleCard(
          label: 'Avatars only',
          child: StreamMessageReplies(avatars: _sampleAvatars(2, palette)),
        ),
        _ExampleCard(
          label: 'Label + avatars',
          child: StreamMessageReplies(
            label: const Text('3 replies'),
            avatars: _sampleAvatars(3, palette),
          ),
        ),
        _ExampleCard(
          label: 'With connector',
          childPadding: _kConnectorOverflowPadding,
          child: StreamMessageReplies(
            label: const Text('5 replies'),
            avatars: _sampleAvatars(2, palette),
          ),
        ),
        _ExampleCard(
          label: 'All slots with overflow',
          subtitle: '5 avatars, max 2 — shows +3 badge.',
          childPadding: _kConnectorOverflowPadding,
          child: StreamMessageReplies(
            label: const Text('8 replies'),
            avatars: _sampleAvatars(5, palette),
            maxAvatars: 2,
          ),
        ),
      ],
    );
  }
}

class _AlignmentSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.streamColorScheme.avatarPalette;

    return _Section(
      label: 'ALIGNMENT',
      description:
          'Controls element order. Start = [connector, avatars, label]; End = [label, avatars, connector].',
      children: [
        _ExampleCard(
          label: 'Start alignment (default)',
          subtitle: 'Connector → avatars → label.',
          childPadding: _kConnectorOverflowPadding,
          child: StreamMessageReplies(
            label: const Text('3 replies'),
            avatars: _sampleAvatars(2, palette),
          ),
        ),
        _ExampleCard(
          label: 'End alignment',
          subtitle: 'Label → avatars → connector.',
          childPadding: _kConnectorOverflowPadding,
          child: StreamMessageReplies(
            label: const Text('3 replies'),
            avatars: _sampleAvatars(2, palette),
            alignment: StreamMessageAlignment.end,
          ),
        ),
      ],
    );
  }
}

class _ConnectorOverflowSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.streamColorScheme.avatarPalette;
    final colorScheme = context.streamColorScheme;

    return _Section(
      label: 'CONNECTOR OVERFLOW',
      description:
          'The connector extends above the row bounds. clipBehavior controls whether it is clipped.',
      children: [
        _ExampleCard(
          label: 'Clip.none (default)',
          subtitle: 'Connector paints outside the component bounds.',
          childPadding: _kConnectorOverflowPadding,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.borderSubtle, width: 0.5),
            ),
            child: StreamMessageReplies(
              label: const Text('3 replies'),
              avatars: _sampleAvatars(2, palette),
              onTap: () {},
            ),
          ),
        ),
        _ExampleCard(
          label: 'Clip.hardEdge',
          subtitle: 'Connector overflow is clipped to the row bounds.',
          childPadding: _kConnectorOverflowPadding,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.borderSubtle, width: 0.5),
            ),
            child: StreamMessageReplies(
              label: const Text('3 replies'),
              avatars: _sampleAvatars(2, palette),
              clipBehavior: Clip.hardEdge,
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class _RealWorldSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.streamColorScheme.avatarPalette;
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;

    return _Section(
      label: 'REAL-WORLD EXAMPLES',
      description: 'Message bubbles with threaded replies beneath.',
      children: [
        _ExampleCard(
          label: 'Incoming message with replies',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamMessageBubble(
                backgroundColor: colorScheme.backgroundSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: radius.lg,
                    topRight: radius.lg,
                    bottomRight: radius.lg,
                    bottomLeft: radius.xs,
                  ),
                ),
                side: BorderSide(color: colorScheme.borderSubtle),
                child: Text(
                  'Has anyone tried the new Flutter update?',
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.textPrimary,
                  ),
                ),
              ),
              StreamMessageRepliesTheme(
                data: StreamMessageRepliesThemeData(
                  connectorColor: colorScheme.backgroundSurface,
                ),
                child: StreamMessageReplies(
                  label: const Text('3 replies'),
                  avatars: _sampleAvatars(2, palette),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Outgoing message with replies',
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StreamMessageBubble(
                  backgroundColor: colorScheme.accentPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: radius.lg,
                      topRight: radius.lg,
                      bottomLeft: radius.lg,
                      bottomRight: radius.xs,
                    ),
                  ),
                  side: BorderSide.none,
                  child: const Text(
                    'Sure, I can help with that!',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
                StreamMessageRepliesTheme(
                  data: StreamMessageRepliesThemeData(
                    connectorColor: colorScheme.accentPrimary,
                  ),
                  child: StreamMessageReplies(
                    label: const Text('5 replies'),
                    avatars: _sampleAvatars(3, palette),
                    alignment: StreamMessageAlignment.end,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
        _ExampleCard(
          label: 'Single reply, no connector',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamMessageBubble(
                backgroundColor: colorScheme.backgroundSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: radius.lg,
                    topRight: radius.lg,
                    bottomRight: radius.lg,
                    bottomLeft: radius.xs,
                  ),
                ),
                side: BorderSide(color: colorScheme.borderSubtle),
                child: Text(
                  'Let me check that.',
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.textPrimary,
                  ),
                ),
              ),
              StreamMessageReplies(
                label: const Text('1 reply'),
                avatars: _sampleAvatars(1, palette),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeOverrideSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.streamColorScheme.avatarPalette;

    return _Section(
      label: 'THEME OVERRIDES',
      description: 'Per-instance overrides via StreamMessageRepliesTheme.',
      children: [
        _ExampleCard(
          label: 'Custom label color',
          child: StreamMessageRepliesTheme(
            data: const StreamMessageRepliesThemeData(
              labelColor: Colors.deepPurple,
            ),
            child: StreamMessageReplies(
              label: const Text('3 replies'),
              avatars: _sampleAvatars(2, palette),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Custom connector',
          subtitle: 'Red connector with 3px stroke.',
          childPadding: _kConnectorOverflowPadding,
          child: StreamMessageRepliesTheme(
            data: const StreamMessageRepliesThemeData(
              connectorColor: Colors.red,
              connectorStrokeWidth: 3,
            ),
            child: StreamMessageReplies(
              label: const Text('3 replies'),
              avatars: _sampleAvatars(2, palette),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Custom spacing',
          subtitle: 'Wider gap (16) between elements.',
          childPadding: _kConnectorOverflowPadding,
          child: StreamMessageReplies(
            label: const Text('3 replies'),
            avatars: _sampleAvatars(2, palette),
            spacing: 16,
          ),
        ),
        _ExampleCard(
          label: 'Compact',
          subtitle: 'Tighter spacing (4) and no padding.',
          child: StreamMessageReplies(
            label: const Text('3 replies'),
            avatars: _sampleAvatars(2, palette),
            spacing: 4,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Helper Widgets & Data
// =============================================================================

const _kConnectorOverflowPadding = EdgeInsets.only(top: 24);

const _sampleImages = [
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
  'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200',
];

const _sampleInitials = ['AB', 'CD', 'EF', 'GH', 'IJ'];

List<Widget> _sampleAvatars(int count, List<StreamAvatarColorPair> palette) {
  return [
    for (var i = 0; i < count; i++)
      StreamAvatar(
        imageUrl: _sampleImages[i % _sampleImages.length],
        backgroundColor: palette[i % palette.length].backgroundColor,
        foregroundColor: palette[i % palette.length].foregroundColor,
        placeholder: (context) => Text(_sampleInitials[i % _sampleInitials.length]),
      ),
  ];
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
    this.subtitle,
    this.childPadding,
  });

  final String label;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? childPadding;

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
          if (childPadding case final padding?)
            Padding(padding: padding, child: child)
          else
            child,
        ],
      ),
    );
  }
}
