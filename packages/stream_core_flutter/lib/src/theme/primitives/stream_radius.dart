import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import 'internal/tokens/stream_tokens_dimensions.dart' as tokens;

part 'stream_radius.g.theme.dart';

/// Border radius primitives for the Stream design system.
///
/// Provides consistent border radius values for rounded corners across all
/// platforms.
///
/// {@tool snippet}
///
/// To use border radius values:
///
/// ```dart
/// const radius = StreamRadius();
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.all(radius.md),
///   ),
/// );
/// ```
/// {@end-tool}
@immutable
@ThemeGen()
class StreamRadius with _$StreamRadius {
  /// Creates a [StreamRadius] with the default values.
  const StreamRadius({
    // `Radius.zero` rather than `circular(radiusNone)`: the analyzer's
    // use_named_constants prefers the named constant, so the token has no
    // reader and is not carried.
    this.none = .zero,
    this.xxs = const .circular(tokens.StreamTokensDimensions.radiusXxs),
    this.xs = const .circular(tokens.StreamTokensDimensions.radiusXs),
    this.sm = const .circular(tokens.StreamTokensDimensions.radiusSm),
    this.md = const .circular(tokens.StreamTokensDimensions.radiusMd),
    this.lg = const .circular(tokens.StreamTokensDimensions.radiusLg),
    this.xl = const .circular(tokens.StreamTokensDimensions.radiusXl),
    this.xxl = const .circular(tokens.StreamTokensDimensions.radius2xl),
    this.xxxl = const .circular(tokens.StreamTokensDimensions.radius3xl),
    this.xxxxl = const .circular(tokens.StreamTokensDimensions.radius4xl),
    this.max = const .circular(tokens.StreamTokensDimensions.radiusMax),
  });

  /// No border radius.
  final Radius none;

  /// The extra extra small border radius.
  final Radius xxs;

  /// The extra small border radius.
  final Radius xs;

  /// The small border radius.
  final Radius sm;

  /// The medium border radius.
  final Radius md;

  /// The large border radius.
  final Radius lg;

  /// The extra large border radius.
  final Radius xl;

  /// The extra extra large border radius.
  final Radius xxl;

  /// The extra extra extra large border radius.
  final Radius xxxl;

  /// The extra extra extra extra large border radius.
  final Radius xxxxl;

  /// The maximum border radius.
  ///
  /// Use for fully rounded elements like pills or circular buttons.
  final Radius max;

  /// Linearly interpolates between two [StreamRadius] instances.
  static StreamRadius? lerp(
    StreamRadius? a,
    StreamRadius? b,
    double t,
  ) => _$StreamRadius.lerp(a, b, t);
}
