import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  test('generates a minimal header with the required fields only', () {
    const environment = SystemEnvironment(
      sdkName: 'stream-sdk',
      sdkIdentifier: 'dart',
      sdkVersion: '1.0.0',
    );

    expect(environment.xStreamClientHeader, 'stream-sdk-dart-v1.0.0');
  });

  test('includes the app name when available', () {
    const environment = SystemEnvironment(
      sdkName: 'stream-sdk',
      sdkIdentifier: 'dart',
      sdkVersion: '1.0.0',
      appName: 'test-app',
    );

    expect(environment.xStreamClientHeader, 'stream-sdk-dart-v1.0.0|app=test-app');
  });

  test('includes the app version when available', () {
    const environment = SystemEnvironment(
      sdkName: 'stream-sdk',
      sdkIdentifier: 'dart',
      sdkVersion: '1.0.0',
      appVersion: '2.0.0',
    );

    expect(environment.xStreamClientHeader, 'stream-sdk-dart-v1.0.0|app_version=2.0.0');
  });

  test('includes the OS name and version together', () {
    const environment = SystemEnvironment(
      sdkName: 'stream-sdk',
      sdkIdentifier: 'dart',
      sdkVersion: '1.0.0',
      osName: 'ios',
      osVersion: '16.0',
    );

    expect(environment.xStreamClientHeader, 'stream-sdk-dart-v1.0.0|os=ios 16.0');
  });

  test('includes the OS name alone when the version is null', () {
    const environment = SystemEnvironment(
      sdkName: 'stream-sdk',
      sdkIdentifier: 'dart',
      sdkVersion: '1.0.0',
      osName: 'android',
    );

    expect(environment.xStreamClientHeader, 'stream-sdk-dart-v1.0.0|os=android');
  });

  test('omits the OS segment when the name is null but the version is not', () {
    const environment = SystemEnvironment(
      sdkName: 'stream-sdk',
      sdkIdentifier: 'dart',
      sdkVersion: '1.0.0',
      osVersion: '16.0',
    );

    expect(environment.xStreamClientHeader, 'stream-sdk-dart-v1.0.0');
  });

  test('includes the device model when available', () {
    const environment = SystemEnvironment(
      sdkName: 'stream-sdk',
      sdkIdentifier: 'dart',
      sdkVersion: '1.0.0',
      deviceModel: 'iPhone 14',
    );

    expect(environment.xStreamClientHeader, 'stream-sdk-dart-v1.0.0|device_model=iPhone 14');
  });

  test('includes every segment in order when all fields are available', () {
    const environment = SystemEnvironment(
      sdkName: 'stream-sdk',
      sdkIdentifier: 'dart',
      sdkVersion: '1.0.0',
      appName: 'test-app',
      appVersion: '2.0.0',
      osName: 'ios',
      osVersion: '16.0',
      deviceModel: 'iPhone 14',
    );

    expect(
      environment.xStreamClientHeader,
      'stream-sdk-dart-v1.0.0|app=test-app|app_version=2.0.0|os=ios 16.0|device_model=iPhone 14',
    );
  });

  test('skips the null values between populated ones', () {
    const environment = SystemEnvironment(
      sdkName: 'stream-sdk',
      sdkIdentifier: 'dart',
      sdkVersion: '1.0.0',
      appVersion: '2.0.0',
      deviceModel: 'iPhone 14',
    );

    expect(
      environment.xStreamClientHeader,
      'stream-sdk-dart-v1.0.0|app_version=2.0.0|device_model=iPhone 14',
    );
  });
}
