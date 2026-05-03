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
import '../sheet/stream_sheet.dart';

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
/// pop. The icon and behaviour depend on the surface:
///
///  * Inside a standalone [StreamSheetRoute] (or its nested navigator's
///    first route), a cross (`xmark`) is shown — pressing it closes the
///    entire sheet.
///  * Inside a stacked [StreamSheetRoute] (one that covers another sheet),
///    a back chevron is shown — pressing it pops back to the previous
///    sheet.
///  * Inside deeper nested routes within a [StreamSheetRoute], a back
///    chevron is shown — pressing it pops one level inside the sheet.
///  * On any other modal surface (bottom sheets, dialogs, fullscreen
///    dialogs), a cross is shown.
///  * On regular pushed pages, a back chevron is shown.
///
/// The drag handle shown on iOS-style bottom sheets is intentionally *not*
/// part of this widget — the sheet itself owns that affordance, which
/// keeps this header usable for non-sheet surfaces (full-page modals,
/// dialog headers).
///
/// {@tool snippet}
///
/// Use inside a [StreamSheetRoute] with a confirm action — the leading
/// close button is auto-implied (cross at the root of a sheet, back
/// chevron when stacked over another sheet):
///
/// ```dart
/// showStreamSheet<ProfileEdits>(
///   context: context,
///   builder: (sheetContext, scrollController) => Column(
///     mainAxisSize: MainAxisSize.min,
///     children: [
///       StreamSheetHeader(
///         title: const Text('Edit profile'),
///         trailing: StreamButton.icon(
///           icon: Icon(context.streamIcons.checkmark),
///           onPressed: () => Navigator.of(sheetContext).pop(edits),
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
    bool primary = true,
    StreamSheetHeaderStyle? style,
  }) : props = .new(
         leading: leading,
         automaticallyImplyLeading: automaticallyImplyLeading,
         title: title,
         subtitle: subtitle,
         trailing: trailing,
         primary: primary,
         style: style,
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
    this.primary = true,
    this.style,
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

  /// Whether this header is the topmost chrome of its surface.
  ///
  /// When true (the default), the header wraps itself in a
  /// `SafeArea(bottom: false)` so it clears the system top inset
  /// (status bar / notch) and horizontal insets.
  ///
  /// Set to false when the header isn't at the top of its surface
  /// (e.g. inside a sub-section of a page that has already consumed
  /// the top inset) so it doesn't double-pad.
  final bool primary;

  /// The visual style applied to this header.
  ///
  /// Resolution order per field: this [style] → ambient
  /// [StreamSheetHeaderTheme] → token-backed defaults.
  final StreamSheetHeaderStyle? style;
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

    final style = context.streamSheetHeaderTheme.style?.merge(props.style) ?? props.style;
    final defaults = _StreamSheetHeaderStyleDefaults(context);

    final effectivePadding = style?.padding ?? defaults.padding;
    final effectiveSpacing = style?.spacing ?? defaults.spacing;
    final effectiveTitleTextStyle = style?.titleTextStyle ?? defaults.titleTextStyle;
    final effectiveSubtitleTextStyle = style?.subtitleTextStyle ?? defaults.subtitleTextStyle;
    final effectiveLeadingStyle = style?.leadingStyle ?? defaults.leadingStyle;
    final effectiveTrailingStyle = style?.trailingStyle ?? defaults.trailingStyle;

    // Leading: caller-provided, or an auto-implied dismissal button when
    // the enclosing route implies one.
    //
    // Inside a [StreamSheetRoute], the dismissal semantics shift:
    //   * The sheet's root content (or the first route in its nested
    //     navigator) shows a cross — pressing it closes the entire sheet.
    //   * Subsequent routes pushed inside the sheet's nested navigator
    //     show a back chevron — pressing it pops one level inside the
    //     sheet.
    //
    // For non-sheet routes the legacy heuristic applies: a regular pushed
    // page gets a back chevron, anything else that implies dismissal
    // (popup routes, dialogs, fullscreen dialogs, custom modal routes)
    // gets a cross.
    var leading = props.leading;
    if (leading == null && props.automaticallyImplyLeading) {
      final parentRoute = ModalRoute.of(context);
      final sheetRoute = StreamSheetRoute.maybeOf(context);

      IconData? icon;
      VoidCallback? onPressed;

      if (parentRoute is StreamSheetRoute) {
        // Header sits directly on a [StreamSheetRoute] (no nested nav
        // layer between us and the route). A stacked sheet's pop
        // returns to the parent sheet — show a back chevron. A root
        // sheet's pop dismisses it entirely — show a close cross.
        icon = parentRoute.isStacked ? icons.chevronLeft : icons.xmark;
        onPressed = Navigator.of(context).maybePop;
      } else if (sheetRoute != null && parentRoute != null) {
        // Header is inside the enclosing sheet's nested navigator
        // (see [showStreamSheet]'s `useNestedNavigation`).
        if (parentRoute.isFirst) {
          // First nested route: tapping the icon dismisses the *whole*
          // sheet via [popSheet]. Mirror the non-nested case for the
          // icon — chevron when the enclosing sheet is stacked (pop
          // reveals the parent), cross when it's a root sheet.
          icon = sheetRoute.isStacked ? icons.chevronLeft : icons.xmark;
          onPressed = () => StreamSheetRoute.popSheet(context);
        } else {
          // Deeper nested route: pop one level inside the sheet.
          icon = icons.chevronLeft;
          onPressed = Navigator.of(context).maybePop;
        }
      } else if (parentRoute != null && parentRoute.impliesAppBarDismissal) {
        final isRegularPage = parentRoute is PageRoute && !parentRoute.fullscreenDialog;
        if (isRegularPage) {
          // Match the platform-aware leading [StreamAppBar] auto-implies
          // for regular pushed pages — chevron on iOS-style platforms,
          // arrow elsewhere. Sheet contexts above keep the chevron
          // because they're iOS-modal-style on every platform.
          icon = switch (Theme.of(context).platform) {
            TargetPlatform.iOS || TargetPlatform.macOS => icons.chevronLeft,
            _ => icons.arrowLeft,
          };
        } else {
          icon = icons.xmark;
        }
        onPressed = Navigator.of(context).maybePop;
      }

      if (icon != null && onPressed != null) {
        leading = StreamButton.icon(
          type: .outline,
          style: .secondary,
          icon: Icon(icon),
          onPressed: onPressed,
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

    Widget header = Padding(
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

    // When [primary] is true, wrap in a `SafeArea(bottom: false)` so
    // the header clears the system top + horizontal insets when used
    // at the top of a screen. Inside a [StreamSheetRoute] the sheet
    // already strips MediaQuery's top padding, so this is a no-op
    // there.
    if (props.primary) {
      header = SafeArea(bottom: false, child: header);
    }

    return header;
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
