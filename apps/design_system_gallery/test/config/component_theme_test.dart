import 'package:design_system_gallery/config/component_theme_descriptors.dart';
import 'package:design_system_gallery/config/theme_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Avatar is excluded from the addable component themes list', () {
    // Avatar's color story is the Avatar Palette section (rotating
    // background/foreground pairs consumed by downstream packages like
    // stream_chat_flutter), not a single fixed override like the other
    // component themes - offering it here would duplicate/conflict with that.
    expect(componentThemeDescriptors.map((d) => d.name), isNot(contains('Avatar')));
  });

  group('ThemeConfiguration component theme overrides', () {
    late ThemeConfiguration config;

    setUp(() => config = ThemeConfiguration.light());
    tearDown(() => config.dispose());

    test('a component is inactive until added', () {
      expect(config.activeComponentThemes, isEmpty);
      expect(config.resolveComponentColor('Online Indicator', 'backgroundOnline'), isNull);
      expect(config.isComponentColorCustom('Online Indicator', 'backgroundOnline'), isFalse);
    });

    test('addComponentTheme makes the component active with no colors set yet', () {
      config.addComponentTheme('Online Indicator');

      expect(config.activeComponentThemes, {'Online Indicator'});
      expect(config.isComponentColorCustom('Online Indicator', 'backgroundOnline'), isFalse);
      // themeData shouldn't carry an override just from being "added" with
      // nothing set - that would be indistinguishable from the SDK default.
      expect(config.themeData.onlineIndicatorTheme.backgroundOnline, isNull);
    });

    test('setComponentColor customizes a property and flows into themeData', () {
      config.addComponentTheme('Online Indicator');
      config.setComponentColor('Online Indicator', 'backgroundOnline', const Color(0xFF112233));

      expect(config.resolveComponentColor('Online Indicator', 'backgroundOnline'), const Color(0xFF112233));
      expect(config.isComponentColorCustom('Online Indicator', 'backgroundOnline'), isTrue);
      expect(config.themeData.onlineIndicatorTheme.backgroundOnline, const Color(0xFF112233));
      // The other property on the same component stays untouched.
      expect(config.isComponentColorCustom('Online Indicator', 'backgroundOffline'), isFalse);
    });

    test('setComponentColor implicitly activates the component', () {
      // Setting a color directly (without an explicit addComponentTheme call
      // first) should still work and register the component as active.
      config.setComponentColor('Badge Count', 'textColor', const Color(0xFF000000));

      expect(config.activeComponentThemes, contains('Badge Count'));
    });

    test('resetComponentColor clears just that property', () {
      config.addComponentTheme('Online Indicator');
      config.setComponentColor('Online Indicator', 'backgroundOnline', const Color(0xFF112233));
      config.setComponentColor('Online Indicator', 'backgroundOffline', const Color(0xFF445566));

      config.resetComponentColor('Online Indicator', 'backgroundOnline');

      expect(config.isComponentColorCustom('Online Indicator', 'backgroundOnline'), isFalse);
      expect(config.isComponentColorCustom('Online Indicator', 'backgroundOffline'), isTrue);
      expect(config.activeComponentThemes, contains('Online Indicator'));
    });

    test('removeComponentTheme drops the whole section', () {
      config.addComponentTheme('Online Indicator');
      config.setComponentColor('Online Indicator', 'backgroundOnline', const Color(0xFF112233));

      config.removeComponentTheme('Online Indicator');

      expect(config.activeComponentThemes, isEmpty);
      expect(config.themeData.onlineIndicatorTheme.backgroundOnline, isNull);
    });

    test('resetToDefaults clears all component overrides', () {
      config.setComponentColor('Online Indicator', 'backgroundOnline', const Color(0xFF112233));
      config.setComponentColor('Badge Count', 'textColor', const Color(0xFF000000));

      config.resetToDefaults();

      expect(config.activeComponentThemes, isEmpty);
    });

    test('componentOverrides is a read-only snapshot', () {
      config.setComponentColor('Online Indicator', 'backgroundOnline', const Color(0xFF112233));

      final snapshot = config.componentOverrides;
      expect(snapshot['Online Indicator']!['backgroundOnline'], const Color(0xFF112233));
      expect(
        () => snapshot['Online Indicator']!['backgroundOffline'] = const Color(0xFF000000),
        throwsUnsupportedError,
      );
    });

    test('ThemeConfiguration.seededFrom carries component overrides to a fresh instance', () {
      config.setComponentColor('Online Indicator', 'backgroundOnline', const Color(0xFF112233));

      final seeded = ThemeConfiguration.seededFrom(config, brightness: Brightness.dark);
      addTearDown(seeded.dispose);

      expect(seeded.resolveComponentColor('Online Indicator', 'backgroundOnline'), const Color(0xFF112233));

      // And it's a copy, not shared state: further edits on either side
      // don't leak to the other.
      seeded.setComponentColor('Online Indicator', 'backgroundOffline', const Color(0xFF999999));
      expect(config.isComponentColorCustom('Online Indicator', 'backgroundOffline'), isFalse);
    });
  });
}
