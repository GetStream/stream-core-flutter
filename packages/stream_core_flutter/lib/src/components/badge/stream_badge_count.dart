import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_badge_count_theme.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A badge component for displaying counts or labels.
///
/// [StreamBadgeCount] displays a text label in a pill-shaped badge.
/// It's typically positioned on avatars, icons, or list items to indicate
/// new messages, notifications, overflow counts, or other information.
///
/// When [child] is provided, the badge is automatically positioned relative
/// to the child using a [Stack], similar to Flutter's [Badge] widget.
///
/// The badge automatically handles:
/// - Adapting width based on the label length
/// - Consistent styling across size variants
/// - Proper text theming from [StreamBadgeCountThemeData]
///
/// {@tool snippet}
///
/// Basic usage (standalone badge):
///
/// ```dart
/// StreamBadgeCount(label: '5')
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With a child widget (automatically positioned):
///
/// ```dart
/// StreamBadgeCount(
///   label: '3',
///   child: StreamAvatar(placeholder: (context) => Text('AB')),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Custom positioning:
///
/// ```dart
/// StreamBadgeCount(
///   label: '3',
///   alignment: Alignment.topRight,
///   offset: Offset(2, -2),
///   child: StreamAvatar(placeholder: (context) => Text('AB')),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Overflow indicator:
///
/// ```dart
/// StreamBadgeCount(
///   label: '+5',
///   size: StreamBadgeCountSize.sm,
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamBadgeCount] uses [StreamBadgeCountThemeData] for default styling.
/// Colors are determined by the current [StreamColorScheme].
///
/// See also:
///
///  * [StreamBadgeCountSize], which defines the available size variants.
///  * [StreamBadgeCountThemeData], for customizing badge appearance.
///  * [StreamBadgeCountTheme], for overriding theme in a widget subtree.
///  * [StreamAvatar], which often displays this badge.
class StreamBadgeCount extends StatelessWidget {
  /// Creates a badge count indicator.
  ///
  /// If [child] is provided, the badge is automatically positioned relative
  /// to the child using a [Stack], similar to Flutter's [Badge] widget.
  /// Use [alignment] and [offset] to fine-tune placement.
  StreamBadgeCount({
    super.key,
    StreamBadgeCountSize? size,
    required String label,
    Widget? child,
    AlignmentGeometry? alignment,
    Offset? offset,
  }) : props = .new(
         size: size,
         label: label,
         child: child,
         alignment: alignment,
         offset: offset,
       );

  /// The properties that configure this badge count.
  final StreamBadgeCountProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).badgeCount;
    if (builder != null) return builder(context, props);
    return DefaultStreamBadgeCount(props: props);
  }
}

/// Properties for configuring a [StreamBadgeCount].
///
/// This class holds all the configuration options for a badge count,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamBadgeCount], which uses these properties.
///  * [DefaultStreamBadgeCount], the default implementation.
class StreamBadgeCountProps {
  /// Creates properties for a badge count.
  const StreamBadgeCountProps({
    this.size,
    required this.label,
    this.child,
    this.alignment,
    this.offset,
  });

  /// The text label to display in the badge.
  ///
  /// Typically a numeric count (e.g., "5") or an overflow indicator
  /// (e.g., "+3", "99+").
  final String label;

  /// The size of the badge.
  ///
  /// If null, uses [StreamBadgeCountThemeData.size], or falls back to
  /// [StreamBadgeCountSize.xs].
  final StreamBadgeCountSize? size;

  /// The widget below this widget in the tree.
  ///
  /// When provided, the badge is positioned relative to this child
  /// using a [Stack]. When null, only the badge is displayed.
  final Widget? child;

  /// The alignment of the badge relative to [child].
  ///
  /// Only used when [child] is provided.
  /// Defaults to [AlignmentDirectional.topEnd].
  final AlignmentGeometry? alignment;

  /// The offset for fine-tuning badge position.
  ///
  /// Applied after [alignment] to adjust the badge's final position.
  /// Defaults to [Offset.zero].
  final Offset? offset;
}

/// The default implementation of [StreamBadgeCount].
///
/// This widget renders the badge count with theming support.
/// It's used as the default factory implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamBadgeCount], the public API widget.
///  * [StreamBadgeCountProps], which configures this widget.
class DefaultStreamBadgeCount extends StatelessWidget {
  /// Creates a default badge count with the given [props].
  const DefaultStreamBadgeCount({super.key, required this.props});

  /// The properties that configure this badge count.
  final StreamBadgeCountProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final boxShadow = context.streamBoxShadow;
    final textTheme = context.streamTextTheme;

    final badgeCountTheme = context.streamBadgeCountTheme;
    final defaults = _StreamBadgeCountThemeDefaults(context);

    final effectiveSize = props.size ?? badgeCountTheme.size ?? defaults.size;
    final effectiveBackgroundColor = badgeCountTheme.backgroundColor ?? defaults.backgroundColor;
    final effectiveBorderColor = badgeCountTheme.borderColor ?? defaults.borderColor;
    final effectiveTextColor = badgeCountTheme.textColor ?? defaults.textColor;

    final padding = _paddingForSize(effectiveSize, spacing);
    final textStyle = _textStyleForSize(effectiveSize, textTheme).copyWith(color: effectiveTextColor);

    final badge = IntrinsicWidth(
      child: AnimatedContainer(
        height: effectiveSize.value,
        constraints: BoxConstraints(minWidth: effectiveSize.value),
        padding: padding,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        duration: kThemeChangeDuration,
        decoration: ShapeDecoration(
          color: effectiveBackgroundColor,
          shape: const StadiumBorder(),
          shadows: boxShadow.elevation2,
        ),
        foregroundDecoration: ShapeDecoration(
          shape: StadiumBorder(
            side: effectiveBorderColor != null ? .new(color: effectiveBorderColor) : .none,
          ),
        ),
        child: DefaultTextStyle(
          style: textStyle,
          child: Text(props.label),
        ),
      ),
    );

    // If no child, just return the badge.
    if (props.child == null) return badge;

    // Otherwise, wrap in Stack like Badge.
    final effectiveAlignment = props.alignment ?? AlignmentDirectional.topEnd;
    final effectiveOffset = props.offset ?? Offset.zero;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        props.child!,
        Positioned.fill(
          child: Align(
            alignment: effectiveAlignment,
            child: Transform.translate(
              offset: effectiveOffset,
              child: badge,
            ),
          ),
        ),
      ],
    );
  }

  // Returns the appropriate text style for the given badge size.
  TextStyle _textStyleForSize(
    StreamBadgeCountSize size,
    StreamTextTheme textTheme,
  ) => switch (size) {
    .xs => textTheme.numericMd,
    .sm || .md || .lg => textTheme.numericXl,
  };

  // Returns the appropriate padding for the given badge size.
  EdgeInsetsGeometry _paddingForSize(
    StreamBadgeCountSize size,
    StreamSpacing spacing,
  ) => switch (size) {
    .xs => .symmetric(horizontal: spacing.xxs),
    .sm || .md => .symmetric(horizontal: spacing.xs),
    .lg => .symmetric(horizontal: spacing.sm),
  };
}

// Default theme values for [StreamBadgeCount].
//
// These defaults are used when no explicit value is provided via
// constructor parameters or [StreamBadgeCountThemeData].
//
// The defaults are context-aware and use colors from the current
// [StreamColorScheme].
class _StreamBadgeCountThemeDefaults extends StreamBadgeCountThemeData {
  _StreamBadgeCountThemeDefaults(this._context);

  final BuildContext _context;

  late final _colorScheme = _context.streamColorScheme;

  @override
  StreamBadgeCountSize get size => .xs;

  @override
  Color get backgroundColor => _colorScheme.backgroundElevation3;

  @override
  Color? get borderColor => null;

  @override
  Color get textColor => _colorScheme.textPrimary;
}
