import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'stream_radius.g.theme.dart';

/// Border radius primitives for the Stream design system.
///
/// Provides platform-aware border radius values for consistent rounded corners
/// across iOS, Android, and other platforms. iOS typically uses larger corner
/// radius values following iOS design guidelines, while Android uses Material
/// Design conventions.
///
/// {@tool snippet}
///
/// To use border radius values:
///
/// ```dart
/// final radius = StreamRadius();
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.all(radius.md),
///   ),
/// );
/// ```
/// {@end-tool}
@immutable
@ThemeGen(constructor: 'raw')
class StreamRadius with _$StreamRadius {
  /// Creates a [StreamRadius] with platform-specific or custom values.
  ///
  /// If [platform] is null, uses [defaultTargetPlatform]. Individual radius
  /// values can be overridden with custom values.
  factory StreamRadius({
    TargetPlatform? platform,
    Radius? none,
    Radius? xxs,
    Radius? xs,
    Radius? sm,
    Radius? md,
    Radius? lg,
    Radius? xl,
    Radius? xxl,
    Radius? xxxl,
    Radius? xxxxl,
    Radius? max,
  }) {
    platform ??= defaultTargetPlatform;
    final defaultRadius = switch (platform) {
      .iOS || .macOS => ios,
      _ => android,
    };

    return .raw(
      none: none ?? defaultRadius.none,
      xxs: xxs ?? defaultRadius.xxs,
      xs: xs ?? defaultRadius.xs,
      sm: sm ?? defaultRadius.sm,
      md: md ?? defaultRadius.md,
      lg: lg ?? defaultRadius.lg,
      xl: xl ?? defaultRadius.xl,
      xxl: xxl ?? defaultRadius.xxl,
      xxxl: xxxl ?? defaultRadius.xxxl,
      xxxxl: xxxxl ?? defaultRadius.xxxxl,
      max: max ?? defaultRadius.max,
    );
  }

  const StreamRadius.raw({
    required this.none,
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
    required this.xxxxl,
    required this.max,
  });

  /// The iOS/macOS border radius scale.
  ///
  /// Uses iOS design guidelines with generally larger radius values.
  static const StreamRadius ios = .raw(
    none: .zero,
    xxs: .circular(2),
    xs: .circular(4),
    sm: .circular(6),
    md: .circular(8),
    lg: .circular(12),
    xl: .circular(16),
    xxl: .circular(20),
    xxxl: .circular(24),
    xxxxl: .circular(32),
    max: .circular(9999),
  );

  /// The Android border radius scale.
  ///
  /// Uses Material Design guidelines with more conservative radius values.
  static const StreamRadius android = .raw(
    none: .zero,
    xxs: .zero,
    xs: .circular(2),
    sm: .circular(4),
    md: .circular(6),
    lg: .circular(8),
    xl: .circular(12),
    xxl: .circular(16),
    xxxl: .circular(20),
    xxxxl: .circular(24),
    max: .circular(9999),
  );

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
