import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';
import '../../theme/components/stream_input_theme.dart';
import '../../theme/components/stream_message_theme.dart';

class StreamBaseMessageComposer extends StatefulWidget {
  const StreamBaseMessageComposer({
    super.key,
    required this.controller,
    required this.isFloating,
    this.placeholder = '',
    this.focusNode,
    this.composerLeading,
    this.composerTrailing,
    this.inputLeading,
    this.inputTrailing,
    this.inputHeader,
  });

  final TextEditingController? controller;
  final bool isFloating;
  final String placeholder;
  final FocusNode? focusNode;

  final Widget? composerLeading;
  final Widget? composerTrailing;
  final Widget? inputLeading;
  final Widget? inputTrailing;
  final Widget? inputHeader;

  @override
  State<StreamBaseMessageComposer> createState() => _StreamBaseMessageComposerState();
}

class _StreamBaseMessageComposerState extends State<StreamBaseMessageComposer> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(StreamBaseMessageComposer oldWidget) {
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

  void _disposeController(StreamBaseMessageComposer widget) {
    if (widget.controller == null) {
      _controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final bottomPaddingSafeArea = MediaQuery.of(context).padding.bottom;
    final minimumBottomPadding = spacing.md;
    final bottomPadding = math.max(bottomPaddingSafeArea, minimumBottomPadding);

    return Container(
      padding: EdgeInsets.only(top: spacing.md, bottom: bottomPadding),
      decoration: widget.isFloating
          ? null
          : BoxDecoration(
              color: context.streamColorScheme.backgroundElevation1,
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
  InputThemeDefaults({required this.context}) : _colorScheme = context.streamColorScheme;

  final BuildContext context;
  final StreamColorScheme _colorScheme;

  StreamInputThemeData get data => StreamInputThemeData(
    textColor: _colorScheme.textPrimary,
    placeholderColor: _colorScheme.textTertiary,
    disabledColor: _colorScheme.textDisabled,
    iconColor: _colorScheme.textTertiary,
    borderColor: _colorScheme.borderDefault,
  );
}

class MessageThemeDefaults {
  MessageThemeDefaults({required this.context}) : _colorScheme = context.streamColorScheme;

  final BuildContext context;
  final StreamColorScheme _colorScheme;

  StreamMessageThemeData get data => StreamMessageThemeData(
    backgroundIncoming: _colorScheme.backgroundSurface,
    backgroundOutgoing: _colorScheme.brand.shade100,
    backgroundAttachmentIncoming: _colorScheme.backgroundSurfaceStrong,
    backgroundAttachmentOutgoing: _colorScheme.brand.shade150,
    backgroundTypingIndicator: _colorScheme.accentNeutral,
    textIncoming: _colorScheme.textPrimary,
    textOutgoing: _colorScheme.brand.shade900,
    textUsername: _colorScheme.textSecondary,
    textTimestamp: _colorScheme.textTertiary,
    textMention: _colorScheme.textLink,
    textLink: _colorScheme.textLink,
    textReaction: _colorScheme.textSecondary,
    textSystem: _colorScheme.textSecondary,
    borderIncoming: _colorScheme.borderSubtle,
    borderOutgoing: _colorScheme.brand.shade100,
    borderOnChatIncoming: _colorScheme.borderOnSurface,
    borderOnChatOutgoing: _colorScheme.brand.shade300,
    replyIndicatorIncoming: _colorScheme.borderOnSurface,
    replyIndicatorOutgoing: _colorScheme.brand.shade400,
  );
}
