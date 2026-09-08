// Epoch nanoseconds are inherently larger than a JS number can hold exactly,
// so the v2 timestamps below are spelled out as literals regardless.
// ignore_for_file: avoid_js_rounded_ints

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  const converter = StreamDateTimeConverter();

  group('fromJson', () {
    test('parses an RFC3339 string in UTC', () {
      final result = converter.fromJson('2024-01-15T10:30:00Z');

      expect(result, DateTime.utc(2024, 1, 15, 10, 30));
      expect(result.isUtc, isTrue);
    });

    test('normalizes an RFC3339 string with an offset to UTC', () {
      final result = converter.fromJson('2024-01-15T10:30:00+02:00');

      expect(result, DateTime.utc(2024, 1, 15, 8, 30));
      expect(result.isUtc, isTrue);
    });

    test('normalizes an RFC3339 string with a negative offset to UTC', () {
      final result = converter.fromJson('2024-01-15T10:30:00-05:30');

      expect(result, DateTime.utc(2024, 1, 15, 16));
      expect(result.isUtc, isTrue);
    });

    test('converts a zoneless string from local time to UTC', () {
      final result = converter.fromJson('2024-01-15T10:30:00');

      expect(result, DateTime(2024, 1, 15, 10, 30).toUtc());
      expect(result.isUtc, isTrue);
    });

    test('keeps microsecond precision when parsing a string', () {
      final result = converter.fromJson('2024-01-15T10:30:00.123456Z');

      expect(result.microsecondsSinceEpoch, DateTime.utc(2024, 1, 15, 10, 30).microsecondsSinceEpoch + 123456);
    });

    test('parses a date-only string as local midnight converted to UTC', () {
      final result = converter.fromJson('2024-01-15');

      expect(result, DateTime(2024, 1, 15).toUtc());
      expect(result.isUtc, isTrue);
    });

    test('converts epoch nanoseconds to a UTC DateTime', () {
      final result = converter.fromJson(1705314600000000000);

      expect(result, DateTime.utc(2024, 1, 15, 10, 30));
      expect(result.isUtc, isTrue);
    });

    test('keeps microsecond precision when converting nanoseconds', () {
      final result = converter.fromJson(1705314600123456000);

      expect(result.microsecondsSinceEpoch, DateTime.utc(2024, 1, 15, 10, 30).microsecondsSinceEpoch + 123456);
    });

    test('truncates sub-microsecond nanoseconds', () {
      final result = converter.fromJson(1705314600000001999);

      expect(result.microsecondsSinceEpoch, DateTime.utc(2024, 1, 15, 10, 30).microsecondsSinceEpoch + 1);
    });

    test('converts zero nanoseconds to the epoch', () {
      final result = converter.fromJson(0);

      expect(result, DateTime.utc(1970));
      expect(result.isUtc, isTrue);
    });

    test('converts negative nanoseconds to a pre-epoch DateTime', () {
      final result = converter.fromJson(-1000000000);

      expect(result, DateTime.utc(1969, 12, 31, 23, 59, 59));
      expect(result.isUtc, isTrue);
    });

    test('accepts a double as well as an int', () {
      final result = converter.fromJson(1500.0);

      expect(result, DateTime.fromMicrosecondsSinceEpoch(1, isUtc: true));
      expect(result.isUtc, isTrue);
    });

    test('throws a FormatException on an unparsable string', () {
      expect(() => converter.fromJson('not a date'), throwsFormatException);
    });

    test('throws a FormatException on an unsupported JSON type', () {
      expect(() => converter.fromJson(true), throwsFormatException);
      expect(() => converter.fromJson(<String, Object?>{}), throwsFormatException);
      expect(() => converter.fromJson(<Object?>[]), throwsFormatException);
    });
  });

  group('toJson', () {
    test('serializes a UTC DateTime as RFC3339', () {
      final result = converter.toJson(DateTime.utc(2024, 1, 15, 10, 30));

      expect(result, '2024-01-15T10:30:00.000Z');
    });

    test('normalizes a local DateTime to UTC', () {
      final local = DateTime(2024, 1, 15, 10, 30);

      final result = converter.toJson(local);

      expect(result, endsWith('Z'));
      expect(DateTime.parse(result), local.toUtc());
    });

    test('keeps microsecond precision', () {
      final result = converter.toJson(DateTime.utc(2024, 1, 15, 10, 30, 0, 123, 456));

      expect(result, '2024-01-15T10:30:00.123456Z');
    });
  });

  group('round trip', () {
    test('a string survives fromJson then toJson', () {
      expect(converter.toJson(converter.fromJson('2024-01-15T10:30:00.123456Z')), '2024-01-15T10:30:00.123456Z');
    });

    test('nanoseconds survive fromJson then toJson', () {
      expect(converter.toJson(converter.fromJson(1705314600123456000)), '2024-01-15T10:30:00.123456Z');
    });
  });
}
