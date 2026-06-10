import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/components/stream_snackbar_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../buttons/stream_button.dart';
import '../common/stream_loading_spinner.dart';

part 'stream_snackbar_messenger.dart';

/// Variants of [StreamSnackbar].
///
/// Each variant maps to a leading visual and a default auto-dismiss
/// policy. See [StreamSnackbar.duration] for the dismissal rules.
///
/// See also:
///
///  * [StreamSnackbar.variant], which selects one of these variants.
enum StreamSnackbarVariant {
  /// Neutral feedback with no leading icon.
  neutral,

  /// Positive confirmation with a leading checkmark.
  success,

  /// Failure or destructive outcome with a leading exclamation icon.
  error,

  /// In-progress operation with a leading spinner.
  ///
  /// Defaults to a persistent display until explicitly dismissed.
  loading,
}

/// An action button rendered at the trailing end of a [StreamSnackbar].
///
/// Pressing the action runs [onPressed] and dismisses the snackbar with
/// [StreamSnackbarClosedReason.action].
///
/// {@tool snippet}
///
/// An undo affordance after a destructive action:
///
/// ```dart
/// StreamSnackbarAction(
///   label: const Text('Undo'),
///   onPressed: () => restore(messageId),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSnackbar.action], the field that holds this value.
@immutable
class StreamSnackbarAction {
  /// Creates an action with a label and a press handler.
  const StreamSnackbarAction({
    required this.label,
    required this.onPressed,
  });

  /// The action's label.
  ///
  /// Typically a [Text]; the snackbar wraps it in a [DefaultTextStyle]
  /// that inherits the foreground colour.
  final Widget label;

  /// Called when the user presses the action button.
  ///
  /// After this callback runs the snackbar is auto-dismissed with
  /// [StreamSnackbarClosedReason.action].
  final VoidCallback onPressed;
}

/// A transient, pill-shaped feedback container.
///
/// Pass an instance to [StreamSnackbarMessenger.show] (looked up
/// via [StreamSnackbarMessenger.of] in the convenience path, or held directly
/// for explicit ownership). The call returns a [StreamSnackbarController]
/// for awaiting dismissal and closing programmatically.
///
/// Visual styling is themable via [StreamSnackbarStyle]; per-app rendering
/// is overridable via [StreamComponentBuilders.snackbar].
///
/// {@tool snippet}
///
/// Show a brief confirmation via the scope convenience:
///
/// ```dart
/// StreamSnackbarMessenger.of(context).show(
///   const StreamSnackbar(message: Text('Message sent')),
/// );
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Pair a variant with an action and await the result:
///
/// ```dart
/// final controller = StreamSnackbarMessenger.of(context).show(
///   StreamSnackbar(
///     message: const Text('Message deleted'),
///     variant: StreamSnackbarVariant.success,
///     action: StreamSnackbarAction(label: const Text('Undo'), onPressed: undo),
///   ),
/// );
/// if (await controller.closed == StreamSnackbarClosedReason.timeout) {
///   commitDelete();
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSnackbarController], the handle returned from `show`.
///  * [StreamSnackbarMessenger], the queue owner.
///  * [StreamSnackbarStyle], for visual customization.
///  * [StreamSnackbarVariant], which drives the leading icon and default
///    duration.
class StreamSnackbar extends StatelessWidget {
  /// Creates a snackbar.
  StreamSnackbar({
    super.key,
    required Widget message,
    StreamSnackbarVariant variant = .neutral,
    StreamSnackbarAction? action,
    Duration? duration,
    DismissDirection? dismissDirection,
  }) : props = .new(
         message: message,
         variant: variant,
         action: action,
         duration: duration,
         dismissDirection: dismissDirection,
       );

  /// The properties that configure this snackbar.
  final StreamSnackbarProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).snackbar;
    if (builder != null) return builder(context, props);
    return DefaultStreamSnackbar(props: props);
  }
}

/// Properties for configuring a [StreamSnackbar].
///
/// See also:
///
///  * [StreamSnackbar], which uses these properties.
class StreamSnackbarProps {
  /// Creates properties for a snackbar.
  const StreamSnackbarProps({
    required this.message,
    this.variant = .neutral,
    this.action,
    this.duration,
    this.dismissDirection,
  });

  /// The message displayed inside the snackbar.
  ///
  /// Typically a [Text]; the snackbar wraps it in a [DefaultTextStyle]
  /// that resolves the foreground colour and clips to a single line.
  final Widget message;

  /// The visual variant.
  ///
  /// Drives the leading icon and, for [StreamSnackbarVariant.loading], the
  /// default persistent duration.
  final StreamSnackbarVariant variant;

  /// An optional trailing action button.
  final StreamSnackbarAction? action;

  /// How long the snackbar remains on screen before auto-dismissing.
  ///
  /// When null, follows the design system's auto-dismiss rules:
  ///  * [StreamSnackbarVariant.loading] is persistent.
  ///  * [StreamSnackbarVariant.error] with an action is persistent.
  ///  * Otherwise, a snackbar with an [action] lingers 10 s; a snackbar
  ///    without an action auto-dismisses after 5 s.
  final Duration? duration;

  /// Direction the user can swipe to dismiss this snackbar.
  ///
  /// Overrides [StreamSnackbarStyle.dismissDirection]. Set to
  /// [DismissDirection.none] to disable swipe-dismissal entirely. When
  /// null on both, defaults to [DismissDirection.down].
  final DismissDirection? dismissDirection;
}

/// The default implementation of [StreamSnackbar].
///
/// See also:
///
///  * [StreamSnackbar], the public API widget.
///  * [StreamSnackbarProps], which configures this widget.
class DefaultStreamSnackbar extends StatelessWidget {
  /// Creates a default snackbar with the given [props].
  const DefaultStreamSnackbar({super.key, required this.props});

  /// The properties that configure this snackbar.
  final StreamSnackbarProps props;

  @override
  Widget build(BuildContext context) {
    final style = context.streamSnackbarTheme.style;
    final defaults = _StreamSnackbarDefaults(context);
    final spacing = context.streamSpacing;

    final effectiveBackgroundColor = style?.backgroundColor ?? defaults.backgroundColor;
    final effectiveForegroundColor = style?.foregroundColor ?? defaults.foregroundColor;
    final effectiveElevation = style?.elevation ?? defaults.elevation;

    final effectiveSide = style?.side ?? defaults.side;
    final effectiveShape = (style?.shape ?? defaults.shape).copyWith(side: effectiveSide);

    final effectivePadding = style?.padding ?? defaults.padding;
    final effectiveConstraints = style?.constraints ?? defaults.constraints;
    final effectiveTextStyle = (style?.textStyle ?? defaults.textStyle).copyWith(color: effectiveForegroundColor);
    final effectiveActionStyle = style?.actionStyle ?? defaults.actionStyle;

    final variant = props.variant;
    final hasLeading = variant != StreamSnackbarVariant.neutral;

    return Semantics(
      container: true,
      liveRegion: true,
      onDismiss: () => StreamSnackbarMessenger.maybeOf(context)?.removeCurrent(),
      child: ConstrainedBox(
        constraints: effectiveConstraints,
        child: Material(
          shape: effectiveShape,
          elevation: effectiveElevation,
          color: effectiveBackgroundColor,
          child: Padding(
            padding: effectivePadding,
            child: Row(
              mainAxisSize: .min,
              spacing: spacing.xxs,
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: hasLeading ? spacing.xxs : spacing.xs,
                      end: spacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: .min,
                      spacing: spacing.xs,
                      children: [
                        ?_buildLeading(context, variant, effectiveForegroundColor),
                        Flexible(
                          child: DefaultTextStyle(
                            maxLines: 1,
                            style: effectiveTextStyle,
                            overflow: TextOverflow.ellipsis,
                            child: props.message,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (props.action case final action?)
                  _SnackbarActionButton(
                    action: action,
                    themeStyle: effectiveActionStyle,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, StreamSnackbarVariant variant, Color iconColor) {
    final icons = context.streamIcons;
    return switch (variant) {
      .neutral => null,
      .success => Icon(icons.checkmark, size: 20, color: iconColor),
      .error => Icon(icons.exclamationCircleFill, size: 20, color: iconColor),
      .loading => StreamLoadingSpinner(
        size: .sm,
        color: iconColor,
        backgroundColor: StreamColors.transparent,
        trackColor: iconColor.withValues(alpha: 0.32),
      ),
    };
  }
}

// Inline trailing action button. Tracks `_handled` so a rapid double-tap
// during the exit animation only fires the callback once and only sends
// one .action dismissal.
class _SnackbarActionButton extends StatefulWidget {
  const _SnackbarActionButton({
    required this.action,
    this.themeStyle,
  });

  final StreamSnackbarAction action;
  final StreamButtonThemeStyle? themeStyle;

  @override
  State<_SnackbarActionButton> createState() => _SnackbarActionButtonState();
}

class _SnackbarActionButtonState extends State<_SnackbarActionButton> {
  var _handled = false;

  void _onPressed() {
    if (_handled) return;
    setState(() => _handled = true);
    final messenger = StreamSnackbarMessenger.maybeOf(context);
    try {
      widget.action.onPressed();
    } finally {
      messenger?.hideCurrent(StreamSnackbarClosedReason.action);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamButton(
      onPressed: _handled ? null : _onPressed,
      size: StreamButtonSize.small,
      type: StreamButtonType.outline,
      themeStyle: widget.themeStyle,
      child: widget.action.label,
    );
  }
}

class _StreamSnackbarDefaults extends StreamSnackbarStyle {
  _StreamSnackbarDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamRadius _radius = _context.streamRadius;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  double get elevation => 3;

  @override
  TextStyle get textStyle => _textTheme.captionDefault;

  @override
  Color get backgroundColor => _colorScheme.backgroundInverse;

  @override
  Color get foregroundColor => _colorScheme.textOnInverse;

  @override
  BoxConstraints get constraints => const BoxConstraints(maxWidth: 370, minHeight: 48);

  @override
  OutlinedBorder get shape => RoundedSuperellipseBorder(borderRadius: .all(_radius.xxxl));

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.symmetric(horizontal: _spacing.xs);

  @override
  EdgeInsetsGeometry get margin => EdgeInsets.symmetric(horizontal: _spacing.md, vertical: _spacing.sm);

  @override
  StreamButtonThemeStyle get actionStyle => StreamButtonThemeStyle.from(
    foregroundColor: foregroundColor,
    borderColor: foregroundColor,
    hoveredOverlayColor: foregroundColor.withValues(alpha: 0.08),
    pressedOverlayColor: foregroundColor.withValues(alpha: 0.16),
  );
}
