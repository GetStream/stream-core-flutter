import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_context_menu_action_theme.dart';
import '../../theme/components/stream_context_menu_heading_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import 'stream_context_menu.dart';
import 'stream_context_menu_action.dart';

/// The heading of a section in a [StreamContextMenu].
///
/// A heading names the actions that follow it, such as "Microphone" above a
/// list of microphones. It shares the row size and padding of a
/// [StreamContextMenuAction] but draws its [label] in a tertiary style, and it
/// is announced as a header to screen readers.
///
/// A [leading] widget, such as a back chevron, turns the heading into the
/// "‹ Parent" row of a submenu.
///
/// A heading is not interactive unless given an [onTap], typically to collapse
/// its section. A tappable heading is also announced as a button, and reports
/// whether its section is expanded when [isExpanded] is given. Set [enabled] to
/// false to draw the heading disabled and ignore taps.
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
/// final icons = context.streamIcons;
///
/// StreamContextMenuHeading(
///   label: Text('Advanced'),
///   trailing: AnimatedRotation(
///     turns: collapsed ? 0.5 : 0,
///     duration: const Duration(milliseconds: 200),
///     child: Icon(icons.chevronUp),
///   ),
///   isExpanded: !collapsed,
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
@experimental
class StreamContextMenuHeading extends StatelessWidget {
  /// Creates a context menu heading.
  StreamContextMenuHeading({
    super.key,
    required Widget label,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    bool enabled = true,
    bool? isExpanded,
  }) : props = .new(
         label: label,
         leading: leading,
         trailing: trailing,
         onTap: onTap,
         enabled: enabled,
         isExpanded: isExpanded,
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
/// Consider keeping a custom implementation announced as a header, and a
/// tappable one as a button carrying [isExpanded].
///
/// See also:
///
///  * [StreamContextMenuHeading], which uses these properties.
///  * [DefaultStreamContextMenuHeading], the default implementation.
@immutable
@experimental
final class StreamContextMenuHeadingProps {
  /// Creates properties for a context menu heading.
  const StreamContextMenuHeadingProps({
    required this.label,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.isExpanded,
  });

  /// The heading widget, typically a [Text].
  ///
  /// The label fills the available horizontal space, so text wrapping and
  /// overflow behavior are controlled by the consumer. If the text may be long,
  /// use [TextOverflow.ellipsis] on the [Text.overflow] property to truncate
  /// rather than wrap:
  ///
  /// ```dart
  /// StreamContextMenuHeading(
  ///   label: Text('Very long heading text', overflow: TextOverflow.ellipsis),
  /// )
  /// ```
  ///
  /// Its text style and color come from [StreamContextMenuHeadingStyle].
  final Widget label;

  /// An optional widget drawn before the [label], typically the back chevron
  /// of a submenu.
  ///
  /// An [Icon] here takes its color and size from
  /// [StreamContextMenuHeadingStyle.foregroundColor] and
  /// [StreamContextMenuHeadingStyle.iconSize].
  final Widget? leading;

  /// An optional widget drawn at the far end of the heading, typically the
  /// chevron of a section that collapses.
  ///
  /// An [Icon] here takes its color and size from
  /// [StreamContextMenuHeadingStyle.foregroundColor] and
  /// [StreamContextMenuHeadingStyle.iconSize].
  final Widget? trailing;

  /// Called when the heading is tapped.
  ///
  /// If null, the heading is not interactive.
  final VoidCallback? onTap;

  /// Whether this heading is enabled.
  ///
  /// When false, the heading is drawn in the disabled style and [onTap] is
  /// not called. A tappable heading is then announced as a disabled button.
  ///
  /// Defaults to true.
  final bool enabled;

  /// Whether the section this heading folds is expanded.
  ///
  /// Reported to screen readers as the expanded or collapsed state of the
  /// heading. Leave it null for a heading that does not fold a section.
  final bool? isExpanded;
}

/// The default implementation of [StreamContextMenuHeading].
///
/// Lays out the optional [StreamContextMenuHeadingProps.leading], the
/// [StreamContextMenuHeadingProps.label] and the optional
/// [StreamContextMenuHeadingProps.trailing] in a row, styled from
/// [StreamContextMenuHeadingTheme]. The row size and padding fall back to
/// [StreamContextMenuActionTheme], so a heading lines up with the actions of
/// its menu.
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
    final style = context.streamContextMenuHeadingTheme.style;
    final actionStyle = context.streamContextMenuActionTheme.style;
    final defaults = _ContextMenuHeadingThemeDefaults(context);

    final effectiveForegroundColor = style?.foregroundColor ?? defaults.foregroundColor;
    final effectiveOverlayColor = style?.overlayColor ?? defaults.overlayColor;
    final effectiveSide = style?.side ?? defaults.side;
    final effectiveTextStyle = style?.textStyle ?? defaults.textStyle;
    final effectiveIconSize = style?.iconSize ?? defaults.iconSize;
    final effectiveMinimumSize = style?.minimumSize ?? actionStyle?.minimumSize ?? defaults.minimumSize;
    final effectiveMaximumSize = style?.maximumSize ?? actionStyle?.maximumSize ?? defaults.maximumSize;
    final effectivePadding = style?.padding ?? actionStyle?.padding ?? defaults.padding;
    final effectiveShape = style?.shape ?? defaults.shape;

    final content = Row(
      spacing: context.streamSpacing.xs,
      mainAxisSize: MainAxisSize.min,
      children: [
        ?props.leading,
        Expanded(child: props.label),
        ?props.trailing,
      ],
    );

    final Widget heading;
    if (props.onTap case final onTap?) {
      heading = TextButton(
        onPressed: props.enabled ? onTap : null,
        style: ButtonStyle(
          tapTargetSize: .shrinkWrap,
          visualDensity: .standard,
          alignment: AlignmentDirectional.centerStart,
          foregroundColor: effectiveForegroundColor,
          iconColor: effectiveForegroundColor,
          overlayColor: effectiveOverlayColor,
          side: effectiveSide,
          textStyle: effectiveTextStyle,
          iconSize: effectiveIconSize,
          minimumSize: effectiveMinimumSize,
          maximumSize: effectiveMaximumSize,
          padding: effectivePadding,
          shape: effectiveShape,
        ),
        child: content,
      );
    } else {
      final states = {if (!props.enabled) WidgetState.disabled};
      final foregroundColor = effectiveForegroundColor.resolve(states);
      final minimumSize = effectiveMinimumSize.resolve(states) ?? Size.zero;
      final maximumSize = effectiveMaximumSize.resolve(states) ?? Size.infinite;
      final padding = effectivePadding.resolve(states) ?? EdgeInsets.zero;
      final iconSize = effectiveIconSize.resolve(states);
      final textStyle = effectiveTextStyle.resolve(states) ?? const TextStyle();

      heading = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minimumSize.width,
          minHeight: minimumSize.height,
          maxWidth: maximumSize.width,
          maxHeight: maximumSize.height,
        ),
        child: Padding(
          padding: padding,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            heightFactor: 1,
            child: IconTheme.merge(
              data: IconThemeData(color: foregroundColor, size: iconSize),
              child: DefaultTextStyle(
                style: textStyle.copyWith(color: foregroundColor),
                child: content,
              ),
            ),
          ),
        ),
      );
    }

    return MergeSemantics(
      child: Semantics(
        header: true,
        expanded: props.isExpanded,
        child: heading,
      ),
    );
  }
}

// Provides default values for [StreamContextMenuHeadingStyle], following the
// mobile menu heading of the design system.
class _ContextMenuHeadingThemeDefaults extends StreamContextMenuHeadingStyle {
  _ContextMenuHeadingThemeDefaults(this.context);

  final BuildContext context;

  late final StreamColorScheme _colorScheme = context.streamColorScheme;
  late final StreamTextTheme _textTheme = context.streamTextTheme;
  late final StreamSpacing _spacing = context.streamSpacing;
  late final StreamRadius _radius = context.streamRadius;

  @override
  WidgetStateProperty<Color> get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    return _colorScheme.textTertiary;
  });

  @override
  WidgetStateProperty<Color> get overlayColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return _colorScheme.backgroundPressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.backgroundHover;
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<BorderSide> get side => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.focused)) return BorderSide(color: _colorScheme.borderFocus, width: 2);
    return BorderSide.none;
  });

  @override
  WidgetStateProperty<TextStyle> get textStyle => WidgetStatePropertyAll(_textTheme.bodyEmphasis);

  @override
  WidgetStateProperty<double> get iconSize => const WidgetStatePropertyAll(20);

  @override
  WidgetStateProperty<Size> get minimumSize => const WidgetStatePropertyAll(Size(242, 40));

  @override
  WidgetStateProperty<Size> get maximumSize => const WidgetStatePropertyAll(Size.infinite);

  @override
  WidgetStateProperty<EdgeInsetsGeometry> get padding => WidgetStatePropertyAll(
    .symmetric(horizontal: _spacing.sm, vertical: _spacing.xs + _spacing.xxxs),
  );

  @override
  WidgetStateProperty<OutlinedBorder> get shape => WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: .all(_radius.lg)),
  );
}
