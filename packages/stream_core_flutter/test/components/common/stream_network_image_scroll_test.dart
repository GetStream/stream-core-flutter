import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

// Physics that always recommend deferring loads, as while a list is flung fast.
class _FlingingPhysics extends ScrollPhysics {
  const _FlingingPhysics({super.parent});

  @override
  _FlingingPhysics applyTo(ScrollPhysics? ancestor) => _FlingingPhysics(parent: buildParent(ancestor));

  @override
  bool recommendDeferredLoading(double velocity, ScrollMetrics metrics, BuildContext context) => true;
}

void main() {
  testWidgets('defers loading while its list is flung fast', (tester) async {
    HttpOverrides.global = null;
    final cacheDirectory = Directory.systemTemp.createTempSync('stream_network_image_scroll_test');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => cacheDirectory.path,
    );
    var requests = 0;
    final server = (await tester.runAsync(() => HttpServer.bind(InternetAddress.loopbackIPv4, 0)))!
      ..listen((request) {
        requests++;
        request.response
          ..statusCode = HttpStatus.notFound
          ..close();
      });
    addTearDown(() => tester.runAsync(() => server.close(force: true)));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: ListView(
          physics: const _FlingingPhysics(),
          children: [StreamNetworkImage('http://127.0.0.1:${server.port}/a.png', width: 40, height: 40)],
        ),
      ),
    );
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }

    expect(requests, 0);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
  });
}
