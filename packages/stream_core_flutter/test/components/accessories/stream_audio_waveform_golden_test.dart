import 'dart:math' as math;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

final List<double> _sampleWaveform = List.generate(
  120,
  (i) => (math.sin(i * 0.15) * 0.3 + 0.5 + math.sin(i * 0.4) * 0.2).clamp(0.0, 1.0),
);

void main() {
  group('StreamAudioWaveformSlider Golden Tests', () {
    goldenTest(
      'renders light theme states',
      fileName: 'stream_audio_waveform_slider_light_states',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          GoldenTestScenario(
            name: 'idle_no_progress',
            child: _buildSliderInTheme(
              StreamAudioWaveformSlider(
                waveform: _sampleWaveform,
                progress: 0,
                onChanged: (_) {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'idle_with_progress',
            child: _buildSliderInTheme(
              StreamAudioWaveformSlider(
                waveform: _sampleWaveform,
                progress: 0.4,
                onChanged: (_) {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'active_with_progress',
            child: _buildSliderInTheme(
              StreamAudioWaveformSlider(
                waveform: _sampleWaveform,
                progress: 0.5,
                isActive: true,
                onChanged: (_) {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'active_full_progress',
            child: _buildSliderInTheme(
              StreamAudioWaveformSlider(
                waveform: _sampleWaveform,
                progress: 1.0,
                isActive: true,
                onChanged: (_) {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'empty_waveform',
            child: _buildSliderInTheme(
              StreamAudioWaveformSlider(
                waveform: const [],
                progress: 0,
                onChanged: (_) {},
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme states',
      fileName: 'stream_audio_waveform_slider_dark_states',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          GoldenTestScenario(
            name: 'idle_no_progress',
            child: _buildSliderInTheme(
              StreamAudioWaveformSlider(
                waveform: _sampleWaveform,
                progress: 0,
                onChanged: (_) {},
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'idle_with_progress',
            child: _buildSliderInTheme(
              StreamAudioWaveformSlider(
                waveform: _sampleWaveform,
                progress: 0.4,
                onChanged: (_) {},
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'active_with_progress',
            child: _buildSliderInTheme(
              StreamAudioWaveformSlider(
                waveform: _sampleWaveform,
                progress: 0.5,
                isActive: true,
                onChanged: (_) {},
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'active_full_progress',
            child: _buildSliderInTheme(
              StreamAudioWaveformSlider(
                waveform: _sampleWaveform,
                progress: 1.0,
                isActive: true,
                onChanged: (_) {},
              ),
              brightness: Brightness.dark,
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders custom theme overrides',
      fileName: 'stream_audio_waveform_slider_custom_theme',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          GoldenTestScenario(
            name: 'custom_colors_idle',
            child: _buildSliderInTheme(
              StreamAudioWaveformTheme(
                data: const StreamAudioWaveformThemeData(
                  color: Colors.purple,
                  progressColor: Colors.orange,
                  idleThumbColor: Colors.grey,
                  thumbBorderColor: Colors.black,
                ),
                child: StreamAudioWaveformSlider(
                  waveform: _sampleWaveform,
                  progress: 0.5,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'custom_colors_active',
            child: _buildSliderInTheme(
              StreamAudioWaveformTheme(
                data: const StreamAudioWaveformThemeData(
                  color: Colors.purple,
                  progressColor: Colors.orange,
                  activeThumbColor: Colors.red,
                  thumbBorderColor: Colors.black,
                ),
                child: StreamAudioWaveformSlider(
                  waveform: _sampleWaveform,
                  progress: 0.5,
                  isActive: true,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });

  group('StreamAudioWaveform Golden Tests', () {
    goldenTest(
      'renders light theme states',
      fileName: 'stream_audio_waveform_light_states',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          GoldenTestScenario(
            name: 'no_progress',
            child: _buildWaveformInTheme(
              StreamAudioWaveform(
                waveform: _sampleWaveform,
                progress: 0,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'half_progress',
            child: _buildWaveformInTheme(
              StreamAudioWaveform(
                waveform: _sampleWaveform,
                progress: 0.5,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'full_progress',
            child: _buildWaveformInTheme(
              StreamAudioWaveform(
                waveform: _sampleWaveform,
                progress: 1.0,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'empty_waveform',
            child: _buildWaveformInTheme(
              const StreamAudioWaveform(
                waveform: [],
                progress: 0,
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme states',
      fileName: 'stream_audio_waveform_dark_states',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          GoldenTestScenario(
            name: 'no_progress',
            child: _buildWaveformInTheme(
              StreamAudioWaveform(
                waveform: _sampleWaveform,
                progress: 0,
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'half_progress',
            child: _buildWaveformInTheme(
              StreamAudioWaveform(
                waveform: _sampleWaveform,
                progress: 0.5,
              ),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'full_progress',
            child: _buildWaveformInTheme(
              StreamAudioWaveform(
                waveform: _sampleWaveform,
                progress: 1.0,
              ),
              brightness: Brightness.dark,
            ),
          ),
        ],
      ),
    );
  });
}

Widget _buildSliderInTheme(
  Widget slider, {
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
          padding: const EdgeInsets.all(8),
          child: SizedBox(width: 280, height: 36, child: slider),
        ),
      ),
    ),
  );
}

Widget _buildWaveformInTheme(
  Widget waveform, {
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
          padding: const EdgeInsets.all(8),
          child: SizedBox(width: 280, height: 32, child: waveform),
        ),
      ),
    ),
  );
}
