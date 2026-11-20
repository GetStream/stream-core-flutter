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

/// A select field styled for the Stream design system.
///
/// This is the field only: it renders the current `value` (or `hintText` when
/// nothing is selected) between a `leading` widget and a caret, and reports
/// presses through `onPressed`. Opening a menu is the caller's job, for example
/// with a [MenuAnchor] whose builder toggles its controller from `onPressed`.
/// That is what lets one field drive more than one selection, for example a
/// single audio field whose menu picks both a microphone and a speaker.
///
/// Set `expanded` while that menu is open to get the active border and the
/// caret-up glyph.
///
/// The base border carries the disabled, error and active states, while hover
/// and focus draw a ring centered on the field's outer edge, so half its width
/// (1px for the default 2px ring) paints outside the field. A clipping ancestor
/// cuts that part off, and a sibling packed edge to edge can paint over it.
///
/// The field's height and padding match [StreamTextInput], so a select and a
/// text input in the same form line up. For a borderless field, pass
/// [StreamSelectInputStyle.ghost] as the `style`.
///
/// Visual properties are resolved in order:
/// 1. Per-instance `style` overrides
/// 2. [StreamSelectInputTheme] from the widget tree
/// 3. Design token fallbacks from [StreamColorScheme], [StreamTextTheme],
///    [StreamSpacing] and [StreamRadius]
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
/// {@tool snippet}
///
/// A borderless select:
///
/// ```dart
/// StreamSelectInput(
///   value: 'MacBook Pro Microphone',
///   semanticLabel: 'Microphone',
///   style: const StreamSelectInputStyle.ghost(),
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
    String? semanticLabel,
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
         semanticLabel: semanticLabel,
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
    this.semanticLabel,
    this.expanded = false,
    this.helperText,
    this.helperState,
    this.onPressed,
    this.focusNode,
    this.style,
  });

  /// Persistent label rendered above the field.
  ///
  /// When provided, also becomes the field's semantic label, unless
  /// [semanticLabel] is set.
  final String? labelText;

  /// An optional widget shown before the value, typically an [Icon].
  final Widget? leading;

  /// The text of the current selection.
  ///
  /// When null, [hintText] is shown in the hint style instead.
  final String? value;

  /// Placeholder text shown while [value] is null.
  ///
  /// While nothing is selected it is announced as the field's hint, or as its
  /// semantic label when neither [labelText] nor [semanticLabel] is set.
  final String? hintText;

  /// The label announced by screen readers for this field.
  ///
  /// Replaces [labelText] as the announced label without changing what is
  /// drawn. Set it when the field has no visible label, for example a device
  /// picker that only shows an icon and the selected device.
  final String? semanticLabel;

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

  /// An optional focus node for the field.
  ///
  /// If null, the field creates and manages its own.
  final FocusNode? focusNode;

  /// Per-instance style overrides.
  ///
  /// Takes precedence over the inherited [StreamSelectInputTheme].
  final StreamSelectInputStyle? style;
}

/// Default implementation of [StreamSelectInput].
///
/// Renders the label, the field with its leading widget, value and caret, the
/// hover and focus ring, and [StreamHelperText].
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
  void didUpdateWidget(DefaultStreamSelectInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new focus node rebuilds the FocusableActionDetector (it is keyed on the
    // node), which reports hover and focus afresh, so drop the old highlights.
    if (oldWidget.props.focusNode != props.focusNode) {
      _hovered = false;
      _focused = false;
    }
  }

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
    final effectiveFillColor = WidgetStateProperty.resolveAs(
      style?.fillColor ?? themeStyle?.fillColor ?? defaults.fillColor,
      states,
    );
    final effectiveContentPadding = style?.contentPadding ?? themeStyle?.contentPadding ?? defaults.contentPadding;

    final effectiveBorder = _resolveSide(
      switch ((_enabled, hasError, props.expanded)) {
        (false, _, _) => style?.disabledBorder ?? themeStyle?.disabledBorder ?? defaults.disabledBorder,
        (_, true, _) => style?.errorBorder ?? themeStyle?.errorBorder ?? defaults.errorBorder,
        (_, _, true) => style?.activeBorder ?? themeStyle?.activeBorder ?? defaults.activeBorder,
        _ => style?.border ?? themeStyle?.border ?? defaults.border,
      },
      states,
    );

    final ringSide = switch ((_enabled, _focused, _hovered)) {
      (false, _, _) => null,
      (_, true, _) => style?.focusRing ?? themeStyle?.focusRing ?? defaults.focusRing,
      (_, _, true) => style?.hoverRing ?? themeStyle?.hoverRing ?? defaults.hoverRing,
      _ => null,
    };
    final effectiveRing = ringSide == null ? null : _resolveSide(ringSide, states);

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

    final semanticLabel = props.semanticLabel ?? props.labelText;
    final hasSemanticLabel = semanticLabel != null;

    return Semantics(
      container: true,
      button: true,
      enabled: _enabled,
      expanded: props.expanded,
      label: hasSemanticLabel ? semanticLabel : (hasValue ? null : props.hintText),
      value: props.value,
      hint: hasSemanticLabel && !hasValue ? props.hintText : null,
      onTap: props.onPressed,
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
            key: ObjectKey(props.focusNode),
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
                    // Offsets the ring's box so the stroke is centered on the
                    // field's outer edge whatever its strokeAlign: an inside
                    // stroke grows the box by half the width, an outside one
                    // shrinks it by the same.
                    Positioned.fill(
                      left: ring.width * ring.strokeAlign / 2,
                      top: ring.width * ring.strokeAlign / 2,
                      right: ring.width * ring.strokeAlign / 2,
                      bottom: ring.width * ring.strokeAlign / 2,
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

// Resolves a side that may be a WidgetStateBorderSide. That class is a
// WidgetStateProperty<BorderSide?>, so WidgetStateProperty.resolveAs<BorderSide>
// would not see it; a side that resolves to null draws nothing.
BorderSide _resolveSide(BorderSide side, Set<WidgetState> states) {
  return WidgetStateProperty.resolveAs<BorderSide?>(side, states) ?? BorderSide.none;
}

// Default theme values for [StreamSelectInput].
//
// These defaults are used when no explicit value is provided via
// [StreamSelectInputStyle] or [StreamSelectInputThemeData]. The value and hint
// styles, icon size, radius and padding match the ones [StreamTextInput] falls
// back to, so the two fields line up in a form. The label differs: it uses
// headingXs, as the select design does, and dims when the field is disabled.
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
