import 'package:flutter/material.dart';

import '../../theme.dart';

/// An annotation row for displaying contextual message annotations.
///
/// Displays an optional [leading] widget (typically an icon) and a [label]
/// widget in a horizontal row with themed styling. Can be used for various
/// annotation types such as "Saved", "Pinned", "Reminder", etc.
///
/// All content is provided by the caller via widget slots. The provided
/// widgets are automatically styled according to
/// [StreamMessageAnnotationStyle].
///
/// The visual order is always `[leading, label]` with configurable spacing
/// between them. When [leading] is null, only the label is shown.
///
/// {@tool snippet}
///
/// Basic annotation with icon and label:
///
/// ```dart
/// StreamMessageAnnotation(
///   leading: Icon(StreamIcons.bookmark),
///   label: Text('Saved'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Tappable annotation:
///
/// ```dart
/// StreamMessageAnnotation(
///   leading: Icon(StreamIcons.pin),
///   label: Text('Pinned'),
///   onTap: () => print('Annotation tapped'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageAnnotationStyle], for the visual style properties.
///  * [StreamMessageAnnotationThemeData], for customizing annotation
///    appearance.
///  * [StreamMessageAnnotationTheme], for overriding theme in a widget
///    subtree.
class StreamMessageAnnotation extends StatelessWidget {
  /// Creates a message annotation row.
  ///
  /// The [label] is required; [leading] is optional and omitted from the row
  /// when null.
  StreamMessageAnnotation({
    super.key,
    Widget? leading,
    required Widget label,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    double? spacing,
    EdgeInsetsGeometry? padding,
  }) : props = .new(
         leading: leading,
         label: label,
         onTap: onTap,
         onLongPress: onLongPress,
         spacing: spacing,
         padding: padding,
       );

  /// The properties that configure this annotation row.
  final StreamMessageAnnotationProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageAnnotation;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageAnnotation(props: props);
  }
}

/// Properties for configuring a [StreamMessageAnnotation].
///
/// See also:
///
///  * [StreamMessageAnnotation], which uses these properties.
class StreamMessageAnnotationProps {
  /// Creates properties for a message annotation row.
  const StreamMessageAnnotationProps({
    this.leading,
    required this.label,
    this.onTap,
    this.onLongPress,
    this.spacing,
    this.padding,
  });

  /// The leading widget, typically an [Icon].
  ///
  /// When null, the row displays only the [label].
  ///
  /// Styled by [StreamMessageAnnotationStyle.iconColor] and
  /// [StreamMessageAnnotationStyle.iconSize].
  final Widget? leading;

  /// The label widget, typically a [Text] showing the annotation type.
  ///
  /// Styled by [StreamMessageAnnotationStyle.textStyle] and
  /// [StreamMessageAnnotationStyle.textColor].
  final Widget label;

  /// Called when the annotation row is tapped.
  final VoidCallback? onTap;

  /// Called when the annotation row is long-pressed.
  final VoidCallback? onLongPress;

  /// The gap between the leading widget and label.
  ///
  /// When null, falls back to [StreamMessageAnnotationStyle.spacing].
  final double? spacing;

  /// The padding around the annotation row content.
  ///
  /// When null, falls back to [StreamMessageAnnotationStyle.padding].
  final EdgeInsetsGeometry? padding;
}

/// The default implementation of [StreamMessageAnnotation].
///
/// See also:
///
///  * [StreamMessageAnnotation], the public API widget.
///  * [StreamMessageAnnotationProps], which configures this widget.
class DefaultStreamMessageAnnotation extends StatelessWidget {
  /// Creates a default message annotation row with the given [props].
  const DefaultStreamMessageAnnotation({super.key, required this.props});

  /// The properties that configure this annotation row.
  final StreamMessageAnnotationProps props;

  @override
  Widget build(BuildContext context) {
    final style = context.streamMessageAnnotationTheme.style;
    final defaults = _StreamMessageAnnotationDefaults(context);

    final effectiveTextStyle = style?.textStyle ?? defaults.textStyle;
    final effectiveTextColor = style?.textColor ?? defaults.textColor;
    final effectiveSpacing = props.spacing ?? style?.spacing ?? defaults.spacing;
    final effectivePadding = props.padding ?? style?.padding ?? defaults.padding;

    Widget? leadingWidget;
    if (props.leading case final leading?) {
      final effectiveIconColor = style?.iconColor ?? defaults.iconColor;
      final effectiveIconSize = style?.iconSize ?? defaults.iconSize;

      leadingWidget = IconTheme.merge(
        data: IconThemeData(color: effectiveIconColor, size: effectiveIconSize),
        child: leading,
      );
    }

    final labelWidget = Flexible(
      child: AnimatedDefaultTextStyle(
        style: effectiveTextStyle.copyWith(color: effectiveTextColor),
        duration: kThemeChangeDuration,
        child: props.label,
      ),
    );

    final child = Padding(
      padding: effectivePadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: effectiveSpacing,
        children: [?leadingWidget, labelWidget],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: props.onTap,
      onLongPress: props.onLongPress,
      child: child,
    );
  }
}

class _StreamMessageAnnotationDefaults extends StreamMessageAnnotationStyle {
  _StreamMessageAnnotationDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  TextStyle get textStyle => _textTheme.metadataEmphasis;

  @override
  Color get textColor => _colorScheme.textPrimary;

  @override
  Color get iconColor => _colorScheme.textPrimary;

  @override
  double get iconSize => 16;

  @override
  double get spacing => _spacing.xxs;

  @override
  EdgeInsetsGeometry get padding => .symmetric(vertical: _spacing.xxs);
}
