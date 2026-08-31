import '../attachment.dart';
import '../cdn/cdn_client.dart';
import 'attachment_upload_batch.dart';
import 'attachment_upload_task.dart';

/// An uploader of [StreamAttachment]s, sending their bytes through a
/// [CdnClient].
///
/// Both methods return at once, handing back the running operation rather than
/// a future to wait on: an upload has a lifecycle worth watching and a way to
/// be called off, and both belong to the object that represents it.
///
/// An upload that fails does not throw. It carries its error, so the outcome is
/// read rather than caught, and one attachment failing never interrupts the
/// caller. Arguments that could not describe an upload at all are the exception
/// and do throw, as documented per method.
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
///
/// Where the bytes go is the [CdnClient]'s business; this decides which
/// endpoint an attachment belongs to, tracks how far it has got, and answers
/// for it. Uploading somewhere else is therefore a matter of supplying a
/// different [CdnClient], not of replacing this.
///
/// Stateless, so one uploader serves any number of concurrent uploads and
/// batches; nothing is shared between them.
///
/// See also:
///
///  * [AttachmentUploadTask], which represents one upload.
///  * [AttachmentUploadBatch], which represents several run as one operation.
///  * [CdnClient], the seam an app supplies to upload elsewhere.
class StreamAttachmentUploader {
  /// Creates a [StreamAttachmentUploader] uploading through the given
  /// [CdnClient].
  const StreamAttachmentUploader({
    required this._cdn,
  });

  final CdnClient _cdn;

  /// Starts uploading [attachment], and returns the task running it.
  ///
  /// The upload's whole lifecycle plays out on [AttachmentUploadTask.state], it
  /// can be called off through [AttachmentUploadTask.cancel], and its outcome
  /// awaited through [AttachmentUploadTask.result].
  ///
  /// Each call starts a new upload and a task is never reused, which is what
  /// makes retrying an attachment a matter of asking again.
  AttachmentUploadTask upload(StreamAttachment attachment) {
    return AttachmentUploadTaskImpl(
      attachment: attachment,
      cdn: _cdn,
    )..start();
  }

  /// Starts uploading every attachment in [attachments], and returns the batch
  /// orchestrating them.
  ///
  /// At most [maxConcurrent] uploads are in flight at any moment; the rest wait
  /// their turn in the order they were given. When [eagerError] is true the
  /// batch gives up on the first failure, calling off the uploads that have not
  /// settled and never starting the ones that have not begun; when false every
  /// attachment is attempted whatever the others do. An empty batch is valid,
  /// and finishes at once with no items.
  ///
  /// Throws an [ArgumentError] if [maxConcurrent] is not greater than zero, or
  /// if two attachments share an id — a batch addresses its uploads by id, so
  /// ids must be unique within one.
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
