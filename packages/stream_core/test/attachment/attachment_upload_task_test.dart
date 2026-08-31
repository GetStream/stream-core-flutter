import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/attachment.dart';
import '../helpers/fake_cdn_client.dart';

void main() {
  group('upload', () {
    test('walks the whole lifecycle on one channel, ending in success', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('image-1');

      final task = uploader.upload(attachment);
      final states = <AttachmentUploadState>[];
      task.state.listen(states.add);

      expect(task.state.value, const UploadQueued());

      (await cdn.awaitUpload(attachment))
        ..sendBytes(500, 1200)
        ..sendBytes(1200, 1200)
        ..succeed(fileUrl: 'https://cdn.example.com/file.jpg', thumbUrl: 'https://cdn.example.com/thumb.jpg');

      final result = await task.result;
      await pumpEventQueue();

      expect(states, [
        const UploadQueued(),
        const UploadPreparing(),
        const UploadInProgress(progress: UploadProgress(sentBytes: 0, totalBytes: 1000)),
        const UploadInProgress(progress: UploadProgress(sentBytes: 500, totalBytes: 1000)),
        const UploadInProgress(progress: UploadProgress(sentBytes: 1000, totalBytes: 1000)),
        isA<UploadSuccess>(),
      ]);

      expect(task.state.isClosed, isTrue, reason: 'no state follows a terminal one');
      expect(
        result.getOrNull(),
        isA<UploadedAttachment>()
            .having((it) => it.remoteUrl, 'remoteUrl', 'https://cdn.example.com/file.jpg')
            .having((it) => it.thumbnailUrl, 'thumbnailUrl', 'https://cdn.example.com/thumb.jpg'),
      );
    });

    test('the task is addressed by the attachment it was given', () {
      final uploader = StreamAttachmentUploader(cdn: FakeCdnClient());
      final attachment = attachmentOf('image-1');

      final task = uploader.upload(attachment);

      expect(task.id, 'image-1');
      expect(task.attachment, same(attachment));
    });

    test('sends an image through the image endpoint', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('image-1', type: AttachmentType.image);

      uploader.upload(attachment);

      expect((await cdn.awaitUpload(attachment)).isImage, isTrue);
    });

    test('sends anything else through the file endpoint', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('video-1', type: AttachmentType.video);

      uploader.upload(attachment);

      expect((await cdn.awaitUpload(attachment)).isImage, isFalse);
    });

    test('hands the attachment custom data back on the uploaded attachment', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1', custom: {'source': 'camera'});

      final task = uploader.upload(attachment);
      (await cdn.awaitUpload(attachment)).succeed();

      expect((await task.result).getOrNull()?.custom, {'source': 'camera'});
    });

    test('starts a new upload every call, so an attachment can be retried', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final first = uploader.upload(attachment);
      (await cdn.awaitUpload(attachment)).fail();
      await first.result;

      final second = uploader.upload(attachment);
      (await cdn.awaitUpload(attachment)).succeed();

      expect(second, isNot(same(first)));
      expect(await second.result, isA<Success<UploadedAttachment>>());
    });

    test('replays the settled state to a listener that arrives late, then ends', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      (await cdn.awaitUpload(attachment)).succeed();
      await task.result;

      expect(await task.state.toList(), [isA<UploadSuccess>()]);
    });
  });

  group('upload progress', () {
    test('counts the attachment payload bytes, not the multipart bytes', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      final states = <AttachmentUploadState>[];
      task.state.listen(states.add);

      (await cdn.awaitUpload(attachment))
        ..sendBytes(200, 1400)
        ..sendBytes(1400, 1400)
        ..succeed();

      await task.result;
      await pumpEventQueue();

      final progress = states.whereType<UploadInProgress>().map((it) => it.progress);
      expect(progress.map((it) => it.totalBytes), everyElement(1000));
      expect(progress.last, const UploadProgress(sentBytes: 1000, totalBytes: 1000));
      expect(progress.last.fraction, 1.0);
    });

    test('falls back to the transport total when the file length cannot be read', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = StreamAttachment(
        id: 'file-1',
        type: AttachmentType.file,
        file: AttachmentFile('/nonexistent/does-not-exist.bin'),
      );

      final task = uploader.upload(attachment);
      final states = <AttachmentUploadState>[];
      task.state.listen(states.add);

      (await cdn.awaitUpload(attachment))
        ..sendBytes(500, 2000)
        ..succeed();

      await task.result;
      await pumpEventQueue();

      final progress = states.whereType<UploadInProgress>().map((it) => it.progress);
      expect(progress.first, const UploadProgress(sentBytes: 0, totalBytes: 0), reason: 'no length to report yet');
      expect(progress.last, const UploadProgress(sentBytes: 500, totalBytes: 2000));
    });
  });

  group('when the upload fails', () {
    test('settles as a failure, keeping the server refusal', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      (await cdn.awaitUpload(attachment)).fail(
        const StreamApiException(message: 'Payload too large', statusCode: 413),
      );

      final result = await task.result;

      expect(
        task.state.value,
        isA<UploadFailed>().having(
          (it) => it.error,
          'error',
          isA<StreamApiException>().having((it) => it.statusCode, 'statusCode', 413),
        ),
      );
      expect(result, isA<Failure>());
    });

    test('normalizes an error a foreign CDN client reported', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      (await cdn.awaitUpload(attachment)).fail(ArgumentError('not a Stream failure'));

      await task.result;

      expect(
        task.state.value,
        isA<UploadFailed>().having((it) => it.error, 'error', isA<StreamClientException>()),
      );
    });

    test('settles when the CDN client throws instead of reporting a failure', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      (await cdn.awaitUpload(attachment)).crash(StateError('boom'));

      final result = await task.result;

      expect(
        task.state.value,
        isA<UploadFailed>().having((it) => it.error, 'error', isA<StreamClientException>()),
        reason: 'a thrown error settles the task rather than escaping it',
      );
      expect(result, isA<Failure>());
    });
  });

  group('cancel', () {
    test('never touches the network when the upload has not started sending', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);

      final task = uploader.upload(attachmentOf('file-1'));
      final states = <AttachmentUploadState>[];
      task.state.listen(states.add);
      task.cancel();

      await task.result;
      await pumpEventQueue();

      expect(cdn.received, isEmpty, reason: 'nothing was ever handed to the CDN');
      expect(
        states,
        [const UploadQueued(), const UploadCancelled()],
        reason: 'the run that was already scheduled must not emit past the terminal state',
      );
    });

    test('absorbs the cancelled answer the transport sends back afterwards', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      final states = <AttachmentUploadState>[];
      task.state.listen(states.add);

      (await cdn.awaitUpload(attachment)).sendBytes(400, 1000);
      task.cancel();

      final result = await task.result;
      // The cancelled request comes back from the transport after the task has
      // already settled on its own.
      await pumpEventQueue();

      expect(states.where((it) => it.isFinal), [const UploadCancelled()], reason: 'settles exactly once');
      expect(task.state.isClosed, isTrue);
      expect(
        result,
        isA<Failure>().having(
          (it) => it.error,
          'error',
          isA<StreamNetworkException>().having((it) => it.isCancelled, 'isCancelled', isTrue),
        ),
      );
    });

    test('settles as the cancelled failure the rest of the SDK reports', () async {
      final uploader = StreamAttachmentUploader(cdn: FakeCdnClient());

      final task = uploader.upload(attachmentOf('file-1'))..cancel();

      expect(
        await task.result,
        isA<Failure>().having(
          (it) => it.error,
          'error',
          isA<StreamNetworkException>().having((it) => it.isCancelled, 'isCancelled', isTrue),
        ),
      );
    });

    test('reads as cancelled when the CDN calls the request off itself', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      // No `task.cancel()`: the client cancels the token it was handed and
      // reports the abort in a shape of its own.
      (await cdn.awaitUpload(attachment)).abort(StateError('connection aborted'));

      final result = await task.result;

      expect(task.state.value, const UploadCancelled());
      expect(
        result,
        isA<Failure>().having(
          (it) => it.error,
          'error',
          isA<StreamNetworkException>().having((it) => it.isCancelled, 'isCancelled', isTrue),
        ),
      );
    });

    test('settles without waiting for a CDN that never answers', () async {
      final cdn = FakeCdnClient(honoursCancellation: false);
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      await cdn.awaitUpload(attachment);
      task.cancel();

      final result = await task.result;

      expect(task.state.value, const UploadCancelled());
      expect(result, isA<Failure>());
    });

    test('wins over an answer that lands after it', () async {
      final cdn = FakeCdnClient(honoursCancellation: false);
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      await cdn.awaitUpload(attachment);
      task.cancel();
      cdn.upload(attachment).succeed();

      await pumpEventQueue();

      expect(task.state.value, const UploadCancelled(), reason: 'the answer is dropped');
      expect(await task.result, isA<Failure>());
    });

    test('leaves the terminal state that was committed first', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      (await cdn.awaitUpload(attachment)).succeed();
      await task.result;

      task.cancel();
      await pumpEventQueue();

      expect(task.state.value, isA<UploadSuccess>());
      expect(await task.result, isA<Success<UploadedAttachment>>());
    });

    test('is safe to call more than once', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      (await cdn.awaitUpload(attachment)).sendBytes(100, 1000);
      task
        ..cancel()
        ..cancel()
        ..cancel();

      await task.result;
      await pumpEventQueue();

      expect(task.state.value, const UploadCancelled());
    });
  });
}
