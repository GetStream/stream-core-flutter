import 'package:flutter/material.dart';

import 'theme_color_slot.dart';

/// A named run of [ThemeColorSlot]s within a [ThemeStudioSection].
///
/// Most sections have a single, unnamed group. `Background Colors` splits
/// into three ("main", "Surface", "Elevation") to match the sub-headings the
/// theme studio panel has always shown.
class ThemeStudioSlotGroup {
  const ThemeStudioSlotGroup({this.heading, required this.slots});

  /// Optional sub-heading rendered above [slots] (e.g. `'Surface'`).
  final String? heading;

  final List<ThemeColorSlot> slots;
}

/// A group of [ThemeColorSlot]s shown together, mirroring one
/// [StreamColorScheme] concern (accent, text, background, ...).
///
/// This is the single source of truth consumed by the theme studio panel,
/// the export page, and the code generator's ordering — add a new color here
/// once and all three pick it up.
class ThemeStudioSection {
  const ThemeStudioSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.groups,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<ThemeStudioSlotGroup> groups;

  /// All slots in this section, flattened across [groups].
  Iterable<ThemeColorSlot> get slots => groups.expand((g) => g.slots);
}

/// The ordered list of color sections, matching [StreamColorScheme.light]'s
/// parameter order.
///
/// `Appearance`, `Brand Color`, `Chrome Color`, and `Avatar Palette` are not
/// represented here: brightness is a single value (not a slot), brand/chrome
/// are [ThemeSeedSlot]s with a different write path, and the avatar palette
/// is a `List<StreamAvatarColorPair>`, not a color.
const themeStudioSections = <ThemeStudioSection>[
  ThemeStudioSection(
    title: 'Accent Colors',
    subtitle: 'accent*',
    icon: Icons.color_lens,
    groups: [
      ThemeStudioSlotGroup(
        slots: [
          ThemeColorSlot.accentPrimary,
          ThemeColorSlot.accentSuccess,
          ThemeColorSlot.accentWarning,
          ThemeColorSlot.accentError,
          ThemeColorSlot.accentNeutral,
        ],
      ),
    ],
  ),
  ThemeStudioSection(
    title: 'Text Colors',
    subtitle: 'text*',
    icon: Icons.format_color_text,
    groups: [
      ThemeStudioSlotGroup(
        slots: [
          ThemeColorSlot.textPrimary,
          ThemeColorSlot.textSecondary,
          ThemeColorSlot.textTertiary,
          ThemeColorSlot.textDisabled,
          ThemeColorSlot.textLink,
          ThemeColorSlot.textOnAccent,
          ThemeColorSlot.textOnInverse,
        ],
      ),
    ],
  ),
  ThemeStudioSection(
    title: 'Background Colors',
    subtitle: 'background*',
    icon: Icons.format_paint,
    groups: [
      ThemeStudioSlotGroup(
        slots: [
          ThemeColorSlot.backgroundApp,
          ThemeColorSlot.backgroundInverse,
          ThemeColorSlot.backgroundOnAccent,
          ThemeColorSlot.backgroundHighlight,
          ThemeColorSlot.backgroundScrim,
          ThemeColorSlot.backgroundOverlayLight,
          ThemeColorSlot.backgroundOverlayDark,
          ThemeColorSlot.backgroundDisabled,
          ThemeColorSlot.backgroundHover,
          ThemeColorSlot.backgroundPressed,
          ThemeColorSlot.backgroundSelected,
        ],
      ),
      ThemeStudioSlotGroup(
        heading: 'Surface',
        slots: [
          ThemeColorSlot.backgroundSurface,
          ThemeColorSlot.backgroundSurfaceSubtle,
          ThemeColorSlot.backgroundSurfaceStrong,
          ThemeColorSlot.backgroundSurfaceCard,
        ],
      ),
      ThemeStudioSlotGroup(
        heading: 'Elevation',
        slots: [
          ThemeColorSlot.backgroundElevation0,
          ThemeColorSlot.backgroundElevation1,
          ThemeColorSlot.backgroundElevation2,
          ThemeColorSlot.backgroundElevation3,
        ],
      ),
    ],
  ),
  ThemeStudioSection(
    title: 'Border Colors - Core',
    subtitle: 'border*',
    icon: Icons.border_all,
    groups: [
      ThemeStudioSlotGroup(
        slots: [
          ThemeColorSlot.borderDefault,
          ThemeColorSlot.borderSubtle,
          ThemeColorSlot.borderStrong,
          ThemeColorSlot.borderOnAccent,
          ThemeColorSlot.borderOnInverse,
          ThemeColorSlot.borderOnSurface,
          ThemeColorSlot.borderOpacitySubtle,
          ThemeColorSlot.borderOpacityStrong,
        ],
      ),
    ],
  ),
  ThemeStudioSection(
    title: 'Border Colors - Utility',
    subtitle: 'border*',
    icon: Icons.border_style,
    groups: [
      ThemeStudioSlotGroup(
        slots: [
          ThemeColorSlot.borderFocus,
          ThemeColorSlot.borderActive,
          ThemeColorSlot.borderHover,
          ThemeColorSlot.borderPressed,
          ThemeColorSlot.borderDisabled,
          ThemeColorSlot.borderDisabledOnSurface,
          ThemeColorSlot.borderError,
          ThemeColorSlot.borderWarning,
          ThemeColorSlot.borderSuccess,
          ThemeColorSlot.borderSelected,
        ],
      ),
    ],
  ),
  ThemeStudioSection(
    title: 'System Colors',
    subtitle: 'system*',
    icon: Icons.settings_system_daydream,
    groups: [
      ThemeStudioSlotGroup(
        slots: [
          ThemeColorSlot.systemText,
          ThemeColorSlot.systemScrollbar,
        ],
      ),
    ],
  ),
];
