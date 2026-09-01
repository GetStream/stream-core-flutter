import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../errors/stream_exception.dart';
import '../../utils.dart';
import '../attachment.dart';
import '../cdn/cdn_client.dart';
import 'attachment_upload_state.dart';
import 'attachment_upload_task.dart';
import 'attachment_uploader.dart';
import 'batch_upload_state.dart';
import 'uploaded_attachment.dart';

/// Several attachment uploads run as one operation.
///
/// A batch orchestrates [AttachmentUploadTask]s; it does not upload anything
/// itself. It decides only what runs when and when the whole thing is done —
/// everything per-attachment is reached through the task that owns it, so
/// cancelling, watching or awaiting one attachment is the same API whether or
/// not it is part of a batch:
///
/// ```dart
/// final batch = uploader.uploadBatch(attachments);
///
/// batch.state.listen((state) => showProgress(state.progress));
/// batch.task('video-1')?.cancel();
///
/// switch (await batch.result) {
///   case BatchUploadCompleted(:final items):
///     submit(items);
///   case BatchUploadStoppedOnError(:final error):
///     report(error);
///   case BatchUploadCancelled():
///     break;
/// }
/// ```
///
/// One upload failing does not fail the batch: a batch of three where the
/// middle one was refused still ran as asked, and finishes as
/// [BatchUploadCompleted] with that failure on its own item. Only
/// `eagerError` changes that, and only for the first failure.
///
/// Obtained from [StreamAttachmentUploader.uploadBatch] rather than
/// constructed. Nothing needs disposing: [state] settles and stops once the
/// batch has finished, and [cancel] is how a batch is stopped before then —
/// including a batch abandoned while a [CdnClient] never answers, which
/// finishes on nothing else.
///
/// See also:
///
///  * [AttachmentUploadTask], the upload a batch is built out of.
///  * [BatchUploadState], the states a batch moves through.
///  * [BatchUploadResult], the three ways a batch can end.
abstract interface class AttachmentUploadBatch {
  /// This batch's identifier, unique among the batches this process makes.
  ///
  /// Assigned when the batch is created and meaningful only within the process
  /// that made it, so it serves to tell two batches apart in log records
  /// rather than to address anything.
  String get id;

  /// This batch's live state, carrying its aggregate progress.
  ///
  /// The current state is always available synchronously, and is the first
  /// thing a new listener is given. No state follows [BatchFinished].
  StateEmitter<BatchUploadState> get state;

  /// The tasks this batch orchestrates, in the order the attachments were
  /// given.
  ///
  /// Fixed when the batch is created and unmodifiable: a batch never grows or
  /// shrinks, so this is also the order [BatchUploadResult.items] arrives in.
  List<AttachmentUploadTask> get uploads;

  /// Every attachment's outcome, once they have all settled.
  ///
  /// Never throws, and never fails as a whole: an upload's own failure is
  /// carried by its [BatchUploadItemResult]. Completes however the batch ended,
  /// cancellation included, so awaiting it is always safe.
  Future<BatchUploadResult> get result;

  /// The task uploading the attachment with the given [id], or `null` if this
  /// batch has none.
  ///
  /// The id is the [StreamAttachment.id] the batch was given, not this batch's
  /// own [id].
  AttachmentUploadTask? task(String id);

  /// Calls off every upload that has not settled.
  ///
  /// Returns at once and is idempotent. A batch that has finished ignores it,
  /// and so does one already giving up on a failure — it has called its
  /// remaining uploads off, and finishes as [BatchUploadStoppedOnError] rather
  /// than changing its mind.
  ///
  /// Otherwise uploads that already succeeded keep their outcome, the batch
  /// moves to [BatchCancelling] until the rest have stopped, and it finishes as
  /// [BatchUploadCancelled].
  ///
  /// Cancelling is not undoing: an attachment already accepted stays where it
  /// was put.
  void cancel();
}

/// The [AttachmentUploadBatch] implementation.
@internal
final class AttachmentUploadBatchImpl implements AttachmentUploadBatch {
  /// Creates an [AttachmentUploadBatchImpl] and starts scheduling.
  ///
  /// Throws an [ArgumentError] if two attachments share an id, which would
  /// make [task] ambiguous, or if [maxConcurrent] is not positive.
  factory AttachmentUploadBatchImpl({
    required Iterable<StreamAttachment> attachments,
    required CdnClient cdn,
    int maxConcurrent = 3,
    bool eagerError = false,
  }) {
    if (maxConcurrent <= 0) {
      throw ArgumentError.value(maxConcurrent, 'maxConcurrent', 'A batch that may run no uploads would never finish');
    }

    // Read once: an `Iterable` is free to be lazy, and a batch validated over
    // one pass but built from another could disagree about what is in it.
    final requested = attachments.toList();

    final ids = <String>{};
    for (final attachment in requested) {
      if (ids.add(attachment.id)) continue;
      throw ArgumentError.value(attachment.id, 'attachments', 'Attachment ids must be unique within a batch');
    }

    final tasks = [
      for (final attachment in requested) AttachmentUploadTaskImpl(attachment: attachment, cdn: cdn),
    ];

    return AttachmentUploadBatchImpl._(
      tasks,
      maxConcurrent: maxConcurrent,
      eagerError: eagerError,
    );
  }

  AttachmentUploadBatchImpl._(
    this._tasks, {
    required this.maxConcurrent,
    required this.eagerError,
  }) : id = const Uuid().v4() {
    for (final task in _tasks) {
      _tasksById[task.id] = task;
      _measure(task);
      task.state.listen((state) => _onTaskState(task, state));
      unawaited(task.result.then((result) => _onTaskSettled(task, result)));
    }

    scheduleMicrotask(_pump);
  }

  @override
  final String id;

  /// The most uploads allowed to be in flight at once.
  final int maxConcurrent;

  /// Whether the batch gives up on the first failure.
  final bool eagerError;

  final List<AttachmentUploadTaskImpl> _tasks;
  final _tasksById = <String, AttachmentUploadTaskImpl>{};

  // Measured attachment lengths; membership means the length is known, so a
  // zero-length attachment counts as measured while an unreadable one does not.
  final _totals = <String, int>{};

  // The last byte count recorded for an upload, which only a settled one is
  // read from — a live upload is read straight off its state.
  final _sent = <String, int>{};
  final _started = <String>{};
  final _active = <String>{};
  final _outcome = Completer<BatchUploadResult>();

  late final _state = MutableStateEmitter<BatchUploadState>(BatchQueued(progress: _aggregate()));

  var _settledCount = 0;
  _BatchEnding? _ending;
  String? _failedUploadId;
  StreamException? _failureError;
  StackTrace? _failureStackTrace;
  var _finishing = false;

  @override
  StateEmitter<BatchUploadState> get state => _state;

  @override
  List<AttachmentUploadTask> get uploads => UnmodifiableListView(_tasks);

  @override
  Future<BatchUploadResult> get result => _outcome.future;

  @override
  AttachmentUploadTask? task(String id) => _tasksById[id];

  @override
  void cancel() {
    if (_finishing || _ending != null || _outcome.isCompleted) return;
    _ending = _BatchEnding.cancelled;
    _cancelUnsettled();
    _emitState();
  }

  // Fills every free slot, in input order. An upload the batch already settled
  // on its behalf — because it was cancelled, or the batch gave up — reads as
  // final and is skipped, so giving up needs no separate check here.
  void _pump() {
    if (_outcome.isCompleted) return;

    for (final task in _tasks) {
      if (_active.length >= maxConcurrent) break;
      if (_started.contains(task.id) || task.state.value.isFinal) continue;
      _started.add(task.id);
      _active.add(task.id);
      task.start();
    }

    _emitState();
    unawaited(_finishIfSettled());
  }

  // A queued attachment's length is known long before its turn comes, and an
  // aggregate total missing one of its terms is no total at all — so every
  // length is read up front rather than as each upload starts.
  void _measure(AttachmentUploadTaskImpl task) {
    unawaited(
      task.measuredLength.then((length) {
        if (length == null) return;
        _totals[task.id] = length;
        _emitState();
      }),
    );
  }

  void _onTaskState(AttachmentUploadTaskImpl task, AttachmentUploadState state) {
    if (state case UploadInProgress(:final progress)) _sent[task.id] = progress.sentBytes;
    _emitState();
  }

  void _onTaskSettled(AttachmentUploadTaskImpl task, Result<UploadedAttachment> result) {
    _active.remove(task.id);
    _settledCount += 1;

    // Only a failure gives up on the batch. A cancellation is a decision
    // somebody already made, about one upload and no others. The state says
    // which of the two it was; the result carries where it was raised.
    if (task.state.value case UploadFailed(:final error)) {
      _stopOnError(task.id, error, result.stackTraceOrNull());
    }

    _pump();
  }

  void _stopOnError(String uploadId, StreamException error, StackTrace? stackTrace) {
    if (!eagerError) return;
    if (_ending != null) return;

    _ending = _BatchEnding.stoppedOnError;
    _failedUploadId = uploadId;
    _failureError = error;
    _failureStackTrace = stackTrace;
    _cancelUnsettled();
  }

  void _cancelUnsettled() {
    for (final task in _tasks) {
      if (task.state.value.isFinal) continue;
      task.cancel();
    }
  }

  void _emitState() {
    if (_finishing || _state.isClosed) return;

    final progress = _aggregate();
    _state.value = switch ((_ending, _failedUploadId, _failureError)) {
      (_BatchEnding.cancelled, _, _) => BatchCancelling(progress: progress),
      (_BatchEnding.stoppedOnError, final failedUploadId?, final error?) => BatchStopping(
        failedUploadId: failedUploadId,
        error: error,
        progress: progress,
      ),
      _ => _started.isEmpty ? BatchQueued(progress: progress) : BatchInProgress(progress: progress),
    };
  }

  Future<void> _finishIfSettled() async {
    if (_finishing || _outcome.isCompleted) return;

    // Counted rather than read off the tasks: they all reach a terminal state
    // before the batch is told about any of them, so a batch that waited only
    // for the states would finish before it had seen the failure that stopped
    // it, and call itself completed.
    if (_settledCount < _tasks.length) return;
    _finishing = true;

    // Read before the suspension below: a `cancel()` can still land while this
    // is waiting, and a batch whose uploads all succeeded did not end up
    // cancelled.
    final ending = _ending;
    final failureError = _failureError;
    final failureStackTrace = _failureStackTrace;
    final progress = _aggregate();

    // Every task is terminal, so every outcome is already there; awaiting them
    // is how the batch reads them without restating how a task settles.
    final results = await Future.wait(_tasks.map((task) => task.result));
    final items = List<BatchUploadItemResult>.unmodifiable([
      for (final (index, task) in _tasks.indexed)
        BatchUploadItemResult(attachment: task.attachment, result: results[index]),
    ]);

    final result = switch (ending) {
      _BatchEnding.stoppedOnError => BatchUploadStoppedOnError(
        items: items,
        error: failureError!,
        stackTrace: failureStackTrace,
      ),
      _BatchEnding.cancelled => BatchUploadCancelled(items: items),
      null => BatchUploadCompleted(items: items),
    };

    _state.value = BatchFinished(result: result, progress: progress);
    await _state.close();

    _outcome.complete(result);
  }

  BatchUploadProgress _aggregate() {
    final states = [for (final task in _tasks) task.state.value];

    // Bytes and counts come from one clock: every count is derived from the
    // state it is reported beside. A progress event still queued behind a
    // settle would otherwise leave a finished batch reporting a fraction of
    // the bytes it sent.
    var sentBytes = 0;
    for (final task in _tasks) {
      sentBytes += switch (task.state.value) {
        UploadInProgress(:final progress) => progress.sentBytes,
        UploadSuccess() => _totals[task.id] ?? _sent[task.id] ?? 0,
        _ => _sent[task.id] ?? 0,
      };
    }

    // An attachment whose length could not be read contributes no term, and a
    // total missing one of its terms would understate the work left.
    final totalKnown = _totals.length == _tasks.length;
    final totalBytes = _totals.values.fold(0, (total, it) => total + it);

    return BatchUploadProgress(
      total: _tasks.length,
      queued: states.whereType<UploadQueued>().length,
      preparing: states.whereType<UploadPreparing>().length,
      uploading: states.whereType<UploadInProgress>().length,
      succeeded: states.whereType<UploadSuccess>().length,
      failed: states.whereType<UploadFailed>().length,
      cancelled: states.whereType<UploadCancelled>().length,
      sentBytes: sentBytes,
      totalBytes: totalKnown ? totalBytes : null,
    );
  }
}

// Which of the two deliberate endings a batch is heading for, held while it
// winds down and read once to build the result it finishes with.
enum _BatchEnding { stoppedOnError, cancelled }
