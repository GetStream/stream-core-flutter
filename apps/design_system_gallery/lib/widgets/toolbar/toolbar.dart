import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:svg_icon_widget/svg_icon_widget.dart';

import '../../config/preview_configuration.dart';
import '../../config/theme_configuration.dart';
import '../../core/stream_icons.dart';
import 'debug_paint_toggle.dart';
import 'device_selector.dart';
import 'text_direction_selector.dart';
import 'text_scale_selector.dart';
import 'theme_mode_toggle.dart';
import 'toolbar_button.dart';
import 'widget_select_toggle.dart';

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
    // Use read (not watch) - rebuilds come from Consumer in gallery_app.dart
    final themeConfig = context.read<ThemeConfiguration>();
    final previewConfig = context.watch<PreviewConfiguration>();
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        border: Border(
          bottom: BorderSide(color: colorScheme.borderDefault),
        ),
      ),
      child: Row(
        children: [
          // Stream Logo and title
          const _StreamBranding(),
          SizedBox(width: spacing.lg),

          // Toolbar controls - wrapped in Expanded to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: spacing.sm,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Device frame toggle
                  ToolbarButton(
                    icon: previewConfig.showDeviceFrame ? Icons.devices : Icons.phone_android,
                    tooltip: 'Device Frame',
                    isActive: previewConfig.showDeviceFrame,
                    onTap: previewConfig.toggleDeviceFrame,
                  ),

                  // Device frame options
                  if (previewConfig.showDeviceFrame)
                    DeviceSelector(
                      selectedDevice: previewConfig.selectedDevice,
                      devices: PreviewConfiguration.deviceOptions,
                      onDeviceChanged: previewConfig.setDevice,
                    ),

                  // Text scale selector
                  TextScaleSelector(
                    value: previewConfig.textScale,
                    options: PreviewConfiguration.textScaleOptions,
                    onChanged: previewConfig.setTextScale,
                  ),

                  // Text direction selector (LTR/RTL)
                  TextDirectionSelector(
                    value: previewConfig.textDirection,
                    options: PreviewConfiguration.textDirectionOptions,
                    onChanged: previewConfig.setTextDirection,
                  ),

                  // Debug tools (debug mode only)
                  if (kDebugMode) ...[
                    const DebugPaintToggle(),
                    const WidgetSelectToggle(),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(width: spacing.md),

          // Theme mode toggle
          ThemeModeToggle(
            isDark: isDark,
            onLightTap: () => themeConfig.setBrightness(Brightness.light),
            onDarkTap: () => themeConfig.setBrightness(Brightness.dark),
          ),
          SizedBox(width: spacing.sm),

          // Theme panel toggle
          ToolbarButton(
            icon: showThemePanel ? Icons.palette : Icons.palette_outlined,
            tooltip: 'Theme Studio',
            isActive: showThemePanel,
            onTap: onToggleThemePanel,
          ),
        ],
      ),
    );
  }
}

// Stream branding logo and title.
class _StreamBranding extends StatelessWidget {
  const _StreamBranding();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stream Logo
        const SvgIcon(StreamSvgIcons.logo, size: 40),
        SizedBox(width: spacing.sm + spacing.xxs),
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
