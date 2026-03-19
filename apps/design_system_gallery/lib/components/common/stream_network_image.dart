import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _kValidUrl = 'https://picsum.photos/seed/stream/400/300';
const _kInvalidUrl = 'https://invalid.test/does-not-exist.jpg';

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamNetworkImage,
  path: '[Components]/Common',
)
Widget buildStreamNetworkImagePlayground(BuildContext context) {
  final fit = context.knobs.object.dropdown<BoxFit>(
    label: 'Fit',
    options: BoxFit.values,
    initialOption: BoxFit.cover,
    labelBuilder: (option) => option.name,
    description: 'How the image should fill its bounds.',
  );

  final width = context.knobs.double.slider(
    label: 'Width',
    initialValue: 300,
    min: 100,
    max: 500,
    description: 'The width of the image.',
  );

  final height = context.knobs.double.slider(
    label: 'Height',
    initialValue: 200,
    min: 100,
    max: 500,
    description: 'The height of the image.',
  );

  final clearCache = context.knobs.boolean(
    label: 'Clear Cache',
    description: 'Evict the demo image from cache.',
  );

  if (clearCache) {
    // ignore: invalid_use_of_visible_for_testing_member
    StreamNetworkImage.evictFromCache(_kValidUrl);
  }

  final colorScheme = context.streamColorScheme;
  final radius = context.streamRadius;

  return Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(radius.md),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.backgroundElevation2,
                borderRadius: BorderRadius.all(radius.md),
              ),
              child: StreamNetworkImage(
                _kValidUrl,
                width: width,
                height: height,
                fit: fit,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamNetworkImage,
  path: '[Components]/Common',
)
Widget buildStreamNetworkImageShowcase(BuildContext context) {
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: context.streamTextTheme.bodyDefault.copyWith(
      color: context.streamColorScheme.textPrimary,
    ),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FitVariantsSection(),
          SizedBox(height: spacing.xl),
          const _CustomBuildersSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Fit Variants Section
// =============================================================================

class _FitVariantsSection extends StatelessWidget {
  const _FitVariantsSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    const fits = [
      BoxFit.cover,
      BoxFit.contain,
      BoxFit.fill,
      BoxFit.fitWidth,
      BoxFit.fitHeight,
      BoxFit.scaleDown,
    ];

    return _ShowcaseCard(
      title: 'FIT VARIANTS',
      description:
          'A tall source image (200x400) in a wide container '
          'to highlight differences between each BoxFit mode.',
      child: Wrap(
        spacing: spacing.md,
        runSpacing: spacing.lg,
        children: [
          for (final fit in fits)
            _ImageDemo(
              label: fit.name,
              child: Container(
                width: 140,
                height: 100,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(radius.md),
                  border: Border.all(color: colorScheme.borderSubtle),
                  color: colorScheme.backgroundElevation2,
                ),
                child: StreamNetworkImage(
                  'https://picsum.photos/seed/fit-demo/200/400',
                  width: 140,
                  height: 100,
                  fit: fit,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Custom Builders Section
// =============================================================================

class _CustomBuildersSection extends StatelessWidget {
  const _CustomBuildersSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return _ShowcaseCard(
      title: 'CUSTOM BUILDERS',
      description:
          'Custom placeholder and error builders. '
          'Tap the error widget to retry.',
      child: Wrap(
        spacing: spacing.md,
        runSpacing: spacing.md,
        children: [
          _ImageDemo(
            label: 'Custom error',
            child: _TapToReloadDemo(
              width: 140,
              height: 100,
              errorBuilder: (context, error, retry) => Container(
                width: 140,
                height: 100,
                color: colorScheme.backgroundElevation2,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 24,
                        color: colorScheme.textTertiary,
                      ),
                      SizedBox(height: spacing.xs),
                      GestureDetector(
                        onTap: retry,
                        child: Text(
                          'Tap to retry',
                          style: textTheme.metadataEmphasis.copyWith(
                            color: colorScheme.accentPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _ImageDemo(
            label: 'Custom placeholder',
            child: ClipRRect(
              borderRadius: BorderRadius.all(radius.md),
              child: StreamNetworkImage(
                'https://picsum.photos/seed/custom-placeholder/300/200',
                width: 140,
                height: 100,
                fit: BoxFit.cover,
                placeholderBuilder: (context) => Container(
                  width: 140,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.backgroundElevation2,
                        colorScheme.backgroundElevation3,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 28,
                      color: colorScheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Tap to Reload Demo
// =============================================================================

/// Shows an invalid URL to demonstrate error state and tap-to-reload.
///
/// When a custom [errorBuilder] is provided, it wraps the retry callback
/// to switch to a valid URL on tap, demonstrating the full
/// error -> retry -> success flow.
///
/// When no [errorBuilder] is provided, the default error widget is used
/// and retry simply re-fetches the same URL.
class _TapToReloadDemo extends StatefulWidget {
  const _TapToReloadDemo({
    required this.width,
    required this.height,
    this.errorBuilder,
  });

  final double width;
  final double height;
  final StreamNetworkImageErrorBuilder? errorBuilder;

  @override
  State<_TapToReloadDemo> createState() => _TapToReloadDemoState();
}

class _TapToReloadDemoState extends State<_TapToReloadDemo> {
  var _useValidUrl = false;

  String get _url => _useValidUrl ? 'https://picsum.photos/seed/retry-success/300/200' : _kInvalidUrl;

  void _onRetry(VoidCallback retry) {
    setState(() => _useValidUrl = true);
    retry();
  }

  @override
  Widget build(BuildContext context) {
    final radius = context.streamRadius;

    return ClipRRect(
      borderRadius: BorderRadius.all(radius.md),
      child: StreamNetworkImage(
        _url,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        errorBuilder: widget.errorBuilder != null
            ? (context, error, retry) => widget.errorBuilder!(context, error, () => _onRetry(retry))
            : null,
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: title),
        SizedBox(height: spacing.md),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
            boxShadow: boxShadow.elevation1,
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageDemo extends StatelessWidget {
  const _ImageDemo({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        SizedBox(height: spacing.sm),
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.accentPrimary,
        borderRadius: BorderRadius.all(radius.xs),
      ),
      child: Text(
        label,
        style: textTheme.metadataEmphasis.copyWith(
          color: colorScheme.textOnAccent,
          letterSpacing: 1,
          fontSize: 9,
        ),
      ),
    );
  }
}
