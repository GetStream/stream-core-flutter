import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Returns a typical file extension for the given file type.
String _getExtension(StreamFileType fileType) {
  return switch (fileType) {
    StreamFileType.pdf => 'pdf',
    StreamFileType.text => 'doc',
    StreamFileType.presentation => 'ppt',
    StreamFileType.spreadsheet => 'xls',
    StreamFileType.code => 'dart',
    StreamFileType.video => 'mp4',
    StreamFileType.audio => 'mp3',
    StreamFileType.compression => 'zip',
    StreamFileType.other => 'wkq',
  };
}

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamFileTypeIcon,
  path: '[Components]/Accessories',
)
Widget buildFileTypeIconPlayground(BuildContext context) {
  final fileType = context.knobs.object.dropdown(
    label: 'File Type',
    options: StreamFileType.values,
    initialOption: StreamFileType.pdf,
    labelBuilder: (option) => option.name,
    description: 'The file type determines which icon is shown.',
  );

  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: StreamFileTypeIconSize.values,
    initialOption: StreamFileTypeIconSize.s40,
    labelBuilder: (option) => option.name,
    description: 'Icon size preset.',
  );

  final extension = context.knobs.string(
    label: 'Extension',
    initialValue: 'pdf',
    description: 'File extension text displayed on the icon (e.g., pdf, doc, mp4).',
  );

  return Center(
    child: StreamFileTypeIcon(
      type: fileType,
      size: size,
      extension: extension.isNotEmpty ? extension : null,
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamFileTypeIcon,
  path: '[Components]/Accessories',
)
Widget buildFileTypeIconShowcase(BuildContext context) {
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
          // File type variants
          const _FileTypeVariantsSection(),
          SizedBox(height: spacing.xl),

          // Size variants
          const _SizeVariantsSection(),
          SizedBox(height: spacing.xl),

          // Quick reference
          const _QuickReferenceSection(),
          SizedBox(height: spacing.xl),

          // Usage patterns
          const _UsagePatternsSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// File Type Variants Section
// =============================================================================

class _FileTypeVariantsSection extends StatelessWidget {
  const _FileTypeVariantsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'FILE TYPES'),
        SizedBox(height: spacing.md),
        ...StreamFileType.values.map((fileType) => _FileTypeCard(fileType: fileType)),
      ],
    );
  }
}

class _FileTypeCard extends StatelessWidget {
  const _FileTypeCard({required this.fileType});

  final StreamFileType fileType;

  String _getDescription(StreamFileType fileType) {
    return switch (fileType) {
      StreamFileType.pdf => 'PDF documents (.pdf)',
      StreamFileType.text => 'Text documents (.doc, .docx, .txt, .rtf)',
      StreamFileType.presentation => 'Presentations (.ppt, .pptx, .key)',
      StreamFileType.spreadsheet => 'Spreadsheets (.xls, .xlsx, .csv)',
      StreamFileType.code => 'Code files (.js, .py, .dart, .html)',
      StreamFileType.video => 'Video files (.mp4, .mov, .avi)',
      StreamFileType.audio => 'Audio files (.mp3, .wav, .aac)',
      StreamFileType.compression => 'Archives (.zip, .rar, .7z, .tar)',
      StreamFileType.other => 'Other file types',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: colorScheme.backgroundSurface,
          borderRadius: BorderRadius.all(radius.lg),
          boxShadow: boxShadow.elevation1,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius.lg),
          border: Border.all(color: colorScheme.borderSurfaceSubtle),
        ),
        child: Row(
          children: [
            // Icon preview
            SizedBox(
              width: 80,
              height: 80,
              child: Center(
                child: StreamFileTypeIcon(
                  type: fileType,
                  size: StreamFileTypeIconSize.s48,
                  extension: _getExtension(fileType),
                ),
              ),
            ),
            SizedBox(width: spacing.md + spacing.xs),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'StreamFileType.${fileType.name}',
                    style: textTheme.captionEmphasis.copyWith(
                      color: colorScheme.accentPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: spacing.xs + spacing.xxs),
                  Text(
                    _getDescription(fileType),
                    style: textTheme.captionDefault.copyWith(
                      color: colorScheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Size Variants Section
// =============================================================================

class _SizeVariantsSection extends StatelessWidget {
  const _SizeVariantsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'SIZE SCALE'),
        SizedBox(height: spacing.md),
        ...StreamFileTypeIconSize.values.map((size) => _SizeCard(size: size)),
      ],
    );
  }
}

class _SizeCard extends StatelessWidget {
  const _SizeCard({required this.size});

  final StreamFileTypeIconSize size;

  String _getDimensions(StreamFileTypeIconSize size) {
    return switch (size) {
      StreamFileTypeIconSize.s48 => '40×48',
      StreamFileTypeIconSize.s40 => '32×40',
    };
  }

  String _getUsage(StreamFileTypeIconSize size) {
    return switch (size) {
      StreamFileTypeIconSize.s48 => 'File previews, galleries, detail views',
      StreamFileTypeIconSize.s40 => 'List items, compact views, messages',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: colorScheme.backgroundSurface,
          borderRadius: BorderRadius.all(radius.lg),
          boxShadow: boxShadow.elevation1,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius.lg),
          border: Border.all(color: colorScheme.borderSurfaceSubtle),
        ),
        child: Row(
          children: [
            // Icon preview
            SizedBox(
              width: 80,
              height: 80,
              child: Center(
                child: StreamFileTypeIcon(
                  type: StreamFileType.pdf,
                  size: size,
                  extension: 'pdf',
                ),
              ),
            ),
            SizedBox(width: spacing.md + spacing.xs),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'StreamFileTypeIconSize.${size.name}',
                        style: textTheme.captionEmphasis.copyWith(
                          color: colorScheme.accentPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.xs + spacing.xxs,
                          vertical: spacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.backgroundSurfaceSubtle,
                          borderRadius: BorderRadius.all(radius.xs),
                        ),
                        child: Text(
                          _getDimensions(size),
                          style: textTheme.metadataEmphasis.copyWith(
                            color: colorScheme.textSecondary,
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.xs + spacing.xxs),
                  Text(
                    _getUsage(size),
                    style: textTheme.captionDefault.copyWith(
                      color: colorScheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Quick Reference Section
// =============================================================================

class _QuickReferenceSection extends StatelessWidget {
  const _QuickReferenceSection();

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
        const _SectionLabel(label: 'QUICK REFERENCE'),
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
            border: Border.all(color: colorScheme.borderSurfaceSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Creating from MIME type',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                'Use the factory constructor to automatically resolve icon and extension:',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              // MIME type examples
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: const [
                  _MimeTypeExample(mimeType: 'application/pdf'),
                  _MimeTypeExample(mimeType: 'audio/mpeg'),
                  _MimeTypeExample(mimeType: 'video/mp4'),
                  _MimeTypeExample(mimeType: 'application/zip'),
                ],
              ),
              SizedBox(height: spacing.md),
              Divider(color: colorScheme.borderSurfaceSubtle),
              SizedBox(height: spacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 14,
                    color: colorScheme.textTertiary,
                  ),
                  SizedBox(width: spacing.xs + spacing.xxs),
                  Expanded(
                    child: Text(
                      'StreamFileTypeIcon.fromMimeType(mimeType: "...")',
                      style: textTheme.metadataDefault.copyWith(
                        color: colorScheme.accentPrimary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MimeTypeExample extends StatelessWidget {
  const _MimeTypeExample({required this.mimeType});

  final String mimeType;

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
        borderRadius: BorderRadius.all(radius.sm),
        border: Border.all(color: colorScheme.borderSurfaceSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamFileTypeIcon.fromMimeType(mimeType: mimeType),
          SizedBox(width: spacing.sm),
          Text(
            mimeType,
            style: textTheme.metadataDefault.copyWith(
              color: colorScheme.textPrimary,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Usage Patterns Section
// =============================================================================

class _UsagePatternsSection extends StatelessWidget {
  const _UsagePatternsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'USAGE PATTERNS'),
        SizedBox(height: spacing.md),

        // File attachment list example
        _ExampleCard(
          title: 'File Attachment List',
          description: 'Display uploaded files with type indicators',
          child: Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                _FileListItem(
                  fileType: [StreamFileType.pdf, StreamFileType.spreadsheet, StreamFileType.compression][i],
                  fileName: ['Report_Q4_2024.pdf', 'Budget_2024.xlsx', 'project_assets.zip'][i],
                  fileSize: ['2.4 MB', '1.2 MB', '45.8 MB'][i],
                ),
                if (i < 2) SizedBox(height: spacing.sm),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.sm),

        // File grid example
        _ExampleCard(
          title: 'File Grid',
          description: 'Gallery view for file browsing',
          child: Wrap(
            spacing: spacing.md,
            runSpacing: spacing.md,
            children: [
              for (final fileType in [
                StreamFileType.pdf,
                StreamFileType.video,
                StreamFileType.audio,
                StreamFileType.code,
              ])
                _FileGridItem(fileType: fileType),
            ],
          ),
        ),
        SizedBox(height: spacing.sm),

        // Message attachment example
        const _ExampleCard(
          title: 'Message Attachment',
          description: 'File shared in a chat conversation',
          child: _MessageAttachmentExample(),
        ),
      ],
    );
  }
}

class _MessageAttachmentExample extends StatelessWidget {
  const _MessageAttachmentExample();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.borderSurfaceSubtle),
      ),
      child: Row(
        children: [
          StreamFileTypeIcon(
            type: StreamFileType.presentation,
            size: StreamFileTypeIconSize.s48,
            extension: 'pptx',
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Q4_Presentation_Final.pptx',
                  style: textTheme.captionEmphasis.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xxs),
                Text(
                  '4.8 MB • Tap to download',
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          Icon(
            Icons.download_outlined,
            size: 20,
            color: colorScheme.accentPrimary,
          ),
        ],
      ),
    );
  }
}

class _FileListItem extends StatelessWidget {
  const _FileListItem({
    required this.fileType,
    required this.fileName,
    required this.fileSize,
  });

  final StreamFileType fileType;
  final String fileName;
  final String fileSize;

  String? _extractExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Row(
      children: [
        StreamFileTypeIcon(
          type: fileType,
          extension: _extractExtension(fileName),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fileName,
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                fileSize,
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FileGridItem extends StatelessWidget {
  const _FileGridItem({required this.fileType});

  final StreamFileType fileType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      width: 72,
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamFileTypeIcon(
            type: fileType,
            size: StreamFileTypeIconSize.s48,
            extension: _getExtension(fileType),
          ),
          SizedBox(height: spacing.xs),
          Text(
            fileType.name,
            style: textTheme.metadataDefault.copyWith(
              color: colorScheme.textSecondary,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
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

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.lg),
        boxShadow: boxShadow.elevation1,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSurfaceSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.captionEmphasis.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.borderSurfaceSubtle,
          ),
          // Content
          Container(
            padding: EdgeInsets.all(spacing.md),
            color: colorScheme.backgroundSurface,
            child: child,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

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
