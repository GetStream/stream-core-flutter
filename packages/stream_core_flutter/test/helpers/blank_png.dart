import 'dart:io';
import 'dart:typed_data';

/// A blank 1-bit greyscale PNG of [width] by [height] pixels.
Uint8List blankPng(int width, int height) {
  Uint8List chunk(String type, List<int> data) {
    return (BytesBuilder()
          ..add((ByteData(4)..setUint32(0, data.length)).buffer.asUint8List())
          ..add(type.codeUnits)
          ..add(data)
          ..add(_crc32([...type.codeUnits, ...data])))
        .takeBytes();
  }

  final header =
      (ByteData(13)
            ..setUint32(0, width)
            ..setUint32(4, height)
            ..setUint8(8, 1))
          .buffer
          .asUint8List();
  final row = Uint8List(1 + (width + 7) ~/ 8);
  final pixels = BytesBuilder(copy: false);
  for (var y = 0; y < height; y++) {
    pixels.add(row);
  }

  return (BytesBuilder()
        ..add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        ..add(chunk('IHDR', header))
        ..add(chunk('IDAT', zlib.encode(pixels.takeBytes())))
        ..add(chunk('IEND', const [])))
      .takeBytes();
}

Uint8List _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final byte in bytes) {
    crc ^= byte;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return (ByteData(4)..setUint32(0, crc ^ 0xFFFFFFFF)).buffer.asUint8List();
}
