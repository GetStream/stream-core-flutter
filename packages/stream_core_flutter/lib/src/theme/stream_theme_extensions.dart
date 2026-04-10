import 'package:flutter/widgets.dart';

import 'components/stream_audio_waveform_theme.dart';
import 'components/stream_avatar_theme.dart';
import 'components/stream_badge_count_theme.dart';
import 'components/stream_badge_notification_theme.dart';
import 'components/stream_button_theme.dart';
import 'components/stream_checkbox_theme.dart';
import 'components/stream_command_chip_theme.dart';
import 'components/stream_context_menu_action_theme.dart';
import 'components/stream_context_menu_theme.dart';
import 'components/stream_emoji_button_theme.dart';
import 'components/stream_emoji_chip_theme.dart';
import 'components/stream_list_tile_theme.dart';
import 'components/stream_message_item_theme.dart';
import 'components/stream_message_theme.dart';
import 'components/stream_online_indicator_theme.dart';
import 'components/stream_playback_speed_toggle_theme.dart';
import 'components/stream_progress_bar_theme.dart';
import 'components/stream_reaction_picker_theme.dart';
import 'components/stream_reactions_theme.dart';
import 'components/stream_skeleton_loading_theme.dart';
import 'components/stream_stepper_theme.dart';
import 'components/stream_text_input_theme.dart';
import 'components/stream_toggle_switch_theme.dart';
import 'primitives/stream_icons.dart';
import 'primitives/stream_radius.dart';
import 'primitives/stream_spacing.dart';
import 'primitives/stream_typography.dart';
import 'semantics/stream_box_shadow.dart';
import 'semantics/stream_color_scheme.dart';
import 'semantics/stream_text_theme.dart';
import 'stream_theme.dart';

/// Extension on [BuildContext] for convenient access to [StreamTheme].
///
/// {@tool snippet}
///
/// Access theme properties directly from context:
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return Container(
///     color: context.streamColorScheme.backgroundPrimary,
///     padding: EdgeInsets.all(context.streamSpacing.md),
///     child: Text('Hello', style: context.streamTextTheme.bodyDefault),
///   );
/// }
/// ```
/// {@end-tool}
extension StreamThemeExtension on BuildContext {
  /// Returns the [StreamTheme] from the closest ancestor.
  ///
  /// If no [StreamTheme] is found, returns a default theme based on
  /// the current [Theme]'s brightness.
  StreamTheme get streamTheme => StreamTheme.of(this);

  /// Returns the [StreamColorScheme] from the current theme.
  StreamColorScheme get streamColorScheme => streamTheme.colorScheme;

  /// Returns the [StreamIcons] from the current theme.
  StreamIcons get streamIcons => streamTheme.icons;

  /// Returns the [StreamTextTheme] from the current theme.
  StreamTextTheme get streamTextTheme => streamTheme.textTheme;

  /// Returns the [StreamTypography] from the current theme.
  StreamTypography get streamTypography => streamTheme.typography;

  /// Returns the [StreamRadius] from the current theme.
  StreamRadius get streamRadius => streamTheme.radius;

  /// Returns the [StreamSpacing] from the current theme.
  StreamSpacing get streamSpacing => streamTheme.spacing;

  /// Returns the [StreamBoxShadow] from the current theme.
  StreamBoxShadow get streamBoxShadow => streamTheme.boxShadow;

  /// Returns the [StreamAudioWaveformThemeData] from the nearest ancestor.
  StreamAudioWaveformThemeData get streamAudioWaveformTheme => StreamAudioWaveformTheme.of(this);

  /// Returns the [StreamAvatarThemeData] from the nearest ancestor.
  StreamAvatarThemeData get streamAvatarTheme => StreamAvatarTheme.of(this);

  /// Returns the [StreamBadgeCountThemeData] from the nearest ancestor.
  StreamBadgeCountThemeData get streamBadgeCountTheme => StreamBadgeCountTheme.of(this);

  /// Returns the [StreamBadgeNotificationThemeData] from the nearest ancestor.
  StreamBadgeNotificationThemeData get streamBadgeNotificationTheme => StreamBadgeNotificationTheme.of(this);

  /// Returns the [StreamButtonThemeData] from the nearest ancestor.
  StreamButtonThemeData get streamButtonTheme => StreamButtonTheme.of(this);

  /// Returns the [StreamCheckboxThemeData] from the nearest ancestor.
  StreamCheckboxThemeData get streamCheckboxTheme => StreamCheckboxTheme.of(this);

  /// Returns the [StreamCommandChipThemeData] from the nearest ancestor.
  StreamCommandChipThemeData get streamCommandChipTheme => StreamCommandChipTheme.of(this);

  /// Returns the [StreamContextMenuThemeData] from the nearest ancestor.
  StreamContextMenuThemeData get streamContextMenuTheme => StreamContextMenuTheme.of(this);

  /// Returns the [StreamContextMenuActionThemeData] from the nearest ancestor.
  StreamContextMenuActionThemeData get streamContextMenuActionTheme => StreamContextMenuActionTheme.of(this);

  /// Returns the [StreamEmojiButtonThemeData] from the nearest ancestor.
  StreamEmojiButtonThemeData get streamEmojiButtonTheme => StreamEmojiButtonTheme.of(this);

  /// Returns the [StreamEmojiChipThemeData] from the nearest ancestor.
  StreamEmojiChipThemeData get streamEmojiChipTheme => StreamEmojiChipTheme.of(this);

  /// Returns the [StreamListTileThemeData] from the nearest ancestor.
  StreamListTileThemeData get streamListTileTheme => StreamListTileTheme.of(this);

  /// Returns the [StreamMessageItemThemeData] from the nearest ancestor.
  StreamMessageItemThemeData get streamMessageItemTheme => StreamMessageItemTheme.of(this);

  /// Returns the [StreamMessageThemeData] from the nearest ancestor.
  StreamMessageThemeData get streamMessageTheme => StreamMessageTheme.of(this);

  /// Returns the [StreamTextInputThemeData] from the nearest ancestor.
  StreamTextInputThemeData get streamTextInputTheme => StreamTextInputTheme.of(this);

  /// Returns the [StreamOnlineIndicatorThemeData] from the nearest ancestor.
  StreamOnlineIndicatorThemeData get streamOnlineIndicatorTheme => StreamOnlineIndicatorTheme.of(this);

  /// Returns the [StreamPlaybackSpeedToggleThemeData] from the nearest ancestor.
  StreamPlaybackSpeedToggleThemeData get streamPlaybackSpeedToggleTheme => StreamPlaybackSpeedToggleTheme.of(this);

  /// Returns the [StreamProgressBarThemeData] from the nearest ancestor.
  StreamProgressBarThemeData get streamProgressBarTheme => StreamProgressBarTheme.of(this);

  /// Returns the [StreamReactionPickerThemeData] from the nearest ancestor.
  StreamReactionPickerThemeData get streamReactionPickerTheme => StreamReactionPickerTheme.of(this);

  /// Returns the [StreamReactionsThemeData] from the nearest ancestor.
  StreamReactionsThemeData get streamReactionsTheme => StreamReactionsTheme.of(this);

  /// Returns the [StreamSkeletonLoadingThemeData] from the nearest ancestor.
  StreamSkeletonLoadingThemeData get streamSkeletonLoadingTheme => StreamSkeletonLoadingTheme.of(this);

  /// Returns the [StreamStepperThemeData] from the nearest ancestor.
  StreamStepperThemeData get streamStepperTheme => StreamStepperTheme.of(this);

  /// Returns the [StreamToggleSwitchThemeData] from the nearest ancestor.
  StreamToggleSwitchThemeData get streamToggleSwitchTheme => StreamToggleSwitchTheme.of(this);
}
