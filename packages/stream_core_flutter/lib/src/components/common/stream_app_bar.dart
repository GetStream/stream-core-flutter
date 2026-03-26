import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A styled [AppBar] with Stream defaults applied.
///
/// [StreamAppBar] renders a standard Material [AppBar] with
/// defaults from the Stream design system applied.
///
/// {@tool snippet}
///
/// Display a simple app bar with a title:
///
/// ```dart
/// StreamAppBar(
///   title: Text('Messages'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [DefaultStreamAppBar], the default visual implementation.
class StreamAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a Stream-styled app bar.
  StreamAppBar({
    super.key,
    Widget? leading,
    double? leadingWidth,
    bool automaticallyImplyLeading = true,
    Widget? title,
    double? titleSpacing,
    TextStyle? titleTextStyle,
    List<Widget>? actions,
    EdgeInsetsGeometry? actionsPadding,
    bool? centerTitle,
    PreferredSizeWidget? bottom,
    double bottomOpacity = 1.0,
    double elevation = 0,
    double scrolledUnderElevation = 0,
    Color? backgroundColor,
    Color? surfaceTintColor,
    ShapeBorder? shape,
    double? preferredHeight,
  }) : props = StreamAppBarProps(
         leading: leading,
         leadingWidth: leadingWidth,
         automaticallyImplyLeading: automaticallyImplyLeading,
         title: title,
         titleSpacing: titleSpacing,
         titleTextStyle: titleTextStyle,
         actions: actions,
         actionsPadding: actionsPadding,
         centerTitle: centerTitle,
         bottom: bottom,
         bottomOpacity: bottomOpacity,
         elevation: elevation,
         scrolledUnderElevation: scrolledUnderElevation,
         backgroundColor: backgroundColor,
         surfaceTintColor: surfaceTintColor,
         shape: shape,
         preferredHeight: preferredHeight,
       );

  /// The props controlling the appearance and behavior of this app bar.
  final StreamAppBarProps props;

  @override
  Size get preferredSize {
    final bottomHeight = props.bottom?.preferredSize.height ?? 0;
    return Size.fromHeight((props.preferredHeight ?? kToolbarHeight) + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).appBar;
    if (builder != null) return builder(context, props);
    return DefaultStreamAppBar(props: props);
  }
}

/// Properties for configuring a [StreamAppBar].
///
/// This class holds all the configuration options for an app bar, allowing
/// them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamAppBar], which uses these properties.
///  * [DefaultStreamAppBar], the default implementation.
class StreamAppBarProps {
  /// Creates properties for an app bar.
  const StreamAppBarProps({
    this.leading,
    this.leadingWidth,
    this.automaticallyImplyLeading = true,
    this.title,
    this.titleSpacing,
    this.titleTextStyle,
    this.actions,
    this.actionsPadding,
    this.centerTitle,
    this.bottom,
    this.bottomOpacity = 1.0,
    this.elevation = 0,
    this.scrolledUnderElevation = 0,
    this.backgroundColor,
    this.surfaceTintColor,
    this.shape,
    this.preferredHeight,
  });

  /// A widget to display before the toolbar's [title].
  final Widget? leading;

  /// Defines the width of [leading] widget.
  final double? leadingWidth;

  /// Controls whether we should try to imply the leading widget if null.
  final bool automaticallyImplyLeading;

  /// The primary widget displayed in the app bar.
  final Widget? title;

  /// The spacing around [title] content on the horizontal axis.
  final double? titleSpacing;

  /// The text style for the [title].
  ///
  /// Defaults to [StreamTextTheme.headingSm].
  final TextStyle? titleTextStyle;

  /// {@macro flutter.material.appbar.actions}
  final List<Widget>? actions;

  /// Defines the padding for [actions].
  final EdgeInsetsGeometry? actionsPadding;

  /// Whether the title should be centered.
  final bool? centerTitle;

  /// An app bar bottom widget, displayed below the [title].
  final PreferredSizeWidget? bottom;

  /// The opacity of the [bottom] widget.
  final double bottomOpacity;

  /// The z-coordinate at which to place this app bar.
  ///
  /// Defaults to `0`.
  final double elevation;

  /// The elevation when content is scrolled underneath the app bar.
  ///
  /// Defaults to `0`.
  final double scrolledUnderElevation;

  /// The background color of the app bar.
  final Color? backgroundColor;

  /// The surface tint color of the app bar.
  final Color? surfaceTintColor;

  /// The shape of the app bar's [Material].
  ///
  /// Defaults to a [LinearBorder] with a bottom edge using
  /// `borderSubtle` color from the Stream color scheme.
  final ShapeBorder? shape;

  /// Override the default toolbar height ([kToolbarHeight]).
  ///
  /// When null, defaults to [kToolbarHeight].
  final double? preferredHeight;
}

/// Default implementation of [StreamAppBar].
///
/// Renders a Material [AppBar] with Stream design system defaults applied.
///
/// See also:
///
///  * [StreamAppBar], the public API widget.
///  * [StreamAppBarProps], which configures this widget.
class DefaultStreamAppBar extends StatelessWidget {
  /// Creates a default Stream app bar.
  const DefaultStreamAppBar({super.key, required this.props});

  /// The props controlling the appearance and behavior of this app bar.
  final StreamAppBarProps props;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streamTextTheme = context.streamTextTheme;
    final streamColorScheme = context.streamColorScheme;

    return AppBar(
      automaticallyImplyLeading: props.automaticallyImplyLeading,
      toolbarTextStyle: theme.textTheme.bodyMedium,
      titleTextStyle: props.titleTextStyle ?? streamTextTheme.headingSm,
      systemOverlayStyle: theme.brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      elevation: props.elevation,
      scrolledUnderElevation: props.scrolledUnderElevation,
      backgroundColor: props.backgroundColor,
      surfaceTintColor: props.surfaceTintColor,
      centerTitle: props.centerTitle,
      leading: props.leading,
      leadingWidth: props.leadingWidth,
      titleSpacing: props.titleSpacing,
      actions: props.actions,
      actionsPadding: props.actionsPadding,
      title: props.title,
      bottom: props.bottom,
      bottomOpacity: props.bottomOpacity,
      shape:
          props.shape ??
          LinearBorder(
            side: BorderSide(
              color: streamColorScheme.borderSubtle,
            ),
            bottom: const LinearBorderEdge(),
          ),
    );
  }
}
