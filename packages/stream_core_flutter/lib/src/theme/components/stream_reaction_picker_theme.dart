import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_reaction_picker_theme.g.theme.dart';

/// Applies a reaction picker theme to descendant [StreamReactionPicker]
/// widgets.
///
/// Wrap a subtree with [StreamReactionPickerTheme] to override reaction picker
/// layout. Access the merged theme using
/// [BuildContext.streamReactionPickerTheme].
///
/// {@tool snippet}
///
/// Override reaction picker layout for a specific section:
///
/// ```dart
/// StreamReactionPickerTheme(
///   data: StreamReactionPickerThemeData(
///     backgroundColor: Colors.white,
///     elevation: 4,
///     spacing: 2,
///   ),
///   child: StreamReactionPicker(
///     props: StreamReactionPickerProps(
///       items: [
///         StreamReactionPickerItem(key: 'like', emoji: Text('👍')),
///         StreamReactionPickerItem(key: 'love', emoji: Text('❤️')),
///       ],
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamReactionPickerThemeData], which describes the reaction picker
///    theme.
///  * [StreamReactionPicker], the widget affected by this theme.
class StreamReactionPickerTheme extends InheritedTheme {
  /// Creates a reaction picker theme that controls descendant reaction pickers.
  const StreamReactionPickerTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The reaction picker theme data for descendant widgets.
  final StreamReactionPickerThemeData data;

  /// Returns the [StreamReactionPickerThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamReactionPickerTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamReactionPickerThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamReactionPickerTheme>();
    return StreamTheme.of(context).reactionPickerTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamReactionPickerTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamReactionPickerTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamReactionPicker] layout.
///
/// {@tool snippet}
///
/// Customize reaction picker layout globally:
///
/// ```dart
/// StreamTheme(
///   reactionPickerTheme: StreamReactionPickerThemeData(
///     backgroundColor: Colors.white,
///     elevation: 4,
///     spacing: 2,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamReactionPicker], the widget that uses this theme data.
///  * [StreamReactionPickerTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamReactionPickerThemeData with _$StreamReactionPickerThemeData {
  /// Creates reaction picker theme data with optional overrides.
  const StreamReactionPickerThemeData({
    this.backgroundColor,
    this.padding,
    this.elevation,
    this.spacing,
    this.shape,
    this.side,
  });

  /// The background color of the reaction picker container.
  final Color? backgroundColor;

  /// The padding around the reaction picker content.
  final EdgeInsetsGeometry? padding;

  /// The elevation of the reaction picker container.
  final double? elevation;

  /// The gap between adjacent reaction items in the picker.
  final double? spacing;

  /// The shape of the reaction picker container.
  ///
  /// Falls back to a [RoundedSuperellipseBorder] with `StreamRadius.xxxxl`.
  final OutlinedBorder? shape;

  /// The border for the reaction picker container.
  final BorderSide? side;

  /// Linearly interpolate between two [StreamReactionPickerThemeData] objects.
  static StreamReactionPickerThemeData? lerp(
    StreamReactionPickerThemeData? a,
    StreamReactionPickerThemeData? b,
    double t,
  ) => _$StreamReactionPickerThemeData.lerp(a, b, t);
}
