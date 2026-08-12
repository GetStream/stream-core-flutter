import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';

/// The shared building block for every row on the export page's settings
/// columns: a light half and a dark half, each themed and painted with that
/// side's own `backgroundApp` — so tile rows, section headers, group
/// headings, and inter-row spacing all paint the same continuous background
/// per column, instead of the page's own background showing through as a
/// seam between them.
class ExportColumnRow extends StatelessWidget {
  const ExportColumnRow({
    super.key,
    required this.lightMaterialTheme,
    required this.darkMaterialTheme,
    required this.lightBuilder,
    required this.darkBuilder,
    this.middle,
  }) : height = null;

  /// A blank spacer of [height] with the same continuous background — use
  /// this instead of a plain transparent `SizedBox` between rows/sections.
  const ExportColumnRow.spacer({
    super.key,
    required this.lightMaterialTheme,
    required this.darkMaterialTheme,
    required double this.height,
  }) : lightBuilder = _empty,
       darkBuilder = _empty,
       middle = null;

  final ThemeData lightMaterialTheme;
  final ThemeData darkMaterialTheme;
  final WidgetBuilder lightBuilder;
  final WidgetBuilder darkBuilder;

  /// Content for the narrow strip between the two halves (e.g. a link
  /// toggle). Left blank (and thus unthemed) for headers/spacers.
  final Widget? middle;

  final double? height;

  static Widget _empty(BuildContext context) => const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    final row = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _side(lightMaterialTheme, lightBuilder)),
          SizedBox(width: 40, child: middle ?? const SizedBox.shrink()),
          Expanded(child: _side(darkMaterialTheme, darkBuilder)),
        ],
      ),
    );
    return height != null ? SizedBox(height: height, child: row) : row;
  }

  Widget _side(ThemeData theme, WidgetBuilder builder) {
    // A Builder gets a BuildContext under this side's Theme, so both the
    // content's own context.streamColorScheme reads AND any dialog it pushes
    // (showDialog captures inherited themes from the caller's context) pick
    // up this side's colors rather than the page's ambient theme.
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => Material(color: context.streamColorScheme.backgroundApp, child: builder(context)),
      ),
    );
  }
}
