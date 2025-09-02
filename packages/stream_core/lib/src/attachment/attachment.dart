import 'package:uuid/uuid.dart';

import 'attachment_file.dart';
import 'attachment_type.dart';
import 'attachment_upload_state.dart';

/// Represents a file attachment with type information and upload state.
///
/// Combines an [AttachmentFile] with its [AttachmentType] and tracks the
/// upload progress through [AttachmentUploadState]. This class provides
/// a complete representation of an attachment throughout its lifecycle.
///
/// Example usage:
/// ```dart
/// // Create with auto-generated ID
/// final attachment = StreamAttachment(
///   type: AttachmentType.image,
///   file: AttachmentFile.fromData(imageBytes, name: 'photo.jpg'),
/// );
///
/// // Create with custom ID and custom data
/// final customAttachment = StreamAttachment(
///   id: 'my-custom-id',
///   type: AttachmentType.image,
///   file: AttachmentFile.fromData(imageBytes, name: 'photo.jpg'),
///   custom: {
///     'source': 'camera',
///     'location': 'New York',
///     'tags': ['vacation', 'family'],
///   },
/// );
///
/// // Use the ID for tracking
/// print('Attachment ID: ${attachment.id}');
///
/// // Access custom data
/// final source = customAttachment.custom?['source'];
/// print('Photo source: $source');
///
/// // Check attachment type
/// if (attachment.isImage) {
///   // Handle image attachment
/// }
/// ```
class StreamAttachment {
  /// Creates a [StreamAttachment] with the specified type and file.
  ///
  /// The [id] parameter provides a unique identifier for this attachment.
  /// If not provided, a UUID v4 will be automatically generated.
  /// The [type] specifies what kind of attachment this is.
  /// The [file] contains the actual file data and metadata.
  /// The [uploadState] tracks the upload progress, defaulting to preparing.
  /// The [custom] allows storing arbitrary key-value pairs for additional
  /// metadata specific to your application's needs.
  StreamAttachment({
    String? id,
    required this.type,
    required this.file,
    this.uploadState = const AttachmentUploadState.preparing(),
    this.custom,
  }) : id = id ?? const Uuid().v4();

  /// The unique identifier for this attachment.
  ///
  /// Used to track and reference this specific attachment throughout its lifecycle.
  /// Automatically generated as a UUID v4 if not provided during construction.
  final String id;

  /// The type of this attachment.
  final AttachmentType type;

  /// The file data and metadata.
  final AttachmentFile file;

  /// The current upload state of this attachment.
  final AttachmentUploadState uploadState;

  /// Optional custom data for storing arbitrary key-value pairs.
  ///
  /// This allows applications to attach additional metadata to attachments
  /// that is specific to their use case, such as:
  /// - Source information (camera, gallery, etc.)
  /// - Location data
  /// - Tags or categories
  /// - Processing flags
  /// - Any other application-specific data
  final Map<String, Object?>? custom;

  /// Creates a copy of this [StreamAttachment] with updated values.
  StreamAttachment copyWith({
    AttachmentType? type,
    AttachmentFile? file,
    AttachmentUploadState? uploadState,
    Map<String, Object?>? custom,
  }) {
    return StreamAttachment(
      id: id, // ID is preserved and cannot be changed
      type: type ?? this.type,
      file: file ?? this.file,
      uploadState: uploadState ?? this.uploadState,
      custom: custom ?? this.custom,
    );
  }
}

/// Helper extension for [StreamAttachment] with convenient type checking methods.
///
/// ```dart
/// if (attachment.isImage) {
///   // Display image viewer
/// } else if (attachment.isVideo) {
///   // Show video player
/// }
/// ```
extension StreamAttachmentTypeHelper on StreamAttachment {
  /// Whether this attachment is an image.
  bool get isImage => type == AttachmentType.image;

  /// Whether this attachment is a generic file.
  bool get isFile => type == AttachmentType.file;

  /// Whether this attachment is a Giphy GIF.
  bool get isGiphy => type == AttachmentType.giphy;

  /// Whether this attachment is a video.
  bool get isVideo => type == AttachmentType.video;

  /// Whether this attachment is an audio file.
  bool get isAudio => type == AttachmentType.audio;

  /// Whether this attachment is a voice recording.
  bool get isVoiceRecording => type == AttachmentType.voiceRecording;

  /// Whether this attachment is a link preview.
  bool get isLinkPreview => type == AttachmentType.linkPreview;
}
