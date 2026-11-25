import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_thumbnail/src/stream_thumbnail_platform.dart';
import 'package:stream_thumbnail/stream_thumbnail.dart';

/// A platform whose thumbnails finish only when the test completes them.
class _GatedPlatform extends StreamThumbnailPlatform {
  final pending = <Completer<Uint8List>>[];

  @override
  Future<Uint8List> thumbnailData({
    required StreamThumbnailSource source,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    final completer = Completer<Uint8List>();
    pending.add(completer);
    return completer.future;
  }
}

void main() {
  late _GatedPlatform platform;

  setUp(() {
    final original = StreamThumbnailPlatform.instance;
    platform = _GatedPlatform();
    StreamThumbnailPlatform.instance = platform;
    addTearDown(() async {
      for (var i = 0; i < platform.pending.length; i++) {
        if (!platform.pending[i].isCompleted) platform.pending[i].complete(Uint8List(0));
        await pumpEventQueue();
      }
      StreamThumbnailPlatform.instance = original;
    });
  });

  Future<Uint8List> generate() => StreamThumbnail.thumbnailData(source: StreamThumbnailSource.file('/a.mp4'));

  test('generates at most three thumbnails at a time', () async {
    for (var i = 0; i < 5; i++) {
      unawaited(generate());
    }
    await pumpEventQueue();

    expect(platform.pending, hasLength(3));
  });

  test('starts a waiting thumbnail as soon as one finishes', () async {
    final results = [for (var i = 0; i < 4; i++) generate()];
    await pumpEventQueue();

    platform.pending.first.complete(Uint8List(0));
    await pumpEventQueue();

    expect(platform.pending, hasLength(4));
    await results.first;
  });

  test('starts a waiting thumbnail when one fails', () async {
    final results = [for (var i = 0; i < 4; i++) generate()];
    await pumpEventQueue();

    platform.pending.first.completeError(StateError('failed'));
    await expectLater(results.first, throwsStateError);
    await pumpEventQueue();

    expect(platform.pending, hasLength(4));
  });
}
