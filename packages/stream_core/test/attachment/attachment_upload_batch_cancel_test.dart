import 'dart:async';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/attachment.dart';
import '../helpers/fake_cdn_client.dart';

void main() {
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
}
