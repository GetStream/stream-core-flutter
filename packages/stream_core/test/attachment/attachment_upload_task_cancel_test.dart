import 'dart:async';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/attachment.dart';
import '../helpers/fake_cdn_client.dart';

void main() {
  group('when the upload is cancelled', () {
    test('settles while the file is still being read, sending nothing', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      final states = <AttachmentUploadState>[];
      task.state.listen(states.add);

      // Queued behind the microtask that starts the upload, so it lands while
      // the task is reading its file and before the length has arrived — the
      // one window where `UploadPreparing` is the live state.
      scheduleMicrotask(task.cancel);

      final result = await task.result;
      await pumpEventQueue();

      expect(states, [const UploadQueued(), const UploadPreparing(), const UploadCancelled()]);
      expect(cdn.wasReceived(attachment), isFalse, reason: 'the read was called off before any send');
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

    test('reports a cancellation the CDN shaped itself, rather than wrapping it again', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      const reported = StreamNetworkException(
        message: 'The request was cancelled',
        isCancelled: true,
        closeCode: 1000,
      );

      final task = uploader.upload(attachment);
      // Nothing cancelled the token: the client answered with a cancellation of
      // its own, already in the shape a caller wants.
      (await cdn.awaitUpload(attachment)).fail(reported);

      final result = await task.result;

      expect(task.state.value, const UploadCancelled());
      // Passed through as it arrived, so its transport detail survives instead
      // of being buried in the cause of a fresh exception.
      expect(result, isA<Failure>().having((it) => it.error, 'error', same(reported)));
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
