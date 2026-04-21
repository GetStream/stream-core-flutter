import 'package:flutter/widgets.dart';
import 'package:stream_core/stream_core.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import 'stream_message_style_property.dart';

part 'stream_message_annotation_theme.g.theme.dart';

/// Visual styling properties for a message annotation row.
///
/// Defines the appearance of annotation rows including text, icons, spacing,
/// and padding. All properties use [StreamMessageLayoutProperty] for
/// placement-aware resolution. Use [StreamMessageAnnotationStyle.from]
/// for uniform values across all placements.
///
/// {@tool snippet}
///
/// Uniform style:
///
/// ```dart
/// StreamMessageAnnotationStyle.from(
///   textColor: Colors.purple,
///   iconColor: Colors.purple,
///   iconSize: 18,
///   spacing: 8,
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Placement-aware style:
///
/// ```dart
/// StreamMessageAnnotationStyle(
///   textColor: StreamMessageLayoutProperty.resolveWith((p) {
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
///  * [StreamMessageAnnotation], which uses this styling.
@themeGen
@immutable
class StreamMessageAnnotationStyle with _$StreamMessageAnnotationStyle {
  /// Creates an annotation style with optional resolver-based overrides.
  const StreamMessageAnnotationStyle({
    this.textStyle,
    this.textColor,
    this.iconColor,
    this.iconSize,
    this.spacing,
    this.padding,
    this.trailingTextStyle,
    this.trailingTextColor,
  });

  /// A convenience constructor that constructs a
  /// [StreamMessageAnnotationStyle] given simple values.
  ///
  /// All parameters default to null. By default this constructor returns
  /// a [StreamMessageAnnotationStyle] that doesn't override anything.
  ///
  /// For example, to override the default annotation text and icon colors,
  /// one could write:
  ///
  /// ```dart
  /// StreamMessageAnnotationStyle.from(
  ///   textColor: Colors.purple,
  ///   iconColor: Colors.purple,
  /// )
  /// ```
  factory StreamMessageAnnotationStyle.from({
    TextStyle? textStyle,
    Color? textColor,
    Color? iconColor,
    double? iconSize,
    double? spacing,
    EdgeInsetsGeometry? padding,
    TextStyle? trailingTextStyle,
    Color? trailingTextColor,
  }) {
    return StreamMessageAnnotationStyle(
      textStyle: textStyle?.let(StreamMessageLayoutProperty.all),
      textColor: textColor?.let(StreamMessageLayoutProperty.all),
      iconColor: iconColor?.let(StreamMessageLayoutProperty.all),
      iconSize: iconSize?.let(StreamMessageLayoutProperty.all),
      spacing: spacing?.let(StreamMessageLayoutProperty.all),
      padding: padding?.let(StreamMessageLayoutProperty.all),
      trailingTextStyle: trailingTextStyle?.let(StreamMessageLayoutProperty.all),
      trailingTextColor: trailingTextColor?.let(StreamMessageLayoutProperty.all),
    );
  }

  /// The text style for the annotation label.
  ///
  /// This only controls typography. Color comes from [textColor].
  final StreamMessageLayoutProperty<TextStyle?>? textStyle;

  /// The color for the annotation label text.
  final StreamMessageLayoutProperty<Color?>? textColor;

  /// The color for the leading icon.
  final StreamMessageLayoutProperty<Color?>? iconColor;

  /// The size for the leading icon.
  final StreamMessageLayoutProperty<double?>? iconSize;

  /// The gap between the leading widget and label.
  final StreamMessageLayoutProperty<double?>? spacing;

  /// The padding around the annotation row content.
  final StreamMessageLayoutProperty<EdgeInsetsGeometry?>? padding;

  /// The text style for the trailing widget.
  ///
  /// Applied to the trailing widget via an inherited [DefaultTextStyle].
  /// The trailing widget (typically a tappable [Text]) picks up this style
  /// automatically. This only controls typography. Color comes from
  /// [trailingTextColor].
  final StreamMessageLayoutProperty<TextStyle?>? trailingTextStyle;

  /// The color for the trailing widget.
  ///
  /// Applied to the trailing widget's text via the inherited
  /// [DefaultTextStyle].
  final StreamMessageLayoutProperty<Color?>? trailingTextColor;

  /// Linearly interpolate between two [StreamMessageAnnotationStyle] objects.
  static StreamMessageAnnotationStyle? lerp(
    StreamMessageAnnotationStyle? a,
    StreamMessageAnnotationStyle? b,
    double t,
  ) => _$StreamMessageAnnotationStyle.lerp(a, b, t);
}
