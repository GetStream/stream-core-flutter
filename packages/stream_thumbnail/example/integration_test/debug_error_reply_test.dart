// DEBUG, not for merging: prints the raw bytes the platform replies with when
// a request fails, to see why Windows error replies can't be decoded.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stream_thumbnail/src/messages.g.dart';

const _channel = 'dev.flutter.pigeon.stream_thumbnail.StreamThumbnailHostApi.thumbnailData';

String _hex(ByteData data) => [
  for (final b in data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)) b.toRadixString(16).padLeft(2, '0'),
].join(' ');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final (name, video, kind) in [
    ('relative path', r'videos\a.mp4', ThumbnailSourceKind.file),
    ('content uri', 'content://media/1', ThumbnailSourceKind.contentUri),
  ]) {
    testWidgets('dump the error reply for a $name', (tester) async {
      final request = ThumbnailRequest(
        video: video,
        sourceKind: kind,
        format: ThumbnailFormat.png,
        maxHeight: 0,
        maxWidth: 0,
        timeMs: 0,
        quality: 10,
      );
      final message = StreamThumbnailHostApi.pigeonChannelCodec.encodeMessage([request])!;
      print('REQUEST $name (${message.lengthInBytes} bytes): ${_hex(message)}');

      final reply = await binding.defaultBinaryMessenger.send(_channel, message);
      if (reply == null) {
        print('REPLY $name: null');
        return;
      }
      print('REPLY $name (${reply.lengthInBytes} bytes): ${_hex(reply)}');

      try {
        print('DECODED $name: ${StreamThumbnailHostApi.pigeonChannelCodec.decodeMessage(reply)}');
      } on FormatException catch (e) {
        print('DECODE FAILED $name: $e');
      }
    });
  }
}
