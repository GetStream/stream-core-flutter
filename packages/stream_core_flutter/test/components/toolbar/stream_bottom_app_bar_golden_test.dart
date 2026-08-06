import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

const _kBarWidth = 390.0;

void main() {
  group('StreamBottomAppBar Golden Tests', () {
    goldenTest(
      'renders regular variants',
      fileName: 'stream_bottom_app_bar_regular',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: _kBarWidth),
        children: [
          GoldenTestScenario(
            name: 'light',
            child: _buildBarInTheme(_bar(StreamSurfaceStyle.regular)),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: _buildBarInTheme(_bar(StreamSurfaceStyle.regular), brightness: Brightness.dark),
          ),
        ],
      ),
    );

    goldenTest(
      'renders floating variants',
      fileName: 'stream_bottom_app_bar_floating',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: _kBarWidth),
        children: [
          GoldenTestScenario(
            name: 'light',
            child: _buildFloatingBarInTheme(_bar(StreamSurfaceStyle.floating)),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: _buildFloatingBarInTheme(_bar(StreamSurfaceStyle.floating), brightness: Brightness.dark),
          ),
        ],
      ),
    );
  });
}

Widget _bar(StreamSurfaceStyle behavior) {
  final floating = behavior.isFloating;
  final type = floating ? StreamButtonType.outline : StreamButtonType.ghost;
  return StreamBottomAppBar(
    style: StreamBottomAppBarStyle(behavior: behavior),
    leading: StreamButton.icon(
      icon: const Icon(Icons.share),
      type: type,
      isFloating: floating,
      onPressed: () {},
    ),
    title: const Text('1 of 9'),
    subtitle: const Text('Tap to share'),
    trailing: StreamButton.icon(
      icon: const Icon(Icons.grid_view),
      type: type,
      isFloating: floating,
      onPressed: () {},
    ),
  );
}

Widget _buildBarInTheme(Widget bar, {Brightness brightness = Brightness.light}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(brightness: brightness, extensions: [streamTheme]),
    child: Builder(
      builder: (context) => Material(
        color: StreamTheme.of(context).colorScheme.backgroundApp,
        child: SizedBox(width: _kBarWidth, child: bar),
      ),
    ),
  );
}

/// Wraps a floating [StreamBottomAppBar] over a content gradient so the upward
/// fade is clearly visible in the snapshot.
Widget _buildFloatingBarInTheme(Widget bar, {Brightness brightness = Brightness.light}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(brightness: brightness, extensions: [streamTheme]),
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
              Positioned(bottom: 0, left: 0, right: 0, child: bar),
            ],
          ),
        );
      },
    ),
  );
}
