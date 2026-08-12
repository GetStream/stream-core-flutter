import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:stream_core_flutter/core.dart';

/// Below this width, the hex value and edit/reset icons don't fit
/// comfortably beside the label/default column — they move to their own
/// row underneath instead of squeezing both onto one line. Chosen to give
/// the label column at least ~100px even after the swatch, gaps, hex text
/// and icons are accounted for; narrower than this and a longer label (or
/// hex) starts wrapping character-by-character instead of just truncating.
const _kStackedLayoutThreshold = 260.0;

/// Whether a [ColorPickerTile] given [outerWidth] of horizontal space (its
/// own render width, before its internal padding) would need the stacked
/// (compact) layout.
///
/// [ColorPickerTile] can't decide this itself via an internal `LayoutBuilder`
/// the way a typical responsive widget would: the export page's linked rows
/// wrap light/dark tiles in `IntrinsicHeight` to align them, and
/// `IntrinsicHeight` can't compute intrinsic dimensions through a
/// `LayoutBuilder` anywhere in its subtree (Flutter throws on it). So a
/// caller that lays out several tiles at a shared, known width — like the
/// export page's settings columns — measures once via its own `LayoutBuilder`
/// placed *above* `IntrinsicHeight`, and passes the result down as
/// [ColorPickerTile.compact].
bool isColorPickerTileCompact(double outerWidth, StreamSpacing spacing) {
  final innerWidth = outerWidth - 2 * (spacing.sm + spacing.xxs);
  return innerWidth < _kStackedLayoutThreshold;
}

/// A tile that displays a color and opens a color picker when tapped.
class ColorPickerTile extends StatelessWidget {
  const ColorPickerTile({
    super.key,
    required this.label,
    required this.color,
    required this.onColorChanged,
    this.isDefault = false,
    this.onReset,
    this.compact = false,
  });

  final String label;

  /// The current color, or `null` when [isDefault] is true and there's no
  /// concrete default to show (e.g. a component theme property that falls
  /// back to a value this tile can't resolve). `null` renders a neutral
  /// placeholder swatch and the literal text `default` in place of a hex
  /// code, rather than a fabricated color that would look like a real value.
  final Color? color;
  final ValueChanged<Color> onColorChanged;

  /// Whether [color] is still the SDK default (i.e. not overridden).
  ///
  /// When true, a "default" caption is shown below [label] and no reset
  /// control is displayed.
  final bool isDefault;

  /// Reverts this color back to its SDK default.
  ///
  /// Ignored (no reset control shown) when [isDefault] is true.
  final VoidCallback? onReset;

  /// Use the stacked (label / default / hex+icons) layout instead of the
  /// inline one — see [isColorPickerTileCompact]. Defaults to false: the
  /// theme studio panel is always wide enough for the inline layout, so it
  /// doesn't need to compute this at all.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs + spacing.xxs),
      child: InkWell(
        onTap: () => _showColorPicker(context),
        borderRadius: BorderRadius.all(radius.sm),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: spacing.sm + spacing.xxs, vertical: spacing.sm),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurfaceSubtle,
            borderRadius: BorderRadius.all(radius.sm),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.sm),
            border: Border.all(color: colorScheme.borderDefault),
          ),
          child: compact ? _buildStacked(context) : _buildInline(context),
        ),
      ),
    );
  }

  /// Swatch, then label/default beside the hex value and icons — everything
  /// on one visual row. Used when there's enough width for the hex and
  /// icons to share a line with the label column without crowding it.
  Widget _buildInline(BuildContext context) {
    final spacing = context.streamSpacing;

    return Row(
      children: [
        _buildSwatch(context),
        SizedBox(width: spacing.sm + spacing.xxs),
        Expanded(child: _buildLabelColumn(context)),
        SizedBox(width: spacing.xs + spacing.xxs),
        _buildValueRow(context, expanded: false),
      ],
    );
  }

  /// Swatch beside label/default, with the hex value and icons moved to
  /// their own row underneath. Used when the tile is too narrow for the hex
  /// and icons to share a line with the label without crowding it — see
  /// [_kStackedLayoutThreshold].
  Widget _buildStacked(BuildContext context) {
    final spacing = context.streamSpacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSwatch(context),
        SizedBox(width: spacing.sm + spacing.xxs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLabelColumn(context),
              _buildValueRow(context, expanded: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwatch(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;

    return Container(
      width: 24,
      height: 24,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? colorScheme.backgroundSurfaceStrong,
        borderRadius: BorderRadius.all(radius.xs),
        boxShadow: color != null ? boxShadow.elevation1 : null,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.xs),
        border: Border.all(color: colorScheme.borderDefault.withValues(alpha: color != null ? 0.3 : 1)),
      ),
      child: color == null ? Icon(Icons.help_outline, size: 14, color: colorScheme.textTertiary) : null,
    );
  }

  Widget _buildLabelColumn(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.metadataDefault.copyWith(color: colorScheme.textPrimary, fontFamily: 'monospace'),
        ),
        // Always laid out (transparent when not default) so a default tile
        // and a customized tile for the same slot are the same height -
        // otherwise a light/dark pair in the export page's linked rows
        // visibly misaligns whenever only one side is customized.
        //
        // Dropped from the semantics tree when it isn't the real state,
        // though: transparent text is still read out, so a customized tile
        // would otherwise announce "default".
        ExcludeSemantics(
          excluding: !isDefault,
          child: Text(
            'default',
            style: textTheme.metadataDefault.copyWith(
              color: isDefault ? colorScheme.textTertiary : StreamColors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  /// The hex value plus reset/edit icons. Inline (`expanded: false`) packs
  /// them tight, appended straight after the label column. Stacked
  /// (`expanded: true`) is its own full-width row, with a [Spacer] pushing
  /// the icons to the trailing edge since there's no label column to butt
  /// up against on that row.
  Widget _buildValueRow(BuildContext context, {required bool expanded}) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (color != null)
          // Flexible + ellipsis rather than a bare Text: at extreme widths
          // (e.g. a component color with a reset icon, on an already-narrow
          // tile) the hex text plus icons can still exceed even this row's
          // own width - shrink the hex first rather than overflow.
          Flexible(
            child: Text(
              _colorToHex(color!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary, fontFamily: 'monospace'),
            ),
          ),
        if (expanded) const Spacer(),
        if (!isDefault && onReset != null) ...[
          SizedBox(width: spacing.xs + spacing.xxs),
          Tooltip(
            message: 'Reset to default',
            child: InkWell(
              onTap: onReset,
              borderRadius: BorderRadius.all(radius.xs),
              child: Icon(Icons.restart_alt, color: colorScheme.textSecondary, size: 14),
            ),
          ),
        ],
        SizedBox(width: spacing.xs + spacing.xxs),
        Icon(Icons.edit, color: colorScheme.textSecondary, size: 12),
      ],
    );
  }

  String _colorToHex(Color color) {
    final hex = color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0');
    return color.a < 1.0 ? '#$hex' : '#${hex.substring(2)}';
  }

  Future<void> _showColorPicker(BuildContext context) async {
    var pickerColor = color ?? context.streamColorScheme.backgroundSurfaceStrong;
    final textTheme = context.streamTextTheme;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          label,
          style: textTheme.headingSm.copyWith(
            fontFamily: 'monospace',
          ),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onColorChanged(pickerColor);
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
