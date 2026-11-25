import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_thumbnail/src/messages.g.dart';
import 'package:stream_thumbnail/src/stream_thumbnail.dart';
import 'package:stream_thumbnail/src/stream_thumbnail_format.dart';
import 'package:stream_thumbnail/src/stream_thumbnail_method_channel.dart';
import 'package:stream_thumbnail/src/stream_thumbnail_platform.dart';
import 'package:stream_thumbnail/src/stream_thumbnail_source.dart';

/// A fake platform that records the last call it received and returns canned
/// results. Extending [StreamThumbnailPlatform] inherits its token, so it
/// can be installed as the active instance without the mock mixin.
class FakeStreamThumbnailPlatform extends StreamThumbnailPlatform {
  final _data = Uint8List.fromList([1, 2, 3]);
  final _file = XFile('/thumb.png');
  var _filesCalled = false;

  /// The canned bytes returned by [thumbnailData].
  Uint8List get data => _data;

  /// The canned file returned by [thumbnailFile].
  XFile get file => _file;

  /// Whether [thumbnailFiles] was invoked.
  bool get filesCalled => _filesCalled;

  /// The arguments captured from the most recent [thumbnailData] call.
  Map<String, Object?>? lastDataCall;

  /// The arguments captured from the most recent [thumbnailFile] call.
  Map<String, Object?>? lastFileCall;

  /// The arguments captured from the most recent [thumbnailFiles] call.
  Map<String, Object?>? lastFilesCall;

  @override
  Future<Uint8List> thumbnailData({
    required StreamThumbnailSource source,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    lastDataCall = {
      'source': source,
      'imageFormat': imageFormat,
      'maxHeight': maxHeight,
      'maxWidth': maxWidth,
      'timeMs': timeMs,
      'quality': quality,
    };
    return _data;
  }

  @override
  Future<XFile> thumbnailFile({
    required StreamThumbnailSource source,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    lastFileCall = {
      'source': source,
      'imageFormat': imageFormat,
    };
    return _file;
  }

  @override
  Future<List<XFile>> thumbnailFiles({
    required List<StreamThumbnailSource> sources,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    _filesCalled = true;
    lastFilesCall = {
      'sources': sources,
      'imageFormat': imageFormat,
    };
    return [];
  }
}

/// Installs a fake platform as the active instance and restores the original
/// when the test finishes.
FakeStreamThumbnailPlatform useFakePlatform() {
  final original = StreamThumbnailPlatform.instance;
  final fake = FakeStreamThumbnailPlatform();
  StreamThumbnailPlatform.instance = fake;
  addTearDown(() => StreamThumbnailPlatform.instance = original);
  return fake;
}

/// A mock of the Pigeon-generated host API, used to test
/// [MethodChannelStreamThumbnail] without a real platform channel.
class MockStreamThumbnailHostApi extends Mock implements StreamThumbnailHostApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      ThumbnailRequest(
        video: '',
        sourceKind: ThumbnailSourceKind.file,
        format: ThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        timeMs: 0,
        quality: 0,
      ),
    );
  });

  group('StreamThumbnail', () {
    final video = StreamThumbnailSource.file('/videos/a.mp4');

    test('thumbnailData forwards to the platform and returns its bytes', () async {
      final fake = useFakePlatform();

      final result = await StreamThumbnail.thumbnailData(source: video);

      expect(result, same(fake.data));
    });

    test('thumbnailData applies the documented default options', () async {
      final fake = useFakePlatform();

      await StreamThumbnail.thumbnailData(source: video);

      expect(fake.lastDataCall, {
        'source': video,
        'imageFormat': StreamThumbnailFormat.png,
        'maxHeight': 0,
        'maxWidth': 0,
        'timeMs': null,
        'quality': 10,
      });
    });

    test('thumbnailFile forwards to the platform and returns its file', () async {
      final fake = useFakePlatform();

      final result = await StreamThumbnail.thumbnailFile(source: video);

      expect(result, same(fake.file));
      expect(fake.lastFileCall?['source'], video);
    });

    test('thumbnailFiles returns an empty list without hitting the platform for no sources', () async {
      final fake = useFakePlatform();

      final result = await StreamThumbnail.thumbnailFiles(sources: []);

      expect(result, isEmpty);
      expect(fake.filesCalled, isFalse);
    });

    test('thumbnailFiles forwards every source to the platform', () async {
      final fake = useFakePlatform();
      final other = StreamThumbnailSource.network(Uri.parse('https://cdn.example.com/b.mp4'));

      await StreamThumbnail.thumbnailFiles(
        sources: [video, other],
        imageFormat: StreamThumbnailFormat.webp,
      );

      expect(fake.lastFilesCall, {
        'sources': [video, other],
        'imageFormat': StreamThumbnailFormat.webp,
      });
    });
  });

  group('StreamThumbnail with an unsupported source', () {
    final unsupported = [
      StreamThumbnailSource.network(Uri.parse('file:///videos/a.mp4')),
      StreamThumbnailSource.network(Uri.parse('ftp://example.com/a.mp4')),
      StreamThumbnailSource.network(Uri.parse('https:/a.mp4')),
      StreamThumbnailSource.contentUri(Uri.parse('file:///videos/a.mp4')),
      StreamThumbnailSource.file('https://cdn.example.com/a.mp4'),
      StreamThumbnailSource.file('//example.com/share/a.mp4'),
    ];
    final isUnsupported = throwsA(isA<PlatformException>().having((e) => e.code, 'code', 'UNSUPPORTED_SOURCE'));

    test('thumbnailData fails without reaching the platform', () async {
      for (final source in unsupported) {
        final fake = useFakePlatform();

        await expectLater(StreamThumbnail.thumbnailData(source: source), isUnsupported, reason: '$source');
        expect(fake.lastDataCall, isNull, reason: '$source');
      }
    });

    test('thumbnailFile fails without reaching the platform', () async {
      final fake = useFakePlatform();

      await expectLater(StreamThumbnail.thumbnailFile(source: unsupported.first), isUnsupported);
      expect(fake.lastFileCall, isNull);
    });

    test('thumbnailFiles fails without reaching the platform if any source is unsupported', () async {
      final fake = useFakePlatform();

      await expectLater(
        StreamThumbnail.thumbnailFiles(sources: [StreamThumbnailSource.file('/videos/a.mp4'), unsupported.first]),
        isUnsupported,
      );
      expect(fake.filesCalled, isFalse);
    });

    test('http and https URLs with a host are accepted', () async {
      for (final url in ['http://cdn.example.com/a.mp4', 'HTTPS://cdn.example.com/a.mp4']) {
        final fake = useFakePlatform();

        await StreamThumbnail.thumbnailData(source: StreamThumbnailSource.network(Uri.parse(url)));
        expect(fake.lastDataCall, isNotNull, reason: url);
      }
    });

    test('local paths, file URIs and object URLs are accepted as files', () async {
      for (final path in [
        '/videos/a.mp4',
        'file:///videos/a.mp4',
        r'C:\videos\a.mp4',
        'C:/videos/a.mp4',
        'blob:https://example.com/0f8e',
      ]) {
        final fake = useFakePlatform();

        await StreamThumbnail.thumbnailData(source: StreamThumbnailSource.file(path));
        expect(fake.lastDataCall, isNotNull, reason: path);
      }
    });
  });

  group('MethodChannelStreamThumbnail', () {
    late MockStreamThumbnailHostApi hostApi;
    late MethodChannelStreamThumbnail channel;

    setUp(() {
      hostApi = MockStreamThumbnailHostApi();
      channel = MethodChannelStreamThumbnail(hostApi: hostApi);
    });

    test('thumbnailData sends the encoded request and returns the bytes', () async {
      final data = Uint8List.fromList([9, 8, 7]);
      when(() => hostApi.thumbnailData(any())).thenAnswer((_) async => data);

      final result = await channel.thumbnailData(
        source: StreamThumbnailSource.file('a.mp4'),
        imageFormat: StreamThumbnailFormat.webp,
        maxHeight: 10,
        maxWidth: 20,
        timeMs: 500,
        quality: 80,
      );

      expect(result, data);
      final request = verify(() => hostApi.thumbnailData(captureAny())).captured.single as ThumbnailRequest;
      expect(request.video, 'a.mp4');
      expect(request.sourceKind, ThumbnailSourceKind.file);
      expect(request.format, ThumbnailFormat.webp);
      expect(request.maxHeight, 10);
      expect(request.maxWidth, 20);
      expect(request.timeMs, 500);
      expect(request.quality, 80);
    });

    test('thumbnailFile wraps the returned path in an XFile', () async {
      when(() => hostApi.thumbnailFile(any())).thenAnswer((_) async => '/tmp/thumb.png');

      final result = await channel.thumbnailFile(
        source: StreamThumbnailSource.file('a.mp4'),
        imageFormat: StreamThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        quality: 10,
      );

      expect(result.path, '/tmp/thumb.png');
    });

    test('thumbnailData rethrows a PlatformException from the native side', () async {
      when(() => hostApi.thumbnailData(any())).thenAnswer(
        (_) async => throw PlatformException(code: 'THUMBNAIL_ERROR', message: 'native error'),
      );

      await expectLater(
        channel.thumbnailData(
          source: StreamThumbnailSource.file('a.mp4'),
          imageFormat: StreamThumbnailFormat.png,
          maxHeight: 0,
          maxWidth: 0,
          quality: 10,
        ),
        throwsA(isA<PlatformException>().having((e) => e.code, 'code', 'THUMBNAIL_ERROR')),
      );
    });

    test('thumbnailFiles invokes the host API once per video and returns their XFiles in order', () async {
      final paths = ['/a.png', '/b.png', '/c.png'];
      var index = 0;
      when(() => hostApi.thumbnailFile(any())).thenAnswer((_) async => paths[index++]);

      final result = await channel.thumbnailFiles(
        sources: [
          for (final v in ['a.mp4', 'b.mp4', 'c.mp4']) StreamThumbnailSource.file(v),
        ],
        imageFormat: StreamThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        quality: 10,
      );

      verify(() => hostApi.thumbnailFile(any())).called(3);
      expect(result.map((file) => file.path), paths);
    });

    test('thumbnailFiles stops at the first failing video instead of skipping it', () async {
      var callCount = 0;
      when(() => hostApi.thumbnailFile(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 2) {
          throw PlatformException(code: 'THUMBNAIL_ERROR', message: 'boom');
        }
        return '/ok.png';
      });

      await expectLater(
        channel.thumbnailFiles(
          sources: [
            for (final v in ['a.mp4', 'b.mp4', 'c.mp4']) StreamThumbnailSource.file(v),
          ],
          imageFormat: StreamThumbnailFormat.png,
          maxHeight: 0,
          maxWidth: 0,
          quality: 10,
        ),
        throwsA(isA<PlatformException>()),
      );
      expect(callCount, 2);
    });

    test('thumbnailFiles decodes one video at a time', () async {
      final pending = <Completer<String>>[];
      when(() => hostApi.thumbnailFile(any())).thenAnswer((_) {
        final completer = Completer<String>();
        pending.add(completer);
        return completer.future;
      });

      final result = channel.thumbnailFiles(
        sources: [
          for (final v in ['a.mp4', 'b.mp4', 'c.mp4']) StreamThumbnailSource.file(v),
        ],
        imageFormat: StreamThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        quality: 10,
      );

      // Only the first request is in flight: the batch must not fan out and
      // leave the platform juggling every decode at once.
      await pumpEventQueue();
      expect(pending, hasLength(1));

      pending[0].complete('/a.png');
      await pumpEventQueue();
      expect(pending, hasLength(2));

      pending[1].complete('/b.png');
      await pumpEventQueue();
      expect(pending, hasLength(3));

      pending[2].complete('/c.png');
      expect((await result).map((file) => file.path), ['/a.png', '/b.png', '/c.png']);
    });

    test('a network source is sent as network with its URL and headers', () async {
      when(() => hostApi.thumbnailData(any())).thenAnswer((_) async => Uint8List(0));

      await channel.thumbnailData(
        source: StreamThumbnailSource.network(
          Uri.parse('https://cdn.example.com/a.mp4?w=640'),
          headers: const {'X-Client': 'example'},
        ),
        imageFormat: StreamThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        quality: 10,
      );

      final request = verify(() => hostApi.thumbnailData(captureAny())).captured.single as ThumbnailRequest;
      expect(request.sourceKind, ThumbnailSourceKind.network);
      expect(request.video, 'https://cdn.example.com/a.mp4?w=640');
      expect(request.headers, const {'X-Client': 'example'});
    });

    test('a file source is sent as file with its path', () async {
      when(() => hostApi.thumbnailData(any())).thenAnswer((_) async => Uint8List(0));

      await channel.thumbnailData(
        source: StreamThumbnailSource.file('/videos/a.mp4'),
        imageFormat: StreamThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        quality: 10,
      );

      final request = verify(() => hostApi.thumbnailData(captureAny())).captured.single as ThumbnailRequest;
      expect(request.sourceKind, ThumbnailSourceKind.file);
      expect(request.video, '/videos/a.mp4');
      expect(request.headers, isNull);
    });

    test('a content URI source is sent as contentUri with its URI', () async {
      when(() => hostApi.thumbnailData(any())).thenAnswer((_) async => Uint8List(0));

      await channel.thumbnailData(
        source: StreamThumbnailSource.contentUri(Uri.parse('content://media/1')),
        imageFormat: StreamThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        quality: 10,
      );

      final request = verify(() => hostApi.thumbnailData(captureAny())).captured.single as ThumbnailRequest;
      expect(request.sourceKind, ThumbnailSourceKind.contentUri);
      expect(request.video, 'content://media/1');
      expect(request.headers, isNull);
    });

    test('a null timeMs is sent as -1 on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      when(() => hostApi.thumbnailData(any())).thenAnswer((_) async => Uint8List(0));

      await channel.thumbnailData(
        source: StreamThumbnailSource.file('a.mp4'),
        imageFormat: StreamThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        quality: 10,
      );

      final request = verify(() => hostApi.thumbnailData(captureAny())).captured.single as ThumbnailRequest;
      expect(request.timeMs, -1);
    });

    test('a null timeMs is sent as 0 on non-Android platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      when(() => hostApi.thumbnailData(any())).thenAnswer((_) async => Uint8List(0));

      await channel.thumbnailData(
        source: StreamThumbnailSource.file('a.mp4'),
        imageFormat: StreamThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        quality: 10,
      );

      final request = verify(() => hostApi.thumbnailData(captureAny())).captured.single as ThumbnailRequest;
      expect(request.timeMs, 0);
    });
  });
}
