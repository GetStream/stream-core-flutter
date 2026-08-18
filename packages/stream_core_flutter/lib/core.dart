/// Core UI primitives shared across all Stream products.
///
/// Import this barrel from any Stream SDK (chat, video, feeds, ...) that
/// needs the shared design-system widgets, theme tokens, or component
/// factory without pulling in chat-specific code.
///
/// For chat-only widgets (message bubble, composer attachments, reactions,
/// etc.) use `package:stream_core_flutter/chat.dart` instead.
library;

export 'package:svg_icon_widget/svg_icon_widget.dart';

export 'src/a11y/stream_accessibility_autofocus.dart';
export 'src/a11y/stream_semantics_announcer.dart';
export 'src/a11y/stream_semantics_transition_announcer.dart';
export 'src/components/accessories/stream_audio_waveform.dart';
export 'src/components/accessories/stream_emoji.dart';
export 'src/components/accessories/stream_file_type_icon.dart';
export 'src/components/avatar/stream_avatar.dart';
export 'src/components/avatar/stream_avatar_group.dart';
export 'src/components/avatar/stream_avatar_stack.dart';
export 'src/components/badge/stream_badge_count.dart';
export 'src/components/badge/stream_badge_notification.dart';
export 'src/components/badge/stream_error_badge.dart';
export 'src/components/badge/stream_image_source_badge.dart';
export 'src/components/badge/stream_media_badge.dart';
export 'src/components/badge/stream_online_indicator.dart';
export 'src/components/badge/stream_retry_badge.dart';
export 'src/components/buttons/stream_button.dart';
export 'src/components/buttons/stream_emoji_button.dart';
export 'src/components/buttons/stream_split_button.dart';
export 'src/components/common/stream_checkbox.dart';
export 'src/components/common/stream_flex.dart';
export 'src/components/common/stream_intrinsic_flex.dart';
export 'src/components/common/stream_loading_spinner.dart';
export 'src/components/common/stream_network_image.dart';
export 'src/components/common/stream_progress_bar.dart';
export 'src/components/common/stream_safe_area.dart';
export 'src/components/common/stream_skeleton_loading.dart';
export 'src/components/common/stream_tap_target_padding.dart';
export 'src/components/common/stream_text_input.dart';
export 'src/components/common/stream_visibility.dart';
export 'src/components/context_menu/stream_context_menu.dart';
export 'src/components/context_menu/stream_context_menu_action.dart';
export 'src/components/controls/stream_emoji_chip.dart';
export 'src/components/controls/stream_emoji_chip_bar.dart';
export 'src/components/controls/stream_playback_speed_toggle.dart';
export 'src/components/controls/stream_remove_control.dart';
export 'src/components/controls/stream_stepper.dart';
export 'src/components/controls/stream_switch.dart';
export 'src/components/controls/stream_video_play_indicator.dart';
export 'src/components/emoji/data/stream_emoji_data.dart';
export 'src/components/emoji/data/stream_supported_emojis.dart';
export 'src/components/emoji/stream_emoji_picker_sheet.dart';
export 'src/components/list/stream_list_tile.dart';
export 'src/components/media_viewer/stream_media_viewer.dart';
export 'src/components/scaffold/stream_scaffold.dart';
export 'src/components/sheet/stream_sheet.dart';
export 'src/components/snackbar/stream_snackbar.dart';
export 'src/components/toolbar/stream_app_bar.dart';
export 'src/components/toolbar/stream_bottom_app_bar.dart';
export 'src/components/toolbar/stream_bottom_nav_bar.dart';
export 'src/components/toolbar/stream_sheet_header.dart';
export 'src/components/toolbar/stream_toolbar.dart';
export 'src/components/toolbar/stream_toolbar_button.dart';
export 'src/components/toolbar/stream_toolbar_scope.dart';
export 'src/factory/stream_component_factory.dart';
export 'src/theme/components/stream_app_bar_theme.dart';
export 'src/theme/components/stream_audio_waveform_theme.dart';
export 'src/theme/components/stream_avatar_theme.dart';
export 'src/theme/components/stream_badge_count_theme.dart';
export 'src/theme/components/stream_badge_notification_theme.dart';
export 'src/theme/components/stream_bottom_app_bar_theme.dart';
export 'src/theme/components/stream_bottom_nav_bar_theme.dart';
export 'src/theme/components/stream_button_theme.dart';
export 'src/theme/components/stream_checkbox_theme.dart';
export 'src/theme/components/stream_context_menu_action_theme.dart';
export 'src/theme/components/stream_context_menu_theme.dart';
export 'src/theme/components/stream_emoji_button_theme.dart';
export 'src/theme/components/stream_emoji_chip_theme.dart';
export 'src/theme/components/stream_list_tile_theme.dart';
export 'src/theme/components/stream_media_viewer_theme.dart';
export 'src/theme/components/stream_online_indicator_theme.dart';
export 'src/theme/components/stream_playback_speed_toggle_theme.dart';
export 'src/theme/components/stream_progress_bar_theme.dart';
export 'src/theme/components/stream_sheet_header_theme.dart';
export 'src/theme/components/stream_sheet_theme.dart';
export 'src/theme/components/stream_skeleton_loading_theme.dart';
export 'src/theme/components/stream_snackbar_theme.dart';
export 'src/theme/components/stream_split_button_theme.dart';
export 'src/theme/components/stream_stepper_theme.dart';
export 'src/theme/components/stream_switch_theme.dart';
export 'src/theme/components/stream_text_input_theme.dart';
export 'src/theme/primitives/stream_colors.dart';
export 'src/theme/primitives/stream_elevation.dart';
export 'src/theme/primitives/stream_icons.dart';
export 'src/theme/primitives/stream_radius.dart';
export 'src/theme/primitives/stream_spacing.dart';
export 'src/theme/primitives/stream_typography.dart';
export 'src/theme/semantics/stream_box_shadow.dart';
export 'src/theme/semantics/stream_color_scheme.dart';
export 'src/theme/semantics/stream_text_theme.dart';
export 'src/theme/stream_floating_fade.dart';
export 'src/theme/stream_surface_style.dart';
export 'src/theme/stream_theme.dart';
export 'src/theme/stream_theme_extensions.dart';
export 'src/theme/widget_state_utils.dart';
