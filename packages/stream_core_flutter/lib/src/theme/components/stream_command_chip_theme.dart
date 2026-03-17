import 'package:flutter/material.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_command_chip_theme.g.theme.dart';

/// Applies a command chip theme to descendant command chip widgets.
///
/// Wrap a subtree with [StreamCommandChipTheme] to override command chip
/// styling. Access the merged theme using [BuildContext.streamCommandChipTheme].
///
/// See also:
///
///  * [StreamCommandChipThemeData], which describes the command chip theme.
class StreamCommandChipTheme extends InheritedTheme {
  /// Creates a command chip theme that controls descendant command chips.
  const StreamCommandChipTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The command chip theme data for descendant widgets.
  final StreamCommandChipThemeData data;

  /// Returns the [StreamCommandChipThemeData] from the current theme context.
  ///
  /// This merges the local theme (if any) with the global theme from
  /// [StreamTheme].
  static StreamCommandChipThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamCommandChipTheme>();
    return StreamTheme.of(context).commandChipTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamCommandChipTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamCommandChipTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing command chip widgets.
///
/// See also:
///
///  * [StreamCommandChipTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamCommandChipThemeData with _$StreamCommandChipThemeData {
  /// Creates a command chip theme with optional color overrides.
  const StreamCommandChipThemeData({
    this.backgroundColor,
    this.labelColor,
    this.iconColor,
    this.minHeight,
  });

  /// The background color of the chip.
  final Color? backgroundColor;

  /// The color of the label text.
  final Color? labelColor;

  /// The color of the leading and trailing icons.
  final Color? iconColor;

  /// The minimum height of the chip.
  final double? minHeight;

  /// Linearly interpolate between two [StreamCommandChipThemeData] objects.
  static StreamCommandChipThemeData? lerp(
    StreamCommandChipThemeData? a,
    StreamCommandChipThemeData? b,
    double t,
  ) => _$StreamCommandChipThemeData.lerp(a, b, t);
}
