import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final isRunningInCi = Platform.environment.containsKey('GITHUB_ACTIONS');

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      // Enable golden tests for CI environments and disable them for local environments.
      ciGoldensConfig: CiGoldensConfig(enabled: isRunningInCi),
      // Disable platform-specific goldens to ensure consistent results across
      // different machines and CI environments.
      platformGoldensConfig: PlatformGoldensConfig(enabled: !isRunningInCi),
    ),
    run: testMain,
  );
}
