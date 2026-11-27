import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:stream_core_flutter/src/cache/internal/stream_bounded_image.dart';

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

  testWidgets('passes its size to the decoder in logical pixels', (tester) async {
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

  testWidgets('passes its fit to the decoder', (tester) async {
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
    final imageState = tester.state(find.byType(Image));

    rebuild(() {});
    await tester.pump();

    expect(_imageOf(tester), before);
    expect(tester.state(find.byType(Image)), same(imageState));
  });

  testWidgets('labels the image for screen readers with its semantic label', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(StreamNetworkImage('https://example.com/a.png', width: 40, height: 40, semanticLabel: 'Avatar')),
    );

    expect(find.bySemanticsLabel('Avatar'), findsOneWidget);
  });

  testWidgets('leaves the image out of the semantics tree when asked to', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        StreamNetworkImage(
          'https://example.com/a.png',
          width: 40,
          height: 40,
          semanticLabel: 'Avatar',
          excludeFromSemantics: true,
        ),
      ),
    );

    expect(find.bySemanticsLabel('Avatar'), findsNothing);
  });

  testWidgets('paints the image with the opacity it is given', (tester) async {
    const opacity = AlwaysStoppedAnimation(0.5);
    await tester.pumpWidget(
      _withStreamTheme(StreamNetworkImage('https://example.com/a.png', width: 40, height: 40, opacity: opacity)),
    );

    expect(tester.widget<RawImage>(find.byType(RawImage)).opacity, opacity);
  });
}

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
