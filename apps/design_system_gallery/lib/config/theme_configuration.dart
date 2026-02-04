import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A notifier that manages the theme configuration for the design system gallery.
///
/// Supports full customization of the Stream design system theme using the
/// exact naming conventions from [StreamColorScheme].
class ThemeConfiguration extends ChangeNotifier {
  ThemeConfiguration({
    Brightness brightness = Brightness.light,
  }) : _brightness = brightness {
    _rebuildTheme();
  }

  factory ThemeConfiguration.light() => ThemeConfiguration();
  factory ThemeConfiguration.dark() => ThemeConfiguration(brightness: Brightness.dark);

  // =========================================================================
  // Core State
  // =========================================================================
  var _themeData = StreamTheme.light();
  StreamTheme get themeData => _themeData;

  Brightness _brightness;
  Brightness get brightness => _brightness;

  // =========================================================================
  // Accent Colors
  // =========================================================================
  Color? _accentPrimary;
  Color? _accentSuccess;
  Color? _accentWarning;
  Color? _accentError;
  Color? _accentNeutral;

  // =========================================================================
  // Text Colors
  // =========================================================================
  Color? _textPrimary;
  Color? _textSecondary;
  Color? _textTertiary;
  Color? _textDisabled;
  Color? _textInverse;
  Color? _textLink;
  Color? _textOnAccent;

  // =========================================================================
  // Background Colors
  // =========================================================================
  Color? _backgroundApp;
  Color? _backgroundSurface;
  Color? _backgroundSurfaceSubtle;
  Color? _backgroundSurfaceStrong;
  Color? _backgroundOverlay;
  Color? _backgroundDisabled;

  // =========================================================================
  // Border Colors - Core
  // =========================================================================
  Color? _borderDefault;
  Color? _borderSubtle;
  Color? _borderStrong;
  Color? _borderOnDark;
  Color? _borderOnAccent;
  Color? _borderOpacity10;
  Color? _borderOpacity25;

  // =========================================================================
  // Border Colors - Utility
  // =========================================================================
  Color? _borderFocus;
  Color? _borderDisabled;
  Color? _borderError;
  Color? _borderWarning;
  Color? _borderSuccess;
  Color? _borderSelected;

  // =========================================================================
  // State Colors
  // =========================================================================
  Color? _stateHover;
  Color? _statePressed;
  Color? _stateSelected;
  Color? _stateFocused;
  Color? _stateDisabled;

  // =========================================================================
  // System Colors
  // =========================================================================
  Color? _systemText;
  Color? _systemScrollbar;

  // =========================================================================
  // Avatar Palette
  // =========================================================================
  List<StreamAvatarColorPair>? _avatarPalette;

  // =========================================================================
  // Brand Color
  // =========================================================================
  Color? _brandPrimaryColor;

  // =========================================================================
  // Getters - Accent
  // =========================================================================
  Color get accentPrimary => _accentPrimary ?? _themeData.colorScheme.accentPrimary;
  Color get accentSuccess => _accentSuccess ?? _themeData.colorScheme.accentSuccess;
  Color get accentWarning => _accentWarning ?? _themeData.colorScheme.accentWarning;
  Color get accentError => _accentError ?? _themeData.colorScheme.accentError;
  Color get accentNeutral => _accentNeutral ?? _themeData.colorScheme.accentNeutral;

  // =========================================================================
  // Getters - Text
  // =========================================================================
  Color get textPrimary => _textPrimary ?? _themeData.colorScheme.textPrimary;
  Color get textSecondary => _textSecondary ?? _themeData.colorScheme.textSecondary;
  Color get textTertiary => _textTertiary ?? _themeData.colorScheme.textTertiary;
  Color get textDisabled => _textDisabled ?? _themeData.colorScheme.textDisabled;
  Color get textInverse => _textInverse ?? _themeData.colorScheme.textInverse;
  Color get textLink => _textLink ?? _themeData.colorScheme.textLink;
  Color get textOnAccent => _textOnAccent ?? _themeData.colorScheme.textOnAccent;

  // =========================================================================
  // Getters - Background
  // =========================================================================
  Color get backgroundApp => _backgroundApp ?? _themeData.colorScheme.backgroundApp;
  Color get backgroundSurface => _backgroundSurface ?? _themeData.colorScheme.backgroundSurface;
  Color get backgroundSurfaceSubtle => _backgroundSurfaceSubtle ?? _themeData.colorScheme.backgroundSurfaceSubtle;
  Color get backgroundSurfaceStrong => _backgroundSurfaceStrong ?? _themeData.colorScheme.backgroundSurfaceStrong;
  Color get backgroundOverlay => _backgroundOverlay ?? _themeData.colorScheme.backgroundOverlay;
  Color get backgroundDisabled => _backgroundDisabled ?? _themeData.colorScheme.backgroundDisabled;

  // =========================================================================
  // Getters - Border Core
  // =========================================================================
  Color get borderDefault => _borderDefault ?? _themeData.colorScheme.borderDefault;
  Color get borderSubtle => _borderSubtle ?? _themeData.colorScheme.borderSubtle;
  Color get borderStrong => _borderStrong ?? _themeData.colorScheme.borderStrong;
  Color get borderOnDark => _borderOnDark ?? _themeData.colorScheme.borderOnDark;
  Color get borderOnAccent => _borderOnAccent ?? _themeData.colorScheme.borderOnAccent;
  Color get borderOpacity10 => _borderOpacity10 ?? _themeData.colorScheme.borderOpacity10;
  Color get borderOpacity25 => _borderOpacity25 ?? _themeData.colorScheme.borderOpacity25;

  // =========================================================================
  // Getters - Border Utility
  // =========================================================================
  Color get borderFocus => _borderFocus ?? _themeData.colorScheme.borderFocus;
  Color get borderDisabled => _borderDisabled ?? _themeData.colorScheme.borderDisabled;
  Color get borderError => _borderError ?? _themeData.colorScheme.borderError;
  Color get borderWarning => _borderWarning ?? _themeData.colorScheme.borderWarning;
  Color get borderSuccess => _borderSuccess ?? _themeData.colorScheme.borderSuccess;
  Color get borderSelected => _borderSelected ?? _themeData.colorScheme.borderSelected;

  // =========================================================================
  // Getters - State
  // =========================================================================
  Color get stateHover => _stateHover ?? _themeData.colorScheme.stateHover;
  Color get statePressed => _statePressed ?? _themeData.colorScheme.statePressed;
  Color get stateSelected => _stateSelected ?? _themeData.colorScheme.stateSelected;
  Color get stateFocused => _stateFocused ?? _themeData.colorScheme.stateFocused;
  Color get stateDisabled => _stateDisabled ?? _themeData.colorScheme.stateDisabled;

  // =========================================================================
  // Getters - System
  // =========================================================================
  Color get systemText => _systemText ?? _themeData.colorScheme.systemText;
  Color get systemScrollbar => _systemScrollbar ?? _themeData.colorScheme.systemScrollbar;

  // =========================================================================
  // Getters - Avatar Palette
  // =========================================================================
  List<StreamAvatarColorPair> get avatarPalette => _avatarPalette ?? _themeData.colorScheme.avatarPalette;

  // =========================================================================
  // Getters - Brand
  // =========================================================================
  Color get brandPrimaryColor => _brandPrimaryColor ?? _themeData.colorScheme.brand.shade500;

  // =========================================================================
  // Setters
  // =========================================================================

  void setBrightness(Brightness brightness) {
    if (_brightness == brightness) return;
    _brightness = brightness;
    _rebuildTheme();
    notifyListeners();
  }

  // Accent
  void setAccentPrimary(Color color) => _update(() => _accentPrimary = color);
  void setAccentSuccess(Color color) => _update(() => _accentSuccess = color);
  void setAccentWarning(Color color) => _update(() => _accentWarning = color);
  void setAccentError(Color color) => _update(() => _accentError = color);
  void setAccentNeutral(Color color) => _update(() => _accentNeutral = color);

  // Text
  void setTextPrimary(Color color) => _update(() => _textPrimary = color);
  void setTextSecondary(Color color) => _update(() => _textSecondary = color);
  void setTextTertiary(Color color) => _update(() => _textTertiary = color);
  void setTextDisabled(Color color) => _update(() => _textDisabled = color);
  void setTextInverse(Color color) => _update(() => _textInverse = color);
  void setTextLink(Color color) => _update(() => _textLink = color);
  void setTextOnAccent(Color color) => _update(() => _textOnAccent = color);

  // Background
  void setBackgroundApp(Color color) => _update(() => _backgroundApp = color);
  void setBackgroundSurface(Color color) => _update(() => _backgroundSurface = color);
  void setBackgroundSurfaceSubtle(Color color) => _update(() => _backgroundSurfaceSubtle = color);
  void setBackgroundSurfaceStrong(Color color) => _update(() => _backgroundSurfaceStrong = color);
  void setBackgroundOverlay(Color color) => _update(() => _backgroundOverlay = color);
  void setBackgroundDisabled(Color color) => _update(() => _backgroundDisabled = color);

  // Border Core
  void setBorderDefault(Color color) => _update(() => _borderDefault = color);
  void setBorderSubtle(Color color) => _update(() => _borderSubtle = color);
  void setBorderStrong(Color color) => _update(() => _borderStrong = color);
  void setBorderOnDark(Color color) => _update(() => _borderOnDark = color);
  void setBorderOnAccent(Color color) => _update(() => _borderOnAccent = color);
  void setBorderOpacity10(Color color) => _update(() => _borderOpacity10 = color);
  void setBorderOpacity25(Color color) => _update(() => _borderOpacity25 = color);

  // Border Utility
  void setBorderFocus(Color color) => _update(() => _borderFocus = color);
  void setBorderDisabled(Color color) => _update(() => _borderDisabled = color);
  void setBorderError(Color color) => _update(() => _borderError = color);
  void setBorderWarning(Color color) => _update(() => _borderWarning = color);
  void setBorderSuccess(Color color) => _update(() => _borderSuccess = color);
  void setBorderSelected(Color color) => _update(() => _borderSelected = color);

  // State
  void setStateHover(Color color) => _update(() => _stateHover = color);
  void setStatePressed(Color color) => _update(() => _statePressed = color);
  void setStateSelected(Color color) => _update(() => _stateSelected = color);
  void setStateFocused(Color color) => _update(() => _stateFocused = color);
  void setStateDisabled(Color color) => _update(() => _stateDisabled = color);

  // System
  void setSystemText(Color color) => _update(() => _systemText = color);
  void setSystemScrollbar(Color color) => _update(() => _systemScrollbar = color);

  // Avatar Palette
  void setAvatarPalette(List<StreamAvatarColorPair> palette) => _update(() => _avatarPalette = palette);

  // Brand
  void setBrandPrimaryColor(Color color) => _update(() => _brandPrimaryColor = color);

  void updateAvatarPaletteAt(int index, StreamAvatarColorPair pair) {
    final current = List<StreamAvatarColorPair>.from(avatarPalette);
    if (index < current.length) {
      current[index] = pair;
      _update(() => _avatarPalette = current);
    }
  }

  void addAvatarPaletteEntry(StreamAvatarColorPair pair) {
    final current = List<StreamAvatarColorPair>.from(avatarPalette);
    current.add(pair);
    _update(() => _avatarPalette = current);
  }

  void removeAvatarPaletteAt(int index) {
    final current = List<StreamAvatarColorPair>.from(avatarPalette);
    if (index < current.length && current.length > 1) {
      current.removeAt(index);
      _update(() => _avatarPalette = current);
    }
  }

  void _update(VoidCallback setter) {
    setter();
    _rebuildTheme();
    notifyListeners();
  }

  void resetToDefaults() {
    _brandPrimaryColor = null;
    // Accent
    _accentPrimary = null;
    _accentSuccess = null;
    _accentWarning = null;
    _accentError = null;
    _accentNeutral = null;
    // Text
    _textPrimary = null;
    _textSecondary = null;
    _textTertiary = null;
    _textDisabled = null;
    _textInverse = null;
    _textLink = null;
    _textOnAccent = null;
    // Background
    _backgroundApp = null;
    _backgroundSurface = null;
    _backgroundSurfaceSubtle = null;
    _backgroundSurfaceStrong = null;
    _backgroundOverlay = null;
    _backgroundDisabled = null;
    // Border Core
    _borderDefault = null;
    _borderSubtle = null;
    _borderStrong = null;
    _borderOnDark = null;
    _borderOnAccent = null;
    _borderOpacity10 = null;
    _borderOpacity25 = null;
    // Border Utility
    _borderFocus = null;
    _borderDisabled = null;
    _borderError = null;
    _borderWarning = null;
    _borderSuccess = null;
    _borderSelected = null;
    // State
    _stateHover = null;
    _statePressed = null;
    _stateSelected = null;
    _stateFocused = null;
    _stateDisabled = null;
    // System
    _systemText = null;
    _systemScrollbar = null;
    // Avatar
    _avatarPalette = null;
    // Brand
    _brandPrimaryColor = null;

    _rebuildTheme();
    notifyListeners();
  }

  void _rebuildTheme() {
    final baseColorScheme = _brightness == Brightness.dark ? StreamColorScheme.dark() : StreamColorScheme.light();

    // Compute effective brand swatch (if brand primary is customized)
    final effectiveBrand = _brandPrimaryColor != null
        ? StreamColorSwatch.fromColor(_brandPrimaryColor!, brightness: _brightness)
        : null;

    // Derived from brand: accentPrimary defaults to brand.shade500
    final effectiveAccentPrimary = _accentPrimary ?? _brandPrimaryColor;

    // Derived from brand: borderFocus defaults to brand.shade300
    final effectiveBorderFocus = _borderFocus ?? effectiveBrand?.shade300;

    // Derived from brand: stateFocused defaults to brand.shade100
    final effectiveStateFocused = _stateFocused ?? effectiveBrand?.shade100;

    // Derived from accentPrimary: textLink and borderSelected
    final effectiveTextLink = _textLink ?? effectiveAccentPrimary;
    final effectiveBorderSelected = _borderSelected ?? effectiveAccentPrimary;

    // Derived from other accents: border utility colors
    final effectiveBorderError = _borderError ?? _accentError;
    final effectiveBorderWarning = _borderWarning ?? _accentWarning;
    final effectiveBorderSuccess = _borderSuccess ?? _accentSuccess;

    final colorScheme = baseColorScheme.copyWith(
      // Brand
      brand: effectiveBrand,
      // Accent - brand primary affects accentPrimary
      accentPrimary: effectiveAccentPrimary,
      accentSuccess: _accentSuccess,
      accentWarning: _accentWarning,
      accentError: _accentError,
      accentNeutral: _accentNeutral,
      // Text - textLink derived from accentPrimary
      textPrimary: _textPrimary,
      textSecondary: _textSecondary,
      textTertiary: _textTertiary,
      textDisabled: _textDisabled,
      textInverse: _textInverse,
      textLink: effectiveTextLink,
      textOnAccent: _textOnAccent,
      // Background
      backgroundApp: _backgroundApp,
      backgroundSurface: _backgroundSurface,
      backgroundSurfaceSubtle: _backgroundSurfaceSubtle,
      backgroundSurfaceStrong: _backgroundSurfaceStrong,
      backgroundOverlay: _backgroundOverlay,
      backgroundDisabled: _backgroundDisabled,
      // Border Core
      borderDefault: _borderDefault,
      borderSubtle: _borderSubtle,
      borderStrong: _borderStrong,
      borderOnDark: _borderOnDark,
      borderOnAccent: _borderOnAccent,
      borderOpacity10: _borderOpacity10,
      borderOpacity25: _borderOpacity25,
      // Border Utility - derived from brand and accents
      borderFocus: effectiveBorderFocus,
      borderDisabled: _borderDisabled,
      borderError: effectiveBorderError,
      borderWarning: effectiveBorderWarning,
      borderSuccess: effectiveBorderSuccess,
      borderSelected: effectiveBorderSelected,
      // State - stateFocused derived from brand
      stateHover: _stateHover,
      statePressed: _statePressed,
      stateSelected: _stateSelected,
      stateFocused: effectiveStateFocused,
      stateDisabled: _stateDisabled,
      // System
      systemText: _systemText,
      systemScrollbar: _systemScrollbar,
      // Avatar
      avatarPalette: _avatarPalette,
    );

    _themeData = StreamTheme(
      brightness: _brightness,
      colorScheme: colorScheme,
    );
  }

  /// Builds a Material ThemeData that uses Stream colors.
  /// Use this for applying Stream theming to regular Flutter widgets.
  ThemeData buildMaterialTheme() {
    final ts = themeData.textTheme;
    final radius = themeData.radius;
    final isDark = brightness == Brightness.dark;

    // Common radius values (StreamRadius returns Radius, use BorderRadius.all)
    final componentRadius = BorderRadius.all(radius.md);
    final dialogRadius = BorderRadius.all(radius.lg);
    final smallRadius = BorderRadius.all(radius.sm);

    // Shared ColorScheme properties - uses class getters for colors
    final materialColorScheme = (isDark ? ColorScheme.dark : ColorScheme.light)(
      primary: accentPrimary,
      secondary: accentPrimary,
      tertiary: accentNeutral,
      error: accentError,
      surface: backgroundSurface,
      surfaceContainerHighest: backgroundSurfaceSubtle,
      onPrimary: textOnAccent,
      onSecondary: textOnAccent,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      onError: textOnAccent,
      outline: borderDefault,
      outlineVariant: borderSubtle,
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: materialColorScheme,
      // StreamTheme extension - enables StreamTheme.of(context) and context extensions
      extensions: [themeData],
      // Colors
      primaryColor: accentPrimary,
      scaffoldBackgroundColor: backgroundApp,
      cardColor: backgroundSurface,
      dividerColor: borderSubtle,
      disabledColor: textDisabled,
      hintColor: textTertiary,
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundSurface,
        surfaceTintColor: StreamColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: dialogRadius,
          side: BorderSide(color: borderSubtle),
        ),
        titleTextStyle: ts.bodyEmphasis.copyWith(color: textPrimary),
        contentTextStyle: ts.bodyDefault.copyWith(color: textSecondary),
      ),
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundSurface,
        foregroundColor: textPrimary,
        surfaceTintColor: StreamColors.transparent,
        elevation: 0,
      ),
      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: textOnAccent,
          disabledBackgroundColor: stateDisabled,
          disabledForegroundColor: textDisabled,
          shape: RoundedRectangleBorder(borderRadius: componentRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: borderDefault),
          shape: RoundedRectangleBorder(borderRadius: componentRadius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPrimary,
          shape: RoundedRectangleBorder(borderRadius: componentRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundSurface,
          foregroundColor: textPrimary,
          surfaceTintColor: StreamColors.transparent,
          shape: RoundedRectangleBorder(borderRadius: componentRadius),
        ),
      ),
      // Input
      inputDecorationTheme: InputDecorationTheme(
        fillColor: backgroundApp,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: componentRadius,
          borderSide: BorderSide(color: borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: componentRadius,
          borderSide: BorderSide(color: borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: componentRadius,
          borderSide: BorderSide(color: accentPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: componentRadius,
          borderSide: BorderSide(color: accentError),
        ),
        hintStyle: ts.bodyDefault.copyWith(color: textTertiary),
        labelStyle: ts.bodyDefault.copyWith(color: textSecondary),
      ),
      // Dropdown
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(backgroundSurface),
          surfaceTintColor: const WidgetStatePropertyAll(StreamColors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: componentRadius,
              side: BorderSide(color: borderSubtle),
            ),
          ),
        ),
      ),
      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        color: backgroundSurface,
        surfaceTintColor: StreamColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: componentRadius,
          side: BorderSide(color: borderSubtle),
        ),
        textStyle: ts.bodyDefault.copyWith(color: textPrimary),
      ),
      // Scrollbar
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(systemScrollbar),
        trackColor: WidgetStatePropertyAll(backgroundSurfaceSubtle),
        radius: radius.max,
        thickness: const WidgetStatePropertyAll(6),
      ),
      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: backgroundSurfaceStrong,
          borderRadius: smallRadius,
        ),
        textStyle: ts.captionDefault.copyWith(color: textPrimary),
      ),
      // Divider
      dividerTheme: DividerThemeData(
        color: borderSubtle,
        thickness: 1,
      ),
      // Icon
      iconTheme: IconThemeData(color: textSecondary),
      // Text - mapped to closest Stream styles by size/weight
      textTheme: TextTheme(
        // Titles - for app bar, dialogs, navigation
        titleLarge: ts.headingLg.copyWith(color: textPrimary),
        titleMedium: ts.bodyEmphasis.copyWith(color: textPrimary),
        titleSmall: ts.captionEmphasis.copyWith(color: textPrimary),
        // Body - main content text
        bodyLarge: ts.bodyEmphasis.copyWith(color: textPrimary),
        bodyMedium: ts.bodyDefault.copyWith(color: textPrimary),
        bodySmall: ts.captionDefault.copyWith(color: textSecondary),
        // Labels - buttons, chips, navigation items
        labelLarge: ts.captionEmphasis.copyWith(color: textPrimary),
        labelMedium: ts.metadataEmphasis.copyWith(color: textSecondary),
        labelSmall: ts.metadataDefault.copyWith(color: textTertiary),
      ),
    );
  }
}
