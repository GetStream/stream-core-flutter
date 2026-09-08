import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  group('CurrentPlatform', () {
    tearDown(() => CurrentPlatform.debugCurrentPlatformOverride = null);

    test('an override drives type and operatingSystem', () {
      CurrentPlatform.debugCurrentPlatformOverride = PlatformType.fuchsia;

      expect(CurrentPlatform.type, PlatformType.fuchsia);
      expect(CurrentPlatform.operatingSystem, 'fuchsia');
    });

    test('an override drives the platform flags', () {
      CurrentPlatform.debugCurrentPlatformOverride = PlatformType.web;

      expect(CurrentPlatform.isWeb, isTrue);
      expect(CurrentPlatform.isAndroid, isFalse);
      expect(CurrentPlatform.isIos, isFalse);
      expect(CurrentPlatform.isMacOS, isFalse);
      expect(CurrentPlatform.isWindows, isFalse);
      expect(CurrentPlatform.isLinux, isFalse);
      expect(CurrentPlatform.isFuchsia, isFalse);
    });

    test('an override drives isMobile', () {
      CurrentPlatform.debugCurrentPlatformOverride = PlatformType.ios;

      expect(CurrentPlatform.isMobile, isTrue);
      expect(CurrentPlatform.isDesktop, isFalse);
    });

    test('an override drives isDesktop', () {
      CurrentPlatform.debugCurrentPlatformOverride = PlatformType.windows;

      expect(CurrentPlatform.isDesktop, isTrue);
      expect(CurrentPlatform.isMobile, isFalse);
    });

    test('an override does not affect isFlutterTest', () {
      final environment = CurrentPlatform.isFlutterTest;
      CurrentPlatform.debugCurrentPlatformOverride = PlatformType.web;

      expect(CurrentPlatform.isFlutterTest, environment);
    });

    test('clearing the override restores the detected platform', () {
      final detected = CurrentPlatform.type;
      final other = PlatformType.values.firstWhere((it) => it != detected);

      CurrentPlatform.debugCurrentPlatformOverride = other;
      expect(CurrentPlatform.type, other);

      CurrentPlatform.debugCurrentPlatformOverride = null;
      expect(CurrentPlatform.type, detected);
    });
  });
}
