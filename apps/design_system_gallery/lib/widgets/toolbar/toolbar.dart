import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

import '../../config/preview_configuration.dart';
import '../../config/theme_configuration.dart';
import 'device_selector.dart';
import 'text_scale_selector.dart';
import 'theme_mode_toggle.dart';
import 'toolbar_button.dart';

/// The main toolbar for the design system gallery.
///
/// Contains branding, device controls, and theme controls.
class GalleryToolbar extends StatelessWidget {
  const GalleryToolbar({
    super.key,
    required this.showThemePanel,
    required this.onToggleThemePanel,
  });

  final bool showThemePanel;
  final VoidCallback onToggleThemePanel;

  @override
  Widget build(BuildContext context) {
    final themeConfig = context.watch<ThemeConfiguration>();
    final previewConfig = context.watch<PreviewConfiguration>();
    final streamTheme = themeConfig.themeData;
    final colorScheme = streamTheme.colorScheme;
    final textTheme = streamTheme.textTheme;
    final boxShadow = streamTheme.boxShadow;
    final isDark = themeConfig.brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        border: Border(
          bottom: BorderSide(color: colorScheme.borderSurfaceSubtle),
        ),
      ),
      child: Row(
        children: [
          // Stream Logo and title
          _StreamBranding(
            colorScheme: colorScheme,
            textTheme: textTheme,
            boxShadow: boxShadow,
          ),
          const SizedBox(width: 24),

          // Toolbar controls - wrapped in Expanded to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Device frame toggle
                  ToolbarButton(
                    icon: previewConfig.showDeviceFrame ? Icons.devices : Icons.phone_android,
                    tooltip: 'Device Frame',
                    isActive: previewConfig.showDeviceFrame,
                    colorScheme: colorScheme,
                    onTap: previewConfig.toggleDeviceFrame,
                  ),
                  const SizedBox(width: 8),

                  // Device selector
                  if (previewConfig.showDeviceFrame) ...[
                    DeviceSelector(
                      selectedDevice: previewConfig.selectedDevice,
                      devices: PreviewConfiguration.deviceOptions,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onDeviceChanged: previewConfig.setDevice,
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Text scale selector
                  TextScaleSelector(
                    value: previewConfig.textScale,
                    options: PreviewConfiguration.textScaleOptions,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onChanged: previewConfig.setTextScale,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Theme mode toggle
          ThemeModeToggle(
            isDark: isDark,
            colorScheme: colorScheme,
            onLightTap: () => themeConfig.setBrightness(Brightness.light),
            onDarkTap: () => themeConfig.setBrightness(Brightness.dark),
          ),
          const SizedBox(width: 8),

          // Theme panel toggle
          ToolbarButton(
            icon: showThemePanel ? Icons.palette : Icons.palette_outlined,
            tooltip: 'Theme Studio',
            isActive: showThemePanel,
            colorScheme: colorScheme,
            onTap: onToggleThemePanel,
          ),
        ],
      ),
    );
  }
}

/// Stream branding logo and title.
class _StreamBranding extends StatelessWidget {
  const _StreamBranding({
    required this.colorScheme,
    required this.textTheme,
    required this.boxShadow,
  });

  final StreamColorScheme colorScheme;
  final StreamTextTheme textTheme;
  final StreamBoxShadow boxShadow;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stream Logo
        Container(
          width: 40,
          height: 40,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.accentPrimary,
                colorScheme.accentPrimary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: boxShadow.elevation2,
          ),
          child: Center(
            child: Text(
              'S',
              style: TextStyle(
                color: colorScheme.textOnAccent,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stream',
              style: textTheme.headingSm.copyWith(
                color: colorScheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Design System',
              style: textTheme.captionDefault.copyWith(
                color: colorScheme.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
