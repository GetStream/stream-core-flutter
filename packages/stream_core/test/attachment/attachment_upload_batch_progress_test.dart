import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/attachment.dart';
import '../helpers/fake_cdn_client.dart';

void main() {
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

    test('finishes with the total still unknown when an attachment could not be measured', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final unreadable = StreamAttachment(
        id: 'unreadable',
        type: AttachmentType.file,
        file: AttachmentFile('/nonexistent/does-not-exist.bin'),
      );
      final sized = attachmentOf('sized');

      final batch = uploader.uploadBatch([unreadable, sized]);

      (await cdn.awaitUpload(unreadable))
        ..sendBytes(400, 400)
        ..succeed();
      (await cdn.awaitUpload(sized)).succeed();

      final result = await batch.result;
      final progress = batch.state.value.progress;

      expect(result, isA<BatchUploadCompleted>());
      expect(progress.succeeded, 2);

      // An attachment that could never be measured contributes no term, so the
      // total stays unknown for good and the fraction never becomes a number —
      // even though the batch completed. `sentBytes` still counts what went
      // out, which for the unmeasured upload is what the transport reported.
      expect(progress.totalBytes, isNull);
      expect(progress.fraction, isNull);
      expect(progress.sentBytes, 1400);
    });

    test('keeps the bytes a failed upload had already sent', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final refused = attachmentOf('refused');
      final delivered = attachmentOf('delivered');

      final batch = uploader.uploadBatch([refused, delivered]);

      (await cdn.awaitUpload(refused))
        ..sendBytes(400, 1000)
        ..fail();
      (await cdn.awaitUpload(delivered))
        ..sendBytes(1000, 1000)
        ..succeed();

      final result = await batch.result;
      final progress = batch.state.value.progress;

      expect(result, isA<BatchUploadCompleted>());
      expect(progress.failed, 1);
      expect(progress.succeeded, 1);

      // A failed upload is the one case where the aggregate reads a byte count
      // recorded by the state listener rather than one it can derive: there is
      // no total to fall back on the way a success has. The partial bytes
      // survive only because the progress event is delivered before the settle
      // that follows it.
      expect(progress.sentBytes, 1400, reason: '400 partial bytes plus a whole 1000-byte file');
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
