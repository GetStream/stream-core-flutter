import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageMetadata,
  path: '[Components]/Message',
)
Widget buildStreamMessageMetadataPlayground(BuildContext context) {
  final timestamp = context.knobs.string(
    label: 'Timestamp',
    initialValue: '09:41',
    description: 'The timestamp text displayed in the metadata row.',
  );

  final showStatus = context.knobs.boolean(
    label: 'Show Status',
    initialValue: true,
    description: 'Whether to show a delivery status icon.',
  );

  final statusOption = context.knobs.object.dropdown<_StatusOption>(
    label: 'Status',
    options: _StatusOption.values,
    initialOption: _StatusOption.delivered,
    labelBuilder: (option) => option.label,
    description: 'The delivery status to display.',
  );

  final showUsername = context.knobs.boolean(
    label: 'Show Username',
    initialValue: true,
    description: 'Whether to show the sender username.',
  );

  final username = context.knobs.string(
    label: 'Username',
    initialValue: 'Alice',
    description: 'The username text.',
  );

  final showEdited = context.knobs.boolean(
    label: 'Show Edited',
    initialValue: true,
    description: 'Whether to show the edited indicator.',
  );

  final editedText = context.knobs.string(
    label: 'Edited Text',
    initialValue: 'Edited',
    description: 'The edited indicator text.',
  );

  final spacing = context.knobs.double.slider(
    label: 'Spacing',
    initialValue: 8,
    max: 24,
    divisions: 24,
    description: 'Gap between main elements. Overrides theme when set.',
  );

  final minHeight = context.knobs.double.slider(
    label: 'Min Height',
    initialValue: 24,
    min: 16,
    max: 48,
    divisions: 32,
    description: 'Minimum height of the metadata row.',
  );

  final accentPrimary = context.streamColorScheme.accentPrimary;

  Widget child = StreamMessageMetadata(
    timestamp: Text(timestamp),
    status: showStatus ? Icon(statusOption.iconData) : null,
    username: showUsername ? Text(username) : null,
    edited: showEdited ? Text(editedText) : null,
    style: StreamMessageMetadataStyle.from(
      spacing: spacing,
      minHeight: minHeight,
    ),
  );

  if (showStatus && statusOption == _StatusOption.read) {
    child = StreamMessageItemTheme(
      data: StreamMessageItemThemeData(
        metadata: StreamMessageMetadataStyle.from(statusColor: accentPrimary),
      ),
      child: child,
    );
  }

  return Center(child: child);
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMessageMetadata,
  path: '[Components]/Message',
)
Widget buildStreamMessageMetadataShowcase(BuildContext context) {
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
          _DeliveryStatusSection(),
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
    return _Section(
      label: 'SLOT COMBINATIONS',
      description: 'Each slot can be shown or hidden independently.',
      children: [
        _ExampleCard(
          label: 'Timestamp only',
          child: StreamMessageMetadata(timestamp: const Text('09:41')),
        ),
        _ExampleCard(
          label: 'Timestamp + username',
          child: StreamMessageMetadata(
            timestamp: const Text('09:41'),
            username: const Text('Alice'),
          ),
        ),
        _ExampleCard(
          label: 'Timestamp + status',
          child: StreamMessageMetadata(
            timestamp: const Text('09:41'),
            status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
          ),
        ),
        _ExampleCard(
          label: 'Timestamp + edited',
          child: StreamMessageMetadata(
            timestamp: const Text('09:41'),
            edited: const Text('Edited'),
          ),
        ),
        _ExampleCard(
          label: 'All slots',
          child: StreamMessageMetadata(
            timestamp: const Text('09:41'),
            status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
            username: const Text('Alice'),
            edited: const Text('Edited'),
          ),
        ),
      ],
    );
  }
}

class _DeliveryStatusSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accentPrimary = context.streamColorScheme.accentPrimary;

    return _Section(
      label: 'DELIVERY STATUS',
      description: 'Status progresses from sending → sent → delivered → read.',
      children: [
        _ExampleCard(
          label: 'Sending',
          subtitle: 'Clock icon while message is in transit.',
          child: StreamMessageMetadata(
            timestamp: const Text('09:41'),
            status: const Icon(StreamIconData.iconClock),
          ),
        ),
        _ExampleCard(
          label: 'Sent',
          subtitle: 'Single checkmark after server acknowledgement.',
          child: StreamMessageMetadata(
            timestamp: const Text('09:41'),
            status: const Icon(StreamIconData.iconCheckmark1Small),
          ),
        ),
        _ExampleCard(
          label: 'Delivered',
          subtitle: 'Double checkmark when received by recipient.',
          child: StreamMessageMetadata(
            timestamp: const Text('09:41'),
            status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
          ),
        ),
        _ExampleCard(
          label: 'Read',
          subtitle: 'Accent-colored double checkmark when read.',
          child: StreamMessageItemTheme(
            data: StreamMessageItemThemeData(
              metadata: StreamMessageMetadataStyle.from(statusColor: accentPrimary),
            ),
            child: StreamMessageMetadata(
              timestamp: const Text('09:41'),
              status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
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
    final colorScheme = context.streamColorScheme;

    return _Section(
      label: 'REAL-WORLD EXAMPLES',
      description: 'Metadata shown beneath message bubbles.',
      children: [
        _ExampleCard(
          label: 'Incoming message',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              StreamMessageBubble(
                child: StreamMessageText('Has anyone tried the new Flutter update?'),
              ),
              StreamMessageMetadata(
                timestamp: const Text('09:41'),
                username: const Text('Bob'),
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Incoming message (edited)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              StreamMessageBubble(
                child: StreamMessageText('I think the new APIs are much better now'),
              ),
              StreamMessageMetadata(
                timestamp: const Text('09:38'),
                username: const Text('Charlie'),
                edited: const Text('Edited'),
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Outgoing message (sending)',
          child: StreamMessagePlacement(
            data: const StreamMessagePlacementData(
              alignment: StreamMessageAlignment.end,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  StreamMessageBubble(
                    child: StreamMessageText('Let me check that real quick'),
                  ),
                  StreamMessageMetadata(
                    timestamp: const Text('09:42'),
                    status: const Icon(StreamIconData.iconClock),
                  ),
                ],
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Outgoing message (read)',
          child: StreamMessagePlacement(
            data: const StreamMessagePlacementData(
              alignment: StreamMessageAlignment.end,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  StreamMessageBubble(
                    child: StreamMessageText('Sure, I can help with that!'),
                  ),
                  StreamMessageItemTheme(
                    data: StreamMessageItemThemeData(
                      metadata: StreamMessageMetadataStyle.from(
                        statusColor: colorScheme.accentPrimary,
                      ),
                    ),
                    child: StreamMessageMetadata(
                      timestamp: const Text('09:40'),
                      status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Outgoing message (read + edited)',
          child: StreamMessagePlacement(
            data: const StreamMessagePlacementData(
              alignment: StreamMessageAlignment.end,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  StreamMessageBubble(
                    child: StreamMessageText('Actually, let me rephrase that'),
                  ),
                  StreamMessageItemTheme(
                    data: StreamMessageItemThemeData(
                      metadata: StreamMessageMetadataStyle.from(
                        statusColor: colorScheme.accentPrimary,
                      ),
                    ),
                    child: StreamMessageMetadata(
                      timestamp: const Text('09:40'),
                      status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
                      edited: const Text('Edited'),
                    ),
                  ),
                ],
              ),
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
    return _Section(
      label: 'THEME OVERRIDES',
      description: 'Per-instance overrides via StreamMessageItemTheme.',
      children: [
        _ExampleCard(
          label: 'Custom username color',
          child: StreamMessageItemTheme(
            data: StreamMessageItemThemeData(
              metadata: StreamMessageMetadataStyle.from(
                usernameColor: Colors.deepPurple,
              ),
            ),
            child: StreamMessageMetadata(
              timestamp: const Text('09:41'),
              username: const Text('Alice'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Custom spacing',
          subtitle: 'Wider gap (16) between elements.',
          child: StreamMessageMetadata(
            timestamp: const Text('09:41'),
            username: const Text('Alice'),
            status: const Icon(StreamIconData.iconCheckmark1Small),
            edited: const Text('Edited'),
            style: StreamMessageMetadataStyle.from(spacing: 16),
          ),
        ),
        _ExampleCard(
          label: 'Compact',
          subtitle: 'Tighter spacing (4) and smaller min height (20).',
          child: StreamMessageMetadata(
            timestamp: const Text('09:41'),
            username: const Text('Alice'),
            style: StreamMessageMetadataStyle.from(spacing: 4, minHeight: 20),
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

// =============================================================================
// Status Icon Options (for Playground knobs)
// =============================================================================

enum _StatusOption {
  sending('Sending', StreamIconData.iconClock),
  sent('Sent', StreamIconData.iconCheckmark1Small),
  delivered('Delivered', StreamIconData.iconDoupleCheckmark1Small),
  read('Read', StreamIconData.iconDoupleCheckmark1Small)
  ;

  const _StatusOption(this.label, this.iconData);

  final String label;
  final IconData iconData;
}
