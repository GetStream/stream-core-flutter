import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_message_metadata_theme.g.theme.dart';

/// Applies a message metadata theme to descendant [StreamMessageMetadata]
/// widgets.
///
/// Wrap a subtree with [StreamMessageMetadataTheme] to override metadata row
/// styling. Access the merged theme using
/// [BuildContext.streamMessageMetadataTheme].
///
/// {@tool snippet}
///
/// Override metadata styling for a specific section:
///
/// ```dart
/// StreamMessageMetadataTheme(
///   data: StreamMessageMetadataThemeData(
///     usernameColor: Colors.blue,
///     spacing: 12,
///   ),
///   child: StreamMessageMetadata(
///     timestamp: Text('09:41'),
///     username: Text('Alice'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageMetadataThemeData], which describes the metadata theme.
///  * [StreamMessageMetadata], the widget affected by this theme.
class StreamMessageMetadataTheme extends InheritedTheme {
  /// Creates a message metadata theme that controls descendant metadata rows.
  const StreamMessageMetadataTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The message metadata theme data for descendant widgets.
  final StreamMessageMetadataThemeData data;

  /// Returns the [StreamMessageMetadataThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamMessageMetadataTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  ///
  /// This allows partial overrides — for example, overriding only
  /// [StreamMessageMetadataThemeData.usernameColor] while inheriting other
  /// properties from the global theme.
  static StreamMessageMetadataThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageMetadataTheme>();
    return StreamTheme.of(context).messageMetadataTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageMetadataTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageMetadataTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamMessageMetadata] widgets.
///
/// Descendant widgets obtain their values from [StreamMessageMetadataTheme.of].
/// All properties are null by default, with fallback values applied by
/// [DefaultStreamMessageMetadata].
///
/// {@tool snippet}
///
/// Customize metadata appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   messageMetadataTheme: StreamMessageMetadataThemeData(
///     usernameColor: Colors.blue,
///     timestampColor: Colors.grey,
///     spacing: 12,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageMetadataTheme], for overriding the theme in a widget
///    subtree.
///  * [StreamMessageMetadata], the widget that uses this theme data.
@themeGen
@immutable
class StreamMessageMetadataThemeData with _$StreamMessageMetadataThemeData {
  /// Creates a message metadata theme data with optional property overrides.
  const StreamMessageMetadataThemeData({
    this.usernameTextStyle,
    this.usernameColor,
    this.timestampTextStyle,
    this.timestampColor,
    this.editedTextStyle,
    this.editedColor,
    this.statusColor,
    this.statusIconSize,
    this.spacing,
    this.statusSpacing,
    this.minHeight,
  });

  /// Defines the default text style for [StreamMessageMetadata.username].
  ///
  /// This only controls typography. Color comes from [usernameColor].
  final TextStyle? usernameTextStyle;

  /// Defines the default color for [StreamMessageMetadata.username].
  final Color? usernameColor;

  /// Defines the default text style for [StreamMessageMetadata.timestamp].
  ///
  /// This only controls typography. Color comes from [timestampColor].
  final TextStyle? timestampTextStyle;

  /// Defines the default color for [StreamMessageMetadata.timestamp].
  final Color? timestampColor;

  /// Defines the default text style for [StreamMessageMetadata.edited].
  ///
  /// This only controls typography. Color comes from [editedColor].
  final TextStyle? editedTextStyle;

  /// Defines the default color for [StreamMessageMetadata.edited].
  final Color? editedColor;

  /// Defines the default color for [StreamMessageMetadata.status].
  ///
  /// Applied via [IconTheme] to the status icon slot.
  final Color? statusColor;

  /// Defines the default size for the status icon.
  ///
  /// Applied via [IconTheme] to the status icon slot.
  final double? statusIconSize;

  /// The gap between main elements (username, timestamp group, edited).
  final double? spacing;

  /// The gap between the status icon and the timestamp.
  final double? statusSpacing;

  /// The minimum height of the metadata row.
  final double? minHeight;

  /// Linearly interpolate between two [StreamMessageMetadataThemeData] objects.
  static StreamMessageMetadataThemeData? lerp(
    StreamMessageMetadataThemeData? a,
    StreamMessageMetadataThemeData? b,
    double t,
  ) => _$StreamMessageMetadataThemeData.lerp(a, b, t);
}
