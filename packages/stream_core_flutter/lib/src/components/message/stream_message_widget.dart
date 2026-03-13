import 'package:flutter/material.dart';

import '../../theme.dart';
import '../common/stream_visibility.dart';
import '../message_placement/stream_channel_kind.dart';
import '../message_placement/stream_message_alignment.dart';
import '../message_placement/stream_message_placement.dart';
import '../message_placement/stream_message_stack_position.dart';

/// The top-level message item widget used directly by message lists.
///
/// [StreamMessageWidget] composes a leading slot (typically an avatar)
/// alongside a content slot, and establishes the [StreamMessagePlacement]
/// that descendant message sub-components use for placement-aware styling.
///
/// {@tool snippet}
///
/// Incoming message with avatar and content:
///
/// ```dart
/// StreamMessageWidget(
///   leading: StreamAvatar(
///     imageUrl: user.avatarUrl,
///     placeholder: (context) => Text(user.initials),
///   ),
///   child: StreamMessageContent(
///     footer: StreamMessageMetadata(timestamp: Text('09:41')),
///     child: StreamMessageBubble(
///       child: StreamMessageText('Hello, world!'),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Outgoing message without avatar:
///
/// ```dart
/// StreamMessageWidget(
///   alignment: StreamMessageAlignment.end,
///   child: StreamMessageContent(
///     footer: StreamMessageMetadata(timestamp: Text('09:42')),
///     child: StreamMessageBubble(
///       child: StreamMessageText('Hey there!'),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageContent], for composing bubble, annotations, and metadata.
///  * [StreamMessagePlacement], the placement context this widget
///    establishes for descendants.
///  * [StreamMessageItemTheme], for theming message items.
class StreamMessageWidget extends StatelessWidget {
  /// Creates a message item.
  ///
  /// The [child] is required. An optional [leading] widget is displayed
  /// alongside the content. The [alignment], [stackPosition], and
  /// [channelKind] configure the [StreamMessagePlacement] for descendants.
  StreamMessageWidget({
    super.key,
    Widget? leading,
    required Widget child,
    StreamMessageAlignment alignment = .start,
    StreamMessageStackPosition stackPosition = .single,
    StreamChannelKind channelKind = .group,
    StreamVisibility? leadingVisibility,
    EdgeInsetsGeometry? padding,
    double? spacing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) : props = .new(
         leading: leading,
         child: child,
         alignment: alignment,
         stackPosition: stackPosition,
         channelKind: channelKind,
         leadingVisibility: leadingVisibility,
         padding: padding,
         spacing: spacing,
         onTap: onTap,
         onLongPress: onLongPress,
       );

  /// The properties that configure this message item.
  final StreamMessageWidgetProps props;

  @override
  Widget build(BuildContext context) => StreamMessagePlacement(
    placement: StreamMessagePlacementData(
      alignment: props.alignment,
      stackPosition: props.stackPosition,
      channelKind: props.channelKind,
    ),
    child: Builder(
      builder: (context) {
        final builder = StreamComponentFactory.of(context).messageWidget;
        if (builder != null) return builder(context, props);
        return DefaultStreamMessageWidget(props: props);
      },
    ),
  );
}

/// Properties for configuring a [StreamMessageWidget].
///
/// See also:
///
///  * [StreamMessageWidget], which uses these properties.
class StreamMessageWidgetProps {
  /// Creates properties for a message item.
  const StreamMessageWidgetProps({
    this.leading,
    required this.child,
    this.alignment = .start,
    this.stackPosition = .single,
    this.channelKind = .group,
    this.leadingVisibility,
    this.padding,
    this.spacing,
    this.onTap,
    this.onLongPress,
  });

  /// Optional widget displayed alongside the content.
  ///
  /// Typically an avatar. Positioned at the start or end of the row
  /// depending on [alignment].
  ///
  /// When null, no leading widget is shown and no space is reserved.
  final Widget? leading;

  /// The main content of the message item.
  ///
  /// Typically a [StreamMessageContent] composing bubble, annotations,
  /// metadata, and reactions.
  final Widget child;

  /// The horizontal alignment of the message.
  ///
  /// Determines the element order in the row and establishes the
  /// [StreamMessagePlacement] alignment for descendants.
  ///
  /// Defaults to [StreamMessageAlignment.start].
  final StreamMessageAlignment alignment;

  /// The position of this message within a consecutive stack.
  ///
  /// Establishes the [StreamMessagePlacement] stack position for
  /// descendants, which sub-components use to adjust visual treatment
  /// (e.g. corner radii).
  ///
  /// Defaults to [StreamMessageStackPosition.single].
  final StreamMessageStackPosition stackPosition;

  /// The kind of channel this message is displayed in.
  ///
  /// Establishes the [StreamMessagePlacement] channel kind for
  /// descendants, which sub-components use to adapt their appearance
  /// (e.g. hiding avatars in direct channels).
  ///
  /// Defaults to [StreamChannelKind.group].
  final StreamChannelKind channelKind;

  /// Overrides the leading widget visibility for this message item.
  ///
  /// When non-null, takes precedence over the theme-resolved value from
  /// [StreamMessageItemThemeData.leadingVisibility].
  ///
  /// When null (the default), the visibility is determined by the theme.
  final StreamVisibility? leadingVisibility;

  /// Outer padding around the entire message item.
  ///
  /// When non-null, takes precedence over the theme value from
  /// [StreamMessageItemThemeData.padding].
  ///
  /// When null (the default), the padding is determined by the theme.
  final EdgeInsetsGeometry? padding;

  /// Horizontal spacing between the leading avatar and the content.
  ///
  /// When non-null, takes precedence over the theme value from
  /// [StreamMessageItemThemeData.spacing].
  ///
  /// When null (the default), the spacing is determined by the theme.
  final double? spacing;

  /// Called when the message item is tapped.
  final VoidCallback? onTap;

  /// Called when the message item is long-pressed.
  final VoidCallback? onLongPress;
}

/// The default implementation of [StreamMessageWidget].
///
/// See also:
///
///  * [StreamMessageWidget], the public API widget.
///  * [StreamMessageWidgetProps], which configures this widget.
class DefaultStreamMessageWidget extends StatelessWidget {
  /// Creates a default message item with the given [props].
  const DefaultStreamMessageWidget({super.key, required this.props});

  /// The properties that configure this message item.
  final StreamMessageWidgetProps props;

  @override
  Widget build(BuildContext context) {
    final placement = StreamMessagePlacement.of(context);
    final theme = StreamMessageItemTheme.of(context);
    final defaults = _StreamMessageWidgetDefaults(context);

    final resolve = StreamMessageStyleResolver(placement, [theme, defaults]);

    final effectivePadding = props.padding ?? theme.padding ?? defaults.padding;
    final effectiveSpacing = props.spacing ?? theme.spacing ?? defaults.spacing;
    final effectiveBackgroundColor = theme.backgroundColor ?? StreamColors.transparent;
    final effectiveLeadingVisibility = props.leadingVisibility ?? resolve((theme) => theme?.leadingVisibility);

    Widget? leadingWidget;
    if (props.leading case final leading?) {
      final effectiveAvatarSize = theme.avatarSize ?? defaults.avatarSize;

      leadingWidget = StreamAvatarTheme(
        data: .new(size: effectiveAvatarSize),
        child: leading,
      );

      leadingWidget = switch (effectiveLeadingVisibility) {
        StreamVisibility.visible => leadingWidget,
        StreamVisibility.hidden => Visibility.maintain(visible: false, child: leadingWidget),
        StreamVisibility.gone => null,
      };
    }

    final content = Flexible(child: props.child);

    final children = switch (props.alignment) {
      StreamMessageAlignment.start => [?leadingWidget, content],
      StreamMessageAlignment.end => [content, ?leadingWidget],
    };

    return Material(
      animateColor: true,
      color: effectiveBackgroundColor,
      child: InkWell(
        onTap: props.onTap,
        onLongPress: props.onLongPress,
        child: Padding(
          padding: effectivePadding,
          child: Row(
            spacing: effectiveSpacing,
            crossAxisAlignment: .end,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _StreamMessageWidgetDefaults extends StreamMessageItemThemeData {
  _StreamMessageWidgetDefaults(this._context);

  final BuildContext _context;

  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  double get spacing => _spacing.xs;

  @override
  StreamAvatarSize get avatarSize => .md;

  @override
  EdgeInsetsGeometry get padding => .symmetric(horizontal: _spacing.md);

  @override
  StreamMessageStyleVisibility get leadingVisibility => .resolveWith(
    (placement) => switch ((placement.channelKind, placement.alignment, placement.stackPosition)) {
      (.direct, _, _) || (_, .end, _) => .gone,
      (_, _, .top || .middle) => .hidden,
      (_, _, .single || .bottom) => .visible,
    },
  );
}
