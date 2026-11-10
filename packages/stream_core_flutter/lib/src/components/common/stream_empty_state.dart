import 'package:flutter/widgets.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_empty_state_theme.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// What a place shows while it has nothing in it: an icon over a title, a
/// description and an optional action, centred.
///
/// Mirrors the `Core / Mobile / Empty State` component from the design. Either
/// the title or the description can be left out, but not both. The text is
/// centred and wraps at the available width, or sooner when
/// [StreamEmptyStateThemeData.maxTextWidth] is set. Screen readers announce the
/// title as a heading.
///
/// {@tool snippet}
///
/// Say a list has no items yet:
///
/// ```dart
/// StreamEmptyState(
///   icon: Icon(context.streamIcons.folder),
///   title: const Text('No files yet'),
///   description: const Text('Files you add show up here.'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// A single line of text under the icon:
///
/// ```dart
/// StreamEmptyState(
///   icon: Icon(context.streamIcons.search),
///   description: const Text('No results'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Offer to try again after a failure:
///
/// ```dart
/// StreamEmptyState(
///   icon: Icon(context.streamIcons.exclamationCircleFill),
///   title: const Text("Couldn't load files"),
///   description: const Text('Check your connection and try again.'),
///   action: StreamButton(
///     style: StreamButtonStyle.secondary,
///     type: StreamButtonType.outline,
///     onPressed: retry,
///     child: const Text('Try again'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmptyStateTheme], for customizing the appearance.
class StreamEmptyState extends StatelessWidget {
  /// Creates an empty state.
  ///
  /// At least one of [title] and [description] must be non-null.
  StreamEmptyState({
    super.key,
    required Widget icon,
    Widget? title,
    Widget? description,
    Widget? action,
  }) : props = .new(
         icon: icon,
         title: title,
         description: description,
         action: action,
       );

  /// The properties that configure this empty state.
  final StreamEmptyStateProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).emptyState;
    if (builder != null) return builder(context, props);
    return DefaultStreamEmptyState(props: props);
  }
}

/// Properties for configuring a [StreamEmptyState].
///
/// This class holds all the configuration options for an empty state,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamEmptyState], which uses these properties.
///  * [DefaultStreamEmptyState], the default implementation.
class StreamEmptyStateProps {
  /// Creates properties for an empty state.
  ///
  /// At least one of [title] and [description] must be non-null.
  const StreamEmptyStateProps({
    required this.icon,
    this.title,
    this.description,
    this.action,
  }) : assert(title != null || description != null, 'An empty state needs a title, a description or both.');

  /// The icon at the top.
  ///
  /// Typically an [Icon]; the empty state provides its size and color.
  final Widget icon;

  /// What is missing.
  ///
  /// Typically a [Text]; the empty state provides its text style, centres it
  /// and marks it as a heading for screen readers. When null, the description
  /// sits right under the icon.
  final Widget? title;

  /// Why it is missing, or what would fill it.
  ///
  /// Typically a [Text]; the empty state provides its text style and centres
  /// it. When null, nothing is shown under the title.
  final Widget? description;

  /// A control under the text, such as a button to try again.
  ///
  /// When null, nothing is shown under the text.
  final Widget? action;
}

/// The default implementation of [StreamEmptyState].
///
/// See also:
///
///  * [StreamEmptyState], the public API widget.
///  * [StreamEmptyStateProps], which configures this widget.
class DefaultStreamEmptyState extends StatelessWidget {
  /// Creates a default empty state with the given [props].
  const DefaultStreamEmptyState({super.key, required this.props});

  /// The properties that configure this empty state.
  final StreamEmptyStateProps props;

  @override
  Widget build(BuildContext context) {
    final theme = context.streamEmptyStateTheme;
    final defaults = _StreamEmptyStateThemeDefaults(context);

    final effectiveIconSize = theme.iconSize ?? defaults.iconSize;
    final effectiveIconColor = theme.iconColor ?? defaults.iconColor;
    final effectiveTitleTextStyle = theme.titleTextStyle ?? defaults.titleTextStyle;
    final effectiveDescriptionTextStyle = theme.descriptionTextStyle ?? defaults.descriptionTextStyle;
    final effectivePadding = theme.padding ?? defaults.padding;
    final effectiveIconSpacing = theme.iconSpacing ?? defaults.iconSpacing;
    final effectiveTextSpacing = theme.textSpacing ?? defaults.textSpacing;
    final effectiveActionSpacing = theme.actionSpacing ?? defaults.actionSpacing;
    final effectiveMaxTextWidth = theme.maxTextWidth ?? double.infinity;

    return Padding(
      padding: effectivePadding,
      child: Column(
        mainAxisSize: .min,
        children: [
          IconTheme.merge(
            data: IconThemeData(size: effectiveIconSize, color: effectiveIconColor),
            child: props.icon,
          ),
          SizedBox(height: effectiveIconSpacing),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveMaxTextWidth),
            child: Column(
              mainAxisSize: .min,
              spacing: effectiveTextSpacing,
              children: [
                if (props.title case final title?)
                  Semantics(
                    header: true,
                    child: DefaultTextStyle.merge(
                      textAlign: .center,
                      style: effectiveTitleTextStyle,
                      child: title,
                    ),
                  ),
                if (props.description case final description?)
                  DefaultTextStyle.merge(
                    textAlign: .center,
                    style: effectiveDescriptionTextStyle,
                    child: description,
                  ),
              ],
            ),
          ),
          if (props.action case final action?) ...[
            SizedBox(height: effectiveActionSpacing),
            action,
          ],
        ],
      ),
    );
  }
}

// Default theme values for [StreamEmptyState].
class _StreamEmptyStateThemeDefaults extends StreamEmptyStateThemeData {
  _StreamEmptyStateThemeDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  double get iconSize => 32;

  @override
  Color get iconColor => _colorScheme.textTertiary;

  @override
  TextStyle get titleTextStyle => _textTheme.headingSm.copyWith(color: _colorScheme.textPrimary);

  @override
  TextStyle get descriptionTextStyle => _textTheme.bodyDefault.copyWith(color: _colorScheme.textSecondary);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.symmetric(horizontal: _spacing.md, vertical: _spacing.xxxl);

  @override
  double get iconSpacing => _spacing.sm;

  @override
  double get textSpacing => _spacing.xs;

  @override
  double get actionSpacing => _spacing.md;
}
