import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stream_thumbnail/stream_thumbnail.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('thumbnailData generates real jpeg bytes from a remote video', (tester) async {
    final bytes = await StreamThumbnail.thumbnailData(
      video: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      imageFormat: StreamThumbnailFormat.jpeg,
      maxWidth: 300,
      quality: 75,
    );

    expect(bytes.length, greaterThan(0));
    // JPEG magic bytes.
    expect(bytes[0], 0xFF);
    expect(bytes[1], 0xD8);
  });

  testWidgets('thumbnailData generates real png bytes from a remote video', (tester) async {
    final bytes = await StreamThumbnail.thumbnailData(
      video: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      maxWidth: 300,
    );

    expect(bytes.length, greaterThan(0));
    // PNG magic bytes.
    expect(bytes.take(4), [0x89, 0x50, 0x4E, 0x47]);
  });

  testWidgets('thumbnailData generates real webp bytes from a remote video', (tester) async {
    final bytes = await StreamThumbnail.thumbnailData(
      video: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      imageFormat: StreamThumbnailFormat.webp,
      maxWidth: 300,
      quality: 80,
    );

    expect(bytes.length, greaterThan(0));
    // RIFF....WEBP header.
    expect(bytes.take(4), 'RIFF'.codeUnits);
    expect(bytes.skip(8).take(4), 'WEBP'.codeUnits);
  });
}
