import 'package:flutter/material.dart';

import '../core/theme_code_generator.dart';
import 'theme_color_slot.dart';
import 'theme_configuration.dart';

/// Drives the export page: two independent [ThemeConfiguration]s (one per
/// brightness) seeded from the theme studio's current, brightness-agnostic
/// state, plus which [ThemeColorSlot]/[ThemeSeedSlot]s/component colors are
/// currently "linked" (edited together) vs. unlinked (edited independently).
/// brand, chrome and accent* colors default to linked; everything else
/// defaults to unlinked (see the comment on `_unlinkedSlots` below).
///
/// Never writes back to the studio [ThemeConfiguration] it was seeded from —
/// export is one-way.
class ThemeExportConfiguration extends ChangeNotifier {
  ThemeExportConfiguration(ThemeConfiguration studio)
    : light = ThemeConfiguration.seededFrom(studio, brightness: Brightness.light),
      dark = ThemeConfiguration.seededFrom(studio, brightness: Brightness.dark) {
    light.addListener(_handleChildChanged);
    dark.addListener(_handleChildChanged);
  }

  final ThemeConfiguration light;
  final ThemeConfiguration dark;

  ThemeConfiguration _side(Brightness brightness) => brightness == Brightness.light ? light : dark;

  // brand, chrome and accent* colors are usually shared between light and
  // dark themes, so they start linked. Nearly everything else (text*,
  // background*, border*, state, system*) is typically *inverted* between
  // brightnesses - e.g. textPrimary is dark-on-light in light mode and
  // light-on-dark in dark mode - so linking those by default would mean the
  // very first edit overwrites one side with a value that's wrong for it.
  // They start unlinked instead.
  final Set<ThemeColorSlot> _unlinkedSlots = {
    for (final slot in ThemeColorSlot.values)
      if (!slot.parameterName.startsWith('accent')) slot,
  };
  final Set<ThemeSeedSlot> _unlinkedSeeds = {};

  bool isSlotLinked(ThemeColorSlot slot) => !_unlinkedSlots.contains(slot);
  bool isSeedLinked(ThemeSeedSlot seed) => !_unlinkedSeeds.contains(seed);

  // Toggling link state doesn't force light/dark back in sync - it only
  // changes where the *next* edit goes. Auto-syncing on re-link would
  // silently discard whichever side's value came from being unlinked.
  void toggleSlotLinked(ThemeColorSlot slot) {
    if (!_unlinkedSlots.remove(slot)) _unlinkedSlots.add(slot);
    notifyListeners();
  }

  void toggleSeedLinked(ThemeSeedSlot seed) {
    if (!_unlinkedSeeds.remove(seed)) _unlinkedSeeds.add(seed);
    notifyListeners();
  }

  /// Sets [slot] to [color], starting from an edit made on [from]'s column.
  /// When linked, both sides get [color]; when unlinked, only [from] does.
  void setColor(ThemeColorSlot slot, Color color, {required Brightness from}) {
    if (isSlotLinked(slot)) {
      light.setOverride(slot, color);
      dark.setOverride(slot, color);
    } else {
      _side(from).setOverride(slot, color);
    }
  }

  void resetColor(ThemeColorSlot slot, {required Brightness from}) {
    if (isSlotLinked(slot)) {
      light.resetOverride(slot);
      dark.resetOverride(slot);
    } else {
      _side(from).resetOverride(slot);
    }
  }

  void setSeed(ThemeSeedSlot seed, Color color, {required Brightness from}) {
    void apply(ThemeConfiguration config) =>
        seed == ThemeSeedSlot.brand ? config.setBrandPrimaryColor(color) : config.setChromePrimaryColor(color);

    if (isSeedLinked(seed)) {
      apply(light);
      apply(dark);
    } else {
      apply(_side(from));
    }
  }

  void resetSeed(ThemeSeedSlot seed, {required Brightness from}) {
    void apply(ThemeConfiguration config) => seed == ThemeSeedSlot.brand ? config.resetBrand() : config.resetChrome();

    if (isSeedLinked(seed)) {
      apply(light);
      apply(dark);
    } else {
      apply(_side(from));
    }
  }

  // Component theme colors, keyed by "component::property". Add/remove of a
  // whole component always applies to both sides together (there's no
  // per-brightness set of active components). Individual property colors
  // start unlinked, same reasoning as everything but brand/chrome/accent*
  // above - a badge or online-indicator background is just as likely to
  // need different light/dark values as a background/border color is.
  final Set<String> _linkedComponentColors = {};

  String _componentKey(String component, String property) => '$component::$property';

  /// The component themes currently active (added via [addComponentTheme]),
  /// present even before any of their colors are customized. Both sides
  /// always agree since add/remove is applied to both together.
  Set<String> get activeComponentThemes => light.activeComponentThemes;

  void addComponentTheme(String component) {
    light.addComponentTheme(component);
    dark.addComponentTheme(component);
  }

  void removeComponentTheme(String component) {
    light.removeComponentTheme(component);
    dark.removeComponentTheme(component);
    _linkedComponentColors.removeWhere((key) => key.startsWith('$component::'));
  }

  bool isComponentColorLinked(String component, String property) =>
      _linkedComponentColors.contains(_componentKey(component, property));

  void toggleComponentColorLinked(String component, String property) {
    final key = _componentKey(component, property);
    if (!_linkedComponentColors.remove(key)) _linkedComponentColors.add(key);
    notifyListeners();
  }

  void setComponentColor(String component, String property, Color color, {required Brightness from}) {
    if (isComponentColorLinked(component, property)) {
      light.setComponentColor(component, property, color);
      dark.setComponentColor(component, property, color);
    } else {
      _side(from).setComponentColor(component, property, color);
    }
  }

  void resetComponentColor(String component, String property, {required Brightness from}) {
    if (isComponentColorLinked(component, property)) {
      light.resetComponentColor(component, property);
      dark.resetComponentColor(component, property);
    } else {
      _side(from).resetComponentColor(component, property);
    }
  }

  // ThemeData is expensive to compare (it and StreamTheme's ~45 component
  // sub-themes are compared field-by-field by InheritedTheme), so it's built
  // once per change and handed out by reference rather than rebuilt on every
  // row's Theme(...) wrapper.
  ThemeData? _lightMaterialTheme;
  ThemeData? _darkMaterialTheme;

  ThemeData get lightMaterialTheme => _lightMaterialTheme ??= light.buildMaterialTheme();
  ThemeData get darkMaterialTheme => _darkMaterialTheme ??= dark.buildMaterialTheme();

  void _handleChildChanged() {
    _lightMaterialTheme = null;
    _darkMaterialTheme = null;
    notifyListeners();
  }

  /// Generates the copy-pasteable Dart snippet for the current state.
  String generateCode() => generateThemeCode(
    light: ThemeExportSide(
      overrides: light.overrides,
      brandSeed: light.brandIsCustom ? light.brandPrimaryColor : null,
      chromeSeed: light.chromeIsCustom ? light.chromePrimaryColor : null,
      avatarPalette: light.avatarPaletteIsCustom ? light.avatarPalette : null,
      componentOverrides: light.componentOverrides,
    ),
    dark: ThemeExportSide(
      overrides: dark.overrides,
      brandSeed: dark.brandIsCustom ? dark.brandPrimaryColor : null,
      chromeSeed: dark.chromeIsCustom ? dark.chromePrimaryColor : null,
      avatarPalette: dark.avatarPaletteIsCustom ? dark.avatarPalette : null,
      componentOverrides: dark.componentOverrides,
    ),
  );

  @override
  void dispose() {
    light.removeListener(_handleChildChanged);
    dark.removeListener(_handleChildChanged);
    light.dispose();
    dark.dispose();
    super.dispose();
  }
}
