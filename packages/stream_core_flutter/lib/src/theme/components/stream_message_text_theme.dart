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
///   textColor: StreamMessageStyleProperty.resolveWith((p) {
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
      textStyle: textStyle?.let(StreamMessageStyleProperty.all),
      textColor: textColor?.let(StreamMessageStyleProperty.all),
      linkStyle: linkStyle?.let(StreamMessageStyleProperty.all),
      linkColor: linkColor?.let(StreamMessageStyleProperty.all),
      mentionStyle: mentionStyle?.let(StreamMessageStyleProperty.all),
      mentionColor: mentionColor?.let(StreamMessageStyleProperty.all),
      singleEmojiStyle: singleEmojiStyle?.let(StreamMessageStyleProperty.all),
      doubleEmojiStyle: doubleEmojiStyle?.let(StreamMessageStyleProperty.all),
      tripleEmojiStyle: tripleEmojiStyle?.let(StreamMessageStyleProperty.all),
    );
  }

  /// The base text style for paragraph content.
  final StreamMessageStyleProperty<TextStyle?>? textStyle;

  /// The color for paragraph text.
  final StreamMessageStyleProperty<Color?>? textColor;

  /// The text style for links.
  final StreamMessageStyleProperty<TextStyle?>? linkStyle;

  /// The color for link text.
  final StreamMessageStyleProperty<Color?>? linkColor;

  /// The text style for @mention text.
  final StreamMessageStyleProperty<TextStyle?>? mentionStyle;

  /// The color for @mention text.
  final StreamMessageStyleProperty<Color?>? mentionColor;

  /// The text style for emoji-only messages containing exactly one emoji.
  final StreamMessageStyleProperty<TextStyle?>? singleEmojiStyle;

  /// The text style for emoji-only messages containing exactly two emojis.
  final StreamMessageStyleProperty<TextStyle?>? doubleEmojiStyle;

  /// The text style for emoji-only messages containing exactly three emojis.
  final StreamMessageStyleProperty<TextStyle?>? tripleEmojiStyle;

  /// Linearly interpolate between two [StreamMessageTextStyle] objects.
  static StreamMessageTextStyle? lerp(
    StreamMessageTextStyle? a,
    StreamMessageTextStyle? b,
    double t,
  ) => _$StreamMessageTextStyle.lerp(a, b, t);
}
