import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../utils.dart';
import '../attachment.dart';
import '../attachment_type.dart';
import '../cdn/cdn_client.dart';
import 'uploaded_attachment.dart';

/// Callback for tracking upload progress.
///
/// Receives the upload [progress] as a value between 0.0 and 1.0.
typedef OnUploadProgress = void Function(double progress);

/// Exception thrown when an attachment upload fails.
///
/// Provides context about which specific attachment failed and the underlying
/// cause for debugging upload issues.
class AttachmentUploadException implements Exception {
  /// Creates an [AttachmentUploadException] with the specified [id] and [cause].
  const AttachmentUploadException({
    required this.id,
    required this.cause,
  });

  /// The ID of the attachment that failed to upload.
  final String id;

  /// The underlying cause of the upload failure.
  final Object cause;

  @override
  String toString() => 'AttachmentUploadException(id: $id, cause: $cause)';
}

/// Uploads [StreamAttachment] objects to remote storage.
///
/// Provides upload functionality with progress tracking and error handling.
/// Automatically selects the appropriate upload method based on attachment
/// type and returns [Result] objects for explicit success/failure handling.
///
/// Example usage:
/// ```dart
/// final uploader = StreamAttachmentUploader(cdn: cdnClient);
///
/// final result = await uploader.upload(attachment);
/// result.fold(
///   onSuccess: (uploaded) => print('Uploaded: ${uploaded.remoteUrl}'),
///   onFailure: (error, _) => print('Upload failed: $error'),
/// );
/// ```
class StreamAttachmentUploader {
  /// Creates a [StreamAttachmentUploader] with the specified [cdn] client.
  const StreamAttachmentUploader({
    required CdnClient cdn,
  }) : _cdn = cdn;

  // The CDN client used for upload operations.
  final CdnClient _cdn;

  /// Uploads a single attachment to remote storage.
  ///
  /// Returns a [Result] containing the [UploadedAttachment] on success or
  /// an [AttachmentUploadException] on failure. Progress updates are provided
  /// through the optional [onProgress] callback.
  Future<Result<UploadedAttachment>> upload(
    StreamAttachment attachment, {
    OnUploadProgress? onProgress,
  }) async {
    final uploadFn = switch (attachment.type) {
      AttachmentType.image => _cdn.uploadImage,
      _ => _cdn.uploadFile,
    };

    final result = await uploadFn(
      attachment.file,
      onProgress: onProgress?.let(
        (f) => (uploaded, total) {
          if (total == 0) return f(0);
          final progress = uploaded / total;
          return f(progress.clamp(0.0, 1.0));
        },
      ),
    );

    return result.fold(
      onSuccess: (data) {
        final uploaded = UploadedAttachment(
          id: attachment.id,
          type: attachment.type,
          custom: attachment.custom,
          remoteUrl: data.fileUrl,
          thumbnailUrl: data.thumbUrl,
        );

        return Result.success(uploaded);
      },
      onFailure: (cause, stackTrace) {
        final ex = AttachmentUploadException(
          id: attachment.id,
          cause: cause,
        );

        return Result.failure(ex, stackTrace);
      },
    );
  }
}

/// Callback for tracking batch upload progress.
///
/// Receives the [attachmentId] and upload [progress] as a value between 0.0 and 1.0
/// for individual attachments during batch upload.
typedef OnBatchUploadProgress = void Function(String attachmentId, double progress);

/// Extension providing batch upload functionality for [StreamAttachmentUploader].
///
/// Adds reactive batch upload with controlled concurrency. Results are emitted
/// as individual uploads complete, enabling immediate UI updates and partial
/// success handling.
extension StreamAttachmentUploaderBatch on StreamAttachmentUploader {
  /// Uploads multiple attachments as a stream of results.
  ///
  /// Processes [attachments] concurrently with [maxConcurrent] limit, emitting
  /// [Result] objects as each upload completes. Progress updates are provided
  /// through the optional [onProgress] callback.
  ///
  /// When [eagerError] is true, the stream throws an exception and closes
  /// immediately on the first upload failure. When false (default), failed
  /// uploads are emitted as [Result.failure] and processing continues.
  ///
  /// Returns a [Stream] of [Result] objects in completion order, not input order.
  Stream<Result<UploadedAttachment>> uploadBatch(
    Iterable<StreamAttachment> attachments, {
    OnBatchUploadProgress? onProgress,
    int maxConcurrent = 5,
    bool eagerError = false,
  }) async* {
    // Early return for empty list
    if (attachments.isEmpty) return;

    // Create a stream that uploads attachments with controlled concurrency
    final uploadStream = Stream.fromIterable(attachments).flatMap(
      maxConcurrent: maxConcurrent,
      (attachment) => Stream.fromFuture(
        upload(
          attachment,
          onProgress: onProgress?.let(
            (f) =>
                (progress) => f(attachment.id, progress),
          ),
        ),
      ),
    );

    // Yield results as they complete
    await for (final result in uploadStream) {
      // If eagerError is enabled, throw on first failure
      if (result.exceptionOrNull() case final error? when eagerError) {
        final stackTrace = result.stackTraceOrNull();
        Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);
      }

      yield result;
    }
  }
}
