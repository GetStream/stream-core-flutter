import 'detector/platform_detector.dart'
    if (dart.library.io) 'detector/platform_detector_io.dart';

/// Platform detection utility for identifying the current runtime environment.
///
/// Provides static methods and properties to detect the current platform,
/// including mobile platforms (Android, iOS), desktop platforms (macOS, Windows, Linux),
/// web environments, and special environments like Fuchsia or Flutter tests.
///
/// This utility automatically selects the appropriate platform detection implementation
/// based on the available Dart libraries, ensuring accurate platform identification
/// across all supported environments.
///
/// Example usage:
/// ```dart
/// if (CurrentPlatform.isAndroid) {
///   // Android-specific code
/// } else if (CurrentPlatform.isIos) {
///   // iOS-specific code
/// }
/// ```
class CurrentPlatform {
  // Private constructor to prevent instantiation.
  CurrentPlatform._();

  /// The current platform type.
  ///
  /// Returns the detected [PlatformType] for the current runtime environment.
  static PlatformType get type => currentPlatform;

  /// Whether the current platform is Android.
  static bool get isAndroid => type == PlatformType.android;

  /// Whether the current platform is iOS.
  static bool get isIos => type == PlatformType.ios;

  /// Whether the current platform is web.
  static bool get isWeb => type == PlatformType.web;

  /// Whether the current platform is macOS.
  static bool get isMacOS => type == PlatformType.macOS;

  /// Whether the current platform is Windows.
  static bool get isWindows => type == PlatformType.windows;

  /// Whether the current platform is Linux.
  static bool get isLinux => type == PlatformType.linux;

  /// Whether the current platform is Fuchsia.
  static bool get isFuchsia => type == PlatformType.fuchsia;

  /// Whether the current environment is a Flutter test.
  ///
  /// Returns true when running in the Flutter test environment,
  /// which is useful for test-specific behavior and mocking.
  static bool get isFlutterTest => isFlutterTestEnvironment;

  /// The operating system name as a string.
  ///
  /// Returns the string representation of the current platform's
  /// operating system (e.g., 'android', 'ios', 'web', 'macos').
  static String get operatingSystem => type.operatingSystem;
}

/// Enumeration of supported platform types.
///
/// Defines all platforms that can be detected by the Stream Core SDK,
/// including mobile, desktop, web, and specialized platforms. Each platform
/// type includes its corresponding operating system identifier string.
enum PlatformType {
  /// Android: <https://www.android.com/>
  android('android'),

  /// iOS: <https://www.apple.com/ios/>
  ios('ios'),

  /// web: <https://en.wikipedia.org/wiki/World_Wide_Web>
  web('web'),

  /// macOS: <https://www.apple.com/macos>
  macOS('macos'),

  /// Windows: <https://www.windows.com>
  windows('windows'),

  /// Linux: <https://www.linux.org>
  linux('linux'),

  /// Fuchsia: <https://fuchsia.dev/fuchsia-src/concepts>
  fuchsia('fuchsia');

  /// Creates a [PlatformType] with the specified [operatingSystem] identifier.
  const PlatformType(this.operatingSystem);

  /// The operating system identifier string for this platform.
  ///
  /// Used for string-based platform identification and API communication.
  final String operatingSystem;
}
