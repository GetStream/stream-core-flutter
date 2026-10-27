import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:stream_core_flutter/chat.dart';

void main() {
  testWidgets('StreamMessageText opens a domain without a scheme over https', (tester) async {
    expect(await _tapLink(tester, 'Some link: youtube.com', 'youtube.com'), 'https://youtube.com');
  });

  testWidgets('StreamMessageText opens the path of a domain without a scheme', (tester) async {
    expect(await _tapLink(tester, 'Docs at getstream.io/chat.', 'getstream.io/chat'), 'https://getstream.io/chat');
  });

  testWidgets('StreamMessageText leaves an unknown top-level domain as plain text', (tester) async {
    expect(await _tapLink(tester, 'Open config.json', 'config.json'), isNull);
  });

  testWidgets('StreamMessageText opens a www address over https', (tester) async {
    expect(await _tapLink(tester, 'See www.google.com', 'www.google.com'), 'https://www.google.com');
  });

  testWidgets('StreamMessageText opens an address with a scheme in quotes', (tester) async {
    expect(await _tapLink(tester, 'Open "http://example.com/a" now', 'example.com'), 'http://example.com/a');
  });

  testWidgets('StreamMessageText opens a domain in brackets that are not a link', (tester) async {
    expect(await _tapLink(tester, 'See [youtube.com] for more', 'youtube.com'), 'https://youtube.com');
  });

  testWidgets('StreamMessageText opens a domain after a closed bracket', (tester) async {
    expect(await _tapLink(tester, '[1] youtube.com](https://example.com)', 'youtube.com'), 'https://youtube.com');
  });

  testWidgets('StreamMessageText opens an email address as an email', (tester) async {
    expect(await _tapLink(tester, 'Mail anna.li@gmail.com', 'anna.li'), 'mailto:anna.li@gmail.com');
  });

  testWidgets('StreamMessageText opens a whole email address with a tag as an email', (tester) async {
    expect(await _tapLink(tester, 'Mail anna.li+tag@gmail.com', 'anna.li'), 'mailto:anna.li+tag@gmail.com');
  });

  testWidgets('StreamMessageText opens a markdown link to an email address', (tester) async {
    expect(
      await _tapLink(tester, '[Mail Anna](mailto:anna@example.com)', 'Mail Anna'),
      'mailto:anna@example.com',
    );
  });

  testWidgets('StreamMessageText keeps the target of a domain in a link label', (tester) async {
    expect(
      await _tapLink(tester, '[visit youtube.com](https://example.com)', 'youtube.com'),
      'https://example.com',
    );
  });

  testWidgets('StreamMessageText keeps the target of a domain in a link label with brackets', (tester) async {
    expect(
      await _tapLink(tester, '[youtube.com [docs]](https://example.com)', 'youtube.com'),
      'https://example.com',
    );
  });

  testWidgets('StreamMessageText keeps the target of a domain in a link label with an escaped bracket', (tester) async {
    expect(
      await _tapLink(tester, r'[a \] youtube.com](https://example.com)', 'youtube.com'),
      'https://example.com',
    );
  });

  testWidgets('StreamMessageText keeps the target of a domain in an emphasized link label', (tester) async {
    expect(
      await _tapLink(tester, '[*youtube.com*](https://example.com)', 'youtube.com'),
      'https://example.com',
    );
  });

  testWidgets('StreamMessageText keeps the target of a domain in a reference link label', (tester) async {
    expect(
      await _tapLink(tester, '[youtube.com][docs]\n\n[docs]: https://example.com', 'youtube.com'),
      'https://example.com',
    );
  });

  testWidgets('StreamMessageText keeps the target of a domain that names a link reference', (tester) async {
    expect(
      await _tapLink(tester, '[YouTube.com]\n\n[youtube.com]: https://example.com', 'YouTube.com'),
      'https://example.com',
    );
  });

  testWidgets('StreamMessageText leaves a domain in inline code as plain text', (tester) async {
    expect(await _tapLink(tester, 'Run `youtube.com` now', 'youtube.com'), isNull);
  });

  testWidgets('StreamMessageText lets a custom syntax claim an address first', (tester) async {
    expect(
      await _tapLink(
        tester,
        'Some link: youtube.com',
        'youtube.com',
        inlineSyntaxes: [_FixedLinkSyntax('youtube.com', 'app://videos')],
      ),
      'app://videos',
    );
  });
}

// Renders [text] and returns the link opened by tapping [linkText], or null
// when the tap opens nothing.
Future<String?> _tapLink(
  WidgetTester tester,
  String text,
  String linkText, {
  List<md.InlineSyntax>? inlineSyntaxes,
}) async {
  String? opened;
  await tester.pumpWidget(
    MaterialApp(
      home: Theme(
        data: ThemeData(extensions: [StreamTheme()]),
        child: StreamMessageLayout(
          data: const StreamMessageLayoutData(),
          child: StreamMessageText(
            text,
            inlineSyntaxes: inlineSyntaxes,
            onTapLink: (_, href, _) => opened = href,
          ),
        ),
      ),
    ),
  );

  await tester.tapOnText(find.textRange.ofSubstring(linkText));
  return opened;
}

// Links every [pattern] to [href].
class _FixedLinkSyntax extends md.InlineSyntax {
  _FixedLinkSyntax(String pattern, this.href) : super(RegExp.escape(pattern));

  final String href;

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('a', match[0]!)..attributes['href'] = href);
    return true;
  }
}
