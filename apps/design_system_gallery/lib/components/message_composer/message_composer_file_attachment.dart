import 'package:material_ui/material_ui.dart';
import 'package:stream_core_flutter/chat.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageComposerFileAttachment,
  path: '[Components]/Message Composer',
)
Widget buildStreamMessageComposerFileAttachmentPlayground(BuildContext context) {
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'quarterly_report.pdf',
    description: 'The file name displayed in the attachment.',
  );

  final fileType = context.knobs.object.dropdown<StreamFileType>(
    label: 'File Type',
    options: StreamFileType.values,
    initialOption: StreamFileType.pdf,
    labelBuilder: (v) => v.name,
    description: 'Determines which icon is shown.',
  );

  final showSubtitle = context.knobs.boolean(
    label: 'Show Subtitle',
    initialValue: true,
    description: 'Toggle a subtitle (e.g. file size).',
  );

  final showRemoveButton = context.knobs.boolean(
    label: 'Show Remove Button',
    initialValue: true,
    description: 'Toggle the remove attachment control.',
  );

  final maxWidth = context.knobs.double.slider(
    label: 'Parent Max Width',
    initialValue: 320,
    min: 150,
    max: 500,
    description: 'Bounds the parent width. Values below 260 force the row to shrink below its natural maximum.',
  );

  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: StreamMessageComposerFileAttachment(
        fileTypeIcon: StreamFileTypeIcon(type: fileType),
        title: Text(title),
        subtitle: showSubtitle
            ? Text(
                '2.4 MB',
                style: context.streamTextTheme.metadataDefault.copyWith(color: context.streamColorScheme.textTertiary),
              )
            : null,
        onRemovePressed: showRemoveButton ? () {} : null,
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamMessageComposerFileAttachment,
  path: '[Components]/Message Composer',
)
Widget buildStreamMessageComposerFileAttachmentShowcase(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        _FileTypesSection(),
        _WithSubtitleSection(),
        _ConstrainedSection(),
      ],
    ),
  );
}

// =============================================================================
// Showcase Sections
// =============================================================================

class _FileTypesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'FILE TYPES',
      description: 'Different file type icons based on the attachment type.',
      children: [
        _ExampleCard(
          label: 'PDF',
          child: StreamMessageComposerFileAttachment(
            fileTypeIcon: StreamFileTypeIcon(type: StreamFileType.pdf),
            title: const Text('annual_report.pdf'),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'Document',
          child: StreamMessageComposerFileAttachment(
            fileTypeIcon: StreamFileTypeIcon(type: StreamFileType.text),
            title: const Text('meeting_notes.docx'),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'Spreadsheet',
          child: StreamMessageComposerFileAttachment(
            fileTypeIcon: StreamFileTypeIcon(type: StreamFileType.spreadsheet),
            title: const Text('project_budget.xlsx'),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'Audio',
          child: StreamMessageComposerFileAttachment(
            fileTypeIcon: StreamFileTypeIcon(type: StreamFileType.audio),
            title: const Text('podcast_episode.mp3'),
            onRemovePressed: () {},
          ),
        ),
      ],
    );
  }
}

class _WithSubtitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final subtitleStyle = context.streamTextTheme.metadataDefault.copyWith(color: colorScheme.textTertiary);

    return _Section(
      label: 'WITH SUBTITLE',
      description: 'An optional subtitle for additional info like file size or upload status.',
      children: [
        _ExampleCard(
          label: 'With file size',
          child: StreamMessageComposerFileAttachment(
            fileTypeIcon: StreamFileTypeIcon(type: StreamFileType.pdf),
            title: const Text('design_specs.pdf'),
            subtitle: Text('4.2 MB', style: subtitleStyle),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'Without remove button',
          child: StreamMessageComposerFileAttachment(
            fileTypeIcon: StreamFileTypeIcon(type: StreamFileType.spreadsheet),
            title: const Text('budget_2025.xlsx'),
            subtitle: Text('1.8 MB', style: subtitleStyle),
          ),
        ),
      ],
    );
  }
}

class _ConstrainedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final subtitleStyle = context.streamTextTheme.metadataDefault.copyWith(color: colorScheme.textTertiary);

    return _Section(
      label: 'CONSTRAINED MAX WIDTH',
      description:
          'When a parent bounds the width, long file names ellipsize on a single line '
          'rather than wrap.',
      children: [
        _ExampleCard(
          label: 'Bounded to 240',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: StreamMessageComposerFileAttachment(
              fileTypeIcon: StreamFileTypeIcon(type: StreamFileType.pdf),
              title: const Text('quarterly_financial_results_summary.pdf'),
              subtitle: Text('12.4 MB', style: subtitleStyle),
              onRemovePressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.children,
    this.description,
  });

  final String label;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              label,
              style: context.streamTextTheme.metadataEmphasis.copyWith(
                letterSpacing: 1.2,
                color: colorScheme.accentPrimary,
              ),
            ),
            if (description case final desc?)
              Text(desc, style: context.streamTextTheme.metadataDefault.copyWith(color: colorScheme.textTertiary)),
          ],
        ),
        ...children,
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.backgroundApp,
        borderRadius: BorderRadius.all(radius.md),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            label,
            style: context.streamTextTheme.metadataEmphasis.copyWith(color: colorScheme.textSecondary),
          ),
          child,
        ],
      ),
    );
  }
}
