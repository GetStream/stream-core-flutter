import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:stream_thumbnail/stream_thumbnail.dart';

/// A generated thumbnail: its bytes, plus where it was written when it came
/// from `thumbnailFile` rather than `thumbnailData`.
typedef Thumbnail = ({Uint8List bytes, String? path});

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'stream_thumbnail example',
      home: ThumbnailPage(),
    );
  }
}

class ThumbnailPage extends StatefulWidget {
  const ThumbnailPage({super.key});

  @override
  State<ThumbnailPage> createState() => _ThumbnailPageState();
}

class _ThumbnailPageState extends State<ThumbnailPage> {
  static const _sampleVideo = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  final _controller = TextEditingController(text: _sampleVideo);
  Future<Thumbnail>? _thumbnail;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Thumbnail> _generateData() async {
    final bytes = await StreamThumbnail.thumbnailData(
      video: _controller.text,
      imageFormat: StreamThumbnailFormat.jpeg,
      maxWidth: 300,
      quality: 75,
    );

    return (bytes: bytes, path: null);
  }

  Future<Thumbnail> _generateFile() async {
    final file = await StreamThumbnail.thumbnailFile(
      video: _controller.text,
      imageFormat: StreamThumbnailFormat.jpeg,
      maxWidth: 300,
      quality: 75,
    );

    return (bytes: await file.readAsBytes(), path: file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Thumbnail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Video file path or URL',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => setState(() {
                      _thumbnail = _generateData();
                    }),
                    child: const Text('As bytes'),
                  ),
                ),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => setState(() {
                      _thumbnail = _generateFile();
                    }),
                    child: const Text('As a file'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: Center(child: _buildPreview())),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final thumbnail = _thumbnail;
    if (thumbnail == null) {
      return const Text('Generate a thumbnail to preview a frame.');
    }

    return FutureBuilder<Thumbnail>(
      future: thumbnail,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Failed to generate thumbnail:\n${snapshot.error}');
        }

        final (:bytes, :path) = snapshot.data!;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Flexible(child: Image.memory(bytes)),
            if (path != null)
              Text(
                path,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        );
      },
    );
  }
}
