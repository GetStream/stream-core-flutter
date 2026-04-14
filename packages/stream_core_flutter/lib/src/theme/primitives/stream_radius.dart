import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

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
    this.none = .zero,
    this.xxs = const .circular(2),
    this.xs = const .circular(4),
    this.sm = const .circular(6),
    this.md = const .circular(8),
    this.lg = const .circular(12),
    this.xl = const .circular(16),
    this.xxl = const .circular(20),
    this.xxxl = const .circular(24),
    this.xxxxl = const .circular(32),
    this.max = const .circular(9999),
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
