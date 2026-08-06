import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

const _kBarWidth = 390.0;

const _items = [
  StreamBottomNavBarItem(
    icon: Icon(Icons.chat_bubble_outline),
    selectedIcon: Icon(Icons.chat_bubble),
    label: 'Chats',
  ),
  StreamBottomNavBarItem(
    icon: Icon(Icons.alternate_email),
    selectedIcon: Icon(Icons.alternate_email),
    label: 'Mentions',
  ),
  StreamBottomNavBarItem(
    icon: Icon(Icons.person_outline),
    selectedIcon: Icon(Icons.person),
    label: 'Profile',
  ),
];

void main() {
  group('StreamBottomNavBar Golden Tests', () {
    goldenTest(
      'renders regular variants',
      fileName: 'stream_bottom_nav_bar_regular',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: _kBarWidth),
        children: [
          GoldenTestScenario(
            name: 'light',
            child: _buildNavBarInTheme(_regularBar()),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: _buildNavBarInTheme(_regularBar(), brightness: Brightness.dark),
          ),
        ],
      ),
    );

    goldenTest(
      'renders floating variants',
      fileName: 'stream_bottom_nav_bar_floating',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: _kBarWidth),
        children: [
          GoldenTestScenario(
            name: 'light',
            child: _buildFloatingNavBarInTheme(_floatingBar()),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: _buildFloatingNavBarInTheme(_floatingBar(), brightness: Brightness.dark),
          ),
        ],
      ),
    );
  });
}

Widget _regularBar() {
  return StreamBottomNavBar(
    items: _items,
    currentIndex: 0,
    onTap: (_) {},
    style: const StreamBottomNavBarStyle(behavior: .regular),
  );
}

Widget _floatingBar() {
  return StreamBottomNavBar(
    items: _items,
    currentIndex: 1,
    onTap: (_) {},
    style: const StreamBottomNavBarStyle(behavior: .floating),
  );
}

Widget _buildNavBarInTheme(
  Widget navBar, {
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
        child: SizedBox(width: _kBarWidth, child: navBar),
      ),
    ),
  );
}

/// Wraps a floating [StreamBottomNavBar] over a content gradient so the fade is
/// clearly visible in the snapshot.
Widget _buildFloatingNavBarInTheme(
  Widget navBar, {
  Brightness brightness = Brightness.light,
}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(
      brightness: brightness,
      extensions: [streamTheme],
    ),
    child: Builder(
      builder: (context) {
        final colorScheme = StreamTheme.of(context).colorScheme;
        return SizedBox(
          width: _kBarWidth,
          height: kStreamToolbarHeight * 3,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.backgroundApp,
                        colorScheme.accentPrimary.withAlpha(0x40),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(bottom: 0, left: 0, right: 0, child: navBar),
            ],
          ),
        );
      },
    ),
  );
}
