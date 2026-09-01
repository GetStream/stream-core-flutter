import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/attachment.dart';
import '../helpers/fake_cdn_client.dart';

void main() {
  group('under continueOnError', () {
    test('attempts every attachment even after one fails', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(4);

      final batch = uploader.uploadBatch(attachments, maxConcurrent: 2);
      await pumpEventQueue();

      cdn.upload(attachments[0]).succeed();
      cdn.upload(attachments[1]).fail();
      await pumpEventQueue();

      cdn.upload(attachments[2]).succeed();
      cdn.upload(attachments[3]).succeed();

      final result = await batch.result;

      expect(result, isA<BatchUploadCompleted>());
      expect(result.items.map((it) => it.result.isSuccess), [true, false, true, true]);
    });

    test('completes even when every upload fails', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(3);

      final batch = uploader.uploadBatch(attachments);
      await pumpEventQueue();
      for (final attachment in attachments) {
        cdn.upload(attachment).fail();
      }

      final result = await batch.result;

      expect(result, isA<BatchUploadCompleted>(), reason: 'the batch ran exactly as asked');
      expect(result.items.map((it) => it.result.isSuccess), everyElement(isFalse));
    });
  });

  group('under stopOnFirstError', () {
    test('starts nothing new and calls off the rest when an upload fails', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(5);

      final batch = uploader.uploadBatch(
        attachments,
        maxConcurrent: 2,
        eagerError: true,
      );

      await pumpEventQueue();
      cdn.upload(attachments[0]).succeed();
      await pumpEventQueue();
      expect(cdn.received, hasLength(3), reason: 'a-2 took the freed slot');

      cdn.upload(attachments[1]).fail();
      final result = await batch.result;

      expect(result, isA<BatchUploadStoppedOnError>());
      expect(result.items.map((it) => it.result.isSuccess), [true, false, false, false, false]);
      expect(cdn.wasReceived(attachments[3]), isFalse, reason: 'a queued upload never starts');
      expect(cdn.wasReceived(attachments[4]), isFalse);
      expect(batch.uploads.skip(2).map((it) => it.state.value), everyElement(const UploadCancelled()));
    });

    test('names the upload that stopped the batch, and what went wrong', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(3);

      final batch = uploader.uploadBatch(
        attachments,
        eagerError: true,
      );

      final states = <BatchUploadState>[];
      batch.state.listen(states.add);

      await pumpEventQueue();
      cdn.upload(attachments[1]).fail(const StreamApiException(message: 'Payload too large', statusCode: 413));
      await batch.result;
      await pumpEventQueue();

      expect(
        states.whereType<BatchStopping>().first,
        isA<BatchStopping>()
            .having((it) => it.failedUploadId, 'failedUploadId', 'a-1')
            .having(
              (it) => it.error,
              'error',
              isA<StreamApiException>().having((it) => it.statusCode, 'statusCode', 413),
            ),
      );
    });

    test("does not give up when a cancelled upload fails in the CDN's own shape", () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(3);

      final batch = uploader.uploadBatch(
        attachments,
        eagerError: true,
      );

      await pumpEventQueue();
      batch.task('a-1')?.cancel();
      cdn.upload(attachments[1]).fail(StateError('connection aborted'));
      await pumpEventQueue();

      cdn.upload(attachments[0]).succeed();
      cdn.upload(attachments[2]).succeed();

      final result = await batch.result;

      expect(result, isA<BatchUploadCompleted>());
      expect(result.items.map((it) => it.result.isSuccess), [true, false, true]);
    });

    test('carries the failure that stopped it, not the cancellations it caused', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(4);
      const refused = StreamApiException(message: 'Payload too large', statusCode: 413);

      final batch = uploader.uploadBatch(attachments, maxConcurrent: 2, eagerError: true);
      await pumpEventQueue();
      cdn.upload(attachments[0]).succeed();
      cdn.upload(attachments[1]).fail(refused);

      final result = await batch.result;

      expect(result, isA<BatchUploadStoppedOnError>().having((it) => it.error, 'error', same(refused)));
      expect(
        result.items.last.result,
        isA<Failure>().having(
          (it) => it.error,
          'error',
          isA<StreamNetworkException>().having((it) => it.isCancelled, 'isCancelled', isTrue),
        ),
        reason: 'the uploads it called off report cancellations of their own',
      );
    });

    test('carries the trace of the upload that stopped it', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(2);

      final batch = uploader.uploadBatch(attachments, eagerError: true);
      await pumpEventQueue();
      cdn.upload(attachments[1]).fail();

      final result = await batch.result as BatchUploadStoppedOnError;

      // The exception says what went wrong; the trace beside it says where, and
      // is the failing task's own rather than one made up here.
      final failed = result.items[1].result as Failure;
      expect(result.stackTrace, same(failed.stackTrace));
    });

    test('gives up even when the failure settles in the same turn as the last success', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(2);

      final batch = uploader.uploadBatch(attachments, eagerError: true);
      await pumpEventQueue();

      // Both settle before the batch is told about either, so nothing is left
      // queued to keep it from finishing early.
      cdn.upload(attachments[0]).succeed();
      cdn.upload(attachments[1]).fail();

      final result = await batch.result;

      expect(result, isA<BatchUploadStoppedOnError>(), reason: 'the failure was seen before finishing');
    });

    test('does not give up when one of its uploads is cancelled', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(3);

      final batch = uploader.uploadBatch(
        attachments,
        eagerError: true,
      );

      await pumpEventQueue();
      batch.task('a-1')?.cancel();
      await pumpEventQueue();

      cdn.upload(attachments[0]).succeed();
      cdn.upload(attachments[2]).succeed();

      final result = await batch.result;

      expect(result, isA<BatchUploadCompleted>());
      expect(result.items.map((it) => it.result.isSuccess), [true, false, true]);
      expect(batch.task('a-1')?.state.value, const UploadCancelled());
    });
  });
}
