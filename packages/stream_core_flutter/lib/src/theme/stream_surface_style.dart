/// The presentation of a Stream surface — grounded ([regular]) or airy
/// ([floating]).
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
///  * [StreamAppBarStyle.surfaceStyle], which overrides it for the app bar.
///  * [StreamBottomAppBarStyle.surfaceStyle], which overrides it for the bottom bar.
enum StreamSurfaceStyle {
  /// A docked surface: opaque, taking its own space in the layout.
  regular,

  /// A floating surface: translucent, hovering over the content it covers.
  floating;

  /// Whether this is the [floating] variant.
  bool get isFloating => this == .floating;
}
