import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stream_thumbnail/stream_thumbnail.dart';

typedef _Received = ({String? authorization, String? client});

/// A server that answers `/redirect` with a redirect to [location], and
/// anything else with the sample video, recording the headers of each request.
Future<(HttpServer, List<_Received>)> _videoServer(Uint8List video, {String Function()? location}) async {
  final received = <_Received>[];
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    final response = request.response;
    if (request.uri.path == '/redirect' && location != null) {
      response
        ..statusCode = HttpStatus.found
        ..headers.set(HttpHeaders.locationHeader, location());
      return response.close();
    }

    received.add((
      authorization: request.headers.value(HttpHeaders.authorizationHeader),
      client: request.headers.value('x-client'),
    ));
    response.headers
      ..contentType = ContentType('video', 'mp4')
      ..set(HttpHeaders.acceptRangesHeader, 'bytes');
    final range = RegExp(r'bytes=(\d+)-(\d*)').firstMatch(request.headers.value(HttpHeaders.rangeHeader) ?? '');
    final start = range == null ? 0 : int.parse(range[1]!);
    final end = range == null || range[2]!.isEmpty ? video.length - 1 : int.parse(range[2]!).clamp(0, video.length - 1);
    if (range != null) {
      response
        ..statusCode = HttpStatus.partialContent
        ..headers.set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/${video.length}');
    }
    response
      ..contentLength = end - start + 1
      ..add(video.sublist(start, end + 1));
    await response.close();
  });
  addTearDown(() => server.close(force: true));
  return (server, received);
}

const _headers = {'Authorization': 'authorization-value', 'X-Client': 'client-value'};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Uint8List video;

  setUpAll(() async {
    final bytes = await rootBundle.load('assets/sample_video.mp4');
    video = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  });

  testWidgets('a redirect to another host is followed without the credential headers', (tester) async {
    final (other, receivedByOther) = await _videoServer(video);
    final (origin, _) = await _videoServer(video, location: () => 'http://localhost:${other.port}/a.mp4');

    final bytes = await StreamThumbnail.thumbnailData(
      source: StreamThumbnailSource.network(Uri.parse('http://127.0.0.1:${origin.port}/redirect'), headers: _headers),
    );

    expect(bytes, isNotEmpty);
    expect(receivedByOther, isNotEmpty);
    expect(receivedByOther, everyElement((authorization: null, client: 'client-value')));
  });

  testWidgets('a redirect within the same host keeps every header', (tester) async {
    late final HttpServer origin;
    final (server, received) = await _videoServer(video, location: () => 'http://127.0.0.1:${origin.port}/a.mp4');
    origin = server;

    final bytes = await StreamThumbnail.thumbnailData(
      source: StreamThumbnailSource.network(Uri.parse('http://127.0.0.1:${origin.port}/redirect'), headers: _headers),
    );

    expect(bytes, isNotEmpty);
    expect(received, isNotEmpty);
    expect(received, everyElement((authorization: 'authorization-value', client: 'client-value')));
  });
}
