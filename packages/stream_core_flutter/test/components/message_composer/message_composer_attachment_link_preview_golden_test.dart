// ignore_for_file: avoid_redundant_argument_values

import 'dart:typed_data';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('MessageComposerAttachmentLinkPreview Golden Tests', () {
    goldenTest(
      'renders light theme matrix',
      fileName: 'message_composer_attachment_link_preview_light_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 360),
        children: [
          GoldenTestScenario(
            name: 'full_no_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: const Text('Getting started with Stream'),
                subtitle: const Text('Build in-app messaging with our flexible SDKs.'),
                caption: const _UrlCaption(url: 'https://getstream.io/chat/docs/'),
                onRemovePressed: null,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'full_with_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: const Text('Getting started with Stream'),
                subtitle: const Text('Build in-app messaging with our flexible SDKs.'),
                caption: const _UrlCaption(url: 'https://getstream.io/chat/docs/'),
                onRemovePressed: () {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'full_with_image_no_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: const Text('Getting started with Stream'),
                subtitle: const Text('Build in-app messaging with our flexible SDKs.'),
                caption: const _UrlCaption(url: 'https://getstream.io/chat/docs/'),
                thumbnail: Image(image: _placeholderImage, fit: BoxFit.cover),
                onRemovePressed: null,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'full_with_image_with_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: const Text('Getting started with Stream'),
                subtitle: const Text('Build in-app messaging with our flexible SDKs.'),
                caption: const _UrlCaption(url: 'https://getstream.io/chat/docs/'),
                thumbnail: Image(image: _placeholderImage, fit: BoxFit.cover),
                onRemovePressed: () {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'caption_only_no_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: null,
                subtitle: null,
                caption: const _UrlCaption(url: 'https://getstream.io/'),
                onRemovePressed: null,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'caption_only_with_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: null,
                subtitle: null,
                caption: const _UrlCaption(url: 'https://getstream.io/'),
                onRemovePressed: () {},
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme matrix',
      fileName: 'message_composer_attachment_link_preview_dark_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 360),
        children: [
          GoldenTestScenario(
            name: 'full_no_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: const Text('Getting started with Stream'),
                subtitle: const Text('Build in-app messaging with our flexible SDKs.'),
                caption: const _UrlCaption(url: 'https://getstream.io/chat/docs/'),
                onRemovePressed: null,
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'full_with_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: const Text('Getting started with Stream'),
                subtitle: const Text('Build in-app messaging with our flexible SDKs.'),
                caption: const _UrlCaption(url: 'https://getstream.io/chat/docs/'),
                onRemovePressed: () {},
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'full_with_image_no_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: const Text('Getting started with Stream'),
                subtitle: const Text('Build in-app messaging with our flexible SDKs.'),
                caption: const _UrlCaption(url: 'https://getstream.io/chat/docs/'),
                thumbnail: Image(image: _placeholderImage, fit: BoxFit.cover),
                onRemovePressed: null,
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'full_with_image_with_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: const Text('Getting started with Stream'),
                subtitle: const Text('Build in-app messaging with our flexible SDKs.'),
                caption: const _UrlCaption(url: 'https://getstream.io/chat/docs/'),
                thumbnail: Image(image: _placeholderImage, fit: BoxFit.cover),
                onRemovePressed: () {},
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'caption_only_no_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: null,
                subtitle: null,
                caption: const _UrlCaption(url: 'https://getstream.io/'),
                onRemovePressed: null,
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'caption_only_with_remove',
            child: _buildLinkPreviewInTheme(
              StreamMessageComposerLinkPreviewAttachment(
                title: null,
                subtitle: null,
                caption: const _UrlCaption(url: 'https://getstream.io/'),
                onRemovePressed: () {},
              ),
              brightness: Brightness.dark,
            ),
          ),
        ],
      ),
    );
  });
}

/// Minimal 1x1 PNG (transparent pixel) for deterministic golden tests.
final _placeholderImage = MemoryImage(Uint8List.fromList(_kTransparentPixelPng));

const _kTransparentPixelPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, //
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, //
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, //
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, //
  0x42, 0x60, 0x82, //
];

class _UrlCaption extends StatelessWidget {
  const _UrlCaption({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(context.streamIcons.link, size: 12),
        Flexible(child: Text(url)),
      ],
    );
  }
}

Widget _buildLinkPreviewInTheme(
  Widget linkPreview, {
  Brightness brightness = Brightness.light,
}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(
      brightness: brightness,
      extensions: [streamTheme],
    ),
    child: Builder(
      builder: (context) => Material(
        color: StreamTheme.of(context).colorScheme.backgroundApp,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: linkPreview,
        ),
      ),
    ),
  );
}
