/// Controls the semantic order of elements in message-related row components
/// based on which side the message bubble is aligned to.
///
/// This is orthogonal to [TextDirection] (LTR/RTL). The alignment determines
/// the children order, while the ambient [TextDirection] determines the visual
/// rendering direction. They compose naturally:
///
/// | Alignment | TextDirection | Visual result                        |
/// |-----------|--------------|---------------------------------------|
/// | start     | LTR          | start-ordered children, left-to-right |
/// | start     | RTL          | start-ordered children, right-to-left |
/// | end       | LTR          | end-ordered children, left-to-right   |
/// | end       | RTL          | end-ordered children, right-to-left   |
///
/// The caller decides which alignment to use based on their app's message
/// layout configuration (all-start, all-end, or directional per sender).
///
/// Each widget that accepts this enum defines its own element order for
/// [start] and [end]. See the individual widget documentation for specifics.
///
/// See also:
///
///  * [StreamMessageLayoutData], which carries this value.
///  * [StreamMessageLayout], the [InheritedModel] that provides it.
///  * [StreamMessageStackPosition], which controls the vertical stacking of
///    consecutive messages from the same sender.
enum StreamMessageAlignment {
  /// Elements ordered toward the start of the message bubble.
  start,

  /// Elements ordered toward the end of the message bubble.
  end,
}
