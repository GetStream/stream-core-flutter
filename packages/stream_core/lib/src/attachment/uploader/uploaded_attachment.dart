import '../attachment_type.dart';

/// Represents a successfully uploaded attachment.
///
/// Contains the attachment ID, type, remote file URLs from the CDN upload,
/// and any custom data associated with the attachment.
/// Preserves the attachment type for proper rendering and handling of the
/// uploaded content.
///
/// Example usage:
/// ```dart
/// final uploadedAttachment = UploadedAttachment(
///   id: 'attachment-123',
///   type: AttachmentType.image,
///   remoteUrl: 'https://cdn.example.com/file.jpg',
///   thumbnailUrl: 'https://cdn.example.com/thumb.jpg',
///   custom: {'source': 'camera', 'processed': true},
/// );
/// ```
class UploadedAttachment {
  /// Creates an [UploadedAttachment] with attachment details and remote URLs.
  const UploadedAttachment({
    required this.id,
    required this.type,
    this.remoteUrl,
    this.thumbnailUrl,
    this.custom,
  });

  /// The ID of the attachment that was uploaded.
  final String id;

  /// The type of the attachment.
  final AttachmentType type;

  /// The remote URL of the uploaded file.
  final String? remoteUrl;

  /// The remote URL of the file thumbnail, if available.
  ///
  /// Primarily generated for video uploads to provide a preview frame.
  final String? thumbnailUrl;

  /// Optional custom data for storing arbitrary key-value pairs.
  ///
  /// This allows applications to attach additional metadata to uploaded
  /// attachments that is specific to their use case.
  final Map<String, Object?>? custom;

  /// Whether this attachment has a thumbnail.
  bool get hasThumbnail => thumbnailUrl?.isNotEmpty ?? false;
}
