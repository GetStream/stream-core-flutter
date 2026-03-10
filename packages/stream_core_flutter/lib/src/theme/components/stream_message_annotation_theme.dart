import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_message_annotation_theme.g.theme.dart';

/// Applies a message annotation theme to descendant [StreamMessageAnnotation]
/// widgets.
///
/// Wrap a subtree with [StreamMessageAnnotationTheme] to override annotation
/// styling. Access the merged theme using
/// [BuildContext.streamMessageAnnotationTheme].
///
/// {@tool snippet}
///
/// Override annotation styling for a specific section:
///
/// ```dart
/// StreamMessageAnnotationTheme(
///   data: StreamMessageAnnotationThemeData(
///     style: StreamMessageAnnotationStyle(
///       textColor: Colors.purple,
///       spacing: 8,
///     ),
///   ),
///   child: StreamMessageAnnotation(
///     leading: Icon(Icons.bookmark),
///     label: Text('Saved'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageAnnotationThemeData], which describes the annotation theme.
///  * [StreamMessageAnnotationStyle], the value object holding visual props.
///  * [StreamMessageAnnotation], the widget affected by this theme.
class StreamMessageAnnotationTheme extends InheritedTheme {
  /// Creates a message annotation theme that controls descendant annotations.
  const StreamMessageAnnotationTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The message annotation theme data for descendant widgets.
  final StreamMessageAnnotationThemeData data;

  /// Returns the [StreamMessageAnnotationThemeData] merged from local and
  /// global themes.
  ///
  /// Local values from the nearest [StreamMessageAnnotationTheme] ancestor
  /// take precedence over global values from [StreamTheme.of].
  ///
  /// This allows partial overrides — for example, overriding only
  /// [StreamMessageAnnotationStyle.textColor] while inheriting other
  /// properties from the global theme.
  static StreamMessageAnnotationThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageAnnotationTheme>();
    return StreamTheme.of(context).messageAnnotationTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageAnnotationTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageAnnotationTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamMessageAnnotation] widgets.
///
/// Descendant widgets obtain their values from
/// [StreamMessageAnnotationTheme.of]. The [style] property is null by default,
/// with fallback values derived from the current [StreamTheme].
///
/// {@tool snippet}
///
/// Customize annotation appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   messageAnnotationTheme: StreamMessageAnnotationThemeData(
///     style: StreamMessageAnnotationStyle(
///       textColor: Colors.blue,
///       iconSize: 18,
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageAnnotationStyle], the value object holding visual props.
///  * [StreamMessageAnnotationTheme], for overriding the theme in a widget
///    subtree.
///  * [StreamMessageAnnotation], the widget that uses this theme data.
@themeGen
@immutable
class StreamMessageAnnotationThemeData with _$StreamMessageAnnotationThemeData {
  /// Creates a message annotation theme data with an optional base [style].
  const StreamMessageAnnotationThemeData({
    this.style,
  });

  /// The base annotation style.
  ///
  /// When the annotation widget resolves its effective style, this serves
  /// as the theme-level default that can be overridden by a direct widget prop.
  final StreamMessageAnnotationStyle? style;

  /// Linearly interpolate between two [StreamMessageAnnotationThemeData]
  /// objects.
  static StreamMessageAnnotationThemeData? lerp(
    StreamMessageAnnotationThemeData? a,
    StreamMessageAnnotationThemeData? b,
    double t,
  ) => _$StreamMessageAnnotationThemeData.lerp(a, b, t);
}

/// Visual style properties for a message annotation row.
///
/// [StreamMessageAnnotationStyle] is a reusable value object that can be
/// applied both as a theme value (via [StreamMessageAnnotationThemeData]) and
/// as a direct widget prop — similar to how [ButtonStyle] works with
/// [ElevatedButton].
///
/// {@tool snippet}
///
/// Create a custom annotation style:
///
/// ```dart
/// const style = StreamMessageAnnotationStyle(
///   textColor: Colors.purple,
///   iconColor: Colors.purple,
///   iconSize: 18,
///   spacing: 8,
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageAnnotationThemeData], which wraps this style for theming.
///  * [StreamMessageAnnotation], the widget that uses this style.
@themeGen
@immutable
class StreamMessageAnnotationStyle with _$StreamMessageAnnotationStyle {
  /// Creates a message annotation style with optional property overrides.
  const StreamMessageAnnotationStyle({
    this.textStyle,
    this.textColor,
    this.iconColor,
    this.iconSize,
    this.spacing,
    this.padding,
  });

  /// The default text style for the annotation label.
  ///
  /// This only controls typography. Color comes from [textColor].
  final TextStyle? textStyle;

  /// The default color for the annotation label text.
  final Color? textColor;

  /// The default color for the leading icon.
  final Color? iconColor;

  /// The default size for the leading icon.
  final double? iconSize;

  /// The gap between the leading widget and label.
  final double? spacing;

  /// The padding around the annotation row content.
  final EdgeInsetsGeometry? padding;

  /// Linearly interpolate between two [StreamMessageAnnotationStyle] instances.
  static StreamMessageAnnotationStyle? lerp(
    StreamMessageAnnotationStyle? a,
    StreamMessageAnnotationStyle? b,
    double t,
  ) => _$StreamMessageAnnotationStyle.lerp(a, b, t);
}
