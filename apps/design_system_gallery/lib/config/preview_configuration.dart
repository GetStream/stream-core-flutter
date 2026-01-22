import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:flutter/foundation.dart';

/// Preview configuration for device frame and text scale.
///
/// Manages the device frame, text scale, and device frame visibility
/// for the widget preview area.
class PreviewConfiguration extends ChangeNotifier {
  PreviewConfiguration();

  // =========================================================================
  // State
  // =========================================================================

  DeviceInfo _selectedDevice = Devices.ios.iPhone13ProMax;
  var _textScale = 1.0;
  var _showDeviceFrame = false;

  // =========================================================================
  // Getters
  // =========================================================================

  DeviceInfo get selectedDevice => _selectedDevice;
  double get textScale => _textScale;
  bool get showDeviceFrame => _showDeviceFrame;

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
}
