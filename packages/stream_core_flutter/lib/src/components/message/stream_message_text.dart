// ignore: migrate_design_widgets
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:material_ui/material_ui.dart';
import 'package:stream_core/stream_core.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_message_item_theme.dart';
import '../../theme/components/stream_message_style_property.dart';
import '../../theme/components/stream_message_text_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../accessories/stream_emoji.dart';
import '../message_layout/stream_message_layout.dart';

/// The default protocol prefix used to identify mention links.
///
/// Links with this scheme (e.g., `[text](mention:id)`) are treated as
/// mentions rather than regular links. A mention type qualifier can follow
/// the scheme to distinguish kinds, e.g. `[text](mention-role:id)`. Bare
/// `mention:` is treated as a user mention.
const kStreamMentionScheme = 'mention';

/// The mention kind carried by a mention link.
///
/// Encoded as the optional suffix on the mention URL scheme: `mention-user:`,
/// `mention-channel:`, `mention-here:`, `mention-role:`, `mention-group:`. A
/// bare `mention:` scheme resolves to [user].
///
/// Defined as a Dart extension type over [String] so the same value flows
/// through the markdown URL, the [md.Element] attribute, and callbacks
/// without wrapper allocations. The set is closed — only the five constants
/// declared on this type are recognised by the markdown mention parser.
extension type const StreamMentionType(String _) implements String {
  /// A mention referencing a single user.
  static const user = StreamMentionType('user');

  /// A channel-wide broadcast mention, e.g. `@channel`.
  static const channel = StreamMentionType('channel');

  /// A broadcast mention targeting online channel members, e.g. `@here`.
  static const here = StreamMentionType('here');

  /// A mention referencing a role, e.g. `@admin`.
  static const role = StreamMentionType('role');

  /// A mention referencing a named group of users.
  static const group = StreamMentionType('group');
}

/// Callback fired when a user-type mention link is tapped.
///
/// [displayText] is the raw display text from the link
/// (e.g., `'@Alice'` from `[@Alice](mention:user123)`).
/// [id] is the mention identifier (the URL-decoded portion after the
/// `mention:` scheme).
///
/// Only invoked for user-type mentions. To handle the full set of mention
/// kinds (channel / here / role / group) in a single callback, use
/// [MarkdownTapAnyMentionCallback].
typedef MarkdownTapMentionCallback = void Function(String displayText, String id);

/// Callback fired when any mention link is tapped.
///
/// [displayText] is the raw display text from the link.
/// [type] is the mention kind decoded from the URL scheme.
/// [id] is the URL-decoded payload following the scheme.
typedef MarkdownTapAnyMentionCallback =
    void Function(
      String displayText,
      StreamMentionType type,
      String id,
    );

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
    MarkdownTapAnyMentionCallback? onTapAnyMention,
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
         onTapAnyMention: onTapAnyMention,
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
  /// Useful for determining jumbomoji rendering such as larger font sizes
  /// or hiding the message bubble.
  ///
  /// ```dart
  /// StreamMessageText.emojiCount('🚀')        // 1
  /// StreamMessageText.emojiCount('👍🔥')      // 2
  /// StreamMessageText.emojiCount('❤️🎉😍')    // 3
  /// StreamMessageText.emojiCount('🎉🎉🎉🎉')  // 4
  /// StreamMessageText.emojiCount('Hello 👋')   // null (mixed)
  /// StreamMessageText.emojiCount('👨‍👩‍👧')       // 1 (ZWJ family)
  /// StreamMessageText.emojiCount('🇺🇸')       // 1 (flag)
  /// StreamMessageText.emojiCount('👍🏽')       // 1 (skin tone)
  /// ```
  static int? emojiCount(String? text) {
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
    this.onTapAnyMention,
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

  /// Called when a user-type mention is tapped.
  ///
  /// Mentions use the `[text](mention:id)` format. Only invoked for user
  /// mentions; to handle every mention kind in a single callback, prefer
  /// [onTapAnyMention] instead.
  ///
  /// When both callbacks are provided, [onTapAnyMention] takes precedence
  /// and this callback is not invoked.
  final MarkdownTapMentionCallback? onTapMention;

  /// Called when a mention of any kind is tapped.
  ///
  /// Receives the [StreamMentionType] decoded from the URL scheme along with the
  /// display text and the URL-decoded id payload. Takes precedence over
  /// [onTapMention] when both are set.
  final MarkdownTapAnyMentionCallback? onTapAnyMention;

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

    final mentionStyles = _resolveMentionStyles(resolve);

    final contentType = layout.contentKind;
    final emojiCount = StreamMessageText.emojiCount(props.text);
    if (emojiCount case final count? when contentType == .jumbomoji) {
      final emojiStyle = switch (count) {
        1 => resolve((s) => s?.singleEmojiStyle),
        2 => resolve((s) => s?.doubleEmojiStyle),
        3 => resolve((s) => s?.tripleEmojiStyle),
        _ => null, // No emoji style (Fallback to regular style)
      };

      effectiveTextStyle = effectiveTextStyle.merge(emojiStyle);
    }

    // Prepend mention syntax so `[text](mention[-type]:id)` is intercepted
    // before the standard LinkSyntax, producing `mention` elements.
    // Regular `a` elements are never touched.
    final effectiveInlineSyntaxes = [
      _StreamMentionSyntax(),
      ...?props.inlineSyntaxes,
    ];

    // Base mention style — variant-specific overrides from [mentionStyles]
    // are merged on top of this in [_StreamMentionBuilder].
    final baseMentionStyle = resolve((s) => s?.mentionStyle).copyWith(
      color: resolve((s) => s?.mentionColor),
      backgroundColor: resolve((s) => s?.mentionBackgroundColor),
    );

    final effectiveBuilders = {
      kStreamMentionScheme: _StreamMentionBuilder(
        stylesByType: mentionStyles,
        fallbackStyle: baseMentionStyle,
        onTap: props.onTapMention,
        onTapAny: props.onTapAnyMention,
      ),
      ...?props.builders,
    };

    // `flutter_markdown_plus` is still built on Flutter's Material, whose
    // `ThemeData` and `MaterialLocalizations` are unrelated types to
    // `material_ui`'s. The bridge maps the ambient theme into that universe so
    // the style sheet, and everything `MarkdownBody` builds, resolve.
    //
    // TODO(material-ui): drop once flutter_markdown_plus supports material_ui.
    // https://linear.app/stream/issue/flu-701
    return Padding(
      padding: effectivePadding,
      // ignore: deprecated_member_use
      child: MaterialUiCompatibilityBridge(
        child: Builder(
          builder: (context) {
            // The bridge maps the colour scheme and text theme but not the
            // legacy-only scalars, and `fromTheme` reads all four.
            final theme = Theme.of(context);

            final markdownTheme = legacy.Theme.of(context).let(
              (it) => it.copyWith(
                primaryColor: theme.primaryColor,
                cardColor: theme.cardColor,
                dividerColor: theme.dividerColor,
                cardTheme: legacy.CardThemeData(color: theme.cardTheme.color),
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
              markdownTheme,
            ).copyWith(p: effectiveTextStyle, a: effectiveLinkStyle).merge(props.styleSheet);

            return MarkdownBody(
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
            );
          },
        ),
      ),
    );
  }

  // Resolves one text style per mention kind. Each variant-specific lookup
  // falls back to the corresponding base property — [mentionStyle],
  // [mentionColor], [mentionBackgroundColor] — so the entry is always
  // fully populated.
  Map<StreamMentionType, TextStyle> _resolveMentionStyles(
    StreamMessageLayoutResolver<StreamMessageTextStyle> resolve,
  ) {
    TextStyle styleFor(StreamMentionType type) {
      // Per the chat design system, `@channel` and `@here` share the
      // `mention-broadcast` styling.
      final variantStyle =
          switch (type) {
            .channel || .here => resolve.maybeResolve((s) => s?.mentionBroadcastStyle),
            .role => resolve.maybeResolve((s) => s?.mentionRoleStyle),
            .group => resolve.maybeResolve((s) => s?.mentionGroupStyle),
            .user => resolve.maybeResolve((s) => s?.mentionUserStyle),
            _ => null,
          } ??
          resolve((s) => s?.mentionStyle);

      final variantColor =
          switch (type) {
            .channel || .here => resolve.maybeResolve((s) => s?.mentionBroadcastColor),
            .role => resolve.maybeResolve((s) => s?.mentionRoleColor),
            .group => resolve.maybeResolve((s) => s?.mentionGroupColor),
            .user => resolve.maybeResolve((s) => s?.mentionUserColor),
            _ => null,
          } ??
          resolve((s) => s?.mentionColor);

      final variantBg =
          switch (type) {
            .channel || .here => resolve.maybeResolve((s) => s?.mentionBroadcastBackgroundColor),
            .role => resolve.maybeResolve((s) => s?.mentionRoleBackgroundColor),
            .group => resolve.maybeResolve((s) => s?.mentionGroupBackgroundColor),
            .user => resolve.maybeResolve((s) => s?.mentionUserBackgroundColor),
            _ => null,
          } ??
          resolve((s) => s?.mentionBackgroundColor);

      return variantStyle.copyWith(
        color: variantColor,
        backgroundColor: variantBg,
      );
    }

    return {
      for (final type in const [
        StreamMentionType.channel,
        StreamMentionType.here,
        StreamMentionType.role,
        StreamMentionType.group,
        StreamMentionType.user,
      ])
        type: styleFor(type),
    };
  }
}

// Intercepts `[text](mention[-type]:id)` patterns before the standard link
// parser, emitting a `mention` element instead of a regular link.
//
// Given `[@Alice](mention:user123)` or `[@admin](mention-role:admin)`:
//
//  * Emits a `mention` element with text content `@Alice` / `@admin`.
//  * Stores the URL-decoded id (`user123` / `admin`) in the `id` attribute.
//  * Stores the captured type (`user` / `channel` / `here` / `role` / `group`)
//    in the `type` attribute. Bare `mention:` (no suffix) resolves to `user`.
//  * Regular links are never touched.
class _StreamMentionSyntax extends md.InlineSyntax {
  _StreamMentionSyntax({
    String scheme = kStreamMentionScheme,
  }) : super(
         '\\[([^\\]\\n]+)\\]\\(${RegExp.escape(scheme)}(?:-(user|channel|here|role|group))?:([^)\\s]+)\\)',
       );

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final displayText = match.group(1)!;
    final type = match.group(2) ?? StreamMentionType.user;
    final rawId = match.group(3)!;

    final el = md.Element.text('mention', displayText);
    el.attributes['id'] = Uri.decodeComponent(rawId);
    el.attributes['type'] = type;
    parser.addNode(el);
    return true;
  }
}

// Renders `mention` elements as tappable styled text with pointer cursor.
//
// Per-element style resolution: reads the `type` attribute set by
// [_StreamMentionSyntax] and merges any variant-specific overrides from
// [stylesByType] on top of [fallbackStyle], which carries the base mention
// style. Variants without overrides fall through to [fallbackStyle] alone.
//
// Tap dispatch: [onTapAny] takes precedence and receives the [MentionType].
// When [onTapAny] is null, the legacy [onTap] fires only for user mentions so
// existing customer code never sees a non-user payload.
class _StreamMentionBuilder extends MarkdownElementBuilder {
  _StreamMentionBuilder({
    required this.stylesByType,
    required this.fallbackStyle,
    this.onTap,
    this.onTapAny,
  });

  final Map<StreamMentionType, TextStyle> stylesByType;
  final TextStyle fallbackStyle;
  final MarkdownTapMentionCallback? onTap;
  final MarkdownTapAnyMentionCallback? onTapAny;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final displayText = element.textContent;
    final id = element.attributes['id'] ?? '';
    final type = StreamMentionType(
      element.attributes['type'] ?? StreamMentionType.user,
    );
    final style = fallbackStyle.merge(stylesByType[type]);

    final VoidCallback? handleTap;
    if (onTapAny case final onTapAny?) {
      handleTap = () => onTapAny(displayText, type, id);
    } else if (onTap case final onTap? when type == StreamMentionType.user) {
      handleTap = () => onTap(displayText, id);
    } else {
      handleTap = null;
    }

    return MouseRegion(
      cursor: handleTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: handleTap,
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
      .jumbomoji => EdgeInsets.zero,
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
  StreamMessageLayoutProperty<Color> get mentionBackgroundColor => .all(StreamColors.transparent);

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
