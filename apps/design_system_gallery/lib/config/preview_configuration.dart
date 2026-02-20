import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:flutter/widgets.dart';

/// Preview configuration for device frame and text scale.
///
/// Manages the device frame, text scale, text direction, target platform,
/// and device frame visibility for the widget preview area.
class PreviewConfiguration extends ChangeNotifier {
  PreviewConfiguration();

  // =========================================================================
  // State
  // =========================================================================

  DeviceInfo _selectedDevice = Devices.ios.iPhone13ProMax;
  var _textScale = 1.0;
  var _showDeviceFrame = false;
  var _textDirection = TextDirection.ltr;
  TargetPlatform? _targetPlatform;

  // =========================================================================
  // Getters
  // =========================================================================

  DeviceInfo get selectedDevice => _selectedDevice;
  double get textScale => _textScale;
  bool get showDeviceFrame => _showDeviceFrame;
  TextDirection get textDirection => _textDirection;

  /// The target platform override, or `null` to use the system default.
  TargetPlatform? get targetPlatform => _targetPlatform;

  // =========================================================================
  // Static Options
  // =========================================================================

  static final deviceOptions = <DeviceInfo>[
    Devices.ios.iPhone13ProMax,
    Devices.ios.iPhone13Mini,
    Devices.ios.iPhoneSE,
    Devices.ios.iPad,
    Devices.android.samsungGalaxyS20,
    Devices.android.samsungGalaxyNote20,
  ];

  static const textScaleOptions = <double>[0.85, 1, 1.15, 1.3, 2];

  static const textDirectionOptions = TextDirection.values;

  /// Platform options available for override.
  ///
  /// `null` represents the system default (no override).
  static const platformOptions = <TargetPlatform?>[
    null,
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
  ];

  // =========================================================================
  // Setters
  // =========================================================================

  void setDevice(DeviceInfo device) {
    if (_selectedDevice == device) return;
    _selectedDevice = device;
    notifyListeners();
  }

  void setTextScale(double scale) {
    if (_textScale == scale) return;
    _textScale = scale;
    notifyListeners();
  }

  void toggleDeviceFrame() {
    _showDeviceFrame = !_showDeviceFrame;
    notifyListeners();
  }

  void setTextDirection(TextDirection direction) {
    if (_textDirection == direction) return;
    _textDirection = direction;
    notifyListeners();
  }

  void setTargetPlatform(TargetPlatform? platform) {
    if (_targetPlatform == platform) return;
    _targetPlatform = platform;
    notifyListeners();
  }
}
