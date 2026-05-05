import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_app_bar_theme.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../buttons/stream_button.dart';
import 'stream_header_toolbar.dart';

/// A top-of-screen header for full-page surfaces in the Stream design system.
///
/// [StreamAppBar] arranges an optional centered [title] (and optional
/// [subtitle]) between optional [leading] and [trailing] widget slots —
/// typically a back button on the leading side and a primary action on the
/// trailing side.
///
/// The heading occupies the flexible center of the row, with a 48×48 spacer
/// reserved opposite a lone [leading] or [trailing] so the title stays
/// visually balanced.
///
/// When [leading] is null and [automaticallyImplyLeading] is true (the
/// default), a dismissal button is inserted if the enclosing route can pop:
///
///  * Inside a fullscreen dialog → a cross (`xmark`).
///  * Otherwise on iOS-style platforms (iOS / macOS) → a back chevron.
///  * Otherwise (Android / web / desktop) → an arrow-left.
///
/// A hairline `borderSubtle` border is drawn along the bottom edge to
/// separate the bar from page content — it's part of the bar's identity
/// rather than a configurable divider.
///
/// [StreamAppBar] implements [PreferredSizeWidget] so it can be passed
/// directly to [Scaffold.appBar].
///
/// {@tool snippet}
///
/// Use as a [Scaffold.appBar] with a centered title — the leading back button
/// is auto-implied:
///
/// ```dart
/// Scaffold(
///   appBar: StreamAppBar(title: const Text('Details')),
///   body: const _DetailsBody(),
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamAppBar] uses [StreamAppBarThemeData] for default styling — colours,
/// padding, spacing, title/subtitle text styles, and per-slot button style
/// propagation. Defaults are derived from [StreamColorScheme],
/// [StreamTextTheme], and [StreamSpacing].
///
/// See also:
///
///  * [StreamAppBarThemeData], for customizing appearance globally.
///  * [StreamAppBarTheme], for overriding theme in a subtree.
///  * [StreamSheetHeader], the equivalent for bottom-sheet / dialog chrome.
///  * [DefaultStreamAppBar], the default visual implementation.
class StreamAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a Stream app bar.
  StreamAppBar({
    super.key,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
    bool primary = true,
    StreamAppBarStyle? style,
  }) : props = .new(
         leading: leading,
         automaticallyImplyLeading: automaticallyImplyLeading,
         title: title,
         subtitle: subtitle,
         trailing: trailing,
         primary: primary,
         style: style,
       );

  /// The properties that configure this app bar.
  final StreamAppBarProps props;

  @override
  Size get preferredSize => const Size.fromHeight(kStreamHeaderHeight);

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).appBar;
    if (builder != null) return builder(context, props);
    return DefaultStreamAppBar(props: props);
  }
}

/// Properties for configuring a [StreamAppBar].
///
/// This class holds all configuration options for an app bar, allowing them
/// to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamAppBar], which uses these properties.
///  * [DefaultStreamAppBar], the default implementation.
class StreamAppBarProps {
  /// Creates properties for an app bar.
  const StreamAppBarProps({
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
  /// Typically a back button. The caller is responsible for the widget's
  /// own hit area; the app bar only reserves a 48×48 slot for symmetry.
  ///
  /// When null and [automaticallyImplyLeading] is true, a default dismissal
  /// button is inserted if the enclosing route can pop — a cross on
  /// fullscreen dialogs, a chevron on iOS-style platforms, an arrow-left
  /// elsewhere.
  final Widget? leading;

  /// Controls whether a default dismissal button is shown when [leading] is
  /// null.
  ///
  /// When true (the default), a button is inserted as the leading widget if
  /// the enclosing route can pop. The icon depends on the surface — see
  /// [StreamAppBar] for the full resolution table.
  final bool automaticallyImplyLeading;

  /// The primary content of the app bar.
  ///
  /// Typically a [Text] widget. Its text style is resolved from
  /// [StreamAppBarStyle.titleTextStyle] (defaults to `textTheme.headingSm` on
  /// `colorScheme.textPrimary`).
  final Widget? title;

  /// Additional content displayed below the [title].
  ///
  /// Typically a [Text] widget. Its text style is resolved from
  /// [StreamAppBarStyle.subtitleTextStyle] (defaults to
  /// `textTheme.captionDefault` on `colorScheme.textSecondary`).
  final Widget? subtitle;

  /// A widget to display after the [title].
  ///
  /// Typically a primary or overflow action. The caller is responsible for
  /// the widget's own hit area; the app bar only reserves a 48×48 slot for
  /// symmetry.
  final Widget? trailing;

  /// Whether this app bar is the topmost chrome of its surface.
  ///
  /// When true (the default), the app bar wraps itself in a
  /// `SafeArea(bottom: false)` so it clears the system top inset
  /// (status bar / notch) and horizontal insets.
  ///
  /// Set to false when the app bar isn't at the top of its surface (e.g.
  /// inside a sub-section of a page that has already consumed the top
  /// inset) so it doesn't double-pad.
  final bool primary;

  /// The visual style applied to this app bar.
  ///
  /// Resolution order per field: this [style] → ambient [StreamAppBarTheme]
  /// → token-backed defaults.
  final StreamAppBarStyle? style;
}

/// The default implementation of [StreamAppBar].
///
/// This widget renders the app bar with theming support from
/// [StreamAppBarTheme]. It's used as the default factory implementation in
/// [StreamComponentFactory].
///
/// The bar uses [NavigationToolbar] internally so the title is centred in
/// the bar's full width (rather than the leftover space between leading and
/// trailing), and only shifts when it would overlap a slot — keeping the
/// title visually centred even when leading and trailing have different
/// widths.
///
/// See also:
///
///  * [StreamAppBar], the public API widget.
///  * [StreamAppBarProps], which configures this widget.
class DefaultStreamAppBar extends StatelessWidget {
  /// Creates a default app bar with the given [props].
  const DefaultStreamAppBar({super.key, required this.props});

  /// The properties that configure this app bar.
  final StreamAppBarProps props;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    final style = context.streamAppBarTheme.style?.merge(props.style) ?? props.style;
    final defaults = _StreamAppBarStyleDefaults(context);

    final effectiveBackgroundColor = style?.backgroundColor ?? defaults.backgroundColor;
    final effectivePadding = style?.padding ?? defaults.padding;
    final effectiveSpacing = style?.spacing ?? defaults.spacing;
    final effectiveTitleTextStyle = style?.titleTextStyle ?? defaults.titleTextStyle;
    final effectiveSubtitleTextStyle = style?.subtitleTextStyle ?? defaults.subtitleTextStyle;
    final effectiveLeadingStyle = style?.leadingStyle ?? defaults.leadingStyle;
    final effectiveTrailingStyle = style?.trailingStyle ?? defaults.trailingStyle;

    // Leading: caller-provided, or an auto-implied dismissal button when
    // the enclosing route implies one. Fullscreen dialogs get a close
    // cross (modal presentation); everything else gets the platform-aware
    // back affordance.
    var leading = props.leading;
    if (leading == null && props.automaticallyImplyLeading) {
      final parentRoute = ModalRoute.of(context);
      if (parentRoute != null && parentRoute.impliesAppBarDismissal) {
        // Platform-aware back affordance — chevron on iOS-style
        // platforms, arrow-left elsewhere.
        final backIcon = switch (Theme.of(context).platform) {
          .iOS || .macOS => icons.chevronLeft,
          _ => icons.arrowLeft,
        };
        final useCloseIcon = parentRoute is PageRoute && parentRoute.fullscreenDialog;
        leading = StreamButton.icon(
          type: .ghost,
          style: .secondary,
          icon: Icon(useCloseIcon ? icons.xmark : backIcon),
          onPressed: Navigator.of(context).maybePop,
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

    Widget? middle;
    if (titleWidget != null || subtitleWidget != null) {
      middle = Column(
        mainAxisSize: .min,
        spacing: spacing.xxs,
        children: [?titleWidget, ?subtitleWidget],
      );
    }

    // The bar advertises a fixed height via [PreferredSizeWidget]; the
    // [SizedBox] enforces it for callers that don't honour the contract
    // (e.g. when placed directly inside a [Column] or a [Container]
    // rather than in a [Scaffold.appBar] slot).
    Widget bar = SizedBox(
      height: kStreamHeaderHeight,
      child: StreamHeaderToolbar(
        padding: effectivePadding,
        spacing: effectiveSpacing,
        leading: leading,
        middle: middle,
        trailing: trailing,
      ),
    );

    if (props.primary) {
      bar = SafeArea(bottom: false, child: bar);
    }

    // The bar's bottom edge is intentionally a hairline border in the
    // design system's `borderSubtle` colour — part of the bar's identity,
    // not a configurable divider.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        border: Border(
          bottom: BorderSide(color: context.streamColorScheme.borderSubtle),
        ),
      ),
      child: bar,
    );
  }
}

// Default style values for [StreamAppBar].
//
// These defaults are used when no explicit value is provided via constructor
// parameters or [StreamAppBarStyle]. The defaults are context-aware and
// use values from [StreamColorScheme], [StreamTextTheme], and [StreamSpacing].
class _StreamAppBarStyleDefaults extends StreamAppBarStyle {
  _StreamAppBarStyleDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  Color get backgroundColor => _colorScheme.backgroundElevation1;

  @override
  double get spacing => _spacing.sm;

  @override
  EdgeInsetsGeometry get padding => .all(_spacing.sm);

  @override
  TextStyle get titleTextStyle => _textTheme.headingSm.copyWith(color: _colorScheme.textPrimary);

  @override
  TextStyle get subtitleTextStyle => _textTheme.captionDefault.copyWith(color: _colorScheme.textSecondary);
}
