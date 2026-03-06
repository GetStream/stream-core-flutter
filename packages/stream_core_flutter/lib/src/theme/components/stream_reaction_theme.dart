import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_reaction_theme.g.theme.dart';

/// Visual style variants for reactions.
enum StreamReactionsType {
  /// Each reaction type is rendered as an individual pill.
  segmented,

  /// Multiple reaction types are grouped into a single cluster.
  clustered,
}

/// Vertical position of reactions relative to the child.
enum StreamReactionsPosition {
  /// Reactions are rendered above the child.
  ///
  /// When `overlap` is true, the reaction strip overlaps the child's top
  /// edge by [StreamReactionsThemeData.overlapExtent].
  header,

  /// Reactions are rendered below the child.
  footer,
}

/// Horizontal alignment of reactions relative to the child.
enum StreamReactionsAlignment {
  /// Align reactions to the leading edge of the child.
  ///
  /// When reactions are wider than the child they extend past the trailing
  /// edge.
  start,

  /// Align reactions to the trailing edge of the child.
  ///
  /// When reactions are wider than the child they extend past the leading
  /// edge.
  end,
}

/// Applies a reaction theme to descendant [StreamReactions] widgets.
class StreamReactionsTheme extends InheritedTheme {
  /// Creates a reaction theme that controls descendant reactions.
  const StreamReactionsTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The reaction theme data for descendant widgets.
  final StreamReactionsThemeData data;

  /// Returns the merged [StreamReactionsThemeData] from local and global themes.
  static StreamReactionsThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamReactionsTheme>();
    return StreamTheme.of(context).reactionsTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamReactionsTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamReactionsTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamReactions] layout.
///
/// Visual styling for the reaction chips themselves (colors, borders, shadows,
/// padding) is controlled via [StreamEmojiChipTheme] — wrap a subtree with it
/// to override chip appearance specifically for reactions.
@themeGen
@immutable
class StreamReactionsThemeData with _$StreamReactionsThemeData {
  /// Creates a reaction layout theme with optional overrides.
  const StreamReactionsThemeData({
    this.spacing,
    this.gap,
    this.overlapExtent,
    this.indent,
  });

  /// Gap between adjacent reaction chips.
  final double? spacing;

  /// Spacing between the reaction strip and the child edge when
  /// [StreamReactionsProps.overlap] is `false`.
  final double? gap;

  /// How much the reaction strip overlaps the child when
  /// [StreamReactionsProps.overlap] is `true`.
  ///
  /// Higher values push reactions further into the child.
  final double? overlapExtent;

  /// Horizontal distance by which the reaction strip is shifted along the
  /// x-axis relative to the child.
  ///
  /// Defaults to `0` when not set.
  final double? indent;

  /// Linearly interpolate between two [StreamReactionsThemeData] objects.
  static StreamReactionsThemeData? lerp(
    StreamReactionsThemeData? a,
    StreamReactionsThemeData? b,
    double t,
  ) => _$StreamReactionsThemeData.lerp(a, b, t);
}
