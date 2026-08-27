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

/// The outcome of one attachment's upload within a batch, paired with the
/// attachment it belongs to.
///
/// The failure inside the result is the upload's own error, unwrapped — an
/// upload refused by the server reads as the same exception kind a refused
/// request does. Which attachment it concerns travels here, beside the
/// outcome, rather than inside it.
typedef AttachmentUploadResult = ({String attachmentId, Result<UploadedAttachment> result});

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
  /// Creates a [StreamAttachmentUploader] uploading through the given [CdnClient].
  const StreamAttachmentUploader({
    required this._cdn,
  });

  // The CDN client used for upload operations.
  final CdnClient _cdn;

  /// Uploads a single attachment to remote storage.
  ///
  /// Returns a [Result] containing the [UploadedAttachment] on success, or
  /// the upload's own failure otherwise. Progress updates are provided
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

    return result.map(
      (data) => UploadedAttachment(
        id: attachment.id,
        type: attachment.type,
        custom: attachment.custom,
        remoteUrl: data.fileUrl,
        thumbnailUrl: data.thumbUrl,
      ),
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
  /// Uploads multiple attachments as a stream of per-attachment outcomes.
  ///
  /// Processes [attachments] concurrently with [maxConcurrent] limit, emitting
  /// an [AttachmentUploadResult] as each upload completes. Progress updates
  /// are provided through the optional [onProgress] callback.
  ///
  /// When [eagerError] is true, the stream throws an exception and closes
  /// immediately on the first upload failure. When false (default), failed
  /// uploads are emitted as failures and processing continues.
  ///
  /// Returns a [Stream] of outcomes in completion order, not input order.
  Stream<AttachmentUploadResult> uploadBatch(
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
        ).then((result) => (attachmentId: attachment.id, result: result)),
      ),
    );

    // Yield outcomes as they complete
    await for (final outcome in uploadStream) {
      // If eagerError is enabled, throw on first failure
      if (outcome.result.exceptionOrNull() case final error? when eagerError) {
        final stackTrace = outcome.result.stackTraceOrNull();
        Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);
      }

      yield outcome;
    }
  }
}
