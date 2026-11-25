import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/src/cache/internal/bounded_image.dart';

/// Encodes a solid image of [width] by [height] pixels as a PNG.
Future<Uint8List> _png(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(const ui.Color(0xFFFF0000), ui.BlendMode.src);
  final image = await recorder.endRecording().toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

/// A blank 1-bit greyscale PNG of [width] by [height] pixels, which stays a
/// few kilobytes however large it is.
Uint8List _blankPng(int width, int height) {
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

Future<ui.Image> _load(ImageProvider provider) {
  final stream = provider.resolve(ImageConfiguration.empty);
  final completer = Completer<ui.Image>();
  stream.addListener(
    ImageStreamListener(
      (info, _) => completer.complete(info.image),
      onError: completer.completeError,
    ),
  );
  return completer.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => PaintingBinding.instance.imageCache.clear());

  test('decodes an image larger than its bounds to fit them, keeping its aspect ratio', () async {
    final image = await _load(BoundedImage(MemoryImage(await _png(400, 200)), maxWidth: 100, maxHeight: 100));

    expect((image.width, image.height), (100, 50));
  });

  test('decodes an image smaller than its bounds at its own size', () async {
    final image = await _load(BoundedImage(MemoryImage(await _png(40, 20)), maxWidth: 100, maxHeight: 100));

    expect((image.width, image.height), (40, 20));
  });

  test('decodes a tall image within both bounds', () async {
    final image = await _load(BoundedImage(MemoryImage(await _png(10, 1000)), maxWidth: 100, maxHeight: 100));

    expect((image.width, image.height), (1, 100));
  });

  test('refuses an image larger than 8192 by 8192 pixels before decoding it', () async {
    await expectLater(
      _load(BoundedImage(MemoryImage(_blankPng(8193, 8193)), maxWidth: 100, maxHeight: 100)),
      throwsA(isA<ImageTooLargeException>().having((e) => (e.width, e.height), 'size', (8193, 8193))),
    );
  });

  test('caches each decoded size of the same image apart', () async {
    final provider = MemoryImage(await _png(400, 400));

    final small = await _load(BoundedImage(provider, maxWidth: 50, maxHeight: 50));
    final large = await _load(BoundedImage(provider, maxWidth: 200, maxHeight: 200));

    expect((small.width, large.width), (50, 200));
  });
}
