import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';

enum StreamMessageComposerInputTrailingState {
  send,
  microphone,
  voiceRecordingActive,
}

class StreamCoreMessageComposerInputTrailing extends StatelessWidget {
  const StreamCoreMessageComposerInputTrailing({
    super.key,
    required this.controller,
    required this.onSendPressed,
    required this.voiceRecordingCallback,
    this.buttonState = StreamMessageComposerInputTrailingState.send,
  });

  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoiceRecordingCallback? voiceRecordingCallback;
  final StreamMessageComposerInputTrailingState buttonState;

  @override
  Widget build(BuildContext context) {
    if (buttonState == StreamMessageComposerInputTrailingState.send || voiceRecordingCallback == null) {
      return StreamButton.icon(
        key: _messageComposerInputTrailingSendKey,
        icon: context.streamIcons.paperPlane,
        size: StreamButtonSize.small,
        onTap: onSendPressed,
      );
    }
    return StreamVoiceRecordingButton(
      voiceRecordingCallback: voiceRecordingCallback!,
      isRecording: buttonState == StreamMessageComposerInputTrailingState.voiceRecordingActive,
    );
  }
}

class StreamVoiceRecordingButton extends StatelessWidget {
  const StreamVoiceRecordingButton({
    super.key,
    required this.voiceRecordingCallback,
    required this.isRecording,
  });

  final VoiceRecordingCallback voiceRecordingCallback;
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _messageComposerInputTrailingMicrophoneKey,
      onLongPress: voiceRecordingCallback.onLongPressStart,
      onLongPressCancel: voiceRecordingCallback.onLongPressCancel,
      onLongPressEnd: voiceRecordingCallback.onLongPressEnd,
      onLongPressMoveUpdate: voiceRecordingCallback.onLongPressMoveUpdate,
      behavior: HitTestBehavior.translucent,
      child: StreamButtonTheme(
        data: StreamButtonThemeData(
          secondary: StreamButtonTypeStyle(
            ghost: StreamButtonThemeStyle(
              backgroundColor: isRecording
                  ? WidgetStateProperty.all(
                      context.streamColorScheme.statePressed,
                    )
                  : null,
            ),
          ),
        ),
        child: StreamButton.icon(
          icon: context.streamIcons.microphone,
          type: StreamButtonType.ghost,
          style: StreamButtonStyle.secondary,
          size: StreamButtonSize.small,
          onTap: () {},
        ),
      ),
    );
  }
}

class VoiceRecordingCallback {
  VoiceRecordingCallback({
    required this.onLongPressStart,
    required this.onLongPressCancel,
    required this.onLongPressEnd,
    this.onLongPressMoveUpdate,
  });

  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressCancel;
  final GestureLongPressEndCallback onLongPressEnd;
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;
}

final _messageComposerInputTrailingSendKey = UniqueKey();
final _messageComposerInputTrailingMicrophoneKey = UniqueKey();
