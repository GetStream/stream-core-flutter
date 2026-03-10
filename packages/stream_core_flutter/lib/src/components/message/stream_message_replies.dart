import 'package:flutter/material.dart';

import '../../theme.dart';
import '../avatar/stream_avatar_stack.dart';
import 'stream_message_alignment.dart';

/// A tappable row showing reply count, participant avatars, and an optional
/// connector for threaded messages.
///
/// Displays an optional [label] (typically a reply count), a list of
/// participant [avatars], and an optional connector linking the row to the
/// parent message bubble.
///
/// The visual order of elements is controlled by [alignment]:
///  * [StreamMessageAlignment.start]: `[connector, avatars, label]`
///  * [StreamMessageAlignment.end]: `[label, avatars, connector]`
///
/// When [showConnector] is true, a connector is displayed that visually
/// links the row to the message bubble above. The connector adapts to
/// [alignment] and the ambient [TextDirection].
///
/// RTL support comes from the ambient [TextDirection] automatically — the
/// alignment only controls the semantic order, not the physical direction.
///
/// {@tool snippet}
///
/// Incoming message with replies:
///
/// ```dart
/// StreamMessageReplies(
///   label: Text('3 replies'),
///   avatars: [
///     StreamAvatar(placeholder: (context) => Text('A')),
///     StreamAvatar(placeholder: (context) => Text('B')),
///   ],
///   showConnector: true,
///   onTap: () => openThread(),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Outgoing message with replies (end alignment):
///
/// ```dart
/// StreamMessageReplies(
///   label: Text('5 replies'),
///   avatars: [
///     StreamAvatar(placeholder: (context) => Text('A')),
///   ],
///   showConnector: true,
///   alignment: StreamMessageAlignment.end,
///   onTap: () => openThread(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageRepliesThemeData], for customizing replies appearance.
///  * [StreamMessageRepliesTheme], for overriding theme in a widget subtree.
///  * [StreamMessageAlignment], for controlling element order.
///  * [StreamAvatarStack], which renders the avatars internally.
class StreamMessageReplies extends StatelessWidget {
  /// Creates a message replies row.
  ///
  /// All slots are optional — when null or empty, they are omitted from the
  /// row.
  StreamMessageReplies({
    super.key,
    Widget? label,
    Iterable<Widget>? avatars,
    StreamAvatarStackSize avatarSize = .sm,
    int maxAvatars = 3,
    bool showConnector = true,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    StreamMessageAlignment alignment = .start,
    double? spacing,
    EdgeInsetsGeometry? padding,
    Clip clipBehavior = .none,
  }) : props = .new(
         label: label,
         avatars: avatars,
         avatarSize: avatarSize,
         maxAvatars: maxAvatars,
         showConnector: showConnector,
         onTap: onTap,
         onLongPress: onLongPress,
         alignment: alignment,
         spacing: spacing,
         padding: padding,
         clipBehavior: clipBehavior,
       );

  /// The properties that configure this replies row.
  final StreamMessageRepliesProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageReplies;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageReplies(props: props);
  }
}

/// Properties for configuring a [StreamMessageReplies].
///
/// See also:
///
///  * [StreamMessageReplies], which uses these properties.
class StreamMessageRepliesProps {
  /// Creates properties for a message replies row.
  const StreamMessageRepliesProps({
    this.label,
    this.avatars,
    this.avatarSize = .sm,
    this.maxAvatars = 3,
    this.showConnector = true,
    this.onTap,
    this.onLongPress,
    this.alignment = .start,
    this.spacing,
    this.padding,
    this.clipBehavior = .none,
  });

  /// An optional label widget, typically a [Text] showing the reply count
  /// (e.g. "3 replies").
  ///
  /// Styled by [StreamMessageRepliesThemeData.labelTextStyle] and
  /// [StreamMessageRepliesThemeData.labelColor].
  final Widget? label;

  /// Avatar widgets for thread participants.
  ///
  /// Displayed as an overlapping stack. The size of each avatar is controlled
  /// by [avatarSize] and the number of visible avatars by [maxAvatars].
  final Iterable<Widget>? avatars;

  /// The size of each avatar in the stack.
  ///
  /// Defaults to [StreamAvatarStackSize.sm] (24px).
  final StreamAvatarStackSize avatarSize;

  /// Maximum number of avatars to display before showing an overflow badge.
  ///
  /// Defaults to 3.
  final int maxAvatars;

  /// Whether to show the connector linking this row to the message bubble.
  ///
  /// The connector appearance is controlled by
  /// [StreamMessageRepliesThemeData.connectorColor] and
  /// [StreamMessageRepliesThemeData.connectorStrokeWidth].
  ///
  /// The connector adapts to [alignment] and [TextDirection] to always
  /// point toward the message bubble.
  final bool showConnector;

  /// Called when the replies row is tapped, typically to navigate to the
  /// thread view.
  final VoidCallback? onTap;

  /// Called when the replies row is long-pressed.
  final VoidCallback? onLongPress;

  /// Controls the semantic order of elements in the row.
  ///
  /// See [StreamMessageAlignment] for details on how this composes with
  /// [TextDirection].
  final StreamMessageAlignment alignment;

  /// The gap between elements (connector, avatars, label).
  ///
  /// When null, falls back to [StreamMessageRepliesThemeData.spacing].
  final double? spacing;

  /// The padding around the replies row content.
  ///
  /// When null, falls back to [StreamMessageRepliesThemeData.padding].
  final EdgeInsetsGeometry? padding;

  /// How to clip the widget's content.
  ///
  /// Useful when the connector overflows the row bounds. Set to
  /// [Clip.hardEdge] or similar to constrain the visible area.
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;
}

/// The default implementation of [StreamMessageReplies].
///
/// See also:
///
///  * [StreamMessageReplies], the public API widget.
///  * [StreamMessageRepliesProps], which configures this widget.
class DefaultStreamMessageReplies extends StatelessWidget {
  /// Creates a default message replies row with the given [props].
  const DefaultStreamMessageReplies({super.key, required this.props});

  /// The properties that configure this replies row.
  final StreamMessageRepliesProps props;

  @override
  Widget build(BuildContext context) {
    final theme = context.streamMessageRepliesTheme;
    final defaults = _StreamMessageRepliesThemeDefaults(context);

    final effectiveLabelTextStyle = theme.labelTextStyle ?? defaults.labelTextStyle;
    final effectiveLabelColor = theme.labelColor ?? defaults.labelColor;
    final effectiveSpacing = props.spacing ?? theme.spacing ?? defaults.spacing;
    final effectivePadding = props.padding ?? theme.padding ?? defaults.padding;

    Widget? labelWidget;
    if (props.label case final label?) {
      labelWidget = Flexible(
        child: AnimatedDefaultTextStyle(
          style: effectiveLabelTextStyle.copyWith(color: effectiveLabelColor),
          duration: kThemeChangeDuration,
          child: label,
        ),
      );
    }

    Widget? avatarsWidget;
    if (props.avatars case final avatars? when avatars.isNotEmpty) {
      avatarsWidget = StreamAvatarStack(
        size: props.avatarSize,
        max: props.maxAvatars,
        children: avatars,
      );
    }

    Widget? connectorWidget;
    if (props.showConnector) {
      final effectiveConnectorColor = theme.connectorColor ?? defaults.connectorColor;
      final effectiveStrokeWidth = theme.connectorStrokeWidth ?? defaults.connectorStrokeWidth;

      connectorWidget = CustomPaint(
        size: const Size(_kConnectorWidth, _kConnectorHeight),
        painter: _ConnectorPainter(
          color: effectiveConnectorColor,
          strokeWidth: effectiveStrokeWidth,
          alignment: props.alignment,
          textDirection: Directionality.of(context),
        ),
      );
    }

    final children = switch (props.alignment) {
      .start => [?connectorWidget, ?avatarsWidget, ?labelWidget],
      .end => [?labelWidget, ?avatarsWidget, ?connectorWidget],
    };

    Widget child = Padding(
      padding: effectivePadding,
      child: Row(mainAxisSize: .min, spacing: effectiveSpacing, children: children),
    );

    if (props.clipBehavior != Clip.none) {
      child = ClipRect(clipBehavior: props.clipBehavior, child: child);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: props.onTap,
      onLongPress: props.onLongPress,
      child: child,
    );
  }
}

// The layout slot size for the connector (from Figma: 16x24px).
const double _kConnectorWidth = 16;
const double _kConnectorHeight = 24;

// The y-coordinate of the path exit point in the SVG (where the curve
// ends horizontally). Used to translate the canvas so the exit aligns
// with the vertical center of the layout slot.
const double _kConnectorExitY = 36;

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.color,
    required this.strokeWidth,
    required this.alignment,
    required this.textDirection,
  });

  final Color color;
  final double strokeWidth;
  final StreamMessageAlignment alignment;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final roundedStroke = strokeWidth.roundToDouble();
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = roundedStroke;

    // Translate so the path exit point (y=36 in the SVG) aligns with the
    // vertical center of the paint area. This lets the Row's default
    // CrossAxisAlignment.center naturally align the connector exit with
    // the avatar center — no hardcoded offset needed.
    canvas.translate(0, (size.height / 2) - _kConnectorExitY);

    // The connector curves inward toward the content. The curve direction
    // depends on which physical side the connector sits on, determined by
    // both alignment and text direction. Mirror the canvas when flipped.
    final isFlipped = switch ((alignment, textDirection)) {
      (StreamMessageAlignment.start, TextDirection.rtl) => true,
      (StreamMessageAlignment.end, TextDirection.ltr) => true,
      _ => false,
    };

    if (isFlipped) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    // Snap the vertical line to pixel boundaries to avoid anti-aliasing blur.
    final isOddStroke = roundedStroke.toInt().isOdd;
    final lineX = isOddStroke ? 0.5 : 0.0;

    // Figma SVG path (16x37): M16 36 C7.44 36 0.5 29.06 0.5 20.5 L0.5 0
    final path = Path()
      ..moveTo(16, 36)
      ..cubicTo(7.43959, 36, lineX, 29.0604, lineX, 20.5)
      ..lineTo(lineX, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      alignment != oldDelegate.alignment ||
      textDirection != oldDelegate.textDirection;
}

class _StreamMessageRepliesThemeDefaults extends StreamMessageRepliesThemeData {
  _StreamMessageRepliesThemeDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  double get connectorStrokeWidth => 1;

  @override
  Color get connectorColor => _colorScheme.borderSubtle;

  @override
  TextStyle get labelTextStyle => _textTheme.captionEmphasis;

  @override
  Color get labelColor => _colorScheme.textLink;

  @override
  double get spacing => _spacing.xs;

  @override
  EdgeInsetsGeometry get padding => .only(top: _spacing.xs, bottom: _spacing.xxs);
}
