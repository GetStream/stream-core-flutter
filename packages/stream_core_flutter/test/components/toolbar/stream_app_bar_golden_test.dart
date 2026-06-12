import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

const _kBarWidth = 390.0;

void main() {
  group('StreamAppBar Golden Tests', () {
    goldenTest(
      'renders light theme variants',
      fileName: 'stream_app_bar_light',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: _kBarWidth),
        children: [
          GoldenTestScenario(
            name: 'title only',
            child: _buildAppBarInTheme(
              StreamAppBar(
                automaticallyImplyLeading: false,
                title: const Text('Details'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'leading and trailing',
            child: _buildAppBarInTheme(
              StreamAppBar(
                automaticallyImplyLeading: false,
                leading: StreamButton.icon(
                  icon: const Icon(Icons.chevron_left),
                  style: StreamButtonStyle.secondary,
                  type: StreamButtonType.ghost,
                  onPressed: () {},
                ),
                title: const Text('Group chat'),
                trailing: StreamButton.icon(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'leading only',
            child: _buildAppBarInTheme(
              StreamAppBar(
                automaticallyImplyLeading: false,
                leading: StreamButton.icon(
                  icon: const Icon(Icons.chevron_left),
                  style: StreamButtonStyle.secondary,
                  type: StreamButtonType.ghost,
                  onPressed: () {},
                ),
                title: const Text('Details'),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme variants',
      fileName: 'stream_app_bar_dark',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: _kBarWidth),
        children: [
          GoldenTestScenario(
            name: 'title only',
            child: _buildAppBarInTheme(
              StreamAppBar(
                automaticallyImplyLeading: false,
                title: const Text('Details'),
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'leading and trailing',
            child: _buildAppBarInTheme(
              StreamAppBar(
                automaticallyImplyLeading: false,
                leading: StreamButton.icon(
                  icon: const Icon(Icons.chevron_left),
                  style: StreamButtonStyle.secondary,
                  type: StreamButtonType.ghost,
                  onPressed: () {},
                ),
                title: const Text('Group chat'),
                trailing: StreamButton.icon(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ),
              brightness: Brightness.dark,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders light theme floating variants',
      fileName: 'stream_app_bar_floating_light',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: _kBarWidth),
        children: [
          GoldenTestScenario(
            name: 'title only',
            child: _buildFloatingAppBarInTheme(
              StreamAppBar(
                automaticallyImplyLeading: false,
                primary: false,
                appBarBehavior: AppBarBehavior.floating,
                title: const Text('Details'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'leading and trailing',
            child: _buildFloatingAppBarInTheme(
              StreamAppBar(
                automaticallyImplyLeading: false,
                primary: false,
                appBarBehavior: AppBarBehavior.floating,
                leading: StreamButton.icon(
                  icon: const Icon(Icons.chevron_left),
                  style: StreamButtonStyle.secondary,
                  type: StreamButtonType.outline,
                  isFloating: true,
                  onPressed: () {},
                ),
                title: const Text('Group chat'),
                trailing: StreamButton.icon(
                  icon: const Icon(Icons.add),
                  isFloating: true,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme floating variants',
      fileName: 'stream_app_bar_floating_dark',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: _kBarWidth),
        children: [
          GoldenTestScenario(
            name: 'title only',
            child: _buildFloatingAppBarInTheme(
              StreamAppBar(
                automaticallyImplyLeading: false,
                primary: false,
                appBarBehavior: AppBarBehavior.floating,
                title: const Text('Details'),
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'leading and trailing',
            child: _buildFloatingAppBarInTheme(
              StreamAppBar(
                automaticallyImplyLeading: false,
                primary: false,
                appBarBehavior: AppBarBehavior.floating,
                leading: StreamButton.icon(
                  icon: const Icon(Icons.chevron_left),
                  style: StreamButtonStyle.secondary,
                  type: StreamButtonType.outline,
                  isFloating: true,
                  onPressed: () {},
                ),
                title: const Text('Group chat'),
                trailing: StreamButton.icon(
                  icon: const Icon(Icons.add),
                  isFloating: true,
                  onPressed: () {},
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

Widget _buildAppBarInTheme(
  Widget appBar, {
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
        child: SizedBox(width: _kBarWidth, child: appBar),
      ),
    ),
  );
}

/// Wraps a floating [StreamAppBar] over a content background so the gradient
/// fade is clearly visible in the snapshot.
Widget _buildFloatingAppBarInTheme(
  Widget appBar, {
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
          height: kStreamToolbarHeight * 2,
          child: Stack(
            children: [
              // Simulated content behind the floating bar.
              Positioned.fill(
                child: ColoredBox(
                  color: colorScheme.backgroundApp,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: colorScheme.accentPrimary,
                    ),
                  ),
                ),
              ),
              Positioned(top: 0, left: 0, right: 0, child: appBar),
            ],
          ),
        );
      },
    ),
  );
}
