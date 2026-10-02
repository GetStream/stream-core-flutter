@TestOn('vm')
library;

import 'dart:io';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  test('AttachmentFile.fromData keeps the name it is given', () {
    final file = AttachmentFile.fromData(Uint8List(3), name: 'photo.png');

    expect(file.name, 'photo.png');
  });

  test('AttachmentFile.fromData takes its MIME type from its name', () {
    final file = AttachmentFile.fromData(Uint8List(3), name: 'photo.png');

    expect(file.mimeType, 'image/png');
  });

  test('AttachmentFile.extension returns the text after the last dot', () {
    final file = AttachmentFile.fromData(Uint8List(3), name: 'archive.tar.gz');

    expect(file.extension, 'gz');
  });

  test('AttachmentFile.extension returns null when the name has no dot', () {
    final file = AttachmentFile('/me/user/somefile');

    expect(file.extension, isNull);
  });

  test('AttachmentFile.extension returns null when the name ends with a dot', () {
    final file = AttachmentFile('/me/user/somefile.');

    expect(file.extension, isNull);
  });

  test('AttachmentFile.toMultipartFile builds the part from the bytes of a file made from data', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final file = AttachmentFile.fromData(bytes, name: 'photo.png');

    final part = await file.toMultipartFile();

    expect(part.length, bytes.length);
    expect(part.filename, 'photo.png');
  });

  test('AttachmentFile.toMultipartFile builds the part from the file at the path', () async {
    final path = _tempFile(Uint8List.fromList([1, 2, 3, 4]), name: 'notes.txt');
    final file = AttachmentFile(path);

    final part = await file.toMultipartFile();

    expect(part.length, 4);
    expect(part.filename, 'notes.txt');
  });

  test('AttachmentFile.toMultipartFile throws when the file at the path is gone', () async {
    final path = _tempFile(Uint8List.fromList([1, 2, 3]), name: 'notes.txt');
    final file = AttachmentFile(path);
    File(path).deleteSync();

    await expectLater(file.toMultipartFile(), throwsA(isA<FileSystemException>()));
  });
}

String _tempFile(Uint8List bytes, {required String name}) {
  final directory = Directory.systemTemp.createTempSync('attachment_file_test');
  addTearDown(() => directory.deleteSync(recursive: true));

  final file = File('${directory.path}${Platform.pathSeparator}$name')..writeAsBytesSync(bytes);
  return file.path;
}
