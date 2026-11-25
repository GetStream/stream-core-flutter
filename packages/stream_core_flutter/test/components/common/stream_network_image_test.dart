import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:stream_core_flutter/src/cache/internal/bounded_image.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

BoundedImage _imageOf(WidgetTester tester, {int index = 0}) {
  final images = tester.widgetList<Image>(find.byType(Image)).toList();
  return images[index].image as BoundedImage;
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

      final first = _imageOf(tester).provider as CachedNetworkImageProvider;
      final second = _imageOf(tester, index: 1).provider as CachedNetworkImageProvider;

      expect(first.cacheManager, isNotNull);
      expect(first.cacheManager, same(second.cacheManager));
    });
  });

  group('StreamNetworkImage decode size', () {
    testWidgets('decodes no larger than its size in physical pixels', (tester) async {
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_withStreamTheme(StreamNetworkImage('https://example.com/a.png', width: 40, height: 20)));

      final image = _imageOf(tester);
      expect((image.maxWidth, image.maxHeight), (120, 60));
    });

    testWidgets('decodes no larger than the cache size it is given', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamNetworkImage('https://example.com/a.png', width: 40, height: 40, cacheWidth: 64, cacheHeight: 32),
        ),
      );

      final image = _imageOf(tester);
      expect((image.maxWidth, image.maxHeight), (64, 32));
    });

    testWidgets('decodes no larger than 4096 pixels on a side', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(StreamNetworkImage('https://example.com/a.png', cacheWidth: 10000)),
      );

      final image = _imageOf(tester);
      expect((image.maxWidth, image.maxHeight), (4096, 4096));
    });
  });
}
