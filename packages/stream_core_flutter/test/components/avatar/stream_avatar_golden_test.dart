import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('StreamAvatar Golden Tests', () {
    // -------------------------------------------------------------------------
    // StreamAvatar — shadow matrix (light)
    // -------------------------------------------------------------------------
    goldenTest(
      'renders shadow variants in light theme',
      fileName: 'stream_avatar_shadow_light',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          for (final size in StreamAvatarSize.values) ...[
            GoldenTestScenario(
              name: '${size.name}_shadow_off',
              child: _buildAvatarInTheme(
                StreamAvatar(
                  size: size,
                  showBorder: false,
                  isFloating: false,
                  placeholder: (context) => const Text('AB'),
                ),
              ),
            ),
            GoldenTestScenario(
              name: '${size.name}_shadow_on',
              child: _buildAvatarInTheme(
                StreamAvatar(
                  size: size,
                  showBorder: false,
                  isFloating: true,
                  placeholder: (context) => const Text('AB'),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    // -------------------------------------------------------------------------
    // StreamAvatar — shadow matrix (dark)
    // -------------------------------------------------------------------------
    goldenTest(
      'renders shadow variants in dark theme',
      fileName: 'stream_avatar_shadow_dark',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          for (final size in StreamAvatarSize.values) ...[
            GoldenTestScenario(
              name: '${size.name}_shadow_off',
              child: _buildAvatarInTheme(
                StreamAvatar(
                  size: size,
                  showBorder: false,
                  isFloating: false,
                  placeholder: (context) => const Text('AB'),
                ),
                brightness: Brightness.dark,
              ),
            ),
            GoldenTestScenario(
              name: '${size.name}_shadow_on',
              child: _buildAvatarInTheme(
                StreamAvatar(
                  size: size,
                  showBorder: false,
                  isFloating: true,
                  placeholder: (context) => const Text('AB'),
                ),
                brightness: Brightness.dark,
              ),
            ),
          ],
        ],
      ),
    );

    // -------------------------------------------------------------------------
    // StreamAvatarGroup — shadow on, various counts (light)
    // -------------------------------------------------------------------------
    goldenTest(
      'renders avatar group with shadow in light theme',
      fileName: 'stream_avatar_group_shadow_light',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          for (final size in StreamAvatarGroupSize.values)
            for (final count in [2, 4, 5])
              GoldenTestScenario(
                name: '${size.name}_count_$count',
                child: _buildAvatarInTheme(
                  StreamAvatarGroup(
                    size: size,
                    isFloating: true,
                    children: List.generate(
                      count,
                      (i) => StreamAvatar(
                        placeholder: (context) => Text(_initials(i)),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );

    // -------------------------------------------------------------------------
    // StreamAvatarGroup — shadow on (dark)
    // -------------------------------------------------------------------------
    goldenTest(
      'renders avatar group with shadow in dark theme',
      fileName: 'stream_avatar_group_shadow_dark',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          for (final size in StreamAvatarGroupSize.values)
            for (final count in [2, 4, 5])
              GoldenTestScenario(
                name: '${size.name}_count_$count',
                child: _buildAvatarInTheme(
                  StreamAvatarGroup(
                    size: size,
                    isFloating: true,
                    children: List.generate(
                      count,
                      (i) => StreamAvatar(
                        placeholder: (context) => Text(_initials(i)),
                      ),
                    ),
                  ),
                  brightness: Brightness.dark,
                ),
              ),
        ],
      ),
    );

    // -------------------------------------------------------------------------
    // StreamAvatarStack — shadow on (light)
    // -------------------------------------------------------------------------
    goldenTest(
      'renders avatar stack with shadow in light theme',
      fileName: 'stream_avatar_stack_shadow_light',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          for (final size in StreamAvatarStackSize.values)
            GoldenTestScenario(
              name: size.name,
              child: _buildAvatarInTheme(
                StreamAvatarStack(
                  size: size,
                  isFloating: true,
                  children: List.generate(
                    4,
                    (i) => StreamAvatar(
                      placeholder: (context) => Text(_initials(i)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // -------------------------------------------------------------------------
    // StreamAvatarStack — shadow on (dark)
    // -------------------------------------------------------------------------
    goldenTest(
      'renders avatar stack with shadow in dark theme',
      fileName: 'stream_avatar_stack_shadow_dark',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          for (final size in StreamAvatarStackSize.values)
            GoldenTestScenario(
              name: size.name,
              child: _buildAvatarInTheme(
                StreamAvatarStack(
                  size: size,
                  isFloating: true,
                  children: List.generate(
                    4,
                    (i) => StreamAvatar(
                      placeholder: (context) => Text(_initials(i)),
                    ),
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

Widget _buildAvatarInTheme(
  Widget avatar, {
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: avatar,
        ),
      ),
    ),
  );
}

String _initials(int index) {
  const names = ['AB', 'CD', 'EF', 'GH', 'IJ'];
  return names[index % names.length];
}
