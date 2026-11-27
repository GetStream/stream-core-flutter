import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'stream_thumbnail_source.dart';

const _maxRedirects = 5;
const _timeout = Duration(seconds: 30);
const _credentialHeaders = {'authorization', 'cookie', 'proxy-authorization'};

/// Follows the redirects of a network [source] sent with headers, and returns
/// a source for the URL they end at.
///
/// Credential headers are dropped once a redirect leaves the scheme, host and
/// port of the URL before it, so they never reach another server. Sources
/// without headers are returned unchanged, and so is every source on Windows,
/// which never sends headers.
Future<StreamThumbnailSource> resolveRedirects(StreamThumbnailSource source) async {
  final headers = source.headers;
  if (Platform.isWindows) return source;
  if (source.kind != StreamThumbnailSourceKind.network || headers == null || headers.isEmpty) return source;

  final client = HttpClient()..connectionTimeout = _timeout;
  try {
    final url = Uri.parse(source.location);
    final (resolved, resolvedHeaders) = await _follow(client, url, headers).timeout(_timeout);
    if (resolved == url) return source;

    return StreamThumbnailSource.network(resolved, headers: resolvedHeaders);
  } on PlatformException {
    rethrow;
  } on Exception {
    throw PlatformException(code: 'THUMBNAIL_ERROR', message: 'Failed to fetch the video.');
  } finally {
    client.close(force: true);
  }
}

Future<(Uri, Map<String, String>)> _follow(HttpClient client, Uri url, Map<String, String> headers) async {
  var current = url;
  var currentHeaders = headers;

  for (var redirects = 0; ; redirects++) {
    final request = await client.getUrl(current);
    request.followRedirects = false;
    currentHeaders.forEach(request.headers.set);
    request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-0');

    final response = await request.close();
    await response.listen(null).cancel();

    final location = response.headers.value(HttpHeaders.locationHeader);
    if (!response.isRedirect || location == null) break;
    if (redirects == _maxRedirects) {
      throw PlatformException(code: 'THUMBNAIL_ERROR', message: 'The video redirected too many times.');
    }

    final next = current.resolve(location);
    if (!next.isScheme('http') && !next.isScheme('https')) {
      throw PlatformException(code: 'UNSUPPORTED_SOURCE', message: 'A network video must be an http or https URL.');
    }
    if (!_isSameOrigin(current, next)) {
      currentHeaders = {
        for (final MapEntry(:key, :value) in currentHeaders.entries)
          if (!_credentialHeaders.contains(key.toLowerCase())) key: value,
      };
    }
    current = next;
  }

  return (current, currentHeaders);
}

bool _isSameOrigin(Uri a, Uri b) => a.scheme == b.scheme && a.host == b.host && a.port == b.port;
