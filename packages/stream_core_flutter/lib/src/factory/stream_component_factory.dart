import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../components.dart';

part 'stream_component_factory.g.theme.dart';

/// Provides component builders to descendant Stream widgets.
///
/// Wrap a subtree with [StreamComponentFactory] to customize how Stream
/// components are rendered. Access the builders using
/// [StreamComponentFactory.of], [StreamComponentFactory.maybeOf], or the
/// [BuildContext] extension
/// [StreamComponentFactoryExtension.streamComponentFactory].
///
/// The nearest [StreamComponentFactory] ancestor takes precedence - nested
/// factories completely override their parents rather than merging.
///
/// {@tool snippet}
///
/// Override button rendering for a subtree:
///
/// ```dart
/// StreamComponentFactory(
///   builders: StreamComponentBuilders(
///     button: (context, props) => MyCustomButton(props: props),
///   ),
///   child: Column(
///     children: [
///       StreamButton(label: 'Uses custom builder'),
///       StreamFileTypeIcon(type: StreamFileType.pdf), // Uses default
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamComponentBuilders], which holds the builder functions.
///  * [StreamButton], [StreamFileTypeIcon], widgets affected by this factory.
class StreamComponentFactory extends InheritedWidget {
  /// Creates a component factory that controls rendering of descendant widgets.
  const StreamComponentFactory({
    super.key,
    required this.builders,
    required super.child,
  });

  /// The component builders for descendant widgets.
  final StreamComponentBuilders builders;

  /// Finds the [StreamComponentBuilders] from the closest
  /// [StreamComponentFactory] ancestor that encloses the given context.
  ///
  /// This will return a default empty [StreamComponentBuilders] if no [StreamComponentFactory] is found
  ///
  /// Typical usage:
  ///
  /// ```dart
  /// final builders = StreamComponentFactory.of(context);
  /// ```
  ///
  /// If you're calling this in the same `build()` method that creates the
  /// `StreamComponentFactory`, consider using a `Builder` or refactoring into
  /// a separate widget to obtain a context below the [StreamComponentFactory].
  static StreamComponentBuilders of(BuildContext context) {
    final streamComponentFactory = context.dependOnInheritedWidgetOfExactType<StreamComponentFactory>();
    return streamComponentFactory?.builders ?? StreamComponentBuilders();
  }

  @override
  bool updateShouldNotify(StreamComponentFactory oldWidget) => builders != oldWidget.builders;
}

/// A function type that builds a widget from a [BuildContext] and typed props.
///
/// Used by [StreamComponentBuilders] to define custom component builders.
typedef StreamComponentBuilder<T> = Widget Function(BuildContext context, T props);

/// A collection of builders for customizing Stream component rendering.
///
/// All builders are nullable - when null, the component uses its default
/// implementation.
///
/// {@tool snippet}
///
/// Create builders with custom button implementation:
///
/// ```dart
/// final builders = StreamComponentBuilders(
///   button: (context, props) => MyCustomButton(props: props),
/// );
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Register a custom component builder via [extensions]:
///
/// ```dart
/// final builders = StreamComponentBuilders(
///   extensions: [
///     StreamComponentBuilderExtension<StreamMessageProps>(
///       builder: (context, props) => MyCustomMessage(props: props),
///     ),
///   ],
/// );
/// ```
///
/// Then retrieve it with [extension]:
///
/// ```dart
/// final builder = StreamComponentFactory.of(context).extension<StreamMessageProps>();
/// if (builder != null) return builder(context, props);
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamComponentFactory], which provides builders to descendants.
///  * [StreamComponentBuilderExtension], which wraps a custom component builder.
@immutable
@ThemeGen(constructor: 'raw')
class StreamComponentBuilders with _$StreamComponentBuilders {
  /// Creates component builders with optional custom implementations.
  ///
  /// Any builder not provided (null) will cause the component to use its
  /// default implementation.
  ///
  /// [extensions] accepts an [Iterable] of [StreamComponentBuilderExtension] instances, which are
  /// converted to a map keyed by [StreamComponentBuilderExtension.type] internally.
  factory StreamComponentBuilders({
    StreamComponentBuilder<StreamAppBarProps>? appBar,
    StreamComponentBuilder<StreamAvatarProps>? avatar,
    StreamComponentBuilder<StreamAvatarGroupProps>? avatarGroup,
    StreamComponentBuilder<StreamAvatarStackProps>? avatarStack,
    StreamComponentBuilder<StreamBadgeCountProps>? badgeCount,
    StreamComponentBuilder<StreamBadgeNotificationProps>? badgeNotification,
    StreamComponentBuilder<StreamButtonProps>? button,
    StreamComponentBuilder<StreamCheckboxProps>? checkbox,
    StreamComponentBuilder<StreamCommandChipProps>? commandChip,
    StreamComponentBuilder<StreamContextMenuActionProps>? contextMenuAction,
    StreamComponentBuilder<StreamEmojiProps>? emoji,
    StreamComponentBuilder<StreamEmojiButtonProps>? emojiButton,
    StreamComponentBuilder<StreamEmojiChipProps>? emojiChip,
    StreamComponentBuilder<StreamEmojiChipBarProps>? emojiChipBar,
    StreamComponentBuilder<StreamErrorBadgeProps>? errorBadge,
    StreamComponentBuilder<StreamFileTypeIconProps>? fileTypeIcon,
    StreamComponentBuilder<StreamListTileProps>? listTile,
    StreamComponentBuilder<StreamLoadingSpinnerProps>? loadingSpinner,
    StreamComponentBuilder<StreamMessageAnnotationProps>? messageAnnotation,
    StreamComponentBuilder<StreamMessageBubbleProps>? messageBubble,
    StreamComponentBuilder<StreamMessageContentProps>? messageContent,
    StreamComponentBuilder<StreamMessageMetadataProps>? messageMetadata,
    StreamComponentBuilder<StreamMessageRepliesProps>? messageReplies,
    StreamComponentBuilder<StreamMessageTextProps>? messageText,
    StreamComponentBuilder<StreamNetworkImageProps>? networkImage,
    StreamComponentBuilder<StreamOnlineIndicatorProps>? onlineIndicator,
    StreamComponentBuilder<StreamPlaybackSpeedToggleProps>? playbackSpeedToggle,
    StreamComponentBuilder<StreamProgressBarProps>? progressBar,
    StreamComponentBuilder<StreamReactionPickerProps>? reactionPicker,
    StreamComponentBuilder<StreamReactionsProps>? reactions,
    StreamComponentBuilder<StreamRetryBadgeProps>? retryBadge,
    StreamComponentBuilder<StreamSheetHeaderProps>? sheetHeader,
    StreamComponentBuilder<StreamSkeletonLoadingProps>? skeletonLoading,
    StreamComponentBuilder<StreamStepperProps>? stepper,
    StreamComponentBuilder<StreamTextInputProps>? textInput,
    StreamComponentBuilder<StreamSwitchProps>? toggleSwitch,
    StreamComponentBuilder<StreamImageSourceBadgeProps>? imageSourceBadge,
    StreamComponentBuilder<StreamJumpToUnreadButtonProps>? jumpToUnreadButton,
    Iterable<StreamComponentBuilderExtension<Object>>? extensions,
  }) {
    extensions ??= <StreamComponentBuilderExtension<Object>>[];

    return .raw(
      appBar: appBar,
      avatar: avatar,
      avatarGroup: avatarGroup,
      avatarStack: avatarStack,
      badgeCount: badgeCount,
      badgeNotification: badgeNotification,
      button: button,
      checkbox: checkbox,
      commandChip: commandChip,
      contextMenuAction: contextMenuAction,
      emoji: emoji,
      emojiButton: emojiButton,
      emojiChip: emojiChip,
      emojiChipBar: emojiChipBar,
      errorBadge: errorBadge,
      fileTypeIcon: fileTypeIcon,
      listTile: listTile,
      loadingSpinner: loadingSpinner,
      messageAnnotation: messageAnnotation,
      messageBubble: messageBubble,
      messageContent: messageContent,
      messageMetadata: messageMetadata,
      messageReplies: messageReplies,
      messageText: messageText,
      networkImage: networkImage,
      onlineIndicator: onlineIndicator,
      playbackSpeedToggle: playbackSpeedToggle,
      progressBar: progressBar,
      reactionPicker: reactionPicker,
      reactions: reactions,
      retryBadge: retryBadge,
      sheetHeader: sheetHeader,
      skeletonLoading: skeletonLoading,
      stepper: stepper,
      textInput: textInput,
      toggleSwitch: toggleSwitch,
      imageSourceBadge: imageSourceBadge,
      jumpToUnreadButton: jumpToUnreadButton,
      extensions: _extensionIterableToMap(extensions),
    );
  }

  /// Creates component builders from a pre-built extensions map.
  const StreamComponentBuilders.raw({
    required this.appBar,
    required this.avatar,
    required this.avatarGroup,
    required this.avatarStack,
    required this.badgeCount,
    required this.badgeNotification,
    required this.button,
    required this.checkbox,
    required this.commandChip,
    required this.contextMenuAction,
    required this.emoji,
    required this.emojiButton,
    required this.emojiChip,
    required this.emojiChipBar,
    required this.errorBadge,
    required this.fileTypeIcon,
    required this.listTile,
    required this.loadingSpinner,
    required this.messageAnnotation,
    required this.messageBubble,
    required this.messageContent,
    required this.messageMetadata,
    required this.messageReplies,
    required this.messageText,
    required this.networkImage,
    required this.onlineIndicator,
    required this.playbackSpeedToggle,
    required this.progressBar,
    required this.reactionPicker,
    required this.reactions,
    required this.retryBadge,
    required this.sheetHeader,
    required this.skeletonLoading,
    required this.stepper,
    required this.textInput,
    required this.toggleSwitch,
    required this.imageSourceBadge,
    required this.jumpToUnreadButton,
    required this.extensions,
  });

  /// Arbitrary additions to this builder set.
  ///
  /// To define extensions, pass an [Iterable] of [StreamComponentBuilderExtension] instances to
  /// [StreamComponentBuilders.new].
  ///
  /// To obtain an extension, use [extension].
  ///
  /// See also:
  ///
  ///  * [extension], a convenience function for obtaining a specific extension.
  final Map<Object, StreamComponentBuilderExtension<Object>> extensions;

  /// Used to obtain a [StreamComponentBuilder] from [extensions].
  ///
  /// Obtain with `StreamComponentFactory.of(context).extension<MyProps>()`.
  ///
  /// See [extensions].
  StreamComponentBuilder<T>? extension<T>() => (extensions[T] as StreamComponentBuilderExtension<T>?)?.call;

  /// Custom builder for app bar widgets.
  ///
  /// When null, [StreamAppBar] uses [DefaultStreamAppBar].
  final StreamComponentBuilder<StreamAppBarProps>? appBar;

  /// Custom builder for avatar widgets.
  ///
  /// When null, [StreamAvatar] uses [DefaultStreamAvatar].
  final StreamComponentBuilder<StreamAvatarProps>? avatar;

  /// Custom builder for avatar group widgets.
  ///
  /// When null, [StreamAvatarGroup] uses [DefaultStreamAvatarGroup].
  final StreamComponentBuilder<StreamAvatarGroupProps>? avatarGroup;

  /// Custom builder for avatar stack widgets.
  ///
  /// When null, [StreamAvatarStack] uses [DefaultStreamAvatarStack].
  final StreamComponentBuilder<StreamAvatarStackProps>? avatarStack;

  /// Custom builder for badge count widgets.
  ///
  /// When null, [StreamBadgeCount] uses [DefaultStreamBadgeCount].
  final StreamComponentBuilder<StreamBadgeCountProps>? badgeCount;

  /// Custom builder for badge notification widgets.
  ///
  /// When null, [StreamBadgeNotification] uses
  /// [DefaultStreamBadgeNotification].
  final StreamComponentBuilder<StreamBadgeNotificationProps>? badgeNotification;

  /// Custom builder for button widgets.
  ///
  /// When null, [StreamButton] uses [DefaultStreamButton].
  final StreamComponentBuilder<StreamButtonProps>? button;

  /// Custom builder for checkbox widgets.
  ///
  /// When null, [StreamCheckbox] uses [DefaultStreamCheckbox].
  final StreamComponentBuilder<StreamCheckboxProps>? checkbox;

  /// Custom builder for command chip widgets.
  ///
  /// When null, [StreamCommandChip] uses [DefaultStreamCommandChip].
  final StreamComponentBuilder<StreamCommandChipProps>? commandChip;

  /// Custom builder for context menu action widgets.
  ///
  /// When null, [StreamContextMenuAction] uses [DefaultStreamContextMenuAction].
  final StreamComponentBuilder<StreamContextMenuActionProps>? contextMenuAction;

  /// Custom builder for emoji widgets.
  ///
  /// When null, [StreamEmoji] uses [DefaultStreamEmoji].
  final StreamComponentBuilder<StreamEmojiProps>? emoji;

  /// Custom builder for emoji button widgets.
  ///
  /// When null, [StreamEmojiButton] uses [DefaultStreamEmojiButton].
  final StreamComponentBuilder<StreamEmojiButtonProps>? emojiButton;

  /// Custom builder for emoji chip widgets.
  ///
  /// When null, [StreamEmojiChip] uses [DefaultStreamEmojiChip].
  final StreamComponentBuilder<StreamEmojiChipProps>? emojiChip;

  /// Custom builder for emoji chip bar widgets.
  ///
  /// When null, [StreamEmojiChipBar] uses [DefaultStreamEmojiChipBar].
  final StreamComponentBuilder<StreamEmojiChipBarProps>? emojiChipBar;

  /// Custom builder for error badge widgets.
  ///
  /// When null, [StreamErrorBadge] uses [DefaultStreamErrorBadge].
  final StreamComponentBuilder<StreamErrorBadgeProps>? errorBadge;

  /// Custom builder for file type icon widgets.
  ///
  /// When null, [StreamFileTypeIcon] uses [DefaultStreamFileTypeIcon].
  final StreamComponentBuilder<StreamFileTypeIconProps>? fileTypeIcon;

  /// Custom builder for list tile widgets.
  ///
  /// When null, [StreamListTile] uses [DefaultStreamListTile].
  final StreamComponentBuilder<StreamListTileProps>? listTile;

  /// Custom builder for loading spinner widgets.
  ///
  /// When null, [StreamLoadingSpinner] uses [DefaultStreamLoadingSpinner].
  final StreamComponentBuilder<StreamLoadingSpinnerProps>? loadingSpinner;

  /// Custom builder for message annotation widgets.
  ///
  /// When null, [StreamMessageAnnotation] uses [DefaultStreamMessageAnnotation].
  final StreamComponentBuilder<StreamMessageAnnotationProps>? messageAnnotation;

  /// Custom builder for message bubble widgets.
  ///
  /// When null, [StreamMessageBubble] uses [DefaultStreamMessageBubble].
  final StreamComponentBuilder<StreamMessageBubbleProps>? messageBubble;

  /// Custom builder for message content layout widgets.
  ///
  /// When null, [StreamMessageContent] uses [DefaultStreamMessageContent].
  final StreamComponentBuilder<StreamMessageContentProps>? messageContent;

  /// Custom builder for message metadata widgets.
  ///
  /// When null, [StreamMessageMetadata] uses [DefaultStreamMessageMetadata].
  final StreamComponentBuilder<StreamMessageMetadataProps>? messageMetadata;

  /// Custom builder for message replies widgets.
  ///
  /// When null, [StreamMessageReplies] uses [DefaultStreamMessageReplies].
  final StreamComponentBuilder<StreamMessageRepliesProps>? messageReplies;

  /// Custom builder for message text (markdown) widgets.
  ///
  /// When null, [StreamMessageText] uses [DefaultStreamMessageText].
  final StreamComponentBuilder<StreamMessageTextProps>? messageText;

  /// Custom builder for network image widgets.
  ///
  /// When null, [StreamNetworkImage] uses [DefaultStreamNetworkImage].
  final StreamComponentBuilder<StreamNetworkImageProps>? networkImage;

  /// Custom builder for online indicator widgets.
  ///
  /// When null, [StreamOnlineIndicator] uses [DefaultStreamOnlineIndicator].
  final StreamComponentBuilder<StreamOnlineIndicatorProps>? onlineIndicator;

  /// Custom builder for playback speed toggle widgets.
  ///
  /// When null, [StreamPlaybackSpeedToggle] uses
  /// [DefaultStreamPlaybackSpeedToggle].
  final StreamComponentBuilder<StreamPlaybackSpeedToggleProps>? playbackSpeedToggle;

  /// Custom builder for progress bar widgets.
  ///
  /// When null, [StreamProgressBar] uses [DefaultStreamProgressBar].
  final StreamComponentBuilder<StreamProgressBarProps>? progressBar;

  /// Custom builder for reaction picker widgets.
  ///
  /// When null, [StreamReactionPicker] uses [DefaultStreamReactionPicker].
  final StreamComponentBuilder<StreamReactionPickerProps>? reactionPicker;

  /// Custom builder for reaction widgets.
  ///
  /// When null, [StreamReactions] uses [DefaultStreamReactions].
  final StreamComponentBuilder<StreamReactionsProps>? reactions;

  /// Custom builder for retry badge widgets.
  ///
  /// When null, [StreamRetryBadge] uses [DefaultStreamRetryBadge].
  final StreamComponentBuilder<StreamRetryBadgeProps>? retryBadge;

  /// Custom builder for sheet header widgets.
  ///
  /// When null, [StreamSheetHeader] uses [DefaultStreamSheetHeader].
  final StreamComponentBuilder<StreamSheetHeaderProps>? sheetHeader;

  /// Custom builder for skeleton loading shimmer widgets.
  ///
  /// When null, [StreamSkeletonLoading] uses [DefaultStreamSkeletonLoading].
  final StreamComponentBuilder<StreamSkeletonLoadingProps>? skeletonLoading;

  /// Custom builder for stepper widgets.
  ///
  /// When null, [StreamStepper] uses [DefaultStreamStepper].
  final StreamComponentBuilder<StreamStepperProps>? stepper;

  /// Custom builder for text input widgets.
  ///
  /// When null, [StreamTextInput] uses [DefaultStreamTextInput].
  final StreamComponentBuilder<StreamTextInputProps>? textInput;

  /// Custom builder for switch widgets.
  ///
  /// When null, [StreamSwitch] uses [DefaultStreamSwitch].
  final StreamComponentBuilder<StreamSwitchProps>? toggleSwitch;

  /// Custom builder for source badge widgets.
  ///
  /// When null, [StreamImageSourceBadge] uses [DefaultStreamImageSourceBadge].
  final StreamComponentBuilder<StreamImageSourceBadgeProps>? imageSourceBadge;

  /// Custom builder for jump-to-unread button widgets.
  ///
  /// When null, [StreamJumpToUnreadButton] uses
  /// [DefaultStreamJumpToUnreadButton].
  final StreamComponentBuilder<StreamJumpToUnreadButtonProps>? jumpToUnreadButton;

  // Convert the [extensionsIterable] passed to [StreamComponentBuilders.new]
  // to the stored [extensions] map, where each entry's key consists of the extension's type.
  static Map<Object, StreamComponentBuilderExtension<Object>> _extensionIterableToMap(
    Iterable<StreamComponentBuilderExtension<Object>> extensionsIterable,
  ) {
    return <Object, StreamComponentBuilderExtension<Object>>{
      for (final extension in extensionsIterable) extension.type: extension,
    };
  }
}

/// A typed builder extension for [StreamComponentBuilders].
///
/// Wraps a single [StreamComponentBuilder] and uses the Props type [T] as the
/// lookup key. This allows external packages to register custom component
/// builders without modifying the core [StreamComponentBuilders] class.
///
/// {@tool snippet}
///
/// Register a custom message builder:
///
/// ```dart
/// StreamComponentFactory(
///   builders: StreamComponentBuilders(
///     extensions: [
///       StreamComponentBuilderExtension<StreamMessageProps>(
///         builder: (context, props) => MyCustomMessage(props: props),
///       ),
///     ],
///   ),
///   child: child,
/// )
/// ```
///
/// Consume it inside a custom component:
///
/// ```dart
/// final builder = StreamComponentFactory.of(context).extension<StreamMessageProps>();
/// if (builder != null) return builder(context, props);
/// return DefaultStreamMessage(props: props);
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamComponentBuilders], which holds extensions.
///  * [StreamComponentBuilders.extension], for obtaining a specific extension.
@immutable
final class StreamComponentBuilderExtension<T> {
  /// Creates a builder extension for a component with Props type [T].
  const StreamComponentBuilderExtension({
    required StreamComponentBuilder<T> builder,
  }) : _builder = builder;

  // The internal builder function that creates the widget from the context and props.
  final StreamComponentBuilder<T> _builder;

  /// Invokes the builder with the given [context] and [props].
  Widget call(BuildContext context, T props) => _builder(context, props);

  /// The extension's type, used as the lookup key.
  Object get type => T;
}

/// Extension on [BuildContext] for convenient access to [StreamComponentBuilders].
///
/// {@tool snippet}
///
/// Access component builders from context:
///
/// ```dart
/// final builders = context.streamComponentFactory;
/// final button = builders?.button?.call(context, props);
/// ```
/// {@end-tool}
extension StreamComponentFactoryExtension on BuildContext {
  /// Returns the [StreamComponentBuilders] from the nearest
  /// [StreamComponentFactory] ancestor, or null if none exists.
  ///
  /// This is equivalent to calling [StreamComponentFactory.of].
  StreamComponentBuilders get streamComponentFactory => StreamComponentFactory.of(this);
}
