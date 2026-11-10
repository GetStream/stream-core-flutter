import 'package:flutter/widgets.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_empty_state_theme.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// What a place shows while it has nothing in it: an icon over a title, an
/// optional description and an optional action, centred.
///
/// Mirrors the `Web / Empty State` component from the design. The title and
/// description are centred and wrap at [StreamEmptyStateThemeData.maxTextWidth].
/// Screen readers announce the title as a heading.
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
  StreamEmptyState({
    super.key,
    required Widget icon,
    required Widget title,
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
  const StreamEmptyStateProps({
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  /// The icon at the top.
  ///
  /// Typically an [Icon]; the empty state provides its size and color.
  final Widget icon;

  /// What is missing.
  ///
  /// Typically a [Text]; the empty state provides its text style, centres it
  /// and marks it as a heading for screen readers.
  final Widget title;

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
    final effectiveSpacing = theme.spacing ?? defaults.spacing;
    final effectiveTextSpacing = theme.textSpacing ?? defaults.textSpacing;
    final effectiveMaxTextWidth = theme.maxTextWidth ?? defaults.maxTextWidth;

    return Padding(
      padding: effectivePadding,
      child: Column(
        mainAxisSize: .min,
        spacing: effectiveSpacing,
        children: [
          IconTheme.merge(
            data: IconThemeData(size: effectiveIconSize, color: effectiveIconColor),
            child: props.icon,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveMaxTextWidth),
            child: Column(
              mainAxisSize: .min,
              spacing: effectiveTextSpacing,
              children: [
                Semantics(
                  header: true,
                  child: DefaultTextStyle.merge(
                    textAlign: .center,
                    style: effectiveTitleTextStyle,
                    child: props.title,
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
          ?props.action,
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
  Color get iconColor => _colorScheme.textSecondary;

  @override
  TextStyle get titleTextStyle => _textTheme.headingXs.copyWith(color: _colorScheme.textPrimary);

  @override
  TextStyle get descriptionTextStyle => _textTheme.captionDefault.copyWith(color: _colorScheme.textSecondary);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.symmetric(horizontal: _spacing.xl, vertical: _spacing.xxxl);

  @override
  double get spacing => _spacing.sm;

  @override
  double get textSpacing => _spacing.xxs;

  @override
  double get maxTextWidth => 320;
}
