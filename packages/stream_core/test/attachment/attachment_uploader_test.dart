import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

StreamAttachment _attachment(String id, AttachmentFile file) => StreamAttachment(
  id: id,
  type: AttachmentType.file,
  file: file,
);

/// A CDN whose outcome per file is scripted by [outcomes].
class _FakeCdn implements CdnClient {
  _FakeCdn(this.outcomes);

  final Map<AttachmentFile, Result<UploadedFile>> outcomes;
  final cancelTokens = <AttachmentFile, CancelToken?>{};

  Future<Result<UploadedFile>> _upload(AttachmentFile file, CancelToken? cancelToken) async {
    cancelTokens[file] = cancelToken;
    return outcomes[file]!;
  }

  @override
  Future<Result<UploadedFile>> uploadFile(
    AttachmentFile file, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) => _upload(file, cancelToken);

  @override
  Future<Result<UploadedFile>> uploadImage(
    AttachmentFile image, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) => _upload(image, cancelToken);

  @override
  Future<Result<void>> deleteFile(String url, {CancelToken? cancelToken}) async => const Result.success(null);

  @override
  Future<Result<void>> deleteImage(String url, {CancelToken? cancelToken}) async => const Result.success(null);
}

const _uploadedFile = UploadedFile(fileUrl: 'https://cdn/file');
const _refused = StreamApiException(message: 'too large', statusCode: 413, code: StreamErrorCode.payloadTooBig);

void main() {
  final fileA = AttachmentFile.fromData(Uint8List(0));
  final fileB = AttachmentFile.fromData(Uint8List(0));

  group('upload', () {
    test('reports the upload failure itself, unwrapped', () async {
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({fileA: const Result.failure(_refused)}),
      );

      final result = await uploader.upload(_attachment('a', fileA));

      // The failure stays catchable by kind; which attachment it was is the
      // caller's knowledge, not the error's.
      expect(result.exceptionOrNull(), same(_refused));
    });

    test('hands the cancel token to the CDN', () async {
      final cdn = _FakeCdn({fileA: const Result.success(_uploadedFile)});
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final cancelToken = CancelToken();

      await uploader.upload(_attachment('a', fileA), cancelToken: cancelToken);

      expect(cdn.cancelTokens[fileA], same(cancelToken));
    });
  });

  group('uploadBatch', () {
    test('pairs every outcome with its attachment', () async {
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({
          fileA: const Result.success(_uploadedFile),
          fileB: const Result.failure(_refused),
        }),
      );

      final outcomes = await uploader.uploadBatch([_attachment('a', fileA), _attachment('b', fileB)]).toList();

      final byId = {for (final (:attachmentId, :result) in outcomes) attachmentId: result};
      expect(byId['a'], isA<Success<UploadedAttachment>>());
      expect(byId['b']?.exceptionOrNull(), same(_refused));
    });
  });

  group('uploadAll', () {
    test('succeeds with every uploaded attachment', () async {
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({
          fileA: const Result.success(_uploadedFile),
          fileB: const Result.success(_uploadedFile),
        }),
      );

      final result = await uploader.uploadAll([_attachment('a', fileA), _attachment('b', fileB)]);

      expect(result.getOrNull()?.map((it) => it.id), unorderedEquals(['a', 'b']));
    });

    test('fails as one with the first failure', () async {
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({
          fileA: const Result.success(_uploadedFile),
          fileB: const Result.failure(_refused),
        }),
      );

      final result = await uploader.uploadAll([_attachment('a', fileA), _attachment('b', fileB)]);

      expect(result.exceptionOrNull(), same(_refused));
    });
  });
}
