import 'package:equatable/equatable.dart';

part 'link_finder.tlds.g.dart';

/// A web link found in text by [findLinks] or [findLinkAt].
class LinkMatch extends Equatable {
  /// Creates a [LinkMatch] spanning [start] to [end] in the searched text.
  const LinkMatch({
    required this.start,
    required this.end,
    required this.text,
    required this.url,
  });

  /// The index of the first character of the link in the searched text.
  final int start;

  /// The index just past the last character of the link in the searched text.
  final int end;

  /// The link as it is written in the text, such as `example.com/docs`.
  final String text;

  /// The address to open for the link.
  ///
  /// The link's own text when it has a scheme. A link written without one,
  /// such as `example.com`, opens over `https://`.
  ///
  /// The address is not percent-encoded, so a caller parsing it into a [Uri]
  /// decides how to encode it.
  final String url;

  @override
  List<Object?> get props => [start, end, text, url];

  @override
  String toString() => 'LinkMatch($start, $end, $text, $url)';
}

/// Finds the web links in [text], in the order they appear.
///
/// A link is an address with an `http://` or `https://` scheme, or a domain
/// written without one, such as `example.com`, `www.example.com/path` or
/// `docs.example.co.uk:8080/a?b=c`. An address without a scheme counts only
/// when it ends in a top-level domain from the IANA root zone, so most file
/// names, such as `config.json`, are not links. A file name whose extension is
/// also a top-level domain, such as `README.md`, is.
///
/// Email addresses, and punctuation that ends the sentence around a link, are
/// left out.
///
/// ```dart
/// final links = findLinks('Docs at example.com/docs, or mail me@x.io.');
/// print(links.single.url); // https://example.com/docs
/// ```
List<LinkMatch> findLinks(String text) {
  final links = <LinkMatch>[];
  var index = 0;
  while (index < text.length) {
    final link = _findLinkAt(text, index);
    if (link == null) {
      index += 1;
      continue;
    }

    links.add(link);
    index = link.end;
  }

  return links;
}

/// The web link starting at [start] in [text], or null if none starts there.
///
/// Finds the same links as [findLinks], but only one starting exactly at
/// [start]. A link starts a word, so a position in the middle of a word or an
/// email address finds nothing.
///
/// A [start] at the end of [text] finds nothing. Throws a [RangeError] if
/// [start] is negative or past the end of [text].
LinkMatch? findLinkAt(String text, int start) {
  RangeError.checkValueInInterval(start, 0, text.length, 'start');
  if (start == text.length) return null;

  return _findLinkAt(text, start);
}

LinkMatch? _findLinkAt(String text, int start) {
  final codeUnit = text.codeUnitAt(start);
  final mayHaveScheme = codeUnit == _kLowercaseH || codeUnit == _kUppercaseH;
  final hasScheme = mayHaveScheme && _scheme.matchAsPrefix(text, start) != null;
  if (hasScheme && !_startsSchemeLink(text, start)) return null;
  if (!hasScheme && !_startsWord(text, start)) return null;

  final end = hasScheme ? _matchWithScheme(text, start) : _matchWithoutScheme(text, start);
  if (end == null) return null;

  final linkEnd = _trimTrailingPunctuation(text, start, end);

  // An address can be the start of an email address, as in `anna.li@gmail.com`.
  if (_continuesAsEmailAddress(text, linkEnd)) return null;

  final link = text.substring(start, linkEnd);
  final url = hasScheme ? link : 'https://$link';
  return LinkMatch(start: start, end: linkEnd, text: link, url: url);
}

const _kAt = 0x40;
const _kHyphen = 0x2D;
const _kUnderscore = 0x5F;
const _kDot = 0x2E;
const _kLowercaseH = 0x68;
const _kUppercaseH = 0x48;
const _kFirstNonAscii = 0x80;

// The longest host name DNS allows, in characters.
const _kMaxHostLength = 253;

// A domain label of up to 63 letters, marks, digits, hyphens and underscores,
// starting with a letter or digit and ending with a letter, mark or digit.
const _kLabelPattern = r'[\p{L}\p{N}](?:[\p{L}\p{M}\p{N}_\-]{0,61}[\p{L}\p{M}\p{N}])?';
const _kAsciiLabelPattern = r'[a-zA-Z0-9](?:[a-zA-Z0-9_\-]{0,61}[a-zA-Z0-9])?';
const _kOctetPattern = r'(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)';

final _scheme = RegExp('https?://', caseSensitive: false);
final _userInfo = RegExp(r'[^\s/?#@\[\]]+@');
final _labels = RegExp('$_kLabelPattern(?:\\.$_kLabelPattern)*', unicode: true);
final _asciiLabels = RegExp('$_kAsciiLabelPattern(?:\\.$_kAsciiLabelPattern)*');
final _ipAddress = RegExp('$_kOctetPattern(?:\\.$_kOctetPattern){3}');
final _port = RegExp(r':\d{1,5}');
final _ipv6Address = RegExp(r'\[[0-9a-fA-F:.]+\]');
final _wordCharacter = RegExp(r'[\p{L}\p{M}\p{N}_]', unicode: true);
final _noSpaceScript = RegExp(
  r'[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Thai}'
  r'\p{Script=Lao}\p{Script=Khmer}\p{Script=Myanmar}]',
  unicode: true,
);

// Characters that can't come right before a link, as they would make the link
// the tail of a word, an address or another link.
const _kInvalidPrecedingCodeUnits = {
  0x40, // @
  0x2E, // .
  0x2D, // -
  0x5F, // _
  0x2F, // /
  0x3A, // :
  0x23, // #
  0x25, // %
  0x26, // &
  0x3D, // =
  0x2B, // +
  0x5C, // \
};

// Punctuation that ends the sentence around a link rather than the link.
const _kTrailingPunctuationCodeUnits = {
  0x3F, // ?
  0x21, // !
  0x2E, // .
  0x2C, // ,
  0x3A, // :
  0x3B, // ;
  0x2A, // *
  0x5F, // _
  0x7E, // ~
  0x27, // '
  0x22, // "
  0x40, // @
  0x2019, // ’
  0x201D, // ”
  0x00BB, // »
};

// Characters a path, query or fragment starts with: / ? #.
const _kPathStarts = {0x2F, 0x3F, 0x23};

// Characters that can't be in an address: < > " ` |.
const _kPathTerminators = {0x3C, 0x3E, 0x22, 0x60, 0x7C};

// Symbols an email address can have before its `@`: . _ % + -.
const _kEmailLocalPartSymbols = {0x2E, 0x5F, 0x25, 0x2B, 0x2D};

// Opening brackets in a path, mapped to the bracket that closes each: ( [ {.
const _kClosingBracketFor = {0x28: 0x29, 0x5B: 0x5D, 0x7B: 0x7D};

// Closing brackets in a path: ) ] }.
const _kClosingBrackets = {0x29, 0x5D, 0x7D};

bool _startsWord(String text, int start) {
  final codeUnit = text.codeUnitAt(start);
  if (codeUnit == _kUnderscore || _isLowSurrogate(codeUnit)) return false;
  if (!_isWordCharacterAt(text, start)) return false;
  if (start == 0) return true;

  final previousStart = _previousCharacterStart(text, start);
  final previous = text.codeUnitAt(previousStart);
  final isInvalidPreceding = _kInvalidPrecedingCodeUnits.contains(previous);
  if (isInvalidPreceding && !_followsEllipsis(text, start)) return false;
  if (!_isWordCharacterAt(text, previousStart)) return true;

  // Scripts written without spaces run words together, so a link may follow
  // one directly: in `请访问google.com`, the link starts at `google.com`.
  return _isAsciiAlphanumeric(codeUnit) && _isNoSpaceScriptAt(text, previousStart);
}

// Whether the `.` right before [start] ends an ellipsis, as in
// `see...example.com`.
bool _followsEllipsis(String text, int start) {
  if (start < 2) return false;
  return text.codeUnitAt(start - 1) == _kDot && text.codeUnitAt(start - 2) == _kDot;
}

// An address with a scheme is a link wherever it doesn't continue a word, as in
// `(https://example.com)` or `_https://example.com_`.
bool _startsSchemeLink(String text, int start) {
  if (start == 0) return true;

  final previousStart = _previousCharacterStart(text, start);
  if (text.codeUnitAt(previousStart) == _kUnderscore) return true;
  return !_isWordCharacterAt(text, previousStart);
}

// The end of the `http://` or `https://` address starting at [start], or null.
int? _matchWithScheme(String text, int start) {
  final scheme = _scheme.matchAsPrefix(text, start)!;
  final hostStart = _userInfo.matchAsPrefix(text, scheme.end)?.end ?? scheme.end;
  final ipv6End = _ipv6Address.matchAsPrefix(text, hostStart)?.end;
  final hostEnd = ipv6End ?? _matchLabelsEnd(_labels, text, hostStart);
  if (hostEnd == null) return null;

  return _matchPortAndPath(text, hostEnd);
}

// The end of the address without a scheme starting at [start], or null.
int? _matchWithoutScheme(String text, int start) {
  // A link that runs on from a script written without spaces, as in
  // `请访问google.com`, has an ASCII host, so the text in that script after
  // it is not read as more of the host.
  final previousStart = start > 0 ? _previousCharacterStart(text, start) : -1;
  final runsOn = previousStart >= 0 && _isWordCharacterAt(text, previousStart);
  final labelsPattern = runsOn ? _asciiLabels : _labels;
  final labelsEnd = _matchLabelsEnd(labelsPattern, text, start);
  if (labelsEnd == null) return null;

  final ipEnd = _ipAddress.matchAsPrefix(text, start)?.end;
  if (ipEnd == labelsEnd) return _matchPortAndPath(text, labelsEnd);

  final host = text.substring(start, labelsEnd);
  if (_runsOnFromNoSpaceScript(host)) return null;

  final parts = host.split('.');
  var partEnd = labelsEnd;
  for (var count = parts.length; count >= 2; count--) {
    final topLevelDomain = parts[count - 1];
    final partStart = partEnd - topLevelDomain.length;
    for (final length in _topLevelDomainLengths(topLevelDomain)) {
      final end = _matchPortAndPath(text, partStart + length);
      if (end != null) return end;
    }
    partEnd = partStart - 1;
  }

  return null;
}

// The end of the dot-separated [labels] of a host starting at [start], or null
// when there are none or they are longer than a host name can be.
int? _matchLabelsEnd(RegExp labels, String text, int start) {
  final end = labels.matchAsPrefix(text, start)?.end;
  if (end == null || end - start > _kMaxHostLength) return null;

  return end;
}

// The lengths at which [label] can end in a known top-level domain, longest
// first: the whole label, or the part before a hyphen or before text in a
// script written without spaces, as in `google.com了解更多`.
Iterable<int> _topLevelDomainLengths(String label) sync* {
  for (var length = label.length; length >= 2; length--) {
    if (length < label.length && !_isLabelBreak(label, length)) continue;
    if (_isTopLevelDomain(label.substring(0, length))) yield length;
  }
}

bool _isLabelBreak(String label, int index) {
  return label.codeUnitAt(index) == _kHyphen || _runsIntoNoSpaceScript(label, index);
}

bool _isTopLevelDomain(String label) => _kIanaTopLevelDomains.contains(label.toLowerCase());

// Whether the first label of [host] runs on from a script written without
// spaces into ASCII, as in `请访问google.com`. The link then starts later,
// at the ASCII part.
bool _runsOnFromNoSpaceScript(String host) {
  final dot = host.indexOf('.');
  final firstLabel = dot == -1 ? host : host.substring(0, dot);
  final codeUnits = firstLabel.codeUnits;
  if (codeUnits.every((codeUnit) => codeUnit < _kFirstNonAscii)) return false;

  return codeUnits.any(_isAsciiAlphanumeric) && _noSpaceScript.hasMatch(firstLabel);
}

// Whether ASCII before [index] runs straight into a script written without
// spaces at [index].
bool _runsIntoNoSpaceScript(String text, int index) {
  return _isAsciiAlphanumeric(text.codeUnitAt(index - 1)) && _isNoSpaceScriptAt(text, index);
}

// The end of the address with its optional port and path after a host ending
// at [hostEnd], or null when the host does not end a word.
int? _matchPortAndPath(String text, int hostEnd) {
  final portEnd = _port.matchAsPrefix(text, hostEnd)?.end;
  if (portEnd != null && !_endsWord(text, portEnd)) return hostEnd;
  if (portEnd == null && !_endsWord(text, hostEnd)) return null;

  return _matchPath(text, portEnd ?? hostEnd);
}

// The end of the path, query or fragment starting at [start], or [start] when
// there is none.
//
// It runs to whitespace or a character that can't be in an address, and stops
// at a closing bracket that closes nothing in it, as in `(see example.com/a)`.
int _matchPath(String text, int start) {
  if (start >= text.length || !_kPathStarts.contains(text.codeUnitAt(start))) return start;

  final expectedClosers = <int>[];
  var index = start;
  while (index < text.length) {
    final codeUnit = text.codeUnitAt(index);
    if (_isWhitespace(codeUnit) || _kPathTerminators.contains(codeUnit)) break;

    if (_kClosingBracketFor[codeUnit] case final closer?) {
      expectedClosers.add(closer);
    } else if (_kClosingBrackets.contains(codeUnit)) {
      if (expectedClosers.isEmpty || expectedClosers.last != codeUnit) break;
      expectedClosers.removeLast();
    }
    index += 1;
  }

  return index;
}

// Whether the text from [index] runs on to the `@` of an email address, as the
// `+tag@gmail.com` of `anna.li+tag@gmail.com` does.
bool _continuesAsEmailAddress(String text, int index) {
  var atIndex = index;
  while (atIndex < text.length && _isEmailLocalPartCodeUnit(text.codeUnitAt(atIndex))) {
    atIndex += 1;
  }

  if (atIndex + 1 >= text.length || text.codeUnitAt(atIndex) != _kAt) return false;
  return _isWordCharacterAt(text, atIndex + 1);
}

bool _isEmailLocalPartCodeUnit(int codeUnit) {
  return _isAsciiAlphanumeric(codeUnit) || _kEmailLocalPartSymbols.contains(codeUnit);
}

bool _endsWord(String text, int end) {
  if (end >= text.length) return true;
  return !_isWordCharacterAt(text, end) || _runsIntoNoSpaceScript(text, end);
}

// The end of the link from [start] to [end] once the punctuation that ends the
// sentence around it is left out.
int _trimTrailingPunctuation(String text, int start, int end) {
  var trimmedEnd = end;
  while (trimmedEnd > start) {
    final last = text.codeUnitAt(trimmedEnd - 1);
    if (!_kTrailingPunctuationCodeUnits.contains(last)) break;
    trimmedEnd -= 1;
  }

  return trimmedEnd;
}

// Whether [codeUnit] is a control character, a space or a Unicode White_Space
// character.
bool _isWhitespace(int codeUnit) {
  return codeUnit <= 0x20 ||
      codeUnit == 0x85 ||
      codeUnit == 0xA0 ||
      codeUnit == 0x1680 ||
      (codeUnit >= 0x2000 && codeUnit <= 0x200A) ||
      codeUnit == 0x2028 ||
      codeUnit == 0x2029 ||
      codeUnit == 0x202F ||
      codeUnit == 0x205F ||
      codeUnit == 0x3000 ||
      codeUnit == 0xFEFF;
}

bool _isAsciiAlphanumeric(int codeUnit) {
  return (codeUnit >= 0x30 && codeUnit <= 0x39) ||
      (codeUnit >= 0x41 && codeUnit <= 0x5A) ||
      (codeUnit >= 0x61 && codeUnit <= 0x7A);
}

bool _isWordCharacterAt(String text, int index) {
  final codeUnit = text.codeUnitAt(index);
  if (codeUnit >= _kFirstNonAscii) return _wordCharacter.matchAsPrefix(text, index) != null;
  return _isAsciiAlphanumeric(codeUnit) || codeUnit == _kUnderscore;
}

bool _isNoSpaceScriptAt(String text, int index) {
  if (text.codeUnitAt(index) < _kFirstNonAscii) return false;
  return _noSpaceScript.matchAsPrefix(text, index) != null;
}

// The index of the character that ends right before [index].
int _previousCharacterStart(String text, int index) {
  final isLowSurrogate = _isLowSurrogate(text.codeUnitAt(index - 1));
  if (!isLowSurrogate || index < 2) return index - 1;
  return _isHighSurrogate(text.codeUnitAt(index - 2)) ? index - 2 : index - 1;
}

bool _isHighSurrogate(int codeUnit) => codeUnit >= 0xD800 && codeUnit <= 0xDBFF;

bool _isLowSurrogate(int codeUnit) => codeUnit >= 0xDC00 && codeUnit <= 0xDFFF;
