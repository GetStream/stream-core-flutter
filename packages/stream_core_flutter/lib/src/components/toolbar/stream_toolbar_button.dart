import 'package:flutter/widgets.dart';

import '../../theme/components/stream_button_theme.dart';
import '../buttons/stream_button.dart';
import 'stream_toolbar_scope.dart';

/// A button that adapts to its enclosing Stream toolbar
/// ([StreamAppBar] / [StreamBottomAppBar]).
///
/// Outlined and elevated when the bar floats, ghost when it's docked.
///
/// Suitable for actions placed in a toolbar slot (the leading back affordance, a
/// trailing text action like _Edit_, footer actions) so they match the bar
/// without each caller styling them by hand.
///
/// Mirrors [StreamButton]: the shape is determined by the presence of [child] —
/// a labelled button when [child] is non-null, and a circular icon-only button
/// (via [StreamToolbarButton.icon]) when it is null. Every [StreamButton] knob
/// is available except `type` and `isFloating`, which the toolbar sets.
///
/// {@tool snippet}
///
/// Place a labelled action in a toolbar slot — it picks up the bar's floating
/// or docked look automatically:
///
/// ```dart
/// StreamAppBar(
///   title: const Text('Profile'),
///   trailing: StreamToolbarButton(
///     onPressed: _startEditing,
///     child: const Text('Edit'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamToolbarButton.icon], for a circular icon-only button.
///  * [StreamToolbarScope], which provides the behaviour this button reads.
///  * [StreamButton], the underlying button this configures.
///  * [StreamAppBar] / [StreamBottomAppBar], the toolbars whose slots host this
///    button.
class StreamToolbarButton extends StatelessWidget {
  /// Creates a labelled toolbar button displaying [child], optionally flanked
  /// by [iconLeft] and/or [iconRight].
  const StreamToolbarButton({
    super.key,
    required Widget this.child,
    this.iconLeft,
    this.iconRight,
    this.onPressed,
    this.style = .secondary,
    this.size = .medium,
    this.isSelected,
    this.autofocus = false,
    this.themeStyle,
  }) : tooltip = null;

  /// Creates a circular icon-only toolbar button displaying [icon].
  const StreamToolbarButton.icon({
    super.key,
    required Widget icon,
    this.onPressed,
    this.style = .secondary,
    this.size = .medium,
    this.isSelected,
    this.autofocus = false,
    this.tooltip,
    this.themeStyle,
  }) : child = null,
       iconLeft = icon,
       iconRight = null;

  /// The label rendered by the button.
  ///
  /// When null, the button renders as a circular icon-only button using
  /// [iconLeft] as its sole icon (see [StreamToolbarButton.icon]).
  final Widget? child;

  /// The icon rendered before [child], or the sole icon of an icon-only button.
  final Widget? iconLeft;

  /// The icon rendered after [child]. Only honoured by a labelled button.
  final Widget? iconRight;

  /// Called when the button is pressed.
  ///
  /// When null, the button is rendered disabled.
  final VoidCallback? onPressed;

  /// The color-scheme variant of the button.
  ///
  /// Defaults to [StreamButtonStyle.secondary].
  final StreamButtonStyle style;

  /// The size of the button.
  ///
  /// Defaults to [StreamButtonSize.medium].
  final StreamButtonSize size;

  /// Whether the button is in a selected state.
  ///
  /// When true, the button displays selected styling.
  /// When false or null, the button is not selected.
  final bool? isSelected;

  /// Whether the button should request focus when first mounted.
  ///
  /// Defaults to `false`.
  final bool autofocus;

  /// Tooltip and accessibility label for the icon-only variant.
  ///
  /// Ignored by a labelled button, which derives its label from [child].
  final String? tooltip;

  /// Per-instance style overrides for this button.
  ///
  /// These properties take precedence over the inherited [StreamButtonTheme]
  /// values for this specific button instance.
  final StreamButtonThemeStyle? themeStyle;

  @override
  Widget build(BuildContext context) {
    // The floating look is cosmetic, so degrade to the docked style outside a
    // toolbar rather than crashing; assert to flag the likely misuse in debug.
    final behavior = StreamToolbarScope.maybeOf(context);
    assert(
      behavior != null,
      'StreamToolbarButton is meant for a Stream toolbar slot; it falls back to '
      'the docked style elsewhere.',
    );
    final isFloating = behavior?.isFloating ?? false;
    final type = isFloating ? StreamButtonType.outline : StreamButtonType.ghost;

    if (child case final child?) {
      return StreamButton(
        type: type,
        isFloating: isFloating,
        style: style,
        size: size,
        isSelected: isSelected,
        autofocus: autofocus,
        themeStyle: themeStyle,
        iconLeft: iconLeft,
        iconRight: iconRight,
        onPressed: onPressed,
        child: child,
      );
    }

    return StreamButton.icon(
      type: type,
      isFloating: isFloating,
      style: style,
      size: size,
      isSelected: isSelected,
      autofocus: autofocus,
      tooltip: tooltip,
      themeStyle: themeStyle,
      icon: iconLeft!,
      onPressed: onPressed,
    );
  }
}
