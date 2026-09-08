import 'system_environment.dart';

/// {@template systemEnvironmentManager}
/// A manager class to handle the current [SystemEnvironment].
///
/// The [SystemEnvironment] passed to the constructor is the SDK-owned
/// baseline, and is trusted as-is: only the SDK that builds the manager is
/// meant to provide it. Every environment passed to [updateEnvironment] is
/// sanitized against that baseline, so an integrator can enrich the Stream
/// client header without changing the SDK identity it reports.
/// {@endtemplate}
class SystemEnvironmentManager {
  /// {@macro systemEnvironmentManager}
  SystemEnvironmentManager({
    required SystemEnvironment environment,
  }) : _sdkName = environment.sdkName,
       _sdkVersion = environment.sdkVersion,
       _osName = environment.osName,
       _environment = environment;

  // The SDK-owned values every update is sanitized against.
  //
  // Snapshotted rather than kept as a SystemEnvironment reference: the type is
  // not final, so a subtype could return something different on every getter
  // read and drift the values an update is supposed to be locked to.
  final String _sdkName;
  final String _sdkVersion;
  final String? _osName;

  /// Returns the Stream client user agent string based on the current
  /// [environment] value.
  String get userAgent => _environment.xStreamClientHeader;

  /// The current [SystemEnvironment].
  SystemEnvironment get environment => _environment;
  SystemEnvironment _environment;

  /// Updates the current [SystemEnvironment].
  ///
  /// The passed [environment] is sanitized against the environment this manager
  /// was constructed with, so the SDK identity reported in the Stream client
  /// header cannot be changed after construction.
  ///
  /// The following fields are applied as passed.
  ///
  /// - [SystemEnvironment.appName]
  /// - [SystemEnvironment.appVersion]
  /// - [SystemEnvironment.osVersion]
  /// - [SystemEnvironment.deviceModel]
  ///
  /// The following fields keep the value given to the constructor, and custom
  /// values for them are ignored.
  ///
  /// - [SystemEnvironment.sdkName]
  /// - [SystemEnvironment.sdkVersion]
  /// - [SystemEnvironment.osName]
  ///
  /// [SystemEnvironment.sdkIdentifier] is a partial exception: only the `dart`
  /// to `flutter` promotion is accepted. Any other value, including a `flutter`
  /// to `dart` demotion or an unrecognized identifier, is ignored.
  ///
  /// Fields are replaced rather than merged, so a field left out of
  /// [environment] is cleared rather than carried over from a previous update.
  ///
  /// For a manager constructed with `sdkName` `stream-feeds`, `sdkIdentifier`
  /// `dart` and `sdkVersion` `1.0.0`:
  ///
  /// ```dart
  /// manager.updateEnvironment(
  ///   const SystemEnvironment(
  ///     sdkName: 'spoofed', // Ignored.
  ///     sdkIdentifier: 'dart',
  ///     sdkVersion: '9.9.9', // Ignored.
  ///     appName: 'MyApp', // Applied.
  ///   ),
  /// );
  ///
  /// print(manager.userAgent); // stream-feeds-dart-v1.0.0|app=MyApp
  /// ```
  void updateEnvironment(SystemEnvironment environment) {
    _environment = _sanitize(environment);
  }

  // Rebuilds the passed environment with the SDK-owned fields restored from
  // the baseline.
  //
  // Always returns a fresh instance. SystemEnvironment is not final, so the
  // passed value may be a subtype whose getters return something different on
  // every read; its fields are copied out once here and it is never handed on
  // directly. Do not add a fast path that returns the passed instance.
  SystemEnvironment _sanitize(SystemEnvironment environment) {
    final current = _SdkIdentifier(_environment.sdkIdentifier);
    final proposed = _SdkIdentifier(environment.sdkIdentifier);

    return SystemEnvironment(
      sdkName: _sdkName,
      sdkIdentifier: current.resolveUpdate(proposed),
      sdkVersion: _sdkVersion,
      appName: environment.appName,
      appVersion: environment.appVersion,
      osName: _osName,
      osVersion: environment.osVersion,
      deviceModel: environment.deviceModel,
    );
  }
}

/// Extension on [SystemEnvironment] to build a Stream client header string.
extension XStreamClientHeaderExtension on SystemEnvironment {
  /// Builds a Stream client header string for API requests.
  ///
  /// The header follows the format:
  /// `{sdk}-{identifier}-v{version}
  /// |app={appName}
  /// |app_version={appVersion}
  /// |os={osName} {osVersion}
  /// |device_model={deviceModel}`
  ///
  /// Only non-null values are included in the header.
  String get xStreamClientHeader {
    final clientInfo = '$sdkName-$sdkIdentifier-v$sdkVersion';

    return [
      clientInfo,
      if (appName case final name?) 'app=$name',
      if (appVersion case final version?) 'app_version=$version',
      switch ((osName, osVersion)) {
        (final name?, final version?) => 'os=$name $version',
        (final name?, null) => 'os=$name',
        _ => null,
      },
      if (deviceModel case final model?) 'device_model=$model',
    ].nonNulls.join('|');
  }
}

// Known SDK identifiers, ranked so that the dart to flutter transition is
// one-way and unrecognized identifiers are never accepted.
extension type const _SdkIdentifier(String value) implements String {
  static const dart = _SdkIdentifier('dart');
  static const flutter = _SdkIdentifier('flutter');

  int get _precedence => switch (this) {
    dart => 0,
    flutter => 1,
    _ => -1,
  };

  // Returns the identifier to keep when [proposed] is offered as a
  // replacement for this one.
  _SdkIdentifier resolveUpdate(_SdkIdentifier proposed) {
    if (proposed._precedence < 0) return this;
    if (proposed._precedence < _precedence) return this;
    return proposed;
  }
}
