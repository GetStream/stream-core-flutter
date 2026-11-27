import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stream_thumbnail/stream_thumbnail.dart';

/// Unpacks [asset] to a temporary file, since the plugin reads videos from
/// the file system.
Future<String> _unpack(String asset) async {
  final bytes = await rootBundle.load(asset);
  final file = File('${Directory.systemTemp.path}/stream_thumbnail_${asset.split('/').last}');
  await file.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes), flush: true);
  addTearDown(file.deleteSync);
  return file.path;
}

Future<Size> _sizeOf(Uint8List image) async {
  final codec = await ui.instantiateImageCodec(image);
  final frame = await codec.getNextFrame();
  final size = Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  frame.image.dispose();
  codec.dispose();
  return size;
}

Future<Size> _thumbnailSize(String video, {int maxWidth = 0, int maxHeight = 0}) async {
  final bytes = await StreamThumbnail.thumbnailData(
    source: StreamThumbnailSource.file(video),
    maxWidth: maxWidth,
    maxHeight: maxHeight,
  );
  return _sizeOf(bytes);
}

final _canDecodeVideosWiderThan4096 = !Platform.isAndroid;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a thumbnail with no bounds keeps the size of a small video', (tester) async {
    final video = await _unpack('assets/sample_video.mp4');

    expect(await _thumbnailSize(video), const Size(320, 240));
  });

  testWidgets('a thumbnail bounded on one side keeps the aspect ratio of the video', (tester) async {
    final video = await _unpack('assets/sample_video.mp4');

    expect(await _thumbnailSize(video, maxWidth: 160), const Size(160, 120));
  });

  testWidgets(
    'a thumbnail of a video wider than 4096 pixels is 4096 pixels wide',
    (tester) async {
      final video = await _unpack('assets/wide_6000x1000.mp4');

      final size = await _thumbnailSize(video);

      expect(size.width, 4096);
      expect(size.height, closeTo(4096 / 6, 1));
    },
    skip: !_canDecodeVideosWiderThan4096,
  );

  testWidgets('a video more than 8192 pixels wide fails with THUMBNAIL_ERROR', (tester) async {
    final video = await _unpack('assets/wide_9000x500.mp4');

    await expectLater(
      StreamThumbnail.thumbnailData(source: StreamThumbnailSource.file(video)),
      throwsA(
        isA<PlatformException>()
            .having((e) => e.code, 'code', 'THUMBNAIL_ERROR')
            .having((e) => e.message, 'message', contains('8192')),
      ),
    );
  });
}
