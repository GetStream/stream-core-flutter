import 'dart:async';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/attachment.dart';
import '../helpers/fake_cdn_client.dart';

void main() {
  group('uploadBatch', () {
    test('finishes an empty batch at once, so callers need no special case', () async {
      final uploader = StreamAttachmentUploader(cdn: FakeCdnClient());

      final batch = uploader.uploadBatch([]);
      final result = await batch.result;

      expect(result, isA<BatchUploadCompleted>());
      expect(result.items, isEmpty);
      expect(batch.uploads, isEmpty);
    });

    test('exposes the task uploading each attachment', () async {
      final uploader = StreamAttachmentUploader(cdn: FakeCdnClient());

      final batch = uploader.uploadBatch(attachmentsOf(3));

      expect(batch.id, isNotEmpty);
      expect(batch.uploads.map((it) => it.id), ['a-0', 'a-1', 'a-2']);
      expect(batch.task('a-1'), same(batch.uploads[1]));
      expect(batch.task('nope'), isNull);

      batch.cancel();
      await batch.result;
    });

    test('refuses attachments that share an id, which it could not address', () {
      final uploader = StreamAttachmentUploader(cdn: FakeCdnClient());

      expect(
        () => uploader.uploadBatch([attachmentOf('dupe'), attachmentOf('dupe')]),
        throwsArgumentError,
      );
    });

    test('refuses a concurrency limit that would start nothing', () {
      final uploader = StreamAttachmentUploader(cdn: FakeCdnClient());

      expect(
        () => uploader.uploadBatch(
          attachmentsOf(2),
          maxConcurrent: 0,
        ),
        throwsArgumentError,
        reason: 'a batch that may run no uploads would never finish',
      );
    });

    test('returns one outcome per attachment, in input order', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(3);

      final batch = uploader.uploadBatch(attachments);
      await pumpEventQueue();

      cdn.upload(attachments[2]).succeed(fileUrl: 'c');
      cdn.upload(attachments[0]).succeed(fileUrl: 'a');
      cdn.upload(attachments[1]).succeed(fileUrl: 'b');

      final result = await batch.result;

      expect(result.items.map((it) => it.attachment.id), ['a-0', 'a-1', 'a-2']);
      expect(result.items.map((it) => it.result.getOrNull()?.remoteUrl), ['a', 'b', 'c']);
    });

    test('holds maxConcurrent as a strict upper bound', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(5);

      final batch = uploader.uploadBatch(attachments, maxConcurrent: 2);
      await pumpEventQueue();

      expect(cdn.inFlight, 2);
      expect(cdn.received, hasLength(2));

      cdn.upload(attachments[0]).succeed();
      await pumpEventQueue();

      expect(cdn.inFlight, 2, reason: 'a freed slot takes exactly one more');
      expect(cdn.received, hasLength(3));

      batch.cancel();
      await batch.result;
    });
  });

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

  group('batch cancel', () {
    test('calls off every unfinished upload and keeps the finished ones', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(4);

      final batch = uploader.uploadBatch(attachments, maxConcurrent: 2);
      await pumpEventQueue();

      cdn.upload(attachments[0]).succeed();
      await pumpEventQueue();

      final states = <BatchUploadState>[];
      batch.state.listen(states.add);

      batch
        ..cancel()
        ..cancel();

      final result = await batch.result;
      await pumpEventQueue();

      expect(states.whereType<BatchCancelling>(), isNotEmpty);
      expect(states.last, isA<BatchFinished>(), reason: 'it waits for its children before finishing');
      expect(result, isA<BatchUploadCancelled>());
      expect(result.items.map((it) => it.result.isSuccess), [true, false, false, false]);
      expect(batch.uploads.skip(1).map((it) => it.state.value), everyElement(const UploadCancelled()));
      expect(batch.state.isClosed, isTrue);
    });

    test('finishes even when a CDN never answers the uploads it called off', () async {
      final cdn = FakeCdnClient(honoursCancellation: false);
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(3);

      final batch = uploader.uploadBatch(attachments);
      await pumpEventQueue();
      batch.cancel();

      final result = await batch.result;

      expect(result, isA<BatchUploadCancelled>());
      expect(batch.state.isClosed, isTrue);
    });

    test('starts nothing when it arrives before the first upload begins', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);

      final batch = uploader.uploadBatch(attachmentsOf(3))..cancel();
      final result = await batch.result;

      expect(cdn.received, isEmpty, reason: 'the scheduled pump must not start a cancelled batch');
      expect(result, isA<BatchUploadCancelled>());
      expect(result.items.map((it) => it.result.isSuccess), everyElement(isFalse));
    });

    test('does not rewrite the outcome when it lands while the batch is finishing', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('a-0');

      final batch = uploader.uploadBatch([attachment]);
      await pumpEventQueue();

      // Cancelling from the task's own outcome lands while the batch is still
      // assembling its result.
      unawaited(batch.uploads.single.result.then((_) => batch.cancel()));
      cdn.upload(attachment).succeed();

      final result = await batch.result;

      expect(result, isA<BatchUploadCompleted>(), reason: 'every upload succeeded');
      expect(result.items.single.result, isA<Success<UploadedAttachment>>());
    });

    test('is ignored once the batch has finished', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(2);

      final batch = uploader.uploadBatch(attachments);
      await pumpEventQueue();
      cdn.upload(attachments[0]).succeed();
      cdn.upload(attachments[1]).succeed();

      final result = await batch.result;
      batch.cancel();
      await pumpEventQueue();

      expect(result, isA<BatchUploadCompleted>());
      expect(batch.state.value, isA<BatchFinished>());
    });
  });

  group('batch progress', () {
    test('reports the bytes it actually sent once every upload has finished', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(3);

      final batch = uploader.uploadBatch(attachments);
      await pumpEventQueue();

      // A burst of progress callbacks in one turn is the ordinary tail of an
      // upload; none of them may be delivered before the upload settles.
      for (final attachment in attachments) {
        final upload = cdn.upload(attachment);
        for (var sent = 50; sent <= 1000; sent += 50) {
          upload.sendBytes(sent, 1000);
        }
        upload.succeed();
      }

      final result = await batch.result;
      final progress = batch.state.value.progress;

      expect(result, isA<BatchUploadCompleted>());
      expect(progress.succeeded, 3);
      expect(progress.sentBytes, 3000, reason: 'three whole files were sent');
      expect(progress.fraction, 1.0);
    });

    test('measures a zero-length attachment rather than reading it as unknown', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final empty = attachmentOf('empty', bytes: 0);
      final sized = attachmentOf('sized');

      final batch = uploader.uploadBatch([empty, sized]);
      await pumpEventQueue();

      expect(batch.state.value.progress.totalBytes, 1000);
      expect(batch.state.value.progress.fraction, 0.0);

      batch.cancel();
      await batch.result;
    });

    test('leaves the total unknown while an attachment cannot be measured', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final unreadable = StreamAttachment(
        id: 'unreadable',
        type: AttachmentType.file,
        file: AttachmentFile('/nonexistent/does-not-exist.bin'),
      );

      final batch = uploader.uploadBatch([unreadable, attachmentOf('sized')]);
      await pumpEventQueue();

      expect(batch.state.value.progress.totalBytes, isNull);
      expect(batch.state.value.progress.fraction, isNull);

      batch.cancel();
      await batch.result;
    });

    test('knows the whole batch total before every upload has started', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = [
        attachmentOf('a-0'),
        attachmentOf('a-1', bytes: 2000),
        attachmentOf('a-2', bytes: 3000),
        attachmentOf('a-3', bytes: 4000),
      ];

      final batch = uploader.uploadBatch(attachments, maxConcurrent: 2);
      await pumpEventQueue();

      expect(cdn.received, hasLength(2), reason: 'two are still queued');
      expect(batch.state.value.progress.totalBytes, 10000);
      expect(batch.state.value.progress.fraction, 0.0);

      batch.cancel();
      await batch.result;
    });

    test('weighs progress by bytes, not by attachment count', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final small = attachmentOf('small');
      final large = attachmentOf('large', bytes: 9000);

      final batch = uploader.uploadBatch([small, large]);
      await pumpEventQueue();

      cdn.upload(small).sendBytes(1000, 1000);
      await pumpEventQueue();

      expect(batch.state.value.progress.fraction, closeTo(0.1, 1e-9));
      expect(batch.state.value.progress.uploading, 2);

      batch.cancel();
      await batch.result;
    });

    test('keeps the bytes of an upload that has already succeeded', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final small = attachmentOf('small');
      final large = attachmentOf('large', bytes: 9000);

      final batch = uploader.uploadBatch([small, large]);
      await pumpEventQueue();

      cdn.upload(small).succeed();
      await pumpEventQueue();

      final progress = batch.state.value.progress;
      expect(progress.succeeded, 1);
      expect(progress.finished, 1);
      expect(progress.total, 2);
      expect(progress.sentBytes, 1000);

      batch.cancel();
      await batch.result;
    });
  });
}
