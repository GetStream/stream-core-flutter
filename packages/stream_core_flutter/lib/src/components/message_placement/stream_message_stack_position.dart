/// The position of a message within a consecutive stack from the same sender.
///
/// Chat applications commonly group consecutive messages from the same user,
/// adjusting the bubble's visual treatment (typically corner radii) based on
/// where it sits in the group.
///
/// {@tool snippet}
///
/// Select a bubble border radius based on stack position:
///
/// ```dart
/// final borderRadius = switch (stackPosition) {
///   .single => BorderRadius.circular(20),
///   .top    => BorderRadius.vertical(top: Radius.circular(20)),
///   .middle => BorderRadius.zero,
///   .bottom => BorderRadius.vertical(bottom: Radius.circular(20)),
/// };
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageAlignment], which controls the horizontal placement of
///    message elements.
enum StreamMessageStackPosition {
  /// A standalone message that is not part of any group.
  single,

  /// The first message in a consecutive group.
  top,

  /// A message in the middle of a consecutive group.
  middle,

  /// The last message in a consecutive group.
  bottom,
}
