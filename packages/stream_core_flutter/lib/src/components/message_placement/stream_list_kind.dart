/// The kind of message list a message is displayed in.
///
/// Used by [StreamMessagePlacementData] to let descendant widgets adapt their
/// appearance based on the list context — for example, showing "Also sent in
/// channel" annotations when viewing messages in a thread.
///
/// See also:
///
///  * [StreamMessagePlacementData], which carries this value.
///  * [StreamMessagePlacement], the [InheritedModel] that provides it.
enum StreamListKind {
  /// The main channel message list.
  channel,

  /// A thread message list.
  thread,
}
