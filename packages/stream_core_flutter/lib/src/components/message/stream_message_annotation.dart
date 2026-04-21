import 'package:flutter/material.dart';

import '../../theme.dart';
import '../message_layout/stream_message_layout.dart';

/// An annotation row for displaying contextual message annotations.
///
/// Displays an optional [leading] widget (typically an icon), a [label]
/// widget, and an optional [trailing] widget in a horizontal row. Can be
/// used for various annotation types such as "Saved", "Pinned", "Reminder",
/// etc.
///
/// All content is provided by the caller via widget slots. The provided
/// widgets are automatically styled according to
/// [StreamMessageAnnotationStyle].
///
/// The visual order is always `[leading, label, trailing]` with configurable
/// spacing between them. Any slot that is null is omitted from the row.
///
/// When [onTap] or [onLongPress] is provided, the entire row — including its
/// padding — becomes tappable. This gives a forgiving hit target for
/// annotations like "Also sent in channel · View" where the "View" trailing
/// link and the label both take the user to the same destination. For more
/// targeted hit areas (e.g., a tappable trailing link while the rest of the
/// row is inert), leave [onTap]/[onLongPress] null and wrap the [trailing]
/// widget with its own [GestureDetector].
///
/// Text/icon styling for [trailing] comes from
/// [StreamMessageAnnotationStyle.trailingTextStyle] and
/// [StreamMessageAnnotationStyle.trailingTextColor]. By default the trailing
/// text uses the primary text color; to render it as a tappable-looking link
/// (e.g., for a "View" action) pass a style with `trailingTextColor` set to
/// the theme's link color.
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
/// Annotation with a row-level tap and a link-colored trailing label:
///
/// ```dart
/// StreamMessageAnnotation(
///   onTap: () => openChannel(),
///   leading: Icon(StreamIcons.arrowUpRight),
///   label: Text('Also sent in channel · '),
///   trailing: Text('View'),
///   style: StreamMessageAnnotationStyle.from(
///     trailingTextColor: Theme.of(context).colorScheme.primary,
///   ),
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
  /// The [label] is required; [leading] and [trailing] are optional and
  /// omitted from the row when null. When [onTap] or [onLongPress] is
  /// provided, the entire row becomes tappable.
  StreamMessageAnnotation({
    super.key,
    Widget? leading,
    required Widget label,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    StreamMessageAnnotationStyle? style,
  }) : props = .new(
         leading: leading,
         label: label,
         trailing: trailing,
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
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.style,
  });

  /// The leading widget, typically an [Icon].
  ///
  /// When null, the row displays only the [label] (and [trailing] if set).
  ///
  /// Styled by [StreamMessageAnnotationStyle.iconColor] and
  /// [StreamMessageAnnotationStyle.iconSize].
  final Widget? leading;

  /// The label widget, typically a [Text] showing the annotation type.
  ///
  /// Styled by [StreamMessageAnnotationStyle.textStyle] and
  /// [StreamMessageAnnotationStyle.textColor].
  final Widget label;

  /// The trailing widget, typically a tappable link or a secondary label
  /// (e.g., a timestamp).
  ///
  /// Styled by [StreamMessageAnnotationStyle.trailingTextStyle] and
  /// [StreamMessageAnnotationStyle.trailingTextColor].
  final Widget? trailing;

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
    final layout = StreamMessageLayout.of(context);
    final annotationStyle = StreamMessageItemTheme.of(context).annotation;
    final defaults = _StreamMessageAnnotationDefaults(context);

    final resolve = StreamMessageLayoutResolver(layout, [props.style, annotationStyle, defaults]);

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

    Widget? trailingWidget;
    if (props.trailing case final trailing?) {
      final effectiveTrailingTextStyle = resolve((s) => s?.trailingTextStyle);
      final effectiveTrailingTextColor = resolve((s) => s?.trailingTextColor);

      trailingWidget = AnimatedDefaultTextStyle(
        style: effectiveTrailingTextStyle.copyWith(color: effectiveTrailingTextColor),
        duration: kThemeChangeDuration,
        child: trailing,
      );
    }

    final child = Padding(
      padding: effectivePadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: effectiveSpacing,
        children: [?leadingWidget, labelWidget, ?trailingWidget],
      ),
    );

    return GestureDetector(
      behavior: .opaque,
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
  StreamMessageLayoutProperty<TextStyle> get textStyle => .all(_textTheme.metadataEmphasis);

  @override
  StreamMessageLayoutProperty<Color> get textColor => .all(_colorScheme.textPrimary);

  @override
  StreamMessageLayoutProperty<Color> get iconColor => .all(_colorScheme.textPrimary);

  @override
  StreamMessageLayoutProperty<double> get iconSize => .all(16);

  @override
  StreamMessageLayoutProperty<double> get spacing => .all(_spacing.xxs);

  @override
  StreamMessageLayoutProperty<EdgeInsetsGeometry> get padding => .all(.symmetric(vertical: _spacing.xxs));

  @override
  StreamMessageLayoutProperty<TextStyle> get trailingTextStyle => .all(_textTheme.metadataDefault);

  @override
  StreamMessageLayoutProperty<Color> get trailingTextColor => .all(_colorScheme.textPrimary);
}
