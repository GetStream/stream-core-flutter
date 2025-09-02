import 'package:dio/dio.dart';

import '../../utils.dart';
import '../attachment_file.dart';
import 'uploaded_file.dart';

/// Content Delivery Network (CDN) client for file operations.
///
/// Provides methods for uploading files and images to the CDN and managing
/// uploaded content through the Stream Core API. Supports progress tracking
/// and request cancellation for optimal user experience.
///
/// All operations return [Result] objects for consistent error handling
/// across the SDK. Upload operations support optional progress callbacks
/// and cancellation tokens for better control over file transfers.
abstract interface class CdnClient {
  /// Uploads an image file to the CDN.
  ///
  /// The [image] must be a valid image file. Upload progress can be tracked
  /// using [onProgress], and the operation can be cancelled using [cancelToken].
  ///
  /// Returns a [Result] containing the [UploadedFile] information or an error.
  Future<Result<UploadedFile>> uploadImage(
    AttachmentFile image, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  });

  /// Uploads a file to the CDN.
  ///
  /// The [file] can be any supported file type. Upload progress can be tracked
  /// using [onProgress], and the operation can be cancelled using [cancelToken].
  ///
  /// Returns a [Result] containing the [UploadedFile] information or an error.
  Future<Result<UploadedFile>> uploadFile(
    AttachmentFile file, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  });

  /// Deletes an image from the CDN using its [url].
  ///
  /// The [url] must be a valid CDN URL for an image. The operation can be
  /// cancelled using [cancelToken] if needed.
  ///
  /// Returns a [Result] containing void on success or an error on failure.
  Future<Result<void>> deleteImage(
    String url, {
    CancelToken? cancelToken,
  });

  /// Deletes a file from the CDN using its [url].
  ///
  /// The [url] must be a valid CDN URL for a file. The operation can be
  /// cancelled using [cancelToken] if needed.
  ///
  /// Returns a [Result] containing void on success or an error on failure.
  Future<Result<void>> deleteFile(
    String url, {
    CancelToken? cancelToken,
  });
}
