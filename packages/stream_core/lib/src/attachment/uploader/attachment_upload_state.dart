import 'package:equatable/equatable.dart';

import '../../errors/stream_exception.dart';
import 'batch_upload_state.dart';
import 'uploaded_attachment.dart';

/// The live state of one attachment upload.
///
/// This is the upload's single canonical channel: progress is part of the
/// state rather than a source of its own, so there is never a moment where a
/// progress update and a lifecycle update disagree.
///
/// ```dart
/// task.state.listen((state) {
///   switch (state) {
///     case UploadQueued():
///       break;
///     case UploadPreparing():
///       showPreparing();
///     case UploadInProgress(:final progress):
///       updateProgress(progress.fraction ?? 0);
///     case UploadSuccess(:final attachment):
///       showUploaded(attachment);
///     case UploadFailed(:final error):
///       showRetry(error);
///     case UploadCancelled():
///       removeAttachment();
///   }
/// });
/// ```
///
/// An upload settles on exactly one of [UploadSuccess], [UploadFailed] or
/// [UploadCancelled], and never moves again.
sealed class AttachmentUploadState extends Equatable {
  /// Creates an [AttachmentUploadState].
  const AttachmentUploadState();

  /// Whether the upload has settled, with no further state to follow.
  bool get isFinal => switch (this) {
    UploadQueued() || UploadPreparing() || UploadInProgress() => false,
    UploadSuccess() || UploadFailed() || UploadCancelled() => true,
  };

  @override
  List<Object?> get props => const [];
}

/// The upload is waiting for a turn, and has not started sending.
final class UploadQueued extends AttachmentUploadState {
  /// Creates an [UploadQueued] state.
  const UploadQueued();
}

/// The upload is reading the file it is about to send.
final class UploadPreparing extends AttachmentUploadState {
  /// Creates an [UploadPreparing] state.
  const UploadPreparing();
}

/// The upload is on its way, [progress] bytes of the file sent so far.
final class UploadInProgress extends AttachmentUploadState {
  /// Creates an [UploadInProgress] state.
  const UploadInProgress({required this.progress});

  /// How far the upload has got.
  final UploadProgress progress;

  @override
  List<Object?> get props => [progress];
}

/// The upload made it, [attachment] carrying its remote urls.
final class UploadSuccess extends AttachmentUploadState {
  /// Creates an [UploadSuccess] state.
  const UploadSuccess({required this.attachment});

  /// The uploaded attachment.
  final UploadedAttachment attachment;

  @override
  List<Object?> get props => [attachment];
}

/// The upload failed with [error].
///
/// The one state that offers the caller a retry, and the only one that
/// triggers a batch that gives up on the first failure — a cancellation is a
/// decision, not a failure.
final class UploadFailed extends AttachmentUploadState {
  /// Creates an [UploadFailed] state.
  const UploadFailed({required this.error});

  /// What went wrong.
  final StreamException error;

  @override
  List<Object?> get props => [error];
}

/// The upload was called off.
///
/// The terminal `Result` says the same thing the rest of the SDK says about a
/// call the caller stopped: a failure carrying
/// [StreamNetworkException.isCancelled].
final class UploadCancelled extends AttachmentUploadState {
  /// Creates an [UploadCancelled] state.
  const UploadCancelled();
}

/// How far one upload has got, in bytes.
///
/// The counts are the attachment's own bytes, and nothing else is reported
/// against them. They are the source of truth and [fraction] is derived, which
/// is what lets a batch aggregate them; see [BatchUploadProgress.fraction].
///
/// A file whose length could not be read reports how much of it has gone
/// without a total to measure against, so a caller drawing a bar handles the
/// indeterminate case:
///
/// ```dart
/// final label = switch (progress.fraction) {
///   null => 'Uploading ${progress.sentBytes} bytes…',
///   final fraction => '${(fraction * 100).round()}%',
/// };
/// ```
final class UploadProgress extends Equatable {
  /// Creates an [UploadProgress].
  const UploadProgress({
    required this.sentBytes,
    required this.totalBytes,
  });

  /// An upload that has not sent anything yet, of a file [totalBytes] long.
  const UploadProgress.none({this.totalBytes}) : sentBytes = 0;

  /// The number of bytes sent so far.
  final int sentBytes;

  /// The number of bytes to send, or `null` when the file's length could not
  /// be read.
  final int? totalBytes;

  /// The sent fraction, between 0.0 and 1.0, or `null` when [totalBytes] is
  /// unknown.
  ///
  /// `1.0` for a file with nothing to send, which is fully sent the moment it
  /// starts.
  double? get fraction {
    final total = totalBytes;
    if (total == null) return null;
    if (total == 0) return 1;
    return (sentBytes / total).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [sentBytes, totalBytes];
}
