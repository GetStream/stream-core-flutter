import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/attachment.dart';

void main() {
  group('BatchUploadItemResult', () {
    test('compares two outcomes for the same attachment by what they carry', () {
      const uploaded = UploadedAttachment(
        id: 'a-0',
        type: AttachmentType.file,
        remoteUrl: 'https://cdn.example.com/file',
      );

      // The same attachment handed over twice is two objects, and the file it
      // wraps holds bytes no caller wants compared. Its id is what addresses
      // the item, so that is what equality reads.
      final first = BatchUploadItemResult(
        attachment: attachmentOf('a-0'),
        result: const Result.success(uploaded),
      );
      final second = BatchUploadItemResult(
        attachment: attachmentOf('a-0'),
        result: const Result.success(uploaded),
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('tells two attachments apart, and two outcomes apart', () {
      const uploaded = UploadedAttachment(id: 'a-0', type: AttachmentType.file);

      final item = BatchUploadItemResult(
        attachment: attachmentOf('a-0'),
        result: const Result.success(uploaded),
      );
      final otherAttachment = BatchUploadItemResult(
        attachment: attachmentOf('a-1'),
        result: const Result.success(uploaded),
      );
      final otherOutcome = BatchUploadItemResult(
        attachment: attachmentOf('a-0'),
        result: const Result.success(
          UploadedAttachment(id: 'a-0', type: AttachmentType.file, remoteUrl: 'https://cdn.example.com/other'),
        ),
      );

      expect(item, isNot(otherAttachment));
      expect(item, isNot(otherOutcome));
    });

    test('compares a failed outcome by the exception it carries', () {
      final refused = BatchUploadItemResult(
        attachment: attachmentOf('a-0'),
        result: const Result.failure(StreamApiException(message: 'Refused', statusCode: 400)),
      );
      final same = BatchUploadItemResult(
        attachment: attachmentOf('a-0'),
        result: const Result.failure(StreamApiException(message: 'Refused', statusCode: 400)),
      );
      final different = BatchUploadItemResult(
        attachment: attachmentOf('a-0'),
        result: const Result.failure(StreamApiException(message: 'Refused', statusCode: 403)),
      );

      expect(refused, same);
      expect(refused, isNot(different));
    });
  });
}
