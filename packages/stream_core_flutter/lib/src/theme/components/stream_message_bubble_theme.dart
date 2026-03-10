import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'stream_message_bubble_theme.g.theme.dart';

/// Structural style properties for a message bubble container.
///
/// [StreamMessageBubbleStyle] is a reusable value object that can be applied
/// both as a theme value (via [StreamMessageBubbleThemeData]) and as a direct
/// widget prop on the future message bubble widget — similar to how
/// [ButtonStyle] works with [ElevatedButton].
///
/// Includes [backgroundColor] so that incoming/outgoing variants can each
/// carry their own fill color alongside the structural properties.
///
/// {@tool snippet}
///
/// Create a custom bubble style:
///
/// ```dart
/// const style = StreamMessageBubbleStyle(
///   shape: RoundedRectangleBorder(
///     borderRadius: BorderRadius.all(Radius.circular(16)),
///   ),
///   side: BorderSide(color: Colors.grey),
///   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageBubbleThemeData], which wraps this style for theming.
///  * [StreamMessageStyle], which provides the color properties for messages.
@themeGen
@immutable
class StreamMessageBubbleStyle with _$StreamMessageBubbleStyle {
  /// Creates a message bubble style with optional property overrides.
  const StreamMessageBubbleStyle({
    this.shape,
    this.side,
    this.padding,
    this.constraints,
    this.backgroundColor,
  });

  /// The shape of the bubble's container.
  ///
  /// This shape is combined with [side] to create a shape decorated with an
  /// outline. Using [OutlinedBorder] (rather than raw [BorderRadius]) aligns
  /// with Material 3 conventions and supports custom tail shapes in the future.
  ///
  /// Defaults to a [RoundedRectangleBorder] built from the design system's
  /// `messageBubbleRadius*` tokens.
  final OutlinedBorder? shape;

  /// The border outline of the bubble.
  ///
  /// This value is combined with [shape] to create a shape decorated with an
  /// outline. Keeping this separate from [shape] allows changing border
  /// color/width without reconstructing the entire shape.
  ///
  /// Defaults to a 1px [StreamColorScheme.borderSubtle] border.
  final BorderSide? side;

  /// Content padding inside the bubble.
  ///
  /// Defaults to a value derived from [StreamSpacing].
  final EdgeInsetsGeometry? padding;

  /// Size constraints for the bubble.
  ///
  /// Defaults to `BoxConstraints(minHeight: 20)`.
  ///
  /// ```dart
  /// constraints: BoxConstraints(minHeight: 20, maxWidth: 280)
  /// ```
  final BoxConstraints? constraints;

  /// The background fill color of the bubble.
  ///
  /// Typically differs between incoming and outgoing messages.
  ///
  /// Defaults to [StreamColorScheme.backgroundSurface].
  final Color? backgroundColor;

  /// Linearly interpolate between two [StreamMessageBubbleStyle] instances.
  static StreamMessageBubbleStyle? lerp(
    StreamMessageBubbleStyle? a,
    StreamMessageBubbleStyle? b,
    double t,
  ) => _$StreamMessageBubbleStyle.lerp(a, b, t);
}

/// Theme data for the message bubble, holding a base [style].
///
/// Nested inside [StreamMessageStyle] so that `incoming` and `outgoing`
/// messages each get their own bubble theme automatically.
///
/// Currently holds a single [style]. Position-specific overrides
/// (e.g. `topStyle`, `middleStyle`) for message grouping will be added in a
/// follow-up.
///
/// {@tool snippet}
///
/// Override bubble styling for outgoing messages via [StreamMessageTheme]:
///
/// ```dart
/// StreamMessageTheme(
///   data: StreamMessageThemeData(
///     outgoing: StreamMessageStyle(
///       bubble: StreamMessageBubbleThemeData(
///         style: StreamMessageBubbleStyle(
///           shape: RoundedRectangleBorder(
///             borderRadius: BorderRadius.circular(24),
///           ),
///           side: BorderSide.none,
///         ),
///       ),
///     ),
///   ),
///   child: ...,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageBubbleStyle], the value object holding structural props.
///  * [StreamMessageStyle], which nests this theme data.
@themeGen
@immutable
class StreamMessageBubbleThemeData with _$StreamMessageBubbleThemeData {
  /// Creates a message bubble theme data with an optional base [style].
  const StreamMessageBubbleThemeData({
    this.style,
  });

  /// The base bubble style.
  ///
  /// When the bubble widget resolves its effective style, this serves
  /// as the theme-level default that can be overridden by a direct widget prop.
  final StreamMessageBubbleStyle? style;

  /// Linearly interpolate between two [StreamMessageBubbleThemeData] instances.
  static StreamMessageBubbleThemeData? lerp(
    StreamMessageBubbleThemeData? a,
    StreamMessageBubbleThemeData? b,
    double t,
  ) => _$StreamMessageBubbleThemeData.lerp(a, b, t);
}
