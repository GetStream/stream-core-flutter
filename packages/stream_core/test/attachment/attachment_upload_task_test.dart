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
        ..sendBytes(500, 1000)
        ..sendBytes(1000, 1000)
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
}
