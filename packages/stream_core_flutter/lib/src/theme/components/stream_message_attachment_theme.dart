import 'package:flutter/widgets.dart';
import 'package:stream_core/stream_core.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import 'stream_message_style_property.dart';

part 'stream_message_attachment_theme.g.theme.dart';

/// Visual styling properties for message attachment containers.
///
/// Defines the appearance of attachment containers including shape, border,
/// and background color. All properties use [StreamMessageStyleProperty] for
/// placement-aware resolution. Use [StreamMessageAttachmentStyle.from] for
/// uniform values across all placements.
///
/// {@tool snippet}
///
/// Uniform style:
///
/// ```dart
/// StreamMessageAttachmentStyle.from(
///   backgroundColor: Colors.grey.shade100,
///   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
///   side: BorderSide(color: Colors.grey),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Placement-aware style:
///
/// ```dart
/// StreamMessageAttachmentStyle(
///   backgroundColor: StreamMessageStyleProperty.resolveWith((p) {
///     final isEnd = p.alignment == StreamMessageAlignment.end;
///     return isEnd ? Colors.blue.shade50 : Colors.grey.shade50;
///   }),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageItemThemeData], which wraps this style for theming.
@themeGen
@immutable
class StreamMessageAttachmentStyle with _$StreamMessageAttachmentStyle {
  /// Creates an attachment style with optional resolver-based overrides.
  const StreamMessageAttachmentStyle({
    this.backgroundColor,
    this.shape,
    this.side,
  });

  /// A convenience constructor that constructs a
  /// [StreamMessageAttachmentStyle] given simple values.
  ///
  /// All parameters default to null. By default this constructor returns
  /// a [StreamMessageAttachmentStyle] that doesn't override anything.
  ///
  /// For example, to override the default attachment background color and
  /// shape, one could write:
  ///
  /// ```dart
  /// StreamMessageAttachmentStyle.from(
  ///   backgroundColor: Colors.grey.shade100,
  ///   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  /// )
  /// ```
  factory StreamMessageAttachmentStyle.from({
    Color? backgroundColor,
    OutlinedBorder? shape,
    BorderSide? side,
  }) {
    return StreamMessageAttachmentStyle(
      backgroundColor: backgroundColor?.let(StreamMessageStyleProperty.all),
      shape: shape?.let(StreamMessageStyleProperty.all),
      side: side?.let(StreamMessageStyleBorderSide.all),
    );
  }

  /// The background fill color of the attachment container.
  ///
  /// Typically differs between start-aligned and end-aligned messages.
  final StreamMessageStyleProperty<Color?>? backgroundColor;

  /// The shape of the attachment container.
  ///
  /// Typically varies by alignment or stack position.
  final StreamMessageStyleProperty<OutlinedBorder?>? shape;

  /// The border outline of the attachment container.
  final StreamMessageStyleBorderSide? side;

  /// Linearly interpolate between two [StreamMessageAttachmentStyle] objects.
  static StreamMessageAttachmentStyle? lerp(
    StreamMessageAttachmentStyle? a,
    StreamMessageAttachmentStyle? b,
    double t,
  ) => _$StreamMessageAttachmentStyle.lerp(a, b, t);
}
