import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageComposerUnsupportedAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentUnsupportedPlayground(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Unsupported attachment',
    description: 'The placeholder label, typically a localized "Unsupported attachment" string.',
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
      child: StreamMessageComposerUnsupportedAttachment(
        label: Text(label),
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
  type: StreamMessageComposerUnsupportedAttachment,
  path: '[Components]/Message Composer',
)
Widget buildMessageComposerAttachmentUnsupportedShowcase(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        _BasicSection(),
      ],
    ),
  );
}

// =============================================================================
// Showcase Sections
// =============================================================================

class _BasicSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'BASIC',
      description:
          'A placeholder for attachments the client cannot render. Fixed at 260 wide; '
          'height adapts to the content.',
      children: [
        _ExampleCard(
          label: 'With remove button',
          child: StreamMessageComposerUnsupportedAttachment(
            label: const Text('Unsupported attachment'),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'Without remove button',
          child: StreamMessageComposerUnsupportedAttachment(
            label: const Text('Unsupported attachment'),
          ),
        ),
        _ExampleCard(
          label: 'Long label (ellipsizes)',
          child: StreamMessageComposerUnsupportedAttachment(
            label: const Text('This particular attachment type is not yet supported on this client'),
            onRemovePressed: () {},
          ),
        ),
        _ExampleCard(
          label: 'Constrained max width (220)',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: StreamMessageComposerUnsupportedAttachment(
              label: const Text('A parent below 260 forces the row to shrink and the label ellipsizes.'),
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
