import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Public-domain Unsplash sample images used by every launcher.
const _sampleImages = <String>[
  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=900&q=80',
  'https://images.unsplash.com/photo-1493558103817-58b2924bce98?w=900&q=80',
  'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=900&q=80',
  'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=900&q=80',
  'https://images.unsplash.com/photo-1505765050516-f72dcac9c60e?w=900&q=80',
];

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMediaViewer,
  path: '[Components]/Media Viewer',
)
Widget buildStreamMediaViewerPlayground(BuildContext context) {
  final showHeader = context.knobs.boolean(
    label: 'Show header',
    initialValue: true,
    description: 'Renders a StreamAppBar as the top chrome.',
  );

  final showFooter = context.knobs.boolean(
    label: 'Show footer',
    initialValue: true,
    description: 'Renders a StreamBottomAppBar as the bottom chrome.',
  );

  final animationMs = context.knobs.double.slider(
    label: 'Chrome animation (ms)',
    initialValue: 200,
    max: 1000,
    description: 'Duration of the chrome show/hide animation.',
  );

  final tintChrome = context.knobs.boolean(
    label: 'Tint chrome over dark media',
    description:
        'Demonstrates StreamMediaViewerThemeData.appBarStyle / '
        'bottomAppBarStyle — scopes a translucent chrome over the media.',
  );

  return _MediaViewerLauncher(
    label: 'Open media viewer',
    onPressed: (launchContext) => _push(
      launchContext,
      StreamMediaViewerTheme(
        data: StreamMediaViewerThemeData(
          chromeAnimationDuration: Duration(milliseconds: animationMs.round()),
          appBarStyle: tintChrome ? const StreamAppBarStyle(backgroundColor: Color(0x55000000)) : null,
          bottomAppBarStyle: tintChrome ? const StreamBottomAppBarStyle(backgroundColor: Color(0x55000000)) : null,
        ),
        child: _PlaygroundMediaViewer(
          showHeader: showHeader,
          showFooter: showFooter,
        ),
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMediaViewer,
  path: '[Components]/Media Viewer',
)
Widget buildStreamMediaViewerShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(
            label: 'Full chrome — header, counter, actions',
            description:
                'The default media viewer with both chrome bars. Tap the '
                'media to toggle them — the background fades to immersive '
                'black when chrome is hidden.',
            launcher: _MediaViewerLauncher(
              label: 'Open full-chrome viewer',
              onPressed: (launchContext) => _push(
                launchContext,
                const _PlaygroundMediaViewer(showHeader: true, showFooter: true),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _Section(
            label: 'Header only — immersive bottom edge',
            description:
                'Footer slot omitted. The media is flush with the bottom '
                'edge while the header still hosts navigation.',
            launcher: _MediaViewerLauncher(
              label: 'Open header-only viewer',
              onPressed: (launchContext) => _push(
                launchContext,
                const _PlaygroundMediaViewer(showHeader: true, showFooter: false),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _Section(
            label: 'Footer only — immersive top edge',
            description:
                'Header slot omitted. The media is flush with the top edge '
                'while the footer hosts a page counter and actions.',
            launcher: _MediaViewerLauncher(
              label: 'Open footer-only viewer',
              onPressed: (launchContext) => _push(
                launchContext,
                const _PlaygroundMediaViewer(showHeader: false, showFooter: true),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _Section(
            label: 'No chrome — pure media surface',
            description:
                'Both chrome slots omitted. The viewer becomes a thin '
                'wrapper around the media — equivalent to immersive mode '
                'with chrome permanently hidden.',
            launcher: _MediaViewerLauncher(
              label: 'Open chrome-less viewer',
              onPressed: (launchContext) => _push(
                launchContext,
                const _PlaygroundMediaViewer(showHeader: false, showFooter: false),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _Section(
            label: 'Tinted chrome — scoped appBarStyle / bottomAppBarStyle',
            description:
                'StreamMediaViewerThemeData carries optional chrome styles '
                'scoped to the viewer. Useful for translucent chrome over a '
                'dark media background without touching app-wide themes.',
            launcher: _MediaViewerLauncher(
              label: 'Open tinted-chrome viewer',
              onPressed: (launchContext) => _push(
                launchContext,
                const StreamMediaViewerTheme(
                  data: StreamMediaViewerThemeData(
                    appBarStyle: StreamAppBarStyle(backgroundColor: Color(0x55000000)),
                    bottomAppBarStyle: StreamBottomAppBarStyle(backgroundColor: Color(0x55000000)),
                  ),
                  child: _PlaygroundMediaViewer(
                    showHeader: true,
                    showFooter: true,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _Section(
            label: 'Faster chrome animation — 80ms show/hide',
            description:
                'chromeAnimationDuration overridden via the theme. Tap the '
                'media to toggle chrome — the slide/fade lands noticeably '
                'snappier than the default 200ms.',
            launcher: _MediaViewerLauncher(
              label: 'Open snappy-chrome viewer',
              onPressed: (launchContext) => _push(
                launchContext,
                const StreamMediaViewerTheme(
                  data: StreamMediaViewerThemeData(
                    chromeAnimationDuration: Duration(milliseconds: 80),
                  ),
                  child: _PlaygroundMediaViewer(
                    showHeader: true,
                    showFooter: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// Helpers
// =============================================================================

class _MediaViewerLauncher extends StatelessWidget {
  const _MediaViewerLauncher({required this.label, required this.onPressed});

  final String label;
  final void Function(BuildContext context) onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamButton(
        onPressed: () => onPressed(context),
        child: Text(label),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.description,
    required this.launcher,
  });

  final String label;
  final String description;
  final Widget launcher;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.captionEmphasis.copyWith(
            color: colorScheme.textSecondary,
          ),
        ),
        SizedBox(height: spacing.xs),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: textTheme.bodyDefault.copyWith(color: colorScheme.textSecondary),
              ),
              SizedBox(height: spacing.md),
              launcher,
            ],
          ),
        ),
      ],
    );
  }
}

class _PlaygroundMediaViewer extends StatefulWidget {
  const _PlaygroundMediaViewer({
    required this.showHeader,
    required this.showFooter,
  });

  final bool showHeader;
  final bool showFooter;

  @override
  State<_PlaygroundMediaViewer> createState() => _PlaygroundMediaViewerState();
}

class _PlaygroundMediaViewerState extends State<_PlaygroundMediaViewer> {
  final _pageController = PageController();
  var _index = 0;
  var _showChrome = true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    return StreamMediaViewer(
      showChrome: _showChrome,
      header: widget.showHeader
          ? StreamAppBar(
              title: const Text('You'),
              subtitle: const Text('14/01/2026, 16:06'),
              trailing: StreamButton.icon(
                icon: Icon(icons.more),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
            )
          : null,
      footer: widget.showFooter
          ? StreamBottomAppBar(
              leading: StreamButton.icon(
                icon: Icon(icons.export),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
              title: Text('${_index + 1} of ${_sampleImages.length}'),
              trailing: StreamButton.icon(
                icon: Icon(icons.gallery),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
              ),
            )
          : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _showChrome = !_showChrome),
        child: PageView.builder(
          controller: _pageController,
          itemCount: _sampleImages.length,
          onPageChanged: (page) => setState(() => _index = page),
          itemBuilder: (_, i) => InteractiveViewer(
            child: Center(child: StreamNetworkImage(_sampleImages[i])),
          ),
        ),
      ),
    );
  }
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => page,
    ),
  );
}
