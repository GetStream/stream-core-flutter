import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stream_thumbnail/stream_thumbnail.dart';
import 'package:stream_thumbnail_example/main.dart';

/// Remote-URL coverage needs network access, so it is opt-in:
/// `flutter test integration_test --dart-define=stream_thumbnail.network=true`.
// ignore: do_not_use_environment, a dart-define is the only way to toggle this on a device.
const _networkTests = bool.fromEnvironment('stream_thumbnail.network');

const _remoteVideo = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

// WebP encoding isn't implemented by the Windows (Media Foundation + WIC)
// backend yet; it reports UNSUPPORTED_FORMAT instead.
final _webpSupported = !Platform.isWindows;

// Only Apple parses a `file://` input as a URL, so only Apple decodes its
// percent-escapes. Android, Linux and Windows strip the prefix and open the rest
// verbatim, so they look for a literally-named `a%20b.mp4` and fail.
final _percentDecodesFileUrls = Platform.isIOS || Platform.isMacOS;

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
    addTearDown(file.deleteSync);
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

  testWidgets('thumbnailFile writes a png named after the video', (tester) async {
    final thumbnail = await StreamThumbnail.thumbnailFile(video: video, maxWidth: 300);

    final written = File(thumbnail.path);
    expect(written.existsSync(), isTrue, reason: 'the reported path must be the file that was written');
    expect(await written.length(), greaterThan(0));
    expect(thumbnail.name, 'stream_thumbnail_sample_video.png');
    expect((await written.readAsBytes()).take(4), [0x89, 0x50, 0x4E, 0x47]);
  });

  testWidgets('thumbnailFile gives each call its own directory', (tester) async {
    final first = await StreamThumbnail.thumbnailFile(video: video, maxWidth: 300);
    final second = await StreamThumbnail.thumbnailFile(video: video, maxWidth: 300);

    // Same video, so the same file name — only the directory keeps them apart.
    expect(first.name, second.name);
    expect(first.path, isNot(second.path));
    expect(File(first.path).existsSync(), isTrue);
    expect(File(second.path).existsSync(), isTrue);
  });

  testWidgets(
    'thumbnailFile accepts a percent-encoded file:// URL',
    (tester) async {
      final spaced = File('${Directory.systemTemp.path}/stream thumbnail spaced.mp4');
      await spaced.writeAsBytes(await File(video).readAsBytes(), flush: true);
      addTearDown(spaced.deleteSync);

      final thumbnail = await StreamThumbnail.thumbnailFile(
        video: 'file://${Uri.encodeFull(spaced.path)}',
        maxWidth: 300,
      );

      expect(File(thumbnail.path).existsSync(), isTrue);
      expect(thumbnail.name, 'stream thumbnail spaced.png');
    },
    skip: !_percentDecodesFileUrls,
  );

  testWidgets('thumbnailFile accepts a bare interpolated file:// path', (tester) async {
    final spaced = File('${Directory.systemTemp.path}/stream thumbnail bare.mp4');
    await spaced.writeAsBytes(await File(video).readAsBytes(), flush: true);
    addTearDown(spaced.deleteSync);

    // The unencoded form callers usually build. Before iOS 17 / macOS 14 `URL(string:)`
    // rejects the space outright, so on those versions this is the raw-path fallback;
    // on newer ones URL parsing accepts it. Both must resolve to the same file.
    final thumbnail = await StreamThumbnail.thumbnailFile(video: 'file://${spaced.path}', maxWidth: 300);

    expect(File(thumbnail.path).existsSync(), isTrue);
  });

  testWidgets('thumbnailFile accepts a file:// path containing # or ?', (tester) async {
    // `#` and `?` are legal in a file name but delimit a fragment/query in a URL, so
    // Apple's URL-first parsing truncates the path unless it falls back. Unlike the
    // space above, this exercises that fallback on every OS version.
    for (final name in ['stream thumbnail #1.mp4', 'stream thumbnail ?2.mp4']) {
      final awkward = File('${Directory.systemTemp.path}/$name');
      await awkward.writeAsBytes(await File(video).readAsBytes(), flush: true);
      addTearDown(awkward.deleteSync);

      final thumbnail = await StreamThumbnail.thumbnailFile(video: 'file://${awkward.path}', maxWidth: 300);

      expect(File(thumbnail.path).existsSync(), isTrue, reason: '$name must resolve to the real file');
      expect(await File(thumbnail.path).length(), greaterThan(0));
    }
  });

  testWidgets(
    'thumbnailFile accepts a file://localhost URL with a # in the name',
    (tester) async {
      // Both branches at once: the `#` forces the raw-path fallback, and that
      // fallback has to drop the `localhost` authority itself or read it as a
      // path segment.
      final awkward = File('${Directory.systemTemp.path}/stream thumbnail #host.mp4');
      await awkward.writeAsBytes(await File(video).readAsBytes(), flush: true);
      addTearDown(awkward.deleteSync);

      final thumbnail = await StreamThumbnail.thumbnailFile(
        video: 'file://localhost${awkward.path}',
        maxWidth: 300,
      );

      expect(File(thumbnail.path).existsSync(), isTrue);
    },
    skip: !_percentDecodesFileUrls,
  );

  testWidgets('thumbnailFiles returns one file per video', (tester) async {
    final thumbnails = await StreamThumbnail.thumbnailFiles(videos: [video, video], maxWidth: 300);

    expect(thumbnails, hasLength(2));
    expect(thumbnails.map((it) => it.path).toSet(), hasLength(2));
    for (final thumbnail in thumbnails) {
      expect(File(thumbnail.path).existsSync(), isTrue);
    }
  });

  // Drives the real widget tree rather than the API, so that a mistake which
  // only shows up on a tap — a bad `setState` callback, say — still fails here.
  testWidgets('the example app previews a thumbnail from either button', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.enterText(find.byType(TextField), video);

    // Only the file variant renders the output path, so asserting on it is what
    // stops the second pass from passing on the first pass's leftover Image.
    // Matched on Text alone — the TextField holds a path too, in an EditableText.
    final pathLabel = find.byWidgetPredicate(
      (widget) => widget is Text && (widget.data?.contains(Platform.pathSeparator) ?? false),
    );

    for (final (button, showsPath) in [('As bytes', false), ('As a file', true)]) {
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: '"$button" must not throw');
      expect(find.byType(Image), findsOneWidget, reason: '"$button" must render a preview');
      expect(pathLabel, showsPath ? findsOneWidget : findsNothing, reason: '"$button" path label');
    }
  });
}
