import 'package:flutter/material.dart';

import '../../theme.dart';
import '../message_layout/stream_message_layout.dart';

/// A styled container that wraps message content with a themed background,
/// shape, and padding.
///
/// [StreamMessageBubble] is the visual shell of a chat message. Metadata,
/// reactions, and reply indicators compose around it at a higher level.
///
/// If a [StreamMessageLayout] is found in the ancestor tree, style
/// properties automatically adapt to the current message layout.
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
///  * [StreamMessageLayout], which provides the layout context
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

  /// Optional style overrides for layout-aware styling.
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
    final layout = StreamMessageLayout.of(context);
    final themeStyle = StreamMessageItemTheme.of(context).bubble;
    final defaults = _StreamMessageBubbleDefaults(context);

    final resolve = StreamMessageLayoutResolver(layout, [props.style, themeStyle, defaults]);

    final effectiveSide = resolve((s) => s?.side);
    final effectiveShape = resolve((s) => s?.shape).copyWith(side: effectiveSide);
    final effectivePadding = props.padding ?? resolve((s) => s?.padding);
    final effectiveConstraints = resolve((s) => s?.constraints);
    final effectiveBackgroundColor = resolve((s) => s?.backgroundColor);

    return ConstrainedBox(
      constraints: effectiveConstraints,
      child: Material(
        clipBehavior: .hardEdge,
        shape: effectiveShape,
        color: effectiveBackgroundColor,
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
  StreamMessageLayoutProperty<Color> get backgroundColor => .resolveWith(
    (layout) => switch ((layout.alignment, layout.contentKind)) {
      (_, .jumbomoji) => StreamColors.transparent,
      (.start, _) => _colorScheme.backgroundSurface,
      (.end, _) => _colorScheme.brand.shade100,
    },
  );

  @override
  StreamMessageLayoutProperty<OutlinedBorder> get shape => .resolveWith(
    (layout) => RoundedSuperellipseBorder(
      borderRadius: switch ((layout.alignment, layout.stackPosition)) {
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
  StreamMessageLayoutBorderSide get side => .resolveWith(
    (layout) => switch ((layout.alignment, layout.contentKind)) {
      (_, .jumbomoji) => BorderSide.none,
      (.start, _) => BorderSide(color: _colorScheme.borderSubtle),
      (.end, _) => BorderSide(color: _colorScheme.brand.shade100),
    },
  );

  @override
  StreamMessageLayoutProperty<EdgeInsetsGeometry> get padding => .resolveWith(
    (layout) => switch (layout.contentKind) {
      .singleAttachment => EdgeInsets.zero,
      _ => .symmetric(vertical: _spacing.xs),
    },
  );

  @override
  StreamMessageLayoutProperty<BoxConstraints> get constraints => .all(const .new(minHeight: 20));
}
