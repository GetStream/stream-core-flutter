import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  // Renders the shipped icon font, so the close button reads as an xmark
  // rather than the test framework's placeholder box.
  setUpAll(() async {
    final loader = FontLoader('packages/stream_core_flutter/${StreamIconData.iconFontFamily}')
      ..addFont(File('lib/fonts/stream_icons_font.otf').readAsBytes().then(ByteData.sublistView));
    await loader.load();
  });

  group('StreamModalDialog Golden Tests', () {
    for (final variant in _Variant.values) {
      for (final brightness in Brightness.values) {
        goldenTest(
          'renders the ${variant.name} variants in ${brightness.name} theme',
          fileName: switch (variant) {
            _Variant.web => 'stream_modal_dialog_${brightness.name}_matrix',
            _Variant.mobile => 'stream_modal_dialog_mobile_${brightness.name}_matrix',
          },
          builder: () => GoldenTestGroup(
            columns: 1,
            children: [
              GoldenTestScenario(
                name: 'title and body',
                child: _buildInTheme(
                  StreamModalDialog(
                    title: const Text('Settings'),
                    child: _body(),
                  ),
                  variant: variant,
                  brightness: brightness,
                ),
              ),
              GoldenTestScenario(
                name: 'header and footer actions',
                child: _buildInTheme(
                  Builder(
                    builder: (context) => StreamModalDialog(
                      title: const Text('Choose what to share'),
                      headerActions: [
                        StreamButton.icon(
                          icon: Icon(context.streamIcons.refresh),
                          style: StreamButtonStyle.secondary,
                          type: StreamButtonType.ghost,
                          onPressed: () {},
                        ),
                      ],
                      actions: [
                        StreamButton(
                          style: StreamButtonStyle.secondary,
                          type: StreamButtonType.ghost,
                          onPressed: () {},
                          child: const Text('Cancel'),
                        ),
                        StreamButton(onPressed: () {}, child: const Text('Share')),
                      ],
                      child: _body(),
                    ),
                  ),
                  variant: variant,
                  brightness: brightness,
                ),
              ),
              GoldenTestScenario(
                name: 'no title, no close button',
                child: _buildInTheme(
                  StreamModalDialog(
                    showCloseButton: false,
                    child: _body(),
                  ),
                  variant: variant,
                  brightness: brightness,
                ),
              ),
            ],
          ),
        );
      }
    }
  });
}

// The design's two sizes: Android and iOS get the mobile one, desktop and the
// web share the web one.
enum _Variant {
  web(platform: TargetPlatform.macOS, width: 480),
  mobile(platform: TargetPlatform.iOS, width: 360);

  const _Variant({
    required this.platform,
    required this.width,
  });

  final TargetPlatform platform;
  final double width;
}

Widget _body() => const Text('Changes apply to everyone in the conversation.');

Widget _buildInTheme(Widget child, {required _Variant variant, Brightness brightness = Brightness.light}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(brightness: brightness, platform: variant.platform, extensions: [streamTheme]),
    child: Builder(
      // On the scrim, the way showStreamModalDialog draws it. Clipped, so the
      // blur stays inside the scenario.
      builder: (context) => ClipRect(
        child: ColoredBox(
          color: StreamTheme.of(context).colorScheme.backgroundApp,
          child: SizedBox(
            width: variant.width,
            height: 280,
            child: Stack(
              children: [
                const Positioned.fill(child: StreamBlurScrim()),
                child,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
