import 'package:flutter/foundation.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'stream_spacing.g.theme.dart';

/// Spacing primitives for the Stream design system.
///
/// Provides consistent spacing values for padding, margins, and gaps between
/// UI elements. Spacing values are the same across all platforms.
///
/// {@tool snippet}
///
/// To use spacing values:
///
/// ```dart
/// const spacing = StreamSpacing();
/// Container(
///   padding: EdgeInsets.all(spacing.md),
///   child: Column(
///     spacing: spacing.xs,
///     children: [...],
///   ),
/// );
/// ```
/// {@end-tool}
@immutable
@ThemeGen()
class StreamSpacing with _$StreamSpacing {
  /// Creates a [StreamSpacing] with the default values.
  const StreamSpacing({
    this.none = 0,
    this.xxxs = 2,
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.lg = 20,
    this.xl = 24,
    this.xxl = 32,
    this.xxxl = 40,
  });

  /// No spacing.
  ///
  /// Used for tight component joins.
  final double none;

  /// Extra extra extra small spacing.
  ///
  /// Used for very tight spacing between closely related elements.
  final double xxxs;

  /// Base unit spacing.
  ///
  /// Used for minimal padding and tight gaps.
  final double xxs;

  /// Extra small spacing.
  ///
  /// Used for small padding and default vertical gaps.
  final double xs;

  /// Small spacing.
  ///
  /// Used for common internal spacing in inputs and buttons.
  final double sm;

  /// Medium spacing.
  ///
  /// Used for default large padding for sections and cards.
  final double md;

  /// Large spacing.
  ///
  /// Used for medium spacing for grouping elements and section breaks.
  final double lg;

  /// Extra large spacing.
  ///
  /// Used for comfortable spacing for chat bubbles and list items.
  final double xl;

  /// Extra extra large spacing.
  ///
  /// Used for larger spacing for panels, modals, and gutters.
  final double xxl;

  /// Extra extra extra large spacing.
  ///
  /// Used for wide layout spacing and breathing room.
  final double xxxl;

  /// Linearly interpolates between two [StreamSpacing] instances.
  static StreamSpacing? lerp(
    StreamSpacing? a,
    StreamSpacing? b,
    double t,
  ) => _$StreamSpacing.lerp(a, b, t);
}

/// Platform-adaptive spacing values derived from the [StreamSpacing] scale.
extension StreamSpacingSafeArea on StreamSpacing {
  /// The recommended minimum bottom inset for a floating surface, such as a
  /// floating navigation pill or a message composer.
  ///
  /// Use it as the `minimum` bottom inset of a [StreamSafeArea] so the surface
  /// keeps a comfortable gap above the bottom of the screen, while a larger
  /// system inset (home indicator, navigation bar) is honored as-is.
  ///
  /// Adapts to [platform], defaulting to the current platform.
  double safeAreaBottom({TargetPlatform? platform}) {
    platform ??= defaultTargetPlatform;
    return switch (platform) {
      .iOS || .macOS => xxl,
      _ => xxxl,
    };
  }
}
