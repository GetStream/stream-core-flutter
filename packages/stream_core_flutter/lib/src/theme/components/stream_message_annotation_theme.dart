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
    this.spanTextStyle,
    this.spanTextColor,
    this.iconColor,
    this.iconSize,
    this.spacing,
    this.padding,
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
    TextStyle? spanTextStyle,
    Color? spanTextColor,
    Color? iconColor,
    double? iconSize,
    double? spacing,
    EdgeInsetsGeometry? padding,
  }) {
    return StreamMessageAnnotationStyle(
      textStyle: textStyle?.let(StreamMessageLayoutProperty.all),
      textColor: textColor?.let(StreamMessageLayoutProperty.all),
      spanTextStyle: spanTextStyle?.let(StreamMessageLayoutProperty.all),
      spanTextColor: spanTextColor?.let(StreamMessageLayoutProperty.all),
      iconColor: iconColor?.let(StreamMessageLayoutProperty.all),
      iconSize: iconSize?.let(StreamMessageLayoutProperty.all),
      spacing: spacing?.let(StreamMessageLayoutProperty.all),
      padding: padding?.let(StreamMessageLayoutProperty.all),
    );
  }

  /// The text style for the annotation label.
  ///
  /// This only controls typography. Color comes from [textColor].
  final StreamMessageLayoutProperty<TextStyle?>? textStyle;

  /// The color for the annotation label text.
  final StreamMessageLayoutProperty<Color?>? textColor;

  /// The text style for child spans in a [StreamMessageAnnotation.rich] label.
  ///
  /// Applied to direct child [TextSpan]s that don't specify an explicit style.
  /// This only controls typography. Color comes from [spanTextColor].
  final StreamMessageLayoutProperty<TextStyle?>? spanTextStyle;

  /// The color for child spans in a [StreamMessageAnnotation.rich] label.
  ///
  /// Applied to direct child [TextSpan]s that don't specify an explicit style.
  final StreamMessageLayoutProperty<Color?>? spanTextColor;

  /// The color for the leading icon.
  final StreamMessageLayoutProperty<Color?>? iconColor;

  /// The size for the leading icon.
  final StreamMessageLayoutProperty<double?>? iconSize;

  /// The gap between the leading widget and label.
  final StreamMessageLayoutProperty<double?>? spacing;

  /// The padding around the annotation row content.
  final StreamMessageLayoutProperty<EdgeInsetsGeometry?>? padding;

  /// Linearly interpolate between two [StreamMessageAnnotationStyle] objects.
  static StreamMessageAnnotationStyle? lerp(
    StreamMessageAnnotationStyle? a,
    StreamMessageAnnotationStyle? b,
    double t,
  ) => _$StreamMessageAnnotationStyle.lerp(a, b, t);
}
