import 'package:flutter/material.dart';

import '../../theme.dart';
import '../message_placement/stream_message_placement.dart';

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
///  * [StreamMessageAnnotationStyle], for customizing annotation appearance.
///  * [StreamMessageItemTheme], for theming via the widget tree.
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
    StreamMessageAnnotationStyle? style,
  }) : props = .new(
         leading: leading,
         label: label,
         onTap: onTap,
         onLongPress: onLongPress,
         style: style,
       );

  /// Creates a message annotation row with a rich text label.
  ///
  /// The [label] string is styled with the annotation's
  /// [StreamMessageAnnotationStyle.textStyle] (defaults to
  /// [StreamTextTheme.metadataEmphasis]). The [spans] are wrapped under a
  /// parent that applies [StreamMessageAnnotationStyle.spanTextStyle]
  /// (defaults to [StreamTextTheme.metadataDefault]), so spans without an
  /// explicit style automatically receive the secondary annotation style.
  ///
  /// Spans that specify an explicit [TextSpan.style] override the default.
  ///
  /// {@tool snippet}
  ///
  /// Annotation with secondary styled span:
  ///
  /// ```dart
  /// StreamMessageAnnotation.rich(
  ///   leading: Icon(StreamIcons.bellNotification),
  ///   label: 'Reminder set · ',
  ///   spans: [TextSpan(text: 'In 2 hours')],
  /// )
  /// ```
  /// {@end-tool}
  StreamMessageAnnotation.rich({
    super.key,
    Widget? leading,
    required String label,
    required List<InlineSpan> spans,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    StreamMessageAnnotationStyle? style,
  }) : props = StreamMessageAnnotationProps(
         leading: leading,
         label: _RichAnnotationLabel(label: label, spans: spans),
         onTap: onTap,
         onLongPress: onLongPress,
         style: style,
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
    this.style,
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

  /// Optional style overrides for placement-aware styling.
  ///
  /// Fields left null fall back to the inherited [StreamMessageItemTheme],
  /// then to built-in defaults.
  final StreamMessageAnnotationStyle? style;
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
    final placement = StreamMessagePlacement.of(context);
    final annotationStyle = props.style ?? StreamMessageItemTheme.of(context).annotation;
    final defaults = _StreamMessageAnnotationDefaults(context);

    final resolve = StreamMessageStyleResolver(placement, [annotationStyle, defaults]);

    final effectiveTextStyle = resolve((s) => s?.textStyle);
    final effectiveTextColor = resolve((s) => s?.textColor);
    final effectiveSpacing = resolve((s) => s?.spacing);
    final effectivePadding = resolve((s) => s?.padding);

    Widget? leadingWidget;
    if (props.leading case final leading?) {
      final effectiveIconColor = resolve((s) => s?.iconColor);
      final effectiveIconSize = resolve((s) => s?.iconSize);

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

// Builds a [Text.rich] where the [label] inherits the annotation's primary
// text style and the [spans] are wrapped under a parent [TextSpan] that
// applies the annotation's span style.
class _RichAnnotationLabel extends StatelessWidget {
  const _RichAnnotationLabel({required this.label, required this.spans});

  final String label;
  final List<InlineSpan> spans;

  @override
  Widget build(BuildContext context) {
    final placement = StreamMessagePlacement.of(context);
    final annotationStyle = StreamMessageItemTheme.of(context).annotation;
    final defaults = _StreamMessageAnnotationDefaults(context);

    final resolve = StreamMessageStyleResolver(placement, [annotationStyle, defaults]);

    final effectiveSpanStyle = resolve((s) => s?.spanTextStyle);
    final effectiveSpanColor = resolve((s) => s?.spanTextColor);

    return Text.rich(
      TextSpan(
        text: label,
        children: [
          TextSpan(
            style: effectiveSpanStyle.copyWith(
              color: effectiveSpanColor,
            ),
            children: spans,
          ),
        ],
      ),
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
  StreamMessageStyleProperty<TextStyle> get textStyle => .all(_textTheme.metadataEmphasis);

  @override
  StreamMessageStyleProperty<Color> get textColor => .all(_colorScheme.textPrimary);

  @override
  StreamMessageStyleProperty<TextStyle> get spanTextStyle => .all(_textTheme.metadataDefault);

  @override
  StreamMessageStyleProperty<Color> get spanTextColor => .all(_colorScheme.textPrimary);

  @override
  StreamMessageStyleProperty<Color> get iconColor => .all(_colorScheme.textPrimary);

  @override
  StreamMessageStyleProperty<double> get iconSize => .all(16);

  @override
  StreamMessageStyleProperty<double> get spacing => .all(_spacing.xxs);

  @override
  StreamMessageStyleProperty<EdgeInsetsGeometry> get padding => .all(.symmetric(vertical: _spacing.xxs));
}
