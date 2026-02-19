import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A versatile button with support for multiple styles, types, and sizes.
///
/// [StreamButton] renders a label-based button or an icon-only button via the
/// [StreamButton.icon] constructor. The button adapts its appearance based on
/// the combination of [StreamButtonStyle], [StreamButtonType], and interaction
/// state (hover, pressed, disabled, selected).
///
/// All visual states can be customized via [StreamButtonTheme].
///
/// {@tool snippet}
///
/// Display a primary solid button:
///
/// ```dart
/// StreamButton(
///   label: 'Submit',
///   onTap: () => print('submitted'),
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
///   label: 'Filter',
///   style: StreamButtonStyle.secondary,
///   type: StreamButtonType.ghost,
///   isSelected: isActive,
///   onTap: () => toggleFilter(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamButtonTheme], for customizing button appearance.
///  * [StreamButtonStyle], for available style variants.
///  * [StreamButtonType], for available type variants.
///  * [StreamButtonSize], for available size variants.
class StreamButton extends StatelessWidget {
  /// Creates a label button with optional leading and trailing icons.
  StreamButton({
    super.key,
    required String label,
    VoidCallback? onTap,
    StreamButtonStyle style = .primary,
    StreamButtonType type = .solid,
    StreamButtonSize size = .medium,
    IconData? iconLeft,
    IconData? iconRight,
    bool? isSelected,
  }) : props = .new(
         label: label,
         onTap: onTap,
         style: style,
         type: type,
         size: size,
         iconLeft: iconLeft,
         iconRight: iconRight,
         isSelected: isSelected,
       );

  /// Creates a circular icon-only button.
  ///
  /// Set [isFloating] to true for an floating button with a shadow.
  StreamButton.icon({
    super.key,
    VoidCallback? onTap,
    StreamButtonStyle style = .primary,
    StreamButtonType type = .solid,
    StreamButtonSize size = .medium,
    IconData? icon,
    bool? isFloating,
    bool? isSelected,
  }) : props = .new(
         onTap: onTap,
         style: style,
         type: type,
         size: size,
         iconLeft: icon,
         isFloating: isFloating,
         isSelected: isSelected,
       );

  /// The props controlling the appearance and behavior of this button.
  final StreamButtonProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.maybeOf(context)?.button;
    if (builder != null) return builder(context, props);
    return DefaultStreamButton(props: props);
  }
}

/// Properties for configuring a [StreamButton].
///
/// This class holds all the configuration options for a button,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamButton], which uses these properties.
///  * [DefaultStreamButton], the default implementation.
class StreamButtonProps {
  /// Creates properties for a button.
  const StreamButtonProps({
    this.label,
    this.onTap,
    this.style = .primary,
    this.type = .solid,
    this.size = .medium,
    this.iconLeft,
    this.iconRight,
    this.isFloating,
    this.isSelected,
  });

  /// The label text displayed on the button.
  ///
  /// If null, the button is rendered as a circular icon-only button.
  final String? label;

  /// Called when the button is pressed.
  ///
  /// If null, the button will be disabled.
  final VoidCallback? onTap;

  /// The visual style variant of the button.
  ///
  /// Determines the color scheme used (primary, secondary, destructive).
  final StreamButtonStyle style;

  /// The type variant of the button.
  ///
  /// Controls the visual weight (solid, outline, ghost).
  final StreamButtonType type;

  /// The size of the button.
  final StreamButtonSize size;

  /// The icon displayed on the left side of the label.
  final IconData? iconLeft;

  /// The icon displayed on the right side of the label.
  final IconData? iconRight;

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
  large(48)
  ;

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
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final buttonTheme = context.streamButtonTheme;

    final themeStyle = switch ((props.style, props.type)) {
      (.primary, .solid) => buttonTheme.primary?.solid,
      (.primary, .outline) => buttonTheme.primary?.outline,
      (.primary, .ghost) => buttonTheme.primary?.ghost,
      (.secondary, .solid) => buttonTheme.secondary?.solid,
      (.secondary, .outline) => buttonTheme.secondary?.outline,
      (.secondary, .ghost) => buttonTheme.secondary?.ghost,
      (.destructive, .solid) => buttonTheme.destructive?.solid,
      (.destructive, .outline) => buttonTheme.destructive?.outline,
      (.destructive, .ghost) => buttonTheme.destructive?.ghost,
    };

    final isFloating = props.isFloating ?? false;
    final defaults = switch ((props.style, props.type)) {
      (.primary, .solid) => _PrimarySolidDefaults(context, isFloating: isFloating),
      (.primary, .outline) => _PrimaryOutlineDefaults(context, isFloating: isFloating),
      (.primary, .ghost) => _PrimaryGhostDefaults(context, isFloating: isFloating),
      (.secondary, .solid) => _SecondarySolidDefaults(context, isFloating: isFloating),
      (.secondary, .outline) => _SecondaryOutlineDefaults(context, isFloating: isFloating),
      (.secondary, .ghost) => _SecondaryGhostDefaults(context, isFloating: isFloating),
      (.destructive, .solid) => _DestructiveSolidDefaults(context, isFloating: isFloating),
      (.destructive, .outline) => _DestructiveOutlineDefaults(context, isFloating: isFloating),
      (.destructive, .ghost) => _DestructiveGhostDefaults(context, isFloating: isFloating),
    };

    final effectiveBackgroundColor = themeStyle?.backgroundColor ?? defaults.backgroundColor;
    final effectiveForegroundColor = themeStyle?.foregroundColor ?? defaults.foregroundColor;
    final effectiveBorderColor = themeStyle?.borderColor ?? defaults.borderColor;
    final effectiveOverlayColor = themeStyle?.overlayColor ?? defaults.overlayColor;
    final effectiveElevation = themeStyle?.elevation ?? defaults.elevation;
    final effectiveIconSize = themeStyle?.iconSize ?? defaults.iconSize;

    final buttonSize = props.size.value;
    final isIconButton = props.label == null;

    return ElevatedButton(
      onPressed: props.onTap,
      statesController: _statesController,
      style: ButtonStyle(
        tapTargetSize: .padded,
        visualDensity: .standard,
        iconSize: effectiveIconSize,
        elevation: effectiveElevation,
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveForegroundColor,
        overlayColor: effectiveOverlayColor,
        minimumSize: .all(.square(buttonSize)),
        maximumSize: .all(isIconButton ? .square(buttonSize) : .fromHeight(buttonSize)),
        padding: .all(isIconButton ? .zero : .symmetric(horizontal: spacing.md)),
        side: switch (effectiveBorderColor) {
          final color? => .resolveWith(
            (states) {
              final resolvedColor = color.resolve(states);
              if (resolvedColor == null) return null;
              return BorderSide(color: resolvedColor);
            },
          ),
          _ => null,
        },
        shape: switch (props.label) {
          null => .all(const CircleBorder()),
          _ => .all(RoundedRectangleBorder(borderRadius: .all(radius.max))),
        },
      ),
      child: switch (isIconButton) {
        true => Icon(props.iconLeft),
        false => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: spacing.xs,
          children: [
            if (props.iconLeft case final iconLeft?) Icon(iconLeft),
            if (props.label case final label?) Flexible(child: Text(label)),
            if (props.iconRight case final iconRight?) Icon(iconRight),
          ],
        ),
      },
    );
  }
}

// -- Shared defaults --------------------------------------------------------

mixin _SharedButtonDefaults on StreamButtonThemeStyle {
  bool get isFloating;
  StreamColorScheme get colorScheme;

  @override
  WidgetStateProperty<double> get iconSize => const WidgetStatePropertyAll(20);

  @override
  WidgetStateProperty<Color> get overlayColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return colorScheme.statePressed;
    if (states.contains(WidgetState.hovered)) return colorScheme.stateHover;
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<double> get elevation => WidgetStateProperty.resolveWith((states) {
    if (!isFloating) return 0;
    if (states.contains(WidgetState.disabled)) return 0.0;
    if (states.contains(WidgetState.pressed)) return 6.0;
    if (states.contains(WidgetState.hovered)) return 8.0;
    return 6.0;
  });
}

// -- Primary defaults -------------------------------------------------------

// Default style for primary solid buttons.
class _PrimarySolidDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _PrimarySolidDefaults(
    this.context, {
    required this.isFloating,
  }) : colorScheme = context.streamColorScheme;

  final BuildContext context;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color>? get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.backgroundDisabled;
    final base = colorScheme.accentPrimary;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.stateSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color>? get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.textOnAccent;
  });
}

// Default style for primary outline buttons.
class _PrimaryOutlineDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _PrimaryOutlineDefaults(
    this.context, {
    required this.isFloating,
  }) : colorScheme = context.streamColorScheme;

  final BuildContext context;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color>? get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return StreamColors.transparent;
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.stateSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color>? get borderColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.borderDisabled;
    return colorScheme.brand.shade200;
  });

  @override
  WidgetStateProperty<Color>? get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.accentPrimary;
  });
}

// Default style for primary ghost buttons.
class _PrimaryGhostDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _PrimaryGhostDefaults(
    this.context, {
    required this.isFloating,
  }) : colorScheme = context.streamColorScheme;

  final BuildContext context;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color>? get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return StreamColors.transparent;
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.stateSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color>? get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.accentPrimary;
  });
}

// -- Secondary defaults -----------------------------------------------------

// Default style for secondary solid buttons.
class _SecondarySolidDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _SecondarySolidDefaults(
    this.context, {
    required this.isFloating,
  }) : colorScheme = context.streamColorScheme;

  final BuildContext context;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color>? get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.backgroundDisabled;
    final base = colorScheme.backgroundSurface;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.stateSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color>? get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.textPrimary;
  });
}

// Default style for secondary outline buttons.
class _SecondaryOutlineDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _SecondaryOutlineDefaults(
    this.context, {
    required this.isFloating,
  }) : colorScheme = context.streamColorScheme;

  final BuildContext context;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color>? get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return StreamColors.transparent;
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.stateSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color>? get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.textPrimary;
  });

  @override
  WidgetStateProperty<Color>? get borderColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.borderDisabled;
    return colorScheme.borderDefault;
  });
}

// Default style for secondary ghost buttons.
class _SecondaryGhostDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _SecondaryGhostDefaults(
    this.context, {
    required this.isFloating,
  }) : colorScheme = context.streamColorScheme;

  final BuildContext context;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color>? get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return StreamColors.transparent;
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.stateSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color>? get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.textPrimary;
  });
}

// -- Destructive defaults ---------------------------------------------------

// Default style for destructive solid buttons.
class _DestructiveSolidDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _DestructiveSolidDefaults(
    this.context, {
    required this.isFloating,
  }) : colorScheme = context.streamColorScheme;

  final BuildContext context;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color>? get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.backgroundDisabled;
    final base = colorScheme.accentError;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.stateSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color>? get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.textOnAccent;
  });
}

// Default style for destructive outline buttons.
class _DestructiveOutlineDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _DestructiveOutlineDefaults(
    this.context, {
    required this.isFloating,
  }) : colorScheme = context.streamColorScheme;

  final BuildContext context;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color>? get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return StreamColors.transparent;
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.stateSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color>? get borderColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.borderDisabled;
    return colorScheme.accentError;
  });

  @override
  WidgetStateProperty<Color>? get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.accentError;
  });
}

// Default style for destructive ghost buttons.
class _DestructiveGhostDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _DestructiveGhostDefaults(
    this.context, {
    required this.isFloating,
  }) : colorScheme = context.streamColorScheme;

  final BuildContext context;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color>? get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return StreamColors.transparent;
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.stateSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color>? get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.accentError;
  });
}
