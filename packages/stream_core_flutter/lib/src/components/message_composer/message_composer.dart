import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';

class StreamCoreMessageComposer extends StatefulWidget {
  const StreamCoreMessageComposer({
    super.key,
    required this.controller,
    required this.isFloating,
    this.placeholder,
    this.focusNode,
    this.composerLeading,
    this.composerTrailing,
    this.inputLeading,
    this.inputTrailing,
    this.inputBody,
    this.inputHeader,
  });

  final TextEditingController? controller;
  final bool isFloating;
  final String? placeholder;
  final FocusNode? focusNode;

  final Widget? composerLeading;
  final Widget? composerTrailing;
  final Widget? inputLeading;
  final Widget? inputTrailing;
  final Widget? inputBody;
  final Widget? inputHeader;

  @override
  State<StreamCoreMessageComposer> createState() => _StreamCoreMessageComposerState();
}

class _StreamCoreMessageComposerState extends State<StreamCoreMessageComposer> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(StreamCoreMessageComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _disposeController(oldWidget);
      _initController();
    }
  }

  @override
  void dispose() {
    _disposeController(widget);
    super.dispose();
  }

  void _initController() {
    _controller = widget.controller ?? TextEditingController();
  }

  void _disposeController(StreamCoreMessageComposer widget) {
    if (widget.controller == null) {
      _controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.only(top: spacing.md),
      decoration: widget.isFloating
          ? null
          : BoxDecoration(
              border: Border(
                top: BorderSide(color: context.streamColorScheme.borderDefault),
              ),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: spacing.md),
          ?widget.composerLeading,
          Expanded(
            child: StreamMessageComposerInput(
              controller: _controller,
              placeholder: widget.placeholder,
              isFloating: widget.isFloating,
              inputLeading: widget.inputLeading,
              inputTrailing: widget.inputTrailing,
              inputBody: widget.inputBody,
              inputHeader: widget.inputHeader,
              focusNode: widget.focusNode,
            ),
          ),
          ?widget.composerTrailing,
          SizedBox(width: spacing.md),
        ],
      ),
    );
  }
}

class MessageData {}

class InputThemeDefaults {
  InputThemeDefaults({required this.context})
    : _colorScheme = context.streamColorScheme,
      _textTheme = context.streamTextTheme;

  final BuildContext context;
  final StreamColorScheme _colorScheme;
  final StreamTextTheme _textTheme;

  StreamTextInputStyle get style => StreamTextInputStyle(
    cursorWidth: 2,
    cursorColor: _colorScheme.accentPrimary,
    cursorErrorColor: _colorScheme.accentError,
    textStyle: _textTheme.bodyDefault.copyWith(color: _colorScheme.textPrimary),
    hintStyle: _textTheme.bodyDefault.copyWith(color: _colorScheme.textTertiary),
  );
}
