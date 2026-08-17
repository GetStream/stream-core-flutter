import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('StreamNetworkImage caching', () {
    testWidgets('routes all images through one shared cache manager', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Column(
            children: [
              StreamNetworkImage('https://example.com/a.png'),
              StreamNetworkImage('https://example.com/b.png'),
            ],
          ),
        ),
      );

      final images = tester.widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage)).toList();
      expect(images, hasLength(2));

      // A Stream-owned cache manager is wired in (not the package default,
      // which would leave the widget's cacheManager null).
      expect(images.first.cacheManager, isNotNull);

      // Every StreamNetworkImage shares the SAME cache manager instance, so the
      // whole SDK caches (and evicts) through one place.
      expect(images.first.cacheManager, same(images.last.cacheManager));
    });
  });
}
