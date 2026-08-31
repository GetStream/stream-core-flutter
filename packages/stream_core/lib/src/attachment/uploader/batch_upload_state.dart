import 'package:equatable/equatable.dart';

import '../../errors/stream_exception.dart';
import '../../utils.dart';
import '../attachment.dart';
import 'uploaded_attachment.dart';

/// The live state of a batch upload.
///
/// Every state carries the batch's [progress], so a caller that only draws a
/// progress bar never has to match on the state at all:
///
/// ```dart
/// batch.state.listen((state) => updateOverallProgress(state.progress));
/// ```
sealed class BatchUploadState extends Equatable {
  /// Creates a [BatchUploadState].
  const BatchUploadState();

  /// How far the batch has got.
  BatchUploadProgress get progress;

  /// Whether the batch has stopped, with no further state to follow.
  bool get isFinal => this is BatchFinished;

  @override
  List<Object?> get props => [progress];
}

/// The batch has not started any of its uploads yet.
final class BatchQueued extends BatchUploadState {
  /// Creates a [BatchQueued] state.
  const BatchQueued({required this.progress});

  @override
  final BatchUploadProgress progress;
}

/// The batch is working through its uploads.
final class BatchInProgress extends BatchUploadState {
  /// Creates a [BatchInProgress] state.
  const BatchInProgress({required this.progress});

  @override
  final BatchUploadProgress progress;
}

/// An upload failed under a batch that gives up on the first failure, and the batch
/// is calling off the uploads that have not settled.
final class BatchStopping extends BatchUploadState {
  /// Creates a [BatchStopping] state.
  const BatchStopping({
    required this.failedUploadId,
    required this.error,
    required this.progress,
  });

  /// The id of the upload whose failure stopped the batch.
  final String failedUploadId;

  /// What went wrong with that upload.
  final StreamException error;

  @override
  final BatchUploadProgress progress;

  @override
  List<Object?> get props => [...super.props, failedUploadId, error];
}

/// The batch was cancelled and is waiting for its uploads to stop.
///
/// Uploads that had already succeeded keep their outcome; the rest settle as
/// cancelled, and the batch finishes as [BatchUploadCancelled].
final class BatchCancelling extends BatchUploadState {
  /// Creates a [BatchCancelling] state.
  const BatchCancelling({required this.progress});

  @override
  final BatchUploadProgress progress;
}

/// Every upload in the batch has settled, and [result] holds one outcome per
/// requested attachment.
final class BatchFinished extends BatchUploadState {
  /// Creates a [BatchFinished] state.
  const BatchFinished({
    required this.result,
    required this.progress,
  });

  /// Every attachment's outcome, and how the batch came to stop.
  final BatchUploadResult result;

  @override
  final BatchUploadProgress progress;

  @override
  List<Object?> get props => [...super.props, result];
}

/// How far a batch upload has got, both in attachments and in bytes.
///
/// The counts and the bytes answer different questions, so both are kept:
/// "uploading 3 of 7" and "5 uploaded · 1 failed · 1 remaining" come from the
/// counts, while a progress bar comes from [fraction].
///
/// ```dart
/// '${progress.finished} of ${progress.total}'
///
/// // `null` until every attachment's length is known, and for a batch with
/// // one that could never be read.
/// if (progress.fraction case final fraction?) drawBar(fraction);
/// ```
final class BatchUploadProgress extends Equatable {
  /// Creates a [BatchUploadProgress].
  const BatchUploadProgress({
    required this.total,
    required this.queued,
    required this.preparing,
    required this.uploading,
    required this.succeeded,
    required this.failed,
    required this.cancelled,
    required this.sentBytes,
    required this.totalBytes,
  });

  /// The number of attachments in the batch.
  final int total;

  /// How many attachments are waiting for a turn.
  final int queued;

  /// How many attachments are being read.
  final int preparing;

  /// How many attachments are on their way.
  final int uploading;

  /// How many attachments made it.
  final int succeeded;

  /// How many attachments failed.
  final int failed;

  /// How many attachments were called off.
  final int cancelled;

  /// The number of bytes sent so far, across the batch.
  ///
  /// An attachment whose length could not be read still contributes to this,
  /// so it is not a count [totalBytes] can be measured against. [totalBytes]
  /// is `null` whenever a batch holds one, and [fraction] reads as unknown for
  /// the whole batch while that is true.
  final int sentBytes;

  /// The number of attachment bytes the batch has to send.
  ///
  /// `null` until every attachment's length is known — an attachment that has
  /// not been read yet cannot contribute to the total, and a total missing
  /// one of its terms would understate the work left.
  final int? totalBytes;

  /// How many attachments have settled.
  int get finished => succeeded + failed + cancelled;

  /// The sent fraction, between 0.0 and 1.0, or `null` while [totalBytes] is
  /// still unknown.
  ///
  /// `1.0` for a batch with nothing to send. Byte weighted rather than count
  /// weighted: a 1 MB image beside a 999 MB video is 0.1% of the batch, not
  /// half of it.
  double? get fraction {
    final total = totalBytes;
    if (total == null) return null;
    if (total == 0) return 1;
    return (sentBytes / total).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
    total,
    queued,
    preparing,
    uploading,
    succeeded,
    failed,
    cancelled,
    sentBytes,
    totalBytes,
  ];
}

/// One attachment's place in a [BatchUploadResult].
final class BatchUploadItemResult extends Equatable {
  /// Creates a [BatchUploadItemResult].
  const BatchUploadItemResult({
    required this.attachment,
    required this.result,
  });

  /// The attachment this outcome concerns.
  final StreamAttachment attachment;

  /// The upload's own outcome, failure as data.
  ///
  /// A cancelled upload reads as a failure carrying a [StreamNetworkException]
  /// with [StreamNetworkException.isCancelled] set.
  final Result<UploadedAttachment> result;

  @override
  List<Object?> get props => [attachment, result];
}

/// One outcome per requested attachment, and how the batch came to stop.
///
/// An upload failing does not make the batch fail — a batch of three where the
/// middle one was refused still ran as asked, and finishes as
/// [BatchUploadCompleted]. Each attachment's own outcome is on its
/// [BatchUploadItemResult].
///
/// Sealed, so a `switch` over the three ways a batch can end is exhaustive,
/// and the failure that gave up on one is only reachable once it has been
/// matched:
///
/// ```dart
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
/// These carry `BatchUpload` where [BatchUploadState]'s members carry only
/// `Batch` on purpose: it is what tells a reader which of the two sealed
/// families a name belongs to, and it keeps [BatchCancelling] a batch still
/// calling its uploads off rather than one letter from a result.
sealed class BatchUploadResult extends Equatable {
  /// Creates a [BatchUploadResult].
  const BatchUploadResult({required this.items});

  /// One outcome per requested attachment, in the order they were given.
  final List<BatchUploadItemResult> items;

  @override
  List<Object?> get props => [items];
}

/// Every attachment reached a terminal state on its own.
final class BatchUploadCompleted extends BatchUploadResult {
  /// Creates a [BatchUploadCompleted] result.
  const BatchUploadCompleted({required super.items});
}

/// An upload failed in a batch that gives up on the first failure, and the
/// rest were called off.
final class BatchUploadStoppedOnError extends BatchUploadResult {
  /// Creates a [BatchUploadStoppedOnError] result.
  const BatchUploadStoppedOnError({required super.items, required this.error});

  /// The failure that gave up on the batch.
  ///
  /// Worth reading rather than hunting for in [items]: the uploads this
  /// failure called off report cancellations of their own, which say nothing
  /// about the cause.
  final StreamException error;

  @override
  List<Object?> get props => [...super.props, error];
}

/// The batch was called off through `batch.cancel()`.
final class BatchUploadCancelled extends BatchUploadResult {
  /// Creates a [BatchUploadCancelled] result.
  const BatchUploadCancelled({required super.items});
}
