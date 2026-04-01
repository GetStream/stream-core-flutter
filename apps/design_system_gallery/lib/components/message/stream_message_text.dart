import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageText,
  path: '[Components]/Message',
)
Widget buildStreamMessageTextPlayground(BuildContext context) {
  // -- Widget props -----------------------------------------------------------

  final selectable = context.knobs.boolean(
    label: 'Selectable',
    description: 'Whether text can be selected.',
  );

  final softLineBreak = context.knobs.boolean(
    label: 'Soft Line Break',
    description: 'Treat single newlines as hard line breaks.',
  );

  final fitContent = context.knobs.boolean(
    label: 'Fit Content',
    initialValue: true,
    description: 'Size to fit content vs expand to parent.',
  );

  // -- Theme props ------------------------------------------------------------

  final textColor = context.knobs.object.dropdown<_ColorOption>(
    label: 'Text Color',
    options: _ColorOption.values,
    labelBuilder: (v) => v.label,
    description: 'Override paragraph text color.',
  );

  final linkColor = context.knobs.object.dropdown<_ColorOption>(
    label: 'Link Color',
    options: _ColorOption.values,
    labelBuilder: (v) => v.label,
    description: 'Override link color.',
  );

  final mentionColor = context.knobs.object.dropdown<_ColorOption>(
    label: 'Mention Color',
    options: _ColorOption.values,
    labelBuilder: (v) => v.label,
    description: 'Override mention color.',
  );

  final style = StreamMessageTextStyle.from(
    textColor: textColor.color,
    linkColor: linkColor.color,
    mentionColor: mentionColor.color,
  );

  return StreamMessageItemTheme(
    data: StreamMessageItemThemeData(text: style),
    child: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        for (final msg in _conversationMessages)
          _ConversationMessage(
            message: msg,
            selectable: selectable,
            softLineBreak: softLineBreak,
            fitContent: fitContent,
          ),
      ],
    ),
  );
}

enum _ColorOption {
  none('Default', null),
  purple('Purple', Colors.purple),
  red('Red', Colors.red),
  green('Green', Colors.green),
  orange('Orange', Colors.orange),
  teal('Teal', Colors.teal)
  ;

  const _ColorOption(this.label, this.color);
  final String label;
  final Color? color;
}

// =============================================================================
// Playground Helpers
// =============================================================================

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.alignment,
    required this.stackPosition,
  });

  final String text;
  final StreamMessageAlignment alignment;
  final StreamMessageStackPosition stackPosition;
}

const _conversationMessages = [
  _ChatMessage(
    text: 'Hey [@Sarah](mention:sarah42), tried the new update?',
    alignment: StreamMessageAlignment.start,
    stackPosition: StreamMessageStackPosition.single,
  ),
  _ChatMessage(
    text: 'Not yet! Got a [link](https://flutter.dev)?',
    alignment: StreamMessageAlignment.end,
    stackPosition: StreamMessageStackPosition.single,
  ),
  _ChatMessage(
    text: 'The `Impeller` improvements are **amazing**',
    alignment: StreamMessageAlignment.start,
    stackPosition: StreamMessageStackPosition.top,
  ),
  _ChatMessage(
    text: 'Jank is _basically_ gone',
    alignment: StreamMessageAlignment.start,
    stackPosition: StreamMessageStackPosition.bottom,
  ),
  _ChatMessage(
    text: '\u{1F44D}\u{1F525}',
    alignment: StreamMessageAlignment.end,
    stackPosition: StreamMessageStackPosition.single,
  ),
  _ChatMessage(
    text:
        '[@Mike](mention:mike789) asked about that pattern:\n\n'
        '```dart\nvoid debounce(Duration d, VoidCallback fn) {\n'
        '  Timer(d, fn);\n}\n```',
    alignment: StreamMessageAlignment.start,
    stackPosition: StreamMessageStackPosition.single,
  ),
  _ChatMessage(
    text: 'Clean! Will add it to shared utils',
    alignment: StreamMessageAlignment.end,
    stackPosition: StreamMessageStackPosition.single,
  ),
  _ChatMessage(
    text: '> Always call `dispose()` to avoid leaks',
    alignment: StreamMessageAlignment.start,
    stackPosition: StreamMessageStackPosition.single,
  ),
  _ChatMessage(
    text: '\u{1F680}',
    alignment: StreamMessageAlignment.end,
    stackPosition: StreamMessageStackPosition.single,
  ),
  _ChatMessage(
    text: 'Already done! Check [the PR](https://github.com/example/pr/42)',
    alignment: StreamMessageAlignment.start,
    stackPosition: StreamMessageStackPosition.single,
  ),
  _ChatMessage(
    text: 'LGTM, merging now',
    alignment: StreamMessageAlignment.end,
    stackPosition: StreamMessageStackPosition.single,
  ),
  _ChatMessage(
    text: 'Btw [@Alice](mention:alice456) left a comment',
    alignment: StreamMessageAlignment.start,
    stackPosition: StreamMessageStackPosition.top,
  ),
  _ChatMessage(
    text: 'Something about **null safety** migration',
    alignment: StreamMessageAlignment.start,
    stackPosition: StreamMessageStackPosition.bottom,
  ),
  _ChatMessage(
    text: '\u{2764}\u{FE0F}\u{1F389}\u{1F60D}',
    alignment: StreamMessageAlignment.end,
    stackPosition: StreamMessageStackPosition.single,
  ),
  _ChatMessage(
    text: "I'll take a look after lunch",
    alignment: StreamMessageAlignment.start,
    stackPosition: StreamMessageStackPosition.top,
  ),
  _ChatMessage(
    text: '\u{1F60E}\u{1F44D}\u{1F525}\u{2764}\u{FE0F}\u{1F389}',
    alignment: StreamMessageAlignment.start,
    stackPosition: StreamMessageStackPosition.bottom,
  ),
  _ChatMessage(
    text: 'That deserves a \u{1F680}!',
    alignment: StreamMessageAlignment.end,
    stackPosition: StreamMessageStackPosition.single,
  ),
];

class _ConversationMessage extends StatelessWidget {
  const _ConversationMessage({
    required this.message,
    required this.selectable,
    required this.softLineBreak,
    required this.fitContent,
  });

  final _ChatMessage message;
  final bool selectable;
  final bool softLineBreak;
  final bool fitContent;

  @override
  Widget build(BuildContext context) {
    final isEnd = message.alignment == StreamMessageAlignment.end;
    final layout = StreamMessageLayoutData(
      alignment: message.alignment,
      stackPosition: message.stackPosition,
    );

    final showGap =
        message.stackPosition == StreamMessageStackPosition.single ||
        message.stackPosition == StreamMessageStackPosition.top;

    return Padding(
      padding: EdgeInsets.only(top: showGap ? 12 : 2),
      child: Align(
        alignment: isEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          child: StreamMessageLayout(
            data: layout,
            child: Builder(
              builder: (context) {
                final emojiCount = StreamMessageText.emojiOnlyCount(message.text);
                final hideBubble = emojiCount != null && emojiCount <= 3;

                Widget text = StreamMessageText(
                  message.text,
                  selectable: selectable,
                  softLineBreak: softLineBreak,
                  fitContent: fitContent,
                  onTapLink: (_, href, _) => _showSnack(context, 'Link: $href'),
                  onTapMention: (displayText, id) => _showSnack(context, 'Mention: $displayText (id: $id)'),
                );

                if (!hideBubble) {
                  text = StreamMessageBubble(child: text);
                }

                return text;
              },
            ),
          ),
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
  type: StreamMessageText,
  path: '[Components]/Message',
)
Widget buildStreamMessageTextShowcase(BuildContext context) {
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
          _MarkdownFeaturesSection(),
          _EmojiSection(),
          _ThemeOverridesSection(),
          _RealWorldSection(),
          _ExtensibilitySection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Showcase Sections
// =============================================================================

class _MarkdownFeaturesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'MARKDOWN FEATURES',
      description: 'Core markdown rendering capabilities.',
      children: [
        _ExampleCard(
          label: 'Inline formatting',
          subtitle: 'Bold, italic, strikethrough, code.',
          child: StreamMessageText(
            '**Bold**, _italic_, ~~strikethrough~~, and `inline code`.',
          ),
        ),
        _ExampleCard(
          label: 'Links',
          subtitle: 'Clickable hyperlinks.',
          child: Builder(
            builder: (context) => StreamMessageText(
              'Visit [Flutter](https://flutter.dev) or [Dart](https://dart.dev).',
              onTapLink: (_, href, _) => _showSnack(context, 'Link: $href'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Mentions',
          subtitle: 'Styled mention links using the mention: protocol.',
          child: Builder(
            builder: (context) => StreamMessageText(
              'Hey [@Alice](mention:alice123), have you seen '
              "[@Bob's update](mention:bob456)?",
              onTapMention: (displayText, id) => _showSnack(context, 'Mention: $displayText (id: $id)'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Headings',
          subtitle: 'H1 through H6.',
          child: StreamMessageText(
            '# Heading 1\n## Heading 2\n### Heading 3\n'
            '#### Heading 4\n##### Heading 5\n###### Heading 6',
          ),
        ),
        _ExampleCard(
          label: 'Lists',
          subtitle: 'Ordered and unordered.',
          child: StreamMessageText(
            '- First item\n- Second item\n  - Nested item\n\n'
            '1. Step one\n2. Step two\n3. Step three',
          ),
        ),
        _ExampleCard(
          label: 'Blockquote',
          subtitle: 'Quoted text with left border.',
          child: StreamMessageText(
            '> The best way to predict the future\n'
            '> is to invent it.\n\n— Alan Kay',
          ),
        ),
        _ExampleCard(
          label: 'Code block',
          subtitle: 'Fenced code with decoration.',
          child: StreamMessageText(
            "```dart\nvoid main() {\n  print('Hello, world!');\n}\n```",
          ),
        ),
        _ExampleCard(
          label: 'Table',
          subtitle: 'Bordered data table.',
          child: StreamMessageText(
            '| Feature | Status |\n|---------|--------|\n'
            '| Markdown | Done |\n| Theming | Done |\n| Tests | Pending |',
          ),
        ),
        _ExampleCard(
          label: 'Horizontal rule',
          child: StreamMessageText('Above the line\n\n---\n\nBelow the line'),
        ),
      ],
    );
  }
}

class _EmojiSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'EMOJI-ONLY MESSAGES',
      description:
          'Messages containing only emojis render at larger sizes '
          'without a bubble. Size scales by emoji count.',
      children: [
        _ExampleCard(
          label: '1 emoji — xxl (${StreamEmojiSize.xxl.value.toInt()}px)',
          child: StreamMessageText('\u{1F680}'),
        ),
        _ExampleCard(
          label: '2 emojis — xl (${StreamEmojiSize.xl.value.toInt()}px)',
          child: StreamMessageText('\u{1F44D}\u{1F525}'),
        ),
        _ExampleCard(
          label: '3 emojis — lg (${StreamEmojiSize.lg.value.toInt()}px)',
          child: StreamMessageText('\u{2764}\u{FE0F}\u{1F389}\u{1F60D}'),
        ),
        _ExampleCard(
          label: '4+ emojis — regular size',
          child: StreamMessageBubble(
            child: StreamMessageText(
              '\u{1F60E}\u{1F44D}\u{1F525}\u{2764}\u{FE0F}\u{1F389}',
            ),
          ),
        ),
        _ExampleCard(
          label: 'ZWJ family (1 grapheme)',
          child: StreamMessageText('\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}'),
        ),
        _ExampleCard(
          label: 'Flag (1 grapheme)',
          child: StreamMessageText('\u{1F1FA}\u{1F1F8}'),
        ),
        _ExampleCard(
          label: 'Skin tone (1 grapheme)',
          child: StreamMessageText('\u{1F44D}\u{1F3FD}'),
        ),
        _ExampleCard(
          label: 'Mixed text + emoji — regular',
          child: StreamMessageBubble(
            child: StreamMessageText('Great job \u{1F44D}'),
          ),
        ),
      ],
    );
  }
}

class _ThemeOverridesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    return _Section(
      label: 'THEME OVERRIDES',
      description: 'Per-instance and placement-aware style overrides.',
      children: [
        _ExampleCard(
          label: 'Custom text color',
          subtitle: 'Purple text via style override.',
          child: StreamMessageText(
            'This text is purple via a style override.',
            style: StreamMessageTextStyle.from(textColor: Colors.purple),
          ),
        ),
        _ExampleCard(
          label: 'Custom code block',
          subtitle: 'Dark background with green monospace text via styleSheet.',
          child: StreamMessageText(
            '```\nconst greeting = "Hello!";\nconsole.log(greeting);\n```',
            styleSheet: MarkdownStyleSheet(
              codeblockDecoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              code: const TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFF4EC9B0),
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Custom blockquote',
          subtitle: 'Brand-colored left border via styleSheet.',
          child: StreamMessageText(
            '> Design is not just what it looks like\n> and feels like.\n'
            '> Design is how it works.\n\n— Steve Jobs',
            styleSheet: MarkdownStyleSheet(
              blockquoteDecoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: colorScheme.accentPrimary, width: 4),
                ),
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Placement-aware styling',
          subtitle: 'Different text colors for start vs end alignment.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              StreamMessageLayout(
                data: const StreamMessageLayoutData(),
                child: StreamMessageItemTheme(
                  data: StreamMessageItemThemeData(
                    text: StreamMessageTextStyle(
                      textColor: StreamMessageLayoutProperty.resolveWith((p) {
                        return p.alignment == StreamMessageAlignment.end ? Colors.white : Colors.black87;
                      }),
                    ),
                  ),
                  child: StreamMessageBubble(
                    child: StreamMessageText('Start-aligned message (dark text)'),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: StreamMessageLayout(
                  data: const StreamMessageLayoutData(alignment: StreamMessageAlignment.end),
                  child: StreamMessageItemTheme(
                    data: StreamMessageItemThemeData(
                      text: StreamMessageTextStyle(
                        textColor: StreamMessageLayoutProperty.resolveWith((p) {
                          return p.alignment == StreamMessageAlignment.end ? Colors.white : Colors.black87;
                        }),
                      ),
                    ),
                    child: StreamMessageBubble(
                      child: StreamMessageText('End-aligned message (white text)'),
                    ),
                  ),
                ),
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
    return _Section(
      label: 'REAL-WORLD COMPOSITIONS',
      description:
          'Message text inside full message layouts with bubbles, '
          'metadata, annotations, replies, and reactions.',
      children: [
        _ExampleCard(
          label: 'Chat message with mention',
          subtitle: 'Text in bubble with a mention and metadata.',
          child: Builder(
            builder: (context) => StreamMessageContent(
              footer: StreamMessageMetadata(
                timestamp: const Text('09:41'),
              ),
              child: StreamMessageBubble(
                child: StreamMessageText(
                  'Hey [@Sarah](mention:sarah42), have you tried the '
                  '**new Flutter update**? The performance '
                  'improvements are _amazing_!',
                  onTapMention: (displayText, id) => _showSnack(context, 'Mention: $displayText (id: $id)'),
                ),
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'AI response',
          subtitle: 'Rich markdown with code in bubble.',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('09:43'),
            ),
            child: StreamMessageBubble(
              child: StreamMessageText(
                '## Quick Sort in Dart\n\n'
                "Here's an efficient implementation:\n\n"
                '```dart\n'
                'List<int> quickSort(List<int> list) {\n'
                '  if (list.length <= 1) return list;\n'
                '  final pivot = list[list.length ~/ 2];\n'
                '  final less = list.where((e) => e < pivot).toList();\n'
                '  final equal = list.where((e) => e == pivot).toList();\n'
                '  final greater = list.where((e) => e > pivot).toList();\n'
                '  return [...quickSort(less), ...equal, ...quickSort(greater)];\n'
                '}\n'
                '```\n\n'
                'The time complexity is **O(n log n)** on average.',
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Pinned message with replies',
          subtitle: 'Annotation, bubble, metadata, and reply indicator.',
          child: StreamMessageContent(
            header: StreamMessageAnnotation(
              leading: Icon(context.streamIcons.pin),
              label: const Text('Pinned by Alice'),
            ),
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamMessageMetadata(
                  timestamp: const Text('08:30'),
                ),
                StreamMessageReplies(
                  label: const Text('4 replies'),
                ),
              ],
            ),
            child: StreamMessageBubble(
              child: StreamMessageText(
                'Meeting agenda:\n\n'
                '1. **Sprint review** — demo the new features\n'
                '2. **Retro** — what went well / what to improve\n'
                '3. **Planning** — next sprint priorities\n\n'
                '> Please come prepared with your updates.',
              ),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Message with reactions',
          subtitle: 'Bubble with markdown text and reaction chips.',
          child: StreamMessageContent(
            footer: StreamMessageMetadata(
              timestamp: const Text('10:15'),
            ),
            child: StreamReactions.segmented(
              items: const [
                StreamReactionsItem(emoji: StreamUnicodeEmoji('\u{1F680}'), count: 5),
                StreamReactionsItem(emoji: StreamUnicodeEmoji('\u{1F44D}'), count: 3),
                StreamReactionsItem(emoji: StreamUnicodeEmoji('\u{2764}\u{FE0F}'), count: 2),
              ],
              child: StreamMessageBubble(
                child: StreamMessageText(
                  'Just shipped the new **markdown component**!\n\n'
                  'Features:\n'
                  '- Full GFM support\n'
                  '- Placement-aware theming\n'
                  '- Custom builder extensibility',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExtensibilitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    return _Section(
      label: 'EXTENSIBILITY',
      description:
          'Demonstrates custom builders, syntax highlighting, '
          'link handlers, and image builders.',
      children: [
        _ExampleCard(
          label: 'Custom syntax highlighter',
          subtitle: 'Keyword-aware highlighting via SyntaxHighlighter.',
          child: StreamMessageText(
            '```dart\n'
            "import 'dart:async';\n\n"
            'void main() async {\n'
            '  final stream = Stream.periodic(\n'
            '    const Duration(seconds: 1),\n'
            '    (i) => i,\n'
            '  );\n\n'
            '  await for (final value in stream) {\n'
            '    if (value > 5) break;\n'
            "    print('Tick: \$value');\n"
            '  }\n'
            '}\n'
            '```',
            syntaxHighlighter: _DemoSyntaxHighlighter(colorScheme),
          ),
        ),
        _ExampleCard(
          label: 'Custom code block builder',
          subtitle: 'Code blocks with a copy button and language label.',
          child: StreamMessageText(
            '```dart\n'
            'class Greeting {\n'
            '  final String name;\n'
            '  Greeting(this.name);\n\n'
            "  String say() => 'Hello, \$name!';\n"
            '}\n'
            '```',
            builders: {'pre': _CopyableCodeBlockBuilder(colorScheme)},
          ),
        ),
        _ExampleCard(
          label: 'Custom link handler',
          subtitle: 'Links with a snackbar preview on tap.',
          child: Builder(
            builder: (context) => StreamMessageText(
              'Check out [Flutter docs](https://flutter.dev) '
              'or [Dart packages](https://pub.dev).',
              onTapLink: (_, href, _) => _showSnack(context, 'Link: $href'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Mention handler',
          subtitle: 'Mentions and links with separate tap handling.',
          child: Builder(
            builder: (context) => StreamMessageText(
              '[@Alice](mention:alice123) shared '
              '[this article](https://example.com) with '
              '[@Bob](mention:bob456).',
              onTapMention: (displayText, id) => _showSnack(context, 'Mention: $displayText (id: $id)'),
              onTapLink: (_, href, _) => _showSnack(context, 'Link: $href'),
            ),
          ),
        ),
        _ExampleCard(
          label: 'Custom image builder',
          subtitle: 'Markdown images with rounded corners and placeholder.',
          child: StreamMessageText(
            '![Flutter logo](https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png)',
            imageBuilder: (uri, title, alt) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  uri.toString(),
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => DecoratedBox(
                    decoration: BoxDecoration(color: colorScheme.backgroundSurface),
                    child: SizedBox(
                      width: 200,
                      height: 100,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colorScheme.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _ExampleCard(
          label: 'MarkdownStyleSheet escape hatch',
          subtitle: 'Fine-grained styling via the styleSheet prop.',
          child: StreamMessageText(
            '# Custom heading\n\n'
            'Paragraph with **bold** and a `code span`.\n\n'
            '> A styled blockquote.',
            styleSheet: MarkdownStyleSheet(
              h1: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: colorScheme.accentPrimary,
              ),
              blockquoteDecoration: BoxDecoration(
                color: colorScheme.accentPrimary.withValues(alpha: 0.1),
                border: Border(
                  left: BorderSide(color: colorScheme.accentPrimary, width: 4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Demo Syntax Highlighter
// =============================================================================

class _DemoSyntaxHighlighter extends SyntaxHighlighter {
  _DemoSyntaxHighlighter(this._colorScheme);

  final StreamColorScheme _colorScheme;

  static final _keywords = RegExp(
    r'\b(import|void|main|async|await|for|final|const|if|break|in|return|class|extends|with|mixin|enum|switch|case|default|try|catch|throw|new|this|super)\b',
  );
  static final _strings = RegExp("'[^']*'");
  static final _comments = RegExp(r'//.*$', multiLine: true);
  static final _types = RegExp(
    r'\b(String|int|double|bool|List|Map|Set|Future|Stream|Duration|void|dynamic|var|Object)\b',
  );

  @override
  TextSpan format(String source) {
    final spans = <TextSpan>[];
    final matches = <_SyntaxMatch>[];

    for (final m in _comments.allMatches(source)) {
      matches.add(_SyntaxMatch(m.start, m.end, _MatchType.comment));
    }
    for (final m in _strings.allMatches(source)) {
      matches.add(_SyntaxMatch(m.start, m.end, _MatchType.string));
    }
    for (final m in _keywords.allMatches(source)) {
      if (!matches.any((s) => m.start >= s.start && m.start < s.end)) {
        matches.add(_SyntaxMatch(m.start, m.end, _MatchType.keyword));
      }
    }
    for (final m in _types.allMatches(source)) {
      if (!matches.any((s) => m.start >= s.start && m.start < s.end)) {
        matches.add(_SyntaxMatch(m.start, m.end, _MatchType.type));
      }
    }

    matches.sort((a, b) => a.start.compareTo(b.start));

    var lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: source.substring(lastEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: source.substring(match.start, match.end),
          style: _styleFor(match.type),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < source.length) {
      spans.add(TextSpan(text: source.substring(lastEnd)));
    }

    return TextSpan(children: spans);
  }

  TextStyle _styleFor(_MatchType type) => switch (type) {
    _MatchType.keyword => TextStyle(color: _colorScheme.accentPrimary, fontWeight: FontWeight.bold),
    _MatchType.string => TextStyle(color: Colors.green.shade700),
    _MatchType.comment => TextStyle(color: _colorScheme.textTertiary, fontStyle: FontStyle.italic),
    _MatchType.type => TextStyle(color: Colors.teal.shade600),
  };
}

enum _MatchType { keyword, string, comment, type }

class _SyntaxMatch {
  const _SyntaxMatch(this.start, this.end, this.type);
  final int start;
  final int end;
  final _MatchType type;
}

// =============================================================================
// Custom Code Block Builder
// =============================================================================

class _CopyableCodeBlockBuilder extends MarkdownElementBuilder {
  _CopyableCodeBlockBuilder(this._colorScheme);

  final StreamColorScheme _colorScheme;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final code = element.textContent.trimRight();
    final language = element.attributes['class']?.replaceFirst('language-', '') ?? '';

    return _CopyableCodeBlock(
      code: code,
      language: language,
      colorScheme: _colorScheme,
    );
  }
}

class _CopyableCodeBlock extends StatefulWidget {
  const _CopyableCodeBlock({
    required this.code,
    required this.language,
    required this.colorScheme,
  });

  final String code;
  final String language;
  final StreamColorScheme colorScheme;

  @override
  State<_CopyableCodeBlock> createState() => _CopyableCodeBlockState();
}

class _CopyableCodeBlockState extends State<_CopyableCodeBlock> {
  var _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final ts = context.streamTextTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.borderSubtle.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              children: [
                if (widget.language.isNotEmpty)
                  Text(
                    widget.language,
                    style: ts.metadataEmphasis.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: _copy,
                  child: Row(
                    spacing: 4,
                    children: [
                      Icon(
                        _copied ? Icons.check : Icons.copy,
                        size: 14,
                        color: _copied ? cs.accentSuccess : cs.textTertiary,
                      ),
                      Text(
                        _copied ? 'Copied!' : 'Copy',
                        style: ts.metadataDefault.copyWith(
                          color: _copied ? cs.accentSuccess : cs.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              widget.code,
              style: ts.metadataDefault.copyWith(
                fontFamily: 'monospace',
                color: cs.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Helpers
// =============================================================================

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
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
                style: context.streamTextTheme.metadataDefault.copyWith(color: colorScheme.textTertiary),
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
    this.subtitle,
  });

  final String label;
  final String? subtitle;
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                label,
                style: textTheme.metadataEmphasis.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              if (subtitle case final sub?)
                Text(
                  sub,
                  style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary),
                ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
