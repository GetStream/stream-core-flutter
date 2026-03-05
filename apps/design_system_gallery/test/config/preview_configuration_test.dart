import 'package:design_system_gallery/config/preview_configuration.dart';
import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PreviewConfiguration', () {
    test('creates with default values', () {
      final config = PreviewConfiguration();
      expect(config.selectedDevice, isNotNull);
      expect(config.textScale, 1.0);
      expect(config.showDeviceFrame, isFalse);
      expect(config.textDirection, TextDirection.ltr);
      expect(config.targetPlatform, isNull);
    });

    test('default device is iPhone13ProMax', () {
      final config = PreviewConfiguration();
      expect(config.selectedDevice, Devices.ios.iPhone13ProMax);
    });

    group('setDevice', () {
      test('updates device', () {
        final config = PreviewConfiguration();
        final newDevice = Devices.ios.iPhone13Mini;
        config.setDevice(newDevice);
        expect(config.selectedDevice, newDevice);
      });

      test('notifies listeners', () {
        final config = PreviewConfiguration();
        var notified = false;
        config.addListener(() => notified = true);
        config.setDevice(Devices.ios.iPhone13Mini);
        expect(notified, isTrue);
      });

      test('does not notify if device is same', () {
        final config = PreviewConfiguration();
        var notifyCount = 0;
        config.addListener(() => notifyCount++);
        config.setDevice(Devices.ios.iPhone13ProMax);
        expect(notifyCount, 0);
      });
    });

    group('setTextScale', () {
      test('updates text scale', () {
        final config = PreviewConfiguration();
        config.setTextScale(1.5);
        expect(config.textScale, 1.5);
      });

      test('notifies listeners', () {
        final config = PreviewConfiguration();
        var notified = false;
        config.addListener(() => notified = true);
        config.setTextScale(1.5);
        expect(notified, isTrue);
      });

      test('does not notify if scale is same', () {
        final config = PreviewConfiguration();
        var notifyCount = 0;
        config.addListener(() => notifyCount++);
        config.setTextScale(1.0);
        expect(notifyCount, 0);
      });

      test('handles extreme values', () {
        final config = PreviewConfiguration();
        config.setTextScale(0.5);
        expect(config.textScale, 0.5);
        config.setTextScale(3.0);
        expect(config.textScale, 3.0);
      });
    });

    group('toggleDeviceFrame', () {
      test('toggles device frame visibility', () {
        final config = PreviewConfiguration();
        expect(config.showDeviceFrame, isFalse);
        config.toggleDeviceFrame();
        expect(config.showDeviceFrame, isTrue);
        config.toggleDeviceFrame();
        expect(config.showDeviceFrame, isFalse);
      });

      test('notifies listeners', () {
        final config = PreviewConfiguration();
        var notifyCount = 0;
        config.addListener(() => notifyCount++);
        config.toggleDeviceFrame();
        expect(notifyCount, 1);
      });
    });

    group('setTextDirection', () {
      test('updates text direction', () {
        final config = PreviewConfiguration();
        config.setTextDirection(TextDirection.rtl);
        expect(config.textDirection, TextDirection.rtl);
      });

      test('notifies listeners', () {
        final config = PreviewConfiguration();
        var notified = false;
        config.addListener(() => notified = true);
        config.setTextDirection(TextDirection.rtl);
        expect(notified, isTrue);
      });

      test('does not notify if direction is same', () {
        final config = PreviewConfiguration();
        var notifyCount = 0;
        config.addListener(() => notifyCount++);
        config.setTextDirection(TextDirection.ltr);
        expect(notifyCount, 0);
      });
    });

    group('setTargetPlatform', () {
      test('updates target platform', () {
        final config = PreviewConfiguration();
        config.setTargetPlatform(TargetPlatform.android);
        expect(config.targetPlatform, TargetPlatform.android);
      });

      test('notifies listeners', () {
        final config = PreviewConfiguration();
        var notified = false;
        config.addListener(() => notified = true);
        config.setTargetPlatform(TargetPlatform.iOS);
        expect(notified, isTrue);
      });

      test('does not notify if platform is same', () {
        final config = PreviewConfiguration();
        var notifyCount = 0;
        config.addListener(() => notifyCount++);
        config.setTargetPlatform(null);
        expect(notifyCount, 0);
      });

      test('can be set to null', () {
        final config = PreviewConfiguration();
        config.setTargetPlatform(TargetPlatform.android);
        config.setTargetPlatform(null);
        expect(config.targetPlatform, isNull);
      });

      test('supports all platforms', () {
        final config = PreviewConfiguration();
        for (final platform in [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.windows,
          TargetPlatform.linux,
        ]) {
          config.setTargetPlatform(platform);
          expect(config.targetPlatform, platform);
        }
      });
    });

    group('static options', () {
      test('deviceOptions is not empty', () {
        expect(PreviewConfiguration.deviceOptions, isNotEmpty);
      });

      test('deviceOptions contains expected devices', () {
        final options = PreviewConfiguration.deviceOptions;
        expect(options, contains(Devices.ios.iPhone13ProMax));
        expect(options, contains(Devices.ios.iPhone13Mini));
        expect(options, contains(Devices.ios.iPhoneSE));
        expect(options, contains(Devices.ios.iPad));
        expect(options, contains(Devices.android.samsungGalaxyS20));
        expect(options, contains(Devices.android.samsungGalaxyNote20));
      });

      test('textScaleOptions is not empty', () {
        expect(PreviewConfiguration.textScaleOptions, isNotEmpty);
      });

      test('textScaleOptions contains expected values', () {
        expect(PreviewConfiguration.textScaleOptions, [0.85, 1, 1.15, 1.3, 2]);
      });

      test('textDirectionOptions contains both directions', () {
        expect(PreviewConfiguration.textDirectionOptions, [
          TextDirection.rtl,
          TextDirection.ltr,
        ]);
      });

      test('platformOptions contains all platforms and null', () {
        final options = PreviewConfiguration.platformOptions;
        expect(options, contains(null));
        expect(options, contains(TargetPlatform.android));
        expect(options, contains(TargetPlatform.iOS));
        expect(options, contains(TargetPlatform.macOS));
        expect(options, contains(TargetPlatform.windows));
        expect(options, contains(TargetPlatform.linux));
      });
    });

    group('edge cases', () {
      test('multiple listeners are notified', () {
        final config = PreviewConfiguration();
        var count1 = 0;
        var count2 = 0;
        config.addListener(() => count1++);
        config.addListener(() => count2++);
        config.setTextScale(1.5);
        expect(count1, 1);
        expect(count2, 1);
      });

      test('can be disposed', () {
        final config = PreviewConfiguration();
        config.dispose();
        // Should not throw
      });

      test('setting same value multiple times', () {
        final config = PreviewConfiguration();
        var notifyCount = 0;
        config.addListener(() => notifyCount++);
        config.setTextScale(1.0);
        config.setTextScale(1.0);
        config.setTextScale(1.0);
        expect(notifyCount, 0);
      });

      test('rapid toggles', () {
        final config = PreviewConfiguration();
        config.toggleDeviceFrame();
        config.toggleDeviceFrame();
        config.toggleDeviceFrame();
        expect(config.showDeviceFrame, isTrue);
      });

      test('chain method calls', () {
        final config = PreviewConfiguration();
        config
          ..setDevice(Devices.ios.iPad)
          ..setTextScale(1.5)
          ..setTextDirection(TextDirection.rtl)
          ..setTargetPlatform(TargetPlatform.android);

        expect(config.selectedDevice, Devices.ios.iPad);
        expect(config.textScale, 1.5);
        expect(config.textDirection, TextDirection.rtl);
        expect(config.targetPlatform, TargetPlatform.android);
      });
    });
  });
}