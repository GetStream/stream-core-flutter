import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../components/dialog/stream_modal_dialog.dart';
import '../stream_theme.dart';

part 'stream_modal_dialog_theme.g.theme.dart';

/// Applies a modal dialog theme to descendant [StreamModalDialog] widgets.
///
/// The theme also reaches the [StreamBlurScrim] that [showStreamModalDialog]
/// draws behind them.
///
/// Wrap a subtree with [StreamModalDialogTheme] to override modal dialog
/// styling. Access the merged theme using
/// [BuildContext.streamModalDialogTheme].
///
/// A theme around the context passed to [showStreamModalDialog] reaches the
/// dialog it opens, even though the dialog is built on the navigator's overlay.
///
/// {@tool snippet}
///
/// Square off the dialogs opened from a subtree and drop the blur:
///
/// ```dart
/// StreamModalDialogTheme(
///   data: StreamModalDialogThemeData(
///     shape: RoundedRectangleBorder(),
///     barrierBlurSigma: 0,
///   ),
///   child: child,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamModalDialogThemeData], which describes the modal dialog theme.
///  * [StreamModalDialog], the widget affected by this theme.
@experimental
class StreamModalDialogTheme extends InheritedTheme {
  /// Creates a modal dialog theme that controls descendant modal dialogs.
  const StreamModalDialogTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The modal dialog theme data for descendant widgets.
  final StreamModalDialogThemeData data;

  /// Returns the [StreamModalDialogThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamModalDialogTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamModalDialogThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamModalDialogTheme>();
    return StreamTheme.of(context).modalDialogTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamModalDialogTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamModalDialogTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamModalDialog] widgets.
///
/// Describes the surface the dialog is drawn on, its header and footer, and
/// the [StreamBlurScrim] behind it. A property left null falls back to the
/// design system default.
///
/// The design has a mobile and a web variant. Android and iOS get the mobile
/// defaults; desktop and the web share the web ones. These fields differ
/// between the two:
///
///  * [barrierBlurSigma]
///  * [StreamModalDialogHeaderStyle.padding]
///  * [StreamModalDialogHeaderStyle.spacing]
///  * [StreamModalDialogFooterStyle.padding]
///  * [StreamModalDialogFooterStyle.expandActions]
///
/// Set any of them to use one value on every platform.
///
/// {@tool snippet}
///
/// Customize modal dialogs globally:
///
/// ```dart
/// StreamTheme(
///   modalDialogTheme: StreamModalDialogThemeData(
///     constraints: BoxConstraints(maxWidth: 480, maxHeight: 640),
///     headerStyle: StreamModalDialogHeaderStyle(
///       padding: EdgeInsets.all(16),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamModalDialog], the widget that uses this theme data.
///  * [StreamModalDialogTheme], for overriding the theme in a widget subtree.
@themeGen
@immutable
@experimental
class StreamModalDialogThemeData with _$StreamModalDialogThemeData {
  /// Creates modal dialog theme data with optional overrides.
  const StreamModalDialogThemeData({
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.shape,
    this.insetPadding,
    this.constraints,
    this.contentPadding,
    this.headerStyle,
    this.footerStyle,
    this.barrierColor,
    this.barrierBlurSigma,
  });

  /// The color of the dialog's surface.
  ///
  /// Defaults to [StreamColorScheme.backgroundElevation1].
  final Color? backgroundColor;

  /// The elevation of the dialog's surface.
  ///
  /// Defaults to [StreamElevation.level4].
  final double? elevation;

  /// The color of the shadow the dialog's surface casts at [elevation].
  ///
  /// Defaults to the [ColorScheme.shadow] of the ambient [Theme].
  final Color? shadowColor;

  /// The shape of the dialog's surface.
  ///
  /// Defaults to a [RoundedRectangleBorder] with [StreamRadius.xl] corners and
  /// a 1px outline: [StreamColors.black5] in light mode and
  /// [StreamColorScheme.borderOpacityStrong] in dark mode.
  final ShapeBorder? shape;

  /// The room kept between the dialog and the edges of the window.
  ///
  /// Defaults to [StreamSpacing.xxl] on every side.
  final EdgeInsets? insetPadding;

  /// The bounds of the dialog.
  ///
  /// Defaults to at most 720 wide and 640 high. The dialog shrinks with the
  /// window, and takes only the height its content needs.
  final BoxConstraints? constraints;

  /// The padding around the dialog's body, between the header and the footer.
  ///
  /// Defaults to none.
  final EdgeInsetsGeometry? contentPadding;

  /// The style of the dialog's header: the title and the header actions.
  final StreamModalDialogHeaderStyle? headerStyle;

  /// The style of the dialog's footer: the row of actions at the bottom.
  final StreamModalDialogFooterStyle? footerStyle;

  /// The fill of the barrier drawn behind the dialog.
  ///
  /// Defaults to [StreamColorScheme.backgroundScrim].
  final Color? barrierColor;

  /// The blur the barrier applies to whatever sits behind it.
  ///
  /// Defaults to 25 on Android and iOS, and to 12.5 on desktop and the web.
  /// Set to `0` to skip the blur, which costs a render layer the size of the
  /// window.
  final double? barrierBlurSigma;

  /// Linearly interpolate between two [StreamModalDialogThemeData] objects.
  static StreamModalDialogThemeData? lerp(
    StreamModalDialogThemeData? a,
    StreamModalDialogThemeData? b,
    double t,
  ) => _$StreamModalDialogThemeData.lerp(a, b, t);
}

/// The style of the header of a [StreamModalDialog].
///
/// See also:
///
///  * [StreamModalDialogThemeData.headerStyle], which holds this style.
@themeGen
@immutable
@experimental
class StreamModalDialogHeaderStyle with _$StreamModalDialogHeaderStyle {
  /// Creates a modal dialog header style with optional overrides.
  const StreamModalDialogHeaderStyle({
    this.padding,
    this.titleTextStyle,
    this.spacing,
    this.actionsSpacing,
  });

  /// The padding around the header.
  ///
  /// Defaults to [StreamSpacing.md] on every side on Android and iOS, and to
  /// [StreamSpacing.xl] on desktop and the web.
  final EdgeInsetsGeometry? padding;

  /// The text style of the title, including its color.
  ///
  /// Defaults to [StreamTextTheme.headingSm] in
  /// [StreamColorScheme.textPrimary].
  final TextStyle? titleTextStyle;

  /// The gap between the title and the header actions.
  ///
  /// Defaults to [StreamSpacing.sm] on Android and iOS, and to
  /// [StreamSpacing.md] on desktop and the web.
  final double? spacing;

  /// The gap between adjacent header actions, including the close button.
  ///
  /// Defaults to [StreamSpacing.xs].
  final double? actionsSpacing;

  /// Linearly interpolate between two [StreamModalDialogHeaderStyle] objects.
  static StreamModalDialogHeaderStyle? lerp(
    StreamModalDialogHeaderStyle? a,
    StreamModalDialogHeaderStyle? b,
    double t,
  ) => _$StreamModalDialogHeaderStyle.lerp(a, b, t);
}

/// The style of the footer of a [StreamModalDialog].
///
/// See also:
///
///  * [StreamModalDialogThemeData.footerStyle], which holds this style.
@themeGen
@immutable
@experimental
class StreamModalDialogFooterStyle with _$StreamModalDialogFooterStyle {
  /// Creates a modal dialog footer style with optional overrides.
  const StreamModalDialogFooterStyle({
    this.padding,
    this.actionsSpacing,
    this.expandActions,
  });

  /// The padding around the footer.
  ///
  /// Defaults to [StreamSpacing.md] on every side on Android and iOS, and to
  /// [StreamSpacing.xl] on desktop and the web.
  final EdgeInsetsGeometry? padding;

  /// The gap between adjacent footer actions.
  ///
  /// Defaults to [StreamSpacing.xs].
  final double? actionsSpacing;

  /// Whether the footer actions share the footer's width equally.
  ///
  /// When false, the actions keep their own width and sit at the trailing
  /// edge. Defaults to true on Android and iOS, and to false on desktop and
  /// the web.
  final bool? expandActions;

  /// Linearly interpolate between two [StreamModalDialogFooterStyle] objects.
  static StreamModalDialogFooterStyle? lerp(
    StreamModalDialogFooterStyle? a,
    StreamModalDialogFooterStyle? b,
    double t,
  ) => _$StreamModalDialogFooterStyle.lerp(a, b, t);
}
