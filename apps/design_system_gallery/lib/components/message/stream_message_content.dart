import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageContent,
  path: '[Components]/Message',
)
Widget buildStreamMessageContentPlayground(BuildContext context) {
  final text = context.knobs.string(
    label: 'Message Text',
    initialValue:
        'Has anyone tried the new Flutter update? '
        'The performance improvements are amazing!',
  );

  final showHeader = context.knobs.boolean(
    label: 'Show Header',
    description: 'Toggle the reminder annotation header.',
  );

  final showReplies = context.knobs.boolean(
    label: 'Show Replies',
    description: 'Toggle the reply indicator with avatars.',
  );

  final showReactions = context.knobs.boolean(
    label: 'Show Reactions',
    description: 'Wrap the bubble and replies with reactions.',
  );

  final reactionType = showReactions
      ? context.knobs.object.dropdown<StreamReactionsType>(
          label: 'Reaction Type',
          options: StreamReactionsType.values,
          initialOption: StreamReactionsType.segmented,
          labelBuilder: (v) => v.name,
          description: 'Segmented shows individual chips, clustered groups them.',
        )
      : StreamReactionsType.segmented;

  final reactionCount = showReactions
      ? context.knobs.int.slider(
          label: 'Reaction Count',
          initialValue: 3,
          min: 1,
          max: _allReactions.length,
          description: 'Number of distinct reaction types to show.',
        )
      : 0;

  final reactionPosition = showReactions
      ? context.knobs.object.dropdown<StreamReactionsPosition>(
          label: 'Reaction Position',
          options: StreamReactionsPosition.values,
          initialOption: StreamReactionsPosition.header,
          labelBuilder: (v) => v.name,
          description: 'Where reactions sit relative to the bubble.',
        )
      : StreamReactionsPosition.footer;

  final reactionOverlap = reactionPosition == StreamReactionsPosition.header;

  final showFooter = context.knobs.boolean(
    label: 'Show Footer',
    initialValue: true,
    description: 'Toggle the metadata footer.',
  );

  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final palette = colorScheme.avatarPalette;

  final emojiCount = StreamMessageText.emojiOnlyCount(text);
  final isEmojiOnly = emojiCount != null && emojiCount <= 3;

  final messageText = StreamMessageText(text);
  final Widget messageWidget = isEmojiOnly ? messageText : StreamMessageBubble(child: messageText);

  final replies = showReplies
      ? StreamMessageReplies(
          label: const Text('3 replies'),
          avatars: _sampleAvatars(3, palette),
          showConnector: !isEmojiOnly,
        )
      : null;

  Widget body;
  if (showReactions) {
    final items = _allReactions.take(reactionCount).toList();

    Widget buildReactions({required Widget child}) => switch (reactionType) {
      StreamReactionsType.segmented => StreamReactions.segmented(
        items: items,
        position: reactionPosition,
        overlap: reactionOverlap,
        alignment: reactionOverlap ? .end : .start,
        indent: reactionOverlap ? 8 : null,
        onPressed: () {},
        child: child,
      ),
      StreamReactionsType.clustered => StreamReactions.clustered(
        items: items,
        position: reactionPosition,
        overlap: reactionOverlap,
        alignment: reactionOverlap ? .end : .start,
        indent: reactionOverlap ? 8 : null,
        onPressed: () {},
        child: child,
      ),
    };

    if (reactionOverlap) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildReactions(child: messageWidget),
          ?replies,
        ],
      );
    } else {
      body = buildReactions(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [messageWidget, ?replies],
        ),
      );
    }
  } else {
    body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [messageWidget, ?replies],
    );
  }

  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: StreamMessageContent(
        header: showHeader
            ? StreamMessageAnnotation(
                leading: const Icon(StreamIconData.iconBellNotification),
                label: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Reminder set'),
                      TextSpan(
                        text: ' · In 2 hours',
                        style: textTheme.metadataDefault,
                      ),
                    ],
                  ),
                ),
              )
            : null,
        footer: showFooter
            ? StreamMessageMetadata(
                timestamp: const Text('09:41'),
                username: const Text('Alice'),
                status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
                edited: const Text('Edited'),
              )
            : null,
        child: body,
      ),
    ),
  );
}

const _allReactions = <StreamReactionsItem>[
  StreamReactionsItem(emoji: Text('👍'), count: 8),
  StreamReactionsItem(emoji: Text('❤'), count: 14),
  StreamReactionsItem(emoji: Text('😂'), count: 5),
  StreamReactionsItem(emoji: Text('🔥'), count: 3),
  StreamReactionsItem(emoji: Text('🎉'), count: 2),
  StreamReactionsItem(emoji: Text('👏'), count: 7),
  StreamReactionsItem(emoji: Text('😮')),
  StreamReactionsItem(emoji: Text('🙏'), count: 4),
];

const _sampleImages = [
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
];

const _sampleInitials = ['AB', 'CD', 'EF'];

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

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMessageContent,
  path: '[Components]/Message',
)
Widget buildStreamMessageContentShowcase(BuildContext context) {
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
          _ReactionVariantsSection(),
          _FullCompositionSection(),
          _EmojiOnlySection(),
          _MinimalSection(),
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
    final textTheme = context.streamTextTheme;
    final palette = context.streamColorScheme.avatarPalette;

    return _Section(
      label: 'SLOT COMBINATIONS',
      description:
          'StreamMessageContent stacks header, child, and footer. '
          'Each slot is optional except child.',
      children: [
        _ExampleCard(
          label: 'Header + child + footer',
          child: StreamMessageContent(
            header: StreamMessageAnnotation(
              leading: const Icon(StreamIconData.iconBellNotification),
              label: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Reminder set'),
                    TextSpan(
                      text: ' · In 2 hours',
                      style: textTheme.metadataDefault,
                    ),
                  ],
                ),
              ),
            ),
            footer: StreamMessageMetadata(
              timestamp: const Text('09:41'),
              username: const Text('Alice'),
              status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
            ),
            child: StreamMessageBubble(
              child: StreamMessageText('Has anyone tried the new Flutter update?'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Child + footer (edited)',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('09:42'),
              status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
              edited: const Text('Edited'),
            ),
            child: StreamMessageBubble(
              child: StreamMessageText('A message with just metadata below.'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Header + child (no footer)',
          child: StreamMessageContent(
            header: StreamMessageAnnotation(
              leading: const Icon(StreamIconData.iconBookmark),
              label: const Text('Saved for later'),
            ),
            child: StreamMessageBubble(
              child: StreamMessageText('Saved message, no footer.'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Children with replies + footer',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('09:43'),
              username: const Text('Bob'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamMessageBubble(
                  child: StreamMessageText('Let me know what you think!'),
                ),
                StreamMessageReplies(
                  label: const Text('5 replies'),
                  avatars: _sampleAvatars(3, palette),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReactionVariantsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'REACTION VARIANTS',
      description:
          'Reactions can overlap or sit below the bubble, and be '
          'positioned at the header or footer of the child.',
      children: [
        _ExampleCard(
          label: 'Overlapping (header)',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('09:44'),
              username: const Text('Alice'),
            ),
            child: StreamReactions.segmented(
              items: const [
                StreamReactionsItem(emoji: Text('👍'), count: 3),
                StreamReactionsItem(emoji: Text('❤'), count: 2),
              ],
              position: StreamReactionsPosition.header,
              alignment: StreamReactionsAlignment.end,
              indent: 8,
              child: StreamMessageBubble(
                child: StreamMessageText('Reactions overlap the bubble edge.'),
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Non-overlapping',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('09:45'),
              username: const Text('Bob'),
            ),
            child: StreamReactions.segmented(
              items: const [
                StreamReactionsItem(emoji: Text('😂'), count: 5),
                StreamReactionsItem(emoji: Text('🔥'), count: 3),
                StreamReactionsItem(emoji: Text('🎉'), count: 2),
              ],
              overlap: false,
              child: StreamMessageBubble(
                child: StreamMessageText('Reactions with a gap below.'),
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Header position',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('09:46'),
            ),
            child: StreamReactions.segmented(
              items: const [
                StreamReactionsItem(emoji: Text('👏'), count: 7),
              ],
              position: StreamReactionsPosition.header,
              alignment: StreamReactionsAlignment.end,
              indent: 8,
              child: StreamMessageBubble(
                child: StreamMessageText('Reaction sits above the bubble.'),
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Many reactions (wrapping)',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('09:47'),
              username: const Text('Charlie'),
            ),
            child: StreamReactions.segmented(
              items: const [
                StreamReactionsItem(emoji: Text('👍'), count: 8),
                StreamReactionsItem(emoji: Text('❤'), count: 14),
                StreamReactionsItem(emoji: Text('😂'), count: 5),
                StreamReactionsItem(emoji: Text('🔥'), count: 3),
                StreamReactionsItem(emoji: Text('🎉'), count: 2),
                StreamReactionsItem(emoji: Text('👏'), count: 7),
              ],
              overlap: false,
              child: StreamMessageBubble(
                child: StreamMessageText('Short text.'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullCompositionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = context.streamTextTheme;
    final palette = context.streamColorScheme.avatarPalette;

    return _Section(
      label: 'FULL COMPOSITION',
      description:
          'All slots populated with annotations, reactions, replies, '
          'and metadata demonstrating the intended layout.',
      children: [
        _ExampleCard(
          label: 'Incoming — all slots',
          child: Align(
            alignment: .centerLeft,
            child: StreamMessageContent(
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamMessageAnnotation(
                    leading: const Icon(StreamIconData.iconPin),
                    label: const Text('Pinned'),
                  ),
                  StreamMessageAnnotation(
                    leading: const Icon(StreamIconData.iconBellNotification),
                    label: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Reminder set'),
                          TextSpan(
                            text: ' · In 30 minutes',
                            style: textTheme.metadataDefault,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              footer: StreamMessageMetadata(
                timestamp: const Text('09:41'),
                username: const Text('Alice'),
                status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
                edited: const Text('Edited'),
              ),
              child: StreamReactions.segmented(
                items: const [
                  StreamReactionsItem(emoji: Text('👍'), count: 3),
                  StreamReactionsItem(emoji: Text('😂'), count: 1),
                  StreamReactionsItem(emoji: Text('❤'), count: 5),
                ],
                overlap: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamMessageBubble(
                      child: StreamMessageText(
                        'This message has multiple annotations, '
                        'reactions, a reply indicator, and full metadata.',
                      ),
                    ),
                    StreamMessageReplies(
                      label: const Text('5 replies'),
                      avatars: _sampleAvatars(3, palette),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Outgoing — reactions + status',
          child: StreamMessageLayout(
            data: const StreamMessageLayoutData(
              alignment: StreamMessageAlignment.end,
            ),
            child: StreamMessageContent(
              footer: StreamMessageMetadata(
                timestamp: const Text('09:42'),
                status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
              ),
              child: StreamReactions.segmented(
                alignment: .end,
                overlap: false,
                items: const [StreamReactionsItem(emoji: Text('👍'), count: 2)],
                child: StreamMessageBubble(
                  child: StreamMessageText('Sure, I can help with that!'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmojiOnlySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.streamColorScheme.avatarPalette;

    return _Section(
      label: 'EMOJI-ONLY MESSAGES',
      description:
          'Messages with 1–3 emojis render without a bubble. '
          'Shown with reactions, replies, and metadata.',
      children: [
        _ExampleCard(
          label: 'Single emoji + reactions + footer',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('09:48'),
              username: const Text('Alice'),
            ),
            child: StreamReactions.segmented(
              items: const [
                StreamReactionsItem(emoji: Text('❤'), count: 4),
                StreamReactionsItem(emoji: Text('😂'), count: 2),
              ],
              overlap: false,
              child: StreamMessageText('👋'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Two emojis + replies (no connector)',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('09:49'),
              username: const Text('Bob'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamMessageText('❤️🔥'),
                StreamMessageReplies(
                  label: const Text('3 replies'),
                  avatars: _sampleAvatars(2, palette),
                  showConnector: false,
                ),
              ],
            ),
          ),
        ),
        _ExampleCard(
          label: 'Three emojis + reactions + replies',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('09:50'),
              username: const Text('Charlie'),
            ),
            child: StreamReactions.segmented(
              items: const [
                StreamReactionsItem(emoji: Text('🔥'), count: 3),
              ],
              overlap: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamMessageText('🎉👏🔥'),
                  StreamMessageReplies(
                    label: const Text('2 replies'),
                    avatars: _sampleAvatars(2, palette),
                    showConnector: false,
                  ),
                ],
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Outgoing emoji + reactions',
          child: StreamMessageLayout(
            data: const StreamMessageLayoutData(
              alignment: StreamMessageAlignment.end,
            ),
            child: StreamMessageContent(
              footer: StreamMessageMetadata(
                timestamp: const Text('09:51'),
                status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
              ),
              child: StreamReactions.segmented(
                alignment: .end,
                overlap: false,
                items: const [
                  StreamReactionsItem(emoji: Text('👍'), count: 5),
                ],
                child: StreamMessageText('😂'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MinimalSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'MINIMAL',
      description: 'Only the required child slot — no header or footer.',
      children: [
        _ExampleCard(
          label: 'Bubble only',
          child: StreamMessageContent(
            child: StreamMessageBubble(
              child: StreamMessageText('Just a bubble, nothing else.'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Bubble + footer only',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('09:50'),
            ),
            child: StreamMessageBubble(
              child: StreamMessageText('Hey!'),
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
