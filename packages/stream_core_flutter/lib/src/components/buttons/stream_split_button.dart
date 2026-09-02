import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/components/stream_split_button_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';
import 'internal/stream_button_defaults.dart';
import 'stream_button.dart';

/// Two buttons sharing one surface, separated by a divider.
///
/// A split button pairs a primary action with a secondary one — most often a
/// caret that opens the options for that action. Both halves are
/// [StreamButton.icon]s painted on a single background, so the control reads
/// as one pill rather than two adjacent buttons.
///
/// The background is as tall as the one a [StreamButtonSize.medium]
/// [StreamButton] paints, and the halves paint smaller still — the surface
/// wraps the two icons rather than their tap targets, which stay full height
/// and overhang it. The control has no size of its own.
///
/// The design gives the control the two variants of
/// [StreamSplitButtonVariant], both filled. The surface is resolved from the
/// same [StreamButtonTheme] entry the halves use, which is what keeps the two
/// from drifting apart.
///
/// Each half keeps its own tap target, hover and press feedback, and
/// accessibility node; the divider is decorative.
///
/// {@tool snippet}
///
/// A microphone button with a caret that opens the audio settings:
///
/// ```dart
/// StreamSplitButton.icon(
///   leadingIcon: Icon(context.streamIcons.voiceFill),
///   trailingIcon: Icon(context.streamIcons.caretDown),
///   leadingTooltip: 'Mute',
///   trailingTooltip: 'Audio settings',
///   onLeadingPressed: () => toggleMute(),
///   onTrailingPressed: () => showAudioSettings(),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Go destructive once the microphone is off, and flip the caret while the
/// menu it opens is showing:
///
/// ```dart
/// StreamSplitButton.icon(
///   variant: isMuted ? StreamSplitButtonVariant.destructive : StreamSplitButtonVariant.regular,
///   leadingIcon: Icon(isMuted ? icons.voiceOffFill : icons.voiceFill),
///   trailingIcon: Icon(isMenuOpen ? icons.caretUp : icons.caretDown),
///   onLeadingPressed: () => toggleMute(),
///   onTrailingPressed: () => toggleMenu(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamButton], the button each half is built from.
///  * [StreamSplitButtonVariant], for the available variants.
///  * [StreamSplitButtonTheme], for customizing split button appearance.
@experimental
class StreamSplitButton extends StatelessWidget {
  /// Creates a split button with an icon in each half.
  ///
  /// [leadingIcon] labels the leading half and [trailingIcon] the trailing one.
  /// Both are configurable so the trailing half can point the caret at
  /// whatever it opens — [StreamIcons.caretDown] for a menu below,
  /// [StreamIcons.caretUp] for one above.
  ///
  /// A half with a null callback is disabled; the control as a whole only
  /// takes on its disabled surface once both halves are.
  @experimental
  StreamSplitButton.icon({
    super.key,
    required Widget leadingIcon,
    required Widget trailingIcon,
    VoidCallback? onLeadingPressed,
    VoidCallback? onTrailingPressed,
    StreamSplitButtonVariant variant = .regular,
    String? leadingTooltip,
    String? trailingTooltip,
    StreamSplitButtonStyle? themeStyle,
  }) : props = .new(
         leadingIcon: leadingIcon,
         trailingIcon: trailingIcon,
         onLeadingPressed: onLeadingPressed,
         onTrailingPressed: onTrailingPressed,
         variant: variant,
         leadingTooltip: leadingTooltip,
         trailingTooltip: trailingTooltip,
         themeStyle: themeStyle,
       );

  /// The props controlling the appearance and behavior of this split button.
  final StreamSplitButtonProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).splitButton;
    if (builder != null) return builder(context, props);
    return DefaultStreamSplitButton(props: props);
  }
}

/// The color scheme variant for a [StreamSplitButton].
///
/// A split button has no visual weight axis — both variants are filled — so
/// this stands apart from the [StreamButtonStyle] / [StreamButtonType] pair a
/// [StreamButton] takes.
@experimental
enum StreamSplitButtonVariant {
  /// The neutral surface fill, for an action in its ordinary state.
  regular,

  /// The error/danger fill, for an action that is off or destructive — a
  /// muted microphone, a stopped camera.
  destructive;

  // The button variant the shared surface and both halves are painted as.
  StreamButtonStyle get _buttonStyle => switch (this) {
    StreamSplitButtonVariant.regular => StreamButtonStyle.secondary,
    StreamSplitButtonVariant.destructive => StreamButtonStyle.destructive,
  };
}

/// Properties for configuring a [StreamSplitButton].
///
/// This class holds all the configuration options for a split button,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamSplitButton], which uses these properties.
///  * [DefaultStreamSplitButton], the default implementation.
class StreamSplitButtonProps {
  /// Creates properties for a split button.
  const StreamSplitButtonProps({
    required this.leadingIcon,
    required this.trailingIcon,
    this.onLeadingPressed,
    this.onTrailingPressed,
    this.variant = .regular,
    this.leadingTooltip,
    this.trailingTooltip,
    this.themeStyle,
  });

  /// The icon rendered in the leading half.
  final Widget leadingIcon;

  /// The icon rendered in the secondary (trailing) half.
  ///
  /// Typically a caret pointing at whatever the half opens.
  final Widget trailingIcon;

  /// Called when the leading half is pressed.
  ///
  /// If null, that half is disabled.
  final VoidCallback? onLeadingPressed;

  /// Called when the trailing half is pressed.
  ///
  /// If null, that half is disabled.
  final VoidCallback? onTrailingPressed;

  /// The visual variant of the split button.
  ///
  /// Determines the color scheme used (regular, destructive).
  final StreamSplitButtonVariant variant;

  /// Text shown in a [Tooltip] on hover / long-press of the leading half, and
  /// used as its accessibility label.
  ///
  /// When null, that half has no tooltip.
  final String? leadingTooltip;

  /// Text shown in a [Tooltip] on hover / long-press of the trailing half, and
  /// used as its accessibility label.
  ///
  /// When null, that half has no tooltip.
  final String? trailingTooltip;

  /// Per-instance style overrides for this split button.
  ///
  /// These properties take precedence over the inherited
  /// [StreamSplitButtonTheme] values for this specific instance.
  final StreamSplitButtonStyle? themeStyle;
}

// The halves are always small buttons: the design draws the surface at the
// height of a medium button with a pair of small ones inside it, and never
// scales the control.
const _halfButtonSize = StreamButtonSize.small;

// The opacity the design draws the divider at on the destructive fill. At full
// strength the white hairline cuts the accent surface in two; knocked back it
// reads as a seam in one control.
const _accentSeparatorOpacity = 0.35;

/// Default implementation of [StreamSplitButton].
///
/// Renders a [Row] of two [StreamButton.icon] halves over a shared surface,
/// with a divider between them.
///
/// See also:
///
///  * [StreamSplitButton], the public widget that delegates to this.
///  * [StreamSplitButtonProps], the configuration properties.
class DefaultStreamSplitButton extends StatelessWidget {
  /// Creates a default split button.
  const DefaultStreamSplitButton({super.key, required this.props});

  /// The props controlling the appearance and behavior of this split button.
  final StreamSplitButtonProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final inheritedStyle = context.streamSplitButtonTheme.styleOf(props.variant);
    final themeStyle = inheritedStyle?.merge(props.themeStyle) ?? props.themeStyle;
    final buttonVariant = props.variant._buttonStyle;
    // Resolved once and shared: the surface below and the halves above are the
    // same button style, so they cannot render as different colors.
    final buttonStyle = resolveStreamButtonThemeStyle(
      context,
      style: buttonVariant,
      type: StreamButtonType.solid,
      isFloating: false,
      themeStyle: themeStyle?.buttonStyle,
    );

    final defaults = _StreamSplitButtonDefaults(context, props.variant);

    final isEnabled = props.onLeadingPressed != null || props.onTrailingPressed != null;
    final states = <WidgetState>{if (!isEnabled) WidgetState.disabled};

    final shape = buttonStyle.shape?.resolve(states) ?? const StadiumBorder();
    // Neither variant is outlined, but a theme may still ask for a border; when
    // it does it is drawn once around the whole control rather than each half.
    final borderColor = buttonStyle.borderColor?.resolve(states);

    final effectiveSeparatorColor = (themeStyle?.separatorColor ?? defaults.separatorColor).resolve(states);
    final effectiveSeparatorThickness = themeStyle?.separatorThickness ?? defaults.separatorThickness;
    final effectiveSeparatorHeight = themeStyle?.separatorHeight ?? defaults.separatorHeight;

    // The halves are inset by [inset] on every edge of the surface, which puts
    // a pair of small buttons under a surface the height of a medium one.
    final inset = spacing.xxs;

    // The halves sit on the shared surface, so they paint neither their own
    // background nor their own border. Their box is the painted circle; the tap
    // target around it comes from [_HitTarget], since MaterialTapTargetSize can
    // only grow both axes at once and the design grows only the height.
    final halfStyle = buttonStyle.copyWith(
      backgroundColor: const WidgetStatePropertyAll(StreamColors.transparent),
      borderColor: const WidgetStatePropertyAll(null),
      elevation: const WidgetStatePropertyAll(0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    Widget half({required Widget icon, required VoidCallback? onPressed, required String? tooltip}) {
      // The merge lifts the half's semantics node up to the tap target, so
      // assistive tech reports the region that actually responds to a tap
      // rather than the smaller square the button paints.
      return MergeSemantics(
        child: _HitTarget(
          minSize: Size(_halfButtonSize.value, kMinInteractiveDimension),
          child: StreamButton.icon(
            icon: icon,
            onPressed: onPressed,
            style: buttonVariant,
            size: _halfButtonSize,
            tooltip: tooltip,
            themeStyle: halfStyle,
          ),
        ),
      );
    }

    return Padding(
      // We only add some horizontal padding to match the extra vertical padding from the _HitTarget
      padding: EdgeInsets.symmetric(horizontal: inset),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Painted behind the halves rather than around them: their tap targets
          // are taller than the surface and overhang it top and bottom.
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: _halfButtonSize.value + inset * 2,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: buttonStyle.backgroundColor?.resolve(states),
                    shape: switch (borderColor) {
                      final color? => shape.copyWith(side: BorderSide(color: color)),
                      _ => shape,
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: inset),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: inset,
              children: [
                half(icon: props.leadingIcon, onPressed: props.onLeadingPressed, tooltip: props.leadingTooltip),
                SizedBox(
                  width: effectiveSeparatorThickness,
                  height: effectiveSeparatorHeight,
                  child: ColoredBox(color: effectiveSeparatorColor ?? StreamColors.transparent),
                ),
                half(
                  icon: props.trailingIcon,
                  onPressed: props.onTrailingPressed,
                  tooltip: props.trailingTooltip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Grows the tap target around [child] to at least [minSize] without growing
// what the child paints.
//
// This mirrors the `_InputPadding` that [MaterialTapTargetSize.padded] installs
// inside every Material button. That knob is all-or-nothing at 48x48; a split
// button half is narrower than it is tall, so it needs the same trick with its
// own size.
class _HitTarget extends SingleChildRenderObjectWidget {
  const _HitTarget({required this.minSize, required super.child});

  final Size minSize;

  @override
  _RenderHitTarget createRenderObject(BuildContext context) => _RenderHitTarget(minSize);

  @override
  void updateRenderObject(BuildContext context, _RenderHitTarget renderObject) {
    renderObject.minSize = minSize;
  }
}

class _RenderHitTarget extends RenderShiftedBox {
  _RenderHitTarget(this._minSize) : super(null);

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (_minSize == value) return;
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) => switch (child) {
    final child? => math.max(child.getMinIntrinsicWidth(height), minSize.width),
    _ => 0,
  };

  @override
  double computeMinIntrinsicHeight(double width) => switch (child) {
    final child? => math.max(child.getMinIntrinsicHeight(width), minSize.height),
    _ => 0,
  };

  @override
  double computeMaxIntrinsicWidth(double height) => switch (child) {
    final child? => math.max(child.getMaxIntrinsicWidth(height), minSize.width),
    _ => 0,
  };

  @override
  double computeMaxIntrinsicHeight(double width) => switch (child) {
    final child? => math.max(child.getMaxIntrinsicHeight(width), minSize.height),
    _ => 0,
  };

  Size _computeSize({required BoxConstraints constraints, required ChildLayouter layoutChild}) {
    if (child case final child?) {
      final childSize = layoutChild(child, constraints);
      return constraints.constrain(
        Size(math.max(childSize.width, minSize.width), math.max(childSize.height, minSize.height)),
      );
    }
    return Size.zero;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(constraints: constraints, layoutChild: ChildLayoutHelper.dryLayoutChild);
  }

  @override
  void performLayout() {
    size = _computeSize(constraints: constraints, layoutChild: ChildLayoutHelper.layoutChild);
    if (child case final child?) {
      final childParentData = child.parentData! as BoxParentData;
      childParentData.offset = Alignment.center.alongOffset(size - child.size as Offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Material's own version of this skips the bounds check, which is why two
    // `padded` buttons side by side fight over taps that belong to neither.
    // Two halves in a row is exactly that case, so check bounds first.
    if (!size.contains(position)) return false;
    if (super.hitTest(result, position: position)) return true;

    // Anything else inside the grown box counts as a hit on the child's centre,
    // so the overhang taps through to the button rather than falling to
    // whatever is behind it.
    final center = child!.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, position) => child!.hitTest(result, position: center),
    );
  }
}

// Default theme values for [StreamSplitButton].
//
// These defaults are used when no explicit value is provided via
// [StreamSplitButtonStyle] or [StreamSplitButtonThemeData].
class _StreamSplitButtonDefaults extends StreamSplitButtonStyle {
  _StreamSplitButtonDefaults(this.context, this._variant);

  final BuildContext context;

  final StreamSplitButtonVariant _variant;

  late final StreamSpacing _spacing = context.streamSpacing;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  // The divider is drawn on the button's own fill, so what it should be is a
  // question about that fill rather than about the button's variant.
  @override
  WidgetStateProperty<Color?> get separatorColor => WidgetStateProperty.resolveWith((states) {
    // A disabled button drops its fill and its icon colour for the shared
    // disabled treatment, so the divider goes back to the hairline that reads
    // on it rather than disappearing into it as borderDisabled did.
    if (states.contains(WidgetState.disabled)) return _colorScheme.borderDefault;

    return switch (_variant) {
      // A light surface fill, which the ordinary hairline reads on.
      StreamSplitButtonVariant.regular => _colorScheme.borderDefault,
      // Drawn against the accent fill, knocked back to the opacity the design
      // draws it at.
      StreamSplitButtonVariant.destructive => _colorScheme.borderOnAccent.withValues(
        alpha: _accentSeparatorOpacity,
      ),
    };
  });

  @override
  double get separatorThickness => 1;

  // Inset from the halves by as much as the halves are inset from the surface.
  @override
  double get separatorHeight => _halfButtonSize.value - _spacing.xxs * 2;
}
