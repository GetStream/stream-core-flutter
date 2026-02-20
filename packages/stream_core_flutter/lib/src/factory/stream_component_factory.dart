import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../components.dart';

part 'stream_component_factory.g.theme.dart';

/// Provides component builders to descendant Stream widgets.
///
/// Wrap a subtree with [StreamComponentFactory] to customize how Stream
/// components are rendered. Access the builders using
/// [StreamComponentFactory.of], [StreamComponentFactory.maybeOf], or the
/// [BuildContext] extension [StreamComponentFactoryExtension.streamComponentFactory].
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
  /// This will throw a [FlutterError] if no [StreamComponentFactory] is found
  /// in the widget tree above the given context.
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
  ///
  /// If you want to return null instead of throwing, use [maybeOf].
  static StreamComponentBuilders of(BuildContext context) {
    final result = maybeOf(context);
    if (result != null) return result;

    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'StreamComponentFactory.of() called with a context that does not '
        'contain a StreamComponentFactory.',
      ),
      ErrorDescription(
        'No StreamComponentFactory ancestor could be found starting from the '
        'context that was passed to StreamComponentFactory.of(). This usually '
        'happens when the context used comes from the widget that creates the '
        'StreamComponentFactory itself.',
      ),
      ErrorHint(
        'To fix this, ensure that you are using a context that is a descendant '
        'of the StreamComponentFactory. You can use a Builder to get a new '
        'context that is under the StreamComponentFactory:\n\n'
        '  Builder(\n'
        '    builder: (context) {\n'
        '      final builders = StreamComponentFactory.of(context);\n'
        '      ...\n'
        '    },\n'
        '  )',
      ),
      ErrorHint(
        'Alternatively, split your build method into smaller widgets so that '
        'you get a new BuildContext that is below the StreamComponentFactory '
        'in the widget tree.',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  /// Finds the [StreamComponentBuilders] from the closest
  /// [StreamComponentFactory] ancestor that encloses the given context.
  ///
  /// Returns null if no such ancestor exists.
  ///
  /// See also:
  ///  * [of], which throws if no [StreamComponentFactory] is found.
  static StreamComponentBuilders? maybeOf(BuildContext context) {
    final streamComponentFactory = context.dependOnInheritedWidgetOfExactType<StreamComponentFactory>();
    return streamComponentFactory?.builders;
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
/// implementation. This follows the same pattern as Flutter's theme system
/// where widgets fall back to their defaults when theme values are null.
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
/// See also:
///
///  * [StreamComponentFactory], which provides builders to descendants.
@themeGen
@immutable
class StreamComponentBuilders with _$StreamComponentBuilders {
  /// Creates component builders with optional custom implementations.
  ///
  /// Any builder not provided (null) will cause the component to use its
  /// default implementation.
  const StreamComponentBuilders({
    this.avatar,
    this.avatarGroup,
    this.avatarStack,
    this.badgeCount,
    this.button,
    this.checkbox,
    this.contextMenuItem,
    this.emoji,
    this.emojiButton,
    this.fileTypeIcon,
    this.onlineIndicator,
    this.progressBar,
  });

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

  /// Custom builder for button widgets.
  ///
  /// When null, [StreamButton] uses [DefaultStreamButton].
  final StreamComponentBuilder<StreamButtonProps>? button;

  /// Custom builder for checkbox widgets.
  ///
  /// When null, [StreamCheckbox] uses [DefaultStreamCheckbox].
  final StreamComponentBuilder<StreamCheckboxProps>? checkbox;

  /// Custom builder for context menu item widgets.
  ///
  /// When null, [StreamContextMenuItem] uses [DefaultStreamContextMenuItem].
  final StreamComponentBuilder<StreamContextMenuItemProps>? contextMenuItem;

  /// Custom builder for emoji widgets.
  ///
  /// When null, [StreamEmoji] uses [DefaultStreamEmoji].
  final StreamComponentBuilder<StreamEmojiProps>? emoji;

  /// Custom builder for emoji button widgets.
  ///
  /// When null, [StreamEmojiButton] uses [DefaultStreamEmojiButton].
  final StreamComponentBuilder<StreamEmojiButtonProps>? emojiButton;

  /// Custom builder for file type icon widgets.
  ///
  /// When null, [StreamFileTypeIcon] uses [DefaultStreamFileTypeIcon].
  final StreamComponentBuilder<StreamFileTypeIconProps>? fileTypeIcon;

  /// Custom builder for online indicator widgets.
  ///
  /// When null, [StreamOnlineIndicator] uses [DefaultStreamOnlineIndicator].
  final StreamComponentBuilder<StreamOnlineIndicatorProps>? onlineIndicator;

  /// Custom builder for progress bar widgets.
  ///
  /// When null, [StreamProgressBar] uses [DefaultStreamProgressBar].
  final StreamComponentBuilder<StreamProgressBarProps>? progressBar;
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
  /// This is equivalent to calling [StreamComponentFactory.maybeOf].
  StreamComponentBuilders? get streamComponentFactory => StreamComponentFactory.maybeOf(this);
}
