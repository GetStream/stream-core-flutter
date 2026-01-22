import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(
  name: 'All Styles',
  type: StreamTextTheme,
  path: '[App Foundation]/Typography',
)
Widget buildStreamTextThemeShowcase(BuildContext context) {
  final streamTheme = StreamTheme.of(context);
  final textTheme = streamTheme.textTheme;
  final colorScheme = streamTheme.colorScheme;

  return DefaultTextStyle(
    style: TextStyle(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Type Scale
          _TypeScale(textTheme: textTheme, colorScheme: colorScheme),
          const SizedBox(height: 32),

          // Complete Reference
          _CompleteReference(textTheme: textTheme, colorScheme: colorScheme),
        ],
      ),
    ),
  );
}

/// Visual type scale showing hierarchy at a glance
class _TypeScale extends StatelessWidget {
  const _TypeScale({required this.textTheme, required this.colorScheme});

  final StreamTextTheme textTheme;
  final StreamColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'TYPE SCALE', colorScheme: colorScheme),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.backgroundSurface,
                colorScheme.backgroundSurfaceSubtle,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.borderSurfaceSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ScaleItem(
                label: 'Heading Lg',
                style: textTheme.headingLg,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              _ScaleItem(
                label: 'Heading Md',
                style: textTheme.headingMd,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              _ScaleItem(
                label: 'Heading Sm',
                style: textTheme.headingSm,
                colorScheme: colorScheme,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: colorScheme.borderSurfaceSubtle),
              ),
              _ScaleItem(
                label: 'Body',
                style: textTheme.bodyDefault,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              _ScaleItem(
                label: 'Caption',
                style: textTheme.captionDefault,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              _ScaleItem(
                label: 'Metadata',
                style: textTheme.metadataDefault,
                colorScheme: colorScheme,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: colorScheme.borderSurfaceSubtle),
              ),
              _ScaleItem(
                label: 'Numeric Lg',
                style: textTheme.numericLg,
                colorScheme: colorScheme,
                sampleText: '1,234',
              ),
              const SizedBox(height: 12),
              _ScaleItem(
                label: 'Numeric Md',
                style: textTheme.numericMd,
                colorScheme: colorScheme,
                sampleText: '99+',
              ),
              const SizedBox(height: 12),
              _ScaleItem(
                label: 'Numeric Sm',
                style: textTheme.numericSm,
                colorScheme: colorScheme,
                sampleText: '5',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScaleItem extends StatelessWidget {
  const _ScaleItem({
    required this.label,
    required this.style,
    required this.colorScheme,
    this.sampleText,
  });

  final String label;
  final TextStyle style;
  final StreamColorScheme colorScheme;
  final String? sampleText;

  @override
  Widget build(BuildContext context) {
    final size = style.fontSize?.toInt() ?? 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 32,
          child: Text(
            '$size',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: colorScheme.textTertiary,
            ),
          ),
        ),
        Container(
          width: 3,
          height: size.toDouble().clamp(8, 40),
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: colorScheme.accentPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Text(
            sampleText ?? 'The quick brown fox jumps over',
            style: style.copyWith(color: colorScheme.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: colorScheme.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Complete reference table
class _CompleteReference extends StatelessWidget {
  const _CompleteReference({
    required this.textTheme,
    required this.colorScheme,
  });

  final StreamTextTheme textTheme;
  final StreamColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final styles = [
      ('headingLg', textTheme.headingLg, 'Page titles'),
      ('headingMd', textTheme.headingMd, 'Section headers'),
      ('headingSm', textTheme.headingSm, 'Card titles'),
      ('bodyDefault', textTheme.bodyDefault, 'Paragraphs'),
      ('bodyEmphasis', textTheme.bodyEmphasis, 'Important text'),
      ('bodyLink', textTheme.bodyLink, 'Links'),
      ('bodyLinkEmphasis', textTheme.bodyLinkEmphasis, 'Bold links'),
      ('captionDefault', textTheme.captionDefault, 'Labels'),
      ('captionEmphasis', textTheme.captionEmphasis, 'Bold labels'),
      ('captionLink', textTheme.captionLink, 'Small links'),
      ('captionLinkEmphasis', textTheme.captionLinkEmphasis, 'Bold small links'),
      ('metadataDefault', textTheme.metadataDefault, 'Timestamps'),
      ('metadataEmphasis', textTheme.metadataEmphasis, 'Bold metadata'),
      ('metadataLink', textTheme.metadataLink, 'Tiny links'),
      ('metadataLinkEmphasis', textTheme.metadataLinkEmphasis, 'Bold tiny links'),
      ('numericLg', textTheme.numericLg, 'Counters'),
      ('numericMd', textTheme.numericMd, 'Badges'),
      ('numericSm', textTheme.numericSm, 'Indicators'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'REFERENCE', colorScheme: colorScheme),
        const SizedBox(height: 16),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.borderSurfaceSubtle),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.backgroundSurfaceSubtle,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Name',
                        style: textTheme.metadataEmphasis.copyWith(
                          color: colorScheme.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Size',
                        style: textTheme.metadataEmphasis.copyWith(
                          color: colorScheme.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Weight',
                        style: textTheme.metadataEmphasis.copyWith(
                          color: colorScheme.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Use',
                        style: textTheme.metadataEmphasis.copyWith(
                          color: colorScheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              ...styles.asMap().entries.map((entry) {
                final (name, style, usage) = entry.value;
                final isLast = entry.key == styles.length - 1;
                return _ReferenceRow(
                  name: name,
                  style: style,
                  usage: usage,
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  showBorder: !isLast,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  const _ReferenceRow({
    required this.name,
    required this.style,
    required this.usage,
    required this.textTheme,
    required this.colorScheme,
    required this.showBorder,
  });

  final String name;
  final TextStyle style;
  final String usage;
  final StreamTextTheme textTheme;
  final StreamColorScheme colorScheme;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final size = style.fontSize?.toInt() ?? 0;
    final weight = _weightName(style.fontWeight);

    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: 'textTheme.$name'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied: textTheme.$name'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: showBorder ? Border(bottom: BorderSide(color: colorScheme.borderSurfaceSubtle)) : null,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.copy,
                    size: 10,
                    color: colorScheme.textTertiary,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${size}px',
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                weight,
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                usage,
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weightName(FontWeight? weight) {
    return switch (weight) {
      FontWeight.w400 => 'Regular',
      FontWeight.w500 => 'Medium',
      FontWeight.w600 => 'Semi',
      FontWeight.w700 => 'Bold',
      _ => '${weight?.value ?? "?"}',
    };
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.colorScheme});

  final String label;
  final StreamColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.accentPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: colorScheme.textOnAccent,
        ),
      ),
    );
  }
}
