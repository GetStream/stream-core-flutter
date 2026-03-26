import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:stream_core/stream_core.dart';

import '../../theme.dart';
import '../accessories/stream_emoji.dart';
import '../message_layout/stream_message_layout.dart';

/// The default protocol prefix used to identify mention links.
///
/// Links with this scheme (e.g., `[text](mention:id)`) are treated as
/// mentions rather than regular links.
const kStreamMentionScheme = 'mention';

/// Callback fired when a mention link is tapped.
///
/// [displayText] is the raw display text from the link
/// (e.g., `'@Alice'` from `[@Alice](mention:user123)`).
/// [id] is the mention identifier (the URL-decoded portion after the
/// `mention:` scheme).
typedef MarkdownTapMentionCallback = void Function(String displayText, String id);

// Matches characters that render as emoji — either those with default emoji
// presentation, or text-default characters forced to emoji via VS16 (U+FE0F).
//
// Uses Unicode property escapes so new emoji are covered automatically when
// Dart's ICU tables update, with no hardcoded code-point ranges to maintain.
final _emojiRegex = RegExp(r'\p{Emoji_Presentation}|\p{Emoji}\uFE0F', unicode: true);

/// Renders markdown text with themed styling.
///
/// {@tool snippet}
///
/// Basic markdown rendering:
///
/// ```dart
/// StreamMessageText('**Hello** _world_')
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With custom code handling and mention support:
///
/// ```dart
/// StreamMessageText(
///   responseMarkdown,
///   syntaxHighlighter: mySyntaxHighlighter,
///   builders: {'pre': MyCodeBlockBuilder()},
///   onTapLink: (text, href, title) => launchUrl(Uri.parse(href ?? '')),
///   onTapMention: (displayText, id) => navigateToProfile(id),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageTextStyle], for customizing text appearance.
///  * [StreamMessageItemTheme], for theming via the widget tree.
///  * [kStreamMentionScheme], the protocol prefix used for mention detection.
class StreamMessageText extends StatelessWidget {
  /// Creates a markdown message text widget.
  StreamMessageText(
    String text, {
    super.key,
    EdgeInsetsGeometry? padding,
    StreamMessageTextStyle? style,
    bool selectable = false,
    MarkdownTapLinkCallback? onTapLink,
    MarkdownTapMentionCallback? onTapMention,
    VoidCallback? onTapText,
    MarkdownImageBuilder? imageBuilder,
    SyntaxHighlighter? syntaxHighlighter,
    Map<String, MarkdownElementBuilder>? builders,
    Map<String, MarkdownPaddingBuilder>? paddingBuilders,
    List<md.BlockSyntax>? blockSyntaxes,
    List<md.InlineSyntax>? inlineSyntaxes,
    md.ExtensionSet? extensionSet,
    bool softLineBreak = false,
    bool fitContent = true,
    MarkdownStyleSheet? styleSheet,
  }) : props = .new(
         text: text,
         padding: padding,
         style: style,
         selectable: selectable,
         onTapLink: onTapLink,
         onTapMention: onTapMention,
         onTapText: onTapText,
         imageBuilder: imageBuilder,
         syntaxHighlighter: syntaxHighlighter,
         builders: builders,
         paddingBuilders: paddingBuilders,
         blockSyntaxes: blockSyntaxes,
         inlineSyntaxes: inlineSyntaxes,
         extensionSet: extensionSet,
         softLineBreak: softLineBreak,
         fitContent: fitContent,
         styleSheet: styleSheet,
       );

  /// The properties that configure this widget.
  final StreamMessageTextProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageText;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageText(props: props);
  }

  /// Returns the number of emoji grapheme clusters if [text] contains only
  /// emojis (ignoring whitespace), or `null` if the text is empty or contains
  /// any non-emoji characters.
  ///
  /// Useful for determining emoji-specific rendering such as larger font sizes
  /// or hiding the message bubble.
  ///
  /// ```dart
  /// StreamMessageText.emojiOnlyCount('🚀')        // 1
  /// StreamMessageText.emojiOnlyCount('👍🔥')      // 2
  /// StreamMessageText.emojiOnlyCount('❤️🎉😍')    // 3
  /// StreamMessageText.emojiOnlyCount('🎉🎉🎉🎉')  // 4
  /// StreamMessageText.emojiOnlyCount('Hello 👋')   // null (mixed)
  /// StreamMessageText.emojiOnlyCount('👨‍👩‍👧')       // 1 (ZWJ family)
  /// StreamMessageText.emojiOnlyCount('🇺🇸')       // 1 (flag)
  /// StreamMessageText.emojiOnlyCount('👍🏽')       // 1 (skin tone)
  /// ```
  static int? emojiOnlyCount(String? text) {
    final trimmed = text?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    final graphemes = trimmed.characters.where((c) => c.trim().isNotEmpty);

    for (final grapheme in graphemes) {
      if (!_emojiRegex.hasMatch(grapheme)) return null;
    }

    return graphemes.length;
  }
}

/// Properties for configuring a [StreamMessageText].
///
/// See also:
///
///  * [StreamMessageText], which uses these properties.
///  * [DefaultStreamMessageText], the default implementation.
@immutable
class StreamMessageTextProps {
  /// Creates properties for a markdown message text widget.
  const StreamMessageTextProps({
    required this.text,
    this.padding,
    this.style,
    this.selectable = false,
    this.onTapLink,
    this.onTapMention,
    this.onTapText,
    this.imageBuilder,
    this.syntaxHighlighter,
    this.builders,
    this.paddingBuilders,
    this.blockSyntaxes,
    this.inlineSyntaxes,
    this.extensionSet,
    this.softLineBreak = false,
    this.fitContent = true,
    this.styleSheet,
  });

  /// The markdown text to render.
  final String text;

  /// Optional padding override for the text content.
  ///
  /// When non-null, takes precedence over the theme-resolved value.
  final EdgeInsetsGeometry? padding;

  /// Optional style overrides for placement-aware styling.
  ///
  /// Fields left null fall back to the inherited [StreamMessageItemTheme],
  /// then to built-in defaults.
  final StreamMessageTextStyle? style;

  /// Whether text is selectable.
  final bool selectable;

  /// Called when a link is tapped.
  final MarkdownTapLinkCallback? onTapLink;

  /// Called when a mention is tapped.
  ///
  /// Mentions use the `[text](mention:id)` format.
  final MarkdownTapMentionCallback? onTapMention;

  /// Called when non-link text is tapped.
  final VoidCallback? onTapText;

  /// Custom image builder.
  final MarkdownImageBuilder? imageBuilder;

  /// Syntax highlighter for code blocks.
  final SyntaxHighlighter? syntaxHighlighter;

  /// Custom element builders keyed by tag name.
  final Map<String, MarkdownElementBuilder>? builders;

  /// Custom padding builders keyed by tag name.
  final Map<String, MarkdownPaddingBuilder>? paddingBuilders;

  /// Additional block-level syntax parsers.
  final List<md.BlockSyntax>? blockSyntaxes;

  /// Additional inline-level syntax parsers.
  final List<md.InlineSyntax>? inlineSyntaxes;

  /// Markdown extension set.
  final md.ExtensionSet? extensionSet;

  /// Whether soft line breaks are treated as hard breaks.
  final bool softLineBreak;

  /// Whether the widget sizes to fit its content.
  final bool fitContent;

  /// Additional style sheet for customising headings, code blocks, tables,
  /// and other markdown styles not exposed in [StreamMessageTextStyle].
  final MarkdownStyleSheet? styleSheet;
}

/// The default implementation of [StreamMessageText].
///
/// See also:
///
///  * [StreamMessageText], the public API widget.
///  * [StreamMessageTextProps], which configures this widget.
class DefaultStreamMessageText extends StatelessWidget {
  /// Creates a default message text widget with the given [props].
  const DefaultStreamMessageText({super.key, required this.props});

  /// The properties that configure this widget.
  final StreamMessageTextProps props;

  @override
  Widget build(BuildContext context) {
    final layout = StreamMessageLayout.of(context);
    final themeStyle = StreamMessageItemTheme.of(context).text;
    final defaults = _StreamMessageTextDefaults(context);

    final resolve = StreamMessageLayoutResolver(layout, [props.style, themeStyle, defaults]);

    final effectivePadding = props.padding ?? resolve((s) => s?.padding);
    final effectiveTextColor = resolve((s) => s?.textColor);
    var effectiveTextStyle = resolve((s) => s?.textStyle).copyWith(color: effectiveTextColor);
    final effectiveLinkColor = resolve((s) => s?.linkColor);
    final effectiveLinkStyle = resolve((s) => s?.linkStyle).copyWith(color: effectiveLinkColor);
    final effectiveMentionColor = resolve((s) => s?.mentionColor);
    final effectiveMentionStyle = resolve((s) => s?.mentionStyle).copyWith(color: effectiveMentionColor);

    final contentType = layout.contentKind;
    final emojiCount = StreamMessageText.emojiOnlyCount(props.text);
    if (emojiCount case final count? when contentType == .emojiOnly) {
      final emojiStyle = switch (count) {
        1 => resolve((s) => s?.singleEmojiStyle),
        2 => resolve((s) => s?.doubleEmojiStyle),
        3 => resolve((s) => s?.tripleEmojiStyle),
        _ => null, // No emoji style (Fallback to regular style)
      };

      effectiveTextStyle = effectiveTextStyle.merge(emojiStyle);
    }

    final streamThemeData = Theme.of(context).let(
      (it) => it.copyWith(
        textTheme: it.textTheme.apply(
          bodyColor: effectiveTextStyle.color,
          decoration: effectiveTextStyle.decoration,
          decorationColor: effectiveTextStyle.decorationColor,
          decorationStyle: effectiveTextStyle.decorationStyle,
          fontFamily: effectiveTextStyle.fontFamily,
          fontFamilyFallback: effectiveTextStyle.fontFamilyFallback,
        ),
      ),
    );

    final markdownSheet = MarkdownStyleSheet.fromTheme(
      streamThemeData, // Apply stream theme data
    ).copyWith(p: effectiveTextStyle, a: effectiveLinkStyle).merge(props.styleSheet);

    // Prepend mention syntax so `[text](mention:id)` is intercepted
    // before the standard LinkSyntax, producing `mention` elements.
    // Regular `a` elements are never touched.
    final mentionStyle = effectiveMentionStyle.copyWith(color: effectiveMentionColor);

    final effectiveInlineSyntaxes = [
      _StreamMentionSyntax(),
      ...?props.inlineSyntaxes,
    ];

    final effectiveBuilders = {
      kStreamMentionScheme: _StreamMentionBuilder(
        style: mentionStyle,
        onTap: props.onTapMention,
      ),
      ...?props.builders,
    };

    return Padding(
      padding: effectivePadding,
      child: MarkdownBody(
        data: props.text,
        selectable: props.selectable,
        styleSheet: markdownSheet,
        styleSheetTheme: .platform,
        syntaxHighlighter: props.syntaxHighlighter,
        onTapLink: props.onTapLink,
        onTapText: props.onTapText,
        imageBuilder: props.imageBuilder,
        builders: effectiveBuilders,
        paddingBuilders: props.paddingBuilders ?? const {},
        blockSyntaxes: props.blockSyntaxes,
        inlineSyntaxes: effectiveInlineSyntaxes,
        extensionSet: props.extensionSet,
        softLineBreak: props.softLineBreak,
        fitContent: props.fitContent,
      ),
    );
  }
}

// Intercepts `[text](mention:id)` patterns before the standard link parser,
// emitting a `mention` element instead of a regular link.
//
// Given `[@Alice](mention:user123)`:
//
//  * Emits a `mention` element with text content `@Alice`.
//  * Stores the URL-decoded id (`user123`) in the `id` attribute.
//  * Regular links are never touched.
class _StreamMentionSyntax extends md.InlineSyntax {
  _StreamMentionSyntax({
    String scheme = kStreamMentionScheme,
  }) : super('\\[([^\\]\\n]+)\\]\\(${RegExp.escape(scheme)}:([^)\\s]+)\\)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final displayText = match.group(1)!;
    final rawId = match.group(2)!;

    final el = md.Element.text('mention', displayText);
    el.attributes['id'] = Uri.decodeComponent(rawId);
    parser.addNode(el);
    return true;
  }
}

// Renders `mention` elements as tappable styled text with pointer cursor.
class _StreamMentionBuilder extends MarkdownElementBuilder {
  _StreamMentionBuilder({required this.style, this.onTap});

  final TextStyle style;
  final MarkdownTapMentionCallback? onTap;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final displayText = element.textContent;
    final id = element.attributes['id'] ?? '';

    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: onTap != null ? () => onTap!(displayText, id) : null,
        child: Text(displayText, style: preferredStyle?.merge(style) ?? style),
      ),
    );
  }
}

// Default values for [StreamMessageTextStyle] backed by stream design tokens.
class _StreamMessageTextDefaults extends StreamMessageTextStyle {
  _StreamMessageTextDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;

  @override
  StreamMessageLayoutProperty<EdgeInsetsGeometry> get padding => .resolveWith(
    (layout) => switch (layout.contentKind) {
      .emojiOnly => EdgeInsets.zero,
      _ => .symmetric(horizontal: _context.streamSpacing.sm),
    },
  );

  @override
  StreamMessageLayoutProperty<TextStyle> get textStyle => .all(_textTheme.bodyDefault);

  @override
  StreamMessageLayoutProperty<Color> get textColor => .resolveWith(
    (layout) => switch (layout.alignment) {
      .start => _colorScheme.textPrimary,
      .end => _colorScheme.brand.shade900,
    },
  );

  @override
  StreamMessageLayoutProperty<TextStyle> get linkStyle => .all(_textTheme.bodyLink);

  @override
  StreamMessageLayoutProperty<Color> get linkColor => .all(_colorScheme.textLink);

  @override
  StreamMessageLayoutProperty<TextStyle> get mentionStyle => .all(_textTheme.bodyLink);

  @override
  StreamMessageLayoutProperty<Color> get mentionColor => .all(_colorScheme.textLink);

  @override
  StreamMessageLayoutProperty<TextStyle> get singleEmojiStyle {
    return .all(.new(fontSize: StreamEmojiSize.xxl.value, height: 1));
  }

  @override
  StreamMessageLayoutProperty<TextStyle> get doubleEmojiStyle {
    return .all(.new(fontSize: StreamEmojiSize.xl.value, height: 1));
  }

  @override
  StreamMessageLayoutProperty<TextStyle> get tripleEmojiStyle {
    return .all(.new(fontSize: StreamEmojiSize.lg.value, height: 1));
  }
}
