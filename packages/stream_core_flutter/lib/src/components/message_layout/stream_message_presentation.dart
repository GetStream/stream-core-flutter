/// How a message is presented to the user.
///
/// Used by [StreamMessageLayoutData] to let descendant widgets adapt their
/// appearance based on what the message is drawn on top of — for example,
/// switching secondary text and icons to white when the message is previewed
/// above a scrim.
///
/// See also:
///
///  * [StreamMessageLayoutData], which carries this value.
///  * [StreamMessageLayout], the [InheritedModel] that provides it.
enum StreamMessagePresentation {
  /// Rendered inline in the message list, on the app background.
  standard,

  /// Rendered as a preview above a scrim, for example in the long-press
  /// message-actions modal.
  ///
  /// Secondary foreground — metadata, annotations, status icons and the
  /// thread-reply label — switches to `StreamColorScheme.textOnAccent` to keep
  /// sufficient contrast against `StreamColorScheme.backgroundScrim`.
  preview,
}
