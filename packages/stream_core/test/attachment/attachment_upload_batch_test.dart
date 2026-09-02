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

    test('leaves no upload still emitting once it has finished', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(5);

      // Two in flight and three never started, so the ones the batch settles
      // on the caller's behalf are covered as well as the ones that ran.
      final batch = uploader.uploadBatch(attachments, maxConcurrent: 2);
      await pumpEventQueue();

      batch.cancel();
      await batch.result;
      await pumpEventQueue();

      // The batch subscribes to every upload and cancels nothing: what ends
      // those subscriptions is each upload closing its own channel as it
      // settles, and the batch cannot finish until all of them have.
      expect(batch.uploads.where((it) => !it.state.isClosed), isEmpty);
    });

    test('refuses attachments that share an id, which it could not address', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);

      expect(
        () => uploader.uploadBatch([attachmentOf('dupe'), attachmentOf('dupe')]),
        throwsArgumentError,
      );

      // Refused before a single upload exists, rather than after some of them
      // have already been set going.
      await pumpEventQueue();
      expect(cdn.received, isEmpty);
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

    test('refills every slot freed in the same turn, and no more', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachments = attachmentsOf(5);

      final batch = uploader.uploadBatch(attachments, maxConcurrent: 2);
      await pumpEventQueue();

      // Both settle before the scheduler runs again, so it has two slots to
      // fill at once rather than the one slot the case above frees.
      cdn.upload(attachments[0]).succeed();
      cdn.upload(attachments[1]).succeed();
      await pumpEventQueue();

      expect(cdn.inFlight, 2);
      expect(cdn.received, hasLength(4), reason: 'both freed slots were taken, and the fifth waits');

      batch.cancel();
      await batch.result;
    });
  });
}
