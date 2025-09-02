/// Type-safe attachment type identifier for Stream attachments.
///
/// Wraps raw string values with predefined constants for attachment types
/// supported by the Stream platform.
///
/// ```dart
/// const type = AttachmentType.image;
/// if (attachment.type.isImage) {
///   // Handle image attachment
/// }
/// ```
extension type const AttachmentType(String rawType) implements String {
  // region Backend defined types

  /// Image attachment type for static image files.
  static const image = AttachmentType('image');

  /// Generic file attachment type for documents and archives.
  static const file = AttachmentType('file');

  /// Giphy GIF attachment type for animated GIFs from Giphy service.
  static const giphy = AttachmentType('giphy');

  /// Video attachment type for video files.
  static const video = AttachmentType('video');

  /// Audio attachment type for audio files.
  static const audio = AttachmentType('audio');

  /// Voice recording attachment type for voice messages.
  static const voiceRecording = AttachmentType('voiceRecording');

  // endregion

  // region Custom types

  /// Link preview attachment type for rich link previews.
  static const linkPreview = AttachmentType('linkPreview');

  // endregion
}
