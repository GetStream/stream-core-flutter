import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

void main() {
  testWidgets('StreamMessageText shows a markdown image as a link to it by default', (tester) async {
    String? tapped;
    await _pump(
      tester,
      StreamMessageText(
        'Look: ![a cat](https://example.com/cat.png)',
        onTapLink: (_, href, _) => tapped = href,
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.byType(StreamNetworkImage), findsNothing);

    await tester.tapOnText(find.textRange.ofSubstring('a cat'));
    expect(tapped, 'https://example.com/cat.png');
  });

  testWidgets('StreamMessageText labels an image link with its host when it has no alt text', (tester) async {
    String? tapped;
    await _pump(
      tester,
      StreamMessageText('![](https://cdn.example.com/uploads/cat.png)', onTapLink: (_, href, _) => tapped = href),
    );

    await tester.tapOnText(find.textRange.ofSubstring('cdn.example.com'));

    expect(find.textContaining('/uploads/', findRichText: true), findsNothing);
    expect(tapped, 'https://cdn.example.com/uploads/cat.png');
  });

  testWidgets('StreamMessageText labels an image link with its shortened address when it has no host', (tester) async {
    final url = 'data:image/png;base64,${'a' * 500}';
    await _pump(tester, StreamMessageText('![]($url)'));

    expect(find.textContaining('${url.substring(0, 47)}…', findRichText: true), findsOneWidget);
  });

  testWidgets('StreamMessageText shows a reference-style image as a link', (tester) async {
    await _pump(tester, StreamMessageText('![a cat][cat]\n\n[cat]: https://example.com/cat.png'));

    expect(find.byType(Image), findsNothing);
    expect(find.textContaining('a cat', findRichText: true), findsOneWidget);
  });

  testWidgets('StreamMessageText keeps an image inside a link as the label of that link', (tester) async {
    String? tapped;
    await _pump(
      tester,
      StreamMessageText(
        '[![a cat](https://example.com/cat.png)](https://example.com/page)',
        onTapLink: (_, href, _) => tapped = href,
      ),
    );

    await tester.tapOnText(find.textRange.ofSubstring('a cat'));
    expect(tapped, 'https://example.com/page');
  });

  testWidgets('StreamMessageText does not build images with imageBuilder unless showImage allows them', (tester) async {
    await _pump(
      tester,
      StreamMessageText('![a cat](https://example.com/cat.png)', imageBuilder: _fakeImage),
    );

    expect(find.byKey(ValueKey(Uri.parse('https://example.com/cat.png'))), findsNothing);
    expect(find.textContaining('a cat', findRichText: true), findsOneWidget);
  });

  testWidgets('StreamMessageText shows the images showImage allows and links the rest', (tester) async {
    await _pump(
      tester,
      StreamMessageText(
        '![ours](https://cdn.example.com/a.png) and ![theirs](https://other.example.org/b.png)',
        imageBuilder: _fakeImage,
        showImage: (image) => image.uri.host == 'cdn.example.com',
      ),
    );

    expect(find.byKey(ValueKey(Uri.parse('https://cdn.example.com/a.png'))), findsOneWidget);
    expect(find.byKey(ValueKey(Uri.parse('https://other.example.org/b.png'))), findsNothing);
    expect(find.textContaining('theirs', findRichText: true), findsOneWidget);
  });

  testWidgets("StreamMessageText passes the image's address, alt text and title to showImage", (tester) async {
    StreamMarkdownImage? asked;
    await _pump(
      tester,
      StreamMessageText(
        '![ours](https://cdn.example.com/a.png "Our image")',
        showImage: (image) {
          asked = image;
          return false;
        },
      ),
    );

    expect(asked?.uri, Uri.parse('https://cdn.example.com/a.png'));
    expect(asked?.alt, 'ours');
    expect(asked?.title, 'Our image');
  });

  for (final url in ['data:image/png;base64,iVBORw0KGgo=', 'file:///etc/hosts', 'resource:logo.png']) {
    testWidgets(
      'StreamMessageText shows an image that is not http or https as a link even when showImage allows it: $url',
      (
        tester,
      ) async {
        var asked = false;
        await _pump(
          tester,
          StreamMessageText(
            '![logo]($url)',
            imageBuilder: _fakeImage,
            showImage: (_) => asked = true,
          ),
        );

        expect(asked, isFalse);
        expect(find.byWidgetPredicate((widget) => widget.key is ValueKey<Uri>), findsNothing);
        expect(find.textContaining('logo', findRichText: true), findsOneWidget);
      },
    );
  }

  testWidgets('StreamMessageText passes showImage the title as plain text', (tester) async {
    StreamMarkdownImage? asked;
    await _pump(
      tester,
      StreamMessageText(
        r'![cat](https://cdn.example.com/a.png "Tom & Jerry \"q\" <x>")',
        showImage: (image) {
          asked = image;
          return false;
        },
      ),
    );

    expect(asked?.title, 'Tom & Jerry "q" <x>');
  });

  testWidgets('StreamMessageText decodes an entity in an image title only once', (tester) async {
    StreamMarkdownImage? asked;
    await _pump(
      tester,
      StreamMessageText(
        '![cat](https://cdn.example.com/a.png "a &amp;lt; b")',
        showImage: (image) {
          asked = image;
          return false;
        },
      ),
    );

    expect(asked?.title, 'a &lt; b');
  });

  testWidgets('StreamMessageText passes showImage the same address as imageBuilder', (tester) async {
    Uri? asked;
    Uri? built;
    await _pump(
      tester,
      StreamMessageText(
        '![cat](https://cdn.example.com/a.png#100x50)',
        showImage: (image) {
          asked = image.uri;
          return true;
        },
        imageBuilder: (uri, title, alt) {
          built = uri;
          return _fakeImage(uri, title, alt);
        },
      ),
    );

    expect(asked, Uri.parse('https://cdn.example.com/a.png'));
    expect(built, asked);
  });

  testWidgets('StreamMessageText shows an image whose address cannot be parsed as a link', (tester) async {
    var asked = false;
    String? tapped;
    await _pump(
      tester,
      StreamMessageText(
        '![logo](http://[::1)',
        imageBuilder: _fakeImage,
        showImage: (_) => asked = true,
        onTapLink: (_, href, _) => tapped = href,
      ),
    );

    await tester.tapOnText(find.textRange.ofSubstring('logo'));

    expect(asked, isFalse);
    expect(tapped, isNotNull);
  });

  testWidgets('StreamMessageText applies a new showImage when given a new key', (tester) async {
    const text = '![cat](https://cdn.example.com/a.png)';
    await _pump(
      tester,
      StreamMessageText(text, key: const ValueKey(1), imageBuilder: _fakeImage, showImage: (_) => false),
    );
    await _pump(
      tester,
      StreamMessageText(text, key: const ValueKey(2), imageBuilder: _fakeImage, showImage: (_) => true),
    );

    expect(find.byKey(ValueKey(Uri.parse('https://cdn.example.com/a.png'))), findsOneWidget);
  });

  testWidgets('StreamMessageText shortens a long host used as an image link label', (tester) async {
    final host = '${'a' * 100}.example.com';
    await _pump(tester, StreamMessageText('![](https://$host/cat.png)'));

    expect(find.textContaining('${host.substring(0, 47)}…', findRichText: true), findsOneWidget);
  });

  testWidgets('StreamMessageText opens the outer link of an allowed image inside a link', (tester) async {
    String? tapped;
    await _pump(
      tester,
      StreamMessageText(
        '[![cat](https://cdn.example.com/a.png)](https://example.com/page)',
        imageBuilder: _fakeImage,
        showImage: (_) => true,
        onTapLink: (_, href, _) => tapped = href,
      ),
    );

    await tester.tap(find.byKey(ValueKey(Uri.parse('https://cdn.example.com/a.png'))));

    expect(tapped, 'https://example.com/page');
  });

  testWidgets('StreamMessageText shows an allowed image with StreamNetworkImage when no imageBuilder is set', (
    tester,
  ) async {
    await _pump(
      tester,
      StreamMessageText('![a cat](https://example.com/cat.png)', showImage: (_) => true),
    );

    final image = tester.widget<StreamNetworkImage>(find.byType(StreamNetworkImage));
    expect(image.props.url, 'https://example.com/cat.png');
    expect(image.props.semanticLabel, 'a cat');
  });
}

Future<void> _pump(WidgetTester tester, StreamMessageText text) {
  return tester.pumpWidget(
    MaterialApp(
      home: Theme(
        data: ThemeData(extensions: [StreamTheme()]),
        child: StreamMessageLayout(data: const StreamMessageLayoutData(), child: text),
      ),
    ),
  );
}

Widget _fakeImage(Uri uri, String? title, String? alt) {
  return ColoredBox(key: ValueKey(uri), color: const Color(0xFF000000), child: const SizedBox.square(dimension: 10));
}
