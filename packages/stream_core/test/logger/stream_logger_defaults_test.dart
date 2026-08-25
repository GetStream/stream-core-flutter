import 'dart:async';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

/// What a process that has never touched the logger starts with.
///
/// Deliberately the only test in this file, and it neither installs anything nor calls
/// `StreamLogger.reset`: every other suite restores the defaults rather than observing them, so a
/// change to the field initialisers would otherwise go unnoticed. `dart test` gives each file its
/// own isolate, which is what keeps these statics pristine.
void main() {
  test('an untouched logger admits nothing, at any level', () {
    const logger = StreamLogger('SC:Component');

    for (final level in StreamLogLevel.values) {
      expect(logger.isLoggable(level), isFalse, reason: '$level');
    }

    expect(
      capturePrints(() => logger.e(() => 'nobody asked for this', error: StateError('boom'))),
      isEmpty,
    );
  });
}

List<String> capturePrints(void Function() body) {
  final lines = <String>[];
  runZoned(body, zoneSpecification: ZoneSpecification(print: (_, _, _, line) => lines.add(line)));
  return lines;
}
