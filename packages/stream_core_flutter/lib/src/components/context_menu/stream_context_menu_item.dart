import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_context_menu_item_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A single item row in a [StreamContextMenu].
///
/// [StreamContextMenuItem] displays a tappable row with an optional [leading]
/// widget, a [label] widget, and an optional [trailing] widget. It supports
/// both normal and destructive styles.
///
/// The visual appearance adapts to interaction states (hover, pressed,
/// disabled) and can be fully customized via [StreamContextMenuItemTheme].
///
/// A typical use case is to pass a [Text] as the [label]. If the text may be
/// long, set [Text.overflow] to [TextOverflow.ellipsis] and [Text.maxLines]
/// to 1, as without it the text will wrap to the next line.
///
/// {@tool snippet}
///
/// Display a normal context menu item:
///
/// ```dart
/// StreamContextMenuItem(
///   label: Text('Reply'),
///   leading: Icon(Icons.reply),
///   onPressed: () => handleReply(),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Display a destructive context menu item:
///
/// ```dart
/// StreamContextMenuItem.destructive(
///   label: Text('Block User'),
///   leading: Icon(Icons.block),
///   onPressed: () => handleBlock(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenu], which contains these items.
///  * [StreamContextMenuSeparator], for visual dividers between items.
///  * [StreamContextMenuItemTheme], for customizing item appearance.
class StreamContextMenuItem extends StatelessWidget {
  /// Creates a context menu item.
  StreamContextMenuItem({
    super.key,
    required Widget label,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
  }) : props = .new(
         label: label,
         onPressed: onPressed,
         leading: leading,
         trailing: trailing,
       );

  /// Creates a destructive context menu item.
  ///
  /// Uses error/danger colors for text and icons, typically for
  /// actions like "Delete", "Block", or "Remove".
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// StreamContextMenuItem.destructive(
  ///   label: Text('Block User'),
  ///   leading: Icon(Icons.block),
  ///   onPressed: () => handleBlock(),
  /// )
  /// ```
  /// {@end-tool}
  StreamContextMenuItem.destructive({
    super.key,
    required Widget label,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
  }) : props = .new(
         label: label,
         onPressed: onPressed,
         leading: leading,
         trailing: trailing,
         isDestructive: true,
       );

  /// The props controlling the appearance and behavior of this item.
  final StreamContextMenuItemProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.maybeOf(context)?.contextMenuItem;
    if (builder != null) return builder(context, props);
    return DefaultStreamContextMenuItem(props: props);
  }
}

/// Properties for configuring a [StreamContextMenuItem].
///
/// This class holds all the configuration options for a context menu item,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamContextMenuItem], which uses these properties.
///  * [DefaultStreamContextMenuItem], the default implementation.
class StreamContextMenuItemProps {
  /// Creates properties for a context menu item.
  const StreamContextMenuItemProps({
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.isDestructive = false,
  });

  /// The label widget displayed on the item.
  ///
  /// Typically a [Text] widget. The label fills the available horizontal
  /// space, so text wrapping and overflow behavior are controlled by the
  /// consumer. If the text may be long, use [TextOverflow.ellipsis] on the
  /// [Text.overflow] property to truncate rather than wrap:
  ///
  /// ```dart
  /// StreamContextMenuItem(
  ///   label: Text('Very long label text', overflow: TextOverflow.ellipsis),
  ///   onPressed: () {},
  /// )
  /// ```
  final Widget label;

  /// Called when the item is activated.
  ///
  /// If null, the item is visually styled as disabled and is non-interactive.
  final VoidCallback? onPressed;

  /// An optional widget displayed before the label.
  ///
  /// Typically an [Icon] widget. The icon color and size are controlled by
  /// [StreamContextMenuItemStyle.foregroundColor] and
  /// [StreamContextMenuItemStyle.iconSize].
  final Widget? leading;

  /// An optional widget displayed after the label.
  ///
  /// Typically a chevron icon for sub-menu navigation, or a keyboard shortcut
  /// indicator.
  final Widget? trailing;

  /// Whether this item uses destructive (error/danger) styling.
  ///
  /// When true, the item uses [StreamColorScheme.accentError] for text and
  /// icon colors. Use [StreamContextMenuItem.destructive] for convenience.
  final bool isDestructive;
}

/// Default implementation of [StreamContextMenuItem].
///
/// Lays out the optional [StreamContextMenuItemProps.leading], the
/// [StreamContextMenuItemProps.label], and optional
/// [StreamContextMenuItemProps.trailing] in a horizontal row.
///
/// All visual properties are resolved from [StreamContextMenuItemTheme] with
/// fallback to sensible defaults, providing automatic state-based feedback
/// (hover, pressed, disabled).
class DefaultStreamContextMenuItem extends StatelessWidget {
  /// Creates a default context menu item.
  const DefaultStreamContextMenuItem({super.key, required this.props});

  /// The props controlling the appearance and behavior of this item.
  final StreamContextMenuItemProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final themeStyle = context.streamContextMenuItemTheme.style;
    final defaults = _ContextMenuItemThemeDefaults(context, isDestructive: props.isDestructive);

    final effectiveBackgroundColor = themeStyle?.backgroundColor ?? defaults.backgroundColor;
    final effectiveForegroundColor = themeStyle?.foregroundColor ?? defaults.foregroundColor;
    final effectiveOverlayColor = themeStyle?.overlayColor ?? defaults.overlayColor;
    final effectiveIconColor = themeStyle?.iconColor ?? defaults.iconColor;
    final effectiveTextStyle = themeStyle?.textStyle ?? defaults.textStyle;
    final effectiveIconSize = themeStyle?.iconSize ?? defaults.iconSize;
    final effectiveMinimumSize = themeStyle?.minimumSize ?? defaults.minimumSize;
    final effectiveMaximumSize = themeStyle?.maximumSize ?? defaults.maximumSize;
    final effectivePadding = themeStyle?.padding ?? defaults.padding;
    final effectiveShape = themeStyle?.shape ?? defaults.shape;

    return TextButton(
      onPressed: props.onPressed,
      style: ButtonStyle(
        tapTargetSize: .shrinkWrap,
        visualDensity: .standard,
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveForegroundColor,
        overlayColor: effectiveOverlayColor,
        iconColor: effectiveIconColor,
        iconSize: effectiveIconSize,
        textStyle: effectiveTextStyle,
        minimumSize: effectiveMinimumSize,
        maximumSize: effectiveMaximumSize,
        padding: effectivePadding,
        shape: effectiveShape,
      ),
      child: Row(
        spacing: spacing.xs,
        mainAxisSize: MainAxisSize.min,
        children: [
          ?props.leading,
          Expanded(child: props.label),
          ?props.trailing,
        ],
      ),
    );
  }
}

// Provides default values for [StreamContextMenuItemStyle] based on
// the current [StreamColorScheme].
class _ContextMenuItemThemeDefaults extends StreamContextMenuItemStyle {
  _ContextMenuItemThemeDefaults(this.context, {required this.isDestructive});

  final BuildContext context;
  final bool isDestructive;

  late final StreamColorScheme _colorScheme = context.streamColorScheme;
  late final StreamTextTheme _textTheme = context.streamTextTheme;
  late final StreamSpacing _spacing = context.streamSpacing;
  late final StreamRadius _radius = context.streamRadius;

  @override
  WidgetStateProperty<Color> get backgroundColor => const WidgetStatePropertyAll(StreamColors.transparent);

  @override
  WidgetStateProperty<Color> get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    return isDestructive ? _colorScheme.accentError : _colorScheme.textPrimary;
  });

  @override
  WidgetStateProperty<Color> get overlayColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return _colorScheme.statePressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.stateHover;
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<TextStyle> get textStyle => WidgetStatePropertyAll(_textTheme.bodyEmphasis);

  @override
  WidgetStateProperty<Color> get iconColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    return isDestructive ? _colorScheme.accentError : _colorScheme.textSecondary;
  });

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
    RoundedRectangleBorder(borderRadius: .all(_radius.md)),
  );
}
