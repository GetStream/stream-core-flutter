import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_reactions_theme.g.theme.dart';

/// The visual presentation style of [StreamReactions].
///
/// Determines whether reactions are shown as individual chips or as a single
/// grouped chip.
enum StreamReactionsType {
  /// Shows each reaction type as an individual chip.
  segmented,

  /// Groups multiple reaction types into a single chip.
  clustered,
}

/// The vertical position of [StreamReactions] relative to the child.
enum StreamReactionsPosition {
  /// Places reactions above the child.
  header,

  /// Places reactions below the child.
  footer,
}

/// The horizontal alignment of [StreamReactions] relative to the child.
enum StreamReactionsAlignment {
  /// Aligns reactions to the leading edge of the child.
  start,

  /// Aligns reactions to the trailing edge of the child.
  end,
}

/// Applies a reactions theme to descendant [StreamReactions] widgets.
///
/// Wrap a subtree with [StreamReactionsTheme] to override reaction layout.
/// Access the merged theme using [BuildContext.streamReactionsTheme].
///
/// {@tool snippet}
///
/// Override reaction layout for a specific section:
///
/// ```dart
/// StreamReactionsTheme(
///   data: StreamReactionsThemeData(
///     spacing: 4,
///     gap: 6,
///     overlapExtent: 8,
///     indent: 4,
///   ),
///   child: StreamReactions.segmented(
///     items: [
///       StreamReactionsItem(emoji: Text('👍'), count: 3),
///       StreamReactionsItem(emoji: Text('❤️'), count: 2),
///     ],
///     child: Container(
///       padding: EdgeInsets.all(12),
///       child: Text('Looks good'),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamReactionsThemeData], which describes the reactions theme.
///  * [StreamReactions], the widget affected by this theme.
class StreamReactionsTheme extends InheritedTheme {
  /// Creates a reactions theme that controls descendant reactions.
  const StreamReactionsTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The reaction theme data for descendant widgets.
  final StreamReactionsThemeData data;

  /// Returns the [StreamReactionsThemeData] merged from local and global themes.
  ///
  /// Local values from the nearest [StreamReactionsTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
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
/// {@tool snippet}
///
/// Customize reaction layout globally:
///
/// ```dart
/// StreamTheme(
///   reactionsTheme: StreamReactionsThemeData(
///     spacing: 4,
///     gap: 6,
///     overlapExtent: 8,
///     indent: 4,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamReactions], the widget that uses this theme data.
///  * [StreamReactionsTheme], for overriding theme in a widget subtree.
///  * [StreamEmojiChipTheme], for customizing chip appearance.
@themeGen
@immutable
class StreamReactionsThemeData with _$StreamReactionsThemeData {
  /// Creates reaction theme data with optional overrides.
  const StreamReactionsThemeData({
    this.spacing,
    this.gap,
    this.overlapExtent,
    this.indent,
  });

  /// The gap between adjacent reaction chips.
  final double? spacing;

  /// The gap between the reaction strip and the child.
  ///
  /// Applied when reactions do not overlap the child.
  final double? gap;

  /// How much the reaction strip overlaps the child.
  ///
  /// Higher values move the reactions further into the child.
  final double? overlapExtent;

  /// The horizontal offset applied to the reaction strip.
  ///
  /// Positive values move reactions toward the trailing side, while negative
  /// values move them toward the leading side.
  final double? indent;

  /// Linearly interpolate between two [StreamReactionsThemeData] objects.
  static StreamReactionsThemeData? lerp(
    StreamReactionsThemeData? a,
    StreamReactionsThemeData? b,
    double t,
  ) => _$StreamReactionsThemeData.lerp(a, b, t);
}
