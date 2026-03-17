import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/stream_theme_extensions.dart';

/// A pill-shaped chip for displaying a slash command selection.
///
/// [StreamCommandChip] renders a thunder icon, a command label, and a dismiss
/// button. It is typically used as an overlay on a message attachment when a
/// slash command is active in the message composer.
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
  }) : props = StreamCommandChipProps(label: label, onDismiss: onDismiss);

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

  /// Called when the dismiss (×) button is tapped.
  ///
  /// When null the dismiss button is still shown but does nothing.
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
    final defaults = _StreamCommandChipDefaults(context);
    final chipTheme = context.streamCommandChipTheme;

    final effectiveBackgroundColor = chipTheme.backgroundColor ?? defaults.backgroundColor;
    final effectiveLabelColor = chipTheme.labelColor ?? defaults.labelColor;
    final effectiveIconColor = chipTheme.iconColor ?? defaults.iconColor;
    final effectiveMinHeight = chipTheme.minHeight ?? defaults.minHeight;

    return Container(
      padding: defaults.padding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: defaults.borderRadius,
      ),
      constraints: BoxConstraints(minHeight: effectiveMinHeight),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: defaults.spacing.xxxs,
        children: [
          Icon(
            context.streamIcons.thunder,
            size: 12,
            color: effectiveIconColor,
          ),
          MediaQuery.withNoTextScaling(
            child: Text(
              props.label,
              style: defaults.labelStyle.copyWith(color: effectiveLabelColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (props.onDismiss != null)
            GestureDetector(
              onTap: props.onDismiss,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 16,
                height: 16,
                child: Icon(
                  context.streamIcons.crossMedium,
                  size: 12,
                  color: effectiveIconColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Provides default values for [StreamCommandChip] based on the current theme.
class _StreamCommandChipDefaults {
  _StreamCommandChipDefaults(this._context);

  final BuildContext _context;

  late final _colorScheme = _context.streamColorScheme;
  late final _textTheme = _context.streamTextTheme;
  late final spacing = _context.streamSpacing;
  late final _radius = _context.streamRadius;

  Color get backgroundColor => _colorScheme.backgroundInverse;

  Color get labelColor => _colorScheme.textInverse;

  Color get iconColor => _colorScheme.textInverse;

  TextStyle get labelStyle => _textTheme.metadataEmphasis;

  double get minHeight => 24;

  EdgeInsetsGeometry get padding => EdgeInsets.symmetric(
    horizontal: spacing.xs,
    vertical: spacing.xxxs,
  );

  BorderRadius get borderRadius => BorderRadius.all(_radius.max);
}
