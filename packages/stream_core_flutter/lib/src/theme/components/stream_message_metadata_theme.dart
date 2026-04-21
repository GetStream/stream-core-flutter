import 'package:flutter/widgets.dart';
import 'package:stream_core/stream_core.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import 'stream_message_style_property.dart';

part 'stream_message_metadata_theme.g.theme.dart';

/// Visual styling properties for a message metadata row.
///
/// Defines the appearance of metadata rows including username, timestamp,
/// edited indicator, status icon, and spacing. All properties use
/// [StreamMessageLayoutProperty] for placement-aware resolution.
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
///   usernameColor: StreamMessageLayoutProperty.resolveWith((p) {
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
    this.statusTextStyle,
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
    TextStyle? statusTextStyle,
    Color? statusColor,
    double? statusIconSize,
    double? spacing,
    double? statusSpacing,
    double? minHeight,
  }) {
    return StreamMessageMetadataStyle(
      usernameTextStyle: usernameTextStyle?.let(StreamMessageLayoutProperty.all),
      usernameColor: usernameColor?.let(StreamMessageLayoutProperty.all),
      timestampTextStyle: timestampTextStyle?.let(StreamMessageLayoutProperty.all),
      timestampColor: timestampColor?.let(StreamMessageLayoutProperty.all),
      editedTextStyle: editedTextStyle?.let(StreamMessageLayoutProperty.all),
      editedColor: editedColor?.let(StreamMessageLayoutProperty.all),
      statusTextStyle: statusTextStyle?.let(StreamMessageLayoutProperty.all),
      statusColor: statusColor?.let(StreamMessageLayoutProperty.all),
      statusIconSize: statusIconSize?.let(StreamMessageLayoutProperty.all),
      spacing: spacing?.let(StreamMessageLayoutProperty.all),
      statusSpacing: statusSpacing?.let(StreamMessageLayoutProperty.all),
      minHeight: minHeight?.let(StreamMessageLayoutProperty.all),
    );
  }

  /// The text style for the username.
  final StreamMessageLayoutProperty<TextStyle?>? usernameTextStyle;

  /// The color for the username text.
  final StreamMessageLayoutProperty<Color?>? usernameColor;

  /// The text style for the timestamp.
  final StreamMessageLayoutProperty<TextStyle?>? timestampTextStyle;

  /// The color for the timestamp text.
  final StreamMessageLayoutProperty<Color?>? timestampColor;

  /// The text style for the edited indicator.
  final StreamMessageLayoutProperty<TextStyle?>? editedTextStyle;

  /// The color for the edited indicator text.
  final StreamMessageLayoutProperty<Color?>? editedColor;

  /// The text style for the status text.
  final StreamMessageLayoutProperty<TextStyle?>? statusTextStyle;

  /// The color for the status icon or text.
  final StreamMessageLayoutProperty<Color?>? statusColor;

  /// The size for the status icon.
  final StreamMessageLayoutProperty<double?>? statusIconSize;

  /// The gap between main elements (username, timestamp group, edited).
  final StreamMessageLayoutProperty<double?>? spacing;

  /// The gap between the status icon and the timestamp.
  final StreamMessageLayoutProperty<double?>? statusSpacing;

  /// The minimum height of the metadata row.
  final StreamMessageLayoutProperty<double?>? minHeight;

  /// Linearly interpolate between two [StreamMessageMetadataStyle] objects.
  static StreamMessageMetadataStyle? lerp(
    StreamMessageMetadataStyle? a,
    StreamMessageMetadataStyle? b,
    double t,
  ) => _$StreamMessageMetadataStyle.lerp(a, b, t);
}
