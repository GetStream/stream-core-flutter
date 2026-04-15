import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamJumpToUnreadButton,
  path: '[Components]/Buttons',
)
Widget buildStreamJumpToUnreadButtonPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatelessWidget {
  const _PlaygroundDemo();

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.string(
      label: 'Label',
      initialValue: '3 unread',
      description: 'The text displayed in the button.',
    );

    final showLeadingIcon = context.knobs.boolean(
      label: 'Custom Leading Icon',
      description: 'Use a custom leading icon instead of the default arrow.',
    );

    final showTrailingIcon = context.knobs.boolean(
      label: 'Custom Trailing Icon',
      description: 'Use a custom trailing icon instead of the default xmark.',
    );

    final isDisabled = context.knobs.boolean(
      label: 'Disabled',
      description: 'Whether the button is non-interactive.',
    );

    final elevation = context.knobs.double.slider(
      label: 'Elevation',
      initialValue: 3,
      max: 12,
      description: 'Material elevation of the pill container.',
    );

    return Center(
      child: StreamJumpToUnreadButtonTheme(
        data: StreamJumpToUnreadButtonThemeData(elevation: elevation),
        child: StreamJumpToUnreadButton(
          label: label,
          leadingIcon: showLeadingIcon ? Icons.arrow_downward : null,
          trailingIcon: showTrailingIcon ? Icons.visibility_off : null,
          onJumpPressed: isDisabled
              ? null
              : () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Jump to unread pressed!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                },
          onDismissPressed: isDisabled
              ? null
              : () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Dismiss pressed!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                },
        ),
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamJumpToUnreadButton,
  path: '[Components]/Buttons',
)
Widget buildStreamJumpToUnreadButtonShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xl,
        children: const [
          _DefaultSection(),
          _DisabledSection(),
          _LongLabelSection(),
          _ThemeOverrideSection(),
          _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Default Section
// =============================================================================

class _DefaultSection extends StatelessWidget {
  const _DefaultSection();

  @override
  Widget build(BuildContext context) {
    return _ShowcaseCard(
      title: 'DEFAULT',
      description: 'Standard jump-to-unread button with label and dismiss',
      child: StreamJumpToUnreadButton(
        label: '3 unread',
        onJumpPressed: () {},
        trailingIcon: context.streamIcons.xmark16,
        onDismissPressed: () {},
      ),
    );
  }
}

// =============================================================================
// Disabled Section
// =============================================================================

class _DisabledSection extends StatelessWidget {
  const _DisabledSection();

  @override
  Widget build(BuildContext context) {
    return _ShowcaseCard(
      title: 'DISABLED',
      description: 'Non-interactive state with both callbacks null',
      child: StreamJumpToUnreadButton(
        label: '3 unread',
        trailingIcon: context.streamIcons.xmark16,
      ),
    );
  }
}

// =============================================================================
// Long Label Section
// =============================================================================

class _LongLabelSection extends StatelessWidget {
  const _LongLabelSection();

  @override
  Widget build(BuildContext context) {
    return _ShowcaseCard(
      title: 'LONG LABEL',
      description: 'Behavior with longer text content',
      child: StreamJumpToUnreadButton(
        label: '128 unread messages',
        onJumpPressed: () {},
        trailingIcon: context.streamIcons.xmark16,
        onDismissPressed: () {},
      ),
    );
  }
}

// =============================================================================
// Theme Override Section
// =============================================================================

class _ThemeOverrideSection extends StatelessWidget {
  const _ThemeOverrideSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'THEME OVERRIDES'),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.lg),
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
            spacing: spacing.xl,
            children: const [
              _CustomColorsOverride(),
              _CustomShapeOverride(),
              _NoElevationOverride(),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomColorsOverride extends StatelessWidget {
  const _CustomColorsOverride();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        Text(
          'Custom colors',
          style: textTheme.captionEmphasis.copyWith(
            color: colorScheme.textPrimary,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          'Accent background with white foreground via theme',
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
          ),
        ),
        Center(
          child: StreamJumpToUnreadButtonTheme(
            data: StreamJumpToUnreadButtonThemeData(
              backgroundColor: colorScheme.accentPrimary,
              side: BorderSide.none,
              leadingStyle: StreamButtonThemeStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.textOnAccent),
              ),
              trailingStyle: StreamButtonThemeStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.textOnAccent),
              ),
            ),
            child: StreamJumpToUnreadButton(
              label: '3 unread',
              onJumpPressed: () {},
              trailingIcon: context.streamIcons.xmark16,
              onDismissPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomShapeOverride extends StatelessWidget {
  const _CustomShapeOverride();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        Text(
          'Custom shape & border',
          style: textTheme.captionEmphasis.copyWith(
            color: colorScheme.textPrimary,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          'Rounded rectangle with thicker border',
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
          ),
        ),
        Center(
          child: StreamJumpToUnreadButtonTheme(
            data: StreamJumpToUnreadButtonThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(radius.md),
              ),
              side: BorderSide(color: colorScheme.borderDefault, width: 2),
            ),
            child: StreamJumpToUnreadButton(
              label: '7 unread',
              onJumpPressed: () {},
              trailingIcon: context.streamIcons.xmark16,
              onDismissPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class _NoElevationOverride extends StatelessWidget {
  const _NoElevationOverride();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        Text(
          'No elevation',
          style: textTheme.captionEmphasis.copyWith(
            color: colorScheme.textPrimary,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          'Flat button without shadow',
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
          ),
        ),
        Center(
          child: StreamJumpToUnreadButtonTheme(
            data: const StreamJumpToUnreadButtonThemeData(elevation: 0),
            child: StreamJumpToUnreadButton(
              label: '12 unread',
              onJumpPressed: () {},
              trailingIcon: context.streamIcons.xmark16,
              onDismissPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Real-World Section
// =============================================================================

class _RealWorldSection extends StatelessWidget {
  const _RealWorldSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'REAL-WORLD EXAMPLE'),
        Container(
          width: double.infinity,
          height: 300,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
            boxShadow: boxShadow.elevation1,
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: const _MessageListMockup(),
        ),
      ],
    );
  }
}

class _MessageListMockup extends StatelessWidget {
  const _MessageListMockup();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.all(spacing.md),
          children: [
            for (var i = 0; i < 6; i++)
              Padding(
                padding: EdgeInsets.only(bottom: spacing.sm),
                child: Align(
                  alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 220),
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: i.isEven ? colorScheme.backgroundSurfaceSubtle : colorScheme.accentPrimary,
                      borderRadius: BorderRadius.all(radius.md),
                    ),
                    child: Text(
                      i.isEven ? 'Hey, how are you?' : "I'm good, thanks!",
                      style: textTheme.bodyDefault.copyWith(
                        color: i.isEven ? colorScheme.textPrimary : colorScheme.textOnAccent,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          top: spacing.sm,
          child: Center(
            child: StreamJumpToUnreadButton(
              label: '3 unread',
              onJumpPressed: () {},
              trailingIcon: context.streamIcons.xmark16,
              onDismissPressed: () {},
            ),
          ),
        ),
      ],
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
          padding: EdgeInsets.all(spacing.lg),
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
              SizedBox(height: spacing.lg),
              Center(child: child),
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
