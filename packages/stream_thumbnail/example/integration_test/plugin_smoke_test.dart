import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stream_thumbnail/stream_thumbnail.dart';

/// Remote-URL coverage needs network access, so it is opt-in:
/// `flutter test integration_test --dart-define=stream_thumbnail.network=true`.
// ignore: do_not_use_environment, a dart-define is the only way to toggle this on a device.
const _networkTests = bool.fromEnvironment('stream_thumbnail.network');

const _remoteVideo = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

// WebP encoding isn't implemented by the Windows (Media Foundation + WIC)
// backend yet; it reports UNSUPPORTED_FORMAT instead.
final _webpSupported = !Platform.isWindows;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // The plugin takes a filesystem path, so the bundled fixture has to be
  // unpacked out of the asset bundle before it can be thumbnailed.
  late final String video;

  setUpAll(() async {
    final bytes = await rootBundle.load('assets/sample_video.mp4');
    final file = File('${Directory.systemTemp.path}/stream_thumbnail_sample_video.mp4');
    await file.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes), flush: true);
    video = file.path;
  });

  testWidgets('thumbnailData generates real jpeg bytes from a local video', (tester) async {
    final bytes = await StreamThumbnail.thumbnailData(
      video: video,
      imageFormat: StreamThumbnailFormat.jpeg,
      maxWidth: 300,
      quality: 75,
    );

    expect(bytes.length, greaterThan(0));
    // JPEG magic bytes.
    expect(bytes[0], 0xFF);
    expect(bytes[1], 0xD8);
  });

  testWidgets('thumbnailData generates real png bytes from a local video', (tester) async {
    final bytes = await StreamThumbnail.thumbnailData(
      video: video,
      maxWidth: 300,
    );

    expect(bytes.length, greaterThan(0));
    // PNG magic bytes.
    expect(bytes.take(4), [0x89, 0x50, 0x4E, 0x47]);
  });

  testWidgets(
    'thumbnailData generates real webp bytes from a local video',
    (tester) async {
      final bytes = await StreamThumbnail.thumbnailData(
        video: video,
        imageFormat: StreamThumbnailFormat.webp,
        maxWidth: 300,
        quality: 80,
      );

      expect(bytes.length, greaterThan(0));
      // RIFF....WEBP header.
      expect(bytes.take(4), 'RIFF'.codeUnits);
      expect(bytes.skip(8).take(4), 'WEBP'.codeUnits);
    },
    skip: !_webpSupported,
  );

  testWidgets(
    'thumbnailData generates real jpeg bytes from a remote video',
    (tester) async {
      final bytes = await StreamThumbnail.thumbnailData(
        video: _remoteVideo,
        imageFormat: StreamThumbnailFormat.jpeg,
        maxWidth: 300,
        quality: 75,
      );

      expect(bytes.length, greaterThan(0));
      // JPEG magic bytes.
      expect(bytes[0], 0xFF);
      expect(bytes[1], 0xD8);
    },
    skip: !_networkTests,
  );
}
