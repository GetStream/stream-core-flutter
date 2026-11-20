import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_message_item_theme.dart';
import '../../theme/components/stream_message_mark_theme.dart';
import '../../theme/components/stream_message_style_property.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../message_layout/stream_message_layout.dart';

/// A short label in a message's metadata row, such as "Played by 3".
///
/// The [label] is drawn in a muted color, or in the accent color when
/// [highlighted]. A [separator] follows it, [StreamMessageMark.separator] by
/// default, setting it apart from the metadata after it. When [onTap] is set,
/// the label can be tapped, for example to open more detail about the mark.
///
/// {@tool snippet}
///
/// A highlighted mark that can be tapped:
///
/// ```dart
/// StreamMessageMark(
///   label: Text('Played by 3'),
///   highlighted: true,
///   onTap: () => showPlayers(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageMarkStyle], for customizing the mark's appearance.
///  * [StreamMessageMetadata], which shows a mark before the timestamp.
class StreamMessageMark extends StatelessWidget {
  /// Creates a message mark.
  StreamMessageMark({
    super.key,
    required Widget label,
    bool highlighted = false,
    Widget? separator = StreamMessageMark.separator,
    VoidCallback? onTap,
    StreamMessageMarkStyle? style,
  }) : props = .new(
         label: label,
         highlighted: highlighted,
         separator: separator,
         onTap: onTap,
         style: style,
       );

  /// The conventional separator between a mark and the metadata after it.
  ///
  /// Used for [StreamMessageMarkProps.separator] unless another one is given.
  static const Widget separator = Text('·');

  /// The properties that configure this mark.
  final StreamMessageMarkProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageMark;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageMark(props: props);
  }
}

/// Properties for configuring a [StreamMessageMark].
///
/// See also:
///
///  * [StreamMessageMark], which uses these properties.
final class StreamMessageMarkProps {
  /// Creates properties for a message mark.
  const StreamMessageMarkProps({
    required this.label,
    this.highlighted = false,
    this.separator = StreamMessageMark.separator,
    this.onTap,
    this.style,
  });

  /// The label widget, typically a [Text].
  ///
  /// Styled by [StreamMessageMarkStyle.textStyle], and by
  /// [StreamMessageMarkStyle.color] or [StreamMessageMarkStyle.highlightedColor].
  final Widget label;

  /// Whether the label uses [StreamMessageMarkStyle.highlightedColor] instead
  /// of [StreamMessageMarkStyle.color].
  final bool highlighted;

  /// The widget after the [label], separating it from the metadata that
  /// follows.
  ///
  /// Defaults to [StreamMessageMark.separator]; pass null when nothing follows
  /// the mark. Styled by [StreamMessageMarkStyle.textStyle] and
  /// [StreamMessageMarkStyle.separatorColor], and hidden from screen readers.
  final Widget? separator;

  /// Called when the label is tapped.
  ///
  /// When null, the label is not interactive.
  final VoidCallback? onTap;

  /// Optional style overrides for placement-aware styling.
  ///
  /// Fields left null fall back to the inherited [StreamMessageItemTheme],
  /// then to built-in defaults.
  final StreamMessageMarkStyle? style;
}

/// The default implementation of [StreamMessageMark].
///
/// See also:
///
///  * [StreamMessageMark], the public API widget.
///  * [StreamMessageMarkProps], which configures this widget.
class DefaultStreamMessageMark extends StatelessWidget {
  /// Creates a default message mark with the given [props].
  const DefaultStreamMessageMark({super.key, required this.props});

  /// The properties that configure this mark.
  final StreamMessageMarkProps props;

  @override
  Widget build(BuildContext context) {
    final layout = StreamMessageLayout.of(context);
    final themeStyle = StreamMessageItemTheme.of(context).mark;
    final defaults = _StreamMessageMarkDefaults(context);

    final resolve = StreamMessageLayoutResolver(layout, [props.style, themeStyle, defaults]);

    final effectiveTextStyle = resolve((s) => s?.textStyle);
    final effectiveSpacing = resolve((s) => s?.spacing);
    final effectiveLabelColor = switch (props.highlighted) {
      true => resolve((s) => s?.highlightedColor),
      false => resolve((s) => s?.color),
    };

    final labelWidget = AnimatedDefaultTextStyle(
      style: effectiveTextStyle.copyWith(color: effectiveLabelColor),
      duration: kThemeChangeDuration,
      child: props.label,
    );

    final label = switch (props.onTap) {
      final onTap? => GestureDetector(behavior: .opaque, onTap: onTap, child: labelWidget),
      null => labelWidget,
    };

    final separator = props.separator;
    if (separator == null) return label;

    final effectiveSeparatorColor = resolve((s) => s?.separatorColor);
    final separatorWidget = ExcludeSemantics(
      child: AnimatedDefaultTextStyle(
        style: effectiveTextStyle.copyWith(color: effectiveSeparatorColor),
        duration: kThemeChangeDuration,
        child: separator,
      ),
    );

    return Row(
      mainAxisSize: .min,
      spacing: effectiveSpacing,
      children: [label, separatorWidget],
    );
  }
}

class _StreamMessageMarkDefaults extends StreamMessageMarkStyle {
  _StreamMessageMarkDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  // Resolves to [standard] for inline messages, and to the on-accent text color
  // for previews, where the message sits on a scrim and needs contrast.
  StreamMessageLayoutProperty<Color> _presentationAware(Color standard) => .resolveWith(
    (layout) => switch (layout.presentation) {
      .standard => standard,
      .preview => _colorScheme.textOnAccent,
    },
  );

  @override
  StreamMessageLayoutProperty<TextStyle> get textStyle => .all(_textTheme.metadataDefault);

  @override
  StreamMessageLayoutProperty<Color> get color => _presentationAware(_colorScheme.textTertiary);

  @override
  StreamMessageLayoutProperty<Color> get highlightedColor => _presentationAware(_colorScheme.accentPrimary);

  @override
  StreamMessageLayoutProperty<Color> get separatorColor => _presentationAware(_colorScheme.textTertiary);

  @override
  StreamMessageLayoutProperty<double> get spacing => .all(_spacing.xs);
}
