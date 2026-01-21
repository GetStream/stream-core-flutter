import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/preview_configuration.dart';
import '../config/theme_configuration.dart';

/// Wrapper widget that applies device frame and text scale to the preview.
///
/// Uses [ListenableBuilder] to explicitly react to [ThemeConfiguration]
/// and [PreviewConfiguration] changes.
class PreviewWrapper extends StatelessWidget {
  const PreviewWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Use ListenableBuilder to explicitly listen to both configurations
    return ListenableBuilder(
      listenable: Listenable.merge([
        context.read<ThemeConfiguration>(),
        context.read<PreviewConfiguration>(),
      ]),
      builder: (context, _) {
        final themeConfig = context.read<ThemeConfiguration>();
        final previewConfig = context.read<PreviewConfiguration>();

        final streamTheme = themeConfig.themeData;
        final colorScheme = streamTheme.colorScheme;
        final boxShadow = streamTheme.boxShadow;

        // Provide StreamTheme via Material theme extension - this is how
        // StreamTheme.of(context) finds the theme in the widget tree
        final content = Theme(
          data: ThemeData(
            brightness: themeConfig.brightness,
            useMaterial3: true,
            scaffoldBackgroundColor: colorScheme.backgroundApp,
            extensions: [streamTheme],
          ),
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

        if (!previewConfig.showDeviceFrame) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 540, maxHeight: 900),
              margin: const EdgeInsets.all(24),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colorScheme.backgroundApp,
                borderRadius: BorderRadius.circular(20),
                boxShadow: boxShadow.elevation3,
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.borderSurfaceSubtle),
              ),
              child: content,
            ),
          );
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: DeviceFrame(
              device: previewConfig.selectedDevice,
              screen: content,
            ),
          ),
        );
      },
    );
  }
}
