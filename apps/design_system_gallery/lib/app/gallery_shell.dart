import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';

import '../core/preview_wrapper.dart';
import '../widgets/theme_studio/theme_customization_panel.dart';
import '../widgets/toolbar/toolbar.dart';
import 'gallery_app.directories.g.dart';
import 'home.dart';

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
    final materialTheme = Theme.of(context);
    final isDark = materialTheme.brightness == .dark;

    return Scaffold(
      backgroundColor: context.streamColorScheme.backgroundApp,
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
                    lightTheme: materialTheme,
                    darkTheme: materialTheme,
                    themeMode: isDark ? .dark : .light,
                    directories: _collapseDirectories(directories),
                    home: const GalleryHomePage(),
                    appBuilder: (context, child) => PreviewWrapper(child: child),
                  ),
                ),
                // Theme customization panel
                if (showThemePanel) ...[
                  const SizedBox(
                    width: 340,
                    child: ThemeCustomizationPanel(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Transforms a list of [WidgetbookNode]s to have their children collapsed
// by default.
//
// This recursively processes all nodes and creates new instances with
// `isInitiallyExpanded: false` for nodes that have children.
List<WidgetbookNode> _collapseDirectories(
  List<WidgetbookNode> nodes,
) => nodes.map(_collapseNode).toList();

WidgetbookNode _collapseNode(
  WidgetbookNode node,
) {
  if (node is WidgetbookCategory) {
    // Keep the category expanded by default, but collapse its children
    return WidgetbookCategory(
      name: node.name,
      children: node.children?.map(_collapseNode).toList(),
    );
  }

  if (node is WidgetbookFolder) {
    // Keep the folder and its children collapsed by default
    return WidgetbookFolder(
      name: node.name,
      isInitiallyExpanded: false,
      children: node.children?.map(_collapseNode).toList(),
    );
  }

  if (node is WidgetbookComponent) {
    // Keep the component and its use cases collapsed by default
    return WidgetbookComponent(
      name: node.name,
      isInitiallyExpanded: false,
      useCases: [
        ...node.useCases.map(
          (useCase) => WidgetbookUseCase(
            name: useCase.name,
            builder: useCase.builder,
            designLink: useCase.designLink,
          ),
        ),
      ],
    );
  }

  return node;
}
