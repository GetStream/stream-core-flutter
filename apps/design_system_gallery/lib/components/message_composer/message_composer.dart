import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

final emptyVoiceRecordingCallback = VoiceRecordingCallback(
  onLongPressStart: () {},
  onLongPressCancel: () {},
  onLongPressEnd: (_) {},
  onLongPressMoveUpdate: (_) {},
);

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamCoreMessageComposer,
  path: '[Components]/Message Composer',
)
Widget buildStreamMessageComposerPlayground(BuildContext context) {
  final textEditingController = TextEditingController();

  return Center(
    child: StreamCoreMessageComposer(
      controller: textEditingController,
      isFloating: false,
      inputTrailing: StreamCoreMessageComposerInputTrailing(
        controller: textEditingController,
        onSendPressed: () {},
        voiceRecordingCallback: emptyVoiceRecordingCallback,
        buttonState: StreamMessageComposerInputTrailingState.microphone,
      ),
    ),
  );
}

// =============================================================================
// Real-world Example
// =============================================================================

@widgetbook.UseCase(
  name: 'Real-world Example',
  type: StreamCoreMessageComposer,
  path: '[Components]/Message Composer',
)
Widget buildStreamMessageComposerExample(BuildContext context) {
  final theme = StreamTheme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  final isFloating = context.knobs.boolean(
    label: 'Floating',
    description: 'When true, the composer has no background or border.',
  );

  // Sample messages for scrollable list
  const messages = [
    (message: 'Hey! How are you doing today?', isMe: false),
    (message: "I'm doing great, thanks for asking!", isMe: true),
    (message: 'Did you see the new design updates?', isMe: false),
    (message: 'Yes! They look amazing. Great work on the color scheme.', isMe: true),
    (message: 'Thanks! We spent a lot of time on the details.', isMe: false),
    (message: 'It really shows. The typography is much cleaner now.', isMe: true),
    (message: 'Glad you like it! Any feedback?', isMe: false),
    (message: 'Maybe we could add more spacing in some areas?', isMe: true),
    (message: "Good point, I'll look into that.", isMe: false),
    (message: 'Perfect! Let me know if you need any help.', isMe: true),
    (message: 'Should be finished by tomorrow.', isMe: false),
    (message: 'Great! Thanks for the update.', isMe: true),
    (message: "No problem! You're welcome.", isMe: false),
    (message: 'I need to go now. See you later!', isMe: false),
    (message: 'Bye! Take care.', isMe: true),
    (message: 'Thanks! You too!', isMe: false),
    (message: 'See you soon!', isMe: true),
    (message: 'Bye!', isMe: false),
    (message: 'See you soon!', isMe: true),
  ];

  final textEditingController = TextEditingController();

  return Scaffold(
    appBar: AppBar(
      title: Row(
        children: [
          StreamAvatar(
            size: StreamAvatarSize.sm,
            placeholder: (context) => const Text('JD'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'John Doe',
                style: textTheme.bodyEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              Text(
                'Online',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.accentSuccess,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    body: isFloating
        ? Stack(
            children: [
              // Scrollable messages area (with bottom padding for composer)
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 250),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < messages.length - 1 ? 8 : 0,
                    ),
                    child: _MessageBubble(
                      message: msg.message,
                      isMe: msg.isMe,
                    ),
                  );
                },
              ),
              // Floating composer at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: StreamCoreMessageComposer(
                  controller: textEditingController,
                  isFloating: true,
                  inputTrailing: StreamCoreMessageComposerInputTrailing(
                    controller: textEditingController,
                    onSendPressed: () {},
                    voiceRecordingCallback: emptyVoiceRecordingCallback,
                    buttonState: StreamMessageComposerInputTrailingState.microphone,
                  ),
                ),
              ),
            ],
          )
        : Column(
            children: [
              // Scrollable messages area
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < messages.length - 1 ? 8 : 0,
                      ),
                      child: _MessageBubble(
                        message: msg.message,
                        isMe: msg.isMe,
                      ),
                    );
                  },
                ),
              ),
              // Non-floating composer
              StreamCoreMessageComposer(
                controller: textEditingController,
                isFloating: false,
                inputTrailing: StreamCoreMessageComposerInputTrailing(
                  controller: textEditingController,
                  onSendPressed: () {},
                  voiceRecordingCallback: emptyVoiceRecordingCallback,
                  buttonState: StreamMessageComposerInputTrailingState.microphone,
                ),
              ),
            ],
          ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  final String message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = StreamTheme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.accentPrimary : colorScheme.backgroundApp,
          borderRadius: BorderRadius.circular(16),
          border: isMe ? null : Border.all(color: colorScheme.borderSubtle),
        ),
        child: Text(
          message,
          style: textTheme.bodyDefault.copyWith(
            color: isMe ? colorScheme.textOnAccent : colorScheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
