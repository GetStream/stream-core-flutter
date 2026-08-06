/// The overall visual style of a Stream-powered app.
///
/// [StreamAppStyle] is a coarse, app-wide switch. Set it once on [StreamTheme]
/// to make every Stream component default to either a grounded *regular* look
/// or an airy *floating* look:
///
/// * [regular] — app bar and bottom bar sit within the layout flow; the
///   message composer is docked at the bottom edge.
/// * [floating] — app bar and bottom bar float above the body with translucent
///   backgrounds; the message composer floats above the keyboard.
///
/// Individual components can override this default by setting their own
/// behaviour on their component-specific theme style (e.g.
/// [StreamAppBarStyle.behavior] for [StreamAppBar], or
/// [StreamBottomAppBarStyle.behavior] for [StreamBottomAppBar]).
///
/// ## Resolution order (high → low priority)
///
/// 1. Component theme style field (e.g. `StreamAppBarStyle.behavior`)
/// 2. This [StreamAppStyle] enum value (the global fallback)
///
/// {@tool snippet}
///
/// Apply a floating style to the whole app:
///
/// ```dart
/// StreamTheme(
///   data: StreamTheme(appStyle: StreamAppStyle.floating),
///   child: MyApp(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTheme], which holds this value.
///  * [StreamAppBarStyle.behavior], the per-component override for the app bar.
///  * [StreamBottomAppBarStyle.behavior], the per-component override for the bottom bar.
enum StreamAppStyle {
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
  ///
  /// Convenience getter used by components when mapping to their own
  /// component-specific behavior enums without hard-coding enum names.
  bool get isFloating => this == .floating;
}
