import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_select_input_theme.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import 'stream_flex.dart';
import 'stream_text_input.dart';

/// The visual treatment of a [StreamSelectInput]'s field.
enum StreamSelectInputType {
  /// A bordered field.
  outline,

  /// A borderless field that only shows its interaction ring and the border of
  /// the disabled, error and active states.
  ghost,
}

/// A select field styled for the Stream design system.
///
/// This is the field only: it renders the current [value] (or [hintText] when
/// nothing is selected) between a [leading] widget and a caret, and reports
/// presses through [onPressed]. Opening a menu is the caller's job, typically
/// with a menu anchor such as `StreamContextMenuAnchor`. That is what lets one
/// field drive more than one selection, for example a single audio field whose
/// menu picks both a microphone and a speaker.
///
/// Set [expanded] while that menu is open to get the active border and the
/// caret-up glyph.
///
/// The base border carries the disabled, error and active states, while hover
/// and focus draw a 2px ring. The ring paints 1px *outside* the field, so a
/// caller that clips this widget, or packs fields edge to edge, clips it.
///
/// The density matches [StreamTextInput], so a select and a text input in the
/// same form line up.
///
/// Visual properties are resolved in order:
/// 1. Per-instance [style] overrides
/// 2. [StreamSelectInputTheme] from the widget tree
/// 3. Design token fallbacks from [StreamColorScheme] and [StreamTextTheme]
///
/// {@tool snippet}
///
/// A labeled select whose menu is open:
///
/// ```dart
/// StreamSelectInput(
///   labelText: 'Language',
///   value: 'English',
///   expanded: isMenuOpen,
///   onPressed: toggleMenu,
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// A select with an error:
///
/// ```dart
/// StreamSelectInput(
///   hintText: 'Choose a language',
///   helperText: 'A language is required',
///   helperState: StreamHelperState.error,
///   onPressed: openMenu,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSelectInputTheme], for customizing select input appearance.
///  * [StreamSelectInputStyle], for the visual style properties.
///  * [StreamTextInput], the text field this select is designed to sit beside.
class StreamSelectInput extends StatelessWidget {
  /// Creates a select field.
  StreamSelectInput({
    super.key,
    String? labelText,
    Widget? leading,
    String? value,
    String? hintText,
    StreamSelectInputType type = StreamSelectInputType.outline,
    bool expanded = false,
    String? helperText,
    StreamHelperState? helperState,
    VoidCallback? onPressed,
    FocusNode? focusNode,
    StreamSelectInputStyle? style,
  }) : props = .new(
         labelText: labelText,
         leading: leading,
         value: value,
         hintText: hintText,
         type: type,
         expanded: expanded,
         helperText: helperText,
         helperState: helperState,
         onPressed: onPressed,
         focusNode: focusNode,
         style: style,
       );

  /// The props controlling the appearance and behavior of this select input.
  final StreamSelectInputProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).selectInput;
    if (builder != null) return builder(context, props);
    return DefaultStreamSelectInput(props: props);
  }
}

/// Properties for configuring a [StreamSelectInput].
///
/// This class holds all the configuration options for a select input,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamSelectInput], which uses these properties.
///  * [DefaultStreamSelectInput], the default implementation.
class StreamSelectInputProps {
  /// Creates properties for a select input.
  const StreamSelectInputProps({
    this.labelText,
    this.leading,
    this.value,
    this.hintText,
    this.type = StreamSelectInputType.outline,
    this.expanded = false,
    this.helperText,
    this.helperState,
    this.onPressed,
    this.focusNode,
    this.style,
  });

  /// Persistent label rendered above the field.
  ///
  /// When provided, also becomes the field's accessibility label.
  final String? labelText;

  /// An optional widget shown before the value, typically an [Icon].
  final Widget? leading;

  /// The text of the current selection.
  ///
  /// When null, [hintText] is shown in the hint style instead.
  final String? value;

  /// Placeholder text shown while [value] is null.
  final String? hintText;

  /// Whether the field is bordered.
  ///
  /// Defaults to [StreamSelectInputType.outline].
  final StreamSelectInputType type;

  /// Whether the field's menu is open.
  ///
  /// When true, the field shows the active border and a caret pointing up.
  /// Defaults to false.
  final bool expanded;

  /// Helper message displayed below the field.
  ///
  /// Rendered using [StreamHelperText]. When null, no helper text is shown.
  final String? helperText;

  /// The semantic state of [helperText].
  ///
  /// [StreamHelperState.error] also drives the field's error border, whether or
  /// not [helperText] is set.
  final StreamHelperState? helperState;

  /// Called when the field is pressed or activated from the keyboard.
  ///
  /// When null, the field is disabled.
  final VoidCallback? onPressed;

  /// Focus node for the field.
  final FocusNode? focusNode;

  /// Per-instance style overrides.
  ///
  /// Takes precedence over the inherited [StreamSelectInputTheme].
  final StreamSelectInputStyle? style;
}

/// Default implementation of [StreamSelectInput].
///
/// Renders the label, the bordered field with its leading widget, value and
/// caret, the hover and focus ring, and [StreamHelperText].
///
/// Styling is resolved from per-instance [StreamSelectInputStyle], inherited
/// [StreamSelectInputTheme], and design token fallbacks in that order.
///
/// See also:
///
///  * [StreamSelectInput], the public widget that delegates to this.
///  * [StreamSelectInputProps], the configuration properties.
class DefaultStreamSelectInput extends StatefulWidget {
  /// Creates a default select input implementation.
  const DefaultStreamSelectInput({super.key, required this.props});

  /// The props controlling the appearance and behavior of this select input.
  final StreamSelectInputProps props;

  @override
  State<DefaultStreamSelectInput> createState() => _DefaultStreamSelectInputState();
}

class _DefaultStreamSelectInputState extends State<DefaultStreamSelectInput> {
  var _hovered = false;
  var _focused = false;

  StreamSelectInputProps get props => widget.props;

  bool get _enabled => props.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    final style = props.style;
    final themeStyle = context.streamSelectInputTheme.style;
    final defaults = _StreamSelectInputDefaults(context);

    final hasError = props.helperState == StreamHelperState.error;
    final hasValue = props.value != null;

    final states = <WidgetState>{
      if (!_enabled) WidgetState.disabled,
      if (_enabled && _hovered) WidgetState.hovered,
      if (_enabled && _focused) WidgetState.focused,
      if (hasError) WidgetState.error,
    };

    final effectiveTextStyle = WidgetStateProperty.resolveAs(
      style?.textStyle ?? themeStyle?.textStyle ?? defaults.textStyle,
      states,
    );
    final effectiveHintStyle = WidgetStateProperty.resolveAs(
      style?.hintStyle ?? themeStyle?.hintStyle ?? defaults.hintStyle,
      states,
    );
    final effectiveLabelStyle = WidgetStateProperty.resolveAs(
      style?.labelStyle ?? themeStyle?.labelStyle ?? defaults.labelStyle,
      states,
    );

    final contentStyle = hasValue ? effectiveTextStyle : effectiveHintStyle;
    final effectiveIconColor = switch (style?.iconColor ?? themeStyle?.iconColor) {
      final iconColor? => WidgetStateProperty.resolveAs(iconColor, states),
      _ => contentStyle.color,
    };
    final effectiveIconSize = style?.iconSize ?? themeStyle?.iconSize ?? defaults.iconSize;
    final effectiveBorderRadius = style?.borderRadius ?? themeStyle?.borderRadius ?? defaults.borderRadius;
    final effectiveFillColor = style?.fillColor ?? themeStyle?.fillColor ?? defaults.fillColor;
    final effectiveContentPadding = style?.contentPadding ?? themeStyle?.contentPadding ?? defaults.contentPadding;

    final effectiveBorder = switch ((_enabled, hasError, props.expanded)) {
      (false, _, _) => style?.disabledBorder ?? themeStyle?.disabledBorder ?? defaults.disabledBorder,
      (_, true, _) => style?.errorBorder ?? themeStyle?.errorBorder ?? defaults.errorBorder,
      (_, _, true) => style?.activeBorder ?? themeStyle?.activeBorder ?? defaults.activeBorder,
      _ => switch ((style?.border ?? themeStyle?.border ?? defaults.border, props.type)) {
        (final border, .outline) => border,
        (final border, .ghost) => border.copyWith(color: Colors.transparent),
      },
    };

    final effectiveRing = switch ((_enabled, _focused, _hovered)) {
      (false, _, _) => null,
      (_, true, _) => style?.focusRing ?? themeStyle?.focusRing ?? defaults.focusRing,
      (_, _, true) => style?.hoverRing ?? themeStyle?.hoverRing ?? defaults.hoverRing,
      _ => null,
    };

    final field = Container(
      decoration: ShapeDecoration(
        color: effectiveFillColor,
        shape: RoundedSuperellipseBorder(
          side: effectiveBorder,
          borderRadius: effectiveBorderRadius,
        ),
      ),
      padding: effectiveContentPadding,
      child: IconTheme(
        data: IconThemeData(size: effectiveIconSize, color: effectiveIconColor),
        child: StreamRow(
          spacing: spacing.xs,
          children: [
            ?props.leading,
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  props.value ?? props.hintText ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: contentStyle,
                ),
              ),
            ),
            Icon(props.expanded ? icons.caretUp : icons.caretDown),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      expanded: props.expanded,
      label: props.labelText,
      value: props.value ?? props.hintText,
      child: StreamColumn(
        spacing: spacing.xs,
        mainAxisAlignment: .center,
        crossAxisAlignment: .start,
        children: [
          if (props.labelText case final labelText?)
            ExcludeSemantics(
              child: Text(
                labelText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: effectiveLabelStyle,
              ),
            ),
          FocusableActionDetector(
            enabled: _enabled,
            focusNode: props.focusNode,
            mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            onShowHoverHighlight: (value) => setState(() => _hovered = value),
            onShowFocusHighlight: (value) => setState(() => _focused = value),
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  props.onPressed?.call();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              onTap: props.onPressed,
              excludeFromSemantics: true,
              child: Stack(
                clipBehavior: .none,
                children: [
                  field,
                  if (effectiveRing case final ring?)
                    Positioned.fill(
                      left: -ring.width / 2,
                      top: -ring.width / 2,
                      right: -ring.width / 2,
                      bottom: -ring.width / 2,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: RoundedSuperellipseBorder(
                              side: ring,
                              borderRadius: effectiveBorderRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (props.helperText case final helperText?) StreamHelperText(text: helperText, state: props.helperState),
        ],
      ),
    );
  }
}

// Default theme values for [StreamSelectInput].
//
// These defaults are used when no explicit value is provided via
// [StreamSelectInputStyle] or [StreamSelectInputThemeData]. The text styles,
// icon size, radius and padding match the ones [StreamTextInput] falls back
// to, so the two fields line up in a form.
class _StreamSelectInputDefaults extends StreamSelectInputStyle {
  _StreamSelectInputDefaults(this.context);

  final BuildContext context;

  late final StreamRadius _radius = context.streamRadius;
  late final StreamSpacing _spacing = context.streamSpacing;
  late final StreamTextTheme _textTheme = context.streamTextTheme;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  @override
  TextStyle get textStyle => WidgetStateTextStyle.resolveWith((states) {
    final color = states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.textPrimary;
    return _textTheme.bodyDefault.copyWith(color: color);
  });

  @override
  TextStyle get hintStyle => WidgetStateTextStyle.resolveWith((states) {
    final color = states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.textTertiary;
    return _textTheme.bodyDefault.copyWith(color: color);
  });

  @override
  TextStyle get labelStyle => WidgetStateTextStyle.resolveWith((states) {
    final color = states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.textPrimary;
    return _textTheme.headingXs.copyWith(color: color);
  });

  @override
  double get iconSize => 20;

  @override
  BorderRadiusGeometry get borderRadius => BorderRadius.all(_radius.lg);

  @override
  BorderSide get border => BorderSide(color: _colorScheme.borderDefault);

  @override
  BorderSide get activeBorder => BorderSide(color: _colorScheme.borderActive);

  @override
  BorderSide get errorBorder => BorderSide(color: _colorScheme.borderError);

  @override
  BorderSide get disabledBorder => BorderSide(color: _colorScheme.borderDisabled);

  @override
  BorderSide get hoverRing => BorderSide(color: _colorScheme.borderHover, width: 2);

  @override
  BorderSide get focusRing => BorderSide(color: _colorScheme.borderFocus, width: 2);

  @override
  EdgeInsetsGeometry get contentPadding => .symmetric(vertical: _spacing.sm, horizontal: _spacing.md);
}
