import '../attachment.dart';
import '../cdn/cdn_client.dart';
import 'attachment_upload_batch.dart';
import 'attachment_upload_task.dart';

/// Uploads [StreamAttachment]s to remote storage.
///
/// Both methods return at once, handing back the running operation rather than
/// a future to wait on: an upload has a lifecycle to watch and a way to be
/// called off, and both belong to the object that represents it.
abstract interface class AttachmentUploader {
  /// Starts uploading [attachment], and returns the task running it.
  AttachmentUploadTask upload(StreamAttachment attachment);

  /// Starts uploading every attachment in [attachments], and returns the batch
  /// orchestrating them.
  AttachmentUploadBatch uploadBatch(
    Iterable<StreamAttachment> attachments, {
    int maxConcurrent = 3,
    bool eagerError = false,
  });
}

/// The [AttachmentUploader] that uploads through a [CdnClient].
///
/// ```dart
/// final uploader = StreamAttachmentUploader(cdn: cdnClient);
///
/// final task = uploader.upload(attachment);
/// task.state.listen(render);
///
/// final result = await task.result;
/// result.fold(
///   onSuccess: (uploaded) => print('Uploaded: ${uploaded.remoteUrl}'),
///   onFailure: (error, _) => print('Upload failed: $error'),
/// );
/// ```
class StreamAttachmentUploader implements AttachmentUploader {
  /// Creates a [StreamAttachmentUploader] uploading through the given
  /// [CdnClient].
  const StreamAttachmentUploader({
    required this._cdn,
  });

  final CdnClient _cdn;

  /// Starts uploading [attachment], and returns the task running it.
  ///
  /// The upload's whole lifecycle plays out on
  /// [AttachmentUploadTask.state], it can be called off through
  /// [AttachmentUploadTask.cancel], and its outcome awaited through
  /// [AttachmentUploadTask.result].
  ///
  /// Each call starts a new upload; a task is never reused, which is what
  /// makes retrying an attachment a matter of asking again.
  @override
  AttachmentUploadTask upload(StreamAttachment attachment) {
    return AttachmentUploadTaskImpl(
      attachment: attachment,
      cdn: _cdn,
    )..start();
  }

  /// Starts uploading every attachment in [attachments], and returns the batch
  /// orchestrating them.
  ///
  /// At most [maxConcurrent] uploads are in flight at any moment. When
  /// [eagerError] is true the batch gives up on the first failure, calling off
  /// the uploads that have not settled and never starting the ones that have
  /// not begun; when false every attachment is attempted whatever the others
  /// do. An empty batch is valid, and finishes at once with no items.
  ///
  /// Throws an [ArgumentError] if [maxConcurrent] is not greater than zero, or
  /// if two attachments share an id — a batch addresses its uploads by id, so
  /// ids must be unique within one.
  @override
  AttachmentUploadBatch uploadBatch(
    Iterable<StreamAttachment> attachments, {
    int maxConcurrent = 3,
    bool eagerError = false,
  }) {
    return AttachmentUploadBatchImpl(
      attachments: attachments,
      cdn: _cdn,
      maxConcurrent: maxConcurrent,
      eagerError: eagerError,
    );
  }
}
