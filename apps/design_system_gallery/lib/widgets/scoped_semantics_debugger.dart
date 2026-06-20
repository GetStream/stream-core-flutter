import 'dart:math' as math;
import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_core_flutter/core.dart';

/// A scoped variant of Flutter's [SemanticsDebugger].
///
/// Walks the global semantics tree but draws onto a clipped, locally-aligned
/// canvas so only nodes intersecting the scope are visualized at correct
/// positions. Purely decorative — never claims pointer events. Shows:
///
///   * A semi-transparent dim over the preview so the colored boundaries pop.
///   * A role-colored 1.5px outline around every semantic node.
///   * A dashed outline for nodes with `mergeAllDescendantsIntoThisNode`,
///     so over-collapsing `MergeSemantics` is immediately obvious.
///
/// For the actual announcement text, use a real screen reader (TalkBack /
/// VoiceOver) on device — that's the ground truth anyway.
class ScopedSemanticsDebugger extends StatefulWidget {
  const ScopedSemanticsDebugger({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<ScopedSemanticsDebugger> createState() => _ScopedSemanticsDebuggerState();
}

class _ScopedSemanticsDebuggerState extends State<ScopedSemanticsDebugger> with WidgetsBindingObserver {
  PipelineOwner? _pipelineOwner;
  SemanticsHandle? _semanticsHandle;
  var _generation = 0;
  final _paintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _attach();
  }

  @override
  void didUpdateWidget(ScopedSemanticsDebugger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      widget.enabled ? _attach() : _detach();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.enabled) return;
    final newOwner = View.pipelineOwnerOf(context);
    if (newOwner != _pipelineOwner) {
      _pipelineOwner?.semanticsOwner?.removeListener(_update);
      newOwner.semanticsOwner?.addListener(_update);
      _pipelineOwner = newOwner;
    }
  }

  @override
  void didChangeMetrics() => setState(() {});

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  void _attach() {
    _semanticsHandle = SemanticsBinding.instance.ensureSemantics();
    WidgetsBinding.instance.addObserver(this);
    final owner = View.pipelineOwnerOf(context);
    owner.semanticsOwner?.addListener(_update);
    _pipelineOwner = owner;
  }

  void _detach() {
    _pipelineOwner?.semanticsOwner?.removeListener(_update);
    _semanticsHandle?.dispose();
    _semanticsHandle = null;
    _pipelineOwner = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  void _update() {
    _generation++;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    }, debugLabel: 'ScopedSemanticsDebugger.update');
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return CustomPaint(
      key: _paintKey,
      foregroundPainter: _ScopedSemanticsDebuggerPainter(
        owner: _pipelineOwner!,
        generation: _generation,
        devicePixelRatio: View.of(context).devicePixelRatio,
        dimColor: context.streamColorScheme.backgroundApp,
        renderBoxFinder: () => _paintKey.currentContext?.findRenderObject() as RenderBox?,
      ),
      child: widget.child,
    );
  }
}

class _ScopedSemanticsDebuggerPainter extends CustomPainter {
  _ScopedSemanticsDebuggerPainter({
    required this.owner,
    required this.generation,
    required this.devicePixelRatio,
    required this.dimColor,
    required this.renderBoxFinder,
  });

  final PipelineOwner owner;
  final int generation;
  final double devicePixelRatio;
  final Color dimColor;
  final RenderBox? Function() renderBoxFinder;

  static const _kStrokeWidth = 1.5;
  static const _kInnerInset = 0.75;

  @override
  void paint(Canvas canvas, Size size) {
    final rootNode = owner.semanticsOwner?.rootSemanticsNode;
    if (rootNode == null) return;

    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = dimColor.withValues(alpha: 0.38));

    final renderBox = renderBoxFinder();
    final globalOffsetLogical = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final globalOffsetPhysical = globalOffsetLogical * devicePixelRatio;

    canvas.save();
    canvas.scale(1.0 / devicePixelRatio, 1.0 / devicePixelRatio);
    canvas.translate(-globalOffsetPhysical.dx, -globalOffsetPhysical.dy);
    _paint(canvas, rootNode);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScopedSemanticsDebuggerPainter oldDelegate) {
    return owner != oldDelegate.owner || generation != oldDelegate.generation || dimColor != oldDelegate.dimColor;
  }

  void _paint(Canvas canvas, SemanticsNode node) {
    if (node.traversalChildIdentifier != null) return;
    canvas.save();
    if (node.transform != null) {
      canvas.transform(node.transform!.storage);
    }
    final rect = node.rect;
    if (!rect.isEmpty) {
      final lineColor = _colorForNode(node);
      final innerRect = rect.deflate(_kInnerInset);
      final strokePaint = Paint()
        ..strokeWidth = _kStrokeWidth
        ..color = lineColor
        ..style = PaintingStyle.stroke;
      if (innerRect.isEmpty) {
        canvas.drawRect(
          rect,
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.fill,
        );
      } else if (node.mergeAllDescendantsIntoThisNode) {
        _drawDashedRect(canvas, innerRect, strokePaint);
      } else {
        canvas.drawRect(innerRect, strokePaint);
      }
    }
    if (!node.mergeAllDescendantsIntoThisNode) {
      node.visitChildren((child) {
        _paint(canvas, child);
        return true;
      });
    }
    canvas.restore();
  }

  void _drawDashedRect(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    double dashLength = 4,
    double gapLength = 3,
  }) {
    final path = Path();
    for (var x = rect.left; x < rect.right; x += dashLength + gapLength) {
      path
        ..moveTo(x, rect.top)
        ..lineTo(math.min(x + dashLength, rect.right), rect.top);
    }
    for (var y = rect.top; y < rect.bottom; y += dashLength + gapLength) {
      path
        ..moveTo(rect.right, y)
        ..lineTo(rect.right, math.min(y + dashLength, rect.bottom));
    }
    for (var x = rect.right; x > rect.left; x -= dashLength + gapLength) {
      path
        ..moveTo(x, rect.bottom)
        ..lineTo(math.max(x - dashLength, rect.left), rect.bottom);
    }
    for (var y = rect.bottom; y > rect.top; y -= dashLength + gapLength) {
      path
        ..moveTo(rect.left, y)
        ..lineTo(rect.left, math.max(y - dashLength, rect.top));
    }
    canvas.drawPath(path, paint);
  }

  /// Role-based colors from StreamColors. Order matters — earlier checks win
  /// for nodes that match multiple roles (e.g., a selected button shows as a
  /// button).
  static Color _colorForNode(SemanticsNode node) {
    final data = node.getSemanticsData();
    if (data.flagsCollection.isTextField) return StreamColors.green.shade500;
    if (data.flagsCollection.isButton) return StreamColors.blue.shade500;
    if (data.flagsCollection.isSelected != Tristate.none) return StreamColors.purple.shade500;
    if (data.hasAction(SemanticsAction.tap)) return StreamColors.cyan.shade500;
    return StreamColors.neutral.shade400;
  }
}
