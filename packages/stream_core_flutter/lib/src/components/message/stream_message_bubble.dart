import 'package:flutter/widgets.dart';

import '../../theme.dart';

/// A styled container that wraps message content with a themed background,
/// shape, and padding.
///
/// [StreamMessageBubble] is the visual shell of a chat message. Metadata,
/// reactions, and reply indicators compose around it at a higher level.
///
/// Each visual property can be set directly on the widget. Unset properties
/// fall back to the inherited [StreamMessageBubbleThemeData], then to
/// built-in defaults.
///
/// {@tool snippet}
///
/// A simple text bubble:
///
/// ```dart
/// StreamMessageBubble(
///   backgroundColor: Colors.blue.shade50,
///   child: Text('Hello, world!'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// A bubble with custom structural properties:
///
/// ```dart
/// StreamMessageBubble(
///   shape: RoundedRectangleBorder(
///     borderRadius: BorderRadius.circular(24),
///   ),
///   side: BorderSide(color: Colors.grey),
///   padding: EdgeInsets.all(16),
///   backgroundColor: Colors.white,
///   child: Text('Styled bubble'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageBubbleStyle], for the structural style properties.
///  * [StreamMessageBubbleThemeData], for theming the bubble.
///  * [StreamMessageGroupPosition], for adjusting shape based on message
///    grouping.
class StreamMessageBubble extends StatelessWidget {
  /// Creates a message bubble.
  ///
  /// The [child] is required; all other parameters are optional and fall back
  /// to theme or default values.
  StreamMessageBubble({
    super.key,
    required Widget child,
    OutlinedBorder? shape,
    BorderSide? side,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Color? backgroundColor,
  }) : props = StreamMessageBubbleProps(
         child: child,
         shape: shape,
         side: side,
         padding: padding,
         constraints: constraints,
         backgroundColor: backgroundColor,
       );

  /// The properties that configure this bubble.
  final StreamMessageBubbleProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageBubble;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageBubble(props: props);
  }
}

/// Properties for configuring a [StreamMessageBubble].
///
/// See also:
///
///  * [StreamMessageBubble], which uses these properties.
class StreamMessageBubbleProps {
  /// Creates properties for a message bubble.
  const StreamMessageBubbleProps({
    required this.child,
    this.shape,
    this.side,
    this.padding,
    this.constraints,
    this.backgroundColor,
  });

  /// The content widget displayed inside the bubble.
  final Widget child;

  /// The shape of the bubble's container.
  ///
  /// If null, uses [StreamMessageBubbleThemeData], then the default
  /// [RoundedRectangleBorder] with 20px radius.
  final OutlinedBorder? shape;

  /// The border outline of the bubble.
  ///
  /// Combined with [shape] via [OutlinedBorder.copyWith]. If null, uses
  /// [StreamMessageBubbleThemeData], then a 1px `borderSubtle` border.
  final BorderSide? side;

  /// Content padding inside the bubble.
  ///
  /// If null, uses [StreamMessageBubbleThemeData], then a value derived
  /// from [StreamSpacing].
  final EdgeInsetsGeometry? padding;

  /// Size constraints for the bubble.
  ///
  /// If null, defaults to `BoxConstraints(minHeight: 20)`.
  final BoxConstraints? constraints;

  /// The background color of the bubble.
  ///
  /// If null, uses [StreamMessageBubbleThemeData], then the surface color
  /// from [StreamColorScheme].
  final Color? backgroundColor;
}

/// The default implementation of [StreamMessageBubble].
///
/// See also:
///
///  * [StreamMessageBubble], the public API widget.
///  * [StreamMessageBubbleProps], which configures this widget.
class DefaultStreamMessageBubble extends StatelessWidget {
  /// Creates a default message bubble with the given [props].
  const DefaultStreamMessageBubble({super.key, required this.props});

  /// The properties that configure this bubble.
  final StreamMessageBubbleProps props;

  @override
  Widget build(BuildContext context) {
    final defaults = _StreamMessageBubbleDefaults(context);

    final effectiveSide = props.side ?? defaults.side;
    final effectiveShape = (props.shape ?? defaults.shape).copyWith(side: effectiveSide);
    final effectivePadding = props.padding ?? defaults.padding;
    final effectiveConstraints = props.constraints ?? defaults.constraints;
    final effectiveBackgroundColor = props.backgroundColor ?? defaults.backgroundColor;

    return ConstrainedBox(
      constraints: effectiveConstraints,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: effectiveShape,
          color: effectiveBackgroundColor,
        ),
        child: Padding(
          padding: effectivePadding,
          child: props.child,
        ),
      ),
    );
  }
}

class _StreamMessageBubbleDefaults extends StreamMessageBubbleStyle {
  _StreamMessageBubbleDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamRadius _radius = _context.streamRadius;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  Color get backgroundColor => _colorScheme.backgroundSurface;

  @override
  OutlinedBorder get shape => RoundedRectangleBorder(borderRadius: .all(_radius.xxxl));

  @override
  BorderSide get side => BorderSide(color: _colorScheme.borderSubtle);

  @override
  EdgeInsetsGeometry get padding => .symmetric(horizontal: _spacing.sm, vertical: _spacing.xs);

  @override
  BoxConstraints get constraints => const BoxConstraints(minHeight: 20);
}
