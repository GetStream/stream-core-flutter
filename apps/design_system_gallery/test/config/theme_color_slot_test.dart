import 'package:design_system_gallery/config/theme_color_slot.dart';
import 'package:design_system_gallery/config/theme_studio_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('ThemeColorSlot', () {
    test('covers exactly the Color? parameters of StreamColorScheme.light/.dark, in order', () {
      // Pinned against StreamColorScheme.light's parameter list
      // (packages/stream_core_flutter/lib/src/theme/semantics/stream_color_scheme.dart).
      //
      // If this fails because a color was added to the SDK: add a matching
      // ThemeColorSlot value (and extend this list). If it fails for any other
      // reason, a slot was renamed or dropped by mistake.
      const expectedParameterNames = [
        'accentPrimary',
        'accentSuccess',
        'accentWarning',
        'accentError',
        'accentNeutral',
        'textPrimary',
        'textSecondary',
        'textTertiary',
        'textDisabled',
        'textLink',
        'textOnAccent',
        'textOnInverse',
        'backgroundApp',
        'backgroundSurface',
        'backgroundSurfaceSubtle',
        'backgroundSurfaceStrong',
        'backgroundSurfaceCard',
        'backgroundOnAccent',
        'backgroundHighlight',
        'backgroundScrim',
        'backgroundOverlayLight',
        'backgroundOverlayDark',
        'backgroundDisabled',
        'backgroundInverse',
        'backgroundElevation0',
        'backgroundElevation1',
        'backgroundElevation2',
        'backgroundElevation3',
        'borderDefault',
        'borderSubtle',
        'borderStrong',
        'borderOnAccent',
        'borderOnInverse',
        'borderOnSurface',
        'borderOpacitySubtle',
        'borderOpacityStrong',
        'borderFocus',
        'borderDisabled',
        'borderDisabledOnSurface',
        'borderHover',
        'borderPressed',
        'borderActive',
        'borderError',
        'borderWarning',
        'borderSuccess',
        'borderSelected',
        'backgroundHover',
        'backgroundPressed',
        'backgroundSelected',
        'systemText',
        'systemScrollbar',
      ];

      expect(ThemeColorSlot.values.map((s) => s.parameterName).toList(), expectedParameterNames);
    });

    test('every parameter name is unique', () {
      final names = ThemeColorSlot.values.map((s) => s.parameterName);
      expect(names.toSet(), hasLength(names.length));
    });

    test('each slot.read reads back the value passed to its matching StreamColorScheme parameter', () {
      // Every parameter gets a distinct color so a swapped or duplicated reader is caught.
      final values = <String, Color>{
        for (final (index, slot) in ThemeColorSlot.values.indexed) slot.parameterName: Color(0xFF000000 | index),
      };

      final scheme = StreamColorScheme.light(
        accentPrimary: values['accentPrimary'],
        accentSuccess: values['accentSuccess'],
        accentWarning: values['accentWarning'],
        accentError: values['accentError'],
        accentNeutral: values['accentNeutral'],
        textPrimary: values['textPrimary'],
        textSecondary: values['textSecondary'],
        textTertiary: values['textTertiary'],
        textDisabled: values['textDisabled'],
        textLink: values['textLink'],
        textOnAccent: values['textOnAccent'],
        textOnInverse: values['textOnInverse'],
        backgroundApp: values['backgroundApp'],
        backgroundSurface: values['backgroundSurface'],
        backgroundSurfaceSubtle: values['backgroundSurfaceSubtle'],
        backgroundSurfaceStrong: values['backgroundSurfaceStrong'],
        backgroundSurfaceCard: values['backgroundSurfaceCard'],
        backgroundOnAccent: values['backgroundOnAccent'],
        backgroundHighlight: values['backgroundHighlight'],
        backgroundScrim: values['backgroundScrim'],
        backgroundOverlayLight: values['backgroundOverlayLight'],
        backgroundOverlayDark: values['backgroundOverlayDark'],
        backgroundDisabled: values['backgroundDisabled'],
        backgroundInverse: values['backgroundInverse'],
        backgroundElevation0: values['backgroundElevation0'],
        backgroundElevation1: values['backgroundElevation1'],
        backgroundElevation2: values['backgroundElevation2'],
        backgroundElevation3: values['backgroundElevation3'],
        borderDefault: values['borderDefault'],
        borderSubtle: values['borderSubtle'],
        borderStrong: values['borderStrong'],
        borderOnAccent: values['borderOnAccent'],
        borderOnInverse: values['borderOnInverse'],
        borderOnSurface: values['borderOnSurface'],
        borderOpacitySubtle: values['borderOpacitySubtle'],
        borderOpacityStrong: values['borderOpacityStrong'],
        borderFocus: values['borderFocus'],
        borderDisabled: values['borderDisabled'],
        borderDisabledOnSurface: values['borderDisabledOnSurface'],
        borderHover: values['borderHover'],
        borderPressed: values['borderPressed'],
        borderActive: values['borderActive'],
        borderError: values['borderError'],
        borderWarning: values['borderWarning'],
        borderSuccess: values['borderSuccess'],
        borderSelected: values['borderSelected'],
        backgroundHover: values['backgroundHover'],
        backgroundPressed: values['backgroundPressed'],
        backgroundSelected: values['backgroundSelected'],
        systemText: values['systemText'],
        systemScrollbar: values['systemScrollbar'],
      );

      for (final slot in ThemeColorSlot.values) {
        expect(slot.read(scheme), values[slot.parameterName], reason: 'slot ${slot.name}');
      }
    });
  });

  group('themeStudioSections', () {
    test('covers every ThemeColorSlot exactly once', () {
      final slotsInSections = themeStudioSections.expand((section) => section.slots).toList();
      expect(slotsInSections.toSet(), ThemeColorSlot.values.toSet());
      expect(slotsInSections, hasLength(ThemeColorSlot.values.length));
    });
  });
}
