/// The floating or regular layout behaviour shared by the Stream app bars —
/// [StreamAppBar] and [StreamBottomAppBar].
///
/// When null on the component's style (e.g. [StreamAppBarStyle.behavior]), the
/// ambient [StreamAppStyle] is used as a fallback — [StreamAppStyle.floating]
/// maps to [floating] and [StreamAppStyle.regular] maps to [regular].
///
/// See also:
///
///  * [StreamAppBarStyle.behavior] / [StreamBottomAppBarStyle.behavior], which
///    carry this value per component.
///  * [StreamToolbarScope], which publishes the resolved value to a bar's slots.
///  * [StreamAppStyle], the global app-wide style that acts as fallback.
enum StreamToolbarBehavior {
  /// The bar sits within the layout flow with a solid background.
  regular,

  /// The bar floats above the body with a translucent background.
  floating;

  /// Whether this is [StreamToolbarBehavior.floating].
  bool get isFloating => this == .floating;
}
