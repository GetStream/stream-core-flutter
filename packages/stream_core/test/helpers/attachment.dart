import 'package:stream_core/stream_core.dart';

/// An attachment of exactly [bytes] bytes.
StreamAttachment attachmentOf(
  String id, {
  int bytes = 1000,
  AttachmentType type = AttachmentType.file,
  Map<String, Object?>? custom,
}) {
  return StreamAttachment(
    id: id,
    type: type,
    file: AttachmentFile.fromData(Uint8List(bytes), name: '$id.bin'),
    custom: custom,
  );
}

/// [count] attachments named `a-0`, `a-1`, ... of [bytes] bytes each.
List<StreamAttachment> attachmentsOf(int count, {int bytes = 1000}) {
  return [for (var index = 0; index < count; index++) attachmentOf('a-$index', bytes: bytes)];
}
