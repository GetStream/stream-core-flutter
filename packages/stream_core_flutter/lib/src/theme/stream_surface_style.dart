/// The presentation of a Stream surface — grounded (*regular*) or airy
/// (*floating*).
///
/// * [regular] — the surface is docked: opaque and occupying its own space in
///   the layout.
/// * [floating] — the surface hovers over the content it covers, translucent.
///
/// A component's own style (e.g. [StreamAppBarStyle.surfaceStyle]) takes
/// precedence over the app-wide default on [StreamTheme].
///
/// {@tool snippet}
///
/// Make the whole app floating:
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
  /// The surface is docked — opaque and taking its own space in the layout.
  regular,

  /// The surface floats above the content it covers, translucent.
  floating;

  /// Whether this is the [floating] variant.
  bool get isFloating => this == .floating;
}
