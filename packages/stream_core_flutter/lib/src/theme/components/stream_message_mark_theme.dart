import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../utils/standard.dart';
import 'stream_message_style_property.dart';

part 'stream_message_mark_theme.g.theme.dart';

/// Visual styling properties for a message mark.
///
/// Defines the appearance of the mark's label in its neutral and highlighted
/// states, and of the separator that follows it. All properties use
/// [StreamMessageLayoutProperty] for placement-aware resolution. Use
/// [StreamMessageMarkStyle.from] for uniform values across all placements.
///
/// {@tool snippet}
///
/// Uniform style:
///
/// ```dart
/// StreamMessageMarkStyle.from(
///   color: Colors.grey,
///   highlightedColor: Colors.green,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageItemThemeData], which wraps this style for theming.
///  * [StreamMessageMark], which uses this styling.
@themeGen
@immutable
class StreamMessageMarkStyle with _$StreamMessageMarkStyle {
  /// Creates a mark style with optional resolver-based overrides.
  const StreamMessageMarkStyle({
    this.textStyle,
    this.color,
    this.highlightedColor,
    this.separatorColor,
    this.spacing,
  });

  /// A convenience constructor that constructs a [StreamMessageMarkStyle]
  /// given simple values.
  ///
  /// All parameters default to null. By default this constructor returns a
  /// [StreamMessageMarkStyle] that doesn't override anything.
  factory StreamMessageMarkStyle.from({
    TextStyle? textStyle,
    Color? color,
    Color? highlightedColor,
    Color? separatorColor,
    double? spacing,
  }) {
    return StreamMessageMarkStyle(
      textStyle: textStyle?.let(StreamMessageLayoutProperty.all),
      color: color?.let(StreamMessageLayoutProperty.all),
      highlightedColor: highlightedColor?.let(StreamMessageLayoutProperty.all),
      separatorColor: separatorColor?.let(StreamMessageLayoutProperty.all),
      spacing: spacing?.let(StreamMessageLayoutProperty.all),
    );
  }

  /// The text style for the label and the separator.
  ///
  /// This only controls typography. Color comes from [color],
  /// [highlightedColor] and [separatorColor].
  final StreamMessageLayoutProperty<TextStyle?>? textStyle;

  /// The color of a label that is not highlighted.
  final StreamMessageLayoutProperty<Color?>? color;

  /// The color of a highlighted label.
  final StreamMessageLayoutProperty<Color?>? highlightedColor;

  /// The color of the separator after the label.
  final StreamMessageLayoutProperty<Color?>? separatorColor;

  /// The space between the label and the separator.
  final StreamMessageLayoutProperty<double?>? spacing;

  /// Linearly interpolate between two [StreamMessageMarkStyle] objects.
  static StreamMessageMarkStyle? lerp(
    StreamMessageMarkStyle? a,
    StreamMessageMarkStyle? b,
    double t,
  ) => _$StreamMessageMarkStyle.lerp(a, b, t);
}
