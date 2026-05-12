import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import 'stream_app_bar_theme.dart';
import 'stream_bottom_app_bar_theme.dart';

part 'stream_media_viewer_theme.g.theme.dart';

/// Applies a media viewer theme to descendant [StreamMediaViewer]s.
///
/// {@tool snippet}
///
/// Tint the chrome for a specific subtree:
///
/// ```dart
/// StreamMediaViewerTheme(
///   data: StreamMediaViewerThemeData(
///     appBarStyle: StreamAppBarStyle(backgroundColor: Colors.transparent),
///   ),
///   child: child,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMediaViewerThemeData], which describes the theme.
///  * [StreamMediaViewer], the widget affected by this theme.
class StreamMediaViewerTheme extends InheritedTheme {
  /// Creates a media viewer theme that controls descendant media viewers.
  const StreamMediaViewerTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The media viewer theme data for descendant widgets.
  final StreamMediaViewerThemeData data;

  /// Returns the [StreamMediaViewerThemeData] merged from local and global
  /// themes. Local values take precedence.
  static StreamMediaViewerThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMediaViewerTheme>();
    return StreamTheme.of(context).mediaViewerTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMediaViewerTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMediaViewerTheme oldWidget) => data != oldWidget.data;
}

/// Visual styling properties for [StreamMediaViewer].
///
/// Unset fields fall back to the viewer's built-in defaults.
///
/// See also:
///
///  * [StreamMediaViewerTheme], which serves this data to descendants.
///  * [StreamMediaViewer], which uses this theme.
@themeGen
@immutable
class StreamMediaViewerThemeData with _$StreamMediaViewerThemeData {
  /// Creates media viewer theme data.
  const StreamMediaViewerThemeData({
    this.backgroundColor,
    this.immersiveBackgroundColor,
    this.chromeAnimationDuration,
    this.appBarStyle,
    this.bottomAppBarStyle,
  });

  /// Background colour behind media when chrome is visible.
  final Color? backgroundColor;

  /// Background colour behind media when chrome is hidden.
  final Color? immersiveBackgroundColor;

  /// Duration of the chrome show/hide animation.
  final Duration? chromeAnimationDuration;

  /// Style scoped to the [StreamAppBar] rendered as the viewer's header.
  final StreamAppBarStyle? appBarStyle;

  /// Style scoped to the [StreamBottomAppBar] rendered as the viewer's footer.
  final StreamBottomAppBarStyle? bottomAppBarStyle;

  /// Linearly interpolate between two [StreamMediaViewerThemeData] objects.
  static StreamMediaViewerThemeData? lerp(
    StreamMediaViewerThemeData? a,
    StreamMediaViewerThemeData? b,
    double t,
  ) => _$StreamMediaViewerThemeData.lerp(a, b, t);
}
