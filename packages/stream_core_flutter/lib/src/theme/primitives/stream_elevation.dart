/// The Material elevations, in logical pixels, of the Stream design system.
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
///   elevation: StreamElevation.level3,
///   child: child,
/// );
/// ```
/// {@end-tool}
abstract final class StreamElevation {
  const StreamElevation._();

  /// No elevation, for a surface flush with its background.
  static const none = 0.0;

  /// Low elevation, for subtle separation.
  ///
  /// Used for cards, list items, and bars that separate from content behind
  /// them.
  static const level1 = 1.0;

  /// Medium-low elevation.
  ///
  /// Used for raised buttons, search bars, and other interactive surfaces.
  static const level2 = 3.0;

  /// Medium-high elevation.
  ///
  /// Used for floating components: the message composer, floating buttons,
  /// menus, and bottom sheets.
  static const level3 = 6.0;

  /// High elevation, for the most prominent surfaces.
  ///
  /// Used for dialogs, modals, and the hovered state of a floating component.
  static const level4 = 8.0;
}
