import 'package:flutter/widgets.dart';
import 'package:stream_core/stream_core.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import 'stream_message_style_property.dart';

part 'stream_message_metadata_theme.g.theme.dart';

/// Visual styling properties for a message metadata row.
///
/// Defines the appearance of metadata rows including username, timestamp,
/// edited indicator, status icon, and spacing. All properties use
/// [StreamMessageStyleProperty] for placement-aware resolution.
/// Use [StreamMessageMetadataStyle.from] for uniform values across all
/// placements.
///
/// {@tool snippet}
///
/// Uniform style:
///
/// ```dart
/// StreamMessageMetadataStyle.from(
///   usernameColor: Colors.blue,
///   timestampColor: Colors.grey,
///   spacing: 12,
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Placement-aware style:
///
/// ```dart
/// StreamMessageMetadataStyle(
///   usernameColor: StreamMessageStyleProperty.resolveWith((p) {
///     final isEnd = p.alignment == StreamMessageAlignment.end;
///     return isEnd ? Colors.blue : Colors.grey;
///   }),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageItemThemeData], which wraps this style for theming.
///  * [StreamMessageMetadata], which uses this styling.
@themeGen
@immutable
class StreamMessageMetadataStyle with _$StreamMessageMetadataStyle {
  /// Creates a metadata style with optional resolver-based overrides.
  const StreamMessageMetadataStyle({
    this.usernameTextStyle,
    this.usernameColor,
    this.timestampTextStyle,
    this.timestampColor,
    this.editedTextStyle,
    this.editedColor,
    this.statusColor,
    this.statusIconSize,
    this.spacing,
    this.statusSpacing,
    this.minHeight,
  });

  /// A convenience constructor that constructs a
  /// [StreamMessageMetadataStyle] given simple values.
  ///
  /// All parameters default to null. By default this constructor returns
  /// a [StreamMessageMetadataStyle] that doesn't override anything.
  ///
  /// For example, to override the default username and timestamp colors,
  /// one could write:
  ///
  /// ```dart
  /// StreamMessageMetadataStyle.from(
  ///   usernameColor: Colors.blue,
  ///   timestampColor: Colors.grey,
  /// )
  /// ```
  factory StreamMessageMetadataStyle.from({
    TextStyle? usernameTextStyle,
    Color? usernameColor,
    TextStyle? timestampTextStyle,
    Color? timestampColor,
    TextStyle? editedTextStyle,
    Color? editedColor,
    Color? statusColor,
    double? statusIconSize,
    double? spacing,
    double? statusSpacing,
    double? minHeight,
  }) {
    return StreamMessageMetadataStyle(
      usernameTextStyle: usernameTextStyle?.let(StreamMessageStyleProperty.all),
      usernameColor: usernameColor?.let(StreamMessageStyleProperty.all),
      timestampTextStyle: timestampTextStyle?.let(StreamMessageStyleProperty.all),
      timestampColor: timestampColor?.let(StreamMessageStyleProperty.all),
      editedTextStyle: editedTextStyle?.let(StreamMessageStyleProperty.all),
      editedColor: editedColor?.let(StreamMessageStyleProperty.all),
      statusColor: statusColor?.let(StreamMessageStyleProperty.all),
      statusIconSize: statusIconSize?.let(StreamMessageStyleProperty.all),
      spacing: spacing?.let(StreamMessageStyleProperty.all),
      statusSpacing: statusSpacing?.let(StreamMessageStyleProperty.all),
      minHeight: minHeight?.let(StreamMessageStyleProperty.all),
    );
  }

  /// The text style for the username.
  final StreamMessageStyleProperty<TextStyle?>? usernameTextStyle;

  /// The color for the username text.
  final StreamMessageStyleProperty<Color?>? usernameColor;

  /// The text style for the timestamp.
  final StreamMessageStyleProperty<TextStyle?>? timestampTextStyle;

  /// The color for the timestamp text.
  final StreamMessageStyleProperty<Color?>? timestampColor;

  /// The text style for the edited indicator.
  final StreamMessageStyleProperty<TextStyle?>? editedTextStyle;

  /// The color for the edited indicator text.
  final StreamMessageStyleProperty<Color?>? editedColor;

  /// The color for the status icon.
  final StreamMessageStyleProperty<Color?>? statusColor;

  /// The size for the status icon.
  final StreamMessageStyleProperty<double?>? statusIconSize;

  /// The gap between main elements (username, timestamp group, edited).
  final StreamMessageStyleProperty<double?>? spacing;

  /// The gap between the status icon and the timestamp.
  final StreamMessageStyleProperty<double?>? statusSpacing;

  /// The minimum height of the metadata row.
  final StreamMessageStyleProperty<double?>? minHeight;

  /// Linearly interpolate between two [StreamMessageMetadataStyle] objects.
  static StreamMessageMetadataStyle? lerp(
    StreamMessageMetadataStyle? a,
    StreamMessageMetadataStyle? b,
    double t,
  ) => _$StreamMessageMetadataStyle.lerp(a, b, t);
}
