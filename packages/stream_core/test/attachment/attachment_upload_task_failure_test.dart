import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/attachment.dart';
import '../helpers/fake_cdn_client.dart';

void main() {
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
}
