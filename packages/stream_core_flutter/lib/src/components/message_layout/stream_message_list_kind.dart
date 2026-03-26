/// The kind of message list a message is displayed in.
///
/// Used by [StreamMessageLayoutData] to let descendant widgets adapt their
/// appearance based on the list context — for example, showing "Also sent in
/// channel" annotations when viewing messages in a thread.
///
/// See also:
///
///  * [StreamMessageLayoutData], which carries this value.
///  * [StreamMessageLayout], the [InheritedModel] that provides it.
enum StreamMessageListKind {
  /// The main channel message list.
  channel,

  /// A thread message list.
  thread,
}
