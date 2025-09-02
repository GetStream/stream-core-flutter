/// Represents the upload state of an attachment.
///
/// This sealed class provides a type-safe way to represent the different states
/// an attachment can be in during the upload process. Each state provides
/// relevant information for that stage of the upload.
///
/// Example usage:
/// ```dart
/// switch (uploadState) {
///   case UploadStatePreparing():
///     // Show preparing indicator
///   case UploadStateInProgress(:final uploaded, :final total):
///     // Show progress: uploaded/total
///   case UploadStateSuccess():
///     // Show success state
///   case UploadStateFailed(:final error):
///     // Show error: error.toString()
/// }
/// ```
sealed class AttachmentUploadState {
  /// Creates a base [AttachmentUploadState].
  const AttachmentUploadState();

  /// Creates a preparing state indicating upload preparation.
  const factory AttachmentUploadState.preparing() = UploadStatePreparing;

  /// Creates an in-progress state with upload progress information.
  const factory AttachmentUploadState.inProgress({
    required double progress,
  }) = UploadStateInProgress;

  /// Creates a success state indicating successful upload completion.
  const factory AttachmentUploadState.success() = UploadStateSuccess;

  /// Creates a failed state with error information.
  const factory AttachmentUploadState.failed({
    required Object error,
    StackTrace? stackTrace,
  }) = UploadStateFailed;
}

/// Upload state indicating the attachment is being prepared for upload.
///
/// This is the initial state before the actual upload process begins.
class UploadStatePreparing extends AttachmentUploadState {
  /// Creates a preparing state.
  const UploadStatePreparing();
}

/// Upload state indicating the attachment upload is in progress.
///
/// Provides progress information including bytes uploaded and total size.
class UploadStateInProgress extends AttachmentUploadState {
  /// Creates an in-progress state with upload progress.
  const UploadStateInProgress({required this.progress});

  /// The upload progress as a value between 0.0 and 1.0.
  final double progress;
}

/// Upload state indicating the attachment was successfully uploaded.
class UploadStateSuccess extends AttachmentUploadState {
  /// Creates a success state.
  const UploadStateSuccess();
}

/// Upload state indicating the attachment upload failed.
///
/// Contains error information and optionally a stack trace for debugging.
class UploadStateFailed extends AttachmentUploadState {
  /// Creates a failed state with error information.
  ///
  /// The [error] parameter contains the error that caused the failure.
  /// The [stackTrace] parameter optionally provides debugging information.
  const UploadStateFailed({required this.error, this.stackTrace});

  /// The error that caused the upload to fail.
  final Object error;

  /// Optional stack trace for debugging the failure.
  final StackTrace? stackTrace;
}
