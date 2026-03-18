import 'package:flutter/widgets.dart';
import 'package:stream_core/stream_core.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import 'stream_message_style_property.dart';

part 'stream_message_annotation_theme.g.theme.dart';

/// Visual styling properties for a message annotation row.
///
/// Defines the appearance of annotation rows including text, icons, spacing,
/// and padding. All properties use [StreamMessageStyleProperty] for
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
///   textColor: StreamMessageStyleProperty.resolveWith((p) {
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
      textStyle: textStyle?.let(StreamMessageStyleProperty.all),
      textColor: textColor?.let(StreamMessageStyleProperty.all),
      spanTextStyle: spanTextStyle?.let(StreamMessageStyleProperty.all),
      spanTextColor: spanTextColor?.let(StreamMessageStyleProperty.all),
      iconColor: iconColor?.let(StreamMessageStyleProperty.all),
      iconSize: iconSize?.let(StreamMessageStyleProperty.all),
      spacing: spacing?.let(StreamMessageStyleProperty.all),
      padding: padding?.let(StreamMessageStyleProperty.all),
    );
  }

  /// The text style for the annotation label.
  ///
  /// This only controls typography. Color comes from [textColor].
  final StreamMessageStyleProperty<TextStyle?>? textStyle;

  /// The color for the annotation label text.
  final StreamMessageStyleProperty<Color?>? textColor;

  /// The text style for child spans in a [StreamMessageAnnotation.rich] label.
  ///
  /// Applied to direct child [TextSpan]s that don't specify an explicit style.
  /// This only controls typography. Color comes from [spanTextColor].
  final StreamMessageStyleProperty<TextStyle?>? spanTextStyle;

  /// The color for child spans in a [StreamMessageAnnotation.rich] label.
  ///
  /// Applied to direct child [TextSpan]s that don't specify an explicit style.
  final StreamMessageStyleProperty<Color?>? spanTextColor;

  /// The color for the leading icon.
  final StreamMessageStyleProperty<Color?>? iconColor;

  /// The size for the leading icon.
  final StreamMessageStyleProperty<double?>? iconSize;

  /// The gap between the leading widget and label.
  final StreamMessageStyleProperty<double?>? spacing;

  /// The padding around the annotation row content.
  final StreamMessageStyleProperty<EdgeInsetsGeometry?>? padding;

  /// Linearly interpolate between two [StreamMessageAnnotationStyle] objects.
  static StreamMessageAnnotationStyle? lerp(
    StreamMessageAnnotationStyle? a,
    StreamMessageAnnotationStyle? b,
    double t,
  ) => _$StreamMessageAnnotationStyle.lerp(a, b, t);
}
