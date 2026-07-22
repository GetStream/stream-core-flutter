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

  @override
  Future<Uint8List> thumbnailData({
    required String video,
    required Map<String, String>? headers,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    lastDataCall = {
      'video': video,
      'headers': headers,
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
    required String video,
    required Map<String, String>? headers,
    required String? thumbnailPath,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    lastFileCall = {
      'video': video,
      'thumbnailPath': thumbnailPath,
      'imageFormat': imageFormat,
    };
    return _file;
  }

  @override
  Future<List<XFile>> thumbnailFiles({
    required List<String> videos,
    required Map<String, String>? headers,
    required String? thumbnailPath,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    _filesCalled = true;
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
        format: ThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        timeMs: 0,
        quality: 0,
      ),
    );
  });

  group('StreamThumbnail', () {
    test('thumbnailData forwards to the platform and returns its bytes', () async {
      final fake = useFakePlatform();

      final result = await StreamThumbnail.thumbnailData(video: 'a.mp4');

      expect(result, same(fake.data));
    });

    test('thumbnailData applies the documented default options', () async {
      final fake = useFakePlatform();

      await StreamThumbnail.thumbnailData(video: 'a.mp4');

      expect(fake.lastDataCall, {
        'video': 'a.mp4',
        'headers': null,
        'imageFormat': StreamThumbnailFormat.png,
        'maxHeight': 0,
        'maxWidth': 0,
        'timeMs': null,
        'quality': 10,
      });
    });

    test('thumbnailFile forwards to the platform and returns its file', () async {
      final fake = useFakePlatform();

      final result = await StreamThumbnail.thumbnailFile(video: 'a.mp4');

      expect(result, same(fake.file));
      expect(fake.lastFileCall?['video'], 'a.mp4');
    });

    test('thumbnailFiles returns an empty list without hitting the platform for no videos', () async {
      final fake = useFakePlatform();

      final result = await StreamThumbnail.thumbnailFiles(videos: []);

      expect(result, isEmpty);
      expect(fake.filesCalled, isFalse);
    });

    test('thumbnailData rejects an empty video path', () {
      useFakePlatform();

      expect(
        () => StreamThumbnail.thumbnailData(video: ''),
        throwsA(isA<AssertionError>()),
      );
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
        video: 'a.mp4',
        headers: null,
        imageFormat: StreamThumbnailFormat.webp,
        maxHeight: 10,
        maxWidth: 20,
        timeMs: 500,
        quality: 80,
      );

      expect(result, data);
      final request = verify(() => hostApi.thumbnailData(captureAny())).captured.single as ThumbnailRequest;
      expect(request.video, 'a.mp4');
      expect(request.format, ThumbnailFormat.webp);
      expect(request.maxHeight, 10);
      expect(request.maxWidth, 20);
      expect(request.timeMs, 500);
      expect(request.quality, 80);
    });

    test('thumbnailFile wraps the returned path in an XFile', () async {
      when(() => hostApi.thumbnailFile(any())).thenAnswer((_) async => '/tmp/thumb.png');

      final result = await channel.thumbnailFile(
        video: 'a.mp4',
        headers: null,
        thumbnailPath: null,
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
          video: 'a.mp4',
          headers: null,
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
        videos: ['a.mp4', 'b.mp4', 'c.mp4'],
        headers: null,
        thumbnailPath: null,
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
          videos: ['a.mp4', 'b.mp4', 'c.mp4'],
          headers: null,
          thumbnailPath: null,
          imageFormat: StreamThumbnailFormat.png,
          maxHeight: 0,
          maxWidth: 0,
          quality: 10,
        ),
        throwsA(isA<PlatformException>()),
      );
      expect(callCount, 2);
    });

    test('a null timeMs is sent as -1 on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      when(() => hostApi.thumbnailData(any())).thenAnswer((_) async => Uint8List(0));

      await channel.thumbnailData(
        video: 'a.mp4',
        headers: null,
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
        video: 'a.mp4',
        headers: null,
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
