import 'dart:async';

import 'package:dio/dio.dart' show CancelToken;
import 'package:meta/meta.dart';

import '../../errors/stream_exception.dart';
import '../../utils.dart';
import '../attachment.dart';
import '../attachment_type.dart';
import '../cdn/cdn_client.dart';
import '../cdn/uploaded_file.dart';
import 'attachment_upload_batch.dart';
import 'attachment_upload_state.dart';
import 'attachment_uploader.dart';
import 'uploaded_attachment.dart';

/// One attachment upload, as a handle on the operation itself.
///
/// The upload is already running: the lifecycle is on [state], the outcome on
/// [result], and [cancel] calls it off. Watching is optional — a task that
/// nobody listens to runs to completion just the same.
///
/// ```dart
/// final task = uploader.upload(attachment);
///
/// task.state.listen((state) {
///   if (state case UploadInProgress(progress: UploadProgress(:final fraction?))) {
///     showProgress(fraction);
///   }
/// });
///
/// final result = await task.result;
/// result.fold(
///   onSuccess: submit,
///   onFailure: (error, _) => showRetry(error),
/// );
/// ```
///
/// Obtained from [StreamAttachmentUploader.upload], or from an
/// [AttachmentUploadBatch] through [AttachmentUploadBatch.task]. Nothing needs
/// disposing: [state] settles and stops once the upload has.
///
/// A task runs once and is never reset. Retrying means asking the uploader for
/// a new one, which is why [attachment] is kept.
///
/// See also:
///
///  * [AttachmentUploadBatch], which orchestrates several of these as one
///    operation.
///  * [AttachmentUploadState], the states an upload moves through.
abstract interface class AttachmentUploadTask {
  /// The local identity of the attachment being uploaded, and the key this
  /// upload is addressed by inside a batch.
  String get id;

  /// The attachment this task uploads.
  ///
  /// Kept for correlation and for retrying: a failed task carries everything
  /// needed to start another one.
  StreamAttachment get attachment;

  /// This upload's live state, its single canonical channel.
  ///
  /// Progress is part of the state rather than a source of its own, so a
  /// progress update and a lifecycle update can never disagree. The current
  /// state is always available synchronously, and is the first thing a new
  /// listener is given.
  ///
  /// An upload settles on exactly one of [UploadSuccess], [UploadFailed] or
  /// [UploadCancelled], delivered as a value — a failure or a cancellation
  /// never arrives as an error, so there is nothing to catch here either.
  StateEmitter<AttachmentUploadState> get state;

  /// This upload's outcome, always a value and never an error.
  ///
  /// A cancelled upload settles as a failure carrying a
  /// [StreamNetworkException] with [StreamNetworkException.isCancelled] set,
  /// the same shape every cancelled call in the SDK reports. A `Result` rather
  /// than a sealed outcome like [AttachmentUploadBatch.result], because one
  /// upload either produced an attachment or did not, and the reason it did
  /// not is a `StreamException` the caller already knows how to read.
  Future<Result<UploadedAttachment>> get result;

  /// Calls the upload off.
  ///
  /// Returns at once, is idempotent, and is safe on a settled task, which
  /// ignores it. Any other task settles as [UploadCancelled] straight away,
  /// without waiting to hear what became of the upload.
  ///
  /// Cancelling is not undoing: an answer that arrives afterwards is dropped,
  /// so an upload that had already been accepted keeps whatever it stored.
  void cancel();
}

/// The [AttachmentUploadTask] implementation.
@internal
final class AttachmentUploadTaskImpl implements AttachmentUploadTask {
  /// Creates an [AttachmentUploadTaskImpl] for [attachment], queued.
  AttachmentUploadTaskImpl({
    required this.attachment,
    required this._cdn,
  });

  @override
  final StreamAttachment attachment;

  final CdnClient _cdn;
  final _cancelToken = CancelToken();
  final _outcome = Completer<Result<UploadedAttachment>>();
  final _state = MutableStateEmitter<AttachmentUploadState>(const UploadQueued());

  var _started = false;

  // Read once and shared with the batch, which needs every length up front to
  // aggregate progress — without this the file would be measured twice.
  late final Future<int?> _measuredLength = runSafely(() => attachment.file.size).then((it) => it.getOrNull());

  /// The attachment's length in bytes, or `null` if it could not be read.
  Future<int?> get measuredLength => _measuredLength;

  @override
  String get id => attachment.id;

  @override
  StateEmitter<AttachmentUploadState> get state => _state;

  @override
  Future<Result<UploadedAttachment>> get result => _outcome.future;

  /// Starts the upload, unless it was already started or already settled.
  void start() {
    if (_started) return;
    _started = true;
    if (_outcome.isCompleted) return;
    scheduleMicrotask(_run);
  }

  @override
  void cancel() {
    if (_outcome.isCompleted) return;

    // The transport is told, but not waited on: a CDN client that ignores the
    // token or never answers must not leave this upload — or a batch waiting
    // on it — unable to settle.
    _stopSending();
    _settleCancelled();
  }

  Future<void> _run() async {
    if (_outcome.isCompleted) return;
    _state.value = const UploadPreparing();

    final totalBytes = await _measuredLength;
    if (_outcome.isCompleted) return;
    _state.value = UploadInProgress(progress: UploadProgress.none(totalBytes: totalBytes));

    final send = switch (attachment.type) {
      AttachmentType.image => _cdn.uploadImage,
      _ => _cdn.uploadFile,
    };

    final uploaded = await runSafely(
      () => send(
        attachment.file,
        cancelToken: _cancelToken,
        onProgress: (sent, total) => _trackProgress(sent: sent, wireTotal: total, fileBytes: totalBytes),
      ),
    ).then((it) => it.flatten<UploadedFile>());

    uploaded.fold(
      onSuccess: (file) => _settleSuccess(
        UploadedAttachment(
          id: attachment.id,
          type: attachment.type,
          custom: attachment.custom,
          remoteUrl: file.fileUrl,
          thumbnailUrl: file.thumbUrl,
        ),
      ),
      onFailure: _settleFailure,
    );
  }

  // The transport counts the multipart framing around the file as well as the
  // file, so its counts are scaled back to the attachment's own — reaching the
  // file's length when the request has gone out rather than as soon as the
  // bytes before the framing have.
  void _trackProgress({required int sent, required int wireTotal, required int? fileBytes}) {
    if (_outcome.isCompleted) return;

    if (fileBytes == null) {
      // Nothing to scale to, so what went out is reported as-is and the total
      // stays unknown, leaving `fraction` indeterminate rather than wrong.
      _state.value = UploadInProgress(progress: UploadProgress(sentBytes: sent, totalBytes: null));
      return;
    }

    final sentBytes = wireTotal > 0 ? (sent / wireTotal * fileBytes).round() : sent;
    _state.value = UploadInProgress(
      progress: UploadProgress(sentBytes: sentBytes.clamp(0, fileBytes), totalBytes: fileBytes),
    );
  }

  void _stopSending() {
    if (_cancelToken.isCancelled) return;
    _cancelToken.cancel('the upload was cancelled');
  }

  void _settleSuccess(UploadedAttachment uploaded) {
    _settle(UploadSuccess(attachment: uploaded), Result.success(uploaded));
  }

  void _settleFailure(Object error, StackTrace? stackTrace) {
    // A token this task cancelled is the authority on why the upload stopped.
    // A CDN client that honours the token but reports the abort in a shape of
    // its own would otherwise read as a failure, and make a batch give up.
    if (_cancelToken.isCancelled) return _settleCancelled(cause: error, stackTrace: stackTrace);

    // The CDN is a pluggable seam, so a foreign error is normalized here the
    // way every boundary normalizes.
    var exception = StreamException.tryFrom(error);
    exception ??= StreamClientException(
      message: 'The upload failed',
      cause: error,
      stackTrace: stackTrace,
    );

    // The CDN reported the cancellation itself, in the shape a caller wants and
    // carrying its own transport detail. Re-wrapping it would bury that in a
    // cause to say nothing new.
    if (exception case final StreamNetworkException cancelled when cancelled.isCancelled) {
      return _settle(const UploadCancelled(), Result.failure(cancelled, stackTrace));
    }

    _settle(UploadFailed(error: exception), Result.failure(exception, stackTrace));
  }

  void _settleCancelled({Object? cause, StackTrace? stackTrace}) {
    final exception = StreamNetworkException(
      message: 'The upload was cancelled',
      isCancelled: true,
      cause: cause,
      stackTrace: stackTrace,
    );

    _settle(const UploadCancelled(), Result.failure(exception, stackTrace));
  }

  // The first terminal state committed wins: a success that lands while a
  // cancellation is being applied cannot un-cancel the task, and the reverse
  // cannot happen either.
  void _settle(AttachmentUploadState finalState, Result<UploadedAttachment> outcome) {
    if (_outcome.isCompleted) return;
    _state.value = finalState;
    _state.close();
    _outcome.complete(outcome);
  }
}
