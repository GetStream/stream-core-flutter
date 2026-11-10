import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_context_menu_heading_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import 'stream_context_menu.dart';
import 'stream_context_menu_action.dart';

/// The heading of a section inside a [StreamContextMenu], such as
/// "Microphone".
///
/// A heading shares the row metrics of a [StreamContextMenuAction] but draws
/// its [label] in a smaller, tertiary style. It is announced as a header to
/// screen readers.
///
/// A heading is not interactive unless given an [onTap], as the heading of a
/// section that collapses is. A tappable heading is also announced as a
/// button, and reports whether its section is [expanded] when that is given.
///
/// A tappable heading draws its highlight on the nearest [Material] ancestor,
/// which a [StreamContextMenu] provides.
///
/// {@tool snippet}
///
/// Label a section of a menu:
///
/// ```dart
/// StreamContextMenu(
///   children: [
///     StreamContextMenuHeading(label: Text('Microphone')),
///     StreamContextMenuAction(label: Text('Built-in microphone')),
///     StreamContextMenuAction(label: Text('External microphone')),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Fold a section away behind its heading:
///
/// ```dart
/// StreamContextMenuHeading(
///   label: Text('Advanced'),
///   trailing: Icon(collapsed ? icons.chevronDown : icons.chevronUp),
///   expanded: !collapsed,
///   onTap: () => setState(() => collapsed = !collapsed),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenu], which contains these headings.
///  * [StreamContextMenuAction], the rows a heading labels.
///  * [StreamContextMenuHeadingTheme], for customizing heading appearance.
class StreamContextMenuHeading extends StatelessWidget {
  /// Creates a context menu heading.
  StreamContextMenuHeading({
    super.key,
    required Widget label,
    Widget? trailing,
    VoidCallback? onTap,
    bool? expanded,
  }) : props = .new(
         label: label,
         trailing: trailing,
         onTap: onTap,
         expanded: expanded,
       );

  /// The props controlling the appearance and behavior of this heading.
  final StreamContextMenuHeadingProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).contextMenuHeading;
    if (builder != null) return builder(context, props);
    return DefaultStreamContextMenuHeading(props: props);
  }
}

/// Properties for configuring a [StreamContextMenuHeading].
///
/// This class holds all the configuration options for a context menu heading,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// A custom implementation should keep announcing the heading as a header,
/// and a tappable one as a button carrying [expanded].
///
/// See also:
///
///  * [StreamContextMenuHeading], which uses these properties.
///  * [DefaultStreamContextMenuHeading], the default implementation.
@immutable
class StreamContextMenuHeadingProps {
  /// Creates properties for a context menu heading.
  const StreamContextMenuHeadingProps({
    required this.label,
    this.trailing,
    this.onTap,
    this.expanded,
  });

  /// The heading widget, typically a [Text].
  ///
  /// Its text style and color come from [StreamContextMenuHeadingThemeData].
  final Widget label;

  /// An optional widget drawn at the far end of the heading, typically the
  /// chevron of a section that collapses.
  ///
  /// An [Icon] here takes its color and size from
  /// [StreamContextMenuHeadingThemeData.foregroundColor] and
  /// [StreamContextMenuHeadingThemeData.iconSize].
  final Widget? trailing;

  /// Called when the heading is tapped.
  ///
  /// If null, the heading is inert, which is what an ordinary heading wants.
  final VoidCallback? onTap;

  /// Whether the section this heading folds is expanded.
  ///
  /// Reported to screen readers as the expanded or collapsed state of a
  /// tappable heading. Leave it null for a heading that does not fold a
  /// section.
  final bool? expanded;
}

/// The default implementation of [StreamContextMenuHeading].
///
/// Lays out the [StreamContextMenuHeadingProps.label] and the optional
/// [StreamContextMenuHeadingProps.trailing] in a row, styled from
/// [StreamContextMenuHeadingTheme] with fallback to defaults that match a
/// [StreamContextMenuAction].
///
/// See also:
///
///  * [StreamContextMenuHeading], the public API widget.
///  * [StreamContextMenuHeadingProps], which configures this widget.
class DefaultStreamContextMenuHeading extends StatelessWidget {
  /// Creates a default context menu heading with the given [props].
  const DefaultStreamContextMenuHeading({super.key, required this.props});

  /// The props controlling the appearance and behavior of this heading.
  final StreamContextMenuHeadingProps props;

  @override
  Widget build(BuildContext context) {
    final theme = context.streamContextMenuHeadingTheme;
    final defaults = _StreamContextMenuHeadingThemeDefaults(context);

    final effectiveTextStyle = theme.textStyle ?? defaults.textStyle;
    final effectiveForegroundColor = theme.foregroundColor ?? defaults.foregroundColor;
    final effectiveIconSize = theme.iconSize ?? defaults.iconSize;
    final effectiveOverlayColor = theme.overlayColor ?? defaults.overlayColor;
    final effectiveMinimumSize = theme.minimumSize ?? defaults.minimumSize;
    final effectivePadding = theme.padding ?? defaults.padding;
    final effectiveSpacing = theme.spacing ?? defaults.spacing;
    final effectiveShape = theme.shape ?? defaults.shape;

    Widget heading = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: effectiveMinimumSize.width,
        minHeight: effectiveMinimumSize.height,
      ),
      child: Padding(
        padding: effectivePadding,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: 1,
          heightFactor: 1,
          child: IconTheme.merge(
            data: IconThemeData(color: effectiveForegroundColor, size: effectiveIconSize),
            child: DefaultTextStyle.merge(
              style: effectiveTextStyle.copyWith(color: effectiveForegroundColor),
              child: switch (props.trailing) {
                final trailing? => Row(
                  spacing: effectiveSpacing,
                  children: [
                    Expanded(child: props.label),
                    trailing,
                  ],
                ),
                null => props.label,
              },
            ),
          ),
        ),
      ),
    );

    if (props.onTap case final onTap?) {
      heading = InkWell(
        onTap: onTap,
        overlayColor: effectiveOverlayColor,
        customBorder: effectiveShape,
        child: heading,
      );
    }

    final isTappable = props.onTap != null;
    return Semantics(
      container: true,
      header: true,
      button: isTappable,
      expanded: isTappable ? props.expanded : null,
      child: heading,
    );
  }
}

// Provides default values for [StreamContextMenuHeadingThemeData] that line a
// heading up with the defaults of a [StreamContextMenuAction].
class _StreamContextMenuHeadingThemeDefaults extends StreamContextMenuHeadingThemeData {
  _StreamContextMenuHeadingThemeDefaults(this.context);

  final BuildContext context;

  late final StreamColorScheme _colorScheme = context.streamColorScheme;
  late final StreamTextTheme _textTheme = context.streamTextTheme;
  late final StreamSpacing _spacing = context.streamSpacing;
  late final StreamRadius _radius = context.streamRadius;

  @override
  TextStyle get textStyle => _textTheme.captionEmphasis;

  @override
  Color get foregroundColor => _colorScheme.textTertiary;

  @override
  double get iconSize => 16;

  @override
  WidgetStateProperty<Color> get overlayColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return _colorScheme.backgroundPressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.backgroundHover;
    if (states.contains(WidgetState.focused)) return _colorScheme.backgroundHover;
    return StreamColors.transparent;
  });

  @override
  Size get minimumSize => const Size(242, 40);

  @override
  EdgeInsetsGeometry get padding => .symmetric(horizontal: _spacing.sm, vertical: _spacing.xs + _spacing.xxxs);

  @override
  double get spacing => _spacing.xs;

  @override
  OutlinedBorder get shape => RoundedRectangleBorder(borderRadius: .all(_radius.md));
}
