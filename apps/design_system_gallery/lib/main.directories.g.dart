// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:design_system_gallery/components/button.dart'
    as _design_system_gallery_components_button;
import 'package:design_system_gallery/theme_config.dart'
    as _design_system_gallery_theme_config;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookComponent(
    name: 'ThemeConfig',
    useCases: [
      _widgetbook.WidgetbookUseCase(
        name: 'Default',
        builder: _design_system_gallery_theme_config.buildCoolButtonUseCase,
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'components',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'StreamButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder:
                _design_system_gallery_components_button.buildCoolButtonUseCase,
          ),
        ],
      ),
    ],
  ),
];
