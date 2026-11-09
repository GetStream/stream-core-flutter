import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamBanner,
  path: '[Components]/Banner',
)
Widget buildStreamBannerPlayground(BuildContext context) {
  final type = context.knobs.object.dropdown<StreamBannerType>(
    label: 'Type',
    options: StreamBannerType.values,
    initialOption: StreamBannerType.loading,
    labelBuilder: (option) => option.name.toUpperCase(),
    description: 'The kind of state, which picks the icon.',
  );

  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Waiting for network…',
    description: 'The message describing the state.',
  );

  final showIcon = context.knobs.boolean(
    label: 'Show Icon',
    initialValue: true,
    description: 'Whether to show the leading icon.',
  );

  final customIcon = context.knobs.boolean(
    label: 'Custom Icon',
    description: 'Whether to replace the default icon for the type.',
  );

  return Center(
    child: StreamBanner(
      type: type,
      title: Text(title),
      icon: customIcon ? Icon(context.streamIcons.clockFill) : null,
      showIcon: showIcon,
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamBanner,
  path: '[Components]/Banner',
)
Widget buildStreamBannerShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(
            label: 'TYPES',
            caption: 'Neutral surface, centered content, for every type',
            children: [
              for (final type in StreamBannerType.values)
                StreamBanner(type: type, title: Text('${type.name} · Waiting for network…')),
            ],
          ),
          SizedBox(height: spacing.xl),
          _Section(
            label: 'LONG TITLE',
            caption: 'The title wraps and stays centered',
            children: [
              StreamBanner(
                type: StreamBannerType.error,
                title: const Text(
                  "Couldn't load content because the connection dropped while it was being fetched",
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xl),
          _Section(
            label: 'IN CONTEXT',
            caption: 'A lost connection, and content that failed to load',
            children: [
              StreamBanner(type: StreamBannerType.loading, title: const Text('Waiting for network…')),
              StreamBanner(type: StreamBannerType.error, title: const Text("Couldn't load content")),
            ],
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.caption, required this.children});

  final String label;
  final String caption;
  final List<Widget> children;

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
        _SectionLabel(label: label),
        SizedBox(height: spacing.md),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.backgroundElevation1,
            borderRadius: BorderRadius.all(radius.lg),
            boxShadow: boxShadow.elevation1,
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing.sm,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(spacing.md, spacing.md, spacing.md, 0),
                child: Text(caption, style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary)),
              ),
              ...children,
              const SizedBox.shrink(),
            ],
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
      padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
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
