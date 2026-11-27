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
/// The caller opens the menu from [onPressed] and sets `isOpen` while it shows.
///
/// The field's horizontal padding, radius and text styles match
/// [StreamTextInput], so a select and a text input in the same form line up.
/// For a borderless field,
/// pass [StreamSelectInputStyle.ghost] as the `style`.
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
///   valueText: 'English',
///   isOpen: isMenuOpen,
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
///   valueText: 'MacBook Pro Microphone',
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
    String? valueText,
    String? hintText,
    String? semanticLabel,
    bool isOpen = false,
    String? helperText,
    StreamHelperState? helperState,
    VoidCallback? onPressed,
    FocusNode? focusNode,
    bool autofocus = false,
    StreamSelectInputStyle? style,
  }) : props = .new(
         labelText: labelText,
         leading: leading,
         valueText: valueText,
         hintText: hintText,
         semanticLabel: semanticLabel,
         isOpen: isOpen,
         helperText: helperText,
         helperState: helperState,
         onPressed: onPressed,
         focusNode: focusNode,
         autofocus: autofocus,
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
    this.valueText,
    this.hintText,
    this.semanticLabel,
    this.isOpen = false,
    this.helperText,
    this.helperState,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
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
  /// When null or empty, [hintText] is shown in the hint style instead.
  final String? valueText;

  /// Placeholder text shown while [valueText] is null or empty.
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
  /// While true, the caret points up and the field's styles resolve with
  /// [WidgetState.selected], which the default border and icon color turn into
  /// their active colors. Screen readers can then collapse the field, and
  /// expand it while false, both through [onPressed].
  ///
  /// Defaults to false.
  final bool isOpen;

  /// Helper message displayed below the field.
  ///
  /// Rendered using [StreamHelperText]. When null, no helper text is shown.
  final String? helperText;

  /// The semantic state of [helperText].
  ///
  /// [StreamHelperState.error] also drives the field's error border, whether
  /// [helperText] is set or not.
  final StreamHelperState? helperState;

  /// Called when the field is pressed or activated from the keyboard.
  ///
  /// When null, the field is disabled.
  final VoidCallback? onPressed;

  /// An optional focus node for the field.
  ///
  /// If null, the field creates and manages its own.
  final FocusNode? focusNode;

  /// Whether the field focuses itself when first built, if nothing else is
  /// focused.
  ///
  /// Defaults to false.
  final bool autofocus;

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

  void _activate() => props.onPressed?.call();

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    final style = props.style;
    final themeStyle = context.streamSelectInputTheme.style;
    final defaults = _StreamSelectInputDefaults(context);

    final hasError = props.helperState == StreamHelperState.error;
    final valueText = props.valueText;
    final hasValue = valueText?.isNotEmpty ?? false;

    final states = <WidgetState>{
      if (!_enabled) WidgetState.disabled,
      if (_enabled && _hovered) WidgetState.hovered,
      if (_enabled && _focused) WidgetState.focused,
      if (props.isOpen) WidgetState.selected,
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
    final effectiveIconColor = WidgetStateProperty.resolveAs(
      style?.iconColor ?? themeStyle?.iconColor ?? defaults.iconColor,
      states,
    );
    final effectiveIconSize = style?.iconSize ?? themeStyle?.iconSize ?? defaults.iconSize;
    final effectiveBorderRadius = style?.borderRadius ?? themeStyle?.borderRadius ?? defaults.borderRadius;
    final effectiveFillColor = WidgetStateProperty.resolveAs(
      style?.fillColor ?? themeStyle?.fillColor ?? defaults.fillColor,
      states,
    );
    final effectiveContentPadding = style?.contentPadding ?? themeStyle?.contentPadding ?? defaults.contentPadding;
    final effectiveLabelPadding = style?.labelPadding ?? themeStyle?.labelPadding ?? defaults.labelPadding;
    final effectiveHelperPadding = style?.helperPadding ?? themeStyle?.helperPadding ?? defaults.helperPadding;
    final effectiveBorder = _resolveSide(style?.border ?? themeStyle?.border ?? defaults.border, states);

    final ringSide = switch ((_enabled, _focused, _hovered)) {
      (false, _, _) => null,
      (_, true, _) => style?.focusRing ?? themeStyle?.focusRing ?? defaults.focusRing,
      (_, _, true) => style?.hoverRing ?? themeStyle?.hoverRing ?? defaults.hoverRing,
      _ => null,
    };
    final effectiveRing = ringSide == null ? null : _resolveSide(ringSide, states);

    // The border paints inside the box without padding it, so its width never
    // changes the field's size.
    final field = DecoratedBox(
      decoration: ShapeDecoration(
        color: effectiveFillColor,
        shape: RoundedSuperellipseBorder(
          side: effectiveBorder,
          borderRadius: effectiveBorderRadius,
        ),
      ),
      child: Padding(
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
                    hasValue ? valueText! : props.hintText ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: hasValue ? effectiveTextStyle : effectiveHintStyle,
                  ),
                ),
              ),
              Icon(props.isOpen ? icons.caretUp : icons.caretDown),
            ],
          ),
        ),
      ),
    );

    final semanticLabel = props.semanticLabel ?? props.labelText;
    final hasSemanticLabel = semanticLabel != null;

    return Semantics(
      container: true,
      button: true,
      enabled: _enabled,
      expanded: props.isOpen,
      label: hasSemanticLabel ? semanticLabel : (hasValue ? null : props.hintText),
      value: hasValue ? valueText : null,
      hint: hasSemanticLabel && !hasValue ? props.hintText : null,
      onTap: props.onPressed,
      onExpand: props.isOpen ? null : props.onPressed,
      onCollapse: props.isOpen ? props.onPressed : null,
      child: StreamColumn(
        spacing: spacing.xs,
        mainAxisAlignment: .center,
        crossAxisAlignment: .start,
        children: [
          if (props.labelText case final labelText?)
            Padding(
              padding: effectiveLabelPadding,
              child: ExcludeSemantics(
                child: Text(
                  labelText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: effectiveLabelStyle,
                ),
              ),
            ),
          FocusableActionDetector(
            key: ObjectKey(props.focusNode),
            enabled: _enabled,
            focusNode: props.focusNode,
            autofocus: props.autofocus,
            mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            onShowHoverHighlight: (value) => setState(() => _hovered = value),
            onShowFocusHighlight: (value) => setState(() => _focused = value),
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate()),
              // Enter maps to this intent instead of ActivateIntent on the web.
              ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => _activate()),
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
          if (props.helperText case final helperText?)
            Padding(
              padding: effectiveHelperPadding,
              child: StreamHelperText(text: helperText, state: props.helperState),
            ),
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
// styles, label style and horizontal padding match the ones [StreamTextInput]
// falls back to.
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
  TextStyle get labelStyle => _textTheme.headingSm.copyWith(color: _colorScheme.textPrimary);

  @override
  Color get iconColor => WidgetStateColor.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    if (states.contains(WidgetState.selected)) return _colorScheme.textPrimary;
    return _colorScheme.textTertiary;
  });

  @override
  double get iconSize => 20;

  @override
  BorderRadiusGeometry get borderRadius => BorderRadius.all(_radius.xl);

  @override
  BorderSide get border => WidgetStateBorderSide.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return BorderSide(color: _colorScheme.borderDisabled);
    if (states.contains(WidgetState.error)) return BorderSide(color: _colorScheme.borderError);
    if (states.contains(WidgetState.selected)) return BorderSide(color: _colorScheme.borderActive);
    return BorderSide(color: _colorScheme.borderDefault);
  });

  @override
  BorderSide get hoverRing => BorderSide(color: _colorScheme.borderHover);

  @override
  BorderSide get focusRing => BorderSide(
    color: _colorScheme.borderFocus,
    width: 2,
    strokeAlign: BorderSide.strokeAlignCenter,
  );

  @override
  EdgeInsetsGeometry get contentPadding => .symmetric(
    vertical: _spacing.sm + _spacing.xxxs,
    horizontal: _spacing.md,
  );

  @override
  EdgeInsetsGeometry get labelPadding => EdgeInsets.zero;

  @override
  EdgeInsetsGeometry get helperPadding => EdgeInsets.zero;
}
