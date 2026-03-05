import 'package:design_system_gallery/config/theme_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeConfiguration', () {
    test('creates with default light brightness', () {
      final config = ThemeConfiguration();
      expect(config.brightness, Brightness.light);
    });

    test('creates with dark brightness', () {
      final config = ThemeConfiguration(brightness: Brightness.dark);
      expect(config.brightness, Brightness.dark);
    });

    test('light factory creates light theme', () {
      final config = ThemeConfiguration.light();
      expect(config.brightness, Brightness.light);
    });

    test('dark factory creates dark theme', () {
      final config = ThemeConfiguration.dark();
      expect(config.brightness, Brightness.dark);
    });

    test('themeData is initialized', () {
      final config = ThemeConfiguration();
      expect(config.themeData, isNotNull);
    });

    test('setBrightness changes brightness', () {
      final config = ThemeConfiguration();
      config.setBrightness(Brightness.dark);
      expect(config.brightness, Brightness.dark);
    });

    test('setBrightness notifies listeners', () {
      final config = ThemeConfiguration();
      var notified = false;
      config.addListener(() => notified = true);
      config.setBrightness(Brightness.dark);
      expect(notified, isTrue);
    });

    test('setBrightness with same value does not notify', () {
      final config = ThemeConfiguration();
      var notifyCount = 0;
      config.addListener(() => notifyCount++);
      config.setBrightness(Brightness.light);
      expect(notifyCount, 0);
    });

    group('accent colors', () {
      test('setAccentPrimary updates and notifies', () {
        final config = ThemeConfiguration();
        var notified = false;
        config.addListener(() => notified = true);
        config.setAccentPrimary(Colors.blue);
        expect(config.accentPrimary, Colors.blue);
        expect(notified, isTrue);
      });

      test('setAccentSuccess updates and notifies', () {
        final config = ThemeConfiguration();
        var notified = false;
        config.addListener(() => notified = true);
        config.setAccentSuccess(Colors.green);
        expect(config.accentSuccess, Colors.green);
        expect(notified, isTrue);
      });

      test('setAccentWarning updates and notifies', () {
        final config = ThemeConfiguration();
        config.setAccentWarning(Colors.orange);
        expect(config.accentWarning, Colors.orange);
      });

      test('setAccentError updates and notifies', () {
        final config = ThemeConfiguration();
        config.setAccentError(Colors.red);
        expect(config.accentError, Colors.red);
      });

      test('setAccentNeutral updates and notifies', () {
        final config = ThemeConfiguration();
        config.setAccentNeutral(Colors.grey);
        expect(config.accentNeutral, Colors.grey);
      });
    });

    group('text colors', () {
      test('setTextPrimary updates', () {
        final config = ThemeConfiguration();
        config.setTextPrimary(Colors.black);
        expect(config.textPrimary, Colors.black);
      });

      test('setTextSecondary updates', () {
        final config = ThemeConfiguration();
        config.setTextSecondary(Colors.grey);
        expect(config.textSecondary, Colors.grey);
      });

      test('setTextTertiary updates', () {
        final config = ThemeConfiguration();
        config.setTextTertiary(Colors.grey);
        expect(config.textTertiary, Colors.grey);
      });

      test('setTextDisabled updates', () {
        final config = ThemeConfiguration();
        config.setTextDisabled(Colors.grey);
        expect(config.textDisabled, Colors.grey);
      });

      test('setTextInverse updates', () {
        final config = ThemeConfiguration();
        config.setTextInverse(Colors.white);
        expect(config.textInverse, Colors.white);
      });

      test('setTextLink updates', () {
        final config = ThemeConfiguration();
        config.setTextLink(Colors.blue);
        expect(config.textLink, Colors.blue);
      });

      test('setTextOnAccent updates', () {
        final config = ThemeConfiguration();
        config.setTextOnAccent(Colors.white);
        expect(config.textOnAccent, Colors.white);
      });
    });

    group('background colors', () {
      test('setBackgroundApp updates', () {
        final config = ThemeConfiguration();
        config.setBackgroundApp(Colors.white);
        expect(config.backgroundApp, Colors.white);
      });

      test('setBackgroundSurface updates', () {
        final config = ThemeConfiguration();
        config.setBackgroundSurface(Colors.white);
        expect(config.backgroundSurface, Colors.white);
      });

      test('setBackgroundSurfaceSubtle updates', () {
        final config = ThemeConfiguration();
        config.setBackgroundSurfaceSubtle(Colors.grey.shade100);
        expect(config.backgroundSurfaceSubtle, Colors.grey.shade100);
      });

      test('setBackgroundSurfaceStrong updates', () {
        final config = ThemeConfiguration();
        config.setBackgroundSurfaceStrong(Colors.grey.shade200);
        expect(config.backgroundSurfaceStrong, Colors.grey.shade200);
      });

      test('setBackgroundOverlay updates', () {
        final config = ThemeConfiguration();
        config.setBackgroundOverlay(Colors.black.withAlpha(128));
        expect(config.backgroundOverlay.alpha, 128);
      });

      test('setBackgroundDisabled updates', () {
        final config = ThemeConfiguration();
        config.setBackgroundDisabled(Colors.grey);
        expect(config.backgroundDisabled, Colors.grey);
      });
    });

    group('border colors', () {
      test('setBorderDefault updates', () {
        final config = ThemeConfiguration();
        config.setBorderDefault(Colors.grey);
        expect(config.borderDefault, Colors.grey);
      });

      test('setBorderSubtle updates', () {
        final config = ThemeConfiguration();
        config.setBorderSubtle(Colors.grey.shade200);
        expect(config.borderSubtle, Colors.grey.shade200);
      });

      test('setBorderStrong updates', () {
        final config = ThemeConfiguration();
        config.setBorderStrong(Colors.grey.shade800);
        expect(config.borderStrong, Colors.grey.shade800);
      });

      test('setBorderFocus updates', () {
        final config = ThemeConfiguration();
        config.setBorderFocus(Colors.blue);
        expect(config.borderFocus, Colors.blue);
      });

      test('setBorderError updates', () {
        final config = ThemeConfiguration();
        config.setBorderError(Colors.red);
        expect(config.borderError, Colors.red);
      });
    });

    group('state colors', () {
      test('setStateHover updates', () {
        final config = ThemeConfiguration();
        config.setStateHover(Colors.grey.shade100);
        expect(config.stateHover.value, Colors.grey.shade100.value);
      });

      test('setStatePressed updates', () {
        final config = ThemeConfiguration();
        config.setStatePressed(Colors.grey.shade200);
        expect(config.statePressed.value, Colors.grey.shade200.value);
      });

      test('setStateSelected updates', () {
        final config = ThemeConfiguration();
        config.setStateSelected(Colors.blue.shade100);
        expect(config.stateSelected.value, Colors.blue.shade100.value);
      });

      test('setStateFocused updates', () {
        final config = ThemeConfiguration();
        config.setStateFocused(Colors.blue.shade50);
        expect(config.stateFocused.value, Colors.blue.shade50.value);
      });

      test('setStateDisabled updates', () {
        final config = ThemeConfiguration();
        config.setStateDisabled(Colors.grey.shade300);
        expect(config.stateDisabled.value, Colors.grey.shade300.value);
      });
    });

    group('system colors', () {
      test('setSystemText updates', () {
        final config = ThemeConfiguration();
        config.setSystemText(Colors.black);
        expect(config.systemText, Colors.black);
      });

      test('setSystemScrollbar updates', () {
        final config = ThemeConfiguration();
        config.setSystemScrollbar(Colors.grey);
        expect(config.systemScrollbar, Colors.grey);
      });
    });

    group('brand color', () {
      test('setBrandPrimaryColor updates', () {
        final config = ThemeConfiguration();
        config.setBrandPrimaryColor(Colors.purple);
        expect(config.brandPrimaryColor, Colors.purple);
      });

      test('brand color affects accent primary', () {
        final config = ThemeConfiguration();
        config.setBrandPrimaryColor(Colors.purple);
        expect(config.accentPrimary, Colors.purple);
      });
    });

    group('resetToDefaults', () {
      test('resets all customizations', () {
        final config = ThemeConfiguration();
        config.setAccentPrimary(Colors.blue);
        config.setTextPrimary(Colors.black);
        config.setBorderDefault(Colors.grey);

        config.resetToDefaults();

        // Values should be reset to defaults
        expect(config.themeData, isNotNull);
      });

      test('notifies listeners on reset', () {
        final config = ThemeConfiguration();
        var notified = false;
        config.addListener(() => notified = true);
        config.resetToDefaults();
        expect(notified, isTrue);
      });
    });

    group('buildMaterialTheme', () {
      test('creates ThemeData', () {
        final config = ThemeConfiguration();
        final themeData = config.buildMaterialTheme();
        expect(themeData, isNotNull);
      });

      test('has correct brightness', () {
        final lightConfig = ThemeConfiguration.light();
        final darkConfig = ThemeConfiguration.dark();

        expect(lightConfig.buildMaterialTheme().brightness, Brightness.light);
        expect(darkConfig.buildMaterialTheme().brightness, Brightness.dark);
      });

      test('enables Material 3', () {
        final config = ThemeConfiguration();
        final themeData = config.buildMaterialTheme();
        expect(themeData.useMaterial3, isTrue);
      });

      test('includes StreamTheme extension', () {
        final config = ThemeConfiguration();
        final themeData = config.buildMaterialTheme();
        expect(themeData.extensions.isNotEmpty, isTrue);
      });

      test('sets scaffold background color', () {
        final config = ThemeConfiguration();
        final themeData = config.buildMaterialTheme();
        expect(themeData.scaffoldBackgroundColor, isNotNull);
      });

      test('configures dialog theme', () {
        final config = ThemeConfiguration();
        final themeData = config.buildMaterialTheme();
        expect(themeData.dialogTheme, isNotNull);
        expect(themeData.dialogTheme.backgroundColor, isNotNull);
      });

      test('configures appBar theme', () {
        final config = ThemeConfiguration();
        final themeData = config.buildMaterialTheme();
        expect(themeData.appBarTheme, isNotNull);
        expect(themeData.appBarTheme.elevation, 0);
      });

      test('configures button themes', () {
        final config = ThemeConfiguration();
        final themeData = config.buildMaterialTheme();
        expect(themeData.filledButtonTheme, isNotNull);
        expect(themeData.outlinedButtonTheme, isNotNull);
        expect(themeData.textButtonTheme, isNotNull);
        expect(themeData.elevatedButtonTheme, isNotNull);
      });

      test('configures input decoration theme', () {
        final config = ThemeConfiguration();
        final themeData = config.buildMaterialTheme();
        expect(themeData.inputDecorationTheme, isNotNull);
        expect(themeData.inputDecorationTheme.filled, isTrue);
      });

      test('configures scrollbar theme', () {
        final config = ThemeConfiguration();
        final themeData = config.buildMaterialTheme();
        expect(themeData.scrollbarTheme, isNotNull);
      });

      test('configures text theme', () {
        final config = ThemeConfiguration();
        final themeData = config.buildMaterialTheme();
        expect(themeData.textTheme, isNotNull);
        expect(themeData.textTheme.bodyMedium, isNotNull);
      });

      test('custom colors are applied', () {
        final config = ThemeConfiguration();
        config.setAccentPrimary(Colors.purple);
        final themeData = config.buildMaterialTheme();
        expect(themeData.colorScheme.primary, Colors.purple);
      });
    });

    group('edge cases', () {
      test('setting same brightness twice', () {
        final config = ThemeConfiguration();
        var notifyCount = 0;
        config.addListener(() => notifyCount++);
        config.setBrightness(Brightness.light);
        config.setBrightness(Brightness.light);
        expect(notifyCount, 0);
      });

      test('multiple listeners are notified', () {
        final config = ThemeConfiguration();
        var count1 = 0;
        var count2 = 0;
        config.addListener(() => count1++);
        config.addListener(() => count2++);
        config.setAccentPrimary(Colors.blue);
        expect(count1, 1);
        expect(count2, 1);
      });

      test('can be disposed', () {
        final config = ThemeConfiguration();
        config.dispose();
        // Should not throw
      });

      test('multiple color updates trigger single rebuild', () {
        final config = ThemeConfiguration();
        var notifyCount = 0;
        config.addListener(() => notifyCount++);
        config.setAccentPrimary(Colors.blue);
        expect(notifyCount, 1);
      });
    });
  });
}