/// Controls the visibility and layout participation of a widget slot.
///
/// This is typically used for optional slots (such as leading avatars in a
/// message row) where a theme needs to express whether the widget should
/// be shown, hidden while still reserving space, or removed entirely.
///
/// {@tool snippet}
///
/// Conditionally hide the avatar in non-bottom stack positions:
///
/// ```dart
/// StreamMessageItemTheme(
///   data: StreamMessageItemThemeData(
///     leadingVisibility: StreamMessageStyleProperty.resolveWith(
///       (p) => switch (p.stackPosition) {
///         StreamMessageStackPosition.bottom ||
///         StreamMessageStackPosition.single => StreamVisibility.visible,
///         _ => StreamVisibility.hidden,
///       },
///     ),
///   ),
///   child: ...,
/// )
/// ```
/// {@end-tool}
enum StreamVisibility {
  /// The widget is fully visible and participates in layout.
  visible,

  /// The widget is invisible but still occupies its layout space.
  hidden,

  /// The widget is removed from the layout entirely — it takes no space.
  gone,
}
