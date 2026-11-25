import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_thumbnail/src/network_redirects.dart';
import 'package:stream_thumbnail/stream_thumbnail.dart';

typedef _Received = ({String path, String? authorization, String? cookie, String? client});

/// A server that redirects `/to/<url>` to `<url>`, answers everything else
/// with `200`, and records the headers of each request it receives.
Future<(HttpServer, List<_Received>)> _server() async {
  final received = <_Received>[];
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    received.add((
      path: request.uri.path,
      authorization: request.headers.value(HttpHeaders.authorizationHeader),
      cookie: request.headers.value(HttpHeaders.cookieHeader),
      client: request.headers.value('x-client'),
    ));
    if (request.uri.path.startsWith('/to/')) {
      request.response
        ..statusCode = HttpStatus.found
        ..headers.set(HttpHeaders.locationHeader, Uri.decodeComponent(request.uri.path.substring(4)));
    }
    await request.response.close();
  });
  addTearDown(() => server.close(force: true));
  return (server, received);
}

const _headers = {'Authorization': 'authorization-value', 'Cookie': 'cookie-value', 'X-Client': 'client-value'};

String _to(String url) => '/to/${Uri.encodeComponent(url)}';

void main() {
  test('returns a source without headers unchanged, without a request', () async {
    final (server, received) = await _server();
    final source = StreamThumbnailSource.network(Uri.parse('http://127.0.0.1:${server.port}/a.mp4'));

    expect(await resolveRedirects(source), same(source));
    expect(received, isEmpty);
  });

  test('returns a source that is not redirected unchanged', () async {
    final (server, _) = await _server();
    final source = StreamThumbnailSource.network(Uri.parse('http://127.0.0.1:${server.port}/a.mp4'), headers: _headers);

    expect(await resolveRedirects(source), same(source));
  });

  test('keeps every header on a redirect within the same host', () async {
    final (server, received) = await _server();
    final origin = 'http://127.0.0.1:${server.port}';

    final resolved = await resolveRedirects(
      StreamThumbnailSource.network(Uri.parse('$origin${_to('$origin/a.mp4')}'), headers: _headers),
    );

    expect(resolved, StreamThumbnailSource.network(Uri.parse('$origin/a.mp4'), headers: _headers));
    expect(received.last, (
      path: '/a.mp4',
      authorization: 'authorization-value',
      cookie: 'cookie-value',
      client: 'client-value',
    ));
  });

  test('drops the credential headers on a redirect to another host', () async {
    final (origin, _) = await _server();
    final (other, received) = await _server();
    final target = 'http://localhost:${other.port}/a.mp4';

    final resolved = await resolveRedirects(
      StreamThumbnailSource.network(
        Uri.parse('http://127.0.0.1:${origin.port}${_to(target)}'),
        headers: _headers,
      ),
    );

    expect(resolved, StreamThumbnailSource.network(Uri.parse(target), headers: const {'X-Client': 'client-value'}));
    expect(received.single, (path: '/a.mp4', authorization: null, cookie: null, client: 'client-value'));
  });

  test('drops the credential headers on a redirect to another port of the same host', () async {
    final (origin, _) = await _server();
    final (other, received) = await _server();
    final target = 'http://127.0.0.1:${other.port}/a.mp4';

    await resolveRedirects(
      StreamThumbnailSource.network(Uri.parse('http://127.0.0.1:${origin.port}${_to(target)}'), headers: _headers),
    );

    expect(received.single, (path: '/a.mp4', authorization: null, cookie: null, client: 'client-value'));
  });

  test('keeps the credential headers dropped when a later redirect comes back to the first host', () async {
    final (origin, received) = await _server();
    final (other, _) = await _server();
    final first = 'http://127.0.0.1:${origin.port}';
    final back = 'http://localhost:${other.port}${_to('$first/a.mp4')}';

    final resolved = await resolveRedirects(
      StreamThumbnailSource.network(Uri.parse('$first${_to(back)}'), headers: _headers),
    );

    expect(resolved.headers, const {'X-Client': 'client-value'});
    expect(received.last, (path: '/a.mp4', authorization: null, cookie: null, client: 'client-value'));
  });

  test('fails with UNSUPPORTED_SOURCE on a redirect to a URL that is not http or https', () async {
    final (server, _) = await _server();

    await expectLater(
      resolveRedirects(
        StreamThumbnailSource.network(
          Uri.parse('http://127.0.0.1:${server.port}${_to('file:///etc/hosts')}'),
          headers: _headers,
        ),
      ),
      throwsA(isA<PlatformException>().having((e) => e.code, 'code', 'UNSUPPORTED_SOURCE')),
    );
  });

  test('fails with THUMBNAIL_ERROR after too many redirects', () async {
    final (server, _) = await _server();
    final origin = 'http://127.0.0.1:${server.port}';
    var url = '$origin/a.mp4';
    for (var i = 0; i < 6; i++) {
      url = '$origin${_to(url)}';
    }

    await expectLater(
      resolveRedirects(StreamThumbnailSource.network(Uri.parse(url), headers: _headers)),
      throwsA(isA<PlatformException>().having((e) => e.code, 'code', 'THUMBNAIL_ERROR')),
    );
  });

  test('fails with THUMBNAIL_ERROR, without the URL, when the server cannot be reached', () async {
    final (server, _) = await _server();
    final url = 'http://127.0.0.1:${server.port}/a.mp4?token=token-value';
    await server.close(force: true);

    await expectLater(
      resolveRedirects(StreamThumbnailSource.network(Uri.parse(url), headers: _headers)),
      throwsA(
        isA<PlatformException>()
            .having((e) => e.code, 'code', 'THUMBNAIL_ERROR')
            .having((e) => e.message, 'message', isNot(contains('token-value'))),
      ),
    );
  });
}
