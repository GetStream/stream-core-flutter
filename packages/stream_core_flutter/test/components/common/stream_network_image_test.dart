import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:stream_core_flutter/src/cache/internal/stream_bounded_image.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

StreamBoundedImage _imageOf(WidgetTester tester, {int index = 0}) {
  final images = tester.widgetList<Image>(find.byType(Image)).toList();
  return images[index].image as StreamBoundedImage;
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

      final first = _imageOf(tester).imageProvider as CachedNetworkImageProvider;
      final second = _imageOf(tester, index: 1).imageProvider as CachedNetworkImageProvider;

      expect(first.cacheManager, isNotNull);
      expect(first.cacheManager, same(second.cacheManager));
    });
  });

  testWidgets('decodes for its size times the device pixel ratio', (tester) async {
    await tester.pumpWidget(_withStreamTheme(StreamNetworkImage('https://example.com/a.png', width: 40, height: 20)));

    final image = _imageOf(tester);
    expect((image.width, image.height, image.useLogicalSize), (40, 20, true));
  });

  testWidgets('decodes to fit within the cache size it is given', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        StreamNetworkImage('https://example.com/a.png', width: 40, height: 40, cacheWidth: 64, cacheHeight: 32),
      ),
    );

    final image = _imageOf(tester);
    expect((image.width, image.height, image.useLogicalSize, image.fit), (64, 32, false, BoxFit.contain));
  });

  testWidgets('decodes to fill a box it covers', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(StreamNetworkImage('https://example.com/a.png', width: 40, height: 40, fit: BoxFit.cover)),
    );

    expect(_imageOf(tester).fit, BoxFit.cover);
  });

  testWidgets('decodes to fit within the cache size it is given, even when covering its box', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        StreamNetworkImage(
          'https://example.com/a.png',
          width: 40,
          height: 40,
          cacheWidth: 64,
          cacheHeight: 64,
          fit: BoxFit.cover,
        ),
      ),
    );

    expect(_imageOf(tester).fit, BoxFit.contain);
  });

  testWidgets('keeps the same image when rebuilt with the same properties', (tester) async {
    late StateSetter rebuild;
    await tester.pumpWidget(
      _withStreamTheme(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return StreamNetworkImage('https://example.com/a.png', width: 40, height: 40);
          },
        ),
      ),
    );
    final before = _imageOf(tester);

    rebuild(() {});
    await tester.pump();

    final after = _imageOf(tester);
    expect(after, isNot(same(before)));
    expect(after, before);
  });
}
