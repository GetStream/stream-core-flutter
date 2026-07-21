import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:stream_thumbnail/stream_thumbnail.dart';

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
  Future<Uint8List>? _thumbnail;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    setState(() {
      _thumbnail = StreamThumbnail.thumbnailData(
        video: _controller.text,
        imageFormat: StreamThumbnailFormat.jpeg,
        maxWidth: 300,
        quality: 75,
      );
    });
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
            FilledButton(
              onPressed: _generate,
              child: const Text('Generate thumbnail'),
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
      return const Text('Tap "Generate thumbnail" to preview a frame.');
    }

    return FutureBuilder<Uint8List>(
      future: thumbnail,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Failed to generate thumbnail:\n${snapshot.error}');
        }
        return Image.memory(snapshot.data!);
      },
    );
  }
}
