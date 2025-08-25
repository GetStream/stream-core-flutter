import '../current_platform.dart';

/// The current platform type for web environments.
///
/// This is the default web implementation that always returns [PlatformType.web]
/// since this file is used when dart:io is not available.
PlatformType get currentPlatform => PlatformType.web;

/// Whether the current environment is a Flutter test.
///
/// Always returns false in web environments since Flutter tests
/// run with dart:io available and use the IO platform detector.
bool get isFlutterTestEnvironment => false;
