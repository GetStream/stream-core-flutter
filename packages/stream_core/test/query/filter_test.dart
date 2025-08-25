import 'dart:convert';

import 'package:stream_core/src/query/filter.dart';
import 'package:stream_core/src/query/filter_operator.dart';
import 'package:test/test.dart';

void main() {
  group('operators', () {
    test('equal', () {
      const field = 'testKey';
      const value = 'testValue';
      final filter = Filter.equal(field, value);
      expect(filter.field, field);
      expect(filter.value, value);
      expect(filter.operator, FilterOperator.equal);
    });

    test('greater', () {
      const field = 'testKey';
      const value = 'testValue';
      final filter = Filter.greater(field, value);
      expect(filter.field, field);
      expect(filter.value, value);
      expect(filter.operator, FilterOperator.greater);
    });

    test('greaterOrEqual', () {
      const field = 'testKey';
      const value = 'testValue';
      final filter = Filter.greaterOrEqual(field, value);
      expect(filter.field, field);
      expect(filter.value, value);
      expect(filter.operator, FilterOperator.greaterOrEqual);
    });

    test('less', () {
      const field = 'testKey';
      const value = 'testValue';
      final filter = Filter.less(field, value);
      expect(filter.field, field);
      expect(filter.value, value);
      expect(filter.operator, FilterOperator.less);
    });

    test('lessOrEqual', () {
      const field = 'testKey';
      const value = 'testValue';
      final filter = Filter.lessOrEqual(field, value);
      expect(filter.field, field);
      expect(filter.value, value);
      expect(filter.operator, FilterOperator.lessOrEqual);
    });

    test('in', () {
      const field = 'testKey';
      const values = ['testValue'];
      final filter = Filter.in_(field, values);
      expect(filter.field, field);
      expect(filter.value, values);
      expect(filter.operator, FilterOperator.in_);
    });

    test('in', () {
      const field = 'testKey';
      const values = ['testValue'];
      final filter = Filter.in_(field, values);
      expect(filter.field, field);
      expect(filter.value, values);
      expect(filter.operator, FilterOperator.in_);
    });

    test('query', () {
      const field = 'testKey';
      const value = 'testQuery';
      final filter = Filter.query(field, value);
      expect(filter.field, field);
      expect(filter.value, value);
      expect(filter.operator, FilterOperator.query);
    });

    test('autoComplete', () {
      const field = 'testKey';
      const value = 'testQuery';
      final filter = Filter.autoComplete(field, value);
      expect(filter.field, field);
      expect(filter.value, value);
      expect(filter.operator, FilterOperator.autoComplete);
    });

    test('exists', () {
      const field = 'testKey';
      final filter = Filter.exists(field);
      expect(filter.field, field);
      expect(filter.value, isTrue);
      expect(filter.operator, FilterOperator.exists);
    });

    test('raw', () {
      const value = {
        'test': ['a', 'b'],
      };
      const filter = Filter.raw(value: value);
      expect(filter.value, value);
    });

    test('empty', () {
      final filter = Filter.empty();
      expect(filter.value, <String, Object?>{});
    });

    test('contains', () {
      const field = 'testKey';
      const values = 'testValue';
      final filter = Filter.contains(field, values);
      expect(filter.field, field);
      expect(filter.value, values);
      expect(filter.operator, FilterOperator.contains);
    });

    group('groupedOperator', () {
      final filter1 = Filter.equal('testKey', 'testValue');
      final filter2 = Filter.in_('testKey', const ['testValue']);
      final filters = [filter1, filter2];

      test('and', () {
        final filter = Filter.and(filters);
        expect(filter.field, isNull);
        expect(filter.value, filters);
        expect(filter.operator, FilterOperator.and);
      });

      test('or', () {
        final filter = Filter.or(filters);
        expect(filter.field, isNull);
        expect(filter.value, filters);
        expect(filter.operator, FilterOperator.or);
      });
    });
  });

  group('encoding', () {
    group('nonGroupedFilter', () {
      test('simpleValue', () {
        const field = 'testKey';
        const value = 'testValue';
        final filter = Filter.equal(field, value);
        final encoded = json.encode(filter);
        expect(encoded, '{"$field":{"\$eq":${json.encode(value)}}}');
      });

      test('listValue', () {
        const field = 'testKey';
        const values = ['testValue'];
        final filter = Filter.in_(field, values);
        final encoded = json.encode(filter);
        expect(encoded, '{"$field":{"\$in":${json.encode(values)}}}');
      });

      test('raw', () {
        const value = {
          'test': ['a', 'b'],
        };
        const filter = Filter.raw(value: value);

        final encoded = json.encode(filter);
        expect(encoded, json.encode(value));
      });

      test('empty', () {
        final filter = Filter.empty();
        final encoded = json.encode(filter);
        expect(encoded, '{}');
      });
    });

    test('groupedFilter', () {
      final filter1 = Filter.equal('testKey', 'testValue');
      final filter2 = Filter.in_('testKey', const ['testValue']);
      final filters = [filter1, filter2];

      final filter = Filter.and(filters);
      final encoded = json.encode(filter);
      expect(encoded, '{"\$and":${json.encode(filters)}}');
    });

    group('equality', () {
      test('simpleFilter', () {
        final filter1 = Filter.equal('testKey', 'testValue');
        final filter2 = Filter.equal('testKey', 'testValue');
        expect(filter1, filter2);
      });

      test('groupedFilter', () {
        final filter1 = Filter.and([Filter.equal('testKey', 'testValue')]);
        final filter2 = Filter.and([Filter.equal('testKey', 'testValue')]);
        expect(filter1, filter2);
      });
    });
  });
}
