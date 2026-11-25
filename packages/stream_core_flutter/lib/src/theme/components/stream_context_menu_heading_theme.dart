import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
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
/// A heading takes its size and padding from [StreamContextMenuActionTheme]
/// when this theme leaves them unset, so restyling the rows of a menu through
/// the action theme alone keeps its headings lined up with its actions.
///
/// {@tool snippet}
///
/// Use the denser row metrics of a desktop menu for one menu, headings
/// included:
///
/// ```dart
/// StreamContextMenuActionTheme(
///   data: StreamContextMenuActionThemeData(
///     style: StreamContextMenuActionStyle(
///       minimumSize: WidgetStatePropertyAll(Size(200, 32)),
///       padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
///     ),
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
@experimental
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
/// {@tool snippet}
///
/// Customize heading appearance globally:
///
/// ```dart
/// StreamTheme(
///   contextMenuHeadingTheme: StreamContextMenuHeadingThemeData(
///     style: StreamContextMenuHeadingStyle(
///       textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 15)),
///       foregroundColor: WidgetStatePropertyAll(Colors.grey),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenuHeading], the widget that uses this theme data.
///  * [StreamContextMenuHeadingTheme], for overriding theme in a widget subtree.
///  * [StreamContextMenuHeadingStyle], for heading-level styling.
@themeGen
@immutable
@experimental
class StreamContextMenuHeadingThemeData with _$StreamContextMenuHeadingThemeData {
  /// Creates a context menu heading theme with optional style overrides.
  const StreamContextMenuHeadingThemeData({this.style});

  /// The visual styling for context menu headings.
  final StreamContextMenuHeadingStyle? style;

  /// Linearly interpolate between two [StreamContextMenuHeadingThemeData]
  /// objects.
  static StreamContextMenuHeadingThemeData? lerp(
    StreamContextMenuHeadingThemeData? a,
    StreamContextMenuHeadingThemeData? b,
    double t,
  ) => _$StreamContextMenuHeadingThemeData.lerp(a, b, t);
}

/// Visual styling properties for context menu headings.
///
/// Every property is a [WidgetStateProperty], resolved against the hovered,
/// focused, pressed and disabled states of a heading that responds to taps. A
/// heading without a tap callback resolves them against no state, or only the
/// disabled state when it is disabled.
///
/// The row metrics, [minimumSize], [maximumSize] and [padding], fall back to
/// the [StreamContextMenuActionStyle] of the surrounding
/// [StreamContextMenuActionTheme] when null here, so a heading lines up with
/// the actions it labels.
///
/// See also:
///
///  * [StreamContextMenuHeadingThemeData], which contains this style.
///  * [StreamContextMenuHeading], which uses this styling.
@themeGen
@immutable
@experimental
class StreamContextMenuHeadingStyle with _$StreamContextMenuHeadingStyle {
  /// Creates context menu heading style properties.
  const StreamContextMenuHeadingStyle({
    this.foregroundColor,
    this.overlayColor,
    this.side,
    this.textStyle,
    this.iconSize,
    this.minimumSize,
    this.maximumSize,
    this.padding,
    this.shape,
  });

  /// The color of the heading label and of an icon in its trailing widget.
  ///
  /// If null, defaults to [StreamColorScheme.textTertiary], or
  /// [StreamColorScheme.textDisabled] when the heading is disabled.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// The highlight drawn over a heading that responds to taps.
  ///
  /// Not drawn for a heading without a tap callback.
  ///
  /// If null, defaults to [StreamColorScheme.backgroundPressed] when pressed
  /// and [StreamColorScheme.backgroundHover] when hovered.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The outline drawn along the [shape] of a heading that responds to taps.
  ///
  /// If null, defaults to a 2px [StreamColorScheme.borderFocus] ring when the
  /// heading has keyboard focus, and no outline otherwise.
  final WidgetStateProperty<BorderSide?>? side;

  /// The text style for the heading label.
  ///
  /// If null, defaults to [StreamTextTheme.bodyEmphasis]. The text color is
  /// controlled by [foregroundColor].
  final WidgetStateProperty<TextStyle?>? textStyle;

  /// The size of an icon in the heading's trailing widget.
  ///
  /// If null, defaults to 20.
  final WidgetStateProperty<double?>? iconSize;

  /// The minimum size of the heading.
  ///
  /// If null, falls back to [StreamContextMenuActionStyle.minimumSize], then to
  /// `Size(242, 40)`, the default minimum size of a [StreamContextMenuAction].
  final WidgetStateProperty<Size?>? minimumSize;

  /// The maximum size of the heading.
  ///
  /// If null, falls back to [StreamContextMenuActionStyle.maximumSize], then to
  /// [Size.infinite].
  final WidgetStateProperty<Size?>? maximumSize;

  /// The padding inside the heading.
  ///
  /// If null, falls back to [StreamContextMenuActionStyle.padding], then to
  /// the default padding of a [StreamContextMenuAction]: horizontal
  /// [StreamSpacing.sm] and vertical [StreamSpacing.xs] + [StreamSpacing.xxxs].
  final WidgetStateProperty<EdgeInsetsGeometry?>? padding;

  /// The shape of the highlight and outline of a heading that responds to
  /// taps.
  ///
  /// If null, defaults to a [RoundedRectangleBorder] with [StreamRadius.lg]
  /// border radius.
  final WidgetStateProperty<OutlinedBorder?>? shape;

  /// Linearly interpolate between two [StreamContextMenuHeadingStyle] values.
  static StreamContextMenuHeadingStyle? lerp(
    StreamContextMenuHeadingStyle? a,
    StreamContextMenuHeadingStyle? b,
    double t,
  ) => _$StreamContextMenuHeadingStyle.lerp(a, b, t);
}
