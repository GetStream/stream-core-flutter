import 'package:flutter/material.dart';

import '../../../theme/components/stream_button_theme.dart';
import '../../../theme/primitives/stream_colors.dart';
import '../../../theme/primitives/stream_radius.dart';
import '../../../theme/semantics/stream_color_scheme.dart';
import '../../../theme/semantics/stream_text_theme.dart';
import '../../../theme/stream_theme_extensions.dart';
import '../stream_button.dart';

/// Resolves the effective style for a button of the given [style] and [type].
///
/// The result layers, from lowest to highest precedence, the built-in defaults
/// for the variant, the inherited [StreamButtonTheme], and [themeStyle].
///
/// Components that compose [StreamButton] use this to paint surfaces that have
/// to match the buttons they contain, such as the shared background behind the
/// two halves of a split button.
///
/// [StreamButtonThemeStyle.padding] and [StreamButtonThemeStyle.fixedSize] are
/// left as-is; both depend on the button's size and shape, which callers
/// resolve themselves.
StreamButtonThemeStyle resolveStreamButtonThemeStyle(
  BuildContext context, {
  required StreamButtonStyle style,
  required StreamButtonType type,
  required bool isFloating,
  StreamButtonThemeStyle? themeStyle,
}) {
  final buttonTheme = context.streamButtonTheme;
  final inheritedStyle = switch ((style, type)) {
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

  final defaults = switch ((style, type)) {
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

  return defaults.merge(inheritedStyle?.merge(themeStyle) ?? themeStyle);
}

// -- Shared defaults --------------------------------------------------------

mixin _SharedButtonDefaults on StreamButtonThemeStyle {
  BuildContext get context;
  bool get isFloating;
  StreamRadius get radius;
  StreamTextTheme get textTheme;
  StreamColorScheme get colorScheme;

  @override
  AlignmentGeometry get alignment => Alignment.center;

  @override
  MaterialTapTargetSize get tapTargetSize => MaterialTapTargetSize.padded;

  @override
  WidgetStateProperty<double> get iconSize => const WidgetStatePropertyAll(20);

  @override
  WidgetStateProperty<TextStyle> get textStyle => WidgetStatePropertyAll(textTheme.bodyEmphasis);

  @override
  WidgetStateProperty<OutlinedBorder> get shape => .all(RoundedSuperellipseBorder(borderRadius: .all(radius.max)));

  @override
  WidgetStateProperty<Color> get overlayColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return colorScheme.backgroundPressed;
    if (states.contains(WidgetState.hovered)) return colorScheme.backgroundHover;
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<Size> get minimumSize => const WidgetStatePropertyAll(Size.zero);

  @override
  WidgetStateProperty<Size> get maximumSize => const WidgetStatePropertyAll(Size.infinite);

  @override
  WidgetStateProperty<double> get elevation {
    final elevations = context.streamElevation;
    return WidgetStateProperty.resolveWith((states) {
      if (!isFloating) return elevations.none;
      if (states.contains(WidgetState.disabled)) return elevations.level3;
      if (states.contains(WidgetState.pressed)) return elevations.level3;
      if (states.contains(WidgetState.hovered)) return elevations.level4;
      return elevations.level3;
    });
  }
}

// -- Primary defaults -------------------------------------------------------

// Default style for primary solid buttons.
class _PrimarySolidDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _PrimarySolidDefaults(
    this.context, {
    required this.isFloating,
  }) : radius = context.streamRadius,
       textTheme = context.streamTextTheme,
       colorScheme = context.streamColorScheme;

  @override
  final BuildContext context;
  @override
  final StreamRadius radius;
  @override
  final StreamTextTheme textTheme;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color> get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.backgroundDisabled;
    final base = colorScheme.accentPrimary;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.backgroundSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color> get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.textOnAccent;
  });
}

// Default style for primary outline buttons.
class _PrimaryOutlineDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _PrimaryOutlineDefaults(
    this.context, {
    required this.isFloating,
  }) : radius = context.streamRadius,
       textTheme = context.streamTextTheme,
       colorScheme = context.streamColorScheme;

  @override
  final BuildContext context;
  @override
  final StreamRadius radius;
  @override
  final StreamTextTheme textTheme;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color> get backgroundColor => WidgetStateProperty.resolveWith((states) {
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.disabled)) return base;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.backgroundSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color> get borderColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.borderDisabled;
    return colorScheme.brand.shade200;
  });

  @override
  WidgetStateProperty<Color> get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.accentPrimary;
  });
}

// Default style for primary ghost buttons.
class _PrimaryGhostDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _PrimaryGhostDefaults(
    this.context, {
    required this.isFloating,
  }) : radius = context.streamRadius,
       textTheme = context.streamTextTheme,
       colorScheme = context.streamColorScheme;

  @override
  final BuildContext context;
  @override
  final StreamRadius radius;
  @override
  final StreamTextTheme textTheme;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color> get backgroundColor => WidgetStateProperty.resolveWith((states) {
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.disabled)) return base;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.backgroundSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color> get foregroundColor => WidgetStateProperty.resolveWith((states) {
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
  }) : radius = context.streamRadius,
       textTheme = context.streamTextTheme,
       colorScheme = context.streamColorScheme;

  @override
  final BuildContext context;
  @override
  final StreamRadius radius;
  @override
  final StreamTextTheme textTheme;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color> get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.backgroundDisabled;
    final base = colorScheme.backgroundSurface;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.backgroundSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color> get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.textPrimary;
  });
}

// Default style for secondary outline buttons.
class _SecondaryOutlineDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _SecondaryOutlineDefaults(
    this.context, {
    required this.isFloating,
  }) : radius = context.streamRadius,
       textTheme = context.streamTextTheme,
       colorScheme = context.streamColorScheme;

  @override
  final BuildContext context;
  @override
  final StreamRadius radius;
  @override
  final StreamTextTheme textTheme;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color> get backgroundColor => WidgetStateProperty.resolveWith((states) {
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.disabled)) return base;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.backgroundSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color> get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.textPrimary;
  });

  @override
  WidgetStateProperty<Color> get borderColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.borderDisabled;
    return colorScheme.borderDefault;
  });
}

// Default style for secondary ghost buttons.
class _SecondaryGhostDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _SecondaryGhostDefaults(
    this.context, {
    required this.isFloating,
  }) : radius = context.streamRadius,
       textTheme = context.streamTextTheme,
       colorScheme = context.streamColorScheme;

  @override
  final BuildContext context;
  @override
  final StreamRadius radius;
  @override
  final StreamTextTheme textTheme;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color> get backgroundColor => WidgetStateProperty.resolveWith((states) {
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.disabled)) return base;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.backgroundSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color> get foregroundColor => WidgetStateProperty.resolveWith((states) {
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
  }) : radius = context.streamRadius,
       textTheme = context.streamTextTheme,
       colorScheme = context.streamColorScheme;

  @override
  final BuildContext context;
  @override
  final StreamRadius radius;
  @override
  final StreamTextTheme textTheme;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color> get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.backgroundDisabled;
    final base = colorScheme.accentError;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.backgroundSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color> get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.textOnAccent;
  });
}

// Default style for destructive outline buttons.
class _DestructiveOutlineDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _DestructiveOutlineDefaults(
    this.context, {
    required this.isFloating,
  }) : radius = context.streamRadius,
       textTheme = context.streamTextTheme,
       colorScheme = context.streamColorScheme;

  @override
  final BuildContext context;
  @override
  final StreamRadius radius;
  @override
  final StreamTextTheme textTheme;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color> get backgroundColor => WidgetStateProperty.resolveWith((states) {
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.disabled)) return base;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.backgroundSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color> get borderColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.borderDisabled;
    return colorScheme.accentError;
  });

  @override
  WidgetStateProperty<Color> get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.accentError;
  });
}

// Default style for destructive ghost buttons.
class _DestructiveGhostDefaults extends StreamButtonThemeStyle with _SharedButtonDefaults {
  _DestructiveGhostDefaults(
    this.context, {
    required this.isFloating,
  }) : radius = context.streamRadius,
       textTheme = context.streamTextTheme,
       colorScheme = context.streamColorScheme;

  @override
  final BuildContext context;
  @override
  final StreamRadius radius;
  @override
  final StreamTextTheme textTheme;
  @override
  final StreamColorScheme colorScheme;
  @override
  final bool isFloating;

  @override
  WidgetStateProperty<Color> get backgroundColor => WidgetStateProperty.resolveWith((states) {
    final base = isFloating ? colorScheme.backgroundElevation1 : StreamColors.transparent;
    if (states.contains(WidgetState.disabled)) return base;
    if (states.contains(WidgetState.selected)) return .alphaBlend(colorScheme.backgroundSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color> get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return colorScheme.textDisabled;
    return colorScheme.accentError;
  });
}
