import 'package:flutter/widgets.dart';

import 'stream_message_alignment.dart';
import 'stream_message_channel_kind.dart';
import 'stream_message_content_kind.dart';
import 'stream_message_list_kind.dart';
import 'stream_message_presentation.dart';
import 'stream_message_stack_position.dart';

// The aspect of a [StreamMessageLayoutData] that a widget depends on.
//
// Used by [StreamMessageLayout] (an [InheritedModel]) to provide
// fine-grained rebuild control. Widgets that only care about one aspect can
// subscribe to just that aspect and skip rebuilds when the others change.
enum _StreamMessageLayoutAspect {
  // The horizontal alignment axis (start / end).
  alignment,

  // The vertical stack position axis (single / top / middle / bottom).
  stackPosition,

  // The channel kind (direct / group).
  channelKind,

  // The list kind (channel / thread).
  listKind,

  // The content kind (standard / singleAttachment / jumbomoji).
  contentKind,

  // The presentation (standard / preview).
  presentation,
}

/// Provides [StreamMessageLayoutData] to descendant widgets.
///
/// Descendants can read the layout data using one of the static methods:
///
///  * [of] — returns the full context (rebuilds when any field changes).
///  * [messageAlignmentOf] — returns only the alignment (ignores other
///    field changes).
///  * [crossAxisAlignmentOf] — returns a [CrossAxisAlignment] derived from
///    the alignment (ignores other field changes).
///  * [alignmentDirectionalOf] — returns an [AlignmentDirectional] derived
///    from the alignment (ignores other field changes).
///  * [messageStackPositionOf] — returns only the stack position (ignores
///    other field changes).
///  * [channelKindOf] — returns only the channel kind (ignores other field
///    changes).
///  * [listKindOf] — returns only the list kind (ignores other field
///    changes).
///  * [contentKindOf] — returns only the content kind (ignores other
///    field changes).
///  * [presentationOf] — returns only the presentation (ignores other
///    field changes).
///
/// When no [StreamMessageLayout] is found in the tree, a default layout of
/// [StreamMessageAlignment.start] + [StreamMessageStackPosition.single] +
/// [StreamMessageChannelKind.group] + [StreamMessageListKind.channel] +
/// [StreamMessageContentKind.standard] +
/// [StreamMessagePresentation.standard] is returned.
///
/// {@tool snippet}
///
/// Read the full layout data in a sub-component:
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   final layout = StreamMessageLayout.of(context);
///   final shape = style?.shape?.resolve(layout)
///       ?? defaults.shape.resolve(layout);
///   // ...
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageLayoutData], the data this widget provides.
class StreamMessageLayout extends InheritedModel<_StreamMessageLayoutAspect> {
  /// Creates a layout scope that provides [data] to descendants.
  const StreamMessageLayout({
    super.key,
    required this.data,
    required super.child,
  });

  /// The message layout data provided to descendants.
  final StreamMessageLayoutData data;

  /// The data from the closest instance of this class that encloses the given
  /// context.
  ///
  /// You can use this function to query the entire
  /// [StreamMessageLayoutData]. When any of that information changes, your
  /// widget will be scheduled to be rebuilt, keeping your widget up-to-date.
  ///
  /// Since it is typical that the widget only requires a subset of properties
  /// of the [StreamMessageLayoutData], prefer using the more specific
  /// methods (for example: [messageAlignmentOf] and [messageStackPositionOf]),
  /// as those methods will not cause a widget to rebuild when unrelated
  /// properties are updated.
  ///
  /// If there is no [StreamMessageLayout] in scope, a default layout of
  /// [StreamMessageAlignment.start] + [StreamMessageStackPosition.single] +
  /// [StreamMessageChannelKind.group] + [StreamMessageListKind.channel] +
  /// [StreamMessageContentKind.standard] +
  /// [StreamMessagePresentation.standard] is returned.
  static StreamMessageLayoutData of(BuildContext context) => _of(context);

  static StreamMessageLayoutData _of(BuildContext context, [_StreamMessageLayoutAspect? aspect]) {
    final data = InheritedModel.inheritFrom<StreamMessageLayout>(context, aspect: aspect)?.data;
    if (data != null) return data;
    return const StreamMessageLayoutData();
  }

  /// Returns [StreamMessageLayoutData.alignment] from the nearest
  /// [StreamMessageLayout] ancestor.
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessageLayoutData.alignment] property of the ancestor
  /// [StreamMessageLayout] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessageLayoutData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static StreamMessageAlignment messageAlignmentOf(BuildContext context) {
    return _of(context, _StreamMessageLayoutAspect.alignment).alignment;
  }

  /// Returns a [CrossAxisAlignment] derived from
  /// [StreamMessageLayoutData.alignment] of the nearest
  /// [StreamMessageLayout] ancestor.
  ///
  /// [StreamMessageAlignment.start] maps to [CrossAxisAlignment.start] and
  /// [StreamMessageAlignment.end] maps to [CrossAxisAlignment.end].
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessageLayoutData.alignment] property of the ancestor
  /// [StreamMessageLayout] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessageLayoutData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static CrossAxisAlignment crossAxisAlignmentOf(BuildContext context) {
    return switch (messageAlignmentOf(context)) {
      StreamMessageAlignment.start => CrossAxisAlignment.start,
      StreamMessageAlignment.end => CrossAxisAlignment.end,
    };
  }

  /// Returns an [AlignmentDirectional] derived from
  /// [StreamMessageLayoutData.alignment] of the nearest
  /// [StreamMessageLayout] ancestor.
  ///
  /// [StreamMessageAlignment.start] maps to
  /// [AlignmentDirectional.centerStart] and [StreamMessageAlignment.end] maps
  /// to [AlignmentDirectional.centerEnd].
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessageLayoutData.alignment] property of the ancestor
  /// [StreamMessageLayout] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessageLayoutData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static AlignmentDirectional alignmentDirectionalOf(BuildContext context) {
    return switch (messageAlignmentOf(context)) {
      StreamMessageAlignment.start => AlignmentDirectional.centerStart,
      StreamMessageAlignment.end => AlignmentDirectional.centerEnd,
    };
  }

  /// Returns [StreamMessageLayoutData.stackPosition] from the nearest
  /// [StreamMessageLayout] ancestor.
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessageLayoutData.stackPosition] property of the
  /// ancestor [StreamMessageLayout] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessageLayoutData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static StreamMessageStackPosition messageStackPositionOf(BuildContext context) {
    return _of(context, _StreamMessageLayoutAspect.stackPosition).stackPosition;
  }

  /// Returns [StreamMessageLayoutData.channelKind] from the nearest
  /// [StreamMessageLayout] ancestor.
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessageLayoutData.channelKind] property of the
  /// ancestor [StreamMessageLayout] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessageLayoutData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static StreamMessageChannelKind channelKindOf(BuildContext context) {
    return _of(context, _StreamMessageLayoutAspect.channelKind).channelKind;
  }

  /// Returns [StreamMessageLayoutData.listKind] from the nearest
  /// [StreamMessageLayout] ancestor.
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessageLayoutData.listKind] property of the
  /// ancestor [StreamMessageLayout] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessageLayoutData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static StreamMessageListKind listKindOf(BuildContext context) {
    return _of(context, _StreamMessageLayoutAspect.listKind).listKind;
  }

  /// Returns [StreamMessageLayoutData.contentKind] from the nearest
  /// [StreamMessageLayout] ancestor.
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessageLayoutData.contentKind] property of the
  /// ancestor [StreamMessageLayout] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessageLayoutData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static StreamMessageContentKind contentKindOf(BuildContext context) {
    return _of(context, _StreamMessageLayoutAspect.contentKind).contentKind;
  }

  /// Returns [StreamMessageLayoutData.presentation] from the nearest
  /// [StreamMessageLayout] ancestor.
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessageLayoutData.presentation] property of the
  /// ancestor [StreamMessageLayout] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessageLayoutData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static StreamMessagePresentation presentationOf(BuildContext context) {
    return _of(context, _StreamMessageLayoutAspect.presentation).presentation;
  }

  @override
  bool updateShouldNotify(StreamMessageLayout oldWidget) => data != oldWidget.data;

  @override
  bool updateShouldNotifyDependent(
    StreamMessageLayout oldWidget,
    Set<Object> dependencies,
  ) => dependencies.any(
    (dependency) {
      if (dependency is! _StreamMessageLayoutAspect) return false;
      return switch (dependency) {
        .alignment => data.alignment != oldWidget.data.alignment,
        .stackPosition => data.stackPosition != oldWidget.data.stackPosition,
        .channelKind => data.channelKind != oldWidget.data.channelKind,
        .listKind => data.listKind != oldWidget.data.listKind,
        .contentKind => data.contentKind != oldWidget.data.contentKind,
        .presentation => data.presentation != oldWidget.data.presentation,
      };
    },
  );
}

/// The layout data for a message.
///
/// Combines positional properties — [alignment] (start vs end),
/// [stackPosition] (single, top, middle, bottom) — with environmental
/// context — [channelKind] (direct vs group), [listKind] (channel vs
/// thread), [presentation] (standard vs preview) — and content
/// classification — [contentKind] (standard, singleAttachment, jumbomoji) —
/// into a single value that [StreamMessageLayoutProperty] resolvers use to
/// compute layout-dependent styling.
///
/// {@tool snippet}
///
/// Create layout data for an end-aligned, single image message at the
/// top of a stack in a group channel:
///
/// ```dart
/// const layout = StreamMessageLayoutData(
///   alignment: StreamMessageAlignment.end,
///   stackPosition: StreamMessageStackPosition.top,
///   channelKind: StreamMessageChannelKind.group,
///   listKind: StreamMessageListKind.channel,
///   contentKind: StreamMessageContentKind.singleAttachment,
///   presentation: StreamMessagePresentation.standard,
/// );
///
/// print(layout.alignment);       // StreamMessageAlignment.end
/// print(layout.stackPosition);   // StreamMessageStackPosition.top
/// print(layout.channelKind);     // StreamMessageChannelKind.group
/// print(layout.listKind);        // StreamMessageListKind.channel
/// print(layout.contentKind);     // StreamMessageContentKind.singleAttachment
/// print(layout.presentation);    // StreamMessagePresentation.standard
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageAlignment], the horizontal alignment axis.
///  * [StreamMessageStackPosition], the vertical stacking axis.
///  * [StreamMessageChannelKind], the kind of channel the message is displayed in.
///  * [StreamMessageListKind], the kind of list the message is displayed in.
///  * [StreamMessageContentKind], the kind of content the message carries.
///  * [StreamMessagePresentation], how the message is presented to the user.
///  * [StreamMessageLayoutProperty], which resolves values from this context.
@immutable
class StreamMessageLayoutData {
  /// Creates message layout data.
  ///
  /// Defaults to a start-aligned, standalone message in a group channel list
  /// with standard content, presented inline ([StreamMessageAlignment.start] +
  /// [StreamMessageStackPosition.single] + [StreamMessageChannelKind.group] +
  /// [StreamMessageListKind.channel] + [StreamMessageContentKind.standard] +
  /// [StreamMessagePresentation.standard]).
  const StreamMessageLayoutData({
    this.alignment = .start,
    this.stackPosition = .single,
    this.channelKind = .group,
    this.listKind = .channel,
    this.contentKind = .standard,
    this.presentation = .standard,
  });

  /// The horizontal alignment of the message.
  final StreamMessageAlignment alignment;

  /// The position of the message within a consecutive stack.
  final StreamMessageStackPosition stackPosition;

  /// The kind of channel this message is displayed in.
  final StreamMessageChannelKind channelKind;

  /// The kind of list this message is displayed in.
  final StreamMessageListKind listKind;

  /// The kind of content this message carries.
  final StreamMessageContentKind contentKind;

  /// How this message is presented to the user.
  final StreamMessagePresentation presentation;

  /// Returns a copy of this [StreamMessageLayoutData] with the given fields
  /// replaced with new values.
  StreamMessageLayoutData copyWith({
    StreamMessageAlignment? alignment,
    StreamMessageStackPosition? stackPosition,
    StreamMessageChannelKind? channelKind,
    StreamMessageListKind? listKind,
    StreamMessageContentKind? contentKind,
    StreamMessagePresentation? presentation,
  }) {
    return StreamMessageLayoutData(
      alignment: alignment ?? this.alignment,
      stackPosition: stackPosition ?? this.stackPosition,
      channelKind: channelKind ?? this.channelKind,
      listKind: listKind ?? this.listKind,
      contentKind: contentKind ?? this.contentKind,
      presentation: presentation ?? this.presentation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StreamMessageLayoutData &&
        other.alignment == alignment &&
        other.stackPosition == stackPosition &&
        other.channelKind == channelKind &&
        other.listKind == listKind &&
        other.contentKind == contentKind &&
        other.presentation == presentation;
  }

  @override
  int get hashCode => Object.hash(alignment, stackPosition, channelKind, listKind, contentKind, presentation);

  @override
  String toString() =>
      'StreamMessageLayoutData(alignment: $alignment, stackPosition: $stackPosition, channelKind: $channelKind, listKind: $listKind, contentKind: $contentKind, presentation: $presentation)';
}
