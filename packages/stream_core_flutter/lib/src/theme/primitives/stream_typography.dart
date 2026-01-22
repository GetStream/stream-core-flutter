import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'stream_typography.g.theme.dart';

/// Typography primitives for the Stream design system.
///
/// Provides platform-aware font sizes, line heights, and font weights for
/// consistent text styling across iOS, Android, and other platforms.
///
/// {@tool snippet}
///
/// To create a typography configuration:
///
/// ```dart
/// final typography = StreamTypography();
/// final fontSize = typography.fontSize.md; // 15.0 on iOS, 16.0 on Android
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTextTheme], which provides semantic text styles using these primitives.
@immutable
@ThemeGen(constructor: 'raw')
class StreamTypography with _$StreamTypography {
  /// Creates a [StreamTypography] with optional custom values.
  ///
  /// If [platform] is null, uses [defaultTargetPlatform]. Font sizes
  /// automatically adjust based on the platform.
  factory StreamTypography({
    TargetPlatform? platform,
    StreamFontSize? fontSize,
    StreamLineHeight? lineHeight,
    StreamFontWeight? fontWeight,
  }) {
    platform ??= defaultTargetPlatform;
    fontSize ??= StreamFontSize(platform: platform);
    lineHeight ??= const StreamLineHeight();
    fontWeight ??= const StreamFontWeight();

    return .raw(
      fontSize: fontSize,
      lineHeight: lineHeight,
      fontWeight: fontWeight,
    );
  }

  const StreamTypography.raw({
    required this.fontSize,
    required this.lineHeight,
    required this.fontWeight,
  });

  /// The font size scale.
  final StreamFontSize fontSize;

  /// The line height values.
  final StreamLineHeight lineHeight;

  /// The font weight values.
  final StreamFontWeight fontWeight;

  /// Linearly interpolates between two [StreamTypography] instances.
  static StreamTypography? lerp(
    StreamTypography? a,
    StreamTypography? b,
    double t,
  ) => _$StreamTypography.lerp(a, b, t);
}

/// Line height values for text.
///
/// Provides three standard line heights for different text densities.
@immutable
@ThemeGen()
class StreamLineHeight with _$StreamLineHeight {
  /// Creates a [StreamLineHeight] with the given values.
  const StreamLineHeight({
    this.tight = 16,
    this.normal = 20,
    this.relaxed = 24,
  });

  /// The tight line height.
  ///
  /// Use for compact text layouts.
  final double tight;

  /// The normal line height.
  ///
  /// Use for standard body text.
  final double normal;

  /// The relaxed line height.
  ///
  /// Use for improved readability in long-form content.
  final double relaxed;

  /// Linearly interpolates between two [StreamLineHeight] instances.
  static StreamLineHeight? lerp(
    StreamLineHeight? a,
    StreamLineHeight? b,
    double t,
  ) => _$StreamLineHeight.lerp(a, b, t);
}

/// Platform-aware font size scale.
///
/// Provides eight font sizes that automatically adjust based on the platform.
/// iOS uses the San Francisco font sizing, while Android uses Roboto sizing.
///
/// {@tool snippet}
///
/// To use platform-specific font sizes:
///
/// ```dart
/// final fontSize = StreamFontSize();
/// Text('Hello', style: TextStyle(fontSize: fontSize.md)); // 15.0 on iOS, 16.0 on Android
/// ```
/// {@end-tool}
@immutable
@ThemeGen(constructor: 'raw')
class StreamFontSize with _$StreamFontSize {
  /// Creates a [StreamFontSize] with platform-specific or custom values.
  ///
  /// If [platform] is null, uses [defaultTargetPlatform]. Individual sizes
  /// can be overridden with custom values.
  factory StreamFontSize({
    TargetPlatform? platform,
    double? micro,
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    platform ??= defaultTargetPlatform;
    final defaultFontSize = switch (platform) {
      .iOS || .macOS => ios,
      _ => android,
    };

    return .raw(
      micro: micro ?? defaultFontSize.micro,
      xxs: xxs ?? defaultFontSize.xxs,
      xs: xs ?? defaultFontSize.xs,
      sm: sm ?? defaultFontSize.sm,
      md: md ?? defaultFontSize.md,
      lg: lg ?? defaultFontSize.lg,
      xl: xl ?? defaultFontSize.xl,
      xxl: xxl ?? defaultFontSize.xxl,
    );
  }

  const StreamFontSize.raw({
    required this.micro,
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  /// The iOS/macOS font size scale.
  ///
  /// Uses San Francisco font sizing conventions.
  static const StreamFontSize ios = .raw(
    micro: 8,
    xxs: 10,
    xs: 12,
    sm: 13,
    md: 15,
    lg: 17,
    xl: 20,
    xxl: 24,
  );

  /// The Android font size scale.
  ///
  /// Uses Roboto font sizing conventions.
  static const StreamFontSize android = .raw(
    micro: 8,
    xxs: 10,
    xs: 12,
    sm: 14,
    md: 16,
    lg: 18,
    xl: 20,
    xxl: 24,
  );

  /// The micro font size.
  final double micro;

  /// The extra extra small font size.
  final double xxs;

  /// The extra small font size.
  final double xs;

  /// The small font size.
  final double sm;

  /// The medium font size.
  final double md;

  /// The large font size.
  final double lg;

  /// The extra large font size.
  final double xl;

  /// The extra extra large font size.
  final double xxl;

  /// Linearly interpolates between two [StreamFontSize] instances.
  static StreamFontSize? lerp(
    StreamFontSize? a,
    StreamFontSize? b,
    double t,
  ) => _$StreamFontSize.lerp(a, b, t);
}

/// Font weight values for text.
///
/// Provides four standard font weights for text hierarchy.
@immutable
@ThemeGen()
class StreamFontWeight with _$StreamFontWeight {
  /// Creates a [StreamFontWeight] with the given values.
  const StreamFontWeight({
    this.regular = .w400,
    this.medium = .w500,
    this.semibold = .w600,
    this.bold = .w700,
  });

  /// The regular font weight.
  final FontWeight regular;

  /// The medium font weight.
  final FontWeight medium;

  /// The semibold font weight.
  final FontWeight semibold;

  /// The bold font weight.
  final FontWeight bold;

  /// Linearly interpolates between two [StreamFontWeight] instances.
  static StreamFontWeight? lerp(
    StreamFontWeight? a,
    StreamFontWeight? b,
    double t,
  ) => _$StreamFontWeight.lerp(a, b, t);
}
