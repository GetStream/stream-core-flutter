import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/attachment.dart';
import '../helpers/fake_cdn_client.dart';

void main() {
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

    test('does not reach the file length until the request has gone out', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1');

      final task = uploader.upload(attachment);
      // As many bytes as the file is long have gone out, but the multipart
      // framing around it has not.
      (await cdn.awaitUpload(attachment)).sendBytes(1000, 1400);
      await pumpEventQueue();

      expect(
        task.state.value,
        isA<UploadInProgress>().having((it) => it.progress.fraction, 'fraction', lessThan(1.0)),
      );

      cdn.upload(attachment).succeed();
      await task.result;
    });

    test('leaves the total unknown when the file length cannot be read', () async {
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
      expect(progress.first, const UploadProgress(sentBytes: 0, totalBytes: null), reason: 'no length to report');

      // What went out is still worth reporting; the total is not invented from
      // the transport's own count, so the fraction reads as indeterminate
      // rather than as a percentage of the wrong whole.
      expect(progress.last, const UploadProgress(sentBytes: 500, totalBytes: null));
      expect(progress.last.fraction, isNull);
    });

    test('reads an empty file as fully sent rather than as an unknown length', () async {
      final cdn = FakeCdnClient();
      final uploader = StreamAttachmentUploader(cdn: cdn);
      final attachment = attachmentOf('file-1', bytes: 0);

      final task = uploader.upload(attachment);
      final states = <AttachmentUploadState>[];
      task.state.listen(states.add);

      (await cdn.awaitUpload(attachment)).succeed();
      await task.result;
      await pumpEventQueue();

      final progress = states.whereType<UploadInProgress>().map((it) => it.progress);
      expect(progress.first, const UploadProgress(sentBytes: 0, totalBytes: 0));
      expect(progress.first.fraction, 1.0, reason: 'nothing to send is already sent');
    });
  });
}
