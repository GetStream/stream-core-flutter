import 'package:flutter/widgets.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_typing_indicator_dots_theme.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// An animated indicator that shows someone is typing.
///
/// The animation follows the ambient text direction and runs for as long as
/// the indicator is shown. When the platform asks for reduced motion, the
/// indicator holds a still frame instead.
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamTypingIndicatorDots()
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With an accessible label:
///
/// ```dart
/// StreamTypingIndicatorDots(semanticsLabel: 'Ada is typing')
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Matching the color of adjacent text:
///
/// ```dart
/// StreamTypingIndicatorDots(color: colorScheme.textSecondary)
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTypingIndicatorDotsTheme], for theming typing indicator dots in a subtree.
///  * [StreamTypingIndicatorDotsThemeData], which describes the typing
///    indicator dots theme.
class StreamTypingIndicatorDots extends StatelessWidget {
  /// Creates typing indicator dots.
  StreamTypingIndicatorDots({
    super.key,
    Color? color,
    double? dotSize,
    double? spacing,
    Duration? period,
    String? semanticsLabel,
  }) : props = .new(
         color: color,
         dotSize: dotSize,
         spacing: spacing,
         period: period,
         semanticsLabel: semanticsLabel,
       );

  /// The properties that configure these typing indicator dots.
  final StreamTypingIndicatorDotsProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).typingIndicatorDots;
    if (builder != null) return builder(context, props);
    return DefaultStreamTypingIndicatorDots(props: props);
  }
}

/// Properties for configuring a [StreamTypingIndicatorDots].
///
/// This class holds all the configuration options for typing indicator dots,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamTypingIndicatorDots], which uses these properties.
///  * [DefaultStreamTypingIndicatorDots], the default implementation.
class StreamTypingIndicatorDotsProps {
  /// Creates properties for typing indicator dots.
  const StreamTypingIndicatorDotsProps({
    this.color,
    this.dotSize,
    this.spacing,
    this.period,
    this.semanticsLabel,
  });

  /// The color of the dots.
  ///
  /// If null, uses [StreamTypingIndicatorDotsThemeData.color].
  final Color? color;

  /// The diameter of each dot in logical pixels.
  ///
  /// If null, uses [StreamTypingIndicatorDotsThemeData.dotSize].
  final double? dotSize;

  /// The gap between adjacent dots in logical pixels.
  ///
  /// If null, uses [StreamTypingIndicatorDotsThemeData.spacing].
  final double? spacing;

  /// The duration of one full cycle of the animation.
  ///
  /// If null, uses [StreamTypingIndicatorDotsThemeData.period].
  final Duration? period;

  /// The label announced by screen readers for the indicator.
  ///
  /// If null, screen readers skip the indicator.
  final String? semanticsLabel;
}

/// The default implementation of [StreamTypingIndicatorDots].
///
/// Styling is resolved from widget props, the current
/// [StreamTypingIndicatorDotsTheme], and falls back to [StreamColorScheme] tokens.
///
/// See also:
///
///  * [StreamTypingIndicatorDots], the public API widget.
///  * [StreamTypingIndicatorDotsProps], which configures this widget.
class DefaultStreamTypingIndicatorDots extends StatefulWidget {
  /// Creates default typing indicator dots with the given [props].
  const DefaultStreamTypingIndicatorDots({super.key, required this.props});

  /// The properties that configure these typing indicator dots.
  final StreamTypingIndicatorDotsProps props;

  @override
  State<DefaultStreamTypingIndicatorDots> createState() => _DefaultStreamTypingIndicatorDotsState();
}

class _DefaultStreamTypingIndicatorDotsState extends State<DefaultStreamTypingIndicatorDots>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final _controller = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(DefaultStreamTypingIndicatorDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void didChangeAccessibilityFeatures() => setState(_syncAnimation);

  // Android's "Remove animations" and iOS's Reduce Motion arrive through
  // different flags, so both are checked.
  bool get _reduceMotion {
    if (MediaQuery.disableAnimationsOf(context)) return true;
    return View.of(context).platformDispatcher.accessibilityFeatures.reduceMotion;
  }

  void _syncAnimation() {
    if (_reduceMotion) {
      _controller.stop();
      return;
    }

    final defaults = _StreamTypingIndicatorDotsThemeDefaults(context);
    final period = widget.props.period ?? context.streamTypingIndicatorDotsTheme.period ?? defaults.period;
    if (_controller.isAnimating && _controller.duration == period) return;

    _controller.duration = period;
    _controller.repeat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.streamTypingIndicatorDotsTheme;
    final defaults = _StreamTypingIndicatorDotsThemeDefaults(context);

    final effectiveColor = widget.props.color ?? theme.color ?? defaults.color;
    final effectiveDotSize = widget.props.dotSize ?? theme.dotSize ?? defaults.dotSize;
    final effectiveSpacing = widget.props.spacing ?? theme.spacing ?? defaults.spacing;

    const dotCount = _TypingIndicatorDotsPainter.dotCount;
    final indicator = RepaintBoundary(
      child: CustomPaint(
        size: Size(dotCount * effectiveDotSize + (dotCount - 1) * effectiveSpacing, effectiveDotSize),
        painter: _TypingIndicatorDotsPainter(
          progress: _controller,
          animate: !_reduceMotion,
          color: effectiveColor,
          dotSize: effectiveDotSize,
          spacing: effectiveSpacing,
          textDirection: Directionality.of(context),
        ),
      ),
    );

    if (widget.props.semanticsLabel case final label?) {
      return Semantics(label: label, child: indicator);
    }

    return ExcludeSemantics(child: indicator);
  }
}

// Paints the dots, fading each one between [_restingOpacity] and full opacity
// and back. Each dot runs a third of a cycle behind the one before it, so the
// highlight travels across the dots in reading order.
class _TypingIndicatorDotsPainter extends CustomPainter {
  _TypingIndicatorDotsPainter({
    required this.progress,
    required this.animate,
    required this.color,
    required this.dotSize,
    required this.spacing,
    required this.textDirection,
  }) : super(repaint: progress);

  static const dotCount = 3;

  static const _restingOpacity = 0.25;

  // Shown instead of the animation when the platform asks for reduced motion.
  static const _staticOpacities = [1.0, 0.5, 0.25];

  final Animation<double> progress;
  final bool animate;
  final Color color;
  final double dotSize;
  final double spacing;
  final TextDirection textDirection;

  final _paint = Paint();

  double _opacityAt(int index) {
    if (!animate) return _staticOpacities[index];

    final phase = (progress.value - index / dotCount) % 1;
    final highlight = 1 - (2 * phase - 1).abs();
    return _restingOpacity + (1 - _restingOpacity) * highlight;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = dotSize / 2;
    for (var index = 0; index < dotCount; index += 1) {
      final slot = switch (textDirection) {
        .ltr => index,
        .rtl => dotCount - 1 - index,
      };

      _paint.color = color.withValues(alpha: color.a * _opacityAt(index));
      final center = Offset(radius + slot * (dotSize + spacing), radius);
      canvas.drawCircle(center, radius, _paint);
    }
  }

  @override
  bool shouldRepaint(_TypingIndicatorDotsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animate != animate ||
        oldDelegate.color != color ||
        oldDelegate.dotSize != dotSize ||
        oldDelegate.spacing != spacing ||
        oldDelegate.textDirection != textDirection;
  }
}

// Provides default values for [StreamTypingIndicatorDotsThemeData] based on the
// current [StreamColorScheme].
class _StreamTypingIndicatorDotsThemeDefaults extends StreamTypingIndicatorDotsThemeData {
  _StreamTypingIndicatorDotsThemeDefaults(this.context);

  final BuildContext context;

  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  @override
  Color get color => _colorScheme.textPrimary;

  @override
  double get dotSize => 5;

  @override
  double get spacing => 4;

  @override
  Duration get period => const Duration(milliseconds: 1500);
}
