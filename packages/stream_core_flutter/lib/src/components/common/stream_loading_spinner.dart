import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A circular loading spinner component.
///
/// [StreamLoadingSpinner] displays a circular loading spinner that rotates
/// continuously. It supports customizing the size, stroke width, and colors.
class StreamLoadingSpinner extends StatelessWidget {
  /// Creates a [StreamLoadingSpinner].
  StreamLoadingSpinner({
    super.key,
    double? size,
    double? strokeWidth,
    Color? color,
    Color? trackColor,
  }) : props = StreamLoadingSpinnerProps(
         size: size,
         strokeWidth: strokeWidth,
         color: color,
         trackColor: trackColor,
       );

  /// The props controlling the appearance of this spinner.
  final StreamLoadingSpinnerProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).loadingSpinner;
    if (builder != null) return builder(context, props);
    return DefaultStreamLoadingSpinner(props: props);
  }
}

/// Properties for configuring a [StreamLoadingSpinner].
///
/// This class holds all the configuration options for a loading spinner,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamLoadingSpinner], which uses these properties.
///  * [DefaultStreamLoadingSpinner], the default implementation.
class StreamLoadingSpinnerProps {
  /// Creates properties for a loading spinner.
  const StreamLoadingSpinnerProps({
    this.size,
    this.strokeWidth,
    this.color,
    this.trackColor,
  });

  /// The diameter of the spinner.
  ///
  /// If null, defaults to 20.
  final double? size;

  /// The width of both the track and the animated arc.
  ///
  /// If null, defaults to 2.
  final double? strokeWidth;

  /// The color of the animated arc.
  ///
  /// If null, uses [StreamColorScheme.accentPrimary].
  final Color? color;

  /// The color of the background track circle.
  ///
  /// If null, uses [StreamColorScheme.borderDefault].
  final Color? trackColor;
}

/// Default implementation of [StreamLoadingSpinner].
///
/// Renders a circular spinner with a background track and a rotating arc
/// using [CustomPaint]. Styling is resolved from widget props and the
/// current [StreamColorScheme].
///
/// See also:
///
///  * [StreamLoadingSpinner], the public API widget.
class DefaultStreamLoadingSpinner extends StatefulWidget {
  /// Creates a default Stream loading spinner.
  const DefaultStreamLoadingSpinner({super.key, required this.props});

  /// The props controlling the appearance of this spinner.
  final StreamLoadingSpinnerProps props;

  @override
  State<DefaultStreamLoadingSpinner> createState() => _DefaultStreamLoadingSpinnerState();
}

class _DefaultStreamLoadingSpinnerState extends State<DefaultStreamLoadingSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final effectiveSize = widget.props.size ?? 20;
    final effectiveStrokeWidth = widget.props.strokeWidth ?? 2;
    final effectiveColor = widget.props.color ?? colorScheme.accentPrimary;
    final effectiveTrackColor = widget.props.trackColor ?? colorScheme.borderDefault;

    return SizedBox.square(
      dimension: effectiveSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SpinnerPainter(
              progress: _controller.value,
              color: effectiveColor,
              trackColor: effectiveTrackColor,
              strokeWidth: effectiveStrokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw the background track.
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw the animated arc.
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const sweepAngle = math.pi / 3; // 60 degrees
    final startAngle = 2 * math.pi * progress - math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
