import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/components/stream_sheet_header_theme.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../buttons/stream_button.dart';
import '../common/stream_visibility.dart';

/// A header for bottom sheets, modals, and dialogs in the Stream design
/// system.
///
/// [StreamSheetHeader] arranges an optional centered [title] (and optional
/// [subtitle]) between optional [leading] and [trailing] widget slots —
/// typically a close button on the leading side and a confirm action on
/// the trailing side.
///
/// The heading occupies the flexible center of the row, with a 48×48
/// spacer reserved opposite a lone [leading] or [trailing] so the title
/// stays visually balanced.
///
/// When [leading] is null and [automaticallyImplyLeading] is true (the
/// default), a dismissal button is inserted if the enclosing route can
/// pop. The icon is a cross (`xmark`) on modal surfaces (bottom sheets,
/// dialogs, fullscreen dialogs) and a back chevron on regular pushed
/// pages.
///
/// The drag handle shown on iOS-style bottom sheets is intentionally *not*
/// part of this widget — the sheet itself owns that affordance, which
/// keeps this header usable for non-sheet surfaces (full-page modals,
/// dialog headers).
///
/// {@tool snippet}
///
/// Use inside a bottom sheet with a confirm action — the leading close
/// button is auto-implied since the sheet's route is a modal surface:
///
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   showDragHandle: true,
///   builder: (context) => Column(
///     mainAxisSize: MainAxisSize.min,
///     children: [
///       StreamSheetHeader(
///         title: Text('Edit profile'),
///         trailing: StreamButton.icon(
///           icon: context.streamIcons.checkmark,
///           onTap: () => Navigator.pop(context, result),
///         ),
///       ),
///       // ... sheet contents
///     ],
///   ),
/// );
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamSheetHeader] uses [StreamSheetHeaderThemeData] for default styling —
/// padding, spacing, title/subtitle text styles, and per-slot button style
/// propagation. Defaults are derived from [StreamColorScheme],
/// [StreamTextTheme], and [StreamSpacing].
///
/// See also:
///
///  * [StreamSheetHeaderThemeData], for customizing appearance globally.
///  * [StreamSheetHeaderTheme], for overriding theme in a subtree.
///  * [StreamAppBar], the equivalent for top-level screen chrome.
///  * [DefaultStreamSheetHeader], the default visual implementation.
class StreamSheetHeader extends StatelessWidget {
  /// Creates a Stream sheet header.
  StreamSheetHeader({
    super.key,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
    EdgeInsetsGeometry? padding,
    double? spacing,
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    StreamButtonThemeStyle? leadingStyle,
    StreamButtonThemeStyle? trailingStyle,
  }) : props = .new(
         leading: leading,
         automaticallyImplyLeading: automaticallyImplyLeading,
         title: title,
         subtitle: subtitle,
         trailing: trailing,
         padding: padding,
         spacing: spacing,
         titleTextStyle: titleTextStyle,
         subtitleTextStyle: subtitleTextStyle,
         leadingStyle: leadingStyle,
         trailingStyle: trailingStyle,
       );

  /// The properties that configure this header.
  final StreamSheetHeaderProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).sheetHeader;
    if (builder != null) return builder(context, props);
    return DefaultStreamSheetHeader(props: props);
  }
}

/// Properties for configuring a [StreamSheetHeader].
///
/// This class holds all configuration options for a sheet header, allowing
/// them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamSheetHeader], which uses these properties.
///  * [DefaultStreamSheetHeader], the default implementation.
class StreamSheetHeaderProps {
  /// Creates properties for a sheet header.
  const StreamSheetHeaderProps({
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding,
    this.spacing,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.leadingStyle,
    this.trailingStyle,
  });

  /// A widget to display before the [title].
  ///
  /// Typically a close button or avatar. The caller is responsible for the
  /// widget's own hit area; the header only reserves a 48×48 slot for
  /// symmetry.
  ///
  /// When null and [automaticallyImplyLeading] is true, a default dismissal
  /// button is inserted if the enclosing route can pop — a cross on modal
  /// surfaces, a back chevron on regular pushed pages.
  final Widget? leading;

  /// Controls whether a default dismissal button is shown when [leading] is
  /// null.
  ///
  /// When true (the default), a button is inserted as the leading widget if
  /// the enclosing route can pop. The icon is a cross on modal surfaces
  /// (bottom sheets, dialogs, fullscreen dialogs) and a back chevron on
  /// regular pushed pages.
  final bool automaticallyImplyLeading;

  /// The primary content of the header.
  ///
  /// Typically a [Text] widget. Its text style is resolved from
  /// [StreamSheetHeaderThemeData.titleTextStyle] (defaults to
  /// `textTheme.headingSm` on `colorScheme.textPrimary`).
  final Widget? title;

  /// Additional content displayed below the [title].
  ///
  /// Typically a [Text] widget. Its text style is resolved from
  /// [StreamSheetHeaderThemeData.subtitleTextStyle] (defaults to
  /// `textTheme.captionDefault` on `colorScheme.textTertiary`).
  final Widget? subtitle;

  /// A widget to display after the [title].
  ///
  /// Typically a confirm or overflow action. The caller is responsible for
  /// the widget's own hit area; the header only reserves a 48×48 slot for
  /// symmetry.
  final Widget? trailing;

  /// The padding around the header's content row.
  ///
  /// Overrides [StreamSheetHeaderThemeData.padding] for this header.
  final EdgeInsetsGeometry? padding;

  /// The horizontal space between [leading], the heading, and [trailing].
  ///
  /// Overrides [StreamSheetHeaderThemeData.spacing] for this header.
  final double? spacing;

  /// The text style applied to [title].
  ///
  /// Overrides [StreamSheetHeaderThemeData.titleTextStyle] for this header.
  final TextStyle? titleTextStyle;

  /// The text style applied to [subtitle].
  ///
  /// Overrides [StreamSheetHeaderThemeData.subtitleTextStyle] for this header.
  final TextStyle? subtitleTextStyle;

  /// The button style propagated to any [StreamButton] in [leading].
  ///
  /// Overrides [StreamSheetHeaderThemeData.leadingStyle] for this header.
  final StreamButtonThemeStyle? leadingStyle;

  /// The button style propagated to any [StreamButton] in [trailing].
  ///
  /// Overrides [StreamSheetHeaderThemeData.trailingStyle] for this header.
  final StreamButtonThemeStyle? trailingStyle;
}

/// The default implementation of [StreamSheetHeader].
///
/// This widget renders the header with theming support from
/// [StreamSheetHeaderTheme]. It's used as the default factory
/// implementation in [StreamComponentFactory].
///
/// When only one of [StreamSheetHeaderProps.leading] /
/// [StreamSheetHeaderProps.trailing] is provided, the opposite side
/// reserves a 48×48 spacer (via [StreamVisibility.hidden]) so the title
/// stays visually centered.
///
/// See also:
///
///  * [StreamSheetHeader], the public API widget.
///  * [StreamSheetHeaderProps], which configures this widget.
class DefaultStreamSheetHeader extends StatelessWidget {
  /// Creates a default sheet header with the given [props].
  const DefaultStreamSheetHeader({super.key, required this.props});

  /// The properties that configure this sheet header.
  final StreamSheetHeaderProps props;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    final style = context.streamSheetHeaderTheme.style;
    final defaults = _StreamSheetHeaderStyleDefaults(context);

    final effectivePadding = props.padding ?? style?.padding ?? defaults.padding;
    final effectiveSpacing = props.spacing ?? style?.spacing ?? defaults.spacing;
    final effectiveTitleTextStyle = props.titleTextStyle ?? style?.titleTextStyle ?? defaults.titleTextStyle;
    final effectiveSubtitleTextStyle =
        props.subtitleTextStyle ?? style?.subtitleTextStyle ?? defaults.subtitleTextStyle;
    final effectiveLeadingStyle = props.leadingStyle ?? style?.leadingStyle;
    final effectiveTrailingStyle = props.trailingStyle ?? style?.trailingStyle;

    // Leading: caller-provided, or an auto-implied dismissal button when
    // the enclosing route implies one. A regular pushed page gets a back
    // chevron; anything else that implies dismissal (popup routes, dialogs,
    // fullscreen dialogs, custom modal routes) gets a cross.
    var leading = props.leading;
    if (leading == null && props.automaticallyImplyLeading) {
      final parentRoute = ModalRoute.of(context);
      if (parentRoute != null && parentRoute.impliesAppBarDismissal) {
        final isRegularPage = parentRoute is PageRoute && !parentRoute.fullscreenDialog;
        leading = StreamButton.icon(
          type: .outline,
          style: .secondary,
          icon: isRegularPage ? icons.chevronLeft : icons.xmark,
          onTap: Navigator.of(context).maybePop,
        );
      }
    }

    var trailing = props.trailing;

    // Propagate leading/trailing button style to any StreamButton in the
    // slot via a scoped StreamButtonTheme covering every style/type
    // combination. Per-instance themeStyle still wins via merge.
    if (leading != null && effectiveLeadingStyle != null) {
      leading = StreamButtonTheme(
        data: .all(.all(effectiveLeadingStyle)),
        child: leading,
      );
    }

    if (trailing != null && effectiveTrailingStyle != null) {
      trailing = StreamButtonTheme(
        data: .all(.all(effectiveTrailingStyle)),
        child: trailing,
      );
    }

    // When only one side is present, reserve a 48×48 spacer on the opposite
    // side so the title stays visually centered.
    if ((leading == null) != (trailing == null)) {
      const spacer = SizedBox.square(dimension: kMinInteractiveDimension);
      leading ??= StreamVisibility.hidden.apply(spacer);
      trailing ??= StreamVisibility.hidden.apply(spacer);
    }

    Widget? titleWidget;
    if (props.title case final title?) {
      titleWidget = AnimatedDefaultTextStyle(
        style: effectiveTitleTextStyle,
        textAlign: TextAlign.center,
        duration: kThemeChangeDuration,
        child: title,
      );
    }

    Widget? subtitleWidget;
    if (props.subtitle case final subtitle?) {
      subtitleWidget = AnimatedDefaultTextStyle(
        style: effectiveSubtitleTextStyle,
        textAlign: TextAlign.center,
        duration: kThemeChangeDuration,
        child: subtitle,
      );
    }

    return Padding(
      padding: effectivePadding,
      child: Row(
        spacing: effectiveSpacing,
        children: [
          ?leading,
          Expanded(
            child: Column(
              mainAxisSize: .min,
              spacing: spacing.xxs,
              children: [?titleWidget, ?subtitleWidget],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// Default style values for [StreamSheetHeader].
//
// These defaults are used when no explicit value is provided via
// constructor parameters or [StreamSheetHeaderStyle]. The defaults are
// context-aware and use values from [StreamColorScheme],
// [StreamTextTheme], and [StreamSpacing].
class _StreamSheetHeaderStyleDefaults extends StreamSheetHeaderStyle {
  _StreamSheetHeaderStyleDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  double get spacing => _spacing.sm;

  @override
  EdgeInsetsGeometry get padding => .all(_spacing.sm);

  @override
  TextStyle get titleTextStyle => _textTheme.headingSm.copyWith(color: _colorScheme.textPrimary);

  @override
  TextStyle get subtitleTextStyle => _textTheme.captionDefault.copyWith(color: _colorScheme.textTertiary);
}
