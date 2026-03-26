import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import 'stream_avatar_theme.dart';
import 'stream_message_annotation_theme.dart';
import 'stream_message_attachment_theme.dart';
import 'stream_message_bubble_theme.dart';
import 'stream_message_metadata_theme.dart';
import 'stream_message_replies_theme.dart';
import 'stream_message_style_property.dart';
import 'stream_message_text_theme.dart';

part 'stream_message_item_theme.g.theme.dart';

/// Applies a message item theme to descendant message widgets.
///
/// Wrap a subtree with [StreamMessageItemTheme] to override placement-aware
/// styling for message sub-components (bubble, annotation, metadata, replies).
///
/// {@tool snippet}
///
/// Override bubble colors based on placement:
///
/// ```dart
/// StreamMessageItemTheme(
///   data: StreamMessageItemThemeData(
///     backgroundColor: Colors.blue.shade50,
///     bubble: StreamMessageBubbleStyle(
///       backgroundColor: StreamMessageLayoutProperty.resolveWith((p) {
///         final isEnd = p.alignment == StreamMessageAlignment.end;
///         return isEnd ? Colors.blue.shade100 : Colors.grey.shade100;
///       }),
///     ),
///   ),
///   child: ...,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageItemThemeData], which describes the theme data.
class StreamMessageItemTheme extends InheritedTheme {
  /// Creates a message item theme that controls descendant message widgets.
  const StreamMessageItemTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The message item theme data for descendant widgets.
  final StreamMessageItemThemeData data;

  /// Returns the [StreamMessageItemThemeData] from the current theme context.
  ///
  /// This merges the local theme (if any) with the global theme from
  /// [StreamTheme].
  static StreamMessageItemThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageItemTheme>();
    return StreamTheme.of(context).messageItemTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageItemTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageItemTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing message item appearance and sub-components.
///
/// Properties are organized in two groups:
///
///  1. **Item-level** — visual and layout properties for the message item
///     itself ([backgroundColor], [leadingVisibility], [headerVisibility],
///     [footerVisibility], [padding], [spacing], [avatarSize]).
///  2. **Sub-component styles** — grouped style overrides for each child
///     component ([text], [bubble], [annotation], [metadata], [replies]).
///
/// A `null` field means "use defaults."
///
/// See also:
///
///  * [StreamMessageItemTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamMessageItemThemeData with _$StreamMessageItemThemeData {
  /// Creates message item theme data with optional overrides.
  const StreamMessageItemThemeData({
    this.backgroundColor,
    this.leadingVisibility,
    this.headerVisibility,
    this.footerVisibility,
    this.padding,
    this.spacing,
    this.avatarSize,
    this.text,
    this.bubble,
    this.attachment,
    this.annotation,
    this.metadata,
    this.replies,
  });

  /// Background color for the entire message item row.
  ///
  /// Typically used for state-driven styling (e.g. selected, reminder).
  /// When null, the message item has no background.
  final Color? backgroundColor;

  /// Controls the visibility of the leading widget based on placement.
  ///
  /// This resolves a [StreamVisibility] value from the current
  /// [StreamMessageLayoutData], allowing visibility to vary by stack
  /// position (e.g. only show the avatar on the bottom message of a stack).
  ///
  /// When null, the leading widget defaults to [StreamVisibility.visible].
  final StreamMessageLayoutVisibility? leadingVisibility;

  /// Controls the visibility of the header (annotations) based on placement.
  ///
  /// This resolves a [StreamVisibility] value from the current
  /// [StreamMessageLayoutData], allowing visibility to vary by placement.
  ///
  /// When null, the header defaults to [StreamVisibility.visible].
  final StreamMessageLayoutVisibility? headerVisibility;

  /// Controls the visibility of the footer (metadata) based on placement.
  ///
  /// This resolves a [StreamVisibility] value from the current
  /// [StreamMessageLayoutData], allowing visibility to vary by stack
  /// position (e.g. only show metadata on the bottom message of a stack).
  ///
  /// When null, the footer defaults to visible for single/bottom messages
  /// and gone for top/middle messages.
  final StreamMessageLayoutVisibility? footerVisibility;

  /// Outer padding around the entire message item.
  final EdgeInsetsGeometry? padding;

  /// Horizontal spacing between the leading avatar and the content.
  final double? spacing;

  /// Default size for the leading avatar.
  ///
  /// When non-null, descendant avatars inherit this size override.
  /// When null, avatars use the size from the nearest ancestor
  /// avatar theme or their own default.
  final StreamAvatarSize? avatarSize;

  /// Style overrides for the message text (markdown).
  final StreamMessageTextStyle? text;

  /// Style overrides for the message bubble.
  final StreamMessageBubbleStyle? bubble;

  /// Style overrides for message attachment containers.
  final StreamMessageAttachmentStyle? attachment;

  /// Style overrides for the message annotation.
  final StreamMessageAnnotationStyle? annotation;

  /// Style overrides for the message metadata.
  final StreamMessageMetadataStyle? metadata;

  /// Style overrides for the message replies.
  final StreamMessageRepliesStyle? replies;

  /// Linearly interpolate between two [StreamMessageItemThemeData] objects.
  static StreamMessageItemThemeData? lerp(
    StreamMessageItemThemeData? a,
    StreamMessageItemThemeData? b,
    double t,
  ) => _$StreamMessageItemThemeData.lerp(a, b, t);
}
