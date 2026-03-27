import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_skeleton_loading_theme.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A skeleton shimmer loading component.
///
/// [StreamSkeletonLoading] displays a shimmer animation effect over its
/// [child], typically used as a placeholder while content is loading.
///
/// The shimmer colors, animation period, and direction can be customized
/// via direct properties or through [StreamSkeletonLoadingTheme].
///
/// {@tool snippet}
///
/// Basic usage with a placeholder container:
///
/// ```dart
/// StreamSkeletonLoading(
///   child: Container(
///     width: double.infinity,
///     height: 20,
///     decoration: BoxDecoration(
///       color: Colors.white,
///       borderRadius: BorderRadius.circular(4),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSkeletonLoadingTheme], for theming skeleton widgets in a subtree.
///  * [StreamSkeletonLoadingThemeData], which describes the skeleton theme.
class StreamSkeletonLoading extends StatelessWidget {
  /// Creates a [StreamSkeletonLoading].
  StreamSkeletonLoading({
    super.key,
    Color? baseColor,
    Color? highlightColor,
    Duration? period,
    ShimmerDirection? direction,
    bool enabled = true,
    required Widget child,
  }) : props = .new(
         baseColor: baseColor,
         highlightColor: highlightColor,
         period: period,
         direction: direction,
         enabled: enabled,
         child: child,
       );

  /// The props controlling the appearance of this skeleton loading.
  final StreamSkeletonLoadingProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).skeletonLoading;
    if (builder != null) return builder(context, props);
    return DefaultStreamSkeletonLoading(props: props);
  }
}

/// Properties for configuring a [StreamSkeletonLoading].
///
/// This class holds all the configuration options for a skeleton shimmer,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamSkeletonLoading], which uses these properties.
///  * [DefaultStreamSkeletonLoading], the default implementation.
class StreamSkeletonLoadingProps {
  /// Creates properties for a skeleton shimmer.
  const StreamSkeletonLoadingProps({
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
    this.period,
    this.direction,
    required this.child,
  });

  /// Whether the shimmer animation is running.
  ///
  /// Defaults to true.
  final bool enabled;

  /// The base color of the shimmer effect.
  ///
  /// If null, uses the theme's base color.
  final Color? baseColor;

  /// The highlight color of the shimmer effect.
  ///
  /// If null, uses the theme's highlight color.
  final Color? highlightColor;

  /// The duration of one shimmer animation cycle.
  ///
  /// If null, uses the theme's period.
  final Duration? period;

  /// The direction of the shimmer animation.
  ///
  /// If null, follows the ambient [Directionality].
  final ShimmerDirection? direction;

  /// The widget to display the shimmer effect over.
  final Widget child;
}

/// Default implementation of [StreamSkeletonLoading].
///
/// Renders a shimmer effect using [Shimmer.fromColors] from the `shimmer`
/// package. Styling is resolved from widget props, the current
/// [StreamSkeletonLoadingTheme], and falls back to [StreamColorScheme] tokens.
///
/// See also:
///
///  * [StreamSkeletonLoading], the public API widget.
class DefaultStreamSkeletonLoading extends StatelessWidget {
  /// Creates a default Stream skeleton loading shimmer.
  const DefaultStreamSkeletonLoading({super.key, required this.props});

  /// The props controlling the appearance of this skeleton loading.
  final StreamSkeletonLoadingProps props;

  @override
  Widget build(BuildContext context) {
    final theme = context.streamSkeletonLoadingTheme;
    final defaults = _StreamSkeletonLoadingThemeDefaults(context);

    final effectiveBaseColor = props.baseColor ?? theme.baseColor ?? defaults.baseColor;
    final effectiveHighlightColor = props.highlightColor ?? theme.highlightColor ?? defaults.highlightColor;
    final effectivePeriod = props.period ?? theme.period ?? defaults.period;

    final textDirection = Directionality.of(context);
    final defaultDirection = textDirection == .ltr ? ShimmerDirection.ltr : ShimmerDirection.rtl;
    final effectiveDirection = props.direction ?? defaultDirection;

    return Shimmer.fromColors(
      enabled: props.enabled,
      baseColor: effectiveBaseColor,
      highlightColor: effectiveHighlightColor,
      period: effectivePeriod,
      direction: effectiveDirection,
      child: props.child,
    );
  }
}

/// A simple shaped placeholder box intended for use inside a
/// [StreamSkeletonLoading].
///
/// Renders a filled rectangle (or circle) using
/// [StreamColorScheme.backgroundSurfaceStrong] as its default color.
///
/// {@tool snippet}
///
/// Compose with [StreamSkeletonLoading] to create loading placeholders:
///
/// ```dart
/// StreamSkeletonLoading(
///   child: Column(
///     children: [
///       StreamSkeletonBox(width: double.infinity, height: 16),
///       SizedBox(height: 8),
///       StreamSkeletonBox(width: 120, height: 16),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSkeletonLoading], which wraps children with a shimmer effect.
class StreamSkeletonBox extends StatelessWidget {
  /// Creates a skeleton placeholder box.
  const StreamSkeletonBox({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.shape = .rectangle,
    this.color,
  });

  /// Creates a circular skeleton placeholder.
  ///
  /// The resulting box has a diameter of `radius * 2`.
  const StreamSkeletonBox.circular({
    super.key,
    required double radius,
    this.color,
  }) : shape = .circle,
       width = radius * 2,
       height = radius * 2,
       borderRadius = null;

  /// The height of the placeholder.
  ///
  /// If null, the box sizes itself based on incoming constraints.
  final double? height;

  /// The width of the placeholder.
  ///
  /// If null, the box sizes itself based on incoming constraints.
  final double? width;

  /// The border radius of the placeholder.
  ///
  /// Ignored when [shape] is [BoxShape.circle].
  final BorderRadiusGeometry? borderRadius;

  /// The shape of the placeholder.
  ///
  /// Defaults to [BoxShape.rectangle].
  final BoxShape shape;

  /// The fill color of the placeholder.
  ///
  /// If null, uses [StreamColorScheme.backgroundSurfaceStrong].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final effectiveColor = color ?? colorScheme.backgroundSurfaceStrong;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        color: effectiveColor,
        borderRadius: borderRadius,
      ),
    );
  }
}

// Provides default values for [StreamSkeletonLoadingThemeData] based on the
// current [StreamColorScheme].
class _StreamSkeletonLoadingThemeDefaults extends StreamSkeletonLoadingThemeData {
  _StreamSkeletonLoadingThemeDefaults(this.context);

  final BuildContext context;

  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  // The shimmer package uses BlendMode.srcATop which replaces child pixels
  // with the gradient. The highlight color is brightness-aware: light mode
  // uses a semi-transparent white overlay, dark mode uses the deepest chrome
  // shade to create a subtle darkening sweep.
  //
  // NOTE: Component theme defaults should generally avoid depending on
  // [Theme.brightnessOf] and instead rely solely on [StreamColorScheme]
  // semantics. This is an exception because the chrome surface hierarchy
  // inverts between light and dark modes, so no single semantic color pair
  // produces the correct base→highlight contrast in both brightnesses.

  @override
  Color get baseColor => _colorScheme.backgroundSurfaceStrong;

  @override
  Color get highlightColor => _colorScheme.backgroundOverlayLight;

  @override
  Duration get period => const Duration(milliseconds: 1500);
}
