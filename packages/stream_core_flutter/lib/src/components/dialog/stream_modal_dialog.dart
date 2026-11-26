import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_modal_dialog_theme.dart';
import '../../utils/display_fold.dart';
import 'internal/stream_modal_parts.dart';

/// Shows [builder] as a modal dialog over a blurred scrim.
///
/// The dialog itself is typically a [StreamModalDialog], which supplies the
/// surface, the header and the footer.
///
/// The barrier is a [StreamBlurScrim]: the scrim color over a backdrop blur,
/// rather than a flat translucent fill. Its color comes from [barrierColor],
/// then [StreamModalDialogThemeData.barrierColor]; its blur comes from
/// [StreamModalDialogThemeData.barrierBlurSigma].
///
/// The themes between [context] and the navigator, such as a
/// [StreamModalDialogTheme] around the caller, are applied to the dialog as
/// they are when it opens. Themes above the navigator, such as the app's, are
/// read as they change.
///
/// With [useSafeArea], the default, the dialog keeps clear of the system UI
/// and display cutouts. The scrim covers the whole window either way.
///
/// Focus stays inside the dialog while it is open: [traversalEdgeBehavior]
/// defaults to [TraversalEdgeBehavior.closedLoop]. [requestFocus] decides
/// whether the dialog takes focus when it opens, and defaults to
/// [Navigator.requestFocus].
///
/// On a window split by a fold, the dialog is drawn in the half closest to
/// [anchorPoint], in window coordinates. Pass the position of the control that
/// opened it. Defaults to the trailing top corner, so the dialog goes to the
/// trailing half; a Flutter route with no anchor point goes to the leading
/// half instead.
///
/// The dialog fades and scales in while the scrim fades in and its blur grows.
/// [animationStyle] overrides the transition's duration, 150 milliseconds by
/// default, and its curves, [Curves.easeOutCubic] by default, as it does for
/// [showDialog]. Its reverse duration is ignored.
///
/// Returns the value the dialog was popped with, or null when it was
/// dismissed.
///
/// See also:
///
///  * [StreamModalDialog], the dialog typically shown with this function.
///  * [StreamModalDialogTheme], for customizing the dialog and its scrim.
@experimental
Future<T?> showStreamModalDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  TraversalEdgeBehavior? traversalEdgeBehavior,
  bool? requestFocus,
  AnimationStyle? animationStyle,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);

  return navigator.push<T>(
    _StreamModalDialogRoute<T>(
      builder: builder,
      themes: themes,
      scrimColor: barrierColor,
      useSafeArea: useSafeArea,
      animationStyle: animationStyle,
      settings: routeSettings,
      anchorPoint: anchorPoint ?? trailingTopAnchorOf(context),
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
      traversalEdgeBehavior: traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
      requestFocus: requestFocus,
    ),
  );
}

// Fades and scales the dialog in over a [StreamBlurScrim] whose blur grows
// with it. The transition is the one the video SDK's modal shipped with.
class _StreamModalDialogRoute<T> extends RawDialogRoute<T> {
  _StreamModalDialogRoute({
    required WidgetBuilder builder,
    required this.themes,
    required this.scrimColor,
    required bool useSafeArea,
    required this.animationStyle,
    super.settings,
    super.anchorPoint,
    super.barrierDismissible,
    super.barrierLabel,
    super.traversalEdgeBehavior,
    super.requestFocus,
  }) : super(
         // The transition draws the scrim instead, so that it can blur.
         barrierColor: null,
         transitionDuration: animationStyle?.duration ?? _kTransitionDuration,
         pageBuilder: (context, animation, secondaryAnimation) {
           final dialog = Builder(builder: builder);
           if (!useSafeArea) return dialog;
           return SafeArea(child: dialog);
         },
       );

  static const _kTransitionDuration = Duration(milliseconds: 150);

  final CapturedThemes themes;
  final Color? scrimColor;
  final AnimationStyle? animationStyle;

  CurvedAnimation? _curvedAnimation;

  CurvedAnimation _curve(Animation<double> animation) {
    if (_curvedAnimation?.parent != animation) {
      _curvedAnimation?.dispose();
      _curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: animationStyle?.curve ?? Curves.easeOutCubic,
        reverseCurve: animationStyle?.reverseCurve,
      );
    }
    return _curvedAnimation!;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = _curve(animation);

    return FadeTransition(
      opacity: curve,
      child: themes.wrap(
        Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: curve,
                  // Resolves the theme as it builds, so that it follows a
                  // change to the app's theme while the dialog is open.
                  builder: (context, _) {
                    final blurSigma = resolveStreamModalDialogTheme(context).barrierBlurSigma!;
                    return StreamBlurScrim(
                      color: scrimColor,
                      blurSigma: blurSigma * curve.value,
                    );
                  },
                ),
              ),
            ),
            ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curve),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _curvedAnimation?.dispose();
    super.dispose();
  }
}

/// A translucent fill over a blur of whatever is behind it.
///
/// [showStreamModalDialog] draws one behind its dialog. It fills the space it
/// is given and does not take taps.
///
/// See also:
///
///  * [StreamModalDialogThemeData.barrierColor] and
///    [StreamModalDialogThemeData.barrierBlurSigma], which theme it.
@experimental
class StreamBlurScrim extends StatelessWidget {
  /// Creates a blur scrim.
  const StreamBlurScrim({
    super.key,
    this.color,
    this.blurSigma,
  });

  /// The fill drawn over the blur.
  ///
  /// Defaults to [StreamModalDialogThemeData.barrierColor], and then to
  /// [StreamColorScheme.backgroundScrim].
  final Color? color;

  /// The blur applied to whatever sits behind the scrim.
  ///
  /// Defaults to [StreamModalDialogThemeData.barrierBlurSigma], and then to 25
  /// on Android and iOS and 12.5 on desktop and the web. Set to `0` to skip the
  /// blur, which costs a render layer the size of the window.
  final double? blurSigma;

  @override
  Widget build(BuildContext context) {
    final theme = resolveStreamModalDialogTheme(context);
    final effectiveColor = color ?? theme.barrierColor!;
    final effectiveBlurSigma = blurSigma ?? theme.barrierBlurSigma!;

    final fill = ColoredBox(color: effectiveColor);

    if (effectiveBlurSigma <= 0) return fill;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: effectiveBlurSigma, sigmaY: effectiveBlurSigma),
      child: fill,
    );
  }
}

/// A centered modal surface with a title, header actions and footer actions.
///
/// The dialog takes only the height its content needs, up to its
/// `constraints`. The body gets the room left between the header and the
/// footer, so pass a scrollable body when the content can outgrow it.
///
/// Pass it to [showStreamModalDialog], which supplies the scrim:
///
/// {@tool snippet}
///
/// ```dart
/// final layout = await showStreamModalDialog<String>(
///   context: context,
///   builder: (context) => StreamModalDialog(
///     title: const Text('Choose a layout'),
///     actions: [
///       StreamButton(
///         style: StreamButtonStyle.secondary,
///         type: StreamButtonType.ghost,
///         onPressed: () => Navigator.pop(context, 'grid'),
///         child: const Text('Grid'),
///       ),
///       StreamButton(
///         onPressed: () => Navigator.pop(context, 'spotlight'),
///         child: const Text('Spotlight'),
///       ),
///     ],
///     child: const Text('Pick how participants are arranged.'),
///   ),
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [showStreamModalDialog], which shows the dialog over a scrim.
///  * [StreamModalDialogTheme], for customizing the dialog's appearance.
@experimental
class StreamModalDialog extends StatelessWidget {
  /// Creates a modal dialog.
  StreamModalDialog({
    super.key,
    Widget? title,
    List<Widget> headerActions = const [],
    bool showCloseButton = true,
    VoidCallback? onClose,
    List<Widget> actions = const [],
    EdgeInsetsGeometry? contentPadding,
    BoxConstraints? constraints,
    String? semanticLabel,
    required Widget child,
  }) : props = .new(
         title: title,
         headerActions: headerActions,
         showCloseButton: showCloseButton,
         onClose: onClose,
         actions: actions,
         contentPadding: contentPadding,
         constraints: constraints,
         semanticLabel: semanticLabel,
         child: child,
       );

  /// The properties that configure this modal dialog.
  final StreamModalDialogProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).modalDialog;
    if (builder != null) return builder(context, props);
    return DefaultStreamModalDialog(props: props);
  }
}

/// Properties for configuring a [StreamModalDialog].
///
/// This class holds all the configuration options for a modal dialog,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamModalDialog], which uses these properties.
///  * [DefaultStreamModalDialog], the default implementation.
@experimental
class StreamModalDialogProps {
  /// Creates properties for a modal dialog.
  const StreamModalDialogProps({
    this.title,
    this.headerActions = const [],
    this.showCloseButton = true,
    this.onClose,
    this.actions = const [],
    this.contentPadding,
    this.constraints,
    this.semanticLabel,
    required this.child,
  });

  /// The dialog's title, drawn at the leading edge of the header.
  ///
  /// Typically a [Text]; the header provides its text style and keeps it to
  /// one line. Unless [semanticLabel] is set, the title names the dialog for
  /// screen readers.
  final Widget? title;

  /// Buttons drawn in the header, before the close button.
  ///
  /// Typically [StreamButton.icon]s.
  final List<Widget> headerActions;

  /// Whether the header draws a close button after [headerActions].
  final bool showCloseButton;

  /// Called when the close button is pressed.
  ///
  /// Defaults to [Navigator.maybePop], so a [PopScope] around the dialog can
  /// keep it open.
  final VoidCallback? onClose;

  /// Buttons drawn in the footer.
  ///
  /// An empty list draws no footer at all. See
  /// [StreamModalDialogFooterStyle.expandActions] for how they share the row.
  final List<Widget> actions;

  /// The padding around [child].
  ///
  /// Defaults to [StreamModalDialogThemeData.contentPadding], and then to 24
  /// at the sides and bottom on desktop and the web, and 16 on Android and
  /// iOS, with none at the top. Pass [EdgeInsets.zero] for a body that runs
  /// edge to edge.
  final EdgeInsetsGeometry? contentPadding;

  /// The bounds of the dialog.
  ///
  /// Defaults to [StreamModalDialogThemeData.constraints], and then to at most
  /// 720 wide and 640 high.
  final BoxConstraints? constraints;

  /// The name screen readers announce when the dialog opens.
  ///
  /// When null, the [title] names the dialog. A dialog with neither is named
  /// [MaterialLocalizations.alertDialogLabel] on Android, Fuchsia, Linux and
  /// Windows, and is left unnamed on iOS and macOS, as [AlertDialog] does.
  final String? semanticLabel;

  /// The dialog's body, between the header and the footer.
  final Widget child;
}

/// The default implementation of [StreamModalDialog].
///
/// See also:
///
///  * [StreamModalDialog], the public API widget.
///  * [StreamModalDialogProps], which configures this widget.
@experimental
class DefaultStreamModalDialog extends StatelessWidget {
  /// Creates a default modal dialog with the given [props].
  const DefaultStreamModalDialog({super.key, required this.props});

  /// The properties that configure this modal dialog.
  final StreamModalDialogProps props;

  @override
  Widget build(BuildContext context) {
    final theme = resolveStreamModalDialogTheme(context);
    final effectiveContentPadding = props.contentPadding ?? theme.contentPadding!;
    final label = props.semanticLabel ?? (props.title == null ? _fallbackLabel(context) : null);

    Widget dialog = StreamModalSurface(
      constraints: props.constraints,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamModalHeader(
            title: props.title,
            titleNamesRoute: label == null,
            actions: [
              ...props.headerActions,
              if (props.showCloseButton) StreamModalCloseButton(onPressed: props.onClose),
            ],
          ),
          Flexible(
            child: Padding(
              padding: effectiveContentPadding,
              child: props.child,
            ),
          ),
          if (props.actions.isNotEmpty) _ModalDialogFooter(actions: props.actions),
        ],
      ),
    );

    if (label != null) {
      dialog = Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        namesRoute: true,
        label: label,
        child: dialog,
      );
    }

    return dialog;
  }

  String? _fallbackLabel(BuildContext context) => switch (Theme.of(context).platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => null,
    TargetPlatform.android ||
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.windows => MaterialLocalizations.of(context).alertDialogLabel,
  };
}

class _ModalDialogFooter extends StatelessWidget {
  const _ModalDialogFooter({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final style = resolveStreamModalDialogTheme(context).footerStyle!;
    final expand = style.expandActions!;

    return Padding(
      padding: style.padding!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: style.actionsSpacing!,
        children: [
          for (final action in actions)
            if (expand) Expanded(child: action) else action,
        ],
      ),
    );
  }
}
