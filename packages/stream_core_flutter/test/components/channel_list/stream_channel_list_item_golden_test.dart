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
                title: 'Jane Doe',
                subtitle: const Text('Hey! Are you free for a call?'),
                timestamp: '9:41',
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
                title: 'Bob Smith',
                subtitle: const Text('Thanks for the update!'),
                timestamp: 'Yesterday',
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
                  title: 'Muted Channel',
                  titleTrailing: Icon(
                    context.streamIcons.mute,
                    size: 16,
                    color: context.streamColorScheme.textTertiary,
                  ),
                  subtitle: const Text('Last message...'),
                  timestamp: '10:15',
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
                title: 'Minimal',
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
                title: 'Very Long Channel Name That Should Be Truncated',
                subtitle: const Text(
                  'This is a very long message preview that should '
                  'be truncated with an ellipsis',
                ),
                timestamp: '01/15/2026',
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
                title: 'Jane Doe',
                subtitle: const Text('Hey! Are you free for a call?'),
                timestamp: '9:41',
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
                title: 'Bob Smith',
                subtitle: const Text('Thanks for the update!'),
                timestamp: 'Yesterday',
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
                  title: 'Group Chat',
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
                  timestamp: '9:41',
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
