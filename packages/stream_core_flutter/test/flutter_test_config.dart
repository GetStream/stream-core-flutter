// ignore_for_file: do_not_use_environment

import 'dart:async';

import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final isCI = const String.fromEnvironment('IS_CI', defaultValue: 'false').toLowerCase() == 'true';

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      // Disable platform-specific goldens to ensure consistent results across
      // different machines and CI environments.
      platformGoldensConfig: PlatformGoldensConfig(enabled: !isCI),
    ),
    run: testMain,
  );
}
