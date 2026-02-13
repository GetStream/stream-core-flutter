import 'package:flutter/material.dart';

import '../../../stream_core_flutter.dart';

class StreamMessageComposerInput extends StatelessWidget {
  const StreamMessageComposerInput({
    super.key,
    required this.controller,
    this.placeholder = '',
    this.isFloating = false,
    this.inputLeading,
    this.inputTrailing,
    this.inputHeader,
    this.focusNode,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool isFloating;
  final Widget? inputLeading;
  final Widget? inputTrailing;
  final Widget? inputHeader;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: _MessageComposerInputField(
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

class _MessageComposerInputField extends StatelessWidget {
  const _MessageComposerInputField({
    required this.controller,
    required this.placeholder,
    this.focusNode,
  });

  final TextEditingController controller;
  final String placeholder;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    // TODO: fully implement the input field

    final composerBorderRadius = context.streamRadius.xxxl;
    final inputTheme = context.streamInputTheme;
    final inputDefaults = InputThemeDefaults(context: context).data;

    final border = OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(composerBorderRadius),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 124),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(
          color: inputTheme.textColor ?? inputDefaults.textColor,
        ),
        maxLines: null,
        decoration: InputDecoration(
          border: border,
          focusedBorder: border,
          enabledBorder: border,
          errorBorder: border,
          disabledBorder: border,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          hintText: placeholder,
          hintStyle: TextStyle(
            color: inputTheme.placeholderColor ?? inputDefaults.placeholderColor,
          ),
        ),
      ),
    );
  }
}
