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
  Color? _textLink;
  Color? _textOnAccent;

  // =========================================================================
  // Background Colors
  // =========================================================================
  Color? _backgroundApp;
  Color? _backgroundSurface;
  Color? _backgroundSurfaceSubtle;
  Color? _backgroundSurfaceStrong;
  Color? _backgroundSurfaceCard;
  Color? _backgroundOnAccent;
  Color? _backgroundHighlight;
  Color? _backgroundScrim;
  Color? _backgroundOverlayLight;
  Color? _backgroundOverlayDark;
  Color? _backgroundDisabled;
  Color? _backgroundHover;
  Color? _backgroundPressed;
  Color? _backgroundSelected;
  Color? _backgroundInverse;
  Color? _backgroundElevation0;
  Color? _backgroundElevation1;
  Color? _backgroundElevation2;
  Color? _backgroundElevation3;

  // =========================================================================
  // Border Colors - Core
  // =========================================================================
  Color? _borderDefault;
  Color? _borderSubtle;
  Color? _borderStrong;
  Color? _borderOnAccent;
  Color? _borderOnSurface;
  Color? _borderOpacitySubtle;
  Color? _borderOpacityStrong;

  // =========================================================================
  // Border Colors - Utility
  // =========================================================================
  Color? _borderFocus;
  Color? _borderDisabled;
  Color? _borderHover;
  Color? _borderPressed;
  Color? _borderActive;
  Color? _borderError;
  Color? _borderWarning;
  Color? _borderSuccess;
  Color? _borderSelected;

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
  // Chrome Color
  // =========================================================================
  Color? _chromePrimaryColor;

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
  Color get textLink => _textLink ?? _themeData.colorScheme.textLink;
  Color get textOnAccent => _textOnAccent ?? _themeData.colorScheme.textOnAccent;

  // =========================================================================
  // Getters - Background
  // =========================================================================
  Color get backgroundApp => _backgroundApp ?? _themeData.colorScheme.backgroundApp;
  Color get backgroundSurface => _backgroundSurface ?? _themeData.colorScheme.backgroundSurface;
  Color get backgroundSurfaceSubtle => _backgroundSurfaceSubtle ?? _themeData.colorScheme.backgroundSurfaceSubtle;
  Color get backgroundSurfaceStrong => _backgroundSurfaceStrong ?? _themeData.colorScheme.backgroundSurfaceStrong;
  Color get backgroundSurfaceCard => _backgroundSurfaceCard ?? _themeData.colorScheme.backgroundSurfaceCard;
  Color get backgroundOnAccent => _backgroundOnAccent ?? _themeData.colorScheme.backgroundOnAccent;
  Color get backgroundHighlight => _backgroundHighlight ?? _themeData.colorScheme.backgroundHighlight;
  Color get backgroundScrim => _backgroundScrim ?? _themeData.colorScheme.backgroundScrim;
  Color get backgroundOverlayLight => _backgroundOverlayLight ?? _themeData.colorScheme.backgroundOverlayLight;
  Color get backgroundOverlayDark => _backgroundOverlayDark ?? _themeData.colorScheme.backgroundOverlayDark;
  Color get backgroundDisabled => _backgroundDisabled ?? _themeData.colorScheme.backgroundDisabled;
  Color get backgroundHover => _backgroundHover ?? _themeData.colorScheme.backgroundHover;
  Color get backgroundPressed => _backgroundPressed ?? _themeData.colorScheme.backgroundPressed;
  Color get backgroundSelected => _backgroundSelected ?? _themeData.colorScheme.backgroundSelected;
  Color get backgroundInverse => _backgroundInverse ?? _themeData.colorScheme.backgroundInverse;
  Color get backgroundElevation0 => _backgroundElevation0 ?? _themeData.colorScheme.backgroundElevation0;
  Color get backgroundElevation1 => _backgroundElevation1 ?? _themeData.colorScheme.backgroundElevation1;
  Color get backgroundElevation2 => _backgroundElevation2 ?? _themeData.colorScheme.backgroundElevation2;
  Color get backgroundElevation3 => _backgroundElevation3 ?? _themeData.colorScheme.backgroundElevation3;

  // =========================================================================
  // Getters - Border Core
  // =========================================================================
  Color get borderDefault => _borderDefault ?? _themeData.colorScheme.borderDefault;
  Color get borderSubtle => _borderSubtle ?? _themeData.colorScheme.borderSubtle;
  Color get borderStrong => _borderStrong ?? _themeData.colorScheme.borderStrong;
  Color get borderOnAccent => _borderOnAccent ?? _themeData.colorScheme.borderOnAccent;
  Color get borderOnSurface => _borderOnSurface ?? _themeData.colorScheme.borderOnSurface;
  Color get borderOpacitySubtle => _borderOpacitySubtle ?? _themeData.colorScheme.borderOpacitySubtle;
  Color get borderOpacityStrong => _borderOpacityStrong ?? _themeData.colorScheme.borderOpacityStrong;

  // =========================================================================
  // Getters - Border Utility
  // =========================================================================
  Color get borderFocus => _borderFocus ?? _themeData.colorScheme.borderFocus;
  Color get borderDisabled => _borderDisabled ?? _themeData.colorScheme.borderDisabled;
  Color get borderHover => _borderHover ?? _themeData.colorScheme.borderHover;
  Color get borderPressed => _borderPressed ?? _themeData.colorScheme.borderPressed;
  Color get borderActive => _borderActive ?? _themeData.colorScheme.borderActive;
  Color get borderError => _borderError ?? _themeData.colorScheme.borderError;
  Color get borderWarning => _borderWarning ?? _themeData.colorScheme.borderWarning;
  Color get borderSuccess => _borderSuccess ?? _themeData.colorScheme.borderSuccess;
  Color get borderSelected => _borderSelected ?? _themeData.colorScheme.borderSelected;

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
  // Getters - Chrome
  // =========================================================================
  Color get chromePrimaryColor => _chromePrimaryColor ?? _themeData.colorScheme.chrome.shade500;

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
  void setTextLink(Color color) => _update(() => _textLink = color);
  void setTextOnAccent(Color color) => _update(() => _textOnAccent = color);

  // Background
  void setBackgroundApp(Color color) => _update(() => _backgroundApp = color);
  void setBackgroundSurface(Color color) => _update(() => _backgroundSurface = color);
  void setBackgroundSurfaceSubtle(Color color) => _update(() => _backgroundSurfaceSubtle = color);
  void setBackgroundSurfaceStrong(Color color) => _update(() => _backgroundSurfaceStrong = color);
  void setBackgroundSurfaceCard(Color color) => _update(() => _backgroundSurfaceCard = color);
  void setBackgroundOnAccent(Color color) => _update(() => _backgroundOnAccent = color);
  void setBackgroundHighlight(Color color) => _update(() => _backgroundHighlight = color);
  void setBackgroundScrim(Color color) => _update(() => _backgroundScrim = color);
  void setBackgroundOverlayLight(Color color) => _update(() => _backgroundOverlayLight = color);
  void setBackgroundOverlayDark(Color color) => _update(() => _backgroundOverlayDark = color);
  void setBackgroundDisabled(Color color) => _update(() => _backgroundDisabled = color);
  void setBackgroundHover(Color color) => _update(() => _backgroundHover = color);
  void setBackgroundPressed(Color color) => _update(() => _backgroundPressed = color);
  void setBackgroundSelected(Color color) => _update(() => _backgroundSelected = color);
  void setBackgroundInverse(Color color) => _update(() => _backgroundInverse = color);
  void setBackgroundElevation0(Color color) => _update(() => _backgroundElevation0 = color);
  void setBackgroundElevation1(Color color) => _update(() => _backgroundElevation1 = color);
  void setBackgroundElevation2(Color color) => _update(() => _backgroundElevation2 = color);
  void setBackgroundElevation3(Color color) => _update(() => _backgroundElevation3 = color);

  // Border Core
  void setBorderDefault(Color color) => _update(() => _borderDefault = color);
  void setBorderSubtle(Color color) => _update(() => _borderSubtle = color);
  void setBorderStrong(Color color) => _update(() => _borderStrong = color);
  void setBorderOnAccent(Color color) => _update(() => _borderOnAccent = color);
  void setBorderOnSurface(Color color) => _update(() => _borderOnSurface = color);
  void setBorderOpacitySubtle(Color color) => _update(() => _borderOpacitySubtle = color);
  void setBorderOpacityStrong(Color color) => _update(() => _borderOpacityStrong = color);

  // Border Utility
  void setBorderFocus(Color color) => _update(() => _borderFocus = color);
  void setBorderDisabled(Color color) => _update(() => _borderDisabled = color);
  void setBorderHover(Color color) => _update(() => _borderHover = color);
  void setBorderPressed(Color color) => _update(() => _borderPressed = color);
  void setBorderActive(Color color) => _update(() => _borderActive = color);
  void setBorderError(Color color) => _update(() => _borderError = color);
  void setBorderWarning(Color color) => _update(() => _borderWarning = color);
  void setBorderSuccess(Color color) => _update(() => _borderSuccess = color);
  void setBorderSelected(Color color) => _update(() => _borderSelected = color);

  // System
  void setSystemText(Color color) => _update(() => _systemText = color);
  void setSystemScrollbar(Color color) => _update(() => _systemScrollbar = color);

  // Avatar Palette
  void setAvatarPalette(List<StreamAvatarColorPair> palette) => _update(() => _avatarPalette = palette);

  // Brand
  void setBrandPrimaryColor(Color color) => _update(() => _brandPrimaryColor = color);

  // Chrome
  void setChromePrimaryColor(Color color) => _update(() => _chromePrimaryColor = color);

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
    _textLink = null;
    _textOnAccent = null;
    // Background
    _backgroundApp = null;
    _backgroundSurface = null;
    _backgroundSurfaceSubtle = null;
    _backgroundSurfaceStrong = null;
    _backgroundSurfaceCard = null;
    _backgroundOnAccent = null;
    _backgroundHighlight = null;
    _backgroundScrim = null;
    _backgroundOverlayLight = null;
    _backgroundOverlayDark = null;
    _backgroundDisabled = null;
    _backgroundHover = null;
    _backgroundPressed = null;
    _backgroundSelected = null;
    _backgroundInverse = null;
    _backgroundElevation0 = null;
    _backgroundElevation1 = null;
    _backgroundElevation2 = null;
    _backgroundElevation3 = null;
    // Border Core
    _borderDefault = null;
    _borderSubtle = null;
    _borderStrong = null;
    _borderOnAccent = null;
    _borderOnSurface = null;
    _borderOpacitySubtle = null;
    _borderOpacityStrong = null;
    // Border Utility
    _borderFocus = null;
    _borderDisabled = null;
    _borderHover = null;
    _borderPressed = null;
    _borderActive = null;
    _borderError = null;
    _borderWarning = null;
    _borderSuccess = null;
    _borderSelected = null;
    // System
    _systemText = null;
    _systemScrollbar = null;
    // Avatar
    _avatarPalette = null;
    // Brand
    _brandPrimaryColor = null;
    // Chrome
    _chromePrimaryColor = null;

    _rebuildTheme();
    notifyListeners();
  }

  void _rebuildTheme() {
    final baseColorScheme = _brightness == Brightness.dark ? StreamColorScheme.dark() : StreamColorScheme.light();
    final isDark = _brightness == Brightness.dark;

    // Compute effective brand swatch (if brand primary is customized)
    final effectiveBrand = _brandPrimaryColor != null
        ? StreamColorSwatch.fromColor(_brandPrimaryColor!, brightness: _brightness)
        : null;

    // Compute effective chrome swatch (if chrome primary is customized)
    final effectiveChrome = _chromePrimaryColor != null
        ? StreamColorSwatch.fromColor(_chromePrimaryColor!, brightness: _brightness)
        : null;

    // Derived from brand: accentPrimary defaults to brand.shade500 (light) / shade400 (dark)
    final effectiveAccentPrimary = _accentPrimary ?? _brandPrimaryColor;

    // Derived from brand: borderFocus defaults to brand.shade150
    final effectiveBorderFocus = _borderFocus ?? effectiveBrand?.shade150;

    // Derived from accentPrimary: textLink and borderActive
    final effectiveTextLink = _textLink ?? effectiveAccentPrimary;
    final effectiveBorderActive = _borderActive ?? effectiveAccentPrimary;

    // Derived from other accents: border utility colors
    final effectiveBorderError = _borderError ?? _accentError;
    final effectiveBorderWarning = _borderWarning ?? _accentWarning;
    final effectiveBorderSuccess = _borderSuccess ?? _accentSuccess;

    // Derived from chrome: all chrome-dependent semantic colors.
    // When chrome is customized via copyWith, the base scheme still holds values
    // derived from the default chrome, so we must re-derive all of them explicitly.
    // Extract subscript lookups to avoid Dart parsing ambiguity with ?[] inside ternaries.
    final chromeShade0 = effectiveChrome?[0];
    final chromeShade1000 = effectiveChrome?[1000];

    final effectiveAccentNeutral = _accentNeutral ?? effectiveChrome?.shade500;
    final effectiveTextPrimary = _textPrimary ?? effectiveChrome?.shade900;
    final effectiveTextSecondary = _textSecondary ?? effectiveChrome?.shade700;
    final effectiveTextTertiary = _textTertiary ?? effectiveChrome?.shade500;
    final effectiveTextDisabled = _textDisabled ?? effectiveChrome?.shade300;
    final effectiveTextOnAccent = _textOnAccent ?? chromeShade0;
    final effectiveBackgroundSurface = _backgroundSurface ?? effectiveChrome?.shade100;
    final effectiveBackgroundSurfaceSubtle = _backgroundSurfaceSubtle ?? effectiveChrome?.shade50;
    final effectiveBackgroundSurfaceStrong = _backgroundSurfaceStrong ?? effectiveChrome?.shade150;
    final effectiveBackgroundSurfaceCard =
        _backgroundSurfaceCard ?? (isDark ? effectiveChrome?.shade100 : effectiveChrome?.shade50);
    final effectiveBackgroundOnAccent = _backgroundOnAccent ?? chromeShade0;
    final effectiveBackgroundDisabled = _backgroundDisabled ?? effectiveChrome?.shade100;
    final effectiveBackgroundInverse = _backgroundInverse ?? effectiveChrome?.shade900;
    final effectiveBackgroundElevation0 = _backgroundElevation0 ?? (isDark ? chromeShade1000 : chromeShade0);
    final effectiveBackgroundElevation1 = _backgroundElevation1 ?? (isDark ? effectiveChrome?.shade50 : chromeShade0);
    final effectiveBackgroundElevation2 = _backgroundElevation2 ?? (isDark ? effectiveChrome?.shade100 : chromeShade0);
    final effectiveBackgroundElevation3 = _backgroundElevation3 ?? (isDark ? effectiveChrome?.shade200 : chromeShade0);
    // backgroundApp derives from backgroundElevation0 in both themes
    final effectiveBackgroundApp = _backgroundApp ?? effectiveBackgroundElevation0;
    final effectiveBorderOnAccent = _borderOnAccent ?? chromeShade0;
    final effectiveBorderOnSurface = _borderOnSurface ?? effectiveChrome?.shade300;
    final effectiveBorderDisabled = _borderDisabled ?? effectiveChrome?.shade100;

    final colorScheme = baseColorScheme.copyWith(
      // Brand
      brand: effectiveBrand,
      // Chrome
      chrome: effectiveChrome,
      // Accent
      accentPrimary: effectiveAccentPrimary,
      accentSuccess: _accentSuccess,
      accentWarning: _accentWarning,
      accentError: _accentError,
      accentNeutral: effectiveAccentNeutral,
      // Text
      textPrimary: effectiveTextPrimary,
      textSecondary: effectiveTextSecondary,
      textTertiary: effectiveTextTertiary,
      textDisabled: effectiveTextDisabled,
      textLink: effectiveTextLink,
      textOnAccent: effectiveTextOnAccent,
      // Background
      backgroundApp: effectiveBackgroundApp,
      backgroundSurface: effectiveBackgroundSurface,
      backgroundSurfaceSubtle: effectiveBackgroundSurfaceSubtle,
      backgroundSurfaceStrong: effectiveBackgroundSurfaceStrong,
      backgroundSurfaceCard: effectiveBackgroundSurfaceCard,
      backgroundOnAccent: effectiveBackgroundOnAccent,
      backgroundHighlight: _backgroundHighlight,
      backgroundScrim: _backgroundScrim,
      backgroundOverlayLight: _backgroundOverlayLight,
      backgroundOverlayDark: _backgroundOverlayDark,
      backgroundDisabled: effectiveBackgroundDisabled,
      backgroundHover: _backgroundHover,
      backgroundPressed: _backgroundPressed,
      backgroundSelected: _backgroundSelected,
      backgroundInverse: effectiveBackgroundInverse,
      backgroundElevation0: effectiveBackgroundElevation0,
      backgroundElevation1: effectiveBackgroundElevation1,
      backgroundElevation2: effectiveBackgroundElevation2,
      backgroundElevation3: effectiveBackgroundElevation3,
      // Border Core
      borderDefault: _borderDefault,
      borderSubtle: _borderSubtle,
      borderStrong: _borderStrong,
      borderOnAccent: effectiveBorderOnAccent,
      borderOnSurface: effectiveBorderOnSurface,
      borderOpacitySubtle: _borderOpacitySubtle,
      borderOpacityStrong: _borderOpacityStrong,
      // Border Utility
      borderFocus: effectiveBorderFocus,
      borderDisabled: effectiveBorderDisabled,
      borderHover: _borderHover,
      borderPressed: _borderPressed,
      borderActive: effectiveBorderActive,
      borderError: effectiveBorderError,
      borderWarning: effectiveBorderWarning,
      borderSuccess: effectiveBorderSuccess,
      borderSelected: _borderSelected,
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
        titleTextStyle: ts.headingSm.copyWith(color: textPrimary),
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
          disabledBackgroundColor: backgroundDisabled,
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
        textStyle: ts.metadataDefault.copyWith(color: textPrimary),
      ),
      // Divider
      dividerTheme: DividerThemeData(
        color: borderSubtle,
        thickness: 1,
      ),
      // Icon
      iconTheme: IconThemeData(color: textSecondary),
      // Text - mapped to Material 3 roles per Figma design system spec
      textTheme: TextTheme(
        // Titles - heading hierarchy
        titleLarge: ts.headingLg.copyWith(color: textPrimary),
        titleMedium: ts.headingMd.copyWith(color: textPrimary),
        titleSmall: ts.headingSm.copyWith(color: textPrimary),
        // Body - content text
        bodyLarge: ts.bodyDefault.copyWith(color: textPrimary),
        bodyMedium: ts.captionDefault.copyWith(color: textPrimary),
        bodySmall: ts.metadataDefault.copyWith(color: textSecondary),
        // Labels - buttons, chips, navigation items
        labelLarge: ts.headingXs.copyWith(color: textPrimary),
        labelMedium: ts.metadataEmphasis.copyWith(color: textSecondary),
        labelSmall: ts.metadataDefault.copyWith(color: textTertiary),
      ),
    );
  }
}
