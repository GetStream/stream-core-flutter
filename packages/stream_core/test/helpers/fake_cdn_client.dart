import 'dart:async';

import 'package:stream_core/stream_core.dart';

/// A [CdnClient] the test drives by hand.
///
/// Uploads park here until the test sends bytes, succeeds them or fails them,
/// which is what makes the scheduler's timing — who is in flight, who is still
/// queued — observable at all.
///
/// Uploads are addressed by the attachment they came from rather than by file
/// name, because a file built from bytes carries no name on every platform.
class FakeCdnClient implements CdnClient {
  /// Creates a [FakeCdnClient].
  ///
  /// When [honoursCancellation] is false a cancelled token is ignored, the way
  /// a third-party client that never answers would behave.
  FakeCdnClient({this.honoursCancellation = true});

  /// Whether a cancelled token comes back as a cancelled failure.
  final bool honoursCancellation;

  final _uploads = <AttachmentFile, FakeUpload>{};
  final _awaited = <AttachmentFile, Completer<FakeUpload>>{};
  final _received = <AttachmentFile>[];

  /// The attachments handed over for upload, in the order they arrived.
  List<AttachmentFile> get received => List.unmodifiable(_received);

  /// How many uploads are in flight right now.
  int get inFlight => _uploads.values.where((it) => !it.isSettled).length;

  /// Whether [attachment] has been handed over at all.
  bool wasReceived(StreamAttachment attachment) => _uploads.containsKey(attachment.file);

  /// The upload of [attachment].
  FakeUpload upload(StreamAttachment attachment) {
    final upload = _uploads[attachment.file];
    if (upload != null) return upload;
    throw StateError('No upload was handed over for "${attachment.id}"');
  }

  /// Completes once [attachment] has been handed over for upload.
  Future<FakeUpload> awaitUpload(StreamAttachment attachment) {
    final upload = _uploads[attachment.file];
    if (upload != null && !upload.isSettled) return Future.value(upload);
    return (_awaited[attachment.file] ??= Completer<FakeUpload>()).future;
  }

  @override
  Future<Result<UploadedFile>> uploadImage(
    AttachmentFile image, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) {
    return _accept(image, isImage: true, onProgress: onProgress, cancelToken: cancelToken);
  }

  @override
  Future<Result<UploadedFile>> uploadFile(
    AttachmentFile file, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) {
    return _accept(file, isImage: false, onProgress: onProgress, cancelToken: cancelToken);
  }

  @override
  Future<Result<void>> deleteImage(String url, {CancelToken? cancelToken}) => throw UnimplementedError();

  @override
  Future<Result<void>> deleteFile(String url, {CancelToken? cancelToken}) => throw UnimplementedError();

  Future<Result<UploadedFile>> _accept(
    AttachmentFile file, {
    required bool isImage,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) {
    final upload = FakeUpload._(
      file: file,
      isImage: isImage,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
    _uploads[file] = upload;
    _received.add(file);
    _awaited.remove(file)?.complete(upload);

    // A cancelled request comes back as the transport's own cancelled failure,
    // the way a Dio-backed CDN client reports one.
    if (honoursCancellation) {
      unawaited(cancelToken?.whenCancel.then((_) => upload._cancel()));
    }

    return upload._outcome.future;
  }
}

/// One upload parked inside a [FakeCdnClient].
class FakeUpload {
  FakeUpload._({
    required this.file,
    required this.isImage,
    required this._onProgress,
    required this._cancelToken,
  });

  /// The file the uploader handed over.
  final AttachmentFile file;

  /// Whether it arrived through the image endpoint.
  final bool isImage;

  final ProgressCallback? _onProgress;
  final CancelToken? _cancelToken;
  final _outcome = Completer<Result<UploadedFile>>();

  /// Whether this upload has settled.
  bool get isSettled => _outcome.isCompleted;

  /// Reports [sent] of [total] bytes sent, as the transport counts them.
  void sendBytes(int sent, int total) => _onProgress?.call(sent, total);

  /// Answers with the uploaded file's urls.
  void succeed({String fileUrl = 'https://cdn.example.com/file', String? thumbUrl}) {
    _settle(Result.success(UploadedFile(fileUrl: fileUrl, thumbUrl: thumbUrl)));
  }

  /// Answers with a failure.
  void fail([Object error = const StreamApiException(message: 'Refused', statusCode: 400)]) {
    _settle(Result.failure(error, StackTrace.current));
  }

  /// Calls the request off on its own initiative and answers with [error],
  /// the way a client that gives up without being asked to would.
  void abort([Object error = 'the client gave up']) {
    _cancelToken?.cancel();
    _settle(Result.failure(error, StackTrace.current));
  }

  /// Throws instead of answering, the way a CDN client that does not report
  /// failure as a [Result] would.
  void crash([Object error = 'the CDN client threw']) {
    if (_outcome.isCompleted) return;
    _outcome.completeError(error, StackTrace.current);
  }

  void _cancel() {
    _settle(
      Result.failure(
        const StreamNetworkException(message: 'The request was cancelled', isCancelled: true),
        StackTrace.current,
      ),
    );
  }

  void _settle(Result<UploadedFile> outcome) {
    if (_outcome.isCompleted) return;
    _outcome.complete(outcome);
  }
}
