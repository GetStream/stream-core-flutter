import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamReactions,
  path: '[Components]/Reactions',
)
Widget buildStreamReactionsPlayground(BuildContext context) {
  final type = context.knobs.object.dropdown(
    label: 'Type',
    options: StreamReactionsType.values,
    initialOption: StreamReactionsType.segmented,
    labelBuilder: (option) => option.name,
    description: 'Segmented shows individual pills; clustered groups into one.',
  );
  final position = context.knobs.object.dropdown(
    label: 'Position',
    options: StreamReactionsPosition.values,
    initialOption: StreamReactionsPosition.header,
    labelBuilder: (option) => option.name,
    description: 'Where reactions sit relative to the bubble.',
  );
  final alignmentOption = context.knobs.object.dropdown(
    label: 'Alignment',
    options: _AlignmentOption.values,
    initialOption: _AlignmentOption.defaultValue,
    labelBuilder: (option) => option.label,
    description: 'Horizontal alignment of reactions. Default derives from message alignment.',
  );
  final crossAxisOption = context.knobs.object.dropdown(
    label: 'Cross Axis Alignment',
    options: _CrossAxisOption.values,
    initialOption: _CrossAxisOption.defaultValue,
    labelBuilder: (option) => option.label,
    description: 'Cross-axis alignment of the column. Default derives from message alignment.',
  );
  final overlap = context.knobs.boolean(
    label: 'Overlap',
    initialValue: true,
    description: 'Reactions overlap the bubble edge with negative spacing.',
  );
  final useIndent = context.knobs.boolean(
    label: 'Override Indent',
    description: 'Enable to set a custom indent. When off, uses the default (null).',
  );
  final indent = useIndent
      ? context.knobs.double.slider(
          label: 'Indent',
          initialValue: 8,
          min: -8,
          max: 8,
          divisions: 8,
          description: 'Horizontal shift applied to the reaction strip.',
        )
      : null;
  final max = overlap
      ? context.knobs.int.slider(
          label: 'Max Visible',
          initialValue: 4,
          min: 1,
          max: 6,
          divisions: 5,
          description: 'Reactions beyond this collapse into a +N chip.',
        )
      : null;
  final direction = context.knobs.object.dropdown(
    label: 'Direction',
    options: _MessageDirection.values,
    initialOption: _MessageDirection.incoming,
    labelBuilder: (option) => option.name,
    description: 'Incoming (start-aligned bubble) or outgoing (end-aligned).',
  );
  final reactionCount = context.knobs.int.slider(
    label: 'Reaction Count',
    initialValue: 5,
    min: 1,
    max: _allReactionItems.length,
    description: 'Number of distinct reaction types to display.',
  );

  final items = _allReactionItems.take(reactionCount).toList();
  final spacing = context.streamSpacing;

  final alignment = alignmentOption.value;
  final crossAxisAlignment = crossAxisOption.value;

  Widget buildReaction({required Widget bubble}) => switch (type) {
    StreamReactionsType.segmented => StreamReactions.segmented(
      items: items,
      position: position,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      max: max,
      overlap: overlap,
      indent: indent,
      onPressed: () => _showSnack(context, 'Reaction tapped'),
      child: bubble,
    ),
    StreamReactionsType.clustered => StreamReactions.clustered(
      items: items,
      position: position,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      max: max,
      overlap: overlap,
      indent: indent,
      onPressed: () => _showSnack(context, 'Reaction tapped'),
      child: bubble,
    ),
  };

  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: .stretch,
          spacing: spacing.xl,
          children: [
            _ChatBubble(
              message: _mediumMessage,
              alignment: direction.alignment,
              reactionBuilder: buildReaction,
            ),
            _ChatBubble(
              message: _shortMessage,
              alignment: direction.alignment,
              reactionBuilder: buildReaction,
            ),
            _ChatBubble(
              message: _longMessage,
              alignment: direction.alignment,
              reactionBuilder: buildReaction,
            ),
          ],
        ),
      ),
    ),
  );
}

/// A realistic chat bubble used in playground and showcase.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.alignment,
    required this.reactionBuilder,
  });

  final String message;
  final StreamMessageAlignment alignment;
  final Widget Function({required Widget bubble}) reactionBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamMessagePlacement(
      placement: StreamMessagePlacementData(alignment: alignment),
      child: StreamMessageContent(
        child: reactionBuilder(
          bubble: StreamMessageBubble(child: StreamMessageText(message)),
        ),
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamReactions,
  path: '[Components]/Reactions',
)
Widget buildStreamReactionsShowcase(BuildContext context) {
  final spacing = context.streamSpacing;

  return SingleChildScrollView(
    padding: EdgeInsets.all(spacing.lg),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.xl,
          children: [
            const _ShowcaseSection(
              title: 'SEGMENTED — FOOTER',
              description:
                  'Individual pills per reaction, positioned as a footer '
                  'with overlap. Varying reaction counts across messages.',
              threads: [
                _ThreadMessage(
                  message: _mediumMessage,
                  alignment: StreamMessageAlignment.start,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: _allReactionItems,
                  max: 4,
                ),
                _ThreadMessage(
                  message: _shortMessage,
                  alignment: StreamMessageAlignment.end,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: [
                    StreamReactionsItem(emoji: Text('👍'), count: 2),
                    StreamReactionsItem(emoji: Text('❤'), count: 1),
                  ],
                ),
                _ThreadMessage(
                  message: _longMessage,
                  alignment: StreamMessageAlignment.start,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: [
                    StreamReactionsItem(emoji: Text('😂'), count: 5),
                    StreamReactionsItem(emoji: Text('🔥'), count: 3),
                    StreamReactionsItem(emoji: Text('👏'), count: 7),
                    StreamReactionsItem(emoji: Text('🎉'), count: 2),
                  ],
                ),
              ],
            ),
            const _ShowcaseSection(
              title: 'SEGMENTED — HEADER',
              description:
                  'Individual pills as a header. Reactions paint on top '
                  'of the child via z-ordering.',
              threads: [
                _ThreadMessage(
                  message: _shortMessage,
                  alignment: StreamMessageAlignment.start,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.header,
                  items: [
                    StreamReactionsItem(emoji: Text('👍'), count: 3),
                    StreamReactionsItem(emoji: Text('❤'), count: 8),
                    StreamReactionsItem(emoji: Text('😂'), count: 2),
                  ],
                ),
                _ThreadMessage(
                  message: _longMessage,
                  alignment: StreamMessageAlignment.end,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.header,
                  items: _allReactionItems,
                  max: 5,
                ),
              ],
            ),
            const _ShowcaseSection(
              title: 'CLUSTERED',
              description:
                  'All reactions grouped into a single chip. Shown in both '
                  'header and footer positions.',
              threads: [
                _ThreadMessage(
                  message: _longMessage,
                  alignment: StreamMessageAlignment.start,
                  type: StreamReactionsType.clustered,
                  position: StreamReactionsPosition.footer,
                  items: _allReactionItems,
                ),
                _ThreadMessage(
                  message: _shortMessage,
                  alignment: StreamMessageAlignment.end,
                  type: StreamReactionsType.clustered,
                  position: StreamReactionsPosition.header,
                  items: [
                    StreamReactionsItem(emoji: Text('👍'), count: 4),
                    StreamReactionsItem(emoji: Text('❤'), count: 3),
                    StreamReactionsItem(emoji: Text('😂'), count: 2),
                  ],
                ),
                _ThreadMessage(
                  message: _mediumMessage,
                  alignment: StreamMessageAlignment.start,
                  type: StreamReactionsType.clustered,
                  position: StreamReactionsPosition.footer,
                  items: [
                    StreamReactionsItem(emoji: Text('🔥'), count: 6),
                    StreamReactionsItem(emoji: Text('🙏'), count: 1),
                  ],
                ),
              ],
            ),
            const _ShowcaseSection(
              title: 'OVERFLOW',
              description:
                  'When reactions exceed the max visible limit, extras are '
                  'collapsed into a +N overflow chip.',
              threads: [
                _ThreadMessage(
                  message: _mediumMessage,
                  alignment: StreamMessageAlignment.start,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: _allReactionItems,
                  max: 3,
                ),
                _ThreadMessage(
                  message: _longMessage,
                  alignment: StreamMessageAlignment.end,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: _allReactionItems,
                  max: 2,
                ),
              ],
            ),
            const _ShowcaseSection(
              title: 'COUNT RULES',
              description:
                  'If any reaction has count > 1, all chips show counts. '
                  'When all have count 1, no counts are displayed.',
              threads: [
                _ThreadMessage(
                  message: 'Single emoji, count 1 — no count shown.',
                  alignment: StreamMessageAlignment.start,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: [StreamReactionsItem(emoji: Text('👍'))],
                ),
                _ThreadMessage(
                  message: 'Single emoji, count 5 — count shown.',
                  alignment: StreamMessageAlignment.end,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: [StreamReactionsItem(emoji: Text('❤'), count: 5)],
                ),
                _ThreadMessage(
                  message: 'Multiple emojis, all count 1 — no counts.',
                  alignment: StreamMessageAlignment.start,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: [
                    StreamReactionsItem(emoji: Text('👍')),
                    StreamReactionsItem(emoji: Text('❤')),
                    StreamReactionsItem(emoji: Text('😂')),
                  ],
                ),
                _ThreadMessage(
                  message: 'Mixed counts — all show counts.',
                  alignment: StreamMessageAlignment.end,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: [
                    StreamReactionsItem(emoji: Text('👍'), count: 8),
                    StreamReactionsItem(emoji: Text('❤')),
                    StreamReactionsItem(emoji: Text('😂'), count: 3),
                    StreamReactionsItem(emoji: Text('🔥')),
                  ],
                ),
                _ThreadMessage(
                  message: 'Clustered — total count shown when > 1.',
                  alignment: StreamMessageAlignment.start,
                  type: StreamReactionsType.clustered,
                  position: StreamReactionsPosition.footer,
                  items: [
                    StreamReactionsItem(emoji: Text('👍')),
                    StreamReactionsItem(emoji: Text('❤')),
                    StreamReactionsItem(emoji: Text('😂')),
                  ],
                ),
              ],
            ),
            const _ShowcaseSection(
              title: 'DETACHED',
              description:
                  'Reactions with overlap disabled — separated from the bubble '
                  'by a fixed gap. Both segmented and clustered.',
              threads: [
                _ThreadMessage(
                  message: _mediumMessage,
                  alignment: StreamMessageAlignment.start,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: [
                    StreamReactionsItem(emoji: Text('😂'), count: 5),
                    StreamReactionsItem(emoji: Text('👍'), count: 2),
                    StreamReactionsItem(emoji: Text('❤'), count: 8),
                  ],
                  overlap: false,
                ),
                _ThreadMessage(
                  message: _shortMessage,
                  alignment: StreamMessageAlignment.end,
                  type: StreamReactionsType.clustered,
                  position: StreamReactionsPosition.footer,
                  items: [
                    StreamReactionsItem(emoji: Text('🔥'), count: 3),
                    StreamReactionsItem(emoji: Text('🎉'), count: 1),
                  ],
                  overlap: false,
                ),
                _ThreadMessage(
                  message: _longMessage,
                  alignment: StreamMessageAlignment.start,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: _allReactionItems,
                  overlap: false,
                ),
              ],
            ),
            _EmojiOnlyShowcaseSection(),
          ],
        ),
      ),
    ),
  );
}

// =============================================================================
// Showcase helpers
// =============================================================================

@immutable
class _ThreadMessage {
  const _ThreadMessage({
    required this.message,
    required this.alignment,
    required this.type,
    required this.position,
    required this.items,
    this.max,
    this.overlap = true,
  });

  final String message;
  final StreamMessageAlignment alignment;
  final StreamReactionsType type;
  final StreamReactionsPosition position;
  final List<StreamReactionsItem> items;
  final int? max;
  final bool overlap;
}

class _ShowcaseSection extends StatelessWidget {
  const _ShowcaseSection({
    required this.title,
    required this.description,
    required this.threads,
  });

  final String title;
  final String description;
  final List<_ThreadMessage> threads;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        _SectionLabel(label: title),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.backgroundApp,
            borderRadius: BorderRadius.all(radius.lg),
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
                  spacing.xs,
                ),
                child: Text(
                  description,
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.textSecondary,
                  ),
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              Padding(
                padding: EdgeInsets.all(spacing.md),
                child: Column(
                  spacing: spacing.lg,
                  crossAxisAlignment: .stretch,
                  children: [
                    for (final t in threads)
                      _ChatBubble(
                        message: t.message,
                        alignment: t.alignment,
                        reactionBuilder: ({required bubble}) => switch (t.type) {
                          StreamReactionsType.segmented => StreamReactions.segmented(
                            items: t.items,
                            position: t.position,
                            max: t.max,
                            overlap: t.overlap,
                            child: bubble,
                            onPressed: () {},
                          ),
                          StreamReactionsType.clustered => StreamReactions.clustered(
                            items: t.items,
                            position: t.position,
                            max: t.max,
                            overlap: t.overlap,
                            child: bubble,
                            onPressed: () {},
                          ),
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmojiOnlyShowcaseSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final palette = colorScheme.avatarPalette;

    const reactions = <StreamReactionsItem>[
      StreamReactionsItem(emoji: Text('❤'), count: 4),
      StreamReactionsItem(emoji: Text('😂'), count: 2),
    ];

    const singleReaction = <StreamReactionsItem>[
      StreamReactionsItem(emoji: Text('👍'), count: 3),
    ];

    Widget emojiMessage({
      required String text,
      required StreamMessageAlignment alignment,
      required List<StreamReactionsItem> items,
      bool showReplies = false,
      StreamReactionsPosition position = StreamReactionsPosition.footer,
    }) {
      final isEnd = alignment == StreamMessageAlignment.end;
      final crossAxis =
          isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;

      final messageText = StreamMessageText(text);

      Widget body = StreamReactions.segmented(
        items: items,
        position: position,
        overlap: position == StreamReactionsPosition.header,
        alignment: position == StreamReactionsPosition.header
            ? StreamReactionsAlignment.end
            : StreamReactionsAlignment.start,
        indent: position == StreamReactionsPosition.header ? 8 : null,
        onPressed: () {},
        child: messageText,
      );

      if (showReplies) {
        body = Column(
          crossAxisAlignment: crossAxis,
          mainAxisSize: MainAxisSize.min,
          children: [
            body,
            StreamMessageReplies(
              label: const Text('2 replies'),
              avatars: _sampleAvatars(2, palette),
              alignment: alignment,
              showConnector: false,
              onTap: () {},
            ),
          ],
        );
      }

      return StreamMessagePlacement(
        placement: StreamMessagePlacementData(alignment: alignment),
        child: Align(
          alignment: isEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: StreamMessageContent(child: body),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'EMOJI-ONLY MESSAGES'),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.backgroundApp,
            borderRadius: BorderRadius.all(radius.lg),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.xs),
                child: Text(
                  'Emoji-only messages (1–3 emojis) render without a bubble. '
                  'Shown with reactions and replies.',
                  style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              Padding(
                padding: EdgeInsets.all(spacing.md),
                child: Column(
                  spacing: spacing.lg,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    emojiMessage(
                      text: '👋',
                      alignment: StreamMessageAlignment.start,
                      items: reactions,
                    ),
                    emojiMessage(
                      text: '❤️🔥',
                      alignment: StreamMessageAlignment.end,
                      items: singleReaction,
                      position: StreamReactionsPosition.header,
                    ),
                    emojiMessage(
                      text: '😂',
                      alignment: StreamMessageAlignment.start,
                      items: reactions,
                      showReplies: true,
                    ),
                    emojiMessage(
                      text: '🎉👏🔥',
                      alignment: StreamMessageAlignment.end,
                      items: reactions,
                      showReplies: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

List<Widget> _sampleAvatars(int count, List<StreamAvatarColorPair> palette) {
  const images = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
  ];
  const initials = ['AB', 'CD', 'EF'];
  return [
    for (var i = 0; i < count; i++)
      StreamAvatar(
        imageUrl: images[i % images.length],
        backgroundColor: palette[i % palette.length].backgroundColor,
        foregroundColor: palette[i % palette.length].foregroundColor,
        placeholder: (context) => Text(initials[i % initials.length]),
      ),
  ];
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

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
}

// =============================================================================
// Enums
// =============================================================================

enum _MessageDirection {
  incoming(StreamMessageAlignment.start),
  outgoing(StreamMessageAlignment.end),
  ;

  const _MessageDirection(this.alignment);

  final StreamMessageAlignment alignment;
}

enum _AlignmentOption {
  defaultValue('Default', null),
  start('start', StreamReactionsAlignment.start),
  end('end', StreamReactionsAlignment.end),
  ;

  const _AlignmentOption(this.label, this.value);

  final String label;
  final StreamReactionsAlignment? value;
}

enum _CrossAxisOption {
  defaultValue('Default', null),
  start('start', CrossAxisAlignment.start),
  center('center', CrossAxisAlignment.center),
  end('end', CrossAxisAlignment.end),
  stretch('stretch', CrossAxisAlignment.stretch),
  ;

  const _CrossAxisOption(this.label, this.value);

  final String label;
  final CrossAxisAlignment? value;
}

// =============================================================================
// Sample data
// =============================================================================

const _allReactionItems = <StreamReactionsItem>[
  StreamReactionsItem(emoji: Text('👍'), count: 8),
  StreamReactionsItem(emoji: Text('❤'), count: 14),
  StreamReactionsItem(emoji: Text('😂'), count: 5),
  StreamReactionsItem(emoji: Text('🔥'), count: 3),
  StreamReactionsItem(emoji: Text('🎉'), count: 2),
  StreamReactionsItem(emoji: Text('👏'), count: 7),
  StreamReactionsItem(emoji: Text('😮')),
  StreamReactionsItem(emoji: Text('🙏'), count: 4),
  StreamReactionsItem(emoji: Text('🚀'), count: 6),
  StreamReactionsItem(emoji: Text('😢'), count: 2),
];

const _shortMessage = 'Sure 👍';

const _mediumMessage = 'Hey, did you check the venue options?';

const _longMessage =
    'Hey, did you get a chance to look at the venue options for Saturday? '
    'I found a couple of great places downtown that might work.';
