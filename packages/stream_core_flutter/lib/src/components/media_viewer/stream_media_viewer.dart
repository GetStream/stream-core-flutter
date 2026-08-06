import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_app_bar_theme.dart';
import '../../theme/components/stream_bottom_app_bar_theme.dart';
import '../../theme/components/stream_media_viewer_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../toolbar/stream_app_bar.dart';
import '../toolbar/stream_bottom_app_bar.dart';

/// A full-screen surface for browsing media (images, videos, etc.).
///
/// Composes an optional [header], [footer], and [child] media area, and
/// animates the chrome in and out via [showChrome]. The [child] is
/// typically a [PageView] of image / video players, [header] a
/// [StreamAppBar], and [footer] a [StreamBottomAppBar] — none are
/// required.
///
/// {@tool snippet}
///
/// Browse a list of attachments with chrome that hides on tap:
///
/// ```dart
/// StreamMediaViewer(
///   showChrome: _showChrome,
///   header: StreamAppBar(title: const Text('Photo')),
///   footer: StreamBottomAppBar(title: Text('${i + 1} of $n')),
///   child: GestureDetector(
///     onTap: () => setState(() => _showChrome = !_showChrome),
///     child: PageView.builder(/* ... */),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMediaViewerTheme], for theming via the widget tree.
///  * [StreamAppBar], the top chrome typically used as [header].
///  * [StreamBottomAppBar], the bottom chrome typically used as [footer].
class StreamMediaViewer extends StatelessWidget {
  /// Creates a Stream media viewer.
  StreamMediaViewer({
    super.key,
    required Widget child,
    PreferredSizeWidget? header,
    PreferredSizeWidget? footer,
    bool showChrome = true,
  }) : props = .new(
         child: child,
         header: header,
         footer: footer,
         showChrome: showChrome,
       );

  /// The properties that configure this media viewer.
  final StreamMediaViewerProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).mediaViewer;
    if (builder != null) return builder(context, props);
    return DefaultStreamMediaViewer(props: props);
  }
}

/// Properties for configuring a [StreamMediaViewer].
///
/// See also:
///
///  * [StreamMediaViewer], which uses these properties.
class StreamMediaViewerProps {
  /// Creates properties for a media viewer.
  const StreamMediaViewerProps({
    required this.child,
    this.header,
    this.footer,
    this.showChrome = true,
  });

  /// The media content. Extends full-bleed behind floating chrome; when the
  /// chrome is regular it is inset to fit between [header] and [footer] (plus
  /// the top / bottom safe-area insets) so the chrome never overlaps it.
  final Widget child;

  /// The top chrome — typically a [StreamAppBar]. Slides off-screen
  /// when [showChrome] flips to false.
  final PreferredSizeWidget? header;

  /// The bottom chrome — typically a [StreamBottomAppBar]. Slides
  /// off-screen when [showChrome] flips to false.
  final PreferredSizeWidget? footer;

  /// Whether the chrome (header / footer) is visible.
  ///
  /// When false, chrome slides off-screen and the background fades to
  /// the immersive colour. The caller owns this state — typically a
  /// tap on the media toggles it.
  final bool showChrome;
}

/// The default implementation of [StreamMediaViewer].
///
/// See also:
///
///  * [StreamMediaViewer], the public API widget.
///  * [StreamMediaViewerProps], which configures this widget.
class DefaultStreamMediaViewer extends StatelessWidget {
  /// Creates a default media viewer with the given [props].
  const DefaultStreamMediaViewer({super.key, required this.props});

  /// The properties that configure this media viewer.
  final StreamMediaViewerProps props;

  @override
  Widget build(BuildContext context) {
    final theme = context.streamMediaViewerTheme;
    final defaults = _StreamMediaViewerDefaults(context);

    final showChrome = props.showChrome;

    final effectiveBackgroundColor = theme.backgroundColor ?? defaults.backgroundColor;
    final effectiveImmersiveBackgroundColor = theme.immersiveBackgroundColor ?? defaults.immersiveBackgroundColor;
    final effectiveDuration = theme.chromeAnimationDuration ?? defaults.chromeAnimationDuration;
    final effectiveAppBarStyle = theme.appBarStyle ?? defaults.appBarStyle;
    final effectiveBottomAppBarStyle = theme.bottomAppBarStyle ?? defaults.bottomAppBarStyle;

    // Scopes optional chrome styles so descendant app bars resolve to
    // them instead of the ambient theme.
    Widget scopeChromeTheme(Widget child) {
      var scoped = child;
      if (effectiveAppBarStyle case final style?) {
        scoped = StreamAppBarTheme(
          data: StreamAppBarThemeData(style: style),
          child: scoped,
        );
      }
      if (effectiveBottomAppBarStyle case final style?) {
        scoped = StreamBottomAppBarTheme(
          data: StreamBottomAppBarThemeData(style: style),
          child: scoped,
        );
      }
      return scoped;
    }

    // Resolve the chrome's floating state: media is full-bleed behind floating
    // chrome, inset under docked chrome. Resolved from the chrome style then the
    // ambient StreamSurfaceStyle — not from a per-instance style on the header /
    // footer widget, so pin the behavior on the media-viewer theme to keep the
    // inset and the chrome in sync.
    final fallbackFloating = context.streamTheme.appStyle.isFloating;
    final headerFloating = effectiveAppBarStyle?.behavior?.isFloating ?? fallbackFloating;
    final footerFloating = effectiveBottomAppBarStyle?.behavior?.isFloating ?? fallbackFloating;

    final mediaQueryPadding = MediaQuery.paddingOf(context);

    final header = props.header?.preferredSize;
    final footer = props.footer?.preferredSize;

    final headerInset = (header == null || headerFloating) ? 0.0 : header.height + mediaQueryPadding.top;
    final footerInset = (footer == null || footerFloating) ? 0.0 : footer.height + mediaQueryPadding.bottom;

    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: effectiveDuration,
      color: showChrome ? effectiveBackgroundColor : effectiveImmersiveBackgroundColor,
      child: scopeChromeTheme(
        Stack(
          fit: .expand,
          children: [
            AnimatedPadding(
              duration: effectiveDuration,
              curve: Curves.easeInOut,
              padding: .only(top: headerInset, bottom: footerInset),
              child: props.child,
            ),
            if (props.header case final header?)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _ChromeSlot(
                  duration: effectiveDuration,
                  visible: showChrome,
                  slideOffset: const Offset(0, -1),
                  child: header,
                ),
              ),
            if (props.footer case final footer?)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _ChromeSlot(
                  duration: effectiveDuration,
                  visible: showChrome,
                  slideOffset: const Offset(0, 1),
                  child: footer,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChromeSlot extends StatelessWidget {
  const _ChromeSlot({
    required this.duration,
    required this.visible,
    required this.slideOffset,
    required this.child,
  });

  final Duration duration;
  final bool visible;
  final Offset slideOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Let taps fall through to the media when chrome is hidden, so
      // the caller's tap-to-toggle gesture can bring it back.
      ignoring: !visible,
      child: AnimatedSlide(
        offset: visible ? .zero : slideOffset,
        duration: duration,
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: duration,
          curve: Curves.easeInOut,
          child: child,
        ),
      ),
    );
  }
}

class _StreamMediaViewerDefaults extends StreamMediaViewerThemeData {
  _StreamMediaViewerDefaults(this.context) : _colorScheme = context.streamColorScheme;

  final BuildContext context;
  final StreamColorScheme _colorScheme;

  @override
  Color get backgroundColor => _colorScheme.backgroundApp;

  @override
  Color get immersiveBackgroundColor => StreamColors.black;

  @override
  Duration get chromeAnimationDuration => kThemeAnimationDuration;
}
