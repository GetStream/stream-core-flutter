import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

/// Wraps [child] in an app with a [StreamTheme].
Widget withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

/// A local server that answers 404 until [recover] is called, then serves a
/// PNG, with the image cache pointed at a temporary directory.
class RecoveringImageServer {
  RecoveringImageServer._(this._server, this._png) {
    _server.listen((request) {
      final response = request.response;
      if (_failing) {
        response.statusCode = HttpStatus.notFound;
      } else {
        response
          ..headers.contentType = ContentType('image', 'png')
          ..add(_png);
      }
      response.close();
    });
  }

  /// Starts a server that fails until [recover] is called.
  static Future<RecoveringImageServer> start(WidgetTester tester) async {
    HttpOverrides.global = null;
    final cacheDirectory = Directory.systemTemp.createTempSync('stream_network_image_retry_test');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => cacheDirectory.path,
    );

    final (server, png) = (await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawColor(const ui.Color(0xFFFF0000), ui.BlendMode.src);
      final image = await recorder.endRecording().toImage(8, 8);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return (await HttpServer.bind(InternetAddress.loopbackIPv4, 0), bytes!.buffer.asUint8List());
    }))!;
    addTearDown(() => tester.runAsync(() => server.close(force: true)));
    return RecoveringImageServer._(server, png);
  }

  final HttpServer _server;
  final List<int> _png;
  var _failing = true;

  /// The URL of [path] on this server.
  String url(String path) => 'http://127.0.0.1:${_server.port}/$path';

  /// Makes the server serve the image from now on.
  void recover() => _failing = false;
}

/// Pumps real time until [condition] holds, for at most five seconds.
Future<void> pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var i = 0; i < 100 && !condition(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
}

/// The number of images shown with pixels.
int shownImages(WidgetTester tester) {
  return tester.widgetList<RawImage>(find.byType(RawImage)).where((it) => it.image != null).length;
}

/// Removes the widget tree and lets pending timers fire.
Future<void> disposeAndFlushTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(minutes: 1));
}
