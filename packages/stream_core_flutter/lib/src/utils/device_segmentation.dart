import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Whether [context] is in a desktop app or on the web, rather than in an
/// Android or iOS app.
///
/// Components with separate mobile and web designs size themselves by this:
/// desktop and the web share the web design, whatever the window size.
@internal
bool isDesktopOrWeb(BuildContext context) {
  if (kIsWeb) return true;
  return switch (Theme.of(context).platform) {
    TargetPlatform.android || TargetPlatform.iOS => false,
    _ => true,
  };
}
