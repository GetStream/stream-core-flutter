import 'package:flutter/material.dart';

import '../../../theme/components/stream_modal_dialog_theme.dart';
import '../../../theme/primitives/stream_colors.dart';
import '../../../theme/primitives/stream_spacing.dart';
import '../../../theme/semantics/stream_color_scheme.dart';
import '../../../theme/semantics/stream_text_theme.dart';
import '../../../theme/stream_theme_extensions.dart';
import '../../../utils/device_segmentation.dart';
import '../../buttons/stream_button.dart';

// The design's maximum size for a modal window; it shrinks with the window.
const _kDefaultConstraints = BoxConstraints(maxWidth: 720, maxHeight: 640);

// The design's barrier blurs: `blur/50` on mobile and `blur/25` on the web.
const _kMobileBarrierBlurSigma = 25.0;
const _kWebBarrierBlurSigma = 12.5;

// The height of a header button, which the title row keeps even without one.
const _kHeaderTitleMinHeight = 40.0;

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
      // Material 3 skips its elevation tint only for exactly this value.
      surfaceTintColor: Colors.transparent,
      elevation: theme.elevation,
      shadowColor: theme.shadowColor,
      clipBehavior: Clip.antiAlias,
      insetPadding: theme.insetPadding,
      shape: theme.shape,
      alignment: Alignment.center,
      constraints: constraints ?? theme.constraints,
      child: child,
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
    this.titleNamesRoute = true,
    required this.actions,
  });

  /// The title, read out as a heading.
  final Widget? title;

  /// Whether the [title] names the route it is in for screen readers.
  final bool titleNamesRoute;

  /// The buttons at the trailing edge.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final style = resolveStreamModalDialogTheme(context).headerStyle!;

    return Padding(
      padding: style.padding!,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: style.spacing!,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: _kHeaderTitleMinHeight),
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle.merge(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.titleTextStyle,
                child: switch (title) {
                  final title? => Semantics(header: true, namesRoute: titleNamesRoute, child: title),
                  null => const SizedBox.shrink(),
                },
              ),
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
  /// Defaults to [Navigator.maybePop], which a [PopScope] can veto.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return StreamButton.icon(
      icon: Icon(context.streamIcons.xmark),
      style: StreamButtonStyle.secondary,
      type: StreamButtonType.ghost,
      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    );
  }
}

// Default theme values for [StreamModalDialog] and the modal parts.
class _StreamModalDialogThemeDefaults extends StreamModalDialogThemeData {
  _StreamModalDialogThemeDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamSpacing _spacing = _context.streamSpacing;
  late final bool _isDesktopOrWeb = isDesktopOrWeb(_context);

  @override
  Color get backgroundColor => _colorScheme.backgroundElevation1;

  @override
  double get elevation => _context.streamElevation.level4;

  @override
  Color get shadowColor => Theme.of(_context).colorScheme.shadow;

  @override
  ShapeBorder get shape => RoundedRectangleBorder(
    borderRadius: BorderRadius.all(_context.streamRadius.xl),
    // The 1px ring of the design's elevation-4 shadow.
    side: BorderSide(
      color: switch (_colorScheme.brightness) {
        Brightness.light => StreamColors.black5,
        Brightness.dark => _colorScheme.borderOpacityStrong,
      },
    ),
  );

  @override
  EdgeInsets get insetPadding => EdgeInsets.all(_spacing.xxl);

  @override
  BoxConstraints get constraints => _kDefaultConstraints;

  @override
  EdgeInsetsGeometry get contentPadding => EdgeInsets.zero;

  @override
  StreamModalDialogHeaderStyle get headerStyle => _StreamModalDialogHeaderStyleDefaults(_context);

  @override
  StreamModalDialogFooterStyle get footerStyle => _StreamModalDialogFooterStyleDefaults(_context);

  @override
  Color get barrierColor => _colorScheme.backgroundScrim;

  @override
  double get barrierBlurSigma => _isDesktopOrWeb ? _kWebBarrierBlurSigma : _kMobileBarrierBlurSigma;
}

class _StreamModalDialogHeaderStyleDefaults extends StreamModalDialogHeaderStyle {
  _StreamModalDialogHeaderStyleDefaults(this._context);

  final BuildContext _context;

  late final StreamSpacing _spacing = _context.streamSpacing;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final bool _isDesktopOrWeb = isDesktopOrWeb(_context);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(_isDesktopOrWeb ? _spacing.xl : _spacing.md);

  @override
  TextStyle get titleTextStyle => _textTheme.headingSm.copyWith(color: _context.streamColorScheme.textPrimary);

  @override
  double get spacing => _isDesktopOrWeb ? _spacing.md : _spacing.sm;

  @override
  double get actionsSpacing => _spacing.xs;
}

class _StreamModalDialogFooterStyleDefaults extends StreamModalDialogFooterStyle {
  _StreamModalDialogFooterStyleDefaults(this._context);

  final BuildContext _context;

  late final StreamSpacing _spacing = _context.streamSpacing;
  late final bool _isDesktopOrWeb = isDesktopOrWeb(_context);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(_isDesktopOrWeb ? _spacing.xl : _spacing.md);

  @override
  double get actionsSpacing => _spacing.xs;

  @override
  bool get expandActions => !_isDesktopOrWeb;
}
