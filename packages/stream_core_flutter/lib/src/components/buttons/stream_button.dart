import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import 'internal/stream_button_defaults.dart';

/// A versatile button with support for multiple styles, types, and sizes.
///
/// [StreamButton] renders an arbitrary [Widget] as its [child], optionally
/// flanked by leading and/or trailing icons via [iconLeft] and [iconRight].
/// For a circular icon-only button, use the [StreamButton.icon] constructor.
///
/// The button adapts its appearance based on the combination of
/// [StreamButtonStyle], [StreamButtonType], and interaction state (hover,
/// pressed, disabled, selected). All visual states can be customized via
/// [StreamButtonTheme].
///
/// {@tool snippet}
///
/// Display a primary solid button:
///
/// ```dart
/// StreamButton(
///   onPressed: () => print('submitted'),
///   child: const Text('Submit'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Display a button with a leading icon:
///
/// ```dart
/// StreamButton(
///   iconLeft: const Icon(Icons.add),
///   onPressed: () => print('added'),
///   child: const Text('Add'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Display a selectable ghost button:
///
/// ```dart
/// StreamButton(
///   style: StreamButtonStyle.secondary,
///   type: StreamButtonType.ghost,
///   isSelected: isActive,
///   onPressed: () => toggleFilter(),
///   child: const Text('Filter'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamButton.icon], for a circular icon-only button.
///  * [StreamButtonTheme], for customizing button appearance.
///  * [StreamButtonStyle], for available style variants.
///  * [StreamButtonType], for available type variants.
///  * [StreamButtonSize], for available size variants.
class StreamButton extends StatelessWidget {
  /// Creates a button that displays [child], optionally flanked by leading
  /// and/or trailing icons ([iconLeft] and [iconRight]).
  ///
  /// Set [isFloating] to true for a floating button with a shadow.
  StreamButton({
    super.key,
    required Widget child,
    VoidCallback? onPressed,
    StreamButtonStyle style = .primary,
    StreamButtonType type = .solid,
    StreamButtonSize size = .medium,
    Widget? iconLeft,
    Widget? iconRight,
    bool? isFloating,
    bool? isSelected,
    bool autofocus = false,
    StreamButtonThemeStyle? themeStyle,
  }) : props = .new(
         child: child,
         onPressed: onPressed,
         style: style,
         type: type,
         size: size,
         iconLeft: iconLeft,
         iconRight: iconRight,
         isFloating: isFloating,
         isSelected: isSelected,
         autofocus: autofocus,
         themeStyle: themeStyle,
       );

  /// Creates a circular icon-only button that displays [icon].
  ///
  /// Set [isFloating] to true for a floating button with a shadow.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// StreamButton.icon(
  ///   icon: const Icon(Icons.add),
  ///   onPressed: () => print('added'),
  /// )
  /// ```
  /// {@end-tool}
  StreamButton.icon({
    super.key,
    required Widget icon,
    VoidCallback? onPressed,
    StreamButtonStyle style = .primary,
    StreamButtonType type = .solid,
    StreamButtonSize size = .medium,
    bool? isFloating,
    bool? isSelected,
    bool autofocus = false,
    String? tooltip,
    StreamButtonThemeStyle? themeStyle,
  }) : props = .new(
         onPressed: onPressed,
         style: style,
         type: type,
         size: size,
         iconLeft: icon,
         isFloating: isFloating,
         isSelected: isSelected,
         autofocus: autofocus,
         tooltip: tooltip,
         themeStyle: themeStyle,
       );

  /// The props controlling the appearance and behavior of this button.
  final StreamButtonProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).button;
    if (builder != null) return builder(context, props);
    return DefaultStreamButton(props: props);
  }
}

/// Properties for configuring a [StreamButton].
///
/// This class holds all the configuration options for a button,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// The presence of [child] determines the button's shape:
///
///  * When [child] is non-null, the button renders [child] flanked by
///    optional [iconLeft] and/or [iconRight] icons.
///  * When [child] is null, the button renders as a circular icon-only
///    button using [iconLeft] as its sole icon (see [StreamButton.icon]).
///
/// See also:
///
///  * [StreamButton], which uses these properties.
///  * [DefaultStreamButton], the default implementation.
class StreamButtonProps {
  /// Creates properties for a button.
  const StreamButtonProps({
    this.child,
    this.onPressed,
    this.style = .primary,
    this.type = .solid,
    this.size = .medium,
    this.iconLeft,
    this.iconRight,
    this.isFloating,
    this.isSelected,
    this.autofocus = false,
    this.tooltip,
    this.themeStyle,
  });

  /// The main content widget displayed inside the button.
  ///
  /// When null, the button renders as a circular icon-only button using
  /// [iconLeft] as its sole icon (see [StreamButton.icon]).
  final Widget? child;

  /// Called when the button is pressed.
  ///
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// The visual style variant of the button.
  ///
  /// Determines the color scheme used (primary, secondary, destructive).
  final StreamButtonStyle style;

  /// The type variant of the button.
  ///
  /// Controls the visual weight (solid, outline, ghost).
  final StreamButtonType type;

  /// The size of the button.
  ///
  /// For regular buttons, only the height is fixed and the width sizes to fit
  /// the content. For icon buttons, both dimensions are fixed.
  ///
  /// This size is still constrained by [StreamButtonThemeStyle.minimumSize]
  /// and [StreamButtonThemeStyle.maximumSize].
  final StreamButtonSize size;

  /// The icon displayed at the leading edge of the button, before [child].
  ///
  /// When [child] is null, this is the sole icon rendered by a circular
  /// icon-only button (see [StreamButton.icon]).
  final Widget? iconLeft;

  /// The icon displayed at the trailing edge of the button, after [child].
  final Widget? iconRight;

  /// Whether the button has a floating (elevated) appearance.
  ///
  /// When true, the button gains elevation and a background fill
  /// for outline and ghost types.
  /// When false or null, the button is not floating.
  final bool? isFloating;

  /// Whether the button is in a selected state.
  ///
  /// When true, the button displays selected styling.
  /// When false or null, the button is not selected.
  final bool? isSelected;

  /// Whether the button should request focus when first mounted.
  ///
  /// When true, the button takes input focus as soon as it is inserted
  /// into the tree.
  /// When false, the button uses normal focus traversal.
  final bool autofocus;

  /// Text shown in a [Tooltip] on hover / long-press, and used as the
  /// button's accessibility label.
  ///
  /// Only honoured by [StreamButton.icon]; the regular [StreamButton]
  /// derives its label from its [child].
  /// When null, the icon button has no tooltip.
  final String? tooltip;

  /// Per-instance style overrides for this button.
  ///
  /// These properties take precedence over the inherited [StreamButtonTheme]
  /// values for this specific button instance.
  final StreamButtonThemeStyle? themeStyle;
}

/// The color scheme variant for a [StreamButton].
///
/// Each style maps to a distinct set of colors defined in the theme.
enum StreamButtonStyle {
  /// Uses the brand/accent color scheme.
  primary,

  /// Uses the neutral/surface color scheme.
  secondary,

  /// Uses the error/danger color scheme.
  destructive,
}

/// The visual weight variant for a [StreamButton].
///
/// Controls how prominently the button is displayed.
enum StreamButtonType {
  /// Filled background with high visual emphasis.
  solid,

  /// Bordered with transparent background for medium emphasis.
  outline,

  /// No border or background for low emphasis.
  ghost,
}

/// Predefined sizes for [StreamButton].
///
/// Each size corresponds to a specific dimension in logical pixels.
///
/// See also:
///
///  * [StreamButtonThemeData], for setting global button styles.
enum StreamButtonSize {
  /// Small button (32px).
  small(32),

  /// Medium button (40px).
  medium(40),

  /// Large button (48px).
  large(48);

  /// Constructs a [StreamButtonSize] with the given dimension.
  const StreamButtonSize(this.value);

  /// The dimension of the button in logical pixels.
  final double value;
}

/// Default implementation of [StreamButton].
///
/// Renders the button using [ElevatedButton] with theme-aware styling and
/// state-based visual feedback. Uses [WidgetStatesController] to manage
/// the selected state.
class DefaultStreamButton extends StatefulWidget {
  /// Creates a default button.
  const DefaultStreamButton({super.key, required this.props});

  /// The props controlling the appearance and behavior of this button.
  final StreamButtonProps props;

  @override
  State<DefaultStreamButton> createState() => _DefaultStreamButtonState();
}

class _DefaultStreamButtonState extends State<DefaultStreamButton> {
  StreamButtonProps get props => widget.props;
  late final WidgetStatesController _statesController;

  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController(
      <WidgetState>{if (props.isSelected ?? false) WidgetState.selected},
    );
  }

  @override
  void didUpdateWidget(DefaultStreamButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _statesController.update(WidgetState.selected, props.isSelected ?? false);
  }

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final themeStyle = resolveStreamButtonThemeStyle(
      context,
      style: props.style,
      type: props.type,
      isFloating: props.isFloating ?? false,
      themeStyle: props.themeStyle,
    );

    final buttonSize = props.size.value;
    final isIconButton = props.child == null;

    final effectiveFixedSize =
        themeStyle.fixedSize ??
        WidgetStatePropertyAll(isIconButton ? Size.square(buttonSize) : Size.fromHeight(buttonSize));
    final effectivePadding =
        themeStyle.padding ??
        switch (isIconButton) {
          true => const WidgetStatePropertyAll(EdgeInsets.zero),
          false => WidgetStatePropertyAll(.symmetric(horizontal: spacing.md)),
        };

    Widget button = Semantics(
      selected: props.isSelected,
      child: ElevatedButton(
        autofocus: props.autofocus,
        onPressed: props.onPressed,
        statesController: _statesController,
        style: ButtonStyle(
          tapTargetSize: themeStyle.tapTargetSize,
          visualDensity: .standard,
          textStyle: themeStyle.textStyle,
          iconSize: themeStyle.iconSize,
          elevation: themeStyle.elevation,
          backgroundColor: themeStyle.backgroundColor,
          foregroundColor: themeStyle.foregroundColor,
          iconColor: themeStyle.foregroundColor,
          overlayColor: themeStyle.overlayColor,
          fixedSize: effectiveFixedSize,
          minimumSize: themeStyle.minimumSize,
          maximumSize: themeStyle.maximumSize,
          padding: effectivePadding,
          alignment: themeStyle.alignment,
          shape: themeStyle.shape,
          side: switch (themeStyle.borderColor) {
            final color? => .resolveWith(
              (states) {
                final resolvedColor = color.resolve(states);
                if (resolvedColor == null) return null;
                return BorderSide(color: resolvedColor);
              },
            ),
            _ => null,
          },
        ),
        child: switch (isIconButton) {
          true => props.iconLeft,
          false => Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: spacing.xs,
            children: [
              ?props.iconLeft,
              if (props.child case final child?) Flexible(child: child),
              ?props.iconRight,
            ],
          ),
        },
      ),
    );

    if (props.tooltip case final tooltip?) {
      button = Tooltip(message: tooltip, child: button);
    }

    return MergeSemantics(child: button);
  }
}
