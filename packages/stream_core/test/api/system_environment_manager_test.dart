import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  test('keeps the environment passed to the constructor', () {
    final manager = SystemEnvironmentManager(environment: _baseline);

    expect(manager.environment.sdkName, 'stream-sdk');
    expect(manager.environment.sdkIdentifier, 'dart');
    expect(manager.environment.sdkVersion, '1.2.3');
    expect(manager.environment.osName, 'ios');
  });

  test('builds the user agent from the current environment', () {
    final manager = SystemEnvironmentManager(environment: _baseline);

    expect(manager.userAgent, 'stream-sdk-dart-v1.2.3|os=ios');
  });

  test('ignores sdkName, sdkVersion and osName passed to an update', () {
    final manager = SystemEnvironmentManager(environment: _baseline);

    manager.updateEnvironment(
      const SystemEnvironment(
        sdkName: 'stream-chat',
        sdkIdentifier: 'dart',
        sdkVersion: '99.0.0',
        osName: 'spoofed-os',
      ),
    );

    expect(manager.environment.sdkName, 'stream-sdk');
    expect(manager.environment.sdkVersion, '1.2.3');
    expect(manager.environment.osName, 'ios');
  });

  test('passes app, os version and device fields through on an update', () {
    final manager = SystemEnvironmentManager(environment: _baseline);

    manager.updateEnvironment(
      const SystemEnvironment(
        sdkName: 'stream-sdk',
        sdkIdentifier: 'dart',
        sdkVersion: '1.2.3',
        appName: 'test-app',
        appVersion: '2.0.0',
        osVersion: '14',
        deviceModel: 'Pixel 7',
      ),
    );

    expect(manager.environment.appName, 'test-app');
    expect(manager.environment.appVersion, '2.0.0');
    expect(manager.environment.osVersion, '14');
    expect(manager.environment.deviceModel, 'Pixel 7');
  });

  test('promotes sdkIdentifier from dart to flutter', () {
    final manager = SystemEnvironmentManager(environment: _baseline);

    manager.updateEnvironment(_identifiedAs('flutter'));

    expect(manager.environment.sdkIdentifier, 'flutter');
  });

  test('ignores a demotion of sdkIdentifier from flutter to dart', () {
    final manager = SystemEnvironmentManager(environment: _baseline);

    manager
      ..updateEnvironment(_identifiedAs('flutter'))
      ..updateEnvironment(_identifiedAs('dart'));

    expect(manager.environment.sdkIdentifier, 'flutter');
  });

  test('keeps a promoted sdkIdentifier across later updates', () {
    final manager = SystemEnvironmentManager(environment: _baseline);

    manager
      ..updateEnvironment(_identifiedAs('flutter'))
      ..updateEnvironment(_identifiedAs('dart', appName: 'test-app'));

    expect(manager.environment.sdkIdentifier, 'flutter');
    expect(manager.environment.appName, 'test-app');
  });

  test('ignores an unrecognized sdkIdentifier', () {
    final manager = SystemEnvironmentManager(environment: _baseline);

    manager.updateEnvironment(_identifiedAs('android'));

    expect(manager.environment.sdkIdentifier, 'dart');
  });

  test('ignores an unrecognized sdkIdentifier when the baseline is unrecognized too', () {
    final manager = SystemEnvironmentManager(environment: _identifiedAs('dart-io'));

    manager.updateEnvironment(_identifiedAs('android'));

    expect(manager.environment.sdkIdentifier, 'dart-io');
  });

  test('accepts a known sdkIdentifier when the baseline is unrecognized', () {
    final manager = SystemEnvironmentManager(environment: _identifiedAs('dart-io'));

    manager.updateEnvironment(_identifiedAs('flutter'));

    expect(manager.environment.sdkIdentifier, 'flutter');
  });

  test('keeps the locked fields at the baseline across repeated updates', () {
    final manager = SystemEnvironmentManager(environment: _baseline);

    manager
      ..updateEnvironment(_identifiedAs('dart', appName: 'first-app'))
      ..updateEnvironment(_identifiedAs('dart', appName: 'second-app'));

    expect(manager.environment.appName, 'second-app');
    expect(manager.environment.sdkName, 'stream-sdk');
    expect(manager.environment.sdkVersion, '1.2.3');
    expect(manager.environment.osName, 'ios');
  });

  test('keeps the locked fields fixed when the baseline object mutates', () {
    final manager = SystemEnvironmentManager(environment: _MutatingBaseline());

    final observed = <String>[];
    for (var i = 0; i < 3; i++) {
      manager.updateEnvironment(_identifiedAs('dart'));
      observed.add(manager.environment.sdkName);
    }

    expect(observed, ['v0', 'v0', 'v0']);
  });

  test('clears a pass-through field left out of a later update', () {
    final manager = SystemEnvironmentManager(environment: _baseline);

    manager
      ..updateEnvironment(_identifiedAs('dart', appName: 'test-app'))
      ..updateEnvironment(_identifiedAs('dart'));

    expect(manager.environment.appName, isNull);
  });
}

// A baseline whose sdkName changes on every getter read. SystemEnvironment is
// not final, so the manager must snapshot the SDK-owned values at construction
// rather than re-read them from the instance it was given.
class _MutatingBaseline extends SystemEnvironment {
  _MutatingBaseline() : super(sdkName: 'v0', sdkIdentifier: 'dart', sdkVersion: '1.0.0');

  var _reads = 0;

  @override
  String get sdkName => 'v${_reads++}';
}

// The baseline a product SDK owns and passes to the constructor.
const _baseline = SystemEnvironment(
  sdkName: 'stream-sdk',
  sdkIdentifier: 'dart',
  sdkVersion: '1.2.3',
  osName: 'ios',
);

// An update as an integrator would send it: only the identifier and the
// overridable fields differ from the baseline.
SystemEnvironment _identifiedAs(String sdkIdentifier, {String? appName}) {
  return SystemEnvironment(
    sdkName: _baseline.sdkName,
    sdkIdentifier: sdkIdentifier,
    sdkVersion: _baseline.sdkVersion,
    appName: appName,
  );
}
