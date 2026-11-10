import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../components/dialog/stream_modal_window.dart';
import '../stream_theme.dart';
import 'stream_list_tile_theme.dart';
import 'stream_modal_dialog_theme.dart';

part 'stream_modal_window_theme.g.theme.dart';

/// Applies a modal window theme to descendant [StreamModalWindow] widgets.
///
/// Wrap a subtree with [StreamModalWindowTheme] to override modal window
/// styling. Access the merged theme using
/// [BuildContext.streamModalWindowTheme].
///
/// A theme around the context passed to [showStreamModalDialog] reaches the
/// window it opens, even though the window is built on the navigator's
/// overlay.
///
/// {@tool snippet}
///
/// Widen the sidebar of the windows opened from a subtree:
///
/// ```dart
/// StreamModalWindowTheme(
///   data: StreamModalWindowThemeData(
///     style: StreamModalWindowStyle(sidebarWidth: 240),
///   ),
///   child: child,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamModalWindowThemeData], which describes the modal window theme.
///  * [StreamModalWindow], the widget affected by this theme.
///  * [StreamModalDialogTheme], which themes the surface and the header the
///    window shares with [StreamModalDialog].
@experimental
class StreamModalWindowTheme extends InheritedTheme {
  /// Creates a modal window theme that controls descendant modal windows.
  const StreamModalWindowTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The modal window theme data for descendant widgets.
  final StreamModalWindowThemeData data;

  /// Returns the [StreamModalWindowThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamModalWindowTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamModalWindowThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamModalWindowTheme>();
    return StreamTheme.of(context).modalWindowTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamModalWindowTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamModalWindowTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamModalWindow] widgets.
///
/// The window is drawn on the same surface and under the same header as a
/// [StreamModalDialog], so their shape, elevation, inset padding, constraints
/// and header style come from [StreamModalDialogThemeData]. This theme covers
/// only what the window adds: its sidebar of tabs and the area the selected
/// tab is drawn in.
///
/// {@tool snippet}
///
/// Customize modal windows globally:
///
/// ```dart
/// StreamTheme(
///   modalWindowTheme: StreamModalWindowThemeData(
///     style: StreamModalWindowStyle(
///       sidebarWidth: 240,
///       contentPadding: EdgeInsets.all(16),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamModalWindow], the widget that uses this theme data.
///  * [StreamModalWindowTheme], for overriding the theme in a widget subtree.
@themeGen
@immutable
@experimental
class StreamModalWindowThemeData with _$StreamModalWindowThemeData {
  /// Creates modal window theme data with optional overrides.
  const StreamModalWindowThemeData({this.style});

  /// The visual style of the window.
  final StreamModalWindowStyle? style;

  /// Linearly interpolate between two [StreamModalWindowThemeData] objects.
  static StreamModalWindowThemeData? lerp(
    StreamModalWindowThemeData? a,
    StreamModalWindowThemeData? b,
    double t,
  ) => _$StreamModalWindowThemeData.lerp(a, b, t);
}

/// The visual style of a [StreamModalWindow]: its surface color, its sidebar
/// of tabs and the area the selected tab is drawn in.
///
/// See also:
///
///  * [StreamModalWindowThemeData.style], which holds this style.
@themeGen
@immutable
@experimental
class StreamModalWindowStyle with _$StreamModalWindowStyle {
  /// Creates a modal window style with optional overrides.
  const StreamModalWindowStyle({
    this.backgroundColor,
    this.sidebarWidth,
    this.sidebarBackgroundColor,
    this.sidebarBorderColor,
    this.sidebarPadding,
    this.navItemStyle,
    this.navItemMinHeight,
    this.navItemIconSize,
    this.navItemSpacing,
    this.contentPadding,
  });

  /// The color of the window's surface.
  ///
  /// Takes precedence over [StreamModalDialogThemeData.backgroundColor], which
  /// the window falls back to, and then to
  /// [StreamColorScheme.backgroundElevation1].
  final Color? backgroundColor;

  /// The width of the sidebar while it shows the tabs' labels.
  ///
  /// Defaults to 200. A collapsed sidebar is as wide as its icons.
  final double? sidebarWidth;

  /// The color of the sidebar.
  ///
  /// Defaults to none, which shows the window's surface through: see
  /// [backgroundColor].
  final Color? sidebarBackgroundColor;

  /// The color of the line between the sidebar and the selected tab.
  ///
  /// Defaults to [StreamColorScheme.borderSubtle].
  final Color? sidebarBorderColor;

  /// The padding around the sidebar's rows.
  ///
  /// Defaults to [StreamSpacing.xs] at the start and end and
  /// [StreamSpacing.xxs] plus [StreamSpacing.xxxs] at the top and bottom.
  final EdgeInsetsGeometry? sidebarPadding;

  /// The style of the sidebar's rows.
  ///
  /// Applies on top of the app's list tile theme, so a row keeps its colors
  /// and text styles. Its shape and padding come from here rather than from
  /// the app's list tile theme: defaults to [StreamRadius.md] corners and
  /// [StreamSpacing.sm] across and [StreamSpacing.xs] down, which makes a row
  /// 36 tall inside its [navItemMinHeight].
  final StreamListTileThemeData? navItemStyle;

  /// The minimum height of each sidebar row, including the space around its
  /// highlight.
  ///
  /// Defaults to 40.
  final double? navItemMinHeight;

  /// The size of each tab's icon in the sidebar.
  ///
  /// Defaults to 16.
  final double? navItemIconSize;

  /// The gap between a tab's icon and its label in the sidebar.
  ///
  /// Defaults to [StreamSpacing.sm].
  final double? navItemSpacing;

  /// The padding around the selected tab's content.
  ///
  /// Defaults to [StreamSpacing.xl] at the start and end and
  /// [StreamSpacing.xxl] at the bottom. The header above the content brings
  /// its own padding.
  final EdgeInsetsGeometry? contentPadding;

  /// Linearly interpolate between two [StreamModalWindowStyle] objects.
  static StreamModalWindowStyle? lerp(
    StreamModalWindowStyle? a,
    StreamModalWindowStyle? b,
    double t,
  ) => _$StreamModalWindowStyle.lerp(a, b, t);
}
