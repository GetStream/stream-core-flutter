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
  final alignment = context.knobs.object.dropdown(
    label: 'Alignment',
    options: StreamReactionsAlignment.values,
    initialOption: StreamReactionsAlignment.end,
    labelBuilder: (option) => option.name,
    description: 'Horizontal alignment of reactions relative to the bubble.',
  );
  final overlap = context.knobs.boolean(
    label: 'Overlap',
    initialValue: true,
    description: 'Reactions overlap the bubble edge with negative spacing.',
  );
  final indent = context.knobs.double.slider(
    label: 'Indent',
    initialValue: 8,
    min: -8,
    max: 8,
    divisions: 8,
    description: 'Horizontal shift applied to the reaction strip.',
  );
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
  final isOutgoing = direction.isOutgoing;
  final crossAxis = isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start;

  Widget buildReaction({required Widget bubble}) => switch (type) {
    StreamReactionsType.segmented => StreamReactions.segmented(
      items: items,
      position: position,
      alignment: alignment,
      crossAxisAlignment: crossAxis,
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
      crossAxisAlignment: crossAxis,
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
              direction: direction,
              reactionBuilder: buildReaction,
            ),
            _ChatBubble(
              message: _shortMessage,
              direction: direction,
              reactionBuilder: buildReaction,
            ),
            _ChatBubble(
              message: _longMessage,
              direction: direction,
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
    required this.direction,
    required this.reactionBuilder,
  });

  final String message;
  final _MessageDirection direction;
  final Widget Function({required Widget bubble}) reactionBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final isOutgoing = direction.isOutgoing;
    final bubbleColor = isOutgoing ? colorScheme.brand.shade100 : colorScheme.backgroundSurface;

    const bubbleRadius = Radius.circular(20);
    final bubbleBorderRadius = isOutgoing
        ? const BorderRadius.only(
            topLeft: bubbleRadius,
            topRight: bubbleRadius,
            bottomLeft: bubbleRadius,
          )
        : const BorderRadius.only(
            topLeft: bubbleRadius,
            topRight: bubbleRadius,
            bottomRight: bubbleRadius,
          );

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: bubbleBorderRadius,
      ),
      child: Text(
        message,
        style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        reactionBuilder(bubble: bubble),
        SizedBox(height: spacing.xxs),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.xxs),
          child: Text(
            isOutgoing ? '09:41 · Read' : '09:40',
            style: textTheme.metadataDefault.copyWith(
              color: colorScheme.textTertiary,
            ),
          ),
        ),
      ],
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
          children: const [
            _ShowcaseSection(
              title: 'SEGMENTED — FOOTER',
              description:
                  'Individual pills per reaction, positioned as a footer '
                  'with overlap. Varying reaction counts across messages.',
              threads: [
                _ThreadMessage(
                  message: _mediumMessage,
                  direction: _MessageDirection.incoming,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: _allReactionItems,
                  max: 4,
                ),
                _ThreadMessage(
                  message: _shortMessage,
                  direction: _MessageDirection.outgoing,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: [
                    StreamReactionsItem(emoji: Text('👍'), count: 2),
                    StreamReactionsItem(emoji: Text('❤'), count: 1),
                  ],
                ),
                _ThreadMessage(
                  message: _longMessage,
                  direction: _MessageDirection.incoming,
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
            _ShowcaseSection(
              title: 'SEGMENTED — HEADER',
              description:
                  'Individual pills as a header. Reactions paint on top '
                  'of the child via z-ordering.',
              threads: [
                _ThreadMessage(
                  message: _shortMessage,
                  direction: _MessageDirection.incoming,
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
                  direction: _MessageDirection.outgoing,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.header,
                  items: _allReactionItems,
                  max: 5,
                ),
              ],
            ),
            _ShowcaseSection(
              title: 'CLUSTERED',
              description:
                  'All reactions grouped into a single chip. Shown in both '
                  'header and footer positions.',
              threads: [
                _ThreadMessage(
                  message: _longMessage,
                  direction: _MessageDirection.incoming,
                  type: StreamReactionsType.clustered,
                  position: StreamReactionsPosition.footer,
                  items: _allReactionItems,
                ),
                _ThreadMessage(
                  message: _shortMessage,
                  direction: _MessageDirection.outgoing,
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
                  direction: _MessageDirection.incoming,
                  type: StreamReactionsType.clustered,
                  position: StreamReactionsPosition.footer,
                  items: [
                    StreamReactionsItem(emoji: Text('🔥'), count: 6),
                    StreamReactionsItem(emoji: Text('🙏'), count: 1),
                  ],
                ),
              ],
            ),
            _ShowcaseSection(
              title: 'OVERFLOW',
              description:
                  'When reactions exceed the max visible limit, extras are '
                  'collapsed into a +N overflow chip.',
              threads: [
                _ThreadMessage(
                  message: _mediumMessage,
                  direction: _MessageDirection.incoming,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: _allReactionItems,
                  max: 3,
                ),
                _ThreadMessage(
                  message: _longMessage,
                  direction: _MessageDirection.outgoing,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: _allReactionItems,
                  max: 2,
                ),
              ],
            ),
            _ShowcaseSection(
              title: 'COUNT RULES',
              description:
                  'If any reaction has count > 1, all chips show counts. '
                  'When all have count 1, no counts are displayed.',
              threads: [
                _ThreadMessage(
                  message: 'Single emoji, count 1 — no count shown.',
                  direction: _MessageDirection.incoming,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: [StreamReactionsItem(emoji: Text('👍'))],
                ),
                _ThreadMessage(
                  message: 'Single emoji, count 5 — count shown.',
                  direction: _MessageDirection.outgoing,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: [StreamReactionsItem(emoji: Text('❤'), count: 5)],
                ),
                _ThreadMessage(
                  message: 'Multiple emojis, all count 1 — no counts.',
                  direction: _MessageDirection.incoming,
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
                  direction: _MessageDirection.outgoing,
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
                  direction: _MessageDirection.incoming,
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
            _ShowcaseSection(
              title: 'DETACHED',
              description:
                  'Reactions with overlap disabled — separated from the bubble '
                  'by a fixed gap. Both segmented and clustered.',
              threads: [
                _ThreadMessage(
                  message: _mediumMessage,
                  direction: _MessageDirection.incoming,
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
                  direction: _MessageDirection.outgoing,
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
                  direction: _MessageDirection.incoming,
                  type: StreamReactionsType.segmented,
                  position: StreamReactionsPosition.footer,
                  items: _allReactionItems,
                  overlap: false,
                ),
              ],
            ),
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
    required this.direction,
    required this.type,
    required this.position,
    required this.items,
    this.max,
    this.overlap = true,
  });

  final String message;
  final _MessageDirection direction;
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
                        direction: t.direction,
                        reactionBuilder: ({required bubble}) {
                          final isOut = t.direction.isOutgoing;
                          final reactionAlignment = t.overlap
                              ? (isOut ? StreamReactionsAlignment.start : StreamReactionsAlignment.end)
                              : (isOut ? StreamReactionsAlignment.end : StreamReactionsAlignment.start);
                          final crossAxis = isOut ? CrossAxisAlignment.end : CrossAxisAlignment.start;

                          return switch (t.type) {
                            StreamReactionsType.segmented => StreamReactions.segmented(
                              items: t.items,
                              position: t.position,
                              alignment: reactionAlignment,
                              crossAxisAlignment: crossAxis,
                              max: t.max,
                              overlap: t.overlap,
                              child: bubble,
                              onPressed: () {},
                            ),
                            StreamReactionsType.clustered => StreamReactions.clustered(
                              items: t.items,
                              position: t.position,
                              alignment: reactionAlignment,
                              crossAxisAlignment: crossAxis,
                              max: t.max,
                              overlap: t.overlap,
                              child: bubble,
                              onPressed: () {},
                            ),
                          };
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
  incoming,
  outgoing
  ;

  bool get isOutgoing => this == outgoing;
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
