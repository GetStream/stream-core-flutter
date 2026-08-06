import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_bottom_app_bar_theme.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_floating_fade.dart';
import '../../theme/stream_surface_style.dart';
import '../../theme/stream_theme_extensions.dart';
import 'stream_toolbar.dart';
import 'stream_toolbar_scope.dart';

/// A bottom-of-screen toolbar for full-page surfaces in the Stream design
/// system.
///
/// [StreamBottomAppBar] arranges an optional centered [title] between
/// optional [leading] and [trailing] widget slots — typically a primary
/// action on either side (e.g. a share button and a gallery toggle).
///
/// The title occupies the flexible center of the row, with the wider of
/// [leading] / [trailing] mirrored on the opposite side so the title stays
/// geometrically centred.
///
/// A hairline `borderSubtle` border is drawn along the top edge to separate
/// the bar from page content — it's part of the bar's identity rather than
/// a configurable divider.
///
/// [StreamBottomAppBar] implements [PreferredSizeWidget] so it can be passed
/// directly to [Scaffold.bottomNavigationBar].
///
/// {@tool snippet}
///
/// Use as a [Scaffold.bottomNavigationBar] with a centered counter — leading
/// and trailing icons sit flush at the screen edges:
///
/// ```dart
/// Scaffold(
///   bottomNavigationBar: StreamBottomAppBar(
///     leading: StreamButton.icon(
///       icon: Icon(context.streamIcons.export),
///       onPressed: _shareImage,
///     ),
///     title: const Text('1 of 9'),
///     trailing: StreamButton.icon(
///       icon: Icon(context.streamIcons.gallery),
///       onPressed: _openGrid,
///     ),
///   ),
///   body: ...,
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamBottomAppBar] uses [StreamBottomAppBarThemeData] for default
/// styling — colours, padding, spacing, title text style, and per-slot
/// button style propagation. Defaults are derived from [StreamColorScheme],
/// [StreamTextTheme], and [StreamSpacing].
///
/// See also:
///
///  * [StreamBottomAppBarThemeData], for customizing appearance globally.
///  * [StreamBottomAppBarTheme], for overriding theme in a subtree.
///  * [StreamAppBar], the equivalent for top-level screen chrome.
///  * [DefaultStreamBottomAppBar], the default visual implementation.
class StreamBottomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a Stream bottom app bar.
  StreamBottomAppBar({
    super.key,
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
    bool primary = true,
    StreamBottomAppBarStyle? style,
  }) : props = .new(
         leading: leading,
         title: title,
         subtitle: subtitle,
         trailing: trailing,
         primary: primary,
         style: style,
       );

  /// The properties that configure this bottom app bar.
  final StreamBottomAppBarProps props;

  @override
  Size get preferredSize => const Size.fromHeight(kStreamToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).bottomAppBar;
    if (builder != null) return builder(context, props);
    return DefaultStreamBottomAppBar(props: props);
  }
}

/// Properties for configuring a [StreamBottomAppBar].
///
/// This class holds all configuration options for a bottom app bar, allowing
/// them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamBottomAppBar], which uses these properties.
///  * [DefaultStreamBottomAppBar], the default implementation.
class StreamBottomAppBarProps {
  /// Creates properties for a bottom app bar.
  const StreamBottomAppBarProps({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.primary = true,
    this.style,
  });

  /// A widget to display before the [title].
  ///
  /// Typically a primary action button. The caller is responsible for the
  /// widget's own size and hit area.
  final Widget? leading;

  /// The primary content of the bar.
  ///
  /// Typically a [Text] widget — for example, a page counter like `1 of 9`.
  /// Its text style is resolved from [StreamBottomAppBarStyle.titleTextStyle]
  /// (defaults to `textTheme.headingSm` on `colorScheme.textPrimary`).
  final Widget? title;

  /// Additional content displayed below the [title].
  ///
  /// Typically a [Text] widget — for example, a hint label below a
  /// page counter. Its text style is resolved from
  /// [StreamBottomAppBarStyle.subtitleTextStyle] (defaults to
  /// `textTheme.captionDefault` on `colorScheme.textSecondary`).
  final Widget? subtitle;

  /// A widget to display after the [title].
  ///
  /// Typically a primary action button. The caller is responsible for the
  /// widget's own size and hit area.
  final Widget? trailing;

  /// Whether this bar is the bottommost chrome of its surface.
  ///
  /// When true (the default), the bar wraps itself in a
  /// `SafeArea(top: false)` so it clears the system bottom inset
  /// (home indicator) and horizontal insets.
  ///
  /// Set to false when the bar isn't at the bottom of its surface (e.g.
  /// inside a sub-section of a page that has already consumed the
  /// bottom inset) so it doesn't double-pad.
  final bool primary;

  /// The visual style applied to this bar.
  ///
  /// Resolution order per field: this [style] → ambient
  /// [StreamBottomAppBarTheme] → token-backed defaults.
  final StreamBottomAppBarStyle? style;
}

/// The default implementation of [StreamBottomAppBar].
///
/// This widget renders the bottom app bar with theming support from
/// [StreamBottomAppBarTheme]. It's used as the default factory
/// implementation in [StreamComponentFactory].
///
/// The title slot is centred in the bar's full inner width via
/// [StreamToolbar], which reserves symmetric space around the middle
/// so an asymmetric leading and trailing don't shift the title off-centre.
///
/// See also:
///
///  * [StreamBottomAppBar], the public API widget.
///  * [StreamBottomAppBarProps], which configures this widget.
class DefaultStreamBottomAppBar extends StatelessWidget {
  /// Creates a default bottom app bar with the given [props].
  const DefaultStreamBottomAppBar({super.key, required this.props});

  /// The properties that configure this bottom app bar.
  final StreamBottomAppBarProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final bottomAppBarTheme = context.streamBottomAppBarTheme;

    final style = bottomAppBarTheme.style?.merge(props.style) ?? props.style;
    final defaults = _StreamBottomAppBarStyleDefaults(context);

    final effectiveBehavior = style?.behavior ?? defaults.behavior;

    final effectiveBackgroundColor = style?.backgroundColor ?? defaults.backgroundColor;
    final effectiveFloatingBackgroundColor = style?.floatingBackgroundColor ?? defaults.floatingBackgroundColor;
    final effectivePadding = style?.padding ?? defaults.padding;
    final effectiveSpacing = style?.spacing ?? defaults.spacing;
    final effectiveTitleTextStyle = style?.titleTextStyle ?? defaults.titleTextStyle;
    final effectiveSubtitleTextStyle = style?.subtitleTextStyle ?? defaults.subtitleTextStyle;
    final effectiveLeadingStyle = style?.leadingStyle ?? defaults.leadingStyle;
    final effectiveTrailingStyle = style?.trailingStyle ?? defaults.trailingStyle;

    var leading = props.leading;
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
      // Title and subtitle read as a single announcement. The bottom bar
      // is a secondary toolbar — it doesn't claim the route's accessible
      // name or expose itself as a heading.
      middle = MergeSemantics(
        child: Column(
          mainAxisSize: .min,
          spacing: spacing.xxs,
          children: [?titleWidget, ?subtitleWidget],
        ),
      );
    }

    // The bar advertises a fixed height via [PreferredSizeWidget]; the
    // [SizedBox] enforces it for callers that don't honour the contract
    // (e.g. when placed directly inside a [Column] or a [Container]
    // rather than in a [Scaffold.bottomNavigationBar] slot).
    Widget bar = SizedBox(
      height: kStreamToolbarHeight,
      child: StreamToolbar(
        padding: effectivePadding,
        spacing: effectiveSpacing,
        leading: leading,
        middle: middle,
        trailing: trailing,
      ),
    );

    if (props.primary) {
      bar = SafeArea(top: false, child: bar);
    }

    // The bar's top edge is intentionally a hairline border in the design
    // system's `borderSubtle` colour — part of the bar's identity, not a
    // configurable divider. When floating, the border is dropped and the bar
    // fades into the content behind it via a gradient instead.
    //
    // The outer [Semantics] keeps the bar's children grouped for screen
    // readers, so leading, title, subtitle, and trailing aren't intermixed
    // with surrounding page content. The inner [Semantics] forces each
    // slot's semantics onto its own node — without it, a raw
    // [GestureDetector] in a slot would attach its action to the outer
    // container and collapse the bar into a single tappable focus stop.
    bar = Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: switch (effectiveBehavior) {
            .floating => null,
            .regular => effectiveBackgroundColor,
          },
          gradient: switch (effectiveBehavior) {
            .floating => _getFloatingGradient(context, color: effectiveFloatingBackgroundColor),
            .regular => null,
          },
          border: switch (effectiveBehavior) {
            .floating => null,
            .regular => Border(top: BorderSide(color: context.streamColorScheme.borderSubtle)),
          },
        ),
        child: Semantics(explicitChildNodes: true, child: bar),
      ),
    );

    // Publish the resolved behaviour to the slots via a [StreamToolbarScope] so
    // slot widgets ([StreamToolbarButton], footer actions, ...) match the bar.
    return StreamToolbarScope(behavior: effectiveBehavior, child: bar);
  }

  LinearGradient _getFloatingGradient(
    BuildContext context, {
    required Color color,
  }) {
    // Compute the fraction of the total bar height occupied by the system
    // safe area so the gradient is solid through the bottom inset and fades up
    // through the toolbar zone above it.
    final safeAreaBottom = props.primary ? MediaQuery.paddingOf(context).bottom : 0.0;
    final totalHeight = safeAreaBottom + kStreamToolbarHeight;
    final solidFraction = totalHeight > 0 ? safeAreaBottom / totalHeight : 0.0;

    return streamFloatingFadeLinearGradient(
      color: color,
      solidFraction: solidFraction,
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
  }
}

// Default style values for [StreamBottomAppBar].
//
// These defaults are used when no explicit value is provided via constructor
// parameters or [StreamBottomAppBarStyle]. The defaults are context-aware
// and use values from [StreamColorScheme], [StreamTextTheme], and
// [StreamSpacing].
class _StreamBottomAppBarStyleDefaults extends StreamBottomAppBarStyle {
  _StreamBottomAppBarStyleDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;
  late final StreamSurfaceStyle _appStyle = _context.streamTheme.appStyle;

  @override
  StreamSurfaceStyle get behavior => _appStyle;

  @override
  Color get backgroundColor => _colorScheme.backgroundElevation1;

  @override
  Color get floatingBackgroundColor => _colorScheme.backgroundElevation0;

  @override
  double get spacing => _spacing.sm;

  @override
  EdgeInsetsGeometry get padding => .all(_spacing.sm);

  @override
  TextStyle get titleTextStyle => _textTheme.headingSm.copyWith(color: _colorScheme.textPrimary);

  @override
  TextStyle get subtitleTextStyle => _textTheme.captionDefault.copyWith(color: _colorScheme.textSecondary);
}
