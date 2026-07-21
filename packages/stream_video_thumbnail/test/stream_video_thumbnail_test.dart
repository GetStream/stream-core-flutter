import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_video_thumbnail/src/stream_thumbnail_format.dart';
import 'package:stream_video_thumbnail/src/stream_video_thumbnail.dart';
import 'package:stream_video_thumbnail/src/stream_video_thumbnail_method_channel.dart';
import 'package:stream_video_thumbnail/src/stream_video_thumbnail_platform.dart';

/// A fake platform that records the last call it received and returns canned
/// results. Extending [StreamVideoThumbnailPlatform] inherits its token, so it
/// can be installed as the active instance without the mock mixin.
class FakeStreamVideoThumbnailPlatform extends StreamVideoThumbnailPlatform {
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
FakeStreamVideoThumbnailPlatform useFakePlatform() {
  final original = StreamVideoThumbnailPlatform.instance;
  final fake = FakeStreamVideoThumbnailPlatform();
  StreamVideoThumbnailPlatform.instance = fake;
  addTearDown(() => StreamVideoThumbnailPlatform.instance = original);
  return fake;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StreamThumbnailFormat', () {
    // The wire protocol sends `imageFormat.index` to the native side, where the
    // int maps to jpg/png/webp. This order is a cross-language contract.
    test('exposes JPEG, PNG and WEBP at indices 0, 1 and 2', () {
      expect(StreamThumbnailFormat.values, [
        StreamThumbnailFormat.jpeg,
        StreamThumbnailFormat.png,
        StreamThumbnailFormat.webp,
      ]);
      expect(StreamThumbnailFormat.jpeg.index, 0);
      expect(StreamThumbnailFormat.png.index, 1);
      expect(StreamThumbnailFormat.webp.index, 2);
    });
  });

  group('StreamVideoThumbnail', () {
    test('thumbnailData forwards to the platform and returns its bytes', () async {
      final fake = useFakePlatform();

      final result = await StreamVideoThumbnail.thumbnailData(video: 'a.mp4');

      expect(result, same(fake.data));
    });

    test('thumbnailData applies the documented default options', () async {
      final fake = useFakePlatform();

      await StreamVideoThumbnail.thumbnailData(video: 'a.mp4');

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

      final result = await StreamVideoThumbnail.thumbnailFile(video: 'a.mp4');

      expect(result, same(fake.file));
      expect(fake.lastFileCall?['video'], 'a.mp4');
    });

    test('thumbnailFiles returns an empty list without hitting the platform for no videos', () async {
      final fake = useFakePlatform();

      final result = await StreamVideoThumbnail.thumbnailFiles(videos: []);

      expect(result, isEmpty);
      expect(fake.filesCalled, isFalse);
    });

    test('thumbnailData rejects an empty video path', () {
      useFakePlatform();

      expect(
        () => StreamVideoThumbnail.thumbnailData(video: ''),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('MethodChannelStreamVideoThumbnail', () {
    const channel = MethodChannelStreamVideoThumbnail.methodChannel;
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    /// Intercepts outgoing calls on the plugin channel, recording them and
    /// replying with [reply].
    List<MethodCall> mockChannel(Object? reply) {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return reply;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      return calls;
    }

    test('thumbnailData invokes "data" with the encoded request and returns the bytes', () async {
      final data = Uint8List.fromList([9, 8, 7]);
      final calls = mockChannel(data);

      final result = await MethodChannelStreamVideoThumbnail().thumbnailData(
        video: 'a.mp4',
        headers: null,
        imageFormat: StreamThumbnailFormat.webp,
        maxHeight: 10,
        maxWidth: 20,
        timeMs: 500,
        quality: 80,
      );

      expect(result, data);
      expect(calls.single.method, 'data');
      final args = calls.single.arguments as Map<Object?, Object?>;
      expect(args['video'], 'a.mp4');
      expect(args['format'], StreamThumbnailFormat.webp.index);
      expect(args['maxh'], 10);
      expect(args['maxw'], 20);
      expect(args['timeMs'], 500);
      expect(args['quality'], 80);
    });

    test('a null timeMs is sent as -1 on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final calls = mockChannel(Uint8List(0));

      await MethodChannelStreamVideoThumbnail().thumbnailData(
        video: 'a.mp4',
        headers: null,
        imageFormat: StreamThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        quality: 10,
      );

      expect((calls.single.arguments as Map)['timeMs'], -1);
    });

    test('a null timeMs is sent as 0 on non-Android platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final calls = mockChannel(Uint8List(0));

      await MethodChannelStreamVideoThumbnail().thumbnailData(
        video: 'a.mp4',
        headers: null,
        imageFormat: StreamThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        quality: 10,
      );

      expect((calls.single.arguments as Map)['timeMs'], 0);
    });
  });
}
