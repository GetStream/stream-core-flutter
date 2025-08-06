import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  test('should return the all default set params', () {
    const options = HttpClientOptions();
    expect(options.baseUrl, 'https://chat.stream-io-api.com');
    expect(options.connectTimeout, const Duration(seconds: 30));
    expect(options.receiveTimeout, const Duration(seconds: 30));
    expect(options.queryParameters, const <String, dynamic>{});
    expect(options.headers, const <String, dynamic>{});
  });

  test('should override all the default set params', () {
    const options = HttpClientOptions(
      baseUrl: 'base-url',
      connectTimeout: Duration(seconds: 3),
      receiveTimeout: Duration(seconds: 3),
      headers: {'test': 'test'},
      queryParameters: {'123': '123'},
    );
    expect(options.baseUrl, 'base-url');
    expect(options.connectTimeout, const Duration(seconds: 3));
    expect(options.receiveTimeout, const Duration(seconds: 3));
    expect(options.headers, {'test': 'test'});
    expect(options.queryParameters, {'123': '123'});
  });
}
