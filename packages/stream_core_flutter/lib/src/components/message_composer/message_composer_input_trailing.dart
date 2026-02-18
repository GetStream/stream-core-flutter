import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';

class StreamMessageComposerInputTrailing extends StatefulWidget {
  const StreamMessageComposerInputTrailing({
    super.key,
    required this.controller,
    required this.onSendPressed,
    required this.voiceRecordingCallback,
  });

  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoiceRecordingCallback? voiceRecordingCallback;

  @override
  State<StreamMessageComposerInputTrailing> createState() => _StreamMessageComposerInputTrailingState();
}

class _StreamMessageComposerInputTrailingState extends State<StreamMessageComposerInputTrailing> {
  var _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onInputTextChanged);
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void didUpdateWidget(StreamMessageComposerInputTrailing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onInputTextChanged);
      widget.controller.addListener(_onInputTextChanged);
    }
  }

  void _onInputTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onInputTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement the trailing component

    if (_hasText || widget.voiceRecordingCallback == null) {
      return StreamButton.icon(
        key: _messageComposerInputTrailingSendKey,
        icon: context.streamIcons.paperPlane,
        size: StreamButtonSize.small,
        onTap: widget.onSendPressed,
      );
    }
    return StreamVoiceRecordingButton(voiceRecordingCallback: widget.voiceRecordingCallback!);
  }
}

class StreamVoiceRecordingButton extends StatelessWidget {
  const StreamVoiceRecordingButton({super.key, required this.voiceRecordingCallback});

  final VoiceRecordingCallback voiceRecordingCallback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _messageComposerInputTrailingMicrophoneKey,
      onLongPress: voiceRecordingCallback.onStart,
      onLongPressEnd: (details) => voiceRecordingCallback.onStop(),
      behavior: HitTestBehavior.translucent,
      child: StreamButton.icon(
        icon: context.streamIcons.microphone,
        type: StreamButtonType.ghost,
        style: StreamButtonStyle.secondary,
        size: StreamButtonSize.small,
        onTap: () {},
      ),
    );
  }
}

class VoiceRecordingCallback {
  VoiceRecordingCallback({required this.onStart, required this.onStop});

  final VoidCallback onStart;
  final VoidCallback onStop;
}

final _messageComposerInputTrailingSendKey = UniqueKey();
final _messageComposerInputTrailingMicrophoneKey = UniqueKey();
