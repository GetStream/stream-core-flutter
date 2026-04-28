import 'package:flutter/material.dart';

import '../../../stream_core_flutter.dart';

/// A widget that represents the message composer input area.
/// This usually contains the input field and the send or microphone button.
class StreamMessageComposerInput extends StatelessWidget {
  const StreamMessageComposerInput({
    super.key,
    required this.controller,
    this.placeholder,
    this.isFloating = false,
    this.inputLeading,
    this.inputTrailing,
    this.inputBody,
    this.inputHeader,
    this.focusNode,
  });

  final TextEditingController controller;
  final String? placeholder;
  final bool isFloating;
  final Widget? inputLeading;
  final Widget? inputTrailing;
  final Widget? inputBody;
  final Widget? inputHeader;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(context.streamRadius.xxxl),
        border: Border.all(
          color: context.streamColorScheme.borderDefault,
        ),
      ),
      decoration: BoxDecoration(
        color: context.streamColorScheme.backgroundElevation1,
        borderRadius: BorderRadius.all(context.streamRadius.xxxl),
        boxShadow: isFloating ? context.streamBoxShadow.elevation3 : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?inputHeader,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ?inputLeading,
              Expanded(
                child:
                    inputBody ??
                    StreamMessageComposerInputField(
                      controller: controller,
                      placeholder: placeholder,
                      focusNode: focusNode,
                    ),
              ),
              ?inputTrailing,
            ],
          ),
        ],
      ),
    );
  }
}

/// A widget that represents the actual text input field for the message composer.
class StreamMessageComposerInputField extends StatelessWidget {
  const StreamMessageComposerInputField({
    super.key,
    required this.controller,
    this.placeholder,
    this.focusNode,
    this.command,
    this.onDismissCommand,
    this.textInputAction,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofocus = false,
    this.autocorrect = true,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// The placeholder text shown when the field is empty.
  final String? placeholder;

  /// The focus node for the text field.
  final FocusNode? focusNode;

  /// The active command label displayed as a chip.
  final String? command;

  /// Called when the user dismisses the command chip.
  final VoidCallback? onDismissCommand;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// Whether the text field should be focused initially.
  final bool autofocus;

  /// Whether to enable autocorrect.
  final bool autocorrect;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final inputStyle = context.streamTextInputTheme.style;
    final inputDefaults = InputThemeDefaults(context: context).style;

    final effectiveStyle = inputStyle?.textStyle ?? inputDefaults.textStyle;
    final effectiveHintStyle = inputStyle?.hintStyle ?? inputDefaults.hintStyle;
    final effectiveCursorColor = inputStyle?.cursorColor ?? inputDefaults.cursorColor;
    final effectiveCursorWidth = inputStyle?.cursorWidth ?? inputDefaults.cursorWidth ?? 2.0;
    final effectiveCursorHeight = inputStyle?.cursorHeight ?? inputDefaults.cursorHeight;
    final effectiveCursorRadius = inputStyle?.cursorRadius ?? inputDefaults.cursorRadius;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 124),
      child: Padding(
        padding: .all(spacing.sm),
        child: Row(
          mainAxisSize: .min,
          spacing: spacing.xxs,
          crossAxisAlignment: .end,
          children: [
            if (command case final command?)
              StreamCommandChip(
                label: command,
                onDismiss: onDismissCommand,
              ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: textInputAction,
                keyboardType: keyboardType,
                textCapitalization: textCapitalization,
                autofocus: autofocus,
                autocorrect: autocorrect,
                style: effectiveStyle,
                cursorColor: effectiveCursorColor,
                cursorWidth: effectiveCursorWidth,
                cursorHeight: effectiveCursorHeight,
                cursorRadius: effectiveCursorRadius,
                maxLines: null,
                decoration: InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: placeholder,
                  hintStyle: effectiveHintStyle,
                  contentPadding: .symmetric(horizontal: spacing.xxs, vertical: spacing.xxxs),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
