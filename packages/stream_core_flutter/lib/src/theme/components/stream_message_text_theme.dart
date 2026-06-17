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
    this.mentionBackgroundColor,
    this.mentionBroadcastStyle,
    this.mentionBroadcastColor,
    this.mentionBroadcastBackgroundColor,
    this.mentionRoleStyle,
    this.mentionRoleColor,
    this.mentionRoleBackgroundColor,
    this.mentionGroupStyle,
    this.mentionGroupColor,
    this.mentionGroupBackgroundColor,
    this.mentionUserStyle,
    this.mentionUserColor,
    this.mentionUserBackgroundColor,
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
    Color? mentionBackgroundColor,
    TextStyle? mentionBroadcastStyle,
    Color? mentionBroadcastColor,
    Color? mentionBroadcastBackgroundColor,
    TextStyle? mentionRoleStyle,
    Color? mentionRoleColor,
    Color? mentionRoleBackgroundColor,
    TextStyle? mentionGroupStyle,
    Color? mentionGroupColor,
    Color? mentionGroupBackgroundColor,
    TextStyle? mentionUserStyle,
    Color? mentionUserColor,
    Color? mentionUserBackgroundColor,
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
      mentionBackgroundColor: mentionBackgroundColor?.let(StreamMessageLayoutProperty.all),
      mentionBroadcastStyle: mentionBroadcastStyle?.let(StreamMessageLayoutProperty.all),
      mentionBroadcastColor: mentionBroadcastColor?.let(StreamMessageLayoutProperty.all),
      mentionBroadcastBackgroundColor: mentionBroadcastBackgroundColor?.let(StreamMessageLayoutProperty.all),
      mentionRoleStyle: mentionRoleStyle?.let(StreamMessageLayoutProperty.all),
      mentionRoleColor: mentionRoleColor?.let(StreamMessageLayoutProperty.all),
      mentionRoleBackgroundColor: mentionRoleBackgroundColor?.let(StreamMessageLayoutProperty.all),
      mentionGroupStyle: mentionGroupStyle?.let(StreamMessageLayoutProperty.all),
      mentionGroupColor: mentionGroupColor?.let(StreamMessageLayoutProperty.all),
      mentionGroupBackgroundColor: mentionGroupBackgroundColor?.let(StreamMessageLayoutProperty.all),
      mentionUserStyle: mentionUserStyle?.let(StreamMessageLayoutProperty.all),
      mentionUserColor: mentionUserColor?.let(StreamMessageLayoutProperty.all),
      mentionUserBackgroundColor: mentionUserBackgroundColor?.let(StreamMessageLayoutProperty.all),
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
  ///
  /// Applies to every mention kind unless a kind-specific style — e.g.
  /// [mentionRoleStyle] — is set.
  final StreamMessageLayoutProperty<TextStyle?>? mentionStyle;

  /// The color for @mention text.
  ///
  /// Applies to every mention kind unless a kind-specific color — e.g.
  /// [mentionRoleColor] — is set.
  final StreamMessageLayoutProperty<Color?>? mentionColor;

  /// The background color for @mention text.
  ///
  /// Applies to every mention kind unless a kind-specific background — e.g.
  /// [mentionRoleBackgroundColor] — is set.
  final StreamMessageLayoutProperty<Color?>? mentionBackgroundColor;

  /// The text style for broadcast mentions (e.g. `@channel`, `@here`).
  ///
  /// When null, falls back to [mentionStyle].
  final StreamMessageLayoutProperty<TextStyle?>? mentionBroadcastStyle;

  /// The color for broadcast mention text (e.g. `@channel`, `@here`).
  ///
  /// When null, falls back to [mentionColor].
  final StreamMessageLayoutProperty<Color?>? mentionBroadcastColor;

  /// The background color for broadcast mention text.
  ///
  /// When null, falls back to [mentionBackgroundColor].
  final StreamMessageLayoutProperty<Color?>? mentionBroadcastBackgroundColor;

  /// The text style for role mentions (e.g. `@admin`).
  ///
  /// When null, falls back to [mentionStyle].
  final StreamMessageLayoutProperty<TextStyle?>? mentionRoleStyle;

  /// The color for role mention text.
  ///
  /// When null, falls back to [mentionColor].
  final StreamMessageLayoutProperty<Color?>? mentionRoleColor;

  /// The background color for role mention text.
  ///
  /// When null, falls back to [mentionBackgroundColor].
  final StreamMessageLayoutProperty<Color?>? mentionRoleBackgroundColor;

  /// The text style for group mentions.
  ///
  /// When null, falls back to [mentionStyle].
  final StreamMessageLayoutProperty<TextStyle?>? mentionGroupStyle;

  /// The color for group mention text.
  ///
  /// When null, falls back to [mentionColor].
  final StreamMessageLayoutProperty<Color?>? mentionGroupColor;

  /// The background color for group mention text.
  ///
  /// When null, falls back to [mentionBackgroundColor].
  final StreamMessageLayoutProperty<Color?>? mentionGroupBackgroundColor;

  /// The text style for user mentions.
  ///
  /// When null, falls back to [mentionStyle].
  final StreamMessageLayoutProperty<TextStyle?>? mentionUserStyle;

  /// The color for user mention text.
  ///
  /// When null, falls back to [mentionColor].
  final StreamMessageLayoutProperty<Color?>? mentionUserColor;

  /// The background color for user mention text.
  ///
  /// When null, falls back to [mentionBackgroundColor].
  final StreamMessageLayoutProperty<Color?>? mentionUserBackgroundColor;

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
