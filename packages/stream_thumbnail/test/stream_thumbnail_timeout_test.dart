import 'dart:async';

import 'package:flutter/services.dart';
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

  final pendingFiles = <Completer<List<XFile>>>[];

  @override
  Future<List<XFile>> thumbnailFiles({
    required List<StreamThumbnailSource> sources,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    final completer = Completer<List<XFile>>();
    pendingFiles.add(completer);
    return completer.future;
  }
}

void main() {
  testWidgets('fails a thumbnail that takes longer than a minute and starts a waiting one', (tester) async {
    final original = StreamThumbnailPlatform.instance;
    final platform = _GatedPlatform();
    StreamThumbnailPlatform.instance = platform;
    addTearDown(() => StreamThumbnailPlatform.instance = original);

    final results = [
      for (var i = 0; i < 4; i++) StreamThumbnail.thumbnailData(source: StreamThumbnailSource.file('/a.mp4')),
    ];
    for (final result in results.skip(1)) {
      result.ignore();
    }
    await tester.pump();
    expect(platform.pending, hasLength(3));

    final timedOut = expectLater(
      results.first,
      throwsA(isA<PlatformException>().having((e) => e.code, 'code', 'THUMBNAIL_ERROR')),
    );
    await tester.pump(const Duration(minutes: 1));

    await timedOut;
    expect(platform.pending, hasLength(4));

    for (final completer in platform.pending) {
      if (!completer.isCompleted) completer.complete(Uint8List(0));
    }
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('gives thumbnailFiles a minute per video', (tester) async {
    final original = StreamThumbnailPlatform.instance;
    final platform = _GatedPlatform();
    StreamThumbnailPlatform.instance = platform;
    addTearDown(() => StreamThumbnailPlatform.instance = original);

    var failed = false;
    StreamThumbnail.thumbnailFiles(
      sources: [StreamThumbnailSource.file('/a.mp4'), StreamThumbnailSource.file('/b.mp4')],
    ).catchError((Object _) {
      failed = true;
      return <XFile>[];
    }).ignore();
    await tester.pump();

    await tester.pump(const Duration(seconds: 90));
    expect(failed, isFalse);

    await tester.pump(const Duration(seconds: 31));
    expect(failed, isTrue);
  });
}
