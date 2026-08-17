import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../config/preview_configuration.dart';
import '../config/theme_configuration.dart';
import 'gallery_shell.dart';

/// Stream Design System Gallery
///
/// A production-level design system gallery for exploring and customizing
/// Stream components. Inspired by Moon Design System and FlexColorScheme.
@widgetbook.App()
class StreamDesignSystemGallery extends StatefulWidget {
  const StreamDesignSystemGallery({super.key});

  @override
  State<StreamDesignSystemGallery> createState() => _StreamDesignSystemGalleryState();
}

class _StreamDesignSystemGalleryState extends State<StreamDesignSystemGallery> {
  final _themeConfig = ThemeConfiguration.light();
  final _previewConfig = PreviewConfiguration();
  var _showThemePanel = true;

  @override
  void dispose() {
    _themeConfig.dispose();
    _previewConfig.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _themeConfig),
        ChangeNotifierProvider.value(value: _previewConfig),
      ],
      child: Consumer<ThemeConfiguration>(
        builder: (context, themeConfig, _) {
          final isDark = themeConfig.brightness == .dark;
          final materialTheme = themeConfig.buildMaterialTheme();

          return MaterialApp(
            title: 'Stream Design System',
            debugShowCheckedModeBanner: false,
            // Use Stream-themed Material theme for all regular widgets
            theme: materialTheme,
            darkTheme: materialTheme,
            themeMode: isDark ? .dark : .light,
            // Maps the theme and localizations into Flutter's Material for the
            // dependencies still built on it — Widgetbook, DeviceFrame, the
            // colour picker — which would otherwise resolve stock defaults.
            //
            // TODO(material-ui): drop as each dependency migrates.
            // https://linear.app/stream/issue/flu-698
            // ignore: deprecated_member_use
            builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
            home: GalleryShell(
              showThemePanel: _showThemePanel,
              onToggleThemePanel: () => setState(() => _showThemePanel = !_showThemePanel),
            ),
          );
        },
      ),
    );
  }
}
