import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/src/cache/internal/stream_bounded_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('evicts an image still shown after it drops out of the image cache', () async {
    final cache = PaintingBinding.instance.imageCache;
    final maximumSize = cache.maximumSize;
    addTearDown(() => cache.maximumSize = maximumSize);
    cache.maximumSize = 1;

    final shown = StreamBoundedImage(MemoryImage(await _png(4, 4)), width: 2);
    final stream = shown.resolve(ImageConfiguration.empty);
    final loaded = Completer<void>();
    final listener = ImageStreamListener((_, _) => loaded.complete());
    stream.addListener(listener);
    addTearDown(() => stream.removeListener(listener));
    await loaded.future;

    for (var i = 0; i < 8; i++) {
      await _load(StreamBoundedImage(MemoryImage(await _png(5 + i, 5)), width: 2));
    }
    StreamBoundedImage.evictAll(shown.imageProvider);

    expect(cache.statusForKey(await shown.obtainKey(ImageConfiguration.empty)).live, isFalse);
  });
}

Future<Uint8List> _png(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(const ui.Color(0xFFFF0000), ui.BlendMode.src);
  final image = await recorder.endRecording().toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

Future<void> _load(ImageProvider provider) {
  final completer = Completer<void>();
  provider
      .resolve(ImageConfiguration.empty)
      .addListener(ImageStreamListener((_, _) => completer.complete(), onError: completer.completeError));
  return completer.future;
}
