import 'package:flutter/widgets.dart';

import '../../theme.dart';
import '../message_placement/stream_message_placement.dart';

/// A styled container that wraps message content with a themed background,
/// shape, and padding.
///
/// [StreamMessageBubble] is the visual shell of a chat message. Metadata,
/// reactions, and reply indicators compose around it at a higher level.
///
/// If a [StreamMessagePlacement] is found in the ancestor tree, style
/// properties automatically adapt to the current message placement.
///
/// {@tool snippet}
///
/// A simple text bubble using theme defaults:
///
/// ```dart
/// StreamMessageBubble(child: Text('Hello, world!'))
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// A bubble with uniform style overrides:
///
/// ```dart
/// StreamMessageBubble(
///   style: StreamMessageBubbleStyle.from(
///     backgroundColor: Colors.white,
///     padding: EdgeInsets.all(16),
///   ),
///   child: Text('Styled bubble'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageBubbleStyle], for resolver-based styling.
///  * [StreamMessageItemTheme], for theming via the widget tree.
///  * [StreamMessagePlacement], which provides the placement context
///    used to resolve styles.
class StreamMessageBubble extends StatelessWidget {
  /// Creates a message bubble.
  ///
  /// The [child] is required. An optional [style] can override individual
  /// fields; unset fields fall back to theme, then to defaults.
  StreamMessageBubble({
    super.key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    StreamMessageBubbleStyle? style,
  }) : props = .new(child: child, padding: padding, style: style);

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
    this.padding,
    this.style,
  });

  /// The content widget displayed inside the bubble.
  final Widget child;

  /// Optional padding override for the bubble content.
  ///
  /// When non-null, takes precedence over the theme-resolved value.
  final EdgeInsetsGeometry? padding;

  /// Optional style overrides for placement-aware styling.
  ///
  /// Fields left null fall back to the inherited [StreamMessageItemTheme],
  /// then to built-in defaults.
  final StreamMessageBubbleStyle? style;
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
    final placement = StreamMessagePlacement.of(context);
    final bubbleStyle = props.style ?? StreamMessageItemTheme.of(context).bubble;
    final defaults = _StreamMessageBubbleDefaults(context);

    final resolve = StreamMessageStyleResolver(placement, [bubbleStyle, defaults]);

    final effectiveSide = resolve((s) => s?.side);
    final effectiveShape = resolve((s) => s?.shape).copyWith(side: effectiveSide);
    final effectivePadding = props.padding ?? resolve((s) => s?.padding);
    final effectiveConstraints = resolve((s) => s?.constraints);
    final effectiveBackgroundColor = resolve((s) => s?.backgroundColor);

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
  StreamMessageStyleProperty<Color> get backgroundColor => .resolveWith(
    (placement) => switch (placement.alignment) {
      .start => _colorScheme.backgroundSurface,
      .end => _colorScheme.brand.shade100,
    },
  );

  @override
  StreamMessageStyleProperty<OutlinedBorder> get shape => .resolveWith(
    (placement) => RoundedSuperellipseBorder(
      borderRadius: switch ((placement.alignment, placement.stackPosition)) {
        (.start, .single || .bottom) => BorderRadiusDirectional.only(
          topStart: _radius.xxl,
          topEnd: _radius.xxl,
          bottomEnd: _radius.xxl,
        ),
        (.end, .single || .bottom) => BorderRadiusDirectional.only(
          topStart: _radius.xxl,
          topEnd: _radius.xxl,
          bottomStart: _radius.xxl,
        ),
        _ => BorderRadiusDirectional.all(_radius.xxl),
      },
    ),
  );

  @override
  StreamMessageStyleBorderSide get side => .resolveWith(
    (placement) => switch (placement.alignment) {
      .start => BorderSide(color: _colorScheme.borderSubtle),
      .end => BorderSide(color: _colorScheme.brand.shade100),
    },
  );

  @override
  StreamMessageStyleProperty<EdgeInsetsGeometry> get padding => .all(.symmetric(vertical: _spacing.xs));

  @override
  StreamMessageStyleProperty<BoxConstraints> get constraints => .all(const BoxConstraints(minHeight: 20));
}
