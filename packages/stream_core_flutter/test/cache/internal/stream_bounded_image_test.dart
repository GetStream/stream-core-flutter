import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/src/cache/internal/stream_bounded_image.dart';

import '../../helpers/blank_png.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('decodes an image larger than its bounds to fit them, keeping its aspect ratio', () async {
    final image = await _load(StreamBoundedImage(MemoryImage(await _png(400, 200)), width: 100, height: 100));

    expect((image.width, image.height), (100, 50));
  });

  test('decodes an image smaller than its bounds at its own size', () async {
    final image = await _load(StreamBoundedImage(MemoryImage(await _png(40, 20)), width: 100, height: 100));

    expect((image.width, image.height), (40, 20));
  });

  test('decodes a tall image within both bounds', () async {
    final image = await _load(StreamBoundedImage(MemoryImage(await _png(10, 1000)), width: 100, height: 100));

    expect((image.width, image.height), (1, 100));
  });

  test('fails to load an image with more pixels than 8192 by 8192', () async {
    await expectLater(
      _load(StreamBoundedImage(MemoryImage(blankPng(8193, 8193)), width: 100, height: 100)),
      throwsA(isA<Exception>().having((e) => '$e', 'message', contains('8193x8193'))),
    );
  });

  test('decodes an image to fill a box it covers, keeping its aspect ratio', () async {
    final image = await _load(
      StreamBoundedImage(MemoryImage(await _png(400, 200)), width: 100, height: 100, fit: BoxFit.cover),
    );

    expect((image.width, image.height), (200, 100));
  });

  test('decodes an image placed at its own size at that size', () async {
    final image = await _load(
      StreamBoundedImage(MemoryImage(await _png(400, 200)), width: 100, height: 100, fit: BoxFit.none),
    );

    expect((image.width, image.height), (400, 200));
  });

  test('decodes an image for a box in logical pixels times the device pixel ratio', () async {
    final image = await _load(
      StreamBoundedImage(MemoryImage(await _png(400, 200)), width: 50, useLogicalSize: true),
      devicePixelRatio: 2,
    );

    expect((image.width, image.height), (100, 50));
  });

  test('decodes an image no larger than 4096 pixels on a side', () async {
    final image = await _load(
      StreamBoundedImage(MemoryImage(await _png(5000, 100)), width: 10000, height: 10000),
    );

    expect((image.width, image.height), (4096, 81));
  });

  test('caches each decoded size of the same image apart', () async {
    final provider = MemoryImage(await _png(400, 400));

    final small = await _load(StreamBoundedImage(provider, width: 50, height: 50));
    final large = await _load(StreamBoundedImage(provider, width: 200, height: 200));

    expect((small.width, large.width), (50, 200));
  });

  test('loads an image again after a failed load', () async {
    final provider = _FailsOnceImage(await _png(40, 20));
    await expectLater(_load(StreamBoundedImage(provider, width: 100, height: 100)), throwsException);
    await Future<void>.delayed(Duration.zero);

    final image = await _load(StreamBoundedImage(provider, width: 100, height: 100));

    expect((image.width, image.height), (40, 20));
  });
}

// Encodes a solid image of [width] by [height] pixels as a PNG.
Future<Uint8List> _png(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(const ui.Color(0xFFFF0000), ui.BlendMode.src);
  final image = await recorder.endRecording().toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

Future<ui.Image> _load(ImageProvider provider, {double devicePixelRatio = 1}) {
  final stream = provider.resolve(ImageConfiguration(devicePixelRatio: devicePixelRatio));
  final completer = Completer<ui.Image>();
  stream.addListener(
    ImageStreamListener(
      (info, _) => completer.complete(info.image),
      onError: completer.completeError,
    ),
  );
  return completer.future;
}

class _FailsOnceImage extends ImageProvider<_FailsOnceImage> {
  _FailsOnceImage(this.bytes);

  final Uint8List bytes;
  var _loads = 0;

  @override
  Future<_FailsOnceImage> obtainKey(ImageConfiguration configuration) => SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_FailsOnceImage key, ImageDecoderCallback decode) {
    _loads += 1;
    final fails = _loads == 1;
    return OneFrameImageStreamCompleter(() async {
      if (fails) throw Exception('offline');
      final codec = await decode(await ui.ImmutableBuffer.fromUint8List(bytes));
      return ImageInfo(image: (await codec.getNextFrame()).image);
    }());
  }
}
