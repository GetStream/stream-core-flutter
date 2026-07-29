import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamTheme.applyPlatform', () {
    test('carries non-typography fields through unchanged', () {
      final theme = StreamTheme(platform: TargetPlatform.android, appStyle: StreamAppStyle.floating);

      final iosTheme = theme.applyPlatform(TargetPlatform.iOS);

      expect(iosTheme.appStyle, equals(StreamAppStyle.floating));
      expect(iosTheme.brightness, equals(theme.brightness));
      expect(iosTheme.colorScheme, equals(theme.colorScheme));
    });

    test('regenerates typography and text theme for the given platform', () {
      final theme = StreamTheme(platform: TargetPlatform.android);

      final iosTheme = theme.applyPlatform(TargetPlatform.iOS);

      expect(iosTheme.typography.fontSize, equals(StreamFontSize.ios));
      expect(theme.typography.fontSize, equals(StreamFontSize.android));
    });
  });
}
