import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_context_menu_heading_theme.g.theme.dart';

/// Applies a context menu heading theme to descendant [StreamContextMenuHeading]
/// widgets.
///
/// Wrap a subtree with [StreamContextMenuHeadingTheme] to override heading
/// styling. Access the merged theme using
/// [BuildContext.streamContextMenuHeadingTheme].
///
/// {@tool snippet}
///
/// Use the denser row metrics of a desktop menu for the headings of one menu:
///
/// ```dart
/// StreamContextMenuHeadingTheme(
///   data: StreamContextMenuHeadingThemeData(
///     minimumSize: Size(200, 32),
///     padding: EdgeInsets.symmetric(horizontal: 8),
///   ),
///   child: StreamContextMenu(
///     children: [
///       StreamContextMenuHeading(label: Text('Microphone')),
///       StreamContextMenuAction(label: Text('Built-in microphone')),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenuHeadingThemeData], which describes the heading theme.
///  * [StreamContextMenuHeading], the widget affected by this theme.
class StreamContextMenuHeadingTheme extends InheritedTheme {
  /// Creates a context menu heading theme that controls descendant headings.
  const StreamContextMenuHeadingTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The context menu heading theme data for descendant widgets.
  final StreamContextMenuHeadingThemeData data;

  /// Returns the [StreamContextMenuHeadingThemeData] merged from local and
  /// global themes.
  ///
  /// Local values from the nearest [StreamContextMenuHeadingTheme] ancestor
  /// take precedence over global values from [StreamTheme.of].
  static StreamContextMenuHeadingThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamContextMenuHeadingTheme>();
    return StreamTheme.of(context).contextMenuHeadingTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamContextMenuHeadingTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamContextMenuHeadingTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamContextMenuHeading] widgets.
///
/// The defaults line a heading up with the default metrics of a
/// [StreamContextMenuAction]: the same minimum size, padding and shape. A menu
/// that restyles its actions through [StreamContextMenuActionTheme] should set
/// the matching values here so the heading keeps sharing the row metrics.
///
/// {@tool snippet}
///
/// Customize heading appearance globally:
///
/// ```dart
/// StreamTheme(
///   contextMenuHeadingTheme: StreamContextMenuHeadingThemeData(
///     textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
///     foregroundColor: Colors.grey,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenuHeading], the widget that uses this theme data.
///  * [StreamContextMenuHeadingTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamContextMenuHeadingThemeData with _$StreamContextMenuHeadingThemeData {
  /// Creates a context menu heading theme with optional style overrides.
  const StreamContextMenuHeadingThemeData({
    this.textStyle,
    this.foregroundColor,
    this.iconSize,
    this.overlayColor,
    this.minimumSize,
    this.padding,
    this.spacing,
    this.shape,
  });

  /// The text style for the heading label.
  ///
  /// If null, defaults to [StreamTextTheme.captionEmphasis]. The text color is
  /// controlled by [foregroundColor].
  final TextStyle? textStyle;

  /// The color of the heading label and of an icon in its trailing widget.
  ///
  /// If null, defaults to [StreamColorScheme.textTertiary].
  final Color? foregroundColor;

  /// The size of an icon in the heading's trailing widget.
  ///
  /// If null, defaults to 16.
  final double? iconSize;

  /// The highlight drawn over a heading that responds to taps.
  ///
  /// Resolved against the hovered, focused and pressed states. Not drawn for
  /// a heading without a tap callback.
  ///
  /// If null, defaults to [StreamColorScheme.backgroundPressed] when pressed
  /// and [StreamColorScheme.backgroundHover] when hovered or focused.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The minimum size of the heading.
  ///
  /// If null, defaults to `Size(242, 40)`, the minimum size of a
  /// [StreamContextMenuAction].
  final Size? minimumSize;

  /// The padding inside the heading.
  ///
  /// If null, defaults to the padding of a [StreamContextMenuAction], derived
  /// from [StreamSpacing].
  final EdgeInsetsGeometry? padding;

  /// The gap between the label and the trailing widget.
  ///
  /// If null, defaults to [StreamSpacing.xs].
  final double? spacing;

  /// The shape of the highlight drawn over a heading that responds to taps.
  ///
  /// If null, defaults to a [RoundedRectangleBorder] with [StreamRadius.md]
  /// border radius, the shape of a [StreamContextMenuAction].
  final OutlinedBorder? shape;

  /// Linearly interpolate between two [StreamContextMenuHeadingThemeData]
  /// objects.
  static StreamContextMenuHeadingThemeData? lerp(
    StreamContextMenuHeadingThemeData? a,
    StreamContextMenuHeadingThemeData? b,
    double t,
  ) => _$StreamContextMenuHeadingThemeData.lerp(a, b, t);
}
