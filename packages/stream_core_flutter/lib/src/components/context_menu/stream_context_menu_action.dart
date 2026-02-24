import 'package:flutter/material.dart';
import 'package:stream_core/stream_core.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_context_menu_action_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import 'stream_context_menu.dart';

/// A single action row in a [StreamContextMenu].
///
/// [StreamContextMenuAction] displays a tappable row with an optional [leading]
/// widget, a [label] widget, and an optional [trailing] widget. It supports
/// both normal and destructive styles.
///
/// The visual appearance adapts to interaction states (hover, pressed,
/// disabled) and can be fully customized via [StreamContextMenuActionTheme].
///
/// Each action carries a [value], and when tapped the default implementation
/// calls [Navigator.pop] with that value so the dialog caller can handle it.
/// Use [enabled] to control whether the action is interactive (disabled actions
/// remain visible but are not tappable).
///
/// The type parameter [T] represents the type of [value] that will be returned
/// when the action is selected.
///
/// A typical use case is to pass a [Text] as the [label]. If the text may be
/// long, set [Text.overflow] to [TextOverflow.ellipsis] and [Text.maxLines]
/// to 1, as without it the text will wrap to the next line.
///
/// {@tool snippet}
///
/// Display a normal context menu action:
///
/// ```dart
/// StreamContextMenuAction(
///   value: 'reply',
///   label: Text('Reply'),
///   leading: Icon(Icons.reply),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Display a destructive context menu action:
///
/// ```dart
/// StreamContextMenuAction.destructive(
///   value: 'block',
///   label: Text('Block User'),
///   leading: Icon(Icons.block),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenu], which contains these actions.
///  * [StreamContextMenuSeparator], for visual dividers between actions.
///  * [StreamContextMenuActionTheme], for customizing action appearance.
class StreamContextMenuAction<T> extends StatelessWidget {
  /// Creates a context menu action.
  StreamContextMenuAction({
    super.key,
    T? value,
    required Widget label,
    VoidCallback? onTap,
    bool enabled = true,
    Widget? leading,
    Widget? trailing,
    bool isDestructive = false,
  }) : props = .new(
         value: value,
         label: label,
         onTap: onTap,
         enabled: enabled,
         leading: leading,
         trailing: trailing,
         isDestructive: isDestructive,
       );

  /// Creates a destructive context menu action.
  ///
  /// Uses error/danger colors for text and icons, typically for
  /// actions like "Delete", "Block", or "Remove".
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// StreamContextMenuAction.destructive(
  ///   value: 'block',
  ///   label: Text('Block User'),
  ///   leading: Icon(Icons.block),
  /// )
  /// ```
  /// {@end-tool}
  StreamContextMenuAction.destructive({
    super.key,
    T? value,
    required Widget label,
    VoidCallback? onTap,
    bool enabled = true,
    Widget? leading,
    Widget? trailing,
  }) : props = .new(
         value: value,
         label: label,
         onTap: onTap,
         enabled: enabled,
         leading: leading,
         trailing: trailing,
         isDestructive: true,
       );

  /// Add a [StreamContextMenuSeparator] between each action in the given
  /// [items].
  ///
  /// If [items] is empty or contains a single element, no separators are
  /// added. The result can be passed directly to [StreamContextMenu.new]'s
  /// `children` parameter.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// StreamContextMenu(
  ///   children: StreamContextMenuAction.separated(
  ///     items: [
  ///       StreamContextMenuAction(label: Text('Reply')),
  ///       StreamContextMenuAction(label: Text('Copy')),
  ///       StreamContextMenuAction(label: Text('Delete')),
  ///     ],
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [StreamContextMenuSeparator], which you can use to obtain this effect
  ///    manually.
  static List<Widget> separated({
    required List<Widget> items,
  }) {
    return [
      for (final (index, child) in items.indexed) ...[
        if (index > 0) const StreamContextMenuSeparator(),
        child,
      ],
    ];
  }

  /// Flatten [sections] into a single list, inserting a
  /// [StreamContextMenuSeparator] between each non-empty section.
  ///
  /// Each section is an [Iterable] of widgets that belong together as a
  /// logical group. Empty sections are silently ignored so that no stray
  /// separators appear. The result can be passed directly to
  /// [StreamContextMenu.new]'s `children` parameter.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// StreamContextMenu(
  ///   children: StreamContextMenuAction.sectioned(
  ///     sections: [
  ///       [
  ///         StreamContextMenuAction(label: Text('Reply')),
  ///         StreamContextMenuAction(label: Text('Copy')),
  ///       ],
  ///       [
  ///         StreamContextMenuAction.destructive(
  ///           label: Text('Delete'),
  ///         ),
  ///       ],
  ///     ],
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [StreamContextMenuSeparator], which you can use to obtain this effect
  ///    manually.
  ///  * [separated], which inserts a separator between every action instead
  ///    of between groups.
  static List<Widget> sectioned({
    required Iterable<Iterable<Widget>> sections,
  }) {
    final nonEmptySections = sections.where((s) => s.isNotEmpty);
    return [
      for (final (index, section) in nonEmptySections.indexed) ...[
        if (index > 0) const StreamContextMenuSeparator(),
        ...section,
      ],
    ];
  }

  /// Partition [items] into non-destructive and destructive groups, then
  /// insert a [StreamContextMenuSeparator] between the two groups.
  ///
  /// Items whose [StreamContextMenuActionProps.isDestructive] is `false` form
  /// the leading section; destructive items form the trailing section.
  /// Under the hood this calls [sectioned] with the two groups.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// StreamContextMenu(
  ///   children: StreamContextMenuAction.partitioned(
  ///     items: actions,
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [sectioned], which lets you provide arbitrary section groupings.
  static List<Widget> partitioned<T>({
    required List<StreamContextMenuAction<T>> items,
  }) {
    final (normal, destructive) = items.partition((it) => !it.props.isDestructive);
    return sectioned(sections: [normal, destructive]);
  }

  /// The props controlling the appearance and behavior of this action.
  final StreamContextMenuActionProps<T> props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.maybeOf(context)?.contextMenuAction;
    if (builder != null) return builder(context, props);
    return DefaultStreamContextMenuAction(props: props);
  }
}

/// Properties for configuring a [StreamContextMenuAction].
///
/// This class holds all the configuration options for a context menu action,
/// including its visual representation, behavior, and an optional [value]
/// that is returned when the action is selected.
///
/// The type parameter [T] represents the type of [value].
///
/// See also:
///
///  * [StreamContextMenuAction], which uses these properties.
///  * [DefaultStreamContextMenuAction], the default implementation.
@immutable
class StreamContextMenuActionProps<T extends Object?> {
  /// Creates properties for a context menu action.
  const StreamContextMenuActionProps({
    this.value,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.leading,
    this.trailing,
    this.isDestructive = false,
  });

  /// The value returned when this action is selected inside a popup route
  /// (e.g. a dialog or bottom sheet).
  ///
  /// When the action is rendered inline — outside any popup route — the value
  /// is not returned; only [onTap] fires.
  ///
  /// Consumers can also use this to find, remove, reorder, or replace specific
  /// actions when customizing a default list of context menu actions.
  final T? value;

  /// The label widget displayed on the action.
  ///
  /// Typically a [Text] widget. The label fills the available horizontal
  /// space, so text wrapping and overflow behavior are controlled by the
  /// consumer. If the text may be long, use [TextOverflow.ellipsis] on the
  /// [Text.overflow] property to truncate rather than wrap:
  ///
  /// ```dart
  /// StreamContextMenuAction(
  ///   label: Text('Very long label text', overflow: TextOverflow.ellipsis),
  /// )
  /// ```
  final Widget label;

  /// Called when the action is tapped.
  ///
  /// When used inside a popup route, this is called **after** the route is
  /// dismissed with [value]. The dismissal happens first so that [onTap] can
  /// safely push a new route without conflicting with the closing menu.
  ///
  /// When used inline (outside any popup route), this is the only callback
  /// that fires.
  final VoidCallback? onTap;

  /// Whether this action is interactive.
  ///
  /// When `false`, the action is visually styled as disabled and taps are
  /// ignored.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// An optional widget displayed before the label.
  ///
  /// Typically an [Icon] widget. The icon color and size are controlled by
  /// [StreamContextMenuActionStyle.foregroundColor] and
  /// [StreamContextMenuActionStyle.iconSize].
  final Widget? leading;

  /// An optional widget displayed after the label.
  ///
  /// Typically a chevron icon for sub-menu navigation, or a keyboard shortcut
  /// indicator.
  final Widget? trailing;

  /// Whether this action uses destructive (error/danger) styling.
  ///
  /// When true, the action uses [StreamColorScheme.accentError] for text and
  /// icon colors. Use [StreamContextMenuAction.destructive] for convenience.
  final bool isDestructive;
}

/// Default implementation of [StreamContextMenuAction].
///
/// Lays out the optional [StreamContextMenuActionProps.leading], the
/// [StreamContextMenuActionProps.label], and optional
/// [StreamContextMenuActionProps.trailing] in a horizontal row.
///
/// All visual properties are resolved from [StreamContextMenuActionTheme] with
/// fallback to sensible defaults, providing automatic state-based feedback
/// (hover, pressed, disabled).
class DefaultStreamContextMenuAction<T> extends StatelessWidget {
  /// Creates a default context menu action.
  const DefaultStreamContextMenuAction({super.key, required this.props});

  /// The props controlling the appearance and behavior of this action.
  final StreamContextMenuActionProps<T> props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final themeStyle = context.streamContextMenuActionTheme.style;
    final defaults = _ContextMenuActionThemeDefaults(context, isDestructive: props.isDestructive);

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

    void handleTap() {
      // Dismiss the route first so that onTap can safely push a new route
      // without conflicting with the closing menu.
      //
      // The guard ensures we only pop when the action is actually inside a
      // popup route (dialog, bottom sheet, etc.). When rendered inline there
      // is no route to dismiss, so only onTap fires.
      if (ModalRoute.of(context) case PopupRoute()) {
        Navigator.pop<T>(context, props.value);
      }

      props.onTap?.call();
    }

    return TextButton(
      onPressed: props.enabled ? handleTap : null,
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

// Provides default values for [StreamContextMenuActionStyle] based on
// the current [StreamColorScheme].
class _ContextMenuActionThemeDefaults extends StreamContextMenuActionStyle {
  _ContextMenuActionThemeDefaults(this.context, {required this.isDestructive});

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
