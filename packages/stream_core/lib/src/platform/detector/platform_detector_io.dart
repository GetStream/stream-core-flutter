import 'dart:io';

import '../current_platform.dart';

/// The current platform type for environments with dart:io available.
///
/// Detects the platform using [Platform] class from dart:io, which is available
/// on mobile and desktop platforms. Returns the appropriate [PlatformType] based
/// on the detected operating system, defaulting to Android for unrecognized platforms.
PlatformType get currentPlatform {
  if (Platform.isWindows) return PlatformType.windows;
  if (Platform.isFuchsia) return PlatformType.fuchsia;
  if (Platform.isMacOS) return PlatformType.macOS;
  if (Platform.isLinux) return PlatformType.linux;
  if (Platform.isIOS) return PlatformType.ios;
  return PlatformType.android;
}

/// Whether the current environment is a Flutter test.
///
/// Detects Flutter test environments by checking for the 'FLUTTER_TEST'
/// environment variable, which is automatically set by the Flutter test framework.
bool get isFlutterTestEnvironment {
  return Platform.environment.containsKey('FLUTTER_TEST');
}
