import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/components/stream_jump_to_unread_button_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import 'stream_button.dart';

/// A floating pill-shaped button for jumping to unread messages.
///
/// The button has two sections separated by a vertical divider:
/// - A **leading** tap area with an icon and a [label] (a [String]).
/// - A **trailing** icon button (typically for dismiss).
///
/// The leading and trailing sections are built using [StreamButton] and
/// [StreamButton.icon] respectively, inheriting their interaction states
/// (hover, pressed) from the design system.
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamJumpToUnreadButton(
///   label: '3 unread',
///   onJumpPressed: () => scrollToUnread(),
///   onDismissPressed: () => markAsRead(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamJumpToUnreadButtonTheme], for customizing appearance.
///  * [StreamJumpToUnreadButtonProps], for the full set of properties.
class StreamJumpToUnreadButton extends StatelessWidget {
  /// Creates a jump-to-unread button.
  ///
  /// The [label] is the text displayed next to the leading icon.
  /// The [trailingIcon] is typically a dismiss icon (e.g. xmark).
  StreamJumpToUnreadButton({
    super.key,
    required String label,
    VoidCallback? onJumpPressed,
    IconData? leadingIcon,
    IconData? trailingIcon,
    VoidCallback? onDismissPressed,
  }) : props = .new(
         label: label,
         onJumpPressed: onJumpPressed,
         leadingIcon: leadingIcon,
         trailingIcon: trailingIcon,
         onDismissPressed: onDismissPressed,
       );

  /// The properties that configure this button.
  final StreamJumpToUnreadButtonProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).jumpToUnreadButton;
    if (builder != null) return builder(context, props);
    return DefaultStreamJumpToUnreadButton(props: props);
  }
}

/// Properties for configuring a [StreamJumpToUnreadButton].
///
/// This class holds all the configuration options for the button,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamJumpToUnreadButton], which uses these properties.
///  * [DefaultStreamJumpToUnreadButton], the default implementation.
class StreamJumpToUnreadButtonProps {
  /// Creates properties for a jump-to-unread button.
  const StreamJumpToUnreadButtonProps({
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.onJumpPressed,
    this.onDismissPressed,
  });

  /// The text label displayed next to the leading icon.
  ///
  /// Typically an unread count string, e.g. `'3 unread'`.
  final String label;

  /// Called when the leading section (icon + label) is pressed.
  ///
  /// Typically used to scroll to the oldest unread message.
  /// If null, the leading section is non-interactive.
  final VoidCallback? onJumpPressed;

  /// The icon displayed at the start of the leading section.
  ///
  /// Falls back to the theme's `arrowUp` icon.
  final IconData? leadingIcon;

  /// The icon displayed in the trailing section after the separator.
  ///
  /// Falls back to the theme's `xmark` icon.
  final IconData? trailingIcon;

  /// Called when the trailing dismiss section is pressed.
  ///
  /// Typically used to dismiss the unread indicator.
  /// If null, the trailing area is non-interactive.
  final VoidCallback? onDismissPressed;
}

/// Default implementation of [StreamJumpToUnreadButton].
///
/// Renders a floating pill-shaped button using [StreamButton] for the leading
/// section and [StreamButton.icon] for the trailing section. All visual
/// properties are sourced from [StreamJumpToUnreadButtonThemeData]
/// with fallbacks from [_JumpToUnreadButtonThemeDefaults].
///
/// See also:
///
///  * [StreamJumpToUnreadButton], the public API widget.
///  * [StreamJumpToUnreadButtonProps], which configures this widget.
class DefaultStreamJumpToUnreadButton extends StatelessWidget {
  /// Creates the default jump-to-unread button.
  const DefaultStreamJumpToUnreadButton({super.key, required this.props});

  /// The props controlling the appearance and behavior of this button.
  final StreamJumpToUnreadButtonProps props;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    final theme = context.streamJumpToUnreadButtonTheme;
    final defaults = _JumpToUnreadButtonThemeDefaults(context);

    final effectiveSide = theme.side ?? defaults.side;
    final effectiveShape = (theme.shape ?? defaults.shape).copyWith(side: effectiveSide);
    final effectiveElevation = theme.elevation ?? defaults.elevation;
    final effectiveShadowColor = theme.shadowColor ?? defaults.shadowColor;
    final effectivePadding = theme.padding ?? defaults.padding;
    final effectiveBackgroundColor = theme.backgroundColor ?? defaults.backgroundColor;

    final effectiveLeadingIcon = props.leadingIcon ?? icons.arrowUp;
    final effectiveTrailingIcon = props.trailingIcon ?? icons.xmark;
    final effectiveLeadingStyle = defaults.leadingStyle.merge(theme.leadingStyle);
    final effectiveTrailingStyle = defaults.trailingStyle.merge(theme.trailingStyle);

    return Material(
      shape: effectiveShape,
      elevation: effectiveElevation,
      shadowColor: effectiveShadowColor,
      color: effectiveBackgroundColor,
      child: Padding(
        padding: effectivePadding,
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: .min,
            spacing: spacing.xxs,
            children: [
              StreamButton(
                label: props.label,
                iconLeft: effectiveLeadingIcon,
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                size: StreamButtonSize.small,
                onTap: props.onJumpPressed,
                themeStyle: effectiveLeadingStyle,
              ),
              VerticalDivider(
                color: effectiveSide.color,
                width: effectiveSide.width,
                thickness: effectiveSide.width,
              ),
              StreamButton.icon(
                icon: effectiveTrailingIcon,
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                size: StreamButtonSize.small,
                onTap: props.onDismissPressed,
                themeStyle: effectiveTrailingStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Default theme values for [StreamJumpToUnreadButton].
//
// These defaults are used when no explicit value is provided via
// [StreamJumpToUnreadButtonThemeData]. The defaults are context-aware
// and use tokens from the current [StreamColorScheme] and [StreamTextTheme].
class _JumpToUnreadButtonThemeDefaults extends StreamJumpToUnreadButtonThemeData {
  _JumpToUnreadButtonThemeDefaults(this._context);

  final BuildContext _context;

  late final _colorScheme = _context.streamColorScheme;
  late final _textTheme = _context.streamTextTheme;
  late final _spacing = _context.streamSpacing;
  late final _radius = _context.streamRadius;

  @override
  double get elevation => 3;

  @override
  Color get backgroundColor => _colorScheme.backgroundElevation1;

  @override
  OutlinedBorder get shape => RoundedRectangleBorder(borderRadius: .all(_radius.max));

  @override
  BorderSide get side => BorderSide(color: _colorScheme.borderDefault);

  @override
  Color get shadowColor => Theme.of(_context).shadowColor;

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(_spacing.xxs);

  @override
  StreamButtonThemeStyle get leadingStyle => StreamButtonThemeStyle(
    iconSize: .all(16),
    tapTargetSize: .shrinkWrap,
    textStyle: .all(_textTheme.captionEmphasis),
    padding: .all(.symmetric(horizontal: _spacing.xs, vertical: _spacing.xxs)),
  );

  @override
  StreamButtonThemeStyle get trailingStyle => StreamButtonThemeStyle(
    iconSize: .all(16),
    tapTargetSize: .shrinkWrap,
    padding: .all(EdgeInsets.all(_spacing.xs)),
  );
}
