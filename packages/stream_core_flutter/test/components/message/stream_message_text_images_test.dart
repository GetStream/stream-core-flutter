import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

void main() {
  testWidgets('shows a markdown image as a link to it by default', (tester) async {
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

  testWidgets('labels an image link with its address when it has no alt text', (tester) async {
    await _pump(tester, StreamMessageText('![](https://example.com/cat.png)'));

    expect(find.textContaining('https://example.com/cat.png', findRichText: true), findsOneWidget);
  });

  testWidgets('shortens a long address used as an image link label', (tester) async {
    final url = 'https://example.com/${'a' * 500}.png';
    await _pump(tester, StreamMessageText('![]($url)'));

    expect(find.textContaining('${url.substring(0, 47)}…', findRichText: true), findsOneWidget);
  });

  testWidgets('shows a reference-style image as a link', (tester) async {
    await _pump(tester, StreamMessageText('![a cat][cat]\n\n[cat]: https://example.com/cat.png'));

    expect(find.byType(Image), findsNothing);
    expect(find.textContaining('a cat', findRichText: true), findsOneWidget);
  });

  testWidgets('keeps an image inside a link as the label of that link', (tester) async {
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

  testWidgets('does not build images with imageBuilder unless showImage allows them', (tester) async {
    await _pump(
      tester,
      StreamMessageText('![a cat](https://example.com/cat.png)', imageBuilder: _fakeImage),
    );

    expect(find.byKey(ValueKey(Uri.parse('https://example.com/cat.png'))), findsNothing);
    expect(find.textContaining('a cat', findRichText: true), findsOneWidget);
  });

  testWidgets('shows the images showImage allows and links the rest', (tester) async {
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

  testWidgets("passes the image's address, alt text and title to showImage", (tester) async {
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
    testWidgets('shows an image that is not http or https as a link even when showImage allows it: $url', (
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
    });
  }

  testWidgets('shows an allowed image with StreamNetworkImage when no imageBuilder is set', (tester) async {
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

Widget _fakeImage(Uri uri, String? title, String? alt) => SizedBox(key: ValueKey(uri), width: 10, height: 10);
