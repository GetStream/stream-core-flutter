import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_list_tile_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A single fixed-height row inspired by Flutter's [ListTile], adapted for the
/// Stream design system.
///
/// [StreamListTile] displays an optional [leading] widget, a [title], an
/// optional [subtitle] below the title, an optional right-side [description],
/// and an optional [trailing] widget. All slots accept arbitrary widgets —
/// the [leading] is typically a [StreamAvatar] but can be any widget.
///
/// The tile responds to taps and long-presses via [onTap] and [onLongPress],
/// and supports [enabled] and [selected] states.
///
/// ## Theming
///
/// Visual properties are resolved from [StreamListTileTheme], with sensible
/// defaults derived from [StreamColorScheme] and [StreamTextTheme].
///
/// ## Material requirement
///
/// Like Flutter's [ListTile], [StreamListTile] requires a [Material] widget
/// somewhere in its ancestor tree for ink effects to render. A [Scaffold]
/// satisfies this automatically in full-page layouts. When using the tile in
/// isolation (e.g. inside a card or a custom container), wrap it with a
/// [Material]:
///
/// ```dart
/// Material(
///   type: MaterialType.transparency,
///   child: StreamListTile(...),
/// )
/// ```
///
/// {@tool snippet}
///
/// A simple list tile with an avatar and a chevron:
///
/// ```dart
/// StreamListTile(
///   leading: StreamAvatar(name: 'Alice'),
///   title: Text('Alice'),
///   subtitle: Text('Online'),
///   trailing: Icon(Icons.chevron_right),
///   onTap: () => Navigator.push(context, ...),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// A selected tile with a description:
///
/// ```dart
/// StreamListTile(
///   leading: StreamAvatar(name: 'Bob'),
///   title: Text('Bob'),
///   description: Text('2 min ago'),
///   selected: true,
///   onTap: () {},
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamListTileTheme], for customizing tile appearance globally.
///  * [DefaultStreamListTile], the default visual implementation.
class StreamListTile extends StatelessWidget {
  /// Creates a list tile.
  StreamListTile({
    super.key,
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? description,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool enabled = true,
    bool selected = false,
  }) : props = .new(
         leading: leading,
         title: title,
         subtitle: subtitle,
         description: description,
         trailing: trailing,
         onTap: onTap,
         onLongPress: onLongPress,
         enabled: enabled,
         selected: selected,
       );

  /// The props controlling the appearance and behavior of this tile.
  final StreamListTileProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).listTile;
    if (builder != null) return builder(context, props);
    return DefaultStreamListTile(props: props);
  }
}

/// Properties for configuring a [StreamListTile].
///
/// This class holds all the configuration options for a list tile, allowing
/// them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamListTile], which uses these properties.
///  * [DefaultStreamListTile], the default implementation.
class StreamListTileProps {
  /// Creates properties for a list tile.
  const StreamListTileProps({
    this.leading,
    this.title,
    this.subtitle,
    this.description,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
  });

  /// A widget displayed before the title.
  ///
  /// Typically a [StreamAvatar], [CircleAvatar], or [Icon].
  final Widget? leading;

  /// The primary content of the list tile.
  ///
  /// Typically a [Text] widget.
  final Widget? title;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget. Should not wrap — use [Text.maxLines] to
  /// enforce a single line.
  final Widget? subtitle;

  /// A widget displayed on the right side of the tile, between the title
  /// column and [trailing].
  ///
  /// Typically a [Text] widget showing secondary metadata such as a timestamp
  /// or status. Uses [StreamColorScheme.textTertiary] by default.
  final Widget? description;

  /// A widget displayed at the end of the tile.
  ///
  /// Typically an [Icon] (e.g. a chevron) or a control widget.
  final Widget? trailing;

  /// Called when the user taps this tile.
  ///
  /// Inoperative if [enabled] is false.
  final VoidCallback? onTap;

  /// Called when the user long-presses this tile.
  ///
  /// Inoperative if [enabled] is false.
  final VoidCallback? onLongPress;

  /// Whether this tile is interactive.
  ///
  /// When false, the tile is styled with the disabled color and [onTap] /
  /// [onLongPress] are inoperative, mirroring [ListTile.enabled].
  final bool enabled;

  /// Whether this tile is in a selected state.
  ///
  /// When true, the tile applies selected-state styling via
  /// [StreamListTileThemeData] (background color, text colors, and icon
  /// colors). This is independent of tap handling.
  final bool selected;
}

/// The default implementation of [StreamListTile].
///
/// Renders the tile with theming support from [StreamListTileTheme].
/// It is used as the default factory implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamListTile], the public API widget.
///  * [StreamListTileProps], which configures this widget.
class DefaultStreamListTile extends StatelessWidget {
  /// Creates a default list tile.
  const DefaultStreamListTile({super.key, required this.props});

  /// The props controlling the appearance and behavior of this tile.
  final StreamListTileProps props;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));

    final spacing = context.streamSpacing;
    final theme = context.streamListTileTheme;
    final defaults = _StreamListTileThemeDefaults(context);

    // Build the WidgetState set once and share it across all color resolvers.
    final states = <WidgetState>{
      if (!props.enabled) WidgetState.disabled,
      if (props.selected) WidgetState.selected,
    };

    final effectiveTitleColor = (theme.titleColor ?? defaults.titleColor).resolve(states)!;
    final effectiveSubtitleColor = (theme.subtitleColor ?? defaults.subtitleColor).resolve(states)!;
    final effectiveDescriptionColor = (theme.descriptionColor ?? defaults.descriptionColor).resolve(states)!;
    final effectiveIconColor = (theme.iconColor ?? defaults.iconColor).resolve(states)!;

    final effectiveTitleTextStyle = theme.titleTextStyle ?? defaults.titleTextStyle;
    final effectiveSubtitleTextStyle = theme.subtitleTextStyle ?? defaults.subtitleTextStyle;
    final effectiveDescriptionTextStyle = theme.descriptionTextStyle ?? defaults.descriptionTextStyle;
    final effectiveMinTileHeight = theme.minTileHeight ?? defaults.minTileHeight;

    Widget? leadingWidget;
    if (props.leading case final leading?) {
      leadingWidget = AnimatedDefaultTextStyle(
        style: TextStyle(color: effectiveIconColor),
        duration: kThemeChangeDuration,
        child: leading,
      );
    }

    Widget? titleWidget;
    if (props.title case final title?) {
      titleWidget = AnimatedDefaultTextStyle(
        style: effectiveTitleTextStyle.copyWith(color: effectiveTitleColor),
        duration: kThemeChangeDuration,
        child: title,
      );
    }

    Widget? subtitleWidget;
    if (props.subtitle case final subtitle?) {
      subtitleWidget = AnimatedDefaultTextStyle(
        style: effectiveSubtitleTextStyle.copyWith(color: effectiveSubtitleColor),
        duration: kThemeChangeDuration,
        child: subtitle,
      );
    }

    Widget? descriptionWidget;
    if (props.description case final description?) {
      descriptionWidget = AnimatedDefaultTextStyle(
        style: effectiveDescriptionTextStyle.copyWith(color: effectiveDescriptionColor),
        duration: kThemeChangeDuration,
        child: description,
      );
    }

    Widget? trailingWidget;
    if (props.trailing case final trailing?) {
      trailingWidget = AnimatedDefaultTextStyle(
        style: TextStyle(color: effectiveIconColor),
        duration: kThemeChangeDuration,
        child: trailing,
      );
    }

    return StreamListTileContainer(
      enabled: props.enabled,
      selected: props.selected,
      onTap: props.onTap,
      onLongPress: props.onLongPress,
      child: IconTheme.merge(
        data: IconThemeData(color: effectiveIconColor),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: effectiveMinTileHeight),
          child: Row(
            spacing: spacing.xs,
            children: [
              ?leadingWidget,
              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [?titleWidget, ?subtitleWidget],
                ),
              ),
              ?descriptionWidget,
              ?trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}

// Default theme values for [StreamListTile].
//
// These defaults are used when no explicit value is provided via
// [StreamListTileThemeData]. The defaults are context-aware and use values
// from [StreamColorScheme], [StreamTextTheme], [StreamSpacing], and
// [StreamRadius].
class _StreamListTileThemeDefaults extends StreamListTileThemeData {
  _StreamListTileThemeDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;
  late final StreamRadius _radius = _context.streamRadius;

  @override
  double get minTileHeight => 40;

  @override
  TextStyle get titleTextStyle => _textTheme.bodyDefault;

  @override
  TextStyle get subtitleTextStyle => _textTheme.metadataDefault;

  @override
  TextStyle get descriptionTextStyle => _textTheme.bodyDefault;

  @override
  ShapeBorder get shape => RoundedRectangleBorder(borderRadius: .all(_radius.lg));

  @override
  EdgeInsetsGeometry get contentPadding => .symmetric(horizontal: _spacing.sm, vertical: _spacing.xs);

  @override
  WidgetStateProperty<Color> get titleColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    return _colorScheme.textPrimary;
  });

  @override
  WidgetStateProperty<Color> get subtitleColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    return _colorScheme.textTertiary;
  });

  @override
  WidgetStateProperty<Color> get descriptionColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    return _colorScheme.textTertiary;
  });

  @override
  WidgetStateProperty<Color> get iconColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    return _colorScheme.textSecondary;
  });

  @override
  WidgetStateProperty<Color> get backgroundColor => .resolveWith((states) {
    const base = StreamColors.transparent;
    if (states.contains(WidgetState.selected)) return .alphaBlend(_colorScheme.stateSelected, base);
    return base;
  });

  @override
  WidgetStateProperty<Color> get overlayColor => .resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return _colorScheme.statePressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.stateHover;
    return StreamColors.transparent;
  });
}

class StreamListTileContainer extends StatelessWidget {
  const StreamListTileContainer({
    super.key,
    required this.child,
    required this.enabled,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final Widget child;

  final bool enabled;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.streamListTileTheme;
    final defaults = _StreamListTileThemeDefaults(context);

    // Build the WidgetState set once and share it across all color resolvers.
    final states = <WidgetState>{
      if (!enabled) WidgetState.disabled,
      if (selected) WidgetState.selected,
    };

    final textDirection = Directionality.of(context);

    final effectiveBackgroundColor = (theme.backgroundColor ?? defaults.backgroundColor).resolve(states);
    final effectiveShape = theme.shape ?? defaults.shape;
    final effectiveContentPadding = (theme.contentPadding ?? defaults.contentPadding).resolve(textDirection);
    final effectiveOverlayColor = theme.overlayColor ?? defaults.overlayColor;

    // Mouse cursor: show a non-interactive cursor when the tile is disabled
    // OR when no gesture callbacks are wired.
    final mouseStates = <WidgetState>{
      if (!enabled || (onTap == null && onLongPress == null)) WidgetState.disabled,
    };

    final effectiveMouseCursor = WidgetStateMouseCursor.clickable.resolve(mouseStates);

    return InkWell(
      customBorder: effectiveShape,
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      canRequestFocus: enabled,
      mouseCursor: effectiveMouseCursor,
      overlayColor: effectiveOverlayColor,
      child: Semantics(
        button: onTap != null || onLongPress != null,
        selected: selected,
        enabled: enabled,
        child: Ink(
          decoration: ShapeDecoration(
            shape: effectiveShape,
            color: effectiveBackgroundColor,
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            minimum: effectiveContentPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}
