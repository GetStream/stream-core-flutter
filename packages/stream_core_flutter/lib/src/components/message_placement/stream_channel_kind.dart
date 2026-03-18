/// The kind of channel a message is displayed in.
///
/// Used by [StreamMessagePlacementData] to let descendant widgets adapt their
/// appearance based on the channel type — for example, hiding avatars in
/// direct (1-to-1) conversations where the sender is always known.
///
/// See also:
///
///  * [StreamMessagePlacementData], which carries this value.
///  * [StreamMessagePlacement], the [InheritedModel] that provides it.
enum StreamChannelKind {
  /// A direct (1-to-1) conversation between two users.
  direct,

  /// A group conversation with multiple participants.
  group,
}
