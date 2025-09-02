import 'package:meta/meta.dart';

/// Represents an uploaded file result from the CDN.
///
/// Contains the URLs for accessing the uploaded file and its thumbnail (if available).
/// This class is returned by CDN upload operations to provide access to the uploaded content.
@immutable
class UploadedFile {
  /// Creates an [UploadedFile] with the specified URLs.
  const UploadedFile({
    this.fileUrl,
    this.thumbUrl,
  });

  /// The URL of the uploaded file.
  ///
  /// This is the primary URL for accessing the uploaded file content.
  final String? fileUrl;

  /// The URL of the file thumbnail.
  ///
  /// Primarily generated for video uploads to provide a preview frame.
  final String? thumbUrl;
}
