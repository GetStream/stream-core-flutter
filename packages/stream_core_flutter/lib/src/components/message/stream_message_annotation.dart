import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_message_annotation_theme.dart';
import '../../theme/components/stream_message_item_theme.dart';
import '../../theme/components/stream_message_style_property.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../message_layout/stream_message_alignment.dart';
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
/// The visual order is always `[leading, label, separator, trailing]` with
/// configurable spacing between them. Any slot that is null is omitted from
/// the row.
///
/// ## Wrapping
///
/// The row prefers to lay everything out on a single line. When the content
/// does not fit the available width, the [trailing] slot moves to a second
/// line as a whole instead of the [label] wrapping mid-sentence, and the
/// [separator] — which only reads as a separator between two things on the
/// same line — is dropped.
///
/// A [label] that is too wide even on its own still wraps across as many
/// lines as it needs, with [trailing] placed below it.
///
/// When [onTap] or [onLongPress] is provided, the entire row — including
/// its padding — becomes tappable. This gives a forgiving hit target for
/// annotations like "Also sent in channel · View" where the trailing link
/// and the label both lead to the same destination.
///
/// When neither is provided, the row is hit-transparent and will not
/// steal taps from widgets beneath it (e.g., in a [Stack] or overlay).
/// For more targeted behavior (e.g., a tappable trailing link while the
/// rest of the row does nothing), leave [onTap]/[onLongPress] null and
/// wrap the [trailing] widget with its own [GestureDetector].
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
///   label: Text('Also sent in channel'),
///   separator: StreamMessageAnnotation.separator,
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
  /// The [label] is required; [leading], [separator] and [trailing] are
  /// optional and omitted from the row when null. When [onTap] or
  /// [onLongPress] is provided, the entire row becomes tappable.
  StreamMessageAnnotation({
    super.key,
    Widget? leading,
    required Widget label,
    Widget? separator,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    StreamMessageAnnotationStyle? style,
  }) : props = .new(
         leading: leading,
         label: label,
         separator: separator,
         trailing: trailing,
         onTap: onTap,
         onLongPress: onLongPress,
         style: style,
       );

  /// The conventional separator between an annotation's label and its
  /// trailing slot: a middle dot.
  ///
  /// Pass it to [StreamMessageAnnotationProps.separator] to get the
  /// `label · trailing` reading used across the Stream SDKs:
  ///
  /// ```dart
  /// StreamMessageAnnotation(
  ///   leading: Icon(StreamIcons.bell),
  ///   label: Text('Reminder set'),
  ///   separator: StreamMessageAnnotation.separator,
  ///   trailing: Text('in 2 hours'),
  /// )
  /// ```
  static const Widget separator = Text('·');

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
    this.separator,
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

  /// The widget placed between [label] and [trailing], typically a
  /// [Text] holding a punctuation mark.
  ///
  /// Defaults to null — no separator. Pass
  /// [StreamMessageAnnotation.separator] for the middle dot used across the
  /// Stream SDKs.
  ///
  /// Only rendered when [trailing] is set and both fit on a single line: a
  /// separator dangling at the end of a wrapped row separates nothing.
  ///
  /// Styled like [label], and hidden from assistive technologies — a
  /// separator is punctuation, not content.
  final Widget? separator;

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

    final labelStyle = effectiveTextStyle.copyWith(color: effectiveTextColor);
    final labelWidget = AnimatedDefaultTextStyle(
      style: labelStyle,
      duration: kThemeChangeDuration,
      child: props.label,
    );

    Widget? separatorWidget;
    Widget? trailingWidget;
    if (props.trailing case final trailing?) {
      final effectiveTrailingTextStyle = resolve((s) => s?.trailingTextStyle);
      final effectiveTrailingTextColor = resolve((s) => s?.trailingTextColor);

      trailingWidget = AnimatedDefaultTextStyle(
        style: effectiveTrailingTextStyle.copyWith(color: effectiveTrailingTextColor),
        duration: kThemeChangeDuration,
        child: trailing,
      );

      // A separator with nothing after it separates nothing, so it only
      // exists alongside a trailing slot.
      if (props.separator case final separator?) {
        separatorWidget = ExcludeSemantics(
          child: AnimatedDefaultTextStyle(
            style: labelStyle,
            duration: kThemeChangeDuration,
            child: separator,
          ),
        );
      }
    }

    final child = Padding(
      padding: effectivePadding,
      child: _AnnotationRow(
        spacing: effectiveSpacing,
        alignment: layout.alignment,
        leading: leadingWidget,
        label: labelWidget,
        separator: separatorWidget,
        trailing: trailingWidget,
      ),
    );

    if (props.onTap != null || props.onLongPress != null) {
      return GestureDetector(
        behavior: .opaque,
        onTap: props.onTap,
        onLongPress: props.onLongPress,
        child: child,
      );
    }

    return child;
  }
}

/// The slots laid out by [_AnnotationRow], in visual order.
enum _AnnotationSlot { leading, label, separator, trailing }

/// Lays out an annotation's slots on a single line, falling back to two lines
/// when they don't fit.
///
/// A plain [Row] with a flexible label solves the overflow by wrapping the
/// label's text, which strands the trailing action beside the label's last
/// line. This lays out `[leading, label, separator, trailing]` as two atomic
/// groups instead: when the line is too narrow, `trailing` moves below
/// `[leading, label]` in full, and `separator` is dropped because it no
/// longer sits between anything.
///
/// The second line is indented to the label's edge, so it reads as a
/// continuation of the row rather than a new one. For an end-aligned message
/// both lines are flushed to the end edge instead.
class _AnnotationRow extends SlottedMultiChildRenderObjectWidget<_AnnotationSlot, RenderBox> {
  const _AnnotationRow({
    required this.spacing,
    required this.alignment,
    required this.label,
    this.leading,
    this.separator,
    this.trailing,
  });

  /// The gap between slots, and between the two lines when the row wraps.
  final double spacing;

  /// Which edge the row is aligned to, mirroring the message it annotates.
  final StreamMessageAlignment alignment;

  final Widget label;
  final Widget? leading;
  final Widget? separator;
  final Widget? trailing;

  @override
  Iterable<_AnnotationSlot> get slots => _AnnotationSlot.values;

  @override
  Widget? childForSlot(_AnnotationSlot slot) => switch (slot) {
    _AnnotationSlot.leading => leading,
    _AnnotationSlot.label => label,
    _AnnotationSlot.separator => separator,
    _AnnotationSlot.trailing => trailing,
  };

  @override
  _RenderAnnotationRow createRenderObject(BuildContext context) {
    return _RenderAnnotationRow(
      spacing: spacing,
      alignment: alignment,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderAnnotationRow renderObject) {
    renderObject
      ..spacing = spacing
      ..alignment = alignment
      ..textDirection = Directionality.of(context);
  }
}

/// The resolved geometry of one [_RenderAnnotationRow] layout pass.
///
/// [offsets] is keyed by slot and holds the position of every slot that takes
/// part in the layout. A slot missing from the map is not painted — which is
/// how the separator disappears on a wrapped row.
typedef _RowGeometry = ({Size size, Map<_AnnotationSlot, Offset> offsets});

class _RenderAnnotationRow extends RenderBox with SlottedContainerRenderObjectMixin<_AnnotationSlot, RenderBox> {
  _RenderAnnotationRow({
    required this._spacing,
    required this._alignment,
    required this._textDirection,
  });

  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  StreamMessageAlignment get alignment => _alignment;
  StreamMessageAlignment _alignment;
  set alignment(StreamMessageAlignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  RenderBox? get _leading => childForSlot(_AnnotationSlot.leading);
  RenderBox get _label => childForSlot(_AnnotationSlot.label)!;
  RenderBox? get _separator => childForSlot(_AnnotationSlot.separator);
  RenderBox? get _trailing => childForSlot(_AnnotationSlot.trailing);

  // The slots painted by the last layout pass, in paint order. Rebuilt on
  // every layout, so it also decides what can be hit-tested.
  final _paintOrder = <_AnnotationSlot>[];

  /// Measures every slot and resolves where each one goes.
  ///
  /// [layoutChild] is [ChildLayoutHelper.layoutChild] for a real layout pass
  /// and [ChildLayoutHelper.dryLayoutChild] for a dry one, so both passes
  /// share this single source of truth.
  _RowGeometry _computeGeometry(BoxConstraints constraints, ChildLayouter layoutChild) {
    final leading = _leading;
    final separator = _separator;
    final trailing = _trailing;

    const unbounded = BoxConstraints();
    final leadingSize = leading == null ? Size.zero : layoutChild(leading, unbounded);
    final separatorSize = separator == null ? Size.zero : layoutChild(separator, unbounded);
    final trailingSize = trailing == null ? Size.zero : layoutChild(trailing, unbounded);

    // The label starts after the leading slot, and everything from the
    // separator onwards trails it. Absent slots claim no gap.
    final gutter = leading == null ? 0.0 : leadingSize.width + spacing;
    final separatorGap = separator == null ? 0.0 : spacing;
    final trailingGap = trailing == null ? 0.0 : spacing;
    final tail = separatorGap + separatorSize.width + trailingGap + trailingSize.width;

    // How wide the label wants to be before it starts wrapping its text.
    final labelWidth = _label.getMaxIntrinsicWidth(double.infinity);

    final maxWidth = constraints.maxWidth;
    // Moving the trailing slot down is only a fix when there is one; a label
    // that overflows on its own gains nothing from a second line.
    final wraps = trailing != null && maxWidth.isFinite && gutter + labelWidth + tail > maxWidth;

    if (!wraps) {
      final labelSize = layoutChild(_label, BoxConstraints(maxWidth: math.max(0, maxWidth - gutter - tail)));

      final height = [
        leadingSize.height,
        labelSize.height,
        separatorSize.height,
        trailingSize.height,
      ].reduce(math.max);

      // Slots are centered against the tallest one.
      double dy(Size size) => (height - size.height) / 2;

      final labelEnd = gutter + labelSize.width;
      return (
        size: constraints.constrain(Size(labelEnd + tail, height)),
        offsets: {
          if (leading != null) _AnnotationSlot.leading: Offset(0, dy(leadingSize)),
          _AnnotationSlot.label: Offset(gutter, dy(labelSize)),
          if (separator != null) _AnnotationSlot.separator: Offset(labelEnd + separatorGap, dy(separatorSize)),
          if (trailing != null)
            _AnnotationSlot.trailing: Offset(
              labelEnd + separatorGap + separatorSize.width + trailingGap,
              dy(trailingSize),
            ),
        },
      );
    }

    // Wrapped: `[leading, label]` on the first line, `trailing` on the
    // second. The label keeps the full width to itself and wraps its own
    // text if it still doesn't fit.
    final labelSize = layoutChild(_label, BoxConstraints(maxWidth: math.max(0, maxWidth - gutter)));
    final firstLine = Size(gutter + labelSize.width, math.max(leadingSize.height, labelSize.height));

    // An end-aligned row hugs the end edge, so indenting the second line
    // would push it away from the message it belongs to.
    final alignsToEnd = alignment == StreamMessageAlignment.end;
    final indent = alignsToEnd ? 0.0 : gutter;
    final secondLine = Size(indent + trailingSize.width, trailingSize.height);

    final width = math.min(maxWidth, math.max(firstLine.width, secondLine.width));
    final size = constraints.constrain(Size(width, firstLine.height + spacing + secondLine.height));

    // Runs shorter than the row are pushed to whichever edge the row hugs.
    double runStart(Size line) => alignsToEnd ? size.width - line.width : 0;

    final firstLineStart = runStart(firstLine);
    return (
      size: size,
      offsets: {
        if (leading != null)
          _AnnotationSlot.leading: Offset(firstLineStart, (firstLine.height - leadingSize.height) / 2),
        _AnnotationSlot.label: Offset(firstLineStart + gutter, (firstLine.height - labelSize.height) / 2),
        _AnnotationSlot.trailing: Offset(runStart(secondLine) + indent, firstLine.height + spacing),
      },
    );
  }

  @override
  void performLayout() {
    final geometry = _computeGeometry(constraints, ChildLayoutHelper.layoutChild);
    size = geometry.size;

    _paintOrder
      ..clear()
      ..addAll(geometry.offsets.keys);

    final flip = textDirection == TextDirection.rtl;
    for (final MapEntry(key: slot, value: offset) in geometry.offsets.entries) {
      final child = childForSlot(slot)!;
      final parentData = child.parentData! as BoxParentData;
      parentData.offset = switch (flip) {
        true => Offset(size.width - offset.dx - child.size.width, offset.dy),
        false => offset,
      };
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeGeometry(constraints, ChildLayoutHelper.dryLayoutChild).size;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    // The narrowest the row can get is the wrapped form: the widest of its
    // two lines, each squeezed as far as its content allows.
    final leading = _leading;
    final gutter = leading == null ? 0.0 : leading.getMinIntrinsicWidth(height) + spacing;
    final firstLine = gutter + _label.getMinIntrinsicWidth(height);
    final secondLine = _trailing?.getMinIntrinsicWidth(height) ?? 0.0;
    return math.max(firstLine, secondLine);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    // The widest the row can get is the single-line form.
    var width = _label.getMaxIntrinsicWidth(height);
    for (final slot in [_leading, _separator, _trailing]) {
      if (slot == null) continue;
      width += slot.getMaxIntrinsicWidth(height) + spacing;
    }
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(width);

  // Whether the row is one line or two depends on the width it is given, so
  // its height follows straight from a dry pass at that width.
  double _intrinsicHeight(double width) {
    return _computeGeometry(BoxConstraints(maxWidth: width), ChildLayoutHelper.dryLayoutChild).size.height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final slot in _paintOrder) {
      final child = childForSlot(slot)!;
      final parentData = child.parentData! as BoxParentData;
      context.paintChild(child, offset + parentData.offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final slot in _paintOrder.reversed) {
      final child = childForSlot(slot)!;
      final parentData = child.parentData! as BoxParentData;
      final hit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (result, transformed) => child.hitTest(result, position: transformed),
      );
      if (hit) return true;
    }
    return false;
  }
}

class _StreamMessageAnnotationDefaults extends StreamMessageAnnotationStyle {
  _StreamMessageAnnotationDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  // Resolves to [standard] for inline messages, and to white for previews,
  // where the message sits on a scrim and annotations need the extra contrast.
  StreamMessageLayoutProperty<Color> _presentationAware(Color standard) => .resolveWith(
    (layout) => switch (layout.presentation) {
      .standard => standard,
      .preview => _colorScheme.textOnAccent,
    },
  );

  @override
  StreamMessageLayoutProperty<TextStyle> get textStyle => .all(_textTheme.metadataEmphasis);

  @override
  StreamMessageLayoutProperty<Color> get textColor => _presentationAware(_colorScheme.textPrimary);

  @override
  StreamMessageLayoutProperty<Color> get iconColor => _presentationAware(_colorScheme.textPrimary);

  @override
  StreamMessageLayoutProperty<double> get iconSize => .all(16);

  @override
  StreamMessageLayoutProperty<double> get spacing => .all(_spacing.xxs);

  @override
  StreamMessageLayoutProperty<EdgeInsetsGeometry> get padding => .all(.symmetric(vertical: _spacing.xxs));

  @override
  StreamMessageLayoutProperty<TextStyle> get trailingTextStyle => .all(_textTheme.metadataDefault);

  @override
  StreamMessageLayoutProperty<Color> get trailingTextColor => _presentationAware(_colorScheme.textPrimary);
}
