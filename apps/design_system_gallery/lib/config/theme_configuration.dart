import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';

import 'component_theme_descriptors.dart';
import 'theme_color_slot.dart';

/// A notifier that manages the theme configuration for the design system gallery.
///
/// Supports full customization of the Stream design system theme using the
/// exact naming conventions from [StreamColorScheme]. Overrides for the 51
/// plain-color parameters are keyed by [ThemeColorSlot] rather than
/// hand-written per-color fields — see `theme_color_slot.dart` for why.
class ThemeConfiguration extends ChangeNotifier {
  ThemeConfiguration({
    Brightness brightness = Brightness.light,
  }) : _brightness = brightness {
    _rebuildTheme();
  }

  factory ThemeConfiguration.light() => ThemeConfiguration();
  factory ThemeConfiguration.dark() => ThemeConfiguration(brightness: Brightness.dark);

  /// Creates a [ThemeConfiguration] seeded with [source]'s current overrides.
  ///
  /// Used by the export page to derive independent light/dark configurations
  /// from the (brightness-agnostic) theme studio state, without either side
  /// writing back to [source].
  factory ThemeConfiguration.seededFrom(ThemeConfiguration source, {required Brightness brightness}) {
    return ThemeConfiguration(brightness: brightness)..applyOverrides(
      source._overrides,
      brandSeed: source._brandSeed,
      chromeSeed: source._chromeSeed,
      avatarPalette: source._avatarPalette,
      componentOverrides: source._componentOverrides,
    );
  }

  // =========================================================================
  // Core State
  // =========================================================================
  var _themeData = StreamTheme.light();
  StreamTheme get themeData => _themeData;

  Brightness _brightness;
  Brightness get brightness => _brightness;

  // Overrides for every plain Color? parameter of StreamColorScheme, keyed by
  // slot. Absence of a key means "use the SDK default".
  final Map<ThemeColorSlot, Color> _overrides = {};

  // Brand & chrome are StreamColorSwatch-valued, so they're seeded from a
  // single Color and normalized via StreamColorSwatch.fromColor, not stored
  // directly as overrides.
  Color? _brandSeed;
  Color? _chromeSeed;

  List<StreamAvatarColorPair>? _avatarPalette;

  // Component theme overrides, keyed by ComponentThemeDescriptor.name, then
  // by property name (e.g. _componentOverrides['Avatar']['backgroundColor']).
  // A component appears here (possibly with an empty inner map) once added
  // via addComponentTheme, so the studio panel keeps showing its section
  // even before any of its colors are customized.
  final Map<String, Map<String, Color>> _componentOverrides = {};

  // =========================================================================
  // Slot-based access
  // =========================================================================

  /// Resolves [slot] to its current value: the override if one is set,
  /// otherwise the SDK default derived by [StreamColorScheme].
  ///
  /// Reads the raw override first rather than reading back through
  /// [themeData] — necessary for [brandPrimaryColor]/[chromePrimaryColor]
  /// (see below) but kept consistent here too.
  Color resolve(ThemeColorSlot slot) => _overrides[slot] ?? slot.read(_themeData.colorScheme);

  /// Whether [slot] has been overridden (vs. using the SDK default).
  bool isCustom(ThemeColorSlot slot) => _overrides.containsKey(slot);

  /// A read-only snapshot of every currently-overridden slot.
  Map<ThemeColorSlot, Color> get overrides => Map.unmodifiable(_overrides);

  void setOverride(ThemeColorSlot slot, Color color) => _update(() => _overrides[slot] = color);

  void resetOverride(ThemeColorSlot slot) => _update(() => _overrides.remove(slot));

  /// Replaces all overrides, brand/chrome seeds, the avatar palette, and
  /// component theme overrides in one rebuild+notify. Used to seed a new
  /// [ThemeConfiguration] from another (see [ThemeConfiguration.seededFrom]).
  void applyOverrides(
    Map<ThemeColorSlot, Color> overrides, {
    Color? brandSeed,
    Color? chromeSeed,
    List<StreamAvatarColorPair>? avatarPalette,
    Map<String, Map<String, Color>>? componentOverrides,
  }) {
    _overrides
      ..clear()
      ..addAll(overrides);
    _brandSeed = brandSeed;
    _chromeSeed = chromeSeed;
    _avatarPalette = avatarPalette;
    _componentOverrides
      ..clear()
      ..addAll(
        componentOverrides?.map((component, values) => MapEntry(component, Map<String, Color>.from(values))) ?? {},
      );
    _rebuildTheme();
    notifyListeners();
  }

  // =========================================================================
  // Getters - Brand & Chrome
  // =========================================================================

  // brand.shade500 is NOT the seed color the user picked - StreamColorSwatch
  // normalizes the seed onto the HCT tone ladder - so the raw override must
  // win here rather than reading back through the built scheme.
  Color get brandPrimaryColor => _brandSeed ?? _themeData.colorScheme.brand.shade500;
  Color get chromePrimaryColor => _chromeSeed ?? _themeData.colorScheme.chrome.shade500;

  bool get brandIsCustom => _brandSeed != null;
  bool get chromeIsCustom => _chromeSeed != null;

  // =========================================================================
  // Getters - Avatar Palette
  // =========================================================================
  List<StreamAvatarColorPair> get avatarPalette => _avatarPalette ?? _themeData.colorScheme.avatarPalette;
  bool get avatarPaletteIsCustom => _avatarPalette != null;

  // =========================================================================
  // Component theme overrides
  // =========================================================================

  /// Component themes currently shown in the studio (added via
  /// [addComponentTheme]) — present even before any of their colors are
  /// customized, so the panel keeps rendering an empty section for them.
  Set<String> get activeComponentThemes => Set.unmodifiable(_componentOverrides.keys);

  /// A read-only deep snapshot of every active component's overrides.
  Map<String, Map<String, Color>> get componentOverrides => {
    for (final entry in _componentOverrides.entries) entry.key: Map.unmodifiable(entry.value),
  };

  Color? resolveComponentColor(String component, String property) => _componentOverrides[component]?[property];

  bool isComponentColorCustom(String component, String property) =>
      _componentOverrides[component]?.containsKey(property) ?? false;

  void addComponentTheme(String component) => _update(() => _componentOverrides.putIfAbsent(component, () => {}));

  void removeComponentTheme(String component) => _update(() => _componentOverrides.remove(component));

  void setComponentColor(String component, String property, Color color) =>
      _update(() => _componentOverrides.putIfAbsent(component, () => {})[property] = color);

  void resetComponentColor(String component, String property) =>
      _update(() => _componentOverrides[component]?.remove(property));

  // =========================================================================
  // Named getters used by buildMaterialTheme() (see AGENTS.md - "Use class
  // getters directly"). Everything else is read via resolve(slot).
  // =========================================================================
  Color get accentPrimary => resolve(ThemeColorSlot.accentPrimary);
  Color get accentNeutral => resolve(ThemeColorSlot.accentNeutral);
  Color get accentError => resolve(ThemeColorSlot.accentError);
  Color get textPrimary => resolve(ThemeColorSlot.textPrimary);
  Color get textSecondary => resolve(ThemeColorSlot.textSecondary);
  Color get textTertiary => resolve(ThemeColorSlot.textTertiary);
  Color get textDisabled => resolve(ThemeColorSlot.textDisabled);
  Color get textOnAccent => resolve(ThemeColorSlot.textOnAccent);
  Color get backgroundApp => resolve(ThemeColorSlot.backgroundApp);
  Color get backgroundSurface => resolve(ThemeColorSlot.backgroundSurface);
  Color get backgroundSurfaceSubtle => resolve(ThemeColorSlot.backgroundSurfaceSubtle);
  Color get backgroundSurfaceStrong => resolve(ThemeColorSlot.backgroundSurfaceStrong);
  Color get backgroundDisabled => resolve(ThemeColorSlot.backgroundDisabled);
  Color get borderDefault => resolve(ThemeColorSlot.borderDefault);
  Color get borderSubtle => resolve(ThemeColorSlot.borderSubtle);
  Color get systemScrollbar => resolve(ThemeColorSlot.systemScrollbar);

  // =========================================================================
  // Setters
  // =========================================================================

  void setBrightness(Brightness brightness) {
    if (_brightness == brightness) return;
    _brightness = brightness;
    _rebuildTheme();
    notifyListeners();
  }

  void setBrandPrimaryColor(Color color) => _update(() => _brandSeed = color);
  void setChromePrimaryColor(Color color) => _update(() => _chromeSeed = color);

  void resetBrand() => _update(() => _brandSeed = null);
  void resetChrome() => _update(() => _chromeSeed = null);

  void setAvatarPalette(List<StreamAvatarColorPair> palette) => _update(() => _avatarPalette = palette);
  void resetAvatarPalette() => _update(() => _avatarPalette = null);

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
    _overrides.clear();
    _brandSeed = null;
    _chromeSeed = null;
    _avatarPalette = null;
    _componentOverrides.clear();

    _rebuildTheme();
    notifyListeners();
  }

  /// Builds [name]'s component theme-data object from its current overrides,
  /// or `null` if it hasn't been added or has no colors set yet (in which
  /// case [StreamTheme] falls back to that component's own SDK default).
  Object? _buildComponentTheme(String name) {
    final values = _componentOverrides[name];
    if (values == null || values.isEmpty) return null;
    final descriptor = componentThemeDescriptors.firstWhere((d) => d.name == name);
    return descriptor.build(values);
  }

  void _rebuildTheme() {
    // Brand swatch, if the brand ("primary") color is customized.
    final effectiveBrand = _brandSeed != null
        ? StreamColorSwatch.fromColor(_brandSeed!, brightness: _brightness)
        : null;

    // Chrome swatch. Mirrors StreamColorScheme.fromSeed: an explicit chrome color wins;
    // otherwise, when a brand color is set but chrome isn't, derive chrome from brand at
    // neutral chroma so chrome-dependent colors still pick up the brand's hue.
    final effectiveChrome = _chromeSeed != null
        ? StreamColorSwatch.fromColor(_chromeSeed!, brightness: _brightness)
        : _brandSeed != null
        ? StreamColorSwatch.fromColor(
            _brandSeed!,
            brightness: _brightness,
            chroma: StreamColorScheme.neutralChroma,
          )
        : null;

    // Every other override is passed through as-is: StreamColorScheme.light()/.dark()
    // already treat null as "use the SDK default" and derive dependent colors internally.
    final buildScheme = _brightness == Brightness.dark ? StreamColorScheme.dark : StreamColorScheme.light;
    final colorScheme = buildScheme(
      // Brand
      brand: effectiveBrand,
      // Chrome
      chrome: effectiveChrome,
      // Accent
      accentPrimary: _overrides[ThemeColorSlot.accentPrimary],
      accentSuccess: _overrides[ThemeColorSlot.accentSuccess],
      accentWarning: _overrides[ThemeColorSlot.accentWarning],
      accentError: _overrides[ThemeColorSlot.accentError],
      accentNeutral: _overrides[ThemeColorSlot.accentNeutral],
      // Text
      textPrimary: _overrides[ThemeColorSlot.textPrimary],
      textSecondary: _overrides[ThemeColorSlot.textSecondary],
      textTertiary: _overrides[ThemeColorSlot.textTertiary],
      textDisabled: _overrides[ThemeColorSlot.textDisabled],
      textLink: _overrides[ThemeColorSlot.textLink],
      textOnAccent: _overrides[ThemeColorSlot.textOnAccent],
      textOnInverse: _overrides[ThemeColorSlot.textOnInverse],
      // Background
      backgroundApp: _overrides[ThemeColorSlot.backgroundApp],
      backgroundSurface: _overrides[ThemeColorSlot.backgroundSurface],
      backgroundSurfaceSubtle: _overrides[ThemeColorSlot.backgroundSurfaceSubtle],
      backgroundSurfaceStrong: _overrides[ThemeColorSlot.backgroundSurfaceStrong],
      backgroundSurfaceCard: _overrides[ThemeColorSlot.backgroundSurfaceCard],
      backgroundOnAccent: _overrides[ThemeColorSlot.backgroundOnAccent],
      backgroundHighlight: _overrides[ThemeColorSlot.backgroundHighlight],
      backgroundScrim: _overrides[ThemeColorSlot.backgroundScrim],
      backgroundOverlayLight: _overrides[ThemeColorSlot.backgroundOverlayLight],
      backgroundOverlayDark: _overrides[ThemeColorSlot.backgroundOverlayDark],
      backgroundDisabled: _overrides[ThemeColorSlot.backgroundDisabled],
      backgroundInverse: _overrides[ThemeColorSlot.backgroundInverse],
      backgroundElevation0: _overrides[ThemeColorSlot.backgroundElevation0],
      backgroundElevation1: _overrides[ThemeColorSlot.backgroundElevation1],
      backgroundElevation2: _overrides[ThemeColorSlot.backgroundElevation2],
      backgroundElevation3: _overrides[ThemeColorSlot.backgroundElevation3],
      // Border - Core
      borderDefault: _overrides[ThemeColorSlot.borderDefault],
      borderSubtle: _overrides[ThemeColorSlot.borderSubtle],
      borderStrong: _overrides[ThemeColorSlot.borderStrong],
      borderOnAccent: _overrides[ThemeColorSlot.borderOnAccent],
      borderOnInverse: _overrides[ThemeColorSlot.borderOnInverse],
      borderOnSurface: _overrides[ThemeColorSlot.borderOnSurface],
      borderOpacitySubtle: _overrides[ThemeColorSlot.borderOpacitySubtle],
      borderOpacityStrong: _overrides[ThemeColorSlot.borderOpacityStrong],
      // Border - Utility
      borderFocus: _overrides[ThemeColorSlot.borderFocus],
      borderDisabled: _overrides[ThemeColorSlot.borderDisabled],
      borderDisabledOnSurface: _overrides[ThemeColorSlot.borderDisabledOnSurface],
      borderHover: _overrides[ThemeColorSlot.borderHover],
      borderPressed: _overrides[ThemeColorSlot.borderPressed],
      borderActive: _overrides[ThemeColorSlot.borderActive],
      borderError: _overrides[ThemeColorSlot.borderError],
      borderWarning: _overrides[ThemeColorSlot.borderWarning],
      borderSuccess: _overrides[ThemeColorSlot.borderSuccess],
      borderSelected: _overrides[ThemeColorSlot.borderSelected],
      // State
      backgroundHover: _overrides[ThemeColorSlot.backgroundHover],
      backgroundPressed: _overrides[ThemeColorSlot.backgroundPressed],
      backgroundSelected: _overrides[ThemeColorSlot.backgroundSelected],
      // System
      systemText: _overrides[ThemeColorSlot.systemText],
      systemScrollbar: _overrides[ThemeColorSlot.systemScrollbar],
      // Avatar
      avatarPalette: _avatarPalette,
    );

    _themeData = StreamTheme(
      brightness: _brightness,
      colorScheme: colorScheme,
      avatarTheme: _buildComponentTheme('Avatar') as StreamAvatarThemeData?,
      badgeCountTheme: _buildComponentTheme('Badge Count') as StreamBadgeCountThemeData?,
      badgeNotificationTheme: _buildComponentTheme('Badge Notification') as StreamBadgeNotificationThemeData?,
      onlineIndicatorTheme: _buildComponentTheme('Online Indicator') as StreamOnlineIndicatorThemeData?,
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
