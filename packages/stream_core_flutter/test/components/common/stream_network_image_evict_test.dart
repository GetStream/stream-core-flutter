import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

Future<List<int>> _png() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(const ui.Color(0xFFFF0000), ui.BlendMode.src);
  final image = await recorder.endRecording().toImage(8, 8);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

void main() {
  testWidgets('evictFromCache removes a shown image from the in-memory cache', (tester) async {
    HttpOverrides.global = null;
    final cacheDirectory = Directory.systemTemp.createTempSync('stream_network_image_evict_test');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => cacheDirectory.path,
    );
    final png = (await tester.runAsync(_png))!;
    final server = (await tester.runAsync(() => HttpServer.bind(InternetAddress.loopbackIPv4, 0)))!
      ..listen(
        (request) => request.response
          ..headers.contentType = ContentType('image', 'png')
          ..add(png)
          ..close(),
      );
    addTearDown(() => tester.runAsync(() => server.close(force: true)));
    final url = 'http://127.0.0.1:${server.port}/avatar.png';

    await tester.pumpWidget(_withStreamTheme(StreamNetworkImage(url, width: 40, height: 40)));
    for (var i = 0; i < 100 && !tester.widgetList<RawImage>(find.byType(RawImage)).any((it) => it.image != null); i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    final provider = tester.widget<Image>(find.byType(Image)).image;
    final key = await provider.obtainKey(createLocalImageConfiguration(tester.element(find.byType(Image))));
    expect(PaintingBinding.instance.imageCache.containsKey(key), isTrue);

    var evicted = false;
    StreamNetworkImage.evictFromCache(url).whenComplete(() => evicted = true).ignore();
    for (var i = 0; i < 100 && !evicted; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    expect(evicted, isTrue, reason: 'evictFromCache finished');

    expect(PaintingBinding.instance.imageCache.containsKey(key), isFalse);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
  });
}
