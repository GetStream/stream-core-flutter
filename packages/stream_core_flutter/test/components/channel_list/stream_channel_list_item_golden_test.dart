import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('StreamChannelListItem Golden Tests', () {
    goldenTest(
      'renders light theme variants',
      fileName: 'stream_channel_list_item_light',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          GoldenTestScenario(
            name: 'full',
            child: _buildInTheme(
              StreamChannelListItem(
                avatar: StreamAvatar(
                  size: StreamAvatarSize.xl,
                  placeholder: (context) => const Text('JD'),
                ),
                title: const Text('Jane Doe'),
                subtitle: const Text('Hey! Are you free for a call?'),
                timestamp: const Text('9:41'),
                unreadCount: 3,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'no_unread',
            child: _buildInTheme(
              StreamChannelListItem(
                avatar: StreamAvatar(
                  size: StreamAvatarSize.xl,
                  placeholder: (context) => const Text('BS'),
                ),
                title: const Text('Bob Smith'),
                subtitle: const Text('Thanks for the update!'),
                timestamp: const Text('Yesterday'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'with_mute_icon',
            child: _buildInTheme(
              Builder(
                builder: (context) => StreamChannelListItem(
                  avatar: StreamAvatar(
                    size: StreamAvatarSize.xl,
                    placeholder: (context) => const Text('MT'),
                  ),
                  title: const Text('Muted Channel'),
                  titleTrailing: Icon(
                    context.streamIcons.mute,
                    size: 16,
                    color: context.streamColorScheme.textTertiary,
                  ),
                  subtitle: const Text('Last message...'),
                  timestamp: const Text('10:15'),
                  unreadCount: 1,
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'no_subtitle',
            child: _buildInTheme(
              StreamChannelListItem(
                avatar: StreamAvatar(
                  size: StreamAvatarSize.xl,
                  placeholder: (context) => const Text('MN'),
                ),
                title: const Text('Minimal'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'long_text',
            child: _buildInTheme(
              StreamChannelListItem(
                avatar: StreamAvatar(
                  size: StreamAvatarSize.xl,
                  placeholder: (context) => const Text('LT'),
                ),
                title: const Text('Very Long Channel Name That Should Be Truncated'),
                subtitle: const Text(
                  'This is a very long message preview that should '
                  'be truncated with an ellipsis',
                ),
                timestamp: const Text('01/15/2026'),
                unreadCount: 99,
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme variants',
      fileName: 'stream_channel_list_item_dark',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          GoldenTestScenario(
            name: 'full',
            child: _buildInTheme(
              StreamChannelListItem(
                avatar: StreamAvatar(
                  size: StreamAvatarSize.xl,
                  placeholder: (context) => const Text('JD'),
                ),
                title: const Text('Jane Doe'),
                subtitle: const Text('Hey! Are you free for a call?'),
                timestamp: const Text('9:41'),
                unreadCount: 3,
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'no_unread',
            child: _buildInTheme(
              StreamChannelListItem(
                avatar: StreamAvatar(
                  size: StreamAvatarSize.xl,
                  placeholder: (context) => const Text('BS'),
                ),
                title: const Text('Bob Smith'),
                subtitle: const Text('Thanks for the update!'),
                timestamp: const Text('Yesterday'),
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'with_widget_subtitle',
            child: _buildInTheme(
              Builder(
                builder: (context) => StreamChannelListItem(
                  avatar: StreamAvatar(
                    size: StreamAvatarSize.xl,
                    placeholder: (context) => const Text('GC'),
                  ),
                  title: const Text('Group Chat'),
                  subtitle: Row(
                    children: [
                      Text(
                        'Alice: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.streamColorScheme.textTertiary,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'New mockups ready for review',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  timestamp: const Text('9:41'),
                  unreadCount: 5,
                ),
              ),
              brightness: Brightness.dark,
            ),
          ),
        ],
      ),
    );
  });
}

Widget _buildInTheme(
  Widget child, {
  Brightness brightness = Brightness.light,
}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(
      brightness: brightness,
      extensions: [streamTheme],
    ),
    child: Builder(
      builder: (context) => Material(
        color: StreamTheme.of(context).colorScheme.backgroundApp,
        child: child,
      ),
    ),
  );
}
