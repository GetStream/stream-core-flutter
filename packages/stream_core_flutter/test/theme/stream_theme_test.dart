import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamTheme.applyPlatform', () {
    test('carries non-typography fields through unchanged', () {
      final theme = StreamTheme(platform: TargetPlatform.android, surfaceStyle: StreamSurfaceStyle.floating);

      final iosTheme = theme.applyPlatform(TargetPlatform.iOS);

      expect(iosTheme.surfaceStyle, equals(StreamSurfaceStyle.floating));
      // ignore: deprecated_member_use_from_same_package
      expect(iosTheme.brightness, equals(theme.brightness));
      expect(iosTheme.colorScheme.brightness, equals(theme.colorScheme.brightness));
      expect(iosTheme.colorScheme, equals(theme.colorScheme));
      expect(iosTheme.elevation, equals(theme.elevation));
    });

    test('regenerates typography and text theme for the given platform', () {
      final theme = StreamTheme(platform: TargetPlatform.android);

      final iosTheme = theme.applyPlatform(TargetPlatform.iOS);

      expect(iosTheme.typography.fontSize, equals(StreamFontSize.ios));
      expect(theme.typography.fontSize, equals(StreamFontSize.android));
    });
  });

  group('StreamTheme.brightness (deprecated)', () {
    test('mirrors colorScheme.brightness for themes built by the factory', () {
      for (final theme in [StreamTheme.light(), StreamTheme.dark()]) {
        // ignore: deprecated_member_use_from_same_package
        expect(theme.brightness, equals(theme.colorScheme.brightness));
      }
    });

    // The parameter stays on copyWith so existing call sites keep compiling;
    // it carries no rendering meaning, which is what the deprecation says.
    test('is still accepted by copyWith, and carries no rendering meaning', () {
      final theme = StreamTheme.light().copyWith(brightness: Brightness.dark) as StreamTheme;

      // ignore: deprecated_member_use_from_same_package
      expect(theme.brightness, equals(Brightness.dark));
      // The colours are untouched — which is exactly why the property is
      // deprecated in favour of colorScheme.brightness.
      expect(theme.colorScheme.brightness, equals(Brightness.light));
    });
  });

  group('StreamTheme.elevation', () {
    test('defaults to the design-system scale', () {
      const elevation = StreamElevation();

      expect(StreamTheme().elevation, equals(elevation));
      expect(
        [elevation.none, elevation.level1, elevation.level2, elevation.level3, elevation.level4],
        equals([0.0, 1.0, 3.0, 6.0, 8.0]),
      );
    });

    test('is overridable through the constructor', () {
      final theme = StreamTheme(elevation: const StreamElevation(level3: 20));

      expect(theme.elevation.level3, equals(20));
      // Unspecified levels keep their defaults.
      expect(theme.elevation.level4, equals(8));
    });

    test('none stays 0 and is not part of equality', () {
      // `none` is a getter rather than a constructor field, so no theme can
      // redefine "flat" as elevated.
      const a = StreamElevation();
      const b = StreamElevation(level1: 99);

      expect(a.none, equals(0));
      expect(b.none, equals(0));
      expect(a, isNot(equals(b)));
    });

    test('lerps between two scales on a theme transition', () {
      final lerped = StreamTheme.light().lerp(
        StreamTheme.light().copyWith(elevation: const StreamElevation(level3: 10)),
        0.5,
      );

      expect((lerped as StreamTheme).elevation.level3, equals(8));
    });
  });
}
