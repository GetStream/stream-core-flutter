import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageComposerLinkPreviewAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentLinkPreviewPlayground(BuildContext context) {
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Getting started with Stream',
    description: 'Optional title of the link preview.',
  );
  final subtitle = context.knobs.string(
    label: 'Subtitle',
    initialValue: 'Build in-app messaging with our flexible SDKs and APIs.',
    description: 'Optional subtitle or description of the link.',
  );
  final url = context.knobs.string(
    label: 'URL',
    initialValue: 'https://getstream.io/chat/docs/',
    description: 'The link URL shown in the caption row.',
  );
  final showMedia = context.knobs.boolean(
    label: 'Show Media',
    initialValue: true,
    description: 'Toggle the link preview thumbnail media.',
  );
  final showRemoveButton = context.knobs.boolean(
    label: 'Show Remove Button',
    initialValue: true,
    description: 'Toggle the remove attachment control.',
  );

  final maxWidth = context.knobs.double.slider(
    label: 'Parent Max Width',
    initialValue: 360,
    min: 200,
    max: 600,
    description:
        'Bounds the parent width. Values below 290 force the preview to shrink '
        'below its natural minimum.',
  );

  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: StreamMessageComposerLinkPreviewAttachment(
        title: title.isEmpty ? null : Text(title),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        caption: url.isEmpty ? null : _UrlCaption(url: url),
        thumbnail: showMedia ? const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover) : null,
        onRemovePressed: showRemoveButton ? () {} : null,
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMessageComposerLinkPreviewAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentLinkPreviewShowcase(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        _FullPreviewSection(),
        _PartialPreviewSection(),
        _MediaCustomizationSection(),
        _ConstrainedSection(),
      ],
    ),
  );
}

// =============================================================================
// Showcase Sections
// =============================================================================

class _FullPreviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'FULL PREVIEW',
      description: 'All fields populated: image, title, subtitle, and URL.',
      children: [
        _ExampleCard(
          label: 'Complete link preview',
          child: StreamMessageComposerLinkPreviewAttachment(
            title: const Text('Stream Chat Flutter SDK'),
            subtitle: const Text('Build real-time chat with our powerful Flutter SDK.'),
            caption: const _UrlCaption(url: 'https://getstream.io/chat/sdk/flutter/'),
            thumbnail: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}

class _PartialPreviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'PARTIAL PREVIEWS',
      description: 'Each field is optional. Null fields are simply omitted from the layout.',
      children: [
        _ExampleCard(
          label: 'Title + caption only',
          child: StreamMessageComposerLinkPreviewAttachment(
            title: const Text('Flutter Documentation'),
            caption: const _UrlCaption(url: 'https://docs.flutter.dev'),
          ),
        ),
        _ExampleCard(
          label: 'Caption only',
          child: StreamMessageComposerLinkPreviewAttachment(
            caption: const _UrlCaption(url: 'https://getstream.io'),
          ),
        ),
        _ExampleCard(
          label: 'Media + title + subtitle (no caption)',
          child: StreamMessageComposerLinkPreviewAttachment(
            title: const Text('Beautiful Landscapes'),
            subtitle: const Text('A collection of stunning nature photography.'),
            thumbnail: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}

class _MediaCustomizationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    return _Section(
      label: 'MEDIA CUSTOMIZATION',
      description:
          'The thumbnail size, shape, and border side are themable. Defaults to a 40×40 '
          'rounded-superellipse with no border.',
      children: [
        _ExampleCard(
          label: 'Larger 56×56 thumbnail',
          child: StreamMessageComposerLinkPreviewAttachment(
            title: const Text('Stream Chat Flutter SDK'),
            subtitle: const Text('Build real-time chat with our powerful Flutter SDK.'),
            caption: const _UrlCaption(url: 'https://getstream.io/chat/sdk/flutter/'),
            thumbnail: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
            style: const StreamMessageComposerLinkPreviewAttachmentThemeData(thumbnailSize: Size.square(56)),
          ),
        ),
        _ExampleCard(
          label: 'Circular thumbnail',
          child: StreamMessageComposerLinkPreviewAttachment(
            title: const Text('Avatar-style favicon'),
            subtitle: const Text('Custom shape via thumbnailShape.'),
            caption: const _UrlCaption(url: 'https://getstream.io'),
            thumbnail: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
            style: const StreamMessageComposerLinkPreviewAttachmentThemeData(thumbnailShape: CircleBorder()),
          ),
        ),
        _ExampleCard(
          label: 'With media border',
          child: StreamMessageComposerLinkPreviewAttachment(
            title: const Text('Bordered thumbnail'),
            subtitle: const Text('Side composed onto the shape via thumbnailSide.'),
            caption: const _UrlCaption(url: 'https://getstream.io'),
            thumbnail: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
            style: StreamMessageComposerLinkPreviewAttachmentThemeData(
              thumbnailSide: BorderSide(color: colorScheme.borderDefault),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConstrainedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'CONSTRAINED MAX WIDTH',
      description:
          'The preview targets a minimum width of 290 so content has room to breathe. When a '
          'parent bounds the width, the preview shrinks to fit and long text ellipsizes on a '
          'single line rather than wrap.',
      children: [
        _ExampleCard(
          label: 'Bounded to 280 (ellipsizes)',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: StreamMessageComposerLinkPreviewAttachment(
              title: const Text('A very long page title that will not fit on a single line at this width'),
              subtitle: const Text('And an even longer description that also exceeds the available space.'),
              caption: const _UrlCaption(url: 'https://getstream.io/chat/sdk/flutter/long-path/another-segment'),
              thumbnail: const Image(image: AssetImage('assets/attachment_image.png'), fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

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

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.children,
    this.description,
  });

  final String label;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              label,
              style: context.streamTextTheme.metadataEmphasis.copyWith(
                letterSpacing: 1.2,
                color: colorScheme.accentPrimary,
              ),
            ),
            if (description case final desc?)
              Text(desc, style: context.streamTextTheme.metadataDefault.copyWith(color: colorScheme.textTertiary)),
          ],
        ),
        ...children,
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.backgroundApp,
        borderRadius: BorderRadius.all(radius.md),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            label,
            style: context.streamTextTheme.metadataEmphasis.copyWith(color: colorScheme.textSecondary),
          ),
          child,
        ],
      ),
    );
  }
}
