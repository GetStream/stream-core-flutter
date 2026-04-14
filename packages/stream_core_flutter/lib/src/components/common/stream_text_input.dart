import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_text_input_theme.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import 'stream_flex.dart';

/// A text input styled for the Stream design system.
///
/// [StreamTextInput] provides a custom text input container with outline
/// borders, optional leading/trailing widgets, and animated helper text.
///
/// The field supports both **controlled** (via [controller]) and
/// **uncontrolled** (via [initialValue]) modes. At most one may be provided;
/// if neither is given, an internal controller is created automatically.
///
/// Visual properties are resolved in order:
/// 1. Per-instance [style] overrides
/// 2. [StreamTextInputTheme] from the widget tree
/// 3. Design token fallbacks from [StreamColorScheme] and [StreamTextTheme]
///
/// {@tool snippet}
///
/// Basic text input with hint:
///
/// ```dart
/// StreamTextInput(
///   hintText: 'Enter your name',
///   onChanged: (value) => print(value),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Text input with error:
///
/// ```dart
/// StreamTextInput(
///   initialValue: 'bad input',
///   helperText: 'This field is required',
///   helperState: StreamHelperState.error,
///   onChanged: (value) {},
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Controlled text input with leading icon:
///
/// ```dart
/// StreamTextInput(
///   controller: myController,
///   leading: Icon(Icons.search),
///   hintText: 'Search...',
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTextInputTheme], for customizing text input appearance.
///  * [StreamTextInputStyle], for the visual style properties.
///  * [StreamHelperText], for the animated helper text widget.
///  * [StreamHelperState], for helper text states.
class StreamTextInput extends StatelessWidget {
  /// Creates a Stream text input.
  ///
  /// At most one of [controller] or [initialValue] may be provided.
  StreamTextInput({
    super.key,
    TextEditingController? controller,
    String? initialValue,
    bool enabled = true,
    Widget? leading,
    Widget? trailing,
    String? hintText,
    String? helperText,
    StreamHelperState? helperState,
    StreamTextInputStyle? style,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    bool autocorrect = false,
    bool autofocus = false,
    bool readOnly = false,
    TextAlign textAlign = .start,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onSubmitted,
    GestureTapCallback? onTap,
    TextCapitalization textCapitalization = .none,
  }) : props = .new(
         controller: controller,
         initialValue: initialValue,
         enabled: enabled,
         leading: leading,
         trailing: trailing,
         hintText: hintText,
         helperText: helperText,
         helperState: helperState,
         style: style,
         focusNode: focusNode,
         keyboardType: keyboardType,
         textInputAction: textInputAction,
         inputFormatters: inputFormatters,
         autocorrect: autocorrect,
         autofocus: autofocus,
         readOnly: readOnly,
         textAlign: textAlign,
         maxLines: maxLines,
         minLines: minLines,
         maxLength: maxLength,
         onChanged: onChanged,
         onEditingComplete: onEditingComplete,
         onSubmitted: onSubmitted,
         onTap: onTap,
         textCapitalization: textCapitalization,
       );

  /// The props controlling the appearance and behavior of this text input.
  final StreamTextInputProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).textInput;
    if (builder != null) return builder(context, props);
    return DefaultStreamTextInput(props: props);
  }
}

/// Properties for configuring a [StreamTextInput].
///
/// This class holds all the configuration options for a text input,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamTextInput], which uses these properties.
///  * [DefaultStreamTextInput], the default implementation.
class StreamTextInputProps {
  /// Creates properties for a text input.
  ///
  /// At most one of [controller] or [initialValue] may be provided.
  /// If neither is given, an internal controller is created automatically.
  const StreamTextInputProps({
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.leading,
    this.trailing,
    this.hintText,
    this.helperText,
    this.helperState,
    this.style,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autocorrect = false,
    this.autofocus = false,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.textCapitalization = .none,
  }) : assert(
         controller == null || initialValue == null,
         'Cannot provide both controller and initialValue.',
       );

  /// Controls the text being edited.
  ///
  /// If null and [initialValue] is also null, an empty controller is created
  /// internally. Mutually exclusive with [initialValue].
  final TextEditingController? controller;

  /// The initial text value when not using a [controller].
  ///
  /// Mutually exclusive with [controller].
  final String? initialValue;

  /// Whether the text input is interactive.
  ///
  /// When false, the field is visually dimmed and ignores input.
  /// Defaults to true.
  final bool enabled;

  /// An optional widget to display before the text input area.
  final Widget? leading;

  /// An optional widget to display after the text input area.
  final Widget? trailing;

  /// Placeholder text shown when the field is empty.
  final String? hintText;

  /// Helper message displayed below the text input with animation.
  ///
  /// Rendered using [StreamHelperText]. When null, no helper text is shown.
  final String? helperText;

  /// The semantic state of [helperText].
  ///
  /// Controls the icon, text color, and border color of the helper area.
  /// When [helperText] is null, this has no visible effect.
  /// Defaults to [StreamHelperState.info] when [helperText] is provided.
  final StreamHelperState? helperState;

  /// Per-instance style overrides.
  ///
  /// Takes precedence over the inherited [StreamTextInputTheme].
  final StreamTextInputStyle? style;

  /// Focus node for the text input.
  final FocusNode? focusNode;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Optional input formatters that restrict or transform input.
  ///
  /// When null, a default formatter that prevents leading whitespace is used.
  /// Pass an explicit empty list to disable all formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to enable autocorrect.
  ///
  /// Defaults to false.
  final bool autocorrect;

  /// Whether the text input should focus itself on mount.
  ///
  /// Defaults to false.
  final bool autofocus;

  /// Whether the text input is read-only.
  ///
  /// Defaults to false.
  final bool readOnly;

  /// How the text should be aligned horizontally.
  ///
  /// Defaults to [TextAlign.start].
  final TextAlign textAlign;

  /// The maximum number of lines for the text input.
  ///
  /// Defaults to 1 (single line). Set to null for unlimited lines.
  final int? maxLines;

  /// The minimum number of lines for the text input.
  final int? minLines;

  /// The maximum number of characters (unicode scalar values) to allow.
  final int? maxLength;

  /// Called when the user changes the text.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits editable content (e.g., presses done).
  final VoidCallback? onEditingComplete;

  /// Called when the user indicates they are done editing the text.
  final ValueChanged<String>? onSubmitted;

  /// Called when the text input is tapped.
  final GestureTapCallback? onTap;

  /// Configures how the platform keyboard capitalizes text.
  ///
  /// Defaults to [TextCapitalization.none].
  final TextCapitalization textCapitalization;
}

/// Default implementation of [StreamTextInput].
///
/// Renders a custom container with outline borders, an editable text field,
/// optional leading/trailing widgets, and animated [StreamHelperText].
///
/// Styling is resolved from widget props, per-instance [StreamTextInputStyle],
/// inherited [StreamTextInputTheme], and design token fallbacks in that order.
///
/// See also:
///
///  * [StreamTextInput], the public widget that delegates to this.
///  * [StreamTextInputProps], the configuration properties.
class DefaultStreamTextInput extends StatefulWidget {
  /// Creates a default text input implementation.
  const DefaultStreamTextInput({super.key, required this.props});

  /// The props controlling the appearance and behavior of this text input.
  final StreamTextInputProps props;

  @override
  State<DefaultStreamTextInput> createState() => _DefaultStreamTextInputState();
}

class _DefaultStreamTextInputState extends State<DefaultStreamTextInput> {
  TextEditingController? _controller;
  FocusNode? _focusNode;

  StreamTextInputProps get props => widget.props;

  TextEditingController get _effectiveController =>
      props.controller ?? (_controller ??= TextEditingController(text: props.initialValue));

  FocusNode get _effectiveFocusNode => props.focusNode ?? (_focusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant DefaultStreamTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.props.focusNode != oldWidget.props.focusNode) {
      (oldWidget.props.focusNode ?? _focusNode)?.removeListener(_handleFocusChanged);
      _effectiveFocusNode.addListener(_handleFocusChanged);
    }

    // Sync initialValue changes when using uncontrolled mode.
    if (props.controller == null && props.initialValue != oldWidget.props.initialValue) {
      final newValue = props.initialValue;
      if (_effectiveController.text != newValue) {
        _effectiveController.value = switch (newValue) {
          final value? => TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          ),
          _ => TextEditingValue.empty,
        };
      }
    }
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    _focusNode?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final style = props.style;
    final inputStyle = context.streamTextInputTheme.style;
    final defaults = _StreamTextInputDefaults(context);

    final states = <WidgetState>{if (!props.enabled) WidgetState.disabled};

    final effectiveTextStyle = WidgetStateProperty.resolveAs(
      style?.textStyle ?? inputStyle?.textStyle ?? defaults.textStyle,
      states,
    );

    final effectiveHintStyle = WidgetStateProperty.resolveAs(
      style?.hintStyle ?? inputStyle?.hintStyle ?? defaults.hintStyle,
      states,
    );

    final effectiveContentPadding = style?.contentPadding ?? inputStyle?.contentPadding ?? defaults.contentPadding;
    final effectiveBorderRadius = style?.borderRadius ?? inputStyle?.borderRadius ?? defaults.borderRadius;
    final effectiveFillColor = style?.fillColor ?? inputStyle?.fillColor ?? defaults.fillColor;
    final effectiveIconColor = WidgetStateProperty.resolveAs(
      style?.iconColor ?? inputStyle?.iconColor ?? defaults.iconColor,
      states,
    );
    final effectiveIconSize = style?.iconSize ?? inputStyle?.iconSize ?? defaults.iconSize;
    final effectiveConstraints = style?.constraints ?? inputStyle?.constraints;
    final effectiveInputFormatters = props.inputFormatters ?? [FilteringTextInputFormatter.deny(RegExp(r'^\s'))];

    final hasError = props.helperState == StreamHelperState.error;
    final effectiveBorder = switch ((hasError, _effectiveFocusNode.hasFocus)) {
      (true, _) => style?.errorBorder ?? inputStyle?.errorBorder ?? defaults.errorBorder,
      (_, true) => style?.focusBorder ?? inputStyle?.focusBorder ?? defaults.focusBorder,
      _ => style?.border ?? inputStyle?.border ?? defaults.border,
    };

    return GestureDetector(
      onTap: props.enabled ? _effectiveFocusNode.requestFocus : null,
      child: Container(
        alignment: .center,
        clipBehavior: .hardEdge,
        constraints: effectiveConstraints,
        decoration: BoxDecoration(
          color: effectiveFillColor,
          borderRadius: effectiveBorderRadius,
          border: Border.fromBorderSide(effectiveBorder),
        ),
        child: Padding(
          padding: effectiveContentPadding,
          child: IconTheme(
            data: IconThemeData(
              size: effectiveIconSize,
              color: effectiveIconColor,
            ),
            child: StreamColumn(
              mainAxisSize: .min,
              spacing: spacing.sm,
              crossAxisAlignment: .start,
              children: [
                StreamRow(
                  spacing: spacing.xs,
                  children: [
                    ?props.leading,
                    Expanded(
                      child: TextField(
                        autocorrect: props.autocorrect,
                        controller: _effectiveController,
                        focusNode: _effectiveFocusNode,
                        onChanged: props.onChanged,
                        onEditingComplete: props.onEditingComplete,
                        onSubmitted: props.onSubmitted,
                        onTap: props.onTap,
                        style: effectiveTextStyle,
                        keyboardType: props.keyboardType,
                        textInputAction: props.textInputAction,
                        inputFormatters: effectiveInputFormatters,
                        autofocus: props.autofocus,
                        readOnly: props.readOnly,
                        textAlign: props.textAlign,
                        textCapitalization: props.textCapitalization,
                        maxLines: props.maxLines,
                        minLines: props.minLines,
                        maxLength: props.maxLength,
                        enabled: props.enabled,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          filled: false,
                          contentPadding: .zero,
                          border: .none,
                          enabledBorder: .none,
                          focusedBorder: .none,
                          disabledBorder: .none,
                          errorBorder: .none,
                          focusedErrorBorder: .none,
                          enabled: props.enabled,
                          hintText: props.hintText,
                          hintStyle: effectiveHintStyle,
                        ),
                      ),
                    ),
                    ?props.trailing,
                  ],
                ),
                if (props.helperText case final helperText?)
                  StreamHelperText(text: helperText, state: props.helperState),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The state of helper text, driving the icon and color.
///
/// Used by [StreamHelperText] and [StreamTextInput] to select the appropriate
/// visual treatment for informational messages displayed below a text input.
///
/// See also:
///
///  * [StreamHelperText], which renders styled helper text.
///  * [StreamTextInputStyle], which provides per-state styling.
enum StreamHelperState {
  /// Neutral informational state.
  info,

  /// Error state — indicates validation failure or other problems.
  error,

  /// Success state — indicates valid input or completion.
  success,
}

const _kTransitionDuration = Duration(milliseconds: 167);

/// Animated helper text with icon, driven by [StreamHelperState].
///
/// Displays a text message with a leading icon whose color and icon glyph
/// are determined by [state]. The widget animates in with a combined fade
/// and slide transition when first shown or when [text] changes.
///
/// Styling is resolved from [StreamTextInputStyle] via the nearest
/// [StreamTextInputTheme] ancestor, with sensible fallbacks from
/// [StreamColorScheme] and [StreamTextTheme].
///
/// {@tool snippet}
///
/// Show an error helper:
///
/// ```dart
/// StreamHelperText(
///   text: 'This field is required',
///   state: StreamHelperState.error,
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Show a success helper:
///
/// ```dart
/// StreamHelperText(
///   text: 'Looks good!',
///   state: StreamHelperState.success,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamHelperState], which determines the visual treatment.
///  * [StreamTextInputStyle], which provides per-state text styles and icons.
///  * [StreamTextInput], which uses this widget internally.
class StreamHelperText extends StatefulWidget {
  /// Creates an animated helper text widget.
  const StreamHelperText({
    super.key,
    required this.text,
    this.state,
    this.style,
    this.icon,
    this.maxLines,
    this.textAlign,
  });

  /// The helper text to display.
  final String text;

  /// The semantic state of this helper text.
  ///
  /// Controls the default icon and text color. Defaults to
  /// [StreamHelperState.info] when null.
  final StreamHelperState? state;

  /// Override text style. When null, resolved from [StreamTextInputStyle] based
  /// on [state].
  final TextStyle? style;

  /// Override leading widget. When null, resolved from [StreamTextInputStyle]
  /// based on [state].
  ///
  /// Typically an [Icon] widget.
  final Widget? icon;

  /// The maximum number of lines for the helper text.
  final int? maxLines;

  /// The text alignment of the helper text.
  final TextAlign? textAlign;

  @override
  State<StreamHelperText> createState() => _StreamHelperTextState();
}

class _StreamHelperTextState extends State<StreamHelperText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kTransitionDuration, vsync: this)
      ..addListener(() => setState(() {}))
      ..forward();
  }

  @override
  void didUpdateWidget(covariant StreamHelperText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text || widget.state != oldWidget.state) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    final inputStyle = context.streamTextInputTheme.style;
    final defaults = _StreamHelperTextDefaults(context);

    final effectiveState = widget.state ?? StreamHelperState.info;
    final effectiveIconSize = inputStyle?.helperIconSize ?? defaults.helperIconSize;
    final effectiveMaxLines = widget.maxLines ?? inputStyle?.helperMaxLines ?? defaults.helperMaxLines;

    final (effectiveIcon, effectiveStyle) = switch (effectiveState) {
      .info => (
        widget.icon ?? Icon(icons.info),
        widget.style ?? inputStyle?.helperInfoStyle ?? defaults.helperInfoStyle,
      ),
      .error => (
        widget.icon ?? Icon(icons.exclamationCircle),
        widget.style ?? inputStyle?.helperErrorStyle ?? defaults.helperErrorStyle,
      ),
      .success => (
        widget.icon ?? Icon(icons.checkmark),
        widget.style ?? inputStyle?.helperSuccessStyle ?? defaults.helperSuccessStyle,
      ),
    };

    return FadeTransition(
      opacity: _controller,
      child: FractionalTranslation(
        translation: Tween<Offset>(
          begin: const Offset(0, -0.25),
          end: Offset.zero,
        ).evaluate(_controller.view),
        child: IconTheme(
          data: .new(
            size: effectiveIconSize,
            color: effectiveStyle.color,
          ),
          child: StreamRow(
            spacing: spacing.xs,
            mainAxisAlignment: .center,
            crossAxisAlignment: .start,
            children: [
              effectiveIcon,
              Expanded(
                child: Text(
                  widget.text,
                  style: effectiveStyle,
                  textAlign: widget.textAlign,
                  maxLines: effectiveMaxLines,
                  overflow: .ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Default theme values for [StreamTextInput].
//
// These defaults are used when no explicit value is provided via
// [StreamTextInputStyle] or [StreamTextInputThemeData].
class _StreamTextInputDefaults extends StreamTextInputStyle {
  _StreamTextInputDefaults(this.context);

  final BuildContext context;

  late final StreamRadius _radius = context.streamRadius;
  late final StreamSpacing _spacing = context.streamSpacing;
  late final StreamTextTheme _textTheme = context.streamTextTheme;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  @override
  double get iconSize => 20;

  @override
  Color get iconColor => WidgetStateColor.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    return _colorScheme.textTertiary;
  });

  @override
  BorderSide get border => BorderSide(color: _colorScheme.borderDefault);

  @override
  BorderSide get focusBorder => BorderSide(color: _colorScheme.borderActive);

  @override
  BorderSide get errorBorder => BorderSide(color: _colorScheme.borderError);

  @override
  BorderRadiusGeometry get borderRadius => BorderRadius.all(_radius.lg);

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
  EdgeInsetsGeometry get contentPadding => .symmetric(vertical: _spacing.sm, horizontal: _spacing.md);
}

// Default theme values for [StreamHelperText].
//
// These defaults are used when no explicit value is provided via
// [StreamTextInputStyle] or [StreamTextInputThemeData].
class _StreamHelperTextDefaults extends StreamTextInputStyle {
  _StreamHelperTextDefaults(this.context);

  final BuildContext context;

  late final StreamTextTheme _textTheme = context.streamTextTheme;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  @override
  int get helperMaxLines => 1;

  @override
  double get helperIconSize => 20;

  @override
  TextStyle get helperInfoStyle => _textTheme.captionDefault.copyWith(color: _colorScheme.textTertiary);

  @override
  TextStyle get helperErrorStyle => _textTheme.captionDefault.copyWith(color: _colorScheme.accentError);

  @override
  TextStyle get helperSuccessStyle => _textTheme.captionDefault.copyWith(color: _colorScheme.accentSuccess);
}
