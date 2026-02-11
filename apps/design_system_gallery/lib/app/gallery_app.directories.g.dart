// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:design_system_gallery/components/accessories/stream_emoji.dart'
    as _design_system_gallery_components_accessories_stream_emoji;
import 'package:design_system_gallery/components/accessories/stream_file_type_icons.dart'
    as _design_system_gallery_components_accessories_stream_file_type_icons;
import 'package:design_system_gallery/components/avatar/stream_avatar.dart'
    as _design_system_gallery_components_avatar_stream_avatar;
import 'package:design_system_gallery/components/avatar/stream_avatar_group.dart'
    as _design_system_gallery_components_avatar_stream_avatar_group;
import 'package:design_system_gallery/components/avatar/stream_avatar_stack.dart'
    as _design_system_gallery_components_avatar_stream_avatar_stack;
import 'package:design_system_gallery/components/badge/stream_badge_count.dart'
    as _design_system_gallery_components_badge_stream_badge_count;
import 'package:design_system_gallery/components/badge/stream_online_indicator.dart'
    as _design_system_gallery_components_badge_stream_online_indicator;
import 'package:design_system_gallery/components/buttons/button.dart'
    as _design_system_gallery_components_buttons_button;
import 'package:design_system_gallery/components/buttons/stream_emoji_button.dart'
    as _design_system_gallery_components_buttons_stream_emoji_button;
import 'package:design_system_gallery/components/message_composer/message_composer.dart'
    as _design_system_gallery_components_message_composer_message_composer;
import 'package:design_system_gallery/components/message_composer/message_composer_attachment_link_preview.dart'
    as _design_system_gallery_components_message_composer_message_composer_attachment_link_preview;
import 'package:design_system_gallery/components/message_composer/message_composer_attachment_media_file.dart'
    as _design_system_gallery_components_message_composer_message_composer_attachment_media_file;
import 'package:design_system_gallery/components/message_composer/message_composer_attachment_reply.dart'
    as _design_system_gallery_components_message_composer_message_composer_attachment_reply;
import 'package:design_system_gallery/components/reaction/picker/stream_reaction_picker_sheet.dart'
    as _design_system_gallery_components_reaction_picker_stream_reaction_picker_sheet;
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
            name: 'StreamEmoji',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_accessories_stream_emoji
                        .buildStreamEmojiPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Showcase',
                builder:
                    _design_system_gallery_components_accessories_stream_emoji
                        .buildStreamEmojiShowcase,
              ),
            ],
          ),
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
                builder: _design_system_gallery_components_avatar_stream_avatar
                    .buildStreamAvatarPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Showcase',
                builder: _design_system_gallery_components_avatar_stream_avatar
                    .buildStreamAvatarShowcase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'StreamAvatarGroup',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_avatar_stream_avatar_group
                        .buildStreamAvatarGroupPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Showcase',
                builder:
                    _design_system_gallery_components_avatar_stream_avatar_group
                        .buildStreamAvatarGroupShowcase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'StreamAvatarStack',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_avatar_stream_avatar_stack
                        .buildStreamAvatarStackPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Showcase',
                builder:
                    _design_system_gallery_components_avatar_stream_avatar_stack
                        .buildStreamAvatarStackShowcase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Badge',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'StreamBadgeCount',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_badge_stream_badge_count
                        .buildStreamBadgeCountPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Showcase',
                builder:
                    _design_system_gallery_components_badge_stream_badge_count
                        .buildStreamBadgeCountShowcase,
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
                builder: _design_system_gallery_components_buttons_button
                    .buildStreamButtonPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Real-world Example',
                builder: _design_system_gallery_components_buttons_button
                    .buildStreamButtonExample,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Size Variants',
                builder: _design_system_gallery_components_buttons_button
                    .buildStreamButtonSizes,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Type Variants',
                builder: _design_system_gallery_components_buttons_button
                    .buildStreamButtonTypes,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'With Icons',
                builder: _design_system_gallery_components_buttons_button
                    .buildStreamButtonWithIcons,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'StreamEmojiButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_buttons_stream_emoji_button
                        .buildStreamEmojiButtonPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Showcase',
                builder:
                    _design_system_gallery_components_buttons_stream_emoji_button
                        .buildStreamEmojiButtonShowcase,
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
                    _design_system_gallery_components_badge_stream_online_indicator
                        .buildStreamOnlineIndicatorPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Showcase',
                builder:
                    _design_system_gallery_components_badge_stream_online_indicator
                        .buildStreamOnlineIndicatorShowcase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Message Composer',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'MessageComposerAttachmentLinkPreview',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_message_composer_message_composer_attachment_link_preview
                        .buildMessageComposerAttachmentLinkPreviewPlayground,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'MessageComposerAttachmentMediaFile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_message_composer_message_composer_attachment_media_file
                        .buildMessageComposerAttachmentMediaFilePlayground,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'MessageComposerAttachmentReply',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_message_composer_message_composer_attachment_reply
                        .buildMessageComposerAttachmentReplyPlayground,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'StreamBaseMessageComposer',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_message_composer_message_composer
                        .buildStreamMessageComposerPlayground,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Real-world Example',
                builder:
                    _design_system_gallery_components_message_composer_message_composer
                        .buildStreamMessageComposerExample,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Reaction',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'StreamReactionPickerSheet',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Playground',
                builder:
                    _design_system_gallery_components_reaction_picker_stream_reaction_picker_sheet
                        .buildStreamReactionPickerSheetDefault,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
