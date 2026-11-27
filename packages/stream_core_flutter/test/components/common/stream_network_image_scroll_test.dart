import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('defers loading while its list is flung fast', (tester) async {
    await _pumpList(tester, ValueNotifier(true));

    expect(PaintingBinding.instance.imageCache.pendingImageCount, 0);
  });

  testWidgets('loads once its list slows down', (tester) async {
    final flinging = ValueNotifier(true);
    await _pumpList(tester, flinging);

    flinging.value = false;
    await tester.pump();
    await tester.pump();

    expect(PaintingBinding.instance.imageCache.pendingImageCount, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
  });
}

Future<void> _pumpList(WidgetTester tester, ValueListenable<bool> flinging) {
  final cacheDirectory = Directory.systemTemp.createTempSync('stream_network_image_scroll_test');
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (_) async => cacheDirectory.path,
  );

  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [StreamTheme()]),
      home: ListView(
        physics: _FlingingPhysics(flinging),
        children: [StreamNetworkImage('http://127.0.0.1:1/a.png', width: 40, height: 40)],
      ),
    ),
  );
}

class _FlingingPhysics extends ScrollPhysics {
  const _FlingingPhysics(this.flinging, {super.parent});

  final ValueListenable<bool> flinging;

  @override
  _FlingingPhysics applyTo(ScrollPhysics? ancestor) => _FlingingPhysics(flinging, parent: buildParent(ancestor));

  @override
  bool recommendDeferredLoading(double velocity, ScrollMetrics metrics, BuildContext context) => flinging.value;
}
