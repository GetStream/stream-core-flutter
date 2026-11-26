import 'package:flutter_test/flutter_test.dart';
import 'package:stream_thumbnail/stream_thumbnail.dart';

void main() {
  test('file rejects an empty path', () {
    expect(() => StreamThumbnailSource.file(''), throwsA(isA<AssertionError>()));
  });

  test('network sources with the same headers in any order are equal', () {
    final url = Uri.parse('https://cdn.example.com/a.mp4');
    final first = StreamThumbnailSource.network(url, headers: const {'a': '1', 'b': '2'});
    final second = StreamThumbnailSource.network(url, headers: const {'b': '2', 'a': '1'});

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });

  test('a network source keeps its headers when the map it was given changes', () {
    final headers = {'a': '1'};
    final source = StreamThumbnailSource.network(Uri.parse('https://cdn.example.com/a.mp4'), headers: headers);
    final hashCode = source.hashCode;

    headers['b'] = '2';

    expect(source.headers, {'a': '1'});
    expect(source.hashCode, hashCode);
  });

  test('network sources with different headers are not equal', () {
    final url = Uri.parse('https://cdn.example.com/a.mp4');

    expect(StreamThumbnailSource.network(url), isNot(StreamThumbnailSource.network(url, headers: const {'a': '1'})));
  });

  test('file sources with different paths are not equal', () {
    expect(StreamThumbnailSource.file('/a.mp4'), isNot(StreamThumbnailSource.file('/b.mp4')));
  });

  test('a file source is not equal to a content URI source with the same location', () {
    expect(
      StreamThumbnailSource.file('content://media/1'),
      isNot(StreamThumbnailSource.contentUri(Uri.parse('content://media/1'))),
    );
  });

  test('toString shows the kind and the URL without its query', () {
    final source = StreamThumbnailSource.network(Uri.parse('https://cdn.example.com/a.mp4?w=640'));

    expect(source.toString(), 'StreamThumbnailSource.network(https://cdn.example.com/a.mp4)');
  });
}
