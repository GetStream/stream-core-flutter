import 'dart:io';

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

void main() {
  testWidgets('retries every image of a failed URL when the retry listenable notifies', (tester) async {
    final retry = ChangeNotifier();
    addTearDown(retry.dispose);
    HttpOverrides.global = null;
    final cacheDirectory = Directory.systemTemp.createTempSync('stream_network_image_retry_test');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => cacheDirectory.path,
    );
    final server = (await tester.runAsync(() => HttpServer.bind(InternetAddress.loopbackIPv4, 0)))!
      ..listen(
        (request) => request.response
          ..statusCode = HttpStatus.notFound
          ..close(),
      );
    addTearDown(() => tester.runAsync(() => server.close(force: true)));
    final url = 'http://127.0.0.1:${server.port}/failing.png';

    await tester.pumpWidget(
      _withStreamTheme(
        Column(
          children: [
            StreamNetworkImage(url, width: 40, height: 40, retryListenable: retry),
            StreamNetworkImage(url, width: 40, height: 40, retryListenable: retry),
          ],
        ),
      ),
    );
    for (var i = 0; i < 100 && find.byType(StreamImageErrorPlaceholder).evaluate().length < 2; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
    }
    expect(find.byType(StreamImageErrorPlaceholder), findsNWidgets(2));

    retry.notifyListeners();
    await tester.pump();

    expect(find.byType(StreamImageErrorPlaceholder), findsNothing);
  });
}
