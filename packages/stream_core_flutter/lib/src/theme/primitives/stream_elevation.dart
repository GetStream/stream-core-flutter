import 'package:flutter/foundation.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'stream_elevation.g.theme.dart';

/// Material elevation primitives, in logical pixels, for the Stream design
/// system.
///
/// The design system describes four elevation levels. Each level is specified as
/// both a drop shadow and a Material level, and Flutter renders drop shadows
/// through `Material`, so the logical-pixel value is the representation used
/// here:
///
/// | Design system token | Material level | Logical pixels |
/// | --- | --- | --- |
/// | `elevation-1` | 1 | 1 |
/// | `elevation-2` | 2 | 3 |
/// | `elevation-3` | 3 | 6 |
/// | `elevation-4` | 3–4 | 6–8 |
///
/// Pass these to `Material.elevation` (or to a component theme's `elevation`
/// field) rather than painting a `BoxShadow`. See `StreamBoxShadow` for the
/// cases where Material cannot render the shadow, such as text shadows.
///
/// {@tool snippet}
///
/// Elevate a surface to the level used by floating components:
///
/// ```dart
/// Material(
///   elevation: context.streamElevation.level3,
///   child: child,
/// );
/// ```
/// {@end-tool}
@immutable
@ThemeGen()
class StreamElevation with _$StreamElevation {
  /// Creates a [StreamElevation] with the default values.
  const StreamElevation({
    this.none = 0,
    this.level1 = 1,
    this.level2 = 3,
    this.level3 = 6,
    this.level4 = 8,
  });

  /// No elevation, for a surface flush with its background.
  final double none;

  /// Low elevation, for subtle separation.
  ///
  /// Used for cards, list items, and bars that separate from content behind
  /// them.
  final double level1;

  /// Medium-low elevation.
  ///
  /// Used for raised buttons, search bars, and other interactive surfaces.
  final double level2;

  /// Medium-high elevation.
  ///
  /// Used for floating components: the message composer, floating buttons,
  /// menus, and bottom sheets.
  final double level3;

  /// High elevation, for the most prominent surfaces.
  ///
  /// Used for dialogs, modals, and the hovered state of a floating component.
  final double level4;

  /// Linearly interpolates between two [StreamElevation] instances.
  static StreamElevation? lerp(
    StreamElevation? a,
    StreamElevation? b,
    double t,
  ) => _$StreamElevation.lerp(a, b, t);
}
