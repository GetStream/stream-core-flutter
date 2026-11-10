import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  const primary = Color(0xFF000001);
  const success = Color(0xFF000002);
  const warning = Color(0xFF000003);
  const error = Color(0xFF000004);

  final factories = <String, StreamColorScheme Function()>{
    'light': () => StreamColorScheme.light(
      accentPrimarySubtle: primary,
      accentSuccessSubtle: success,
      accentWarningSubtle: warning,
      accentErrorSubtle: error,
    ),
    'dark': () => StreamColorScheme.dark(
      accentPrimarySubtle: primary,
      accentSuccessSubtle: success,
      accentWarningSubtle: warning,
      accentErrorSubtle: error,
    ),
  };

  for (final MapEntry(key: mode, value: create) in factories.entries) {
    test('StreamColorScheme.$mode defaults the subtle backgrounds to the subtle accents', () {
      final colorScheme = create();

      expect(colorScheme.backgroundInfoSubtle, primary);
      expect(colorScheme.backgroundSuccessSubtle, success);
      expect(colorScheme.backgroundWarningSubtle, warning);
      expect(colorScheme.backgroundErrorSubtle, error);
    });
  }
}
