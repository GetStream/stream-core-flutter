import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:svg_icon_widget/svg_icon_widget.dart';

import '../core/stream_icons.dart';

/// The home page content for the gallery.
/// Displayed when no component is selected in the sidebar.
class GalleryHomePage extends StatelessWidget {
  const GalleryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return ColoredBox(
      color: colorScheme.backgroundApp,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const _StreamLogo(),
                SizedBox(height: spacing.xl),

                // Title
                Text(
                  'Stream Design System',
                  style: textTheme.headingLg.copyWith(
                    color: colorScheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.sm),

                // Subtitle
                Text(
                  'A comprehensive design system for building beautiful, '
                  'consistent chat and activity feed experiences.',
                  style: textTheme.bodyDefault.copyWith(
                    color: colorScheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.xl),

                // Feature chips
                const _FeatureChips(),
                SizedBox(height: spacing.xl + spacing.lg),

                // Getting started hint
                const _GettingStartedHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StreamLogo extends StatelessWidget {
  const _StreamLogo();

  @override
  Widget build(BuildContext context) {
    return const SvgIcon(
      StreamSvgIcons.logo,
      size: 80,
    );
  }
}

class _FeatureChips extends StatelessWidget {
  const _FeatureChips();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      alignment: WrapAlignment.center,
      children: const [
        _FeatureChip(icon: Icons.palette_outlined, label: 'Themeable'),
        _FeatureChip(icon: Icons.dark_mode_outlined, label: 'Dark Mode'),
        _FeatureChip(icon: Icons.devices_outlined, label: 'Responsive'),
        _FeatureChip(icon: Icons.accessibility_new_outlined, label: 'Accessible'),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
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
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.textSecondary,
          ),
          SizedBox(width: spacing.xs),
          Text(
            label,
            style: textTheme.captionDefault.copyWith(
              color: colorScheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GettingStartedHint extends StatelessWidget {
  const _GettingStartedHint();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.accentPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(
          color: colorScheme.accentPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back,
            size: 18,
            color: colorScheme.accentPrimary,
          ),
          SizedBox(width: spacing.sm),
          Flexible(
            child: Text(
              'Select a component from the sidebar to get started',
              style: textTheme.captionDefault.copyWith(
                color: colorScheme.accentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
