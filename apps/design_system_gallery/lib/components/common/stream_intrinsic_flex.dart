import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

enum _ChildKind {
  fixedSmall('Fixed small'),
  fixedMedium('Fixed medium'),
  fixedLarge('Fixed large'),
  expanded('Expanded'),
  aligned('Aligned'),
  ;

  const _ChildKind(this.label);

  final String label;
}

enum _ChildAlignment {
  start(Alignment.centerLeft, Alignment.topCenter),
  center(Alignment.center, Alignment.center),
  end(Alignment.centerRight, Alignment.bottomCenter),
  ;

  const _ChildAlignment(this.vertical, this.horizontal);

  /// Alignment used when direction is vertical (cross-axis = horizontal).
  final Alignment vertical;

  /// Alignment used when direction is horizontal (cross-axis = vertical).
  final Alignment horizontal;

  Alignment resolve({required bool isVertical}) => isVertical ? vertical : horizontal;

  String label({required bool isVertical}) => switch (this) {
    start => isVertical ? 'left' : 'top',
    center => 'center',
    end => isVertical ? 'right' : 'bottom',
  };
}

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamIntrinsicFlex,
  path: '[Components]/Common',
)
Widget buildStreamIntrinsicFlexPlayground(BuildContext context) {
  final direction = context.knobs.object.dropdown(
    label: 'Direction',
    options: Axis.values,
    labelBuilder: (value) => value.name,
    initialOption: Axis.vertical,
    description: 'The main axis direction.',
  );

  final mainAxisAlignment = context.knobs.object.dropdown(
    label: 'Main Axis Alignment',
    options: MainAxisAlignment.values,
    labelBuilder: (value) => value.name,
    initialOption: MainAxisAlignment.start,
    description: 'How children are placed along the main axis.',
  );

  final mainAxisSize = context.knobs.object.dropdown(
    label: 'Main Axis Size',
    options: MainAxisSize.values,
    labelBuilder: (value) => value.name,
    initialOption: MainAxisSize.min,
    description: 'Whether to minimize or maximize main-axis extent.',
  );

  final spacing = context.knobs.double.slider(
    label: 'Spacing',
    initialValue: 8,
    min: -24,
    max: 32,
    description: 'Space between children. Negative values cause overlap.',
  );

  final crossAxisAlignment = context.knobs.object.dropdown(
    label: 'Cross Axis Alignment',
    options: [
      CrossAxisAlignment.start,
      CrossAxisAlignment.center,
      CrossAxisAlignment.end,
    ],
    labelBuilder: (value) => value.name,
    initialOption: CrossAxisAlignment.start,
    description: 'How children are placed along the cross axis.',
  );

  // null = hidden
  final childConfigs = <({_ChildKind kind, bool candidate, bool bounded, _ChildAlignment alignment})?>[];
  const defaults = [
    (_ChildKind.fixedMedium, true, false, _ChildAlignment.start),
    (_ChildKind.expanded, false, false, _ChildAlignment.start),
    (_ChildKind.fixedLarge, false, false, _ChildAlignment.start),
    (_ChildKind.aligned, false, false, _ChildAlignment.end),
    (_ChildKind.fixedSmall, true, false, _ChildAlignment.start),
  ];

  for (var i = 0; i < 5; i++) {
    final visible = context.knobs.boolean(
      label: 'Child ${i + 1}',
      initialValue: true,
      description: 'Show or hide child ${i + 1}.',
    );

    if (!visible) {
      childConfigs.add(null);
      continue;
    }

    final kind = context.knobs.object.dropdown(
      label: 'Child ${i + 1} type',
      options: _ChildKind.values,
      labelBuilder: (value) => value.label,
      initialOption: defaults[i].$1,
      description: 'Type of child ${i + 1}.',
    );
    final candidate = context.knobs.boolean(
      label: 'Child ${i + 1} candidate',
      initialValue: defaults[i].$2,
      description: 'Mark child ${i + 1} as a StreamIntrinsicSizeCandidate.',
    );
    final bounded = context.knobs.boolean(
      label: 'Child ${i + 1} bounded',
      initialValue: defaults[i].$3,
      description:
          'Wrap child ${i + 1} in StreamIntrinsicBoundedCrossAxis '
          "so it is measured under the parent's cross-axis ceiling.",
    );

    final isVertical = direction == Axis.vertical;
    var alignment = defaults[i].$4;
    if (kind == _ChildKind.aligned) {
      alignment = context.knobs.object.dropdown(
        label: 'Child ${i + 1} alignment',
        options: _ChildAlignment.values,
        labelBuilder: (value) => value.label(isVertical: isVertical),
        initialOption: defaults[i].$4,
        description: 'Alignment for child ${i + 1}.',
      );
    }

    childConfigs.add((kind: kind, candidate: candidate, bounded: bounded, alignment: alignment));
  }

  return _PlaygroundBody(
    direction: direction,
    mainAxisAlignment: mainAxisAlignment,
    mainAxisSize: mainAxisSize,
    spacing: spacing,
    crossAxisAlignment: crossAxisAlignment,
    childConfigs: childConfigs,
  );
}

class _PlaygroundBody extends StatelessWidget {
  const _PlaygroundBody({
    required this.direction,
    required this.mainAxisAlignment,
    required this.mainAxisSize,
    required this.spacing,
    required this.crossAxisAlignment,
    required this.childConfigs,
  });

  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final List<({_ChildKind kind, bool candidate, bool bounded, _ChildAlignment alignment})?> childConfigs;

  List<Widget> _buildChildren(
    BuildContext context, {
    bool wrapMarkers = true,
  }) {
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final themeSpacing = context.streamSpacing;
    final isVertical = direction == Axis.vertical;

    return [
      for (var i = 0; i < childConfigs.length; i++)
        if (childConfigs[i] case final config?)
          () {
            final palette = _childPalette[i % _childPalette.length];

            final sizes = _childSizes(config.kind, isVertical);

            var child = switch (config.kind) {
              _ChildKind.fixedSmall || _ChildKind.fixedMedium || _ChildKind.fixedLarge => Container(
                width: sizes.width,
                height: sizes.height,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: palette.bg,
                  borderRadius: BorderRadius.all(radius.sm),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  '${i + 1}: ${sizes.crossLabel}',
                  style: textTheme.metadataEmphasis.copyWith(color: palette.fg),
                ),
              ),
              _ChildKind.aligned => Align(
                alignment: config.alignment.resolve(isVertical: isVertical),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: palette.bg,
                    borderRadius: BorderRadius.all(radius.sm),
                  ),
                  child: Text(
                    '${i + 1}: ${config.alignment.label(isVertical: isVertical)}',
                    style: textTheme.metadataEmphasis.copyWith(color: palette.fg),
                  ),
                ),
              ),
              _ChildKind.expanded => Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: themeSpacing.sm,
                    vertical: themeSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: palette.bg,
                    borderRadius: BorderRadius.all(radius.sm),
                    border: Border.all(color: palette.fg.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '${i + 1}: flex',
                    style: textTheme.metadataEmphasis.copyWith(color: palette.fg),
                  ),
                ),
              ),
            };

            if (wrapMarkers && config.candidate) {
              child = StreamIntrinsicSizeCandidate(child: child);
            }
            if (wrapMarkers && config.bounded) {
              child = StreamIntrinsicBoundedCrossAxis(child: child);
            }
            return child;
          }(),
    ];
  }

  static ({double width, double height, String crossLabel}) _childSizes(
    _ChildKind kind,
    bool isVertical,
  ) {
    return switch (kind) {
      _ChildKind.fixedSmall =>
        isVertical ? (width: 80, height: 36, crossLabel: 'w 80') : (width: 80, height: 32, crossLabel: 'h 32'),
      _ChildKind.fixedMedium =>
        isVertical ? (width: 140, height: 36, crossLabel: 'w 140') : (width: 80, height: 56, crossLabel: 'h 56'),
      _ChildKind.fixedLarge =>
        isVertical ? (width: 200, height: 36, crossLabel: 'w 200') : (width: 80, height: 80, crossLabel: 'h 80'),
      _ => (width: 0, height: 0, crossLabel: ''),
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeSpacing = context.streamSpacing;

    final isVertical = direction == Axis.vertical;
    final hasFlex = childConfigs.any((c) => c?.kind == _ChildKind.expanded);
    final needsBoundedMain = isVertical && (hasFlex || mainAxisSize == MainAxisSize.max);

    Widget wrapMain(Widget child) {
      if (!needsBoundedMain) return child;
      return SizedBox(height: 300, child: child);
    }

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(themeSpacing.lg),
        child: Column(
          spacing: themeSpacing.xl,
          children: [
            _LabeledFlexBox(
              label: 'StreamIntrinsicFlex',
              isIntrinsic: true,
              child: wrapMain(
                StreamIntrinsicFlex(
                  direction: direction,
                  mainAxisAlignment: mainAxisAlignment,
                  mainAxisSize: mainAxisSize,
                  spacing: spacing,
                  crossAxisAlignment: crossAxisAlignment,
                  children: _buildChildren(context),
                ),
              ),
            ),
            _LabeledFlexBox(
              label: 'Regular Flex',
              isIntrinsic: false,
              child: wrapMain(
                Flex(
                  direction: direction,
                  mainAxisAlignment: mainAxisAlignment,
                  mainAxisSize: mainAxisSize,
                  crossAxisAlignment: crossAxisAlignment,
                  spacing: spacing,
                  children: _buildChildren(context, wrapMarkers: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledFlexBox extends StatelessWidget {
  const _LabeledFlexBox({
    required this.label,
    required this.isIntrinsic,
    required this.child,
  });

  final String label;
  final bool isIntrinsic;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final accentColor = isIntrinsic ? colorScheme.accentPrimary : colorScheme.textTertiary;

    return Column(
      spacing: spacing.xs,
      children: [
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: accentColor,
            fontFamily: 'monospace',
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.all(radius.md),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      ],
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamIntrinsicFlex,
  path: '[Components]/Common',
)
Widget buildStreamIntrinsicFlexShowcase(BuildContext context) {
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
          _ShrinkWrapSection(),
          _SizeCandidatesSection(),
          _BoundedChildrenSection(),
          _CrossAxisAlignmentSection(),
          _BaselineAlignmentSection(),
          _NegativeSpacingSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Shrink-Wrap Section
// =============================================================================

class _ShrinkWrapSection extends StatelessWidget {
  const _ShrinkWrapSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'SHRINK-WRAP BEHAVIOR'),
        _ExampleCard(
          title: 'Column (cross-axis = width)',
          description:
              'Expanding children and Align fill the full available '
              'width in a regular Column, but stay confined to the '
              'widest child in StreamIntrinsicColumn.',
          child: _ShrinkWrapColumnDemo(),
        ),
        _ExampleCard(
          title: 'Row (cross-axis = height)',
          description:
              'Same principle along the vertical cross-axis. Expanding '
              'children stretch to fill available height in a regular '
              'Row, but are confined in StreamIntrinsicRow.',
          child: _ShrinkWrapRowDemo(),
        ),
      ],
    );
  }
}

class _ShrinkWrapColumnDemo extends StatelessWidget {
  const _ShrinkWrapColumnDemo();

  List<Widget> _buildChildren(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return [
      _ColoredBar(width: 160, label: 'Fixed 160px', palette: _childPalette[0]),
      Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
          decoration: BoxDecoration(
            color: _childPalette[1].bg,
            borderRadius: BorderRadius.all(radius.sm),
          ),
          child: Text(
            'I expand to fill',
            style: textTheme.metadataEmphasis.copyWith(color: _childPalette[1].fg),
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.accentPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.all(radius.sm),
          ),
          child: Text(
            'aligned right',
            style: textTheme.metadataEmphasis.copyWith(color: colorScheme.accentPrimary),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _ShrinkWrapComparisonPair(
      intrinsicLabel: 'StreamIntrinsicColumn',
      regularLabel: 'Regular Column',
      intrinsicCaption: 'Width = widest child (160px)',
      regularCaption: 'Children expand to fill available width',
      buildIntrinsic: (children) => SizedBox(
        height: 200,
        child: StreamIntrinsicColumn(
          spacing: context.streamSpacing.xs,
          children: children,
        ),
      ),
      buildRegular: (children) => SizedBox(
        height: 200,
        child: Column(
          spacing: context.streamSpacing.xs,
          children: children,
        ),
      ),
      children: _buildChildren(context),
    );
  }
}

class _ShrinkWrapRowDemo extends StatelessWidget {
  const _ShrinkWrapRowDemo();

  List<Widget> _buildChildren(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return [
      _ColoredBar(height: 80, label: '80px', palette: _childPalette[0]),
      Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: spacing.xs, vertical: spacing.sm),
          decoration: BoxDecoration(
            color: _childPalette[1].bg,
            borderRadius: BorderRadius.all(radius.sm),
          ),
          child: Text(
            'Expands',
            style: textTheme.metadataEmphasis.copyWith(color: _childPalette[1].fg),
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.accentPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.all(radius.sm),
          ),
          child: Text(
            'bottom',
            style: textTheme.metadataEmphasis.copyWith(color: colorScheme.accentPrimary),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _ShrinkWrapComparisonPair(
      intrinsicLabel: 'StreamIntrinsicRow',
      regularLabel: 'Regular Row',
      intrinsicCaption: 'Height = tallest child (80px)',
      regularCaption: 'Children expand to fill available height',
      buildIntrinsic: (children) => StreamIntrinsicRow(
        spacing: context.streamSpacing.xs,
        children: children,
      ),
      buildRegular: (children) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.streamSpacing.xs,
        children: children,
      ),
      children: _buildChildren(context),
    );
  }
}

class _ShrinkWrapComparisonPair extends StatelessWidget {
  const _ShrinkWrapComparisonPair({
    required this.intrinsicLabel,
    required this.regularLabel,
    required this.intrinsicCaption,
    required this.regularCaption,
    required this.buildIntrinsic,
    required this.buildRegular,
    required this.children,
  });

  final String intrinsicLabel;
  final String regularLabel;
  final String intrinsicCaption;
  final String regularCaption;
  final Widget Function(List<Widget> children) buildIntrinsic;
  final Widget Function(List<Widget> children) buildRegular;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.lg,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.xs,
            children: [
              Text(
                intrinsicLabel,
                style: textTheme.metadataEmphasis.copyWith(
                  color: colorScheme.accentPrimary,
                  fontFamily: 'monospace',
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.accentPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.all(radius.md),
                  border: Border.all(
                    color: colorScheme.accentPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: buildIntrinsic(children),
              ),
              Text(
                intrinsicCaption,
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.accentPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.xs,
            children: [
              Text(
                regularLabel,
                style: textTheme.metadataEmphasis.copyWith(
                  color: colorScheme.textTertiary,
                  fontFamily: 'monospace',
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.textTertiary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.all(radius.md),
                  border: Border.all(
                    color: colorScheme.textTertiary.withValues(alpha: 0.2),
                  ),
                ),
                child: buildRegular(children),
              ),
              Text(
                regularCaption,
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Size Candidates Section
// =============================================================================

class _SizeCandidatesSection extends StatelessWidget {
  const _SizeCandidatesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'SIZE CANDIDATES'),
        _ExampleCard(
          title: 'Column — candidates determine width',
          description:
              'Only candidates determine the cross-axis extent. '
              'Toggle which children are candidates to see how the '
              'column width changes.',
          child: _SizeCandidatesColumnDemo(),
        ),
        _ExampleCard(
          title: 'Row — candidates determine height',
          description:
              'Same concept along the vertical cross-axis. Toggle '
              'candidates to see how the row height changes.',
          child: _SizeCandidatesRowDemo(),
        ),
      ],
    );
  }
}

class _SizeCandidatesColumnDemo extends StatefulWidget {
  const _SizeCandidatesColumnDemo();

  @override
  State<_SizeCandidatesColumnDemo> createState() => _SizeCandidatesColumnDemoState();
}

class _SizeCandidatesColumnDemoState extends State<_SizeCandidatesColumnDemo> {
  final _candidates = <int>{0, 1};

  static const _widths = [100.0, 140.0, 200.0, 80.0];
  static const _labels = ['Header', 'Content', 'Footer', 'Tag'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            for (var i = 0; i < _labels.length; i++)
              FilterChip(
                label: Text('${_labels[i]} (${_widths[i].toInt()}px)', style: textTheme.metadataDefault),
                selected: _candidates.contains(i),
                onSelected: (selected) => setState(() {
                  selected ? _candidates.add(i) : _candidates.remove(i);
                }),
              ),
          ],
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.accentPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.all(radius.md),
            border: Border.all(color: colorScheme.accentPrimary.withValues(alpha: 0.3)),
          ),
          child: StreamIntrinsicColumn(
            spacing: spacing.xs,
            children: [
              for (var i = 0; i < _labels.length; i++)
                _wrapCandidate(
                  isCandidate: _candidates.contains(i),
                  child: _ColoredBar(
                    width: _widths[i],
                    label: '${_labels[i]}${_candidates.contains(i) ? ' *' : ''}',
                    palette: _childPalette[i % _childPalette.length],
                    borderColor: _candidates.contains(i) ? _childPalette[i % _childPalette.length].fg : null,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SizeCandidatesRowDemo extends StatefulWidget {
  const _SizeCandidatesRowDemo();

  @override
  State<_SizeCandidatesRowDemo> createState() => _SizeCandidatesRowDemoState();
}

class _SizeCandidatesRowDemoState extends State<_SizeCandidatesRowDemo> {
  final _candidates = <int>{0, 2};

  static const _heights = [40.0, 56.0, 80.0, 32.0];
  static const _labels = ['Sm', 'Med', 'Lg', 'Xs'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            for (var i = 0; i < _labels.length; i++)
              FilterChip(
                label: Text('${_labels[i]} (${_heights[i].toInt()}px)', style: textTheme.metadataDefault),
                selected: _candidates.contains(i),
                onSelected: (selected) => setState(() {
                  selected ? _candidates.add(i) : _candidates.remove(i);
                }),
              ),
          ],
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.accentPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.all(radius.md),
            border: Border.all(color: colorScheme.accentPrimary.withValues(alpha: 0.3)),
          ),
          child: StreamIntrinsicRow(
            spacing: spacing.xs,
            children: [
              for (var i = 0; i < _labels.length; i++)
                _wrapCandidate(
                  isCandidate: _candidates.contains(i),
                  child: _ColoredBar(
                    height: _heights[i],
                    label: '${_labels[i]}${_candidates.contains(i) ? ' *' : ''}',
                    palette: _childPalette[i % _childPalette.length],
                    borderColor: _candidates.contains(i) ? _childPalette[i % _childPalette.length].fg : null,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _wrapCandidate({required bool isCandidate, required Widget child}) {
  if (isCandidate) return StreamIntrinsicSizeCandidate(child: child);
  return child;
}

// =============================================================================
// Bounded Children Section
// =============================================================================

class _BoundedChildrenSection extends StatelessWidget {
  const _BoundedChildrenSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'BOUNDED CHILDREN'),
        _ExampleCard(
          title: 'Marker changes how a child is measured',
          description:
              'StreamIntrinsicColumn measures children with an unbounded '
              'cross-axis by default, so Align shrink-wraps. Wrap a child '
              "in StreamIntrinsicBoundedCrossAxis to give it the parent's "
              'cross-axis ceiling — Align then fills, and the column resolves '
              'to that wider extent.',
          child: _BoundedAlignDemo(),
        ),
        _ExampleCard(
          title: 'Hosting a ListView(shrinkWrap: true)',
          description:
              'A vertical viewport asserts when given an unbounded width. '
              'Wrapping the child in StreamIntrinsicBoundedCrossAxis hands '
              'it a bounded width during pass-1, so a shrink-wrapping '
              'ListView (or Wrap) inside it can lay out without asserting.',
          child: _BoundedListViewDemo(),
        ),
      ],
    );
  }
}

class _BoundedAlignDemo extends StatelessWidget {
  const _BoundedAlignDemo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    Widget alignedChild() => Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.accentPrimary.withValues(alpha: 0.16),
          borderRadius: BorderRadius.all(radius.sm),
        ),
        child: Text(
          'aligned right',
          style: textTheme.metadataEmphasis.copyWith(color: colorScheme.accentPrimary),
        ),
      ),
    );

    Widget card({
      required String label,
      required Widget alignChild,
      required bool accent,
    }) {
      final accentColor = accent ? colorScheme.accentPrimary : colorScheme.textTertiary;
      return _VariantDemo(
        label: label,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.all(radius.md),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: StreamIntrinsicColumn(
              spacing: spacing.xs,
              children: [
                _ColoredBar(width: 80, label: 'Fixed 80', palette: _childPalette[0]),
                alignChild,
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.lg,
      children: [
        Expanded(
          child: card(
            label: 'unmarked',
            alignChild: alignedChild(),
            accent: false,
          ),
        ),
        Expanded(
          child: card(
            label: 'StreamIntrinsicBoundedCrossAxis',
            alignChild: StreamIntrinsicBoundedCrossAxis(child: alignedChild()),
            accent: true,
          ),
        ),
      ],
    );
  }
}

class _BoundedListViewDemo extends StatelessWidget {
  const _BoundedListViewDemo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final list = ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, _) => Divider(height: 1, color: colorScheme.borderSubtle),
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
        child: Text(
          'Item ${i + 1}',
          style: textTheme.metadataEmphasis.copyWith(color: colorScheme.textPrimary),
        ),
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.accentPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.all(radius.md),
          border: Border.all(color: colorScheme.accentPrimary.withValues(alpha: 0.3)),
        ),
        child: StreamIntrinsicColumn(
          spacing: spacing.xs,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
              child: Text(
                'Header',
                style: textTheme.captionEmphasis.copyWith(color: colorScheme.accentPrimary),
              ),
            ),
            StreamIntrinsicBoundedCrossAxis(child: list),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
              child: Text(
                'Footer',
                style: textTheme.captionEmphasis.copyWith(color: colorScheme.accentPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Cross-Axis Alignment Section
// =============================================================================

class _CrossAxisAlignmentSection extends StatelessWidget {
  const _CrossAxisAlignmentSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'CROSS-AXIS ALIGNMENT'),
        _ExampleCard(
          title: 'Column — horizontal alignment',
          description:
              'The column width is resolved from the widest child, then '
              'narrower children are aligned within that extent.',
          child: _CrossAxisAlignmentColumnDemo(),
        ),
        _ExampleCard(
          title: 'Row — vertical alignment',
          description:
              'The row height is resolved from the tallest child, then '
              'shorter children are aligned within that extent.',
          child: _CrossAxisAlignmentRowDemo(),
        ),
      ],
    );
  }
}

class _CrossAxisAlignmentColumnDemo extends StatelessWidget {
  const _CrossAxisAlignmentColumnDemo();

  static const _alignments = [
    ('start', CrossAxisAlignment.start),
    ('center', CrossAxisAlignment.center),
    ('end', CrossAxisAlignment.end),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.lg,
      children: [
        for (final (label, alignment) in _alignments)
          Expanded(
            child: _VariantDemo(
              label: label,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.accentPrimary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.all(radius.md),
                  border: Border.all(color: colorScheme.accentPrimary.withValues(alpha: 0.2)),
                ),
                child: StreamIntrinsicColumn(
                  spacing: 4,
                  crossAxisAlignment: alignment,
                  children: [
                    _ColoredBar(width: 80, palette: _childPalette[0]),
                    _ColoredBar(width: 140, palette: _childPalette[1]),
                    _ColoredBar(width: 60, palette: _childPalette[2]),
                    _ColoredBar(width: 110, palette: _childPalette[3]),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CrossAxisAlignmentRowDemo extends StatelessWidget {
  const _CrossAxisAlignmentRowDemo();

  static const _alignments = [
    ('start', CrossAxisAlignment.start),
    ('center', CrossAxisAlignment.center),
    ('end', CrossAxisAlignment.end),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.lg,
      children: [
        for (final (label, alignment) in _alignments)
          Expanded(
            child: _VariantDemo(
              label: label,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.accentPrimary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.all(radius.md),
                  border: Border.all(color: colorScheme.accentPrimary.withValues(alpha: 0.2)),
                ),
                child: StreamIntrinsicRow(
                  spacing: 4,
                  crossAxisAlignment: alignment,
                  children: [
                    _ColoredBar(height: 40, palette: _childPalette[0]),
                    _ColoredBar(height: 72, palette: _childPalette[1]),
                    _ColoredBar(height: 32, palette: _childPalette[2]),
                    _ColoredBar(height: 56, palette: _childPalette[3]),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Baseline Alignment Section
// =============================================================================

class _BaselineAlignmentSection extends StatelessWidget {
  const _BaselineAlignmentSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'BASELINE ALIGNMENT'),
        _ExampleCard(
          title: 'Row — baseline alignment',
          description:
              'Children with different font sizes are aligned along '
              'their text baseline. The row height shrink-wraps to '
              'accommodate the tallest ascent + descent.',
          child: _BaselineAlignmentDemo(),
        ),
      ],
    );
  }
}

class _BaselineAlignmentDemo extends StatelessWidget {
  const _BaselineAlignmentDemo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    Widget buildChild(String text, double fontSize, int paletteIndex) {
      final palette = _childPalette[paletteIndex % _childPalette.length];
      return Container(
        padding: EdgeInsets.symmetric(horizontal: spacing.xs, vertical: spacing.xxs),
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius: BorderRadius.all(radius.sm),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, color: palette.fg, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        _VariantDemo(
          label: 'baseline',
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.accentPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.all(radius.md),
              border: Border.all(color: colorScheme.accentPrimary.withValues(alpha: 0.2)),
            ),
            child: StreamIntrinsicRow(
              spacing: spacing.xs,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                buildChild('Small', 12, 0),
                buildChild('Medium', 20, 1),
                buildChild('Large', 32, 2),
                buildChild('Tiny', 10, 3),
              ],
            ),
          ),
        ),
        _VariantDemo(
          label: 'center (comparison)',
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.textTertiary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.all(radius.md),
              border: Border.all(color: colorScheme.textTertiary.withValues(alpha: 0.2)),
            ),
            child: StreamIntrinsicRow(
              spacing: spacing.xs,
              // ignore: avoid_redundant_argument_values
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildChild('Small', 12, 0),
                buildChild('Medium', 20, 1),
                buildChild('Large', 32, 2),
                buildChild('Tiny', 10, 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Negative Spacing Section
// =============================================================================

class _NegativeSpacingSection extends StatelessWidget {
  const _NegativeSpacingSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'NEGATIVE SPACING'),
        _ExampleCard(
          title: 'Column — vertical overlap',
          description:
              'Negative spacing causes children to overlap vertically. '
              'Later children paint on top of earlier ones.',
          child: _NegativeSpacingColumnDemo(),
        ),
        _ExampleCard(
          title: 'Row — horizontal overlap',
          description:
              'Same effect along the horizontal axis. Useful for '
              'stacked avatars or overlapping cards.',
          child: _NegativeSpacingRowDemo(),
        ),
      ],
    );
  }
}

class _NegativeSpacingColumnDemo extends StatelessWidget {
  const _NegativeSpacingColumnDemo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xl,
      children: [
        for (final value in [-4.0, -12.0, -20.0])
          _VariantDemo(
            label: 'spacing: ${value.toInt()}',
            child: StreamIntrinsicColumn(
              spacing: value,
              children: [
                for (var i = 0; i < 4; i++)
                  Container(
                    width: 120,
                    padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
                    decoration: BoxDecoration(
                      color: _childPalette[i % _childPalette.length].bg,
                      borderRadius: BorderRadius.all(radius.lg),
                      border: Border.all(color: colorScheme.backgroundSurface, width: 2),
                    ),
                    child: Text(
                      'Card ${i + 1}',
                      style: textTheme.captionEmphasis.copyWith(
                        color: _childPalette[i % _childPalette.length].fg,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NegativeSpacingRowDemo extends StatelessWidget {
  const _NegativeSpacingRowDemo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xl,
      children: [
        for (final value in [-4.0, -12.0, -20.0])
          _VariantDemo(
            label: 'spacing: ${value.toInt()}',
            child: StreamIntrinsicRow(
              spacing: value,
              children: [
                for (var i = 0; i < 4; i++)
                  Container(
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
                    decoration: BoxDecoration(
                      color: _childPalette[i % _childPalette.length].bg,
                      borderRadius: BorderRadius.all(radius.lg),
                      border: Border.all(color: colorScheme.backgroundSurface, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: textTheme.captionEmphasis.copyWith(
                          color: _childPalette[i % _childPalette.length].fg,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _ColoredBar extends StatelessWidget {
  const _ColoredBar({
    this.width,
    this.height,
    required this.palette,
    this.label,
    this.borderColor,
  });

  final double? width;
  final double? height;
  final ({Color bg, Color fg}) palette;
  final String? label;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;

    final isHorizontal = width != null;

    return Container(
      width: width ?? 32,
      height: height ?? 32,
      padding: EdgeInsets.symmetric(horizontal: isHorizontal ? 8 : 2, vertical: isHorizontal ? 0 : 4),
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.all(radius.sm),
        border: borderColor != null ? Border.all(color: borderColor!, width: 2) : null,
      ),
      alignment: isHorizontal ? Alignment.centerLeft : Alignment.topCenter,
      child: label != null
          ? Text(
              label!,
              style: textTheme.metadataEmphasis.copyWith(color: palette.fg, fontSize: isHorizontal ? null : 9),
              overflow: TextOverflow.ellipsis,
              textAlign: isHorizontal ? null : TextAlign.center,
            )
          : null,
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
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
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
          Divider(height: 1, color: colorScheme.borderSubtle),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.md),
            color: colorScheme.backgroundSurfaceSubtle,
            child: child,
          ),
        ],
      ),
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

class _VariantDemo extends StatelessWidget {
  const _VariantDemo({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.xs,
      children: [
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
          ),
        ),
        child,
      ],
    );
  }
}

// =============================================================================
// Helpers
// =============================================================================

final _childPalette = [
  (
    bg: StreamColors.blue.shade400.withValues(alpha: 0.8),
    fg: StreamColors.blue.shade900,
  ),
  (
    bg: StreamColors.cyan.shade400.withValues(alpha: 0.8),
    fg: StreamColors.cyan.shade900,
  ),
  (
    bg: StreamColors.green.shade400.withValues(alpha: 0.8),
    fg: StreamColors.green.shade900,
  ),
  (
    bg: StreamColors.purple.shade400.withValues(alpha: 0.8),
    fg: StreamColors.purple.shade900,
  ),
  (
    bg: StreamColors.yellow.shade400.withValues(alpha: 0.8),
    fg: StreamColors.yellow.shade900,
  ),
];
