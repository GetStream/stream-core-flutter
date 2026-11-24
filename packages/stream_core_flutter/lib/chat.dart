/// Chat-specific widgets and themes built on top of the shared design system.
///
/// Stream Chat SDKs import this single barrel — it re-exports `core.dart` for
/// the shared primitives (avatars, theme tokens, the component factory) plus
/// the chat-specific widgets (message bubble, composer attachments, reaction
/// pickers, and related theme classes).
///
/// Non-chat Stream SDKs (video, feeds, ...) must NOT import this barrel; pull
/// in the shared primitives from `core.dart` instead so that chat code does
/// not leak into their public API.
library;

export 'core.dart';

export 'src/components/buttons/stream_jump_to_unread_button.dart';
export 'src/components/controls/stream_command_chip.dart';
export 'src/components/message/stream_message_annotation.dart';
export 'src/components/message/stream_message_attachment.dart';
export 'src/components/message/stream_message_bubble.dart';
export 'src/components/message/stream_message_content.dart';
export 'src/components/message/stream_message_metadata.dart';
export 'src/components/message/stream_message_replies.dart';
export 'src/components/message/stream_message_text.dart';
export 'src/components/message_composer/attachment/stream_message_composer_attachment.dart';
export 'src/components/message_composer/attachment/stream_message_composer_edit_message_attachment.dart';
export 'src/components/message_composer/attachment/stream_message_composer_file_attachment.dart';
export 'src/components/message_composer/attachment/stream_message_composer_link_preview_attachment.dart';
export 'src/components/message_composer/attachment/stream_message_composer_media_attachment.dart';
export 'src/components/message_composer/attachment/stream_message_composer_reply_attachment.dart';
export 'src/components/message_composer/attachment/stream_message_composer_unsupported_attachment.dart';
export 'src/components/message_layout/stream_message_alignment.dart';
export 'src/components/message_layout/stream_message_channel_kind.dart';
export 'src/components/message_layout/stream_message_content_kind.dart';
export 'src/components/message_layout/stream_message_layout.dart';
export 'src/components/message_layout/stream_message_list_kind.dart';
export 'src/components/message_layout/stream_message_presentation.dart';
export 'src/components/message_layout/stream_message_stack_position.dart';
export 'src/components/reaction/stream_reaction_picker.dart';
export 'src/components/reaction/stream_reactions.dart';

export 'src/theme/components/stream_command_chip_theme.dart';
export 'src/theme/components/stream_jump_to_unread_button_theme.dart';
export 'src/theme/components/stream_message_annotation_theme.dart';
export 'src/theme/components/stream_message_attachment_theme.dart';
export 'src/theme/components/stream_message_bubble_theme.dart';
export 'src/theme/components/stream_message_composer_attachment_theme.dart';
export 'src/theme/components/stream_message_composer_edit_message_attachment_theme.dart';
export 'src/theme/components/stream_message_composer_file_attachment_theme.dart';
export 'src/theme/components/stream_message_composer_link_preview_attachment_theme.dart';
export 'src/theme/components/stream_message_composer_media_attachment_theme.dart';
export 'src/theme/components/stream_message_composer_reply_attachment_theme.dart';
export 'src/theme/components/stream_message_composer_unsupported_attachment_theme.dart';
export 'src/theme/components/stream_message_item_theme.dart';
export 'src/theme/components/stream_message_metadata_theme.dart';
export 'src/theme/components/stream_message_replies_theme.dart';
export 'src/theme/components/stream_message_style_property.dart';
export 'src/theme/components/stream_message_text_theme.dart';
export 'src/theme/components/stream_reaction_picker_theme.dart';
export 'src/theme/components/stream_reactions_theme.dart';
