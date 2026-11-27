import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/src/cache/internal/stream_bounded_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('forgets decoded sizes of images no longer cached once more are tracked than the cache holds', () async {
    final cache = PaintingBinding.instance.imageCache;
    final maximumSize = cache.maximumSize;
    addTearDown(() => cache.maximumSize = maximumSize);
    cache.maximumSize = 4;

    for (var i = 0; i < 20; i++) {
      await _load(StreamBoundedImage(MemoryImage(await _png(4 + i, 4)), width: 2));
    }

    expect(StreamBoundedImage.debugTrackedImageCount, lessThanOrEqualTo(2 * 4 + 1));
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
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (_, _) {
      stream.removeListener(listener);
      completer.complete();
    },
    onError: completer.completeError,
  );
  stream.addListener(listener);
  return completer.future;
}
