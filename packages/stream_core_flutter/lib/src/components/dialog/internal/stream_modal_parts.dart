import 'package:flutter/material.dart';

import '../../../theme/components/stream_modal_dialog_theme.dart';
import '../../../theme/primitives/stream_spacing.dart';
import '../../../theme/semantics/stream_color_scheme.dart';
import '../../../theme/semantics/stream_text_theme.dart';
import '../../../theme/stream_theme_extensions.dart';
import '../../buttons/stream_button.dart';
import '../stream_modal_dialog.dart';

// The parts of a modal shared by `StreamModalDialog` and, later,
// `StreamModalWindow`: the surface, the header and its close button. They
// resolve their look from [StreamModalDialogTheme], so every modal shares one
// surface and one header and a modal only themes what it adds.

/// The blur the design gives the scrim behind a modal.
const kStreamModalScrimBlurSigma = 12.5;

/// Resolves the effective modal dialog theme at [context].
///
/// The result layers, from lowest to highest precedence, the built-in
/// defaults and the inherited [StreamModalDialogTheme]. Every field and every
/// field of [StreamModalDialogThemeData.headerStyle] and
/// [StreamModalDialogThemeData.footerStyle] is non-null.
StreamModalDialogThemeData resolveStreamModalDialogTheme(BuildContext context) {
  return _StreamModalDialogThemeDefaults(context).merge(context.streamModalDialogTheme);
}

/// The surface of a modal: an elevated card centered in the window and kept
/// away from its edges.
class StreamModalSurface extends StatelessWidget {
  /// Creates a modal surface.
  const StreamModalSurface({
    super.key,
    this.constraints,
    this.backgroundColor,
    required this.child,
  });

  /// The bounds of the surface.
  ///
  /// Defaults to [StreamModalDialogThemeData.constraints].
  final BoxConstraints? constraints;

  /// The color of the surface.
  ///
  /// Defaults to [StreamModalDialogThemeData.backgroundColor].
  final Color? backgroundColor;

  /// The surface's content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = resolveStreamModalDialogTheme(context);

    return Dialog(
      backgroundColor: backgroundColor ?? theme.backgroundColor,
      // Must be exactly `Colors.transparent`: Material 3 skips the elevation
      // tint only for that value. `StreamColors.transparent` is transparent
      // *white*, which Material treats as a real tint and blends in at the
      // surface's elevation, lifting the dark surface from #1c1c1c to ~#383838.
      surfaceTintColor: Colors.transparent,
      elevation: theme.elevation,
      clipBehavior: Clip.antiAlias,
      insetPadding: theme.insetPadding,
      shape: theme.shape,
      child: ConstrainedBox(constraints: constraints ?? theme.constraints!, child: child),
    );
  }
}

/// The header of a modal: a one-line title at the leading edge and a row of
/// actions at the trailing edge.
class StreamModalHeader extends StatelessWidget {
  /// Creates a modal header.
  const StreamModalHeader({
    super.key,
    required this.title,
    required this.actions,
  });

  /// The title, read out as a heading.
  final Widget? title;

  /// The buttons at the trailing edge.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final style = resolveStreamModalDialogTheme(context).headerStyle!;

    return Padding(
      padding: style.padding!,
      child: Row(
        spacing: style.spacing!,
        children: [
          Expanded(
            child: DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.titleTextStyle,
              child: switch (title) {
                final title? => Semantics(header: true, child: title),
                null => const SizedBox.shrink(),
              },
            ),
          ),
          if (actions.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: style.actionsSpacing!,
              children: actions,
            ),
        ],
      ),
    );
  }
}

/// The close button of a modal's header.
class StreamModalCloseButton extends StatelessWidget {
  /// Creates a close button.
  const StreamModalCloseButton({super.key, this.onPressed});

  /// Called when the button is pressed.
  ///
  /// Defaults to popping the modal with no value.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return StreamButton.icon(
      icon: Icon(context.streamIcons.xmark),
      style: StreamButtonStyle.secondary,
      type: StreamButtonType.ghost,
      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

// Default theme values for [StreamModalDialog] and the modal parts.
class _StreamModalDialogThemeDefaults extends StreamModalDialogThemeData {
  _StreamModalDialogThemeDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  Color get backgroundColor => _colorScheme.backgroundElevation1;

  @override
  double get elevation => _context.streamElevation.level4;

  @override
  ShapeBorder get shape => RoundedRectangleBorder(borderRadius: BorderRadius.all(_context.streamRadius.xl));

  @override
  EdgeInsets get insetPadding => EdgeInsets.all(_spacing.xxl);

  @override
  BoxConstraints get constraints => StreamModalDialog.defaultConstraints;

  @override
  StreamModalDialogHeaderStyle get headerStyle => _StreamModalDialogHeaderStyleDefaults(_context);

  @override
  StreamModalDialogFooterStyle get footerStyle => _StreamModalDialogFooterStyleDefaults(_context);

  @override
  Color get scrimColor => _colorScheme.backgroundScrim;

  @override
  double get scrimBlurSigma => kStreamModalScrimBlurSigma;
}

class _StreamModalDialogHeaderStyleDefaults extends StreamModalDialogHeaderStyle {
  _StreamModalDialogHeaderStyleDefaults(this._context);

  final BuildContext _context;

  late final StreamSpacing _spacing = _context.streamSpacing;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(_spacing.xl);

  @override
  TextStyle get titleTextStyle => _textTheme.headingSm.copyWith(color: _context.streamColorScheme.textPrimary);

  @override
  double get spacing => _spacing.md;

  @override
  double get actionsSpacing => _spacing.xs;
}

class _StreamModalDialogFooterStyleDefaults extends StreamModalDialogFooterStyle {
  _StreamModalDialogFooterStyleDefaults(this._context);

  final BuildContext _context;

  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(_spacing.xl);

  @override
  double get actionsSpacing => _spacing.xs;
}
