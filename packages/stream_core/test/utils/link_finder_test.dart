import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  final cases = <(String description, String text, List<String> links)>[
    // Addresses without a scheme.
    ('finds a domain', 'Some link: youtube.com', ['youtube.com']),
    ('finds a domain with a path', 'Docs at getstream.io/chat', ['getstream.io/chat']),
    ('finds a subdomain with a port and query', 'docs.example.co.uk:8080/a?b=c', ['docs.example.co.uk:8080/a?b=c']),
    ('finds a www address', 'See www.google.com', ['www.google.com']),
    ('finds an uppercase top-level domain', 'GOOGLE.COM and Example.Com', ['GOOGLE.COM', 'Example.Com']),
    ('finds an IP address', 'Open 192.168.0.1:8080/x', ['192.168.0.1:8080/x']),
    ('finds a domain that starts with an IP address', 'Open 1.2.3.4.nip.io', ['1.2.3.4.nip.io']),
    ('finds a punycode domain', 'xn--80ak6aa92e.com', ['xn--80ak6aa92e.com']),
    ('finds an internationalized domain', 'пример.рф bücher.de 例子.中国', ['пример.рф', 'bücher.de', '例子.中国']),
    ('finds a top-level domain in punycode', 'пример.xn--p1ai', ['пример.xn--p1ai']),
    ('finds a file name whose extension is a top-level domain', 'Open README.md', ['README.md']),

    // Addresses with a scheme.
    ('finds an http address', 'http://getstream.io/chat', ['http://getstream.io/chat']),
    ('finds an https address with any host', 'https://localhost:3000/path', ['https://localhost:3000/path']),
    ('finds an uppercase scheme', 'HTTPS://example.com', ['HTTPS://example.com']),
    ('finds a host that starts with an IP address', 'http://127.0.0.1.nip.io/x', ['http://127.0.0.1.nip.io/x']),
    ('finds credentials before the host', 'https://user:pw@example.com/x', ['https://user:pw@example.com/x']),

    // Text that is not a link.
    ('leaves out an unknown top-level domain', 'config.json and main.dart', []),
    ('leaves out version numbers and abbreviations', 'v1.2.3, e.g. this', []),
    ('leaves out an IP address with an octet out of range', '256.1.1.1', []),
    ('leaves out a version number with more than four parts', 'version 1.2.3.4.5', []),
    ('leaves out an unknown top-level domain in punycode', 'foo.xn--zzzz', []),
    ('leaves out an email address', 'Mail anna.li@gmail.com', []),
    ('leaves out the start of an email address with a tag', 'anna.li+tag@gmail.com', []),
    ('leaves out the start of an email address with a percent sign', 'jo.me%x@y.com', []),
    ('leaves out the start of an email address with a hyphen', 'abc.com-foo@x.com', []),
    ('leaves out a mention', 'Hey @john.doe', []),
    ('leaves out an address that continues a path', 'x/youtube.com', []),
    ('leaves out a top-level domain that continues into a word', 'youtube.comx', []),
    ('leaves out a label longer than 63 characters', '${'a' * 64}.com', []),
    ('leaves out a host with a label longer than 63 characters', 'https://${'a' * 64}.com', []),
    ('leaves out a domain longer than 253 characters', '${'a.' * 130}com', []),
    ('leaves out a host longer than 253 characters', 'https://${'a.' * 130}com', []),

    // Where a link starts and ends.
    ('finds a label of 63 characters', '${'a' * 63}.com', ['${'a' * 63}.com']),
    ('ends a link at a hyphen after the top-level domain', 'youtube.com-foo', ['youtube.com']),
    ('ends a link at a dot followed by an unknown label', 'youtube.com.x', ['youtube.com']),
    ('leaves out the punctuation ending a sentence', 'See youtube.com/docs. Really?', ['youtube.com/docs']),
    ('leaves out an at sign after a domain', 'Ping youtube.com@ now', ['youtube.com']),
    ('leaves out a closing parenthesis around a link', '(see youtube.com/foo)', ['youtube.com/foo']),
    (
      'keeps a closing parenthesis opened in the link',
      'en.wikipedia.org/wiki/Foo_(bar)',
      ['en.wikipedia.org/wiki/Foo_(bar)'],
    ),
    (
      'leaves out quotes around a link',
      '"youtube.com" “youtube.com” «youtube.com»',
      ['youtube.com', 'youtube.com', 'youtube.com'],
    ),
    ('leaves out emphasis around a link', '*youtube.com* ~youtube.com~', ['youtube.com', 'youtube.com']),
    (
      'leaves out opening punctuation before a link',
      '¿youtube.com? see—youtube.com （youtube.com） 「youtube.com」',
      ['youtube.com', 'youtube.com', 'youtube.com', 'youtube.com'],
    ),
    ('leaves out brackets around a link', 'see [youtube.com]', ['youtube.com']),
    ('starts a link after a non-breaking space', 'see\u00A0youtube.com', ['youtube.com']),
    ('starts a link after text in a script written without spaces', '请访问google.com了解更多', ['google.com']),
    ('reads only ASCII as the host after text in a script written without spaces', '访问example.中国', []),
    ('starts a link after an ellipsis', 'te paso el enlace...idealista.com/piso', ['idealista.com/piso']),
    ('leaves out a word after an ellipsis that is not an address', 'el finde...osea no', []),
    ('starts an address with a scheme after punctuation', '_http://foo.com/bar_', ['http://foo.com/bar']),

    // Paths.
    ('keeps brackets that open and close in a path', 'http://foo.com/path_[a]-{b}', ['http://foo.com/path_[a]-{b}']),
    ('ends a path at a closing bracket that closes nothing', '(http://foo.com/bar)more', ['http://foo.com/bar']),
    ('keeps symbols, emoji and other scripts in a path', r'http://foo.com/a0/$€¥🐼–', [r'http://foo.com/a0/$€¥🐼–']),
    (
      'keeps text in a script written without spaces in a path',
      'https://example.me/tmp/自殺でも？.png',
      ['https://example.me/tmp/自殺でも？.png'],
    ),
    ('ends a path at a character that cannot be in an address', 'http://foo.bar/path|more', ['http://foo.bar/path']),
    ('leaves out an at sign ending a path', 'http://foo.bar/path@', ['http://foo.bar/path']),
    ('finds an IPv6 host after a scheme', 'http://[2001:db8::1]:8080/x', ['http://[2001:db8::1]:8080/x']),
  ];

  for (final (description, text, links) in cases) {
    test('findLinks $description', () {
      expect(_linkTexts(text), links);
    });
  }

  test('findLinks opens an address without a scheme over https', () {
    final link = findLinks('Docs at getstream.io/chat').single;

    expect(link.url, 'https://getstream.io/chat');
  });

  test('findLinks keeps the scheme of an address that has one', () {
    final link = findLinks('Docs at http://getstream.io/chat').single;

    expect(link.url, 'http://getstream.io/chat');
  });

  test('findLinks reports where each link is in the text', () {
    const text = 'See youtube.com and getstream.io.';

    expect(findLinks(text), [
      _linkMatch(text, 'youtube.com'),
      _linkMatch(text, 'getstream.io'),
    ]);
  });

  test('findLinks finds the links after a long run of labels in a script written without spaces', () {
    final text = '${'中a.' * 2000} youtube.com';

    expect(_linkTexts(text), ['youtube.com']);
  });

  test('findLinks finds nothing in empty text', () {
    expect(findLinks(''), isEmpty);
  });

  test('findLinkAt finds the link starting at the index', () {
    const text = 'See youtube.com';

    expect(findLinkAt(text, text.indexOf('youtube.com')), _linkMatch(text, 'youtube.com'));
  });

  test('findLinkAt finds nothing in the middle of a word', () {
    const text = 'See youtube.com';

    expect(findLinkAt(text, text.indexOf('tube.com')), isNull);
  });

  test('findLinkAt finds nothing at the end of the text', () {
    const text = 'youtube.com';

    expect(findLinkAt(text, text.length), isNull);
  });

  test('findLinkAt throws for an index past the end of the text', () {
    const text = 'youtube.com';

    expect(() => findLinkAt(text, text.length + 1), throwsRangeError);
  });

  test('findLinkAt throws for a negative index', () {
    expect(() => findLinkAt('youtube.com', -1), throwsRangeError);
  });
}

List<String> _linkTexts(String text) => [for (final link in findLinks(text)) link.text];

// The link to [link] where it first appears in [text], opened over https.
LinkMatch _linkMatch(String text, String link) {
  final start = text.indexOf(link);
  return LinkMatch(start: start, end: start + link.length, text: link, url: 'https://$link');
}
