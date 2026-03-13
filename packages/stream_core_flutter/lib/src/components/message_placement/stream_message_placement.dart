import 'package:flutter/widgets.dart';

import 'stream_channel_kind.dart';
import 'stream_message_alignment.dart';
import 'stream_message_stack_position.dart';

// The aspect of a [StreamMessagePlacementData] that a widget depends on.
//
// Used by [StreamMessagePlacement] (an [InheritedModel]) to provide
// fine-grained rebuild control. Widgets that only care about one axis can
// subscribe to just that aspect and skip rebuilds when the other changes.
enum _StreamMessagePlacementAspect {
  // The horizontal alignment axis (start / end).
  alignment,

  // The vertical stack position axis (single / top / middle / bottom).
  stackPosition,

  // The channel kind (direct / group).
  channelKind,
}

/// Provides [StreamMessagePlacementData] to descendant widgets.
///
/// Descendants can read the placement using one of the static methods:
///
///  * [of] — returns the full placement (rebuilds when either axis changes).
///  * [alignmentOf] — returns only the alignment (ignores stack position
///    changes).
///  * [crossAxisAlignmentOf] — returns a [CrossAxisAlignment] derived from
///    the alignment (ignores stack position changes).
///  * [stackPositionOf] — returns only the stack position (ignores alignment
///    changes).
///  * [channelKindOf] — returns only the channel kind (ignores alignment and
///    stack position changes).
///
/// When no [StreamMessagePlacement] is found in the tree, a default placement
/// of [StreamMessageAlignment.start] + [StreamMessageStackPosition.single] +
/// [StreamChannelKind.group] is returned.
///
/// {@tool snippet}
///
/// Read the full placement in a sub-component:
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   final placement = StreamMessagePlacement.of(context);
///   final shape = style?.shape?.resolve(placement)
///       ?? defaults.shape.resolve(placement);
///   // ...
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessagePlacementData], the data this widget provides.
class StreamMessagePlacement extends InheritedModel<_StreamMessagePlacementAspect> {
  /// Creates a placement scope that provides [placement] to descendants.
  const StreamMessagePlacement({
    super.key,
    required this.placement,
    required super.child,
  });

  /// The message placement provided to descendants.
  final StreamMessagePlacementData placement;

  /// The data from the closest instance of this class that encloses the given
  /// context.
  ///
  /// You can use this function to query the entire
  /// [StreamMessagePlacementData]. When any of that information changes, your
  /// widget will be scheduled to be rebuilt, keeping your widget up-to-date.
  ///
  /// Since it is typical that the widget only requires a subset of properties
  /// of the [StreamMessagePlacementData], prefer using the more specific
  /// methods (for example: [alignmentOf] and [stackPositionOf]), as those
  /// methods will not cause a widget to rebuild when unrelated properties are
  /// updated.
  ///
  /// If there is no [StreamMessagePlacement] in scope, a default placement of
  /// [StreamMessageAlignment.start] + [StreamMessageStackPosition.single] is
  /// returned.
  static StreamMessagePlacementData of(BuildContext context) => _of(context);

  static StreamMessagePlacementData _of(BuildContext context, [_StreamMessagePlacementAspect? aspect]) {
    final placement = InheritedModel.inheritFrom<StreamMessagePlacement>(context, aspect: aspect)?.placement;
    if (placement != null) return placement;
    return const StreamMessagePlacementData();
  }

  /// Returns [StreamMessagePlacementData.alignment] from the nearest
  /// [StreamMessagePlacement] ancestor.
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessagePlacementData.alignment] property of the ancestor
  /// [StreamMessagePlacement] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessagePlacementData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static StreamMessageAlignment alignmentOf(BuildContext context) {
    return _of(context, _StreamMessagePlacementAspect.alignment).alignment;
  }

  /// Returns a [CrossAxisAlignment] derived from
  /// [StreamMessagePlacementData.alignment] of the nearest
  /// [StreamMessagePlacement] ancestor.
  ///
  /// [StreamMessageAlignment.start] maps to [CrossAxisAlignment.start] and
  /// [StreamMessageAlignment.end] maps to [CrossAxisAlignment.end].
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessagePlacementData.alignment] property of the ancestor
  /// [StreamMessagePlacement] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessagePlacementData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static CrossAxisAlignment crossAxisAlignmentOf(BuildContext context) {
    return switch (alignmentOf(context)) {
      StreamMessageAlignment.start => CrossAxisAlignment.start,
      StreamMessageAlignment.end => CrossAxisAlignment.end,
    };
  }

  /// Returns [StreamMessagePlacementData.stackPosition] from the nearest
  /// [StreamMessagePlacement] ancestor.
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessagePlacementData.stackPosition] property of the
  /// ancestor [StreamMessagePlacement] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessagePlacementData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static StreamMessageStackPosition stackPositionOf(BuildContext context) {
    return _of(context, _StreamMessagePlacementAspect.stackPosition).stackPosition;
  }

  /// Returns [StreamMessagePlacementData.channelKind] from the nearest
  /// [StreamMessagePlacement] ancestor.
  ///
  /// Use of this method will cause the given [context] to rebuild any time
  /// that the [StreamMessagePlacementData.channelKind] property of the
  /// ancestor [StreamMessagePlacement] changes.
  ///
  /// Prefer using this function over getting the attribute directly from the
  /// [StreamMessagePlacementData] returned from [of], because using this
  /// function will only rebuild the [context] when this specific attribute
  /// changes, not when _any_ attribute changes.
  static StreamChannelKind channelKindOf(BuildContext context) {
    return _of(context, _StreamMessagePlacementAspect.channelKind).channelKind;
  }

  @override
  bool updateShouldNotify(StreamMessagePlacement oldWidget) => placement != oldWidget.placement;

  @override
  bool updateShouldNotifyDependent(
    StreamMessagePlacement oldWidget,
    Set<Object> dependencies,
  ) => dependencies.any(
    (dependency) {
      if (dependency is! _StreamMessagePlacementAspect) return false;
      return switch (dependency) {
        .alignment => placement.alignment != oldWidget.placement.alignment,
        .stackPosition => placement.stackPosition != oldWidget.placement.stackPosition,
        .channelKind => placement.channelKind != oldWidget.placement.channelKind,
      };
    },
  );
}

/// Describes where a message sits within the message list layout.
///
/// Combines [alignment] (start vs end), [stackPosition]
/// (single, top, middle, bottom), and [channelKind] (direct vs group) into a
/// single value that [StreamMessageStyleProperty] resolvers use to compute
/// placement-dependent styling.
///
/// {@tool snippet}
///
/// Create a placement for an end-aligned message at the top of a stack in a
/// group channel:
///
/// ```dart
/// const placement = StreamMessagePlacementData(
///   alignment: StreamMessageAlignment.end,
///   stackPosition: StreamMessageStackPosition.top,
///   channelKind: StreamChannelKind.group,
/// );
///
/// print(placement.alignment);       // StreamMessageAlignment.end
/// print(placement.stackPosition);   // StreamMessageStackPosition.top
/// print(placement.channelKind);     // StreamChannelKind.group
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageAlignment], the horizontal alignment axis.
///  * [StreamMessageStackPosition], the vertical stacking axis.
///  * [StreamChannelKind], the kind of channel the message is displayed in.
///  * [StreamMessageStyleProperty], which resolves values based on placement.
@immutable
class StreamMessagePlacementData {
  /// Creates a message placement.
  ///
  /// Defaults to a start-aligned, standalone message in a group channel
  /// ([StreamMessageAlignment.start] + [StreamMessageStackPosition.single] +
  /// [StreamChannelKind.group]).
  const StreamMessagePlacementData({
    this.alignment = .start,
    this.stackPosition = .single,
    this.channelKind = .group,
  });

  /// The horizontal alignment of the message.
  final StreamMessageAlignment alignment;

  /// The position of the message within a consecutive stack.
  final StreamMessageStackPosition stackPosition;

  /// The kind of channel this message is displayed in.
  final StreamChannelKind channelKind;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StreamMessagePlacementData &&
        other.alignment == alignment &&
        other.stackPosition == stackPosition &&
        other.channelKind == channelKind;
  }

  @override
  int get hashCode => Object.hash(alignment, stackPosition, channelKind);

  @override
  String toString() =>
      'StreamMessagePlacementData(alignment: $alignment, stackPosition: $stackPosition, channelKind: $channelKind)';
}
