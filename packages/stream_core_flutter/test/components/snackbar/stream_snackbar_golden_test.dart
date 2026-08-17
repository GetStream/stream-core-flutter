import 'package:alchemist/alchemist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamSnackbar Golden Tests', () {
    goldenTest(
      'renders light theme variant matrix',
      fileName: 'stream_snackbar_light_matrix',
      pumpBeforeTest: pumpOnce,
      builder: () => GoldenTestGroup(
        columns: 1,
        children: [
          for (final variant in StreamSnackbarVariant.values) ...[
            GoldenTestScenario(
              name: '${variant.name} · message only',
              child: _buildInTheme(
                StreamSnackbar(
                  message: const Text('Saved successfully'),
                  variant: variant,
                ),
              ),
            ),
            GoldenTestScenario(
              name: '${variant.name} · with action',
              child: _buildInTheme(
                StreamSnackbar(
                  message: const Text('Message deleted'),
                  variant: variant,
                  action: StreamSnackbarAction(label: const Text('Undo'), onPressed: () {}),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    goldenTest(
      'renders dark theme variant matrix',
      fileName: 'stream_snackbar_dark_matrix',
      pumpBeforeTest: pumpOnce,
      builder: () => GoldenTestGroup(
        columns: 1,
        children: [
          for (final variant in StreamSnackbarVariant.values) ...[
            GoldenTestScenario(
              name: '${variant.name} · message only',
              child: _buildInTheme(
                StreamSnackbar(
                  message: const Text('Saved successfully'),
                  variant: variant,
                ),
                brightness: Brightness.dark,
              ),
            ),
            GoldenTestScenario(
              name: '${variant.name} · with action',
              child: _buildInTheme(
                StreamSnackbar(
                  message: const Text('Message deleted'),
                  variant: variant,
                  action: StreamSnackbarAction(label: const Text('Undo'), onPressed: () {}),
                ),
                brightness: Brightness.dark,
              ),
            ),
          ],
        ],
      ),
    );

    goldenTest(
      'renders RTL variant matrix',
      fileName: 'stream_snackbar_rtl_matrix',
      pumpBeforeTest: pumpOnce,
      builder: () => GoldenTestGroup(
        columns: 1,
        children: [
          for (final variant in StreamSnackbarVariant.values) ...[
            GoldenTestScenario(
              name: '${variant.name} · message only',
              child: _buildInTheme(
                StreamSnackbar(
                  message: const Text('تم الحفظ بنجاح'),
                  variant: variant,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            GoldenTestScenario(
              name: '${variant.name} · with action',
              child: _buildInTheme(
                StreamSnackbar(
                  message: const Text('تم حذف الرسالة'),
                  variant: variant,
                  action: StreamSnackbarAction(label: const Text('تراجع'), onPressed: () {}),
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ],
      ),
    );
  });
}

Widget _buildInTheme(
  Widget child, {
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Directionality(
    textDirection: textDirection,
    child: Theme(
      data: ThemeData(
        brightness: brightness,
        extensions: [streamTheme],
      ),
      child: Builder(
        builder: (context) => Material(
          color: StreamTheme.of(context).colorScheme.backgroundApp,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(child: child),
          ),
        ),
      ),
    ),
  );
}
