import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_modal_dialog_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../utils/display_fold.dart';
import 'internal/stream_modal_parts.dart';

/// Shows [builder] as a modal dialog over a blurred scrim.
///
/// The dialog itself is typically a [StreamModalDialog], which supplies the
/// surface, the header and the footer.
///
/// The barrier is a [StreamBlurScrim]: the scrim color over a backdrop blur,
/// rather than the flat translucent black Material's [showDialog] paints. Its
/// color and blur come from [StreamModalDialogThemeData.scrimColor] and
/// [StreamModalDialogThemeData.scrimBlurSigma].
///
/// The themes between [context] and the navigator, such as a
/// [StreamModalDialogTheme] around the caller, are applied to the dialog as
/// they are when it opens. Themes above the navigator, such as the app's, are
/// read as they change.
///
/// On a window split by a fold, the dialog is drawn in the half closest to
/// [anchorPoint], in window coordinates. Pass the position of the control that
/// opened it. Defaults to the trailing top corner.
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
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);

  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint ?? trailingTopAnchorOf(context),
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
    // The scrim is drawn as part of the transition instead, so that it can
    // carry the blur. A colored barrier here would paint a second, flat one
    // underneath it.
    barrierColor: StreamColors.transparent,
    transitionDuration: const Duration(milliseconds: 150),
    // A Builder, so the dialog is built under the themes the transition
    // applies.
    pageBuilder: (context, animation, secondaryAnimation) => Builder(builder: builder),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

      return FadeTransition(
        opacity: curve,
        child: themes.wrap(
          Stack(
            children: [
              // Behind the dialog and out of the way of the modal barrier that
              // sits below, which is what a tap outside dismisses.
              const Positioned.fill(
                // Resolves its color as it builds, so that it follows a change
                // to the app's theme while the dialog is open.
                child: IgnorePointer(child: StreamBlurScrim()),
              ),
              ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(curve),
                child: child,
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// The scrim a modal surface sits on: a translucent fill over a blur of
/// whatever is behind it.
///
/// [showStreamModalDialog] draws one behind its dialog. It fills the space it
/// is given and does not take taps.
///
/// See also:
///
///  * [StreamModalDialogThemeData.scrimColor] and
///    [StreamModalDialogThemeData.scrimBlurSigma], which theme it.
@experimental
class StreamBlurScrim extends StatelessWidget {
  /// Creates a blur scrim.
  const StreamBlurScrim({super.key, this.color, this.blurSigma});

  /// The fill drawn over the blur.
  ///
  /// Defaults to [StreamModalDialogThemeData.scrimColor], and then to
  /// [StreamColorScheme.backgroundScrim].
  final Color? color;

  /// The blur applied to whatever sits behind the scrim.
  ///
  /// Defaults to [StreamModalDialogThemeData.scrimBlurSigma], and then to 12.5.
  /// Set to `0` to skip the blur, which costs a render layer the size of the
  /// window.
  final double? blurSigma;

  @override
  Widget build(BuildContext context) {
    final theme = resolveStreamModalDialogTheme(context);
    final effectiveBlurSigma = blurSigma ?? theme.scrimBlurSigma!;

    final fill = ColoredBox(color: color ?? theme.scrimColor!);

    if (effectiveBlurSigma <= 0) return fill;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: effectiveBlurSigma, sigmaY: effectiveBlurSigma),
      child: fill,
    );
  }
}

/// A centered modal surface with a title, an optional row of header actions
/// and an optional row of footer actions.
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
/// final confirmed = await showStreamModalDialog<bool>(
///   context: context,
///   builder: (context) => StreamModalDialog(
///     title: const Text('Discard changes?'),
///     actions: [
///       StreamButton(
///         style: StreamButtonStyle.secondary,
///         type: StreamButtonType.ghost,
///         onPressed: () => Navigator.pop(context, false),
///         child: const Text('Keep editing'),
///       ),
///       StreamButton(
///         style: StreamButtonStyle.destructive,
///         onPressed: () => Navigator.pop(context, true),
///         child: const Text('Discard'),
///       ),
///     ],
///     child: const Text('Your edits will be lost.'),
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
    BoxConstraints? constraints,
    required Widget child,
  }) : props = .new(
         title: title,
         headerActions: headerActions,
         showCloseButton: showCloseButton,
         onClose: onClose,
         actions: actions,
         constraints: constraints,
         child: child,
       );

  /// The size the design gives a modal window.
  ///
  /// A maximum rather than a fixed size: the dialog shrinks with the window,
  /// and takes only the height its content needs.
  static const defaultConstraints = BoxConstraints(maxWidth: 720, maxHeight: 640);

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
    this.constraints,
    required this.child,
  });

  /// The dialog's title, drawn at the leading edge of the header.
  ///
  /// Typically a [Text]; the header provides its text style and keeps it to
  /// one line.
  final Widget? title;

  /// Buttons drawn in the header, before the close button.
  ///
  /// Typically [StreamButton.icon]s.
  final List<Widget> headerActions;

  /// Whether the header draws a close button after [headerActions].
  final bool showCloseButton;

  /// Called when the close button is pressed.
  ///
  /// Defaults to popping the dialog with no value.
  final VoidCallback? onClose;

  /// Buttons drawn in the footer, aligned to the trailing edge.
  ///
  /// An empty list draws no footer at all.
  final List<Widget> actions;

  /// The bounds of the dialog.
  ///
  /// Defaults to [StreamModalDialogThemeData.constraints], and then to
  /// [StreamModalDialog.defaultConstraints].
  final BoxConstraints? constraints;

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
    return StreamModalSurface(
      constraints: props.constraints,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamModalHeader(
            title: props.title,
            actions: [
              ...props.headerActions,
              if (props.showCloseButton) StreamModalCloseButton(onPressed: props.onClose),
            ],
          ),
          Flexible(child: props.child),
          if (props.actions.isNotEmpty) _ModalDialogFooter(actions: props.actions),
        ],
      ),
    );
  }
}

class _ModalDialogFooter extends StatelessWidget {
  const _ModalDialogFooter({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final style = resolveStreamModalDialogTheme(context).footerStyle!;

    return Padding(
      padding: style.padding!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: style.actionsSpacing!,
        children: actions,
      ),
    );
  }
}
