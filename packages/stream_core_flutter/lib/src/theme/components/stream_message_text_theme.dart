import 'package:flutter/widgets.dart';
import 'package:stream_core/stream_core.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import 'stream_message_style_property.dart';

part 'stream_message_text_theme.g.theme.dart';

/// Placement-aware styling for markdown message text.
///
/// Controls the appearance of paragraph text, links, and mentions.
/// Use [StreamMessageTextStyle.from] for uniform values across all placements.
///
/// Additional markdown styles (headings, code blocks, blockquotes, tables,
/// layout) can be customised via [StreamMessageTextProps.styleSheet].
///
/// {@tool snippet}
///
/// Uniform style:
///
/// ```dart
/// StreamMessageTextStyle.from(
///   textColor: Colors.black,
///   linkStyle: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Placement-aware style:
///
/// ```dart
/// StreamMessageTextStyle(
///   textColor: StreamMessageLayoutProperty.resolveWith((p) {
///     final isEnd = p.alignment == StreamMessageAlignment.end;
///     return isEnd ? Colors.white : Colors.black;
///   }),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageItemThemeData], which wraps this style for theming.
///  * [StreamMessageText], which uses this styling.
@themeGen
@immutable
class StreamMessageTextStyle with _$StreamMessageTextStyle {
  /// Creates a message text style with optional resolver-based overrides.
  const StreamMessageTextStyle({
    this.padding,
    this.textStyle,
    this.textColor,
    this.linkStyle,
    this.linkColor,
    this.mentionStyle,
    this.mentionColor,
    this.singleEmojiStyle,
    this.doubleEmojiStyle,
    this.tripleEmojiStyle,
  });

  /// A convenience constructor that constructs a [StreamMessageTextStyle]
  /// given simple values.
  ///
  /// All parameters default to null. By default this constructor returns
  /// a [StreamMessageTextStyle] that doesn't override anything.
  ///
  /// For example, to override the default text color and link style, one
  /// could write:
  ///
  /// ```dart
  /// StreamMessageTextStyle.from(
  ///   textColor: Colors.black,
  ///   linkStyle: TextStyle(color: Colors.blue),
  /// )
  /// ```
  factory StreamMessageTextStyle.from({
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Color? textColor,
    TextStyle? linkStyle,
    Color? linkColor,
    TextStyle? mentionStyle,
    Color? mentionColor,
    TextStyle? singleEmojiStyle,
    TextStyle? doubleEmojiStyle,
    TextStyle? tripleEmojiStyle,
  }) {
    return StreamMessageTextStyle(
      padding: padding?.let(StreamMessageLayoutProperty.all),
      textStyle: textStyle?.let(StreamMessageLayoutProperty.all),
      textColor: textColor?.let(StreamMessageLayoutProperty.all),
      linkStyle: linkStyle?.let(StreamMessageLayoutProperty.all),
      linkColor: linkColor?.let(StreamMessageLayoutProperty.all),
      mentionStyle: mentionStyle?.let(StreamMessageLayoutProperty.all),
      mentionColor: mentionColor?.let(StreamMessageLayoutProperty.all),
      singleEmojiStyle: singleEmojiStyle?.let(StreamMessageLayoutProperty.all),
      doubleEmojiStyle: doubleEmojiStyle?.let(StreamMessageLayoutProperty.all),
      tripleEmojiStyle: tripleEmojiStyle?.let(StreamMessageLayoutProperty.all),
    );
  }

  /// The padding around the message text content.
  ///
  /// Useful for mixed-content bubbles where text needs its own inset
  /// independent of the bubble's padding.
  final StreamMessageLayoutProperty<EdgeInsetsGeometry?>? padding;

  /// The base text style for paragraph content.
  final StreamMessageLayoutProperty<TextStyle?>? textStyle;

  /// The color for paragraph text.
  final StreamMessageLayoutProperty<Color?>? textColor;

  /// The text style for links.
  final StreamMessageLayoutProperty<TextStyle?>? linkStyle;

  /// The color for link text.
  final StreamMessageLayoutProperty<Color?>? linkColor;

  /// The text style for @mention text.
  final StreamMessageLayoutProperty<TextStyle?>? mentionStyle;

  /// The color for @mention text.
  final StreamMessageLayoutProperty<Color?>? mentionColor;

  /// The text style for emoji-only messages containing exactly one emoji.
  final StreamMessageLayoutProperty<TextStyle?>? singleEmojiStyle;

  /// The text style for emoji-only messages containing exactly two emojis.
  final StreamMessageLayoutProperty<TextStyle?>? doubleEmojiStyle;

  /// The text style for emoji-only messages containing exactly three emojis.
  final StreamMessageLayoutProperty<TextStyle?>? tripleEmojiStyle;

  /// Linearly interpolate between two [StreamMessageTextStyle] objects.
  static StreamMessageTextStyle? lerp(
    StreamMessageTextStyle? a,
    StreamMessageTextStyle? b,
    double t,
  ) => _$StreamMessageTextStyle.lerp(a, b, t);
}
