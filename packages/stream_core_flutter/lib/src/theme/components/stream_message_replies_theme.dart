import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_message_replies_theme.g.theme.dart';

/// Applies a message replies theme to descendant [StreamMessageReplies]
/// widgets.
///
/// Wrap a subtree with [StreamMessageRepliesTheme] to override replies row
/// styling. Access the merged theme using
/// [BuildContext.streamMessageRepliesTheme].
///
/// {@tool snippet}
///
/// Override replies styling for a specific section:
///
/// ```dart
/// StreamMessageRepliesTheme(
///   data: StreamMessageRepliesThemeData(
///     labelColor: Colors.purple,
///     spacing: 12,
///   ),
///   child: StreamMessageReplies(
///     label: Text('3 replies'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageRepliesThemeData], which describes the replies theme.
///  * [StreamMessageReplies], the widget affected by this theme.
class StreamMessageRepliesTheme extends InheritedTheme {
  /// Creates a message replies theme that controls descendant replies rows.
  const StreamMessageRepliesTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The message replies theme data for descendant widgets.
  final StreamMessageRepliesThemeData data;

  /// Returns the [StreamMessageRepliesThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamMessageRepliesTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  ///
  /// This allows partial overrides — for example, overriding only
  /// [StreamMessageRepliesThemeData.labelColor] while inheriting other
  /// properties from the global theme.
  static StreamMessageRepliesThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageRepliesTheme>();
    return StreamTheme.of(context).messageRepliesTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageRepliesTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageRepliesTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamMessageReplies] widgets.
///
/// Descendant widgets obtain their values from [StreamMessageRepliesTheme.of].
/// All properties are null by default, with fallback values applied by
/// [DefaultStreamMessageReplies].
///
/// {@tool snippet}
///
/// Customize replies appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   messageRepliesTheme: StreamMessageRepliesThemeData(
///     labelColor: Colors.blue,
///     spacing: 12,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageRepliesTheme], for overriding the theme in a widget
///    subtree.
///  * [StreamMessageReplies], the widget that uses this theme data.
@themeGen
@immutable
class StreamMessageRepliesThemeData with _$StreamMessageRepliesThemeData {
  /// Creates a message replies theme data with optional property overrides.
  const StreamMessageRepliesThemeData({
    this.labelTextStyle,
    this.labelColor,
    this.spacing,
    this.padding,
    this.connectorColor,
    this.connectorStrokeWidth,
  });

  /// Defines the default text style for [StreamMessageReplies.label].
  ///
  /// This only controls typography. Color comes from [labelColor].
  final TextStyle? labelTextStyle;

  /// Defines the default color for [StreamMessageReplies.label].
  final Color? labelColor;

  /// The gap between elements (connector, avatars, label).
  final double? spacing;

  /// The padding around the replies row content.
  final EdgeInsetsGeometry? padding;

  /// The color of the connector path linking the row to the message bubble.
  final Color? connectorColor;

  /// The stroke width of the connector path.
  final double? connectorStrokeWidth;

  /// Linearly interpolate between two [StreamMessageRepliesThemeData] objects.
  static StreamMessageRepliesThemeData? lerp(
    StreamMessageRepliesThemeData? a,
    StreamMessageRepliesThemeData? b,
    double t,
  ) => _$StreamMessageRepliesThemeData.lerp(a, b, t);
}
