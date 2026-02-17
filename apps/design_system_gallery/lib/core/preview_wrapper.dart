import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

import '../config/preview_configuration.dart';

/// Wrapper widget that applies device frame and text scale to the preview.
///
/// Uses a nested [Navigator] so that dialogs and bottom sheets open within
/// the preview container rather than covering the entire gallery app.
///
/// The declarative [Navigator.pages] API is used instead of [onGenerateRoute]
/// so that theme changes propagate into the route content without recreating
/// the navigator (which would reset use-case state).
///
/// A [GlobalObjectKey] is used on the [Navigator] so that toggling the device
/// frame on/off reparents the navigator without losing state.
class PreviewWrapper extends StatelessWidget {
  const PreviewWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final previewConfig = context.watch<PreviewConfiguration>();

    final colorScheme = context.streamColorScheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final targetPlatform = previewConfig.targetPlatform;

    Widget content = Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: .linear(previewConfig.textScale),
        ),
        child: Directionality(
          textDirection: previewConfig.textDirection,
          child: Navigator(
            key: const GlobalObjectKey('preview-navigator'),
            pages: [
              MaterialPage(
                child: ScaffoldMessenger(
                  child: Scaffold(body: child),
                ),
              ),
            ],
            // no-op as the preview page should never be popped
            onDidRemovePage: (_) {},
          ),
        ),
      ),
    );

    // Apply platform override to both Material theme and Stream theme so
    // that platform-aware primitives (e.g. StreamRadius, StreamTypography)
    // resolve correctly for the selected platform.
    if (targetPlatform != null) {
      content = _PlatformOverride(
        platform: targetPlatform,
        child: content,
      );
    }

    if (previewConfig.showDeviceFrame) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.xl),
          child: DeviceFrame(
            device: previewConfig.selectedDevice,
            screen: content,
          ),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 900),
        margin: EdgeInsets.all(spacing.lg),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius.xl),
          boxShadow: boxShadow.elevation3,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius.xl),
          border: Border.all(color: colorScheme.borderDefault),
        ),
        child: content,
      ),
    );
  }
}

/// Overrides the target platform for both Material and Stream themes.
///
/// Rebuilds [StreamTheme] with the given [platform] so that platform-aware
/// primitives like [StreamRadius] and [StreamTypography] use the correct
/// platform-specific values.
class _PlatformOverride extends StatelessWidget {
  const _PlatformOverride({
    required this.platform,
    required this.child,
  });

  final TargetPlatform platform;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final currentStreamTheme = context.streamTheme;

    // Rebuild StreamTheme with the overridden platform so that
    // platform-aware values (radius, typography) are recalculated.
    final overriddenStreamTheme = StreamTheme(
      brightness: currentStreamTheme.brightness,
      platform: platform,
      colorScheme: currentStreamTheme.colorScheme,
    );

    return Theme(
      data: currentTheme.copyWith(
        platform: platform,
        extensions: {
          ...currentTheme.extensions.values,
          overriddenStreamTheme,
        },
      ),
      child: child,
    );
  }
}
