import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_command_chip_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A pill-shaped chip for displaying a slash command selection.
///
/// [StreamCommandChip] renders a thunder icon, a command label, and a dismiss
/// (×) icon. It is typically used as an overlay on a message attachment when a
/// slash command is active in the message composer.
///
/// Tapping anywhere on the chip invokes [onDismiss]; the trailing × icon is a
/// visual affordance. When [onDismiss] is null the chip is inert and the
/// dismiss icon is hidden.
///
/// {@tool snippet}
///
/// Display a command chip with a dismiss callback:
///
/// ```dart
/// StreamCommandChip(
///   label: '/giphy',
///   onDismiss: () => clearCommand(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamCommandChipTheme], for customizing chip appearance.
class StreamCommandChip extends StatelessWidget {
  /// Creates a command chip with a [label] and optional [onDismiss] callback.
  StreamCommandChip({
    super.key,
    required String label,
    VoidCallback? onDismiss,
  }) : props = .new(label: label, onDismiss: onDismiss);

  /// The props controlling the appearance and behavior of this chip.
  final StreamCommandChipProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).commandChip;
    if (builder != null) return builder(context, props);
    return DefaultStreamCommandChip(props: props);
  }
}

/// Properties for configuring a [StreamCommandChip].
///
/// See also:
///
///  * [StreamCommandChip], which uses these properties.
///  * [DefaultStreamCommandChip], the default implementation.
class StreamCommandChipProps {
  /// Creates properties for a command chip.
  const StreamCommandChipProps({
    required this.label,
    this.onDismiss,
  });

  /// The command label to display inside the chip.
  final String label;

  /// Called when the chip is tapped.
  ///
  /// Tapping anywhere on the chip — not just the × icon — invokes this
  /// callback. When null the chip is inert and the dismiss icon is hidden.
  final VoidCallback? onDismiss;
}

/// Default implementation of [StreamCommandChip].
class DefaultStreamCommandChip extends StatelessWidget {
  /// Creates a default command chip.
  const DefaultStreamCommandChip({super.key, required this.props});

  /// The props controlling the appearance and behavior of this chip.
  final StreamCommandChipProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final defaults = _StreamCommandChipDefaults(context);
    final chipTheme = context.streamCommandChipTheme;

    final effectiveMinHeight = chipTheme.minHeight ?? defaults.minHeight;
    final effectivePadding = chipTheme.padding ?? defaults.padding;
    final effectiveBorderRadius = chipTheme.borderRadius ?? defaults.borderRadius;
    final effectiveBackgroundColor = chipTheme.backgroundColor ?? defaults.backgroundColor;
    final effectiveForegroundColor = chipTheme.foregroundColor ?? defaults.foregroundColor;
    final effectiveLabelStyle = (chipTheme.labelStyle ?? defaults.labelStyle).copyWith(color: effectiveForegroundColor);

    return GestureDetector(
      behavior: .opaque,
      onTap: props.onDismiss,
      child: Container(
        constraints: .new(minHeight: effectiveMinHeight),
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: effectiveBorderRadius,
        ),
        child: IconTheme(
          data: .new(color: effectiveForegroundColor),
          child: DefaultTextStyle.merge(
            maxLines: 1,
            overflow: .ellipsis,
            style: effectiveLabelStyle,
            child: MediaQuery.withNoTextScaling(
              child: Row(
                mainAxisSize: .min,
                children: [
                  Icon(size: 12, context.streamIcons.bolt),
                  SizedBox(width: spacing.xxs),
                  Flexible(child: Text(props.label)),
                  if (props.onDismiss != null) ...[
                    SizedBox(width: spacing.xxxs),
                    Icon(size: 16, context.streamIcons.xmarkSmall),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Provides default values for [StreamCommandChip] based on the current theme.
class _StreamCommandChipDefaults extends StreamCommandChipThemeData {
  _StreamCommandChipDefaults(this._context);

  final BuildContext _context;

  late final _colorScheme = _context.streamColorScheme;
  late final _textTheme = _context.streamTextTheme;
  late final _radius = _context.streamRadius;
  late final _spacing = _context.streamSpacing;

  @override
  double get minHeight => 24;

  @override
  Color get backgroundColor => _colorScheme.backgroundInverse;

  @override
  Color get foregroundColor => _colorScheme.textOnInverse;

  @override
  TextStyle get labelStyle => _textTheme.metadataEmphasis;

  @override
  EdgeInsetsGeometry get padding => .symmetric(horizontal: _spacing.xs, vertical: _spacing.xxxs);

  @override
  BorderRadiusGeometry get borderRadius => .all(_radius.max);
}
