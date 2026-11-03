import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamScaffold Golden Tests', () {
    goldenTest(
      'renders a snackbar above the bottom slots in light theme',
      fileName: 'stream_scaffold_snackbar_light_matrix',
      builder: () => _buildMatrix(Brightness.light),
    );

    goldenTest(
      'renders a snackbar above the bottom slots in dark theme',
      fileName: 'stream_scaffold_snackbar_dark_matrix',
      builder: () => _buildMatrix(Brightness.dark),
    );
  });
}

GoldenTestGroup _buildMatrix(Brightness brightness) {
  return GoldenTestGroup(
    columns: 3,
    children: [
      GoldenTestScenario(
        name: 'docked bottom',
        child: _buildScene(brightness: brightness),
      ),
      GoldenTestScenario(
        name: 'floating bottom',
        child: _buildScene(brightness: brightness, bottomSurfaceStyle: StreamSurfaceStyle.floating),
      ),
      GoldenTestScenario(
        name: 'docked bottom · accessory',
        child: _buildScene(brightness: brightness, withAccessory: true),
      ),
    ],
  );
}

Widget _buildScene({
  required Brightness brightness,
  StreamSurfaceStyle bottomSurfaceStyle = StreamSurfaceStyle.regular,
  bool withAccessory = false,
}) {
  return SizedBox(
    width: 320,
    height: 400,
    child: Theme(
      data: ThemeData(
        brightness: brightness,
        extensions: [StreamTheme(brightness: brightness)],
      ),
      child: _ShowingSnackbar(
        child: StreamScaffold(
          bottomSurfaceStyle: bottomSurfaceStyle,
          body: const _Body(),
          bottom: const _Bottom(),
          bottomAccessory: withAccessory ? const _Accessory() : null,
        ),
      ),
    ),
  );
}

// Wraps [child] in a snackbar scope that is already showing a snackbar.
class _ShowingSnackbar extends StatefulWidget {
  const _ShowingSnackbar({required this.child});

  final Widget child;

  @override
  State<_ShowingSnackbar> createState() => _ShowingSnackbarState();
}

class _ShowingSnackbarState extends State<_ShowingSnackbar> {
  final _messenger = StreamSnackbarMessenger();

  @override
  void initState() {
    super.initState();
    _messenger.show(
      StreamSnackbar(
        message: const Text('Message copied to clipboard'),
        variant: StreamSnackbarVariant.success,
      ),
    );
  }

  @override
  void dispose() {
    _messenger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamSnackbarScope.withState(messenger: _messenger, child: widget.child);
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    return ListView(
      children: [
        for (var i = 0; i < 8; i++)
          ListTile(
            title: Text('Message ${i + 1}', style: TextStyle(color: colorScheme.textPrimary)),
          ),
      ],
    );
  }
}

class _Bottom extends StatelessWidget {
  const _Bottom();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    return Container(
      height: 56,
      alignment: Alignment.center,
      color: colorScheme.backgroundElevation1,
      child: Text('Bottom', style: TextStyle(color: colorScheme.textSecondary)),
    );
  }
}

class _Accessory extends StatelessWidget {
  const _Accessory();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    return Container(
      height: 40,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        shape: const StadiumBorder(),
      ),
      child: Text('Bottom accessory', style: TextStyle(color: colorScheme.textPrimary)),
    );
  }
}
