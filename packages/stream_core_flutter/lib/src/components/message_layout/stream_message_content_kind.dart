/// The kind of content a message carries.
///
/// See also:
///
///  * [StreamMessageLayoutData.contentKind], which stores this value.
///  * [StreamMessageLayout], which provides it to descendant widgets.
enum StreamMessageContentKind {
  /// Text, mixed content, or multiple attachments.
  standard,

  /// A single attachment without text or a quoted reply.
  singleAttachment,

  /// An emoji-only message (typically 1-3 emojis) without other content.
  emojiOnly,
}
