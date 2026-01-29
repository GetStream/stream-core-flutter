import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Returns a typical file extension for the given category.
String _getExtension(FileTypeCategory category) {
  return switch (category) {
    FileTypeCategory.pdf => 'pdf',
    FileTypeCategory.text => 'doc',
    FileTypeCategory.presentation => 'ppt',
    FileTypeCategory.spreadsheet => 'xls',
    FileTypeCategory.code => 'dart',
    FileTypeCategory.video => 'mp4',
    FileTypeCategory.audio => 'mp3',
    FileTypeCategory.compression => 'zip',
    FileTypeCategory.other => 'wkq',
  };
}

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: FileTypeIcon,
  path: '[Components]/Accessories/File Type Icon',
)
Widget buildFileTypeIconPlayground(BuildContext context) {
  final category = context.knobs.object.dropdown(
    label: 'Category',
    options: FileTypeCategory.values,
    initialOption: FileTypeCategory.pdf,
    labelBuilder: (option) => option.name,
    description: 'The file type category determines which icon is shown.',
  );

  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: FileTypeIconSize.values,
    initialOption: FileTypeIconSize.s40,
    labelBuilder: (option) => option.name,
    description: 'Icon size preset.',
  );

  final extension = context.knobs.string(
    label: 'Extension',
    initialValue: 'pdf',
    description: 'File extension text displayed on the icon (e.g., pdf, doc, mp4).',
  );

  return Center(
    child: FileTypeIcon(
      category: category,
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
  type: FileTypeIcon,
  path: '[Components]/Accessories/File Type Icon',
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
          // Category variants
          const _CategoryVariantsSection(),
          SizedBox(height: spacing.xl),

          // Size variants
          const _SizeVariantsSection(),
          SizedBox(height: spacing.xl),

          // Usage patterns
          const _UsagePatternsSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// MIME Types
// =============================================================================

/// All supported MIME types grouped by category.
const _supportedMimeTypes = <FileTypeCategory, List<String>>{
  FileTypeCategory.pdf: [
    'application/pdf',
  ],
  FileTypeCategory.audio: [
    'audio/mpeg',
    'audio/aac',
    'audio/wav',
    'audio/x-wav',
    'audio/flac',
    'audio/mp4',
    'audio/ogg',
    'audio/aiff',
    'audio/alac',
  ],
  FileTypeCategory.compression: [
    'application/zip',
    'application/x-7z-compressed',
    'application/x-arj',
    'application/vnd.debian.binary-package',
    'application/x-apple-diskimage',
    'application/x-rar-compressed',
    'application/x-rpm',
    'application/x-compress',
  ],
  FileTypeCategory.presentation: [
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.apple.keynote',
    'application/vnd.oasis.opendocument.presentation',
  ],
  FileTypeCategory.spreadsheet: [
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-excel.sheet.macroEnabled.12',
    'application/vnd.oasis.opendocument.spreadsheet',
  ],
  FileTypeCategory.text: [
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.oasis.opendocument.text',
    'text/plain',
    'application/rtf',
    'application/x-tex',
    'application/vnd.wordperfect',
  ],
  FileTypeCategory.code: [
    'text/html',
    'text/csv',
    'application/xml',
    'text/markdown',
    'application/x-tar',
  ],
  FileTypeCategory.other: [
    'application/x-wiki',
    'application/octet-stream',
  ],
};

@widgetbook.UseCase(
  name: 'MIME Types',
  type: FileTypeIcon,
  path: '[Components]/Accessories/File Type Icon',
)
Widget buildFileTypeIconMimeTypes(BuildContext context) {
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
          Text(
            'Supported MIME Types',
            style: textTheme.headingSm.copyWith(color: colorScheme.textPrimary),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Use FileTypeIcon.fromMimeType() to automatically resolve the icon and extension from a MIME type.',
            style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
          ),
          SizedBox(height: spacing.lg),
          for (final category in _supportedMimeTypes.keys) ...[
            _MimeTypeCategorySection(
              category: category,
              mimeTypes: _supportedMimeTypes[category]!,
            ),
            SizedBox(height: spacing.lg),
          ],
        ],
      ),
    ),
  );
}

class _MimeTypeCategorySection extends StatelessWidget {
  const _MimeTypeCategorySection({
    required this.category,
    required this.mimeTypes,
  });

  final FileTypeCategory category;
  final List<String> mimeTypes;

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
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.md),
            color: colorScheme.backgroundSurfaceSubtle,
            child: Row(
              children: [
                FileTypeIcon(
                  category: category,
                  extension: _getExtension(category),
                ),
                SizedBox(width: spacing.sm),
                Text(
                  category.name.toUpperCase(),
                  style: textTheme.captionEmphasis.copyWith(
                    color: colorScheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.xs + spacing.xxs,
                    vertical: spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.accentPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.all(radius.xs),
                  ),
                  child: Text(
                    '${mimeTypes.length} types',
                    style: textTheme.metadataEmphasis.copyWith(
                      color: colorScheme.accentPrimary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // MIME type list
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: mimeTypes.map((mimeType) => _MimeTypeChip(mimeType: mimeType)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MimeTypeChip extends StatelessWidget {
  const _MimeTypeChip({required this.mimeType});

  final String mimeType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final (_, extension) = FileTypeIcon.getExtension(mimeType);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
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
            FileTypeIcon.fromMimeType(mimeType: mimeType),
            SizedBox(width: spacing.sm),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mimeType,
                    style: textTheme.metadataDefault.copyWith(
                      color: colorScheme.textPrimary,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (extension != null)
                    Text(
                      '.$extension',
                      style: textTheme.metadataEmphasis.copyWith(
                        color: colorScheme.accentPrimary,
                        fontFamily: 'monospace',
                        fontSize: 10,
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
// Category Variants Section
// =============================================================================

class _CategoryVariantsSection extends StatelessWidget {
  const _CategoryVariantsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'FILE TYPE CATEGORIES'),
        SizedBox(height: spacing.md),
        ...FileTypeCategory.values.map((category) => _CategoryCard(category: category)),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final FileTypeCategory category;

  String _getDescription(FileTypeCategory category) {
    return switch (category) {
      FileTypeCategory.pdf => 'PDF documents (.pdf)',
      FileTypeCategory.text => 'Text documents (.doc, .docx, .txt, .rtf)',
      FileTypeCategory.presentation => 'Presentations (.ppt, .pptx, .key)',
      FileTypeCategory.spreadsheet => 'Spreadsheets (.xls, .xlsx, .csv)',
      FileTypeCategory.code => 'Code files (.js, .py, .dart, .html)',
      FileTypeCategory.video => 'Video files (.mp4, .mov, .avi)',
      FileTypeCategory.audio => 'Audio files (.mp3, .wav, .aac)',
      FileTypeCategory.compression => 'Archives (.zip, .rar, .7z, .tar)',
      FileTypeCategory.other => 'Other file types',
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
                child: FileTypeIcon(
                  category: category,
                  size: FileTypeIconSize.s48,
                  extension: _getExtension(category),
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
                    'FileTypeCategory.${category.name}',
                    style: textTheme.captionEmphasis.copyWith(
                      color: colorScheme.accentPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: spacing.xs + spacing.xxs),
                  Text(
                    _getDescription(category),
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
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'SIZE SCALE'),
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
                'Available icon sizes for different use cases',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: FileTypeIconSize.values.map((size) => _SizeItem(size: size)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SizeItem extends StatelessWidget {
  const _SizeItem({required this.size});

  final FileTypeIconSize size;

  String _getDimensions(FileTypeIconSize size) {
    return switch (size) {
      FileTypeIconSize.s48 => '40×48',
      FileTypeIconSize.s40 => '32×40',
    };
  }

  String _getUsage(FileTypeIconSize size) {
    return switch (size) {
      FileTypeIconSize.s48 => 'File previews, galleries',
      FileTypeIconSize.s40 => 'List items, compact views',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FileTypeIcon(
          category: FileTypeCategory.pdf,
          size: size,
          extension: 'pdf',
        ),
        SizedBox(height: spacing.sm),
        Text(
          'FileTypeIconSize.${size.name}',
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
            fontSize: 10,
          ),
        ),
        SizedBox(height: spacing.xxs),
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
            style: textTheme.metadataDefault.copyWith(
              color: colorScheme.textSecondary,
              fontFamily: 'monospace',
              fontSize: 10,
            ),
          ),
        ),
        SizedBox(height: spacing.xs),
        Text(
          _getUsage(size),
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
                  category: [FileTypeCategory.pdf, FileTypeCategory.spreadsheet, FileTypeCategory.compression][i],
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
              for (final category in [
                FileTypeCategory.pdf,
                FileTypeCategory.video,
                FileTypeCategory.audio,
                FileTypeCategory.code,
              ])
                _FileGridItem(category: category),
            ],
          ),
        ),
      ],
    );
  }
}

class _FileListItem extends StatelessWidget {
  const _FileListItem({
    required this.category,
    required this.fileName,
    required this.fileSize,
  });

  final FileTypeCategory category;
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
        FileTypeIcon(
          category: category,
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
  const _FileGridItem({required this.category});

  final FileTypeCategory category;

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
          FileTypeIcon(
            category: category,
            size: FileTypeIconSize.s48,
            extension: _getExtension(category),
          ),
          SizedBox(height: spacing.xs),
          Text(
            category.name,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
