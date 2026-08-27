import 'dart:async';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

StreamAttachment _attachment(
  String id,
  AttachmentFile file, {
  AttachmentType type = AttachmentType.file,
  Map<String, Object?>? custom,
}) => StreamAttachment(id: id, type: type, file: file, custom: custom);

/// A CDN whose outcome per file is scripted by [outcomes], recording how each
/// upload was made.
class _FakeCdn implements CdnClient {
  _FakeCdn(this.outcomes, {this.progress = const {}});

  final Map<AttachmentFile, Future<Result<UploadedFile>> Function()> outcomes;
  final Map<AttachmentFile, List<(int, int)>> progress;

  final cancelTokens = <AttachmentFile, CancelToken?>{};
  final methods = <AttachmentFile, String>{};

  Future<Result<UploadedFile>> _upload(
    String method,
    AttachmentFile file,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  ) {
    methods[file] = method;
    cancelTokens[file] = cancelToken;
    for (final (sent, total) in progress[file] ?? const <(int, int)>[]) {
      onProgress?.call(sent, total);
    }

    return outcomes[file]!();
  }

  @override
  Future<Result<UploadedFile>> uploadFile(
    AttachmentFile file, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) => _upload('file', file, onProgress, cancelToken);

  @override
  Future<Result<UploadedFile>> uploadImage(
    AttachmentFile image, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) => _upload('image', image, onProgress, cancelToken);

  @override
  Future<Result<void>> deleteFile(String url, {CancelToken? cancelToken}) async => const Result.success(null);

  @override
  Future<Result<void>> deleteImage(String url, {CancelToken? cancelToken}) async => const Result.success(null);
}

Future<Result<UploadedFile>> Function() _succeeds([UploadedFile file = _uploadedFile]) =>
    () async => Result.success(file);
Future<Result<UploadedFile>> Function() _fails() =>
    () async => const Result.failure(_refused);

/// An upload that stays in flight until [token] is cancelled, then settles the
/// way a cancelled CDN request does.
Future<Result<UploadedFile>> Function() _cancelsWith(CancelToken token) => () async {
  await token.whenCancel;
  return const Result.failure(_cancelled);
};

const _uploadedFile = UploadedFile(fileUrl: 'https://cdn/file', thumbUrl: 'https://cdn/thumb');
const _refused = StreamApiException(message: 'too large', statusCode: 413, code: StreamErrorCode.payloadTooBig);
const _cancelled = StreamNetworkException(message: 'The upload was cancelled', isCancelled: true);

final Matcher _isCancelledFailure = isA<StreamNetworkException>().having((it) => it.isCancelled, 'isCancelled', isTrue);

void main() {
  final fileA = AttachmentFile.fromData(Uint8List(0));
  final fileB = AttachmentFile.fromData(Uint8List(0));

  group('upload', () {
    test('maps the CDN response onto the attachment it uploaded', () async {
      final uploader = StreamAttachmentUploader(cdn: _FakeCdn({fileA: _succeeds()}));

      final result = await uploader.upload(
        _attachment('a', fileA, type: AttachmentType.image, custom: const {'k': 'v'}),
      );

      expect(
        result.getOrNull(),
        isA<UploadedAttachment>()
            .having((it) => it.id, 'id', 'a')
            .having((it) => it.type, 'type', AttachmentType.image)
            .having((it) => it.custom, 'custom', const {'k': 'v'})
            .having((it) => it.remoteUrl, 'remoteUrl', 'https://cdn/file')
            .having((it) => it.thumbnailUrl, 'thumbnailUrl', 'https://cdn/thumb'),
      );
    });

    test('reports the upload failure itself, unwrapped', () async {
      final uploader = StreamAttachmentUploader(cdn: _FakeCdn({fileA: _fails()}));

      final result = await uploader.upload(_attachment('a', fileA));

      // The failure stays catchable by kind; which attachment it was is the
      // caller's knowledge, not the error's.
      expect(result.exceptionOrNull(), same(_refused));
    });

    test('routes an image through the image upload and everything else through the file one', () async {
      final cdn = _FakeCdn({fileA: _succeeds(), fileB: _succeeds()});
      final uploader = StreamAttachmentUploader(cdn: cdn);

      await uploader.upload(_attachment('a', fileA, type: AttachmentType.image));
      await uploader.upload(_attachment('b', fileB, type: AttachmentType.video));

      expect(cdn.methods[fileA], 'image');
      expect(cdn.methods[fileB], 'file');
    });

    test('hands the cancel token to the CDN', () async {
      final cdn = _FakeCdn({fileA: _succeeds()});
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final cancelToken = CancelToken();

      await uploader.upload(_attachment('a', fileA), cancelToken: cancelToken);

      expect(cdn.cancelTokens[fileA], same(cancelToken));
    });

    test('cancelling mid-upload settles it as a cancelled failure', () async {
      final cancelToken = CancelToken();
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({fileA: _cancelsWith(cancelToken)}),
      );

      final pending = uploader.upload(_attachment('a', fileA), cancelToken: cancelToken);
      cancelToken.cancel();

      final result = await pending;
      expect(result.exceptionOrNull(), _isCancelledFailure);
    });

    test('cancelling one upload leaves another in flight untouched', () async {
      final cancelToken = CancelToken();
      final slow = Completer<Result<UploadedFile>>();
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({fileA: _cancelsWith(cancelToken), fileB: () => slow.future}),
      );

      final cancelled = uploader.upload(_attachment('a', fileA), cancelToken: cancelToken);
      final untouched = uploader.upload(_attachment('b', fileB), cancelToken: CancelToken());

      cancelToken.cancel();
      expect((await cancelled).exceptionOrNull(), _isCancelledFailure);

      // The other upload is still in flight and completes on its own terms.
      slow.complete(const Result.success(_uploadedFile));
      expect(
        (await untouched).getOrNull(),
        isA<UploadedAttachment>().having((it) => it.id, 'id', 'b'),
      );
    });

    test('a cancelled attachment can be retried with a fresh token', () async {
      final cancelToken = CancelToken();
      var attempts = 0;
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({
          fileA: () {
            attempts += 1;
            if (attempts == 1) return _cancelsWith(cancelToken)();
            return _succeeds()();
          },
        }),
      );
      final attachment = _attachment('a', fileA);

      final first = uploader.upload(attachment, cancelToken: cancelToken);
      cancelToken.cancel();
      expect((await first).exceptionOrNull(), _isCancelledFailure);

      final retried = await uploader.upload(attachment, cancelToken: CancelToken());
      expect(
        retried.getOrNull(),
        isA<UploadedAttachment>().having((it) => it.remoteUrl, 'remoteUrl', 'https://cdn/file'),
      );
    });

    test('normalizes progress to a fraction, clamped, with an empty total as zero', () async {
      final cdn = _FakeCdn(
        {fileA: _succeeds()},
        progress: {
          fileA: [(5, 10), (0, 0), (20, 10)],
        },
      );
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final seen = <double>[];

      await uploader.upload(_attachment('a', fileA), onProgress: seen.add);

      expect(seen, [0.5, 0.0, 1.0]);
    });
  });

  group('uploadBatch', () {
    test('pairs every outcome with its attachment', () async {
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({fileA: _succeeds(), fileB: _fails()}),
      );

      final outcomes = await uploader.uploadBatch([_attachment('a', fileA), _attachment('b', fileB)]).toList();

      final byId = {for (final (:attachmentId, :result) in outcomes) attachmentId: result};
      expect(byId['a'], isA<Success<UploadedAttachment>>());
      expect(byId['b']?.exceptionOrNull(), same(_refused));
    });

    test('emits in completion order, not input order', () async {
      final slow = Completer<Result<UploadedFile>>();
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({fileA: () => slow.future, fileB: _succeeds()}),
      );

      final order = <String>[];
      await uploader.uploadBatch([_attachment('a', fileA), _attachment('b', fileB)]).forEach((outcome) {
        order.add(outcome.attachmentId);

        // The first attachment finishes only after the second already has.
        if (outcome.attachmentId == 'b') {
          slow.complete(const Result.success(_uploadedFile));
        }
      });

      expect(order, ['b', 'a']);
    });

    test('reports the per-attachment progress under its id', () async {
      final cdn = _FakeCdn(
        {fileA: _succeeds()},
        progress: {
          fileA: [(5, 10)],
        },
      );
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final seen = <(String, double)>[];

      await uploader.uploadBatch(
        [_attachment('a', fileA)],
        onProgress: (attachmentId, progress) => seen.add((attachmentId, progress)),
      ).drain<void>();

      expect(seen, [('a', 0.5)]);
    });

    test('a cancelled upload reads as cancelled while the rest of the batch lands', () async {
      final cancelToken = CancelToken();
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({fileA: _cancelsWith(cancelToken), fileB: _succeeds()}),
      );

      final outcomes = uploader.uploadBatch([_attachment('a', fileA), _attachment('b', fileB)]).toList();
      cancelToken.cancel();

      final byId = {for (final (:attachmentId, :result) in await outcomes) attachmentId: result};
      expect(byId['a']?.exceptionOrNull(), _isCancelledFailure);
      expect(byId['b'], isA<Success<UploadedAttachment>>());
    });

    test('emits nothing for an empty batch', () async {
      final uploader = StreamAttachmentUploader(cdn: _FakeCdn({}));

      expect(await uploader.uploadBatch(const []).toList(), isEmpty);
    });

    test('with eagerError, throws the first failure and closes', () async {
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({fileA: _fails(), fileB: _succeeds()}),
      );

      final outcomes = uploader.uploadBatch(
        [_attachment('a', fileA), _attachment('b', fileB)],
        maxConcurrent: 1,
        eagerError: true,
      );

      await expectLater(outcomes, emitsError(same(_refused)));
    });

    test('without eagerError, emits the failure and continues', () async {
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({fileA: _fails(), fileB: _succeeds()}),
      );

      final outcomes = await uploader.uploadBatch(
        [_attachment('a', fileA), _attachment('b', fileB)],
        maxConcurrent: 1,
      ).toList();

      expect(outcomes.map((it) => it.attachmentId), ['a', 'b']);
      expect(outcomes.first.result, isA<Failure>());
      expect(outcomes.last.result, isA<Success<UploadedAttachment>>());
    });
  });

  group('uploadAll', () {
    test('succeeds with every uploaded attachment', () async {
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({fileA: _succeeds(), fileB: _succeeds()}),
      );

      final result = await uploader.uploadAll([_attachment('a', fileA), _attachment('b', fileB)]);

      expect(result.getOrNull()?.map((it) => it.id), unorderedEquals(['a', 'b']));
    });

    test('fails as one with the first failure', () async {
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({fileA: _succeeds(), fileB: _fails()}),
      );

      final result = await uploader.uploadAll([_attachment('a', fileA), _attachment('b', fileB)]);

      expect(result.exceptionOrNull(), same(_refused));
    });

    test('fails as one with the cancelled failure when an upload is called off', () async {
      final cancelToken = CancelToken();
      final uploader = StreamAttachmentUploader(
        cdn: _FakeCdn({fileA: _cancelsWith(cancelToken), fileB: _succeeds()}),
      );

      final pending = uploader.uploadAll([_attachment('a', fileA), _attachment('b', fileB)]);
      cancelToken.cancel();

      expect((await pending).exceptionOrNull(), _isCancelledFailure);
    });

    test('succeeds empty for an empty batch', () async {
      final uploader = StreamAttachmentUploader(cdn: _FakeCdn({}));

      final result = await uploader.uploadAll(const []);

      expect(result.getOrNull(), isEmpty);
    });
  });
}
