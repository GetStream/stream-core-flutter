import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageComposer,
  path: '[Components]/Message Composer',
)
Widget buildStreamMessageComposerPlayground(BuildContext context) {
  return const Center(
    child: StreamMessageComposer(),
  );
}

// =============================================================================
// Component Structure
// =============================================================================

@widgetbook.UseCase(
  name: 'Component Structure',
  type: StreamMessageComposer,
  path: '[Components]/Message Composer',
)
Widget buildStreamMessageComposerStructure(BuildContext context) {
  final theme = StreamTheme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  final componentProps = MessageComposerComponentProps(controller: TextEditingController());

  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: colorScheme.backgroundSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message Composer Structure',
              style: textTheme.headingSm.copyWith(
                color: colorScheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The composer is built from customizable sub-components:',
              style: textTheme.bodyDefault.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Full Composer
            const _ComponentCard(
              label: 'StreamMessageComposer',
              description: 'Main composer widget',
              child: StreamMessageComposer(),
            ),
            const SizedBox(height: 16),

            // Leading
            _ComponentCard(
              label: 'StreamMessageComposerLeading',
              description: 'Action button(s) before the input',
              child: StreamMessageComposerLeading(props: componentProps),
            ),
            const SizedBox(height: 16),

            // Input
            _ComponentCard(
              label: 'StreamMessageComposerInput',
              description: 'Input area with header, text field, and actions',
              child: StreamMessageComposerInput(props: componentProps),
            ),
            const SizedBox(height: 16),

            // Input Header
            _ComponentCard(
              label: 'StreamMessageComposerInputHeader',
              description: 'Header slots for replies, attachments, etc.',
              child: StreamMessageComposerInputHeader(props: componentProps),
            ),
            const SizedBox(height: 16),

            // Input Trailing
            _ComponentCard(
              label: 'StreamMessageComposerInputTrailing',
              description: 'Send button or other trailing actions',
              child: StreamMessageComposerInputTrailing(props: componentProps),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({
    required this.label,
    required this.description,
    required this.child,
  });

  final String label;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = StreamTheme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.backgroundApp,
        borderRadius: BorderRadius.circular(8),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.borderSurfaceSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.captionEmphasis.copyWith(
                    color: colorScheme.accentPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.borderSurfaceSubtle,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Real-world Example
// =============================================================================

@widgetbook.UseCase(
  name: 'Real-world Example',
  type: StreamMessageComposer,
  path: '[Components]/Message Composer',
)
Widget buildStreamMessageComposerExample(BuildContext context) {
  final theme = StreamTheme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  final isFloating = context.knobs.boolean(
    label: 'Floating',
    initialValue: false,
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
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: StreamMessageComposer(isFloating: true),
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
              const StreamMessageComposer(isFloating: false),
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
          border: isMe ? null : Border.all(color: colorScheme.borderSurfaceSubtle),
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
