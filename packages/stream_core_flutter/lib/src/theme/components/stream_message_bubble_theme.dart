import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_core/stream_core.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import 'stream_message_style_property.dart';

part 'stream_message_bubble_theme.g.theme.dart';

/// Visual styling properties for the message bubble.
///
/// Defines the appearance of message bubbles including shape, border, padding,
/// constraints, and background color. All properties use
/// [StreamMessageLayoutProperty] for placement-aware resolution.
/// Use [StreamMessageBubbleStyle.from] for uniform values across all
/// placements.
///
/// {@tool snippet}
///
/// Uniform style:
///
/// ```dart
/// StreamMessageBubbleStyle.from(
///   backgroundColor: Colors.blue,
///   padding: EdgeInsets.all(12),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Placement-aware style:
///
/// ```dart
/// StreamMessageBubbleStyle(
///   backgroundColor: StreamMessageLayoutProperty.resolveWith((p) {
///     final isEnd = p.alignment == StreamMessageAlignment.end;
///     return isEnd ? Colors.blue.shade100 : Colors.grey.shade100;
///   }),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageItemThemeData], which wraps this style for theming.
///  * [StreamMessageBubble], which uses this styling.
@themeGen
@immutable
class StreamMessageBubbleStyle with _$StreamMessageBubbleStyle {
  /// Creates a bubble style with optional resolver-based overrides.
  const StreamMessageBubbleStyle({
    this.shape,
    this.side,
    this.padding,
    this.constraints,
    this.backgroundColor,
  });

  /// A convenience constructor that constructs a [StreamMessageBubbleStyle]
  /// given simple values.
  ///
  /// All parameters default to null. By default this constructor returns
  /// a [StreamMessageBubbleStyle] that doesn't override anything.
  ///
  /// For example, to override the default bubble background color and
  /// padding, one could write:
  ///
  /// ```dart
  /// StreamMessageBubbleStyle.from(
  ///   backgroundColor: Colors.blue.shade100,
  ///   padding: EdgeInsets.all(12),
  /// )
  /// ```
  factory StreamMessageBubbleStyle.from({
    OutlinedBorder? shape,
    BorderSide? side,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Color? backgroundColor,
  }) {
    return StreamMessageBubbleStyle(
      shape: shape?.let(StreamMessageLayoutProperty.all),
      side: side?.let(StreamMessageLayoutBorderSide.all),
      padding: padding?.let(StreamMessageLayoutProperty.all),
      constraints: constraints?.let(StreamMessageLayoutProperty.all),
      backgroundColor: backgroundColor?.let(StreamMessageLayoutProperty.all),
    );
  }

  /// The shape of the bubble.
  ///
  /// Typically varies by stack position and alignment (tail corner side).
  final StreamMessageLayoutProperty<OutlinedBorder?>? shape;

  /// The border outline of the bubble.
  final StreamMessageLayoutBorderSide? side;

  /// Content padding inside the bubble.
  final StreamMessageLayoutProperty<EdgeInsetsGeometry?>? padding;

  /// Size constraints for the bubble.
  final StreamMessageLayoutProperty<BoxConstraints?>? constraints;

  /// The background fill color of the bubble.
  ///
  /// Typically differs between start-aligned and end-aligned messages.
  final StreamMessageLayoutProperty<Color?>? backgroundColor;

  /// Linearly interpolate between two [StreamMessageBubbleStyle] objects.
  static StreamMessageBubbleStyle? lerp(
    StreamMessageBubbleStyle? a,
    StreamMessageBubbleStyle? b,
    double t,
  ) => _$StreamMessageBubbleStyle.lerp(a, b, t);
}
