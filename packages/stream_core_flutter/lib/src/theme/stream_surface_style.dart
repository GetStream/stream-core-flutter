/// How a Stream surface presents itself — grounded (*regular*) or airy
/// (*floating*).
///
/// Used at two scopes with the same values: the app-wide default on
/// [StreamTheme], and a per-component override on a component's style (e.g.
/// [StreamAppBarStyle.surfaceStyle]).
///
/// * [regular] — app bar and bottom bar sit within the layout flow; the
///   message composer is docked at the bottom edge.
/// * [floating] — app bar and bottom bar float above the body with translucent
///   backgrounds; the message composer floats above the keyboard.
///
/// ## Resolution order (high → low priority)
///
/// 1. Component theme style field (e.g. `StreamAppBarStyle.surfaceStyle`)
/// 2. The app-wide value on [StreamTheme] (the global fallback)
///
/// {@tool snippet}
///
/// Apply a floating style to the whole app:
///
/// ```dart
/// ThemeData(extensions: [StreamTheme(surfaceStyle: StreamSurfaceStyle.floating)])
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTheme], which holds the app-wide default.
///  * [StreamAppBarStyle.surfaceStyle], the per-component override for the app bar.
///  * [StreamBottomAppBarStyle.surfaceStyle], the per-component override for the bottom bar.
enum StreamSurfaceStyle {
  /// All components default to a grounded, regularly-positioned layout.
  ///
  /// App bar and bottom bar sit within the layout flow. The message composer
  /// is docked at the bottom edge.
  regular,

  /// All components default to an airy, floating layout.
  ///
  /// App bar and bottom bar float above the body with translucent backgrounds.
  /// The message composer floats above the keyboard.
  floating;

  /// Whether this style is the floating variant.
  bool get isFloating => this == .floating;
}
