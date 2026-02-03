// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:design_system_gallery/components/accessories/stream_file_type_icons.dart'
    as _design_system_gallery_components_accessories_stream_file_type_icons;
import 'package:design_system_gallery/components/button.dart'
    as _design_system_gallery_components_button;
import 'package:design_system_gallery/components/stream_avatar.dart'
    as _design_system_gallery_components_stream_avatar;
import 'package:design_system_gallery/components/stream_avatar_stack.dart'
    as _design_system_gallery_components_stream_avatar_stack;
import 'package:design_system_gallery/components/stream_online_indicator.dart'
    as _design_system_gallery_components_stream_online_indicator;
import 'package:design_system_gallery/primitives/colors.dart'
    as _design_system_gallery_primitives_colors;
import 'package:design_system_gallery/primitives/icons.dart'
    as _design_system_gallery_primitives_icons;
import 'package:design_system_gallery/primitives/radius.dart'
    as _design_system_gallery_primitives_radius;
import 'package:design_system_gallery/primitives/spacing.dart'
    as _design_system_gallery_primitives_spacing;
import 'package:design_system_gallery/semantics/elevations.dart'
    as _design_system_gallery_semantics_elevations;
import 'package:design_system_gallery/semantics/typography.dart'
    as _design_system_gallery_semantics_typography;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'App Foundation',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Primitives',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'Colors',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'StreamColors',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'All Colors',
                    builder: _design_system_gallery_primitives_colors
                        .buildStreamColorsShowcase,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Icons',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'StreamIcons',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'All Icons',
                    builder: _design_system_gallery_primitives_icons
                        .buildStreamIconsShowcase,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Radius',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'StreamRadius',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'All Values',
                    builder: _design_system_gallery_primitives_radius
                        .buildStreamRadiusShowcase,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Spacing',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'StreamSpacing',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'All Values',
                    builder: _design_system_gallery_primitives_spacing
                        .buildStreamSpacingShowcase,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Semantics',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'Elevations',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'StreamBoxShadow',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'All Elevations',
                    builder: _design_system_gallery_semantics_elevations
                        .buildStreamBoxShadowShowcase,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'Typography',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'StreamTextTheme',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'All Styles',
                    builder: _design_system_gallery_semantics_typography
                        .buildStreamTextThemeShowcase,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Components',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'Accessories',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'StreamFileTypeIcon',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_accessories_stream_file_type_icons
                        .buildFileTypeIconPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Showcase',
                builder:
                    _design_system_gallery_components_accessories_stream_file_type_icons
                        .buildFileTypeIconShowcase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Avatar',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'StreamAvatar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder: _design_system_gallery_components_stream_avatar
                    .buildStreamAvatarPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Showcase',
                builder: _design_system_gallery_components_stream_avatar
                    .buildStreamAvatarShowcase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'StreamAvatarStack',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder: _design_system_gallery_components_stream_avatar_stack
                    .buildStreamAvatarStackPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Showcase',
                builder: _design_system_gallery_components_stream_avatar_stack
                    .buildStreamAvatarStackShowcase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Button',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'StreamButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder: _design_system_gallery_components_button
                    .buildStreamButtonPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Real-world Example',
                builder: _design_system_gallery_components_button
                    .buildStreamButtonExample,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Size Variants',
                builder: _design_system_gallery_components_button
                    .buildStreamButtonSizes,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Type Variants',
                builder: _design_system_gallery_components_button
                    .buildStreamButtonTypes,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'With Icons',
                builder: _design_system_gallery_components_button
                    .buildStreamButtonWithIcons,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Indicator',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'StreamOnlineIndicator',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_stream_online_indicator
                        .buildStreamOnlineIndicatorPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Showcase',
                builder:
                    _design_system_gallery_components_stream_online_indicator
                        .buildStreamOnlineIndicatorShowcase,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
