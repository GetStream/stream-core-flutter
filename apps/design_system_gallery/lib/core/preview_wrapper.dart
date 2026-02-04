import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

import '../config/preview_configuration.dart';

/// Wrapper widget that applies device frame and text scale to the preview.
///
/// Uses [ListenableBuilder] to explicitly react to [PreviewConfiguration] changes.
/// StreamTheme is already available via MaterialApp's theme extensions.
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

    final content = Directionality(
      textDirection: previewConfig.textDirection,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(previewConfig.textScale),
        ),
        child: ColoredBox(
          color: colorScheme.backgroundApp,
          child: child,
        ),
      ),
    );

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
          color: colorScheme.backgroundApp,
          borderRadius: BorderRadius.all(radius.xl),
          boxShadow: boxShadow.elevation3,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius.xl),
          border: Border.all(color: colorScheme.borderSurfaceSubtle),
        ),
        child: content,
      ),
    );
  }
}
