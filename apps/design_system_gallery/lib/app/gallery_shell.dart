import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook/widgetbook.dart';

import '../config/theme_configuration.dart';
import '../core/preview_wrapper.dart';
import '../widgets/theme_studio/theme_customization_panel.dart';
import '../widgets/toolbar/toolbar.dart';
import 'gallery_app.directories.g.dart';

/// The main shell that wraps the widgetbook with custom Stream branding.
///
/// This widget provides the overall layout including:
/// - Top toolbar with branding and controls
/// - Main widgetbook content area
/// - Optional theme customization panel
class GalleryShell extends StatelessWidget {
  const GalleryShell({
    super.key,
    required this.showThemePanel,
    required this.onToggleThemePanel,
  });

  final bool showThemePanel;
  final VoidCallback onToggleThemePanel;

  @override
  Widget build(BuildContext context) {
    final themeConfig = context.watch<ThemeConfiguration>();
    final isDark = themeConfig.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _getShellBackground(themeConfig.brightness),
      body: Column(
        children: [
          // Toolbar spans across the entire width
          GalleryToolbar(
            showThemePanel: showThemePanel,
            onToggleThemePanel: onToggleThemePanel,
          ),
          // Content area below toolbar
          Expanded(
            child: Row(
              children: [
                // Widgetbook area
                Expanded(
                  child: Widgetbook.material(
                    // Theme updates via themeMode/lightTheme/darkTheme props
                    // Preview updates via PreviewWrapper's ListenableBuilder
                    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                    lightTheme: themeConfig.buildMaterialTheme(),
                    darkTheme: themeConfig.buildMaterialTheme(),
                    directories: directories,
                    appBuilder: (context, child) => PreviewWrapper(child: child),
                  ),
                ),
                // Theme customization panel - aligned with widgetbook content
                if (showThemePanel)
                  SizedBox(
                    width: 340,
                    child: ThemeCustomizationPanel(configuration: themeConfig),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getShellBackground(Brightness brightness) {
    return brightness == Brightness.dark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA);
  }
}
