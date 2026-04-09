import 'package:flutter/widgets.dart';
import 'package:stream_core/stream_core.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import 'stream_message_style_property.dart';

part 'stream_message_replies_theme.g.theme.dart';

/// Visual styling properties for a message replies row.
///
/// Defines the appearance of replies rows including label, spacing, padding,
/// and connector styling. All properties use [StreamMessageLayoutProperty]
/// for placement-aware resolution. Use [StreamMessageRepliesStyle.from]
/// for uniform values across all placements.
///
/// {@tool snippet}
///
/// Uniform style:
///
/// ```dart
/// StreamMessageRepliesStyle.from(
///   labelColor: Colors.blue,
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
/// StreamMessageRepliesStyle(
///   labelColor: StreamMessageLayoutProperty.resolveWith((p) {
///     final isEnd = p.alignment == StreamMessageAlignment.end;
///     return isEnd ? Colors.blue : Colors.purple;
///   }),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageItemThemeData], which wraps this style for theming.
///  * [StreamMessageReplies], which uses this styling.
@themeGen
@immutable
class StreamMessageRepliesStyle with _$StreamMessageRepliesStyle {
  /// Creates a replies style with optional resolver-based overrides.
  const StreamMessageRepliesStyle({
    this.labelTextStyle,
    this.labelColor,
    this.spacing,
    this.padding,
    this.connectorColor,
    this.connectorStrokeWidth,
    this.clipBehavior,
  });

  /// A convenience constructor that constructs a
  /// [StreamMessageRepliesStyle] given simple values.
  ///
  /// All parameters default to null. By default this constructor returns
  /// a [StreamMessageRepliesStyle] that doesn't override anything.
  ///
  /// For example, to override the default replies label color and spacing,
  /// one could write:
  ///
  /// ```dart
  /// StreamMessageRepliesStyle.from(
  ///   labelColor: Colors.blue,
  ///   spacing: 12,
  /// )
  /// ```
  factory StreamMessageRepliesStyle.from({
    TextStyle? labelTextStyle,
    Color? labelColor,
    double? spacing,
    EdgeInsetsGeometry? padding,
    Color? connectorColor,
    double? connectorStrokeWidth,
    Clip? clipBehavior,
  }) {
    return StreamMessageRepliesStyle(
      labelTextStyle: labelTextStyle?.let(StreamMessageLayoutProperty.all),
      labelColor: labelColor?.let(StreamMessageLayoutProperty.all),
      spacing: spacing?.let(StreamMessageLayoutProperty.all),
      padding: padding?.let(StreamMessageLayoutProperty.all),
      connectorColor: connectorColor?.let(StreamMessageLayoutProperty.all),
      connectorStrokeWidth: connectorStrokeWidth?.let(StreamMessageLayoutProperty.all),
      clipBehavior: clipBehavior?.let(StreamMessageLayoutClip.all),
    );
  }

  /// The text style for the replies label.
  final StreamMessageLayoutProperty<TextStyle?>? labelTextStyle;

  /// The color for the replies label text.
  final StreamMessageLayoutProperty<Color?>? labelColor;

  /// The gap between elements (connector, avatars, label).
  final StreamMessageLayoutProperty<double?>? spacing;

  /// The padding around the replies row content.
  final StreamMessageLayoutProperty<EdgeInsetsGeometry?>? padding;

  /// The color of the connector path linking the row to the message bubble.
  final StreamMessageLayoutProperty<Color?>? connectorColor;

  /// The stroke width of the connector path.
  final StreamMessageLayoutProperty<double?>? connectorStrokeWidth;

  /// How to clip the widget's content.
  ///
  /// Controls whether the connector overflow is clipped at the row boundary.
  final StreamMessageLayoutClip? clipBehavior;

  /// Linearly interpolate between two [StreamMessageRepliesStyle] objects.
  static StreamMessageRepliesStyle? lerp(
    StreamMessageRepliesStyle? a,
    StreamMessageRepliesStyle? b,
    double t,
  ) => _$StreamMessageRepliesStyle.lerp(a, b, t);
}
