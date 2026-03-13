import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageWidget,
  path: '[Components]/Message',
)
Widget buildStreamMessageWidgetPlayground(BuildContext context) {
  // -- Widget props -----------------------------------------------------------

  final text = context.knobs.string(
    label: 'Message Text',
    initialValue:
        'Has anyone tried the new Flutter update? '
        'The performance improvements are amazing!',
    description: 'The text content inside the message bubble.',
  );

  final alignment = context.knobs.object.dropdown<StreamMessageAlignment>(
    label: 'Alignment',
    options: StreamMessageAlignment.values,
    labelBuilder: (v) => v.name,
    description: 'Start (incoming) or end (outgoing).',
  );

  final messageCount = context.knobs.int.slider(
    label: 'Message Count',
    initialValue: 1,
    min: 1,
    max: 5,
    description: 'Number of messages in the stack. Positions are assigned automatically.',
  );

  final channelKind = context.knobs.object.dropdown<StreamChannelKind>(
    label: 'Channel Kind',
    options: StreamChannelKind.values,
    initialOption: StreamChannelKind.group,
    labelBuilder: (v) => v.name,
    description: 'Direct (1-to-1) hides avatars; group shows them.',
  );

  // -- Content slots ----------------------------------------------------------

  final showHeader = context.knobs.boolean(
    label: 'Show Header',
    description: 'Toggle the annotation header.',
  );

  final showReplies = context.knobs.boolean(
    label: 'Show Replies',
    description: 'Toggle the reply indicator with avatars.',
  );

  final showReactions = context.knobs.boolean(
    label: 'Show Reactions',
    description: 'Wrap the bubble with reactions.',
  );

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

  final reactionOverlap =
      showReactions &&
      context.knobs.boolean(
        label: 'Reaction Overlap',
        initialValue: true,
        description: 'Whether reactions overlap the bubble edge.',
      );

  final showFooter = context.knobs.boolean(
    label: 'Show Footer',
    initialValue: true,
    description: 'Toggle the metadata footer.',
  );

  // -- Build ------------------------------------------------------------------

  final textTheme = context.streamTextTheme;
  final palette = context.streamColorScheme.avatarPalette;

  final crossAlign = switch (alignment) {
    StreamMessageAlignment.start => CrossAxisAlignment.start,
    StreamMessageAlignment.end => CrossAxisAlignment.end,
  };

  Widget buildBody(String messageText) {
    final textWidget = StreamMessageText(messageText);
    final eCount = StreamMessageText.emojiOnlyCount(messageText);
    final emoji = eCount != null && eCount <= 3;
    final Widget messageBody = emoji ? textWidget : StreamMessageBubble(child: textWidget);

    final replies = showReplies
        ? StreamMessageReplies(
            label: const Text('3 replies'),
            avatars: _sampleAvatars(3, palette),
            showConnector: !emoji,
            onTap: () {},
          )
        : null;

    Widget body = Column(
      crossAxisAlignment: crossAlign,
      mainAxisSize: MainAxisSize.min,
      children: [messageBody, ?replies],
    );

    if (showReactions) {
      final items = _allReactions.take(reactionCount).toList();

      Widget buildReactions({required Widget child}) => StreamReactions.segmented(
        items: items,
        position: reactionPosition,
        overlap: reactionOverlap,
        onPressed: () {},
        child: child,
      );

      if (reactionOverlap) {
        body = Column(
          crossAxisAlignment: crossAlign,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildReactions(child: messageBody),
            ?replies,
          ],
        );
      } else {
        body = buildReactions(child: body);
      }
    }

    return body;
  }

  StreamMessageStackPosition stackPositionFor(int index, int count) {
    if (count == 1) return StreamMessageStackPosition.single;
    if (index == 0) return StreamMessageStackPosition.top;
    if (index == count - 1) return StreamMessageStackPosition.bottom;
    return StreamMessageStackPosition.middle;
  }

  final avatar = StreamAvatar(
    imageUrl: _avatarImages[0],
    backgroundColor: palette[0].backgroundColor,
    foregroundColor: palette[0].foregroundColor,
    placeholder: (context) => const Text('AJ'),
  );

  final messages = <Widget>[
    for (var i = 0; i < messageCount; i++)
      StreamMessageWidget(
        alignment: alignment,
        stackPosition: stackPositionFor(i, messageCount),
        channelKind: channelKind,
        onTap: () => _showSnack(context, 'Message tapped'),
        onLongPress: () => _showSnack(context, 'Message long-pressed'),
        leading: avatar,
        child: i == messageCount - 1
            ? StreamMessageContent(
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
                      )
                    : null,
                child: buildBody(text),
              )
            : StreamMessageContent(
                child: StreamMessageBubble(
                  child: StreamMessageText(_stackMessages[i % _stackMessages.length]),
                ),
              ),
      ),
  ];

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: messages,
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMessageWidget,
  path: '[Components]/Message',
)
Widget buildStreamMessageWidgetShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 32,
        children: [
          _AlignmentSection(),
          _StackPositionsSection(),
          _ChannelKindSection(),
          _VisibilitySection(),
          _FullCompositionSection(),
          _EmojiOnlySection(),
          _ConversationSection(),
          _ThemeOverrideSection(),
          _MinimalSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Showcase Sections
// =============================================================================

class _AlignmentSection extends StatelessWidget {
  const _AlignmentSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'ALIGNMENT',
      description:
          'The leading avatar is placed at the start or end of the row '
          'depending on alignment. Descendants receive placement context.',
      children: [
        _ExampleCard(
          label: 'Start (incoming)',
          child: _MessageItem(
            avatarIndex: 0,
            text: 'Has anyone tried the new Flutter update?',
            timestamp: '09:41',
            username: 'Alice',
          ),
        ),
        _ExampleCard(
          label: 'End (outgoing)',
          child: _MessageItem(
            alignment: StreamMessageAlignment.end,
            avatarIndex: 1,
            text: 'Sure, I can help with that!',
            timestamp: '09:42',
            status: Icon(StreamIconData.iconDoupleCheckmark1Small),
          ),
        ),
        _ExampleCard(
          label: 'Start — no avatar',
          child: _MessageItem(
            text: 'A message without a leading avatar.',
            timestamp: '09:43',
          ),
        ),
      ],
    );
  }
}

class _StackPositionsSection extends StatelessWidget {
  const _StackPositionsSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'STACK POSITIONS',
      description:
          'In a consecutive group, only the bottom message shows the '
          'avatar. Middle and top messages hide it while preserving spacing. '
          'This is driven by the default leadingVisibility in the theme.',
      children: [
        _ExampleCard(
          label: 'Incoming stack (top → middle → bottom)',
          child: Column(
            spacing: 2,
            children: [
              _MessageItem(
                stackPosition: StreamMessageStackPosition.top,
                avatarIndex: 0,
                text: 'The keynote was incredible this year',
              ),
              _MessageItem(
                stackPosition: StreamMessageStackPosition.middle,
                avatarIndex: 0,
                text: 'Especially the Impeller demo',
              ),
              _MessageItem(
                stackPosition: StreamMessageStackPosition.bottom,
                avatarIndex: 0,
                text: 'Did you catch the part about Wasm support?',
                timestamp: '09:41',
                username: 'Alice',
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Outgoing stack (top → middle → bottom)',
          child: Column(
            spacing: 2,
            children: [
              _MessageItem(
                alignment: StreamMessageAlignment.end,
                stackPosition: StreamMessageStackPosition.top,
                avatarIndex: 1,
                text: 'Yes! The performance charts were wild',
              ),
              _MessageItem(
                alignment: StreamMessageAlignment.end,
                stackPosition: StreamMessageStackPosition.middle,
                avatarIndex: 1,
                text: '60fps on low-end devices',
              ),
              _MessageItem(
                alignment: StreamMessageAlignment.end,
                stackPosition: StreamMessageStackPosition.bottom,
                avatarIndex: 1,
                text: "Can't wait to try it in our app",
                timestamp: '09:42',
                status: Icon(StreamIconData.iconDoupleCheckmark1Small),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChannelKindSection extends StatelessWidget {
  const _ChannelKindSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'CHANNEL KIND',
      description:
          'In direct (1-to-1) channels, avatars are hidden by default since '
          'the sender is always known. In group channels, avatars are shown '
          'for identification.',
      children: [
        _ExampleCard(
          label: 'Group channel — avatars visible',
          child: Column(
            spacing: 2,
            children: [
              _MessageItem(
                avatarIndex: 0,
                text: 'In a group channel, avatars help identify the sender.',
                timestamp: '09:41',
                username: 'Alice',
              ),
              _MessageItem(
                alignment: StreamMessageAlignment.end,
                avatarIndex: 1,
                text: 'Makes sense for multi-participant chats!',
                timestamp: '09:42',
                status: Icon(StreamIconData.iconDoupleCheckmark1Small),
              ),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Direct channel — avatars hidden',
          child: Column(
            spacing: 2,
            children: [
              _MessageItem(
                channelKind: StreamChannelKind.direct,
                avatarIndex: 0,
                text: 'In a direct channel, you already know who is talking.',
                timestamp: '09:41',
                username: 'Alice',
              ),
              _MessageItem(
                channelKind: StreamChannelKind.direct,
                alignment: StreamMessageAlignment.end,
                avatarIndex: 1,
                text: 'So avatars are removed to save space.',
                timestamp: '09:42',
                status: Icon(StreamIconData.iconDoupleCheckmark1Small),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VisibilitySection extends StatelessWidget {
  const _VisibilitySection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'LEADING VISIBILITY',
      description:
          'Leading visibility is theme-driven via StreamMessageItemTheme. '
          'It supports three modes: visible (shown), hidden (space reserved), '
          'and gone (no space).',
      children: [
        const _ExampleCard(
          label: 'Visible — avatar fully shown (default)',
          child: _MessageItem(
            avatarIndex: 0,
            text: 'Avatar is visible.',
            timestamp: '10:00',
            username: 'Alice',
          ),
        ),
        _ExampleCard(
          label: 'Hidden — space reserved, avatar invisible',
          child: StreamMessageItemTheme(
            data: StreamMessageItemThemeData(
              leadingVisibility: StreamMessageStyleVisibility.all(StreamVisibility.hidden),
            ),
            child: const _MessageItem(
              avatarIndex: 0,
              text: 'Avatar space is preserved for alignment.',
              timestamp: '10:01',
            ),
          ),
        ),
        _ExampleCard(
          label: 'Gone — no space reserved',
          child: StreamMessageItemTheme(
            data: StreamMessageItemThemeData(
              leadingVisibility: StreamMessageStyleVisibility.all(StreamVisibility.gone),
            ),
            child: const _MessageItem(
              avatarIndex: 0,
              text: 'Avatar is removed entirely from the layout.',
              timestamp: '10:02',
            ),
          ),
        ),
      ],
    );
  }
}

class _FullCompositionSection extends StatelessWidget {
  const _FullCompositionSection();

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
          child: _MessageItem(
            avatarIndex: 0,
            text:
                'This message has an annotation, '
                'reactions, a reply indicator, and full metadata.',
            timestamp: '09:41',
            username: 'Alice',
            status: const Icon(StreamIconData.iconDoupleCheckmark1Small),
            edited: const Text('Edited'),
            annotation: StreamMessageAnnotation(
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
            reactions: _allReactions.take(4).toList(),
            replies: StreamMessageReplies(
              label: const Text('5 replies'),
              avatars: _sampleAvatars(3, palette),
            ),
          ),
        ),
        const _ExampleCard(
          label: 'Outgoing — reactions + status',
          child: _MessageItem(
            alignment: StreamMessageAlignment.end,
            avatarIndex: 1,
            text: 'Looks great, merging the PR now!',
            timestamp: '09:42',
            status: Icon(StreamIconData.iconDoupleCheckmark1Small),
            reactions: [
              StreamReactionsItem(emoji: Text('👍'), count: 2),
              StreamReactionsItem(emoji: Text('🎉'), count: 1),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmojiOnlySection extends StatelessWidget {
  const _EmojiOnlySection();

  @override
  Widget build(BuildContext context) {
    final palette = context.streamColorScheme.avatarPalette;

    return _Section(
      label: 'EMOJI-ONLY MESSAGES',
      description:
          'Messages with 1–3 emojis render without a bubble. '
          'Shown with the full message widget layout.',
      children: [
        const _ExampleCard(
          label: 'Single emoji',
          child: _MessageItem(
            avatarIndex: 0,
            text: '👋',
            timestamp: '11:00',
            username: 'Alice',
            isEmojiOnly: true,
          ),
        ),
        const _ExampleCard(
          label: 'Multi-emoji with reactions',
          child: _MessageItem(
            avatarIndex: 2,
            text: '🎉👏🔥',
            timestamp: '11:01',
            username: 'Charlie',
            isEmojiOnly: true,
            reactions: [
              StreamReactionsItem(emoji: Text('❤'), count: 4),
              StreamReactionsItem(emoji: Text('😂'), count: 2),
            ],
          ),
        ),
        _ExampleCard(
          label: 'Outgoing emoji with replies',
          child: _MessageItem(
            alignment: StreamMessageAlignment.end,
            avatarIndex: 1,
            text: '👍🔥',
            timestamp: '11:02',
            isEmojiOnly: true,
            replies: StreamMessageReplies(
              label: const Text('2 replies'),
              avatars: _sampleAvatars(2, palette),
              showConnector: false,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConversationSection extends StatelessWidget {
  const _ConversationSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'CONVERSATION',
      description:
          'A realistic exchange showing how alignment, stack position, '
          'and avatar visibility combine in a typical chat thread.',
      children: [
        _ExampleCard(
          label: 'Mixed thread',
          child: Column(
            spacing: 2,
            children: [
              _MessageItem(
                stackPosition: StreamMessageStackPosition.top,
                avatarIndex: 0,
                text: 'Hey, are you free this weekend?',
              ),
              _MessageItem(
                stackPosition: StreamMessageStackPosition.bottom,
                avatarIndex: 0,
                text: 'We could go hiking 🏔️',
                timestamp: '09:41',
                username: 'Alice',
              ),
              SizedBox(height: 8),
              _MessageItem(
                alignment: StreamMessageAlignment.end,
                avatarIndex: 1,
                text: 'Sounds great! Let me check my schedule.',
                timestamp: '09:42',
                status: Icon(StreamIconData.iconDoupleCheckmark1Small),
              ),
              SizedBox(height: 8),
              _MessageItem(
                avatarIndex: 2,
                text: 'Count me in! I know a great trail near the lake 🌲',
                timestamp: '09:43',
                username: 'Charlie',
              ),
              SizedBox(height: 8),
              _MessageItem(
                alignment: StreamMessageAlignment.end,
                stackPosition: StreamMessageStackPosition.top,
                avatarIndex: 1,
                text: 'Perfect, Saturday morning works?',
              ),
              _MessageItem(
                alignment: StreamMessageAlignment.end,
                stackPosition: StreamMessageStackPosition.bottom,
                avatarIndex: 1,
                text: "I'll bring coffee ☕",
                timestamp: '09:44',
                status: Icon(StreamIconData.iconDoupleCheckmark1Small),
              ),
              SizedBox(height: 8),
              _MessageItem(
                avatarIndex: 0,
                text: '👍',
                timestamp: '09:45',
                username: 'Alice',
                isEmojiOnly: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeOverrideSection extends StatelessWidget {
  const _ThemeOverrideSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    return _Section(
      label: 'THEME OVERRIDE',
      description:
          'Use StreamMessageItemTheme to override item-level properties '
          'like background color and avatar size.',
      children: [
        _ExampleCard(
          label: 'Pinned message with highlight background',
          child: StreamMessageItemTheme(
            data: StreamMessageItemThemeData(
              backgroundColor: colorScheme.backgroundHighlight,
            ),
            child: const _MessageItem(
              avatarIndex: 0,
              text: 'This message is pinned to the conversation.',
              timestamp: '09:41',
              username: 'Alice',
            ),
          ),
        ),
        const _ExampleCard(
          label: 'Smaller avatar override',
          child: StreamMessageItemTheme(
            data: StreamMessageItemThemeData(
              avatarSize: StreamAvatarSize.sm,
            ),
            child: _MessageItem(
              avatarIndex: 1,
              text: 'A message with a smaller avatar.',
              timestamp: '09:42',
              username: 'Bob',
            ),
          ),
        ),
      ],
    );
  }
}

class _MinimalSection extends StatelessWidget {
  const _MinimalSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'MINIMAL',
      description: 'Stripped-down messages with only essential content.',
      children: [
        _ExampleCard(
          label: 'Bubble only — no avatar, no footer',
          child: _MessageItem(
            text: 'Just a bubble, nothing else.',
          ),
        ),
        _ExampleCard(
          label: 'Bubble + footer only',
          child: _MessageItem(
            text: 'Hey!',
            timestamp: '09:50',
          ),
        ),
        _ExampleCard(
          label: 'Avatar + bubble only',
          child: _MessageItem(
            avatarIndex: 0,
            text: 'Message with avatar, no metadata.',
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Sample Data
// =============================================================================

const _avatarImages = [
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
  'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
];

const _avatarInitials = ['AJ', 'BK', 'CL', 'DM'];

const _stackMessages = [
  'Hey everyone!',
  'Just got back from lunch 🍕',
  'Did you see the latest PR?',
  'Looks great, nice work!',
];

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

List<Widget> _sampleAvatars(int count, List<StreamAvatarColorPair> palette) {
  return [
    for (var i = 0; i < count; i++)
      StreamAvatar(
        imageUrl: _avatarImages[i % _avatarImages.length],
        backgroundColor: palette[i % palette.length].backgroundColor,
        foregroundColor: palette[i % palette.length].foregroundColor,
        placeholder: (context) => Text(_avatarInitials[i % _avatarInitials.length]),
      ),
  ];
}

// =============================================================================
// Helper Widgets
// =============================================================================

class _MessageItem extends StatelessWidget {
  const _MessageItem({
    this.alignment = StreamMessageAlignment.start,
    this.stackPosition = StreamMessageStackPosition.single,
    this.channelKind = StreamChannelKind.group,
    this.avatarIndex,
    required this.text,
    this.timestamp,
    this.username,
    this.edited,
    this.status,
    this.replies,
    this.annotation,
    this.reactions,
    this.isEmojiOnly = false,
  });

  final StreamMessageAlignment alignment;
  final StreamMessageStackPosition stackPosition;
  final StreamChannelKind channelKind;
  final int? avatarIndex;
  final String text;
  final String? timestamp;
  final String? username;
  final Widget? edited;
  final Widget? status;
  final Widget? replies;
  final Widget? annotation;
  final List<StreamReactionsItem>? reactions;
  final bool isEmojiOnly;

  @override
  Widget build(BuildContext context) {
    final palette = context.streamColorScheme.avatarPalette;

    Widget? leading;
    if (avatarIndex case final i?) {
      leading = StreamAvatar(
        imageUrl: _avatarImages[i % _avatarImages.length],
        backgroundColor: palette[i % palette.length].backgroundColor,
        foregroundColor: palette[i % palette.length].foregroundColor,
        placeholder: (context) => Text(_avatarInitials[i % _avatarInitials.length]),
      );
    }

    final messageText = StreamMessageText(text);
    final crossAlign = switch (alignment) {
      StreamMessageAlignment.start => CrossAxisAlignment.start,
      StreamMessageAlignment.end => CrossAxisAlignment.end,
    };

    final Widget messageBody = isEmojiOnly ? messageText : StreamMessageBubble(child: messageText);

    Widget body = Column(
      crossAxisAlignment: crossAlign,
      mainAxisSize: MainAxisSize.min,
      children: [messageBody, ?replies],
    );

    if (reactions case final items?) {
      body = StreamReactions.segmented(items: items, overlap: false, child: body);
    }

    return StreamMessageWidget(
      padding: .zero,
      alignment: alignment,
      stackPosition: stackPosition,
      channelKind: channelKind,
      leading: leading,
      child: StreamMessageContent(
        header: annotation,
        footer: timestamp != null
            ? StreamMessageMetadata(
                timestamp: Text(timestamp!),
                username: username != null ? Text(username!) : null,
                edited: edited,
                status: status,
              )
            : null,
        child: body,
      ),
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

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}
