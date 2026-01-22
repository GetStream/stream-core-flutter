// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

class TestModel {
  TestModel({
    this.id,
    this.name,
    this.createdAt,
    this.members,
    this.type,
    this.metadata,
    this.tags,
    this.projects,
    this.location,
  });

  final String? id;
  final String? name;
  final DateTime? createdAt;
  final List<String>? members;
  final String? type;
  final Map<String, Object?>? metadata;
  final List<String>? tags;
  final List<Map<String, Object?>>? projects;
  final LocationCoordinate? location;
}

// Test implementation of FilterField for testing purposes
class TestFilterField extends FilterField<TestModel> {
  TestFilterField(super.remote, super.value);

  static final id = TestFilterField('id', (it) => it.id);
  static final name = TestFilterField('name', (it) => it.name);
  static final createdAt = TestFilterField('created_at', (it) => it.createdAt);
  static final members = TestFilterField('members', (it) => it.members);
  static final type = TestFilterField('type', (it) => it.type);
  static final metadata = TestFilterField('metadata', (it) => it.metadata);
  static final tags = TestFilterField('tags', (it) => it.tags);
  static final projects = TestFilterField('projects', (it) => it.projects);
  static final near = TestFilterField('near', (it) => it.location);
  static final withinBounds = TestFilterField(
    'within_bounds',
    (it) => it.location,
  );
}

void main() {
  group('Comparison', () {
    group('Equal', () {
      test('should create equal filter correctly', () {
        final field = TestFilterField.name;
        const value = 'test';

        var filter = Filter.equal(field, value);

        expect(filter, isA<EqualOperator<TestModel>>());
        filter = filter as EqualOperator<TestModel>;
        expect(filter.field, field);
        expect(filter.value, value);
        expect(filter.operator, FilterOperator.equal);
      });

      test('should serialize to JSON correctly', () {
        final field = TestFilterField.name;
        const value = 'test';

        final filter = Filter.equal(field, value);
        final json = filter.toJson();

        expect(json, {
          'name': {r'$eq': 'test'},
        });
      });

      test('should work with different value types', () {
        final numericFilter = Filter.equal(TestFilterField.id, 123);
        final boolFilter = Filter.equal(TestFilterField.type, true);

        expect(numericFilter.toJson(), {
          'id': {r'$eq': 123},
        });
        expect(boolFilter.toJson(), {
          'type': {r'$eq': true},
        });
      });
    });

    group('Greater', () {
      test('should create greater filter correctly', () {
        final field = TestFilterField.createdAt;
        final value = DateTime(2023);

        var filter = Filter.greater(field, value);

        expect(filter, isA<GreaterOperator<TestModel>>());
        filter = filter as GreaterOperator<TestModel>;
        expect(filter.field, field);
        expect(filter.value, value);
        expect(filter.operator, FilterOperator.greater);
      });

      test('should serialize to JSON correctly', () {
        final field = TestFilterField.id;
        const value = 100;

        final filter = Filter.greater(field, value);
        final json = filter.toJson();

        expect(json, {
          'id': {r'$gt': 100},
        });
      });
    });

    group('GreaterOrEqual', () {
      test('should create greater or equal filter correctly', () {
        final field = TestFilterField.id;
        const value = 50;

        var filter = Filter.greaterOrEqual(field, value);

        expect(filter, isA<GreaterOrEqualOperator<TestModel>>());
        filter = filter as GreaterOrEqualOperator<TestModel>;
        expect(filter.field, field);
        expect(filter.value, value);
        expect(filter.operator, FilterOperator.greaterOrEqual);
      });

      test('should serialize to JSON correctly', () {
        final field = TestFilterField.id;
        const value = 50;

        final filter = Filter.greaterOrEqual(field, value);
        final json = filter.toJson();

        expect(json, {
          'id': {r'$gte': 50},
        });
      });
    });

    group('Less', () {
      test('should create less filter correctly', () {
        final field = TestFilterField.id;
        const value = 100;

        var filter = Filter.less(field, value);

        expect(filter, isA<LessOperator<TestModel>>());
        filter = filter as LessOperator<TestModel>;
        expect(filter.field, field);
        expect(filter.value, value);
        expect(filter.operator, FilterOperator.less);
      });

      test('should serialize to JSON correctly', () {
        final field = TestFilterField.id;
        const value = 100;

        final filter = Filter.less(field, value);
        final json = filter.toJson();

        expect(json, {
          'id': {r'$lt': 100},
        });
      });
    });

    group('LessOrEqual', () {
      test('should create less or equal filter correctly', () {
        final field = TestFilterField.id;
        const value = 100;

        var filter = Filter.lessOrEqual(field, value);

        expect(filter, isA<LessOrEqualOperator<TestModel>>());
        filter = filter as LessOrEqualOperator<TestModel>;
        expect(filter.field, field);
        expect(filter.value, value);
        expect(filter.operator, FilterOperator.lessOrEqual);
      });

      test('should serialize to JSON correctly', () {
        final field = TestFilterField.id;
        const value = 100;

        final filter = Filter.lessOrEqual(field, value);
        final json = filter.toJson();

        expect(json, {
          'id': {r'$lte': 100},
        });
      });
    });
  });

  group('List', () {
    group('In', () {
      test('should create in filter correctly', () {
        final field = TestFilterField.tags;
        final values = ['tag1', 'tag2', 'tag3'];

        var filter = Filter.in_(field, values);

        expect(filter, isA<InOperator<TestModel>>());
        filter = filter as InOperator<TestModel>;
        expect(filter.field, field);
        expect(filter.value, values);
        expect(filter.operator, FilterOperator.in_);
      });

      test('should serialize to JSON correctly', () {
        final field = TestFilterField.tags;
        final values = ['tag1', 'tag2', 'tag3'];

        final filter = Filter.in_(field, values);
        final json = filter.toJson();

        expect(json, {
          'tags': {
            r'$in': ['tag1', 'tag2', 'tag3'],
          },
        });
      });

      test('should work with different value types', () {
        final numericFilter = Filter.in_(TestFilterField.id, [1, 2, 3]);

        expect(numericFilter.toJson(), {
          'id': {
            r'$in': [1, 2, 3],
          },
        });
      });
    });

    group('Contains', () {
      test('should create contains filter correctly', () {
        final field = TestFilterField.members;
        const value = 'user123';

        var filter = Filter.contains(field, value);

        expect(filter, isA<ContainsOperator<TestModel>>());
        filter = filter as ContainsOperator<TestModel>;
        expect(filter.field, field);
        expect(filter.value, value);
        expect(filter.operator, FilterOperator.contains_);
      });

      test('should serialize to JSON correctly', () {
        final field = TestFilterField.members;
        const value = 'user123';

        final filter = Filter.contains(field, value);
        final json = filter.toJson();

        expect(json, {
          'members': {r'$contains': 'user123'},
        });
      });
    });
  });

  group('Exists', () {
    test('should create exists filter correctly', () {
      final field = TestFilterField.metadata;
      const exists = true;

      var filter = Filter.exists(field, exists: exists);

      expect(filter, isA<ExistsOperator<TestModel>>());
      filter = filter as ExistsOperator<TestModel>;
      expect(filter.field, field);
      expect(filter.exists, exists);
      expect(filter.operator, FilterOperator.exists);
    });

    test('should serialize to JSON correctly with exists=true', () {
      final field = TestFilterField.metadata;
      const exists = true;

      final filter = Filter.exists(field, exists: exists);
      final json = filter.toJson();

      expect(json, {
        'metadata': {r'$exists': true},
      });
    });

    test('should serialize to JSON correctly with exists=false', () {
      final field = TestFilterField.metadata;
      const exists = false;

      final filter = Filter.exists(field, exists: exists);
      final json = filter.toJson();

      expect(json, {
        'metadata': {r'$exists': false},
      });
    });
  });

  group('Evaluation', () {
    group('Query', () {
      test('should create query filter correctly', () {
        final field = TestFilterField.name;
        const query = 'search term';

        var filter = Filter.query(field, query);

        expect(filter, isA<QueryOperator<TestModel>>());
        filter = filter as QueryOperator<TestModel>;
        expect(filter.field, field);
        expect(filter.query, query);
        expect(filter.operator, FilterOperator.query);
      });

      test('should serialize to JSON correctly', () {
        final field = TestFilterField.name;
        const query = 'search term';

        final filter = Filter.query(field, query);
        final json = filter.toJson();

        expect(json, {
          'name': {r'$q': 'search term'},
        });
      });
    });

    group('AutoComplete', () {
      test('should create autocomplete filter correctly', () {
        final field = TestFilterField.name;
        const query = 'prefix';

        var filter = Filter.autoComplete(field, query);

        expect(filter, isA<AutoCompleteOperator<TestModel>>());
        filter = filter as AutoCompleteOperator<TestModel>;
        expect(filter.field, field);
        expect(filter.query, query);
        expect(filter.operator, FilterOperator.autoComplete);
      });

      test('should serialize to JSON correctly', () {
        final field = TestFilterField.name;
        const query = 'prefix';

        final filter = Filter.autoComplete(field, query);
        final json = filter.toJson();

        expect(json, {
          'name': {r'$autocomplete': 'prefix'},
        });
      });
    });
  });

  group('PathExists', () {
    test('should create path exists filter correctly', () {
      final field = TestFilterField.metadata;
      const path = 'nested.field';

      var filter = Filter.pathExists(field, path);

      expect(filter, isA<PathExistsOperator<TestModel>>());
      filter = filter as PathExistsOperator<TestModel>;
      expect(filter.field, field);
      expect(filter.path, path);
      expect(filter.operator, FilterOperator.pathExists);
    });

    test('should serialize to JSON correctly', () {
      final field = TestFilterField.metadata;
      const path = 'nested.field';

      final filter = Filter.pathExists(field, path);
      final json = filter.toJson();

      expect(json, {
        'metadata': {r'$path_exists': 'nested.field'},
      });
    });
  });

  group('Logical', () {
    group('And', () {
      test('should create and filter correctly', () {
        final filter1 = Filter.equal(TestFilterField.name, 'test');
        final filter2 = Filter.greater(TestFilterField.id, 100);
        final filters = [filter1, filter2];

        var andFilter = Filter.and(filters);

        expect(andFilter, isA<AndOperator<TestModel>>());
        andFilter = andFilter as AndOperator<TestModel>;
        expect(andFilter.filters, filters);
        expect(andFilter.operator, FilterOperator.and);
      });

      test('should serialize to JSON correctly', () {
        final filter1 = Filter.equal(TestFilterField.name, 'test');
        final filter2 = Filter.greater(TestFilterField.id, 100);
        final filters = [filter1, filter2];

        final andFilter = Filter.and(filters);
        final json = andFilter.toJson();

        expect(json, {
          r'$and': [
            {
              'name': {r'$eq': 'test'},
            },
            {
              'id': {r'$gt': 100},
            },
          ],
        });
      });

      test('should handle nested logical filters', () {
        final filter1 = Filter.equal(TestFilterField.name, 'test');
        final filter2 = Filter.greater(TestFilterField.id, 100);
        final orFilter = Filter.or([filter1, filter2]);

        final filter3 = Filter.equal(TestFilterField.type, 'messaging');
        final andFilter = Filter.and([orFilter, filter3]);

        final json = andFilter.toJson();

        expect(json, {
          r'$and': [
            {
              r'$or': [
                {
                  'name': {r'$eq': 'test'},
                },
                {
                  'id': {r'$gt': 100},
                },
              ],
            },
            {
              'type': {r'$eq': 'messaging'},
            },
          ],
        });
      });
    });

    group('Or', () {
      test('should create or filter correctly', () {
        final filter1 = Filter.equal(TestFilterField.name, 'test');
        final filter2 = Filter.greater(TestFilterField.id, 100);
        final filters = [filter1, filter2];

        var orFilter = Filter.or(filters);

        expect(orFilter, isA<OrOperator<TestModel>>());
        orFilter = orFilter as OrOperator<TestModel>;
        expect(orFilter.filters, filters);
        expect(orFilter.operator, FilterOperator.or);
      });

      test('should serialize to JSON correctly', () {
        final filter1 = Filter.equal(TestFilterField.name, 'test');
        final filter2 = Filter.greater(TestFilterField.id, 100);
        final filters = [filter1, filter2];

        final orFilter = Filter.or(filters);
        final json = orFilter.toJson();

        expect(json, {
          r'$or': [
            {
              'name': {r'$eq': 'test'},
            },
            {
              'id': {r'$gt': 100},
            },
          ],
        });
      });
    });
  });

  group('JSON Encoding', () {
    test('should encode filters correctly using json.encode', () {
      final filter = Filter.equal(TestFilterField.name, 'test');
      final encoded = json.encode(filter);

      expect(encoded, r'{"name":{"$eq":"test"}}');
    });

    test('should encode complex nested filters correctly', () {
      final filter1 = Filter.equal(TestFilterField.type, 'messaging');
      final filter2 = Filter.in_(
        TestFilterField.members,
        ['user1', 'user2'],
      );
      final filter3 = Filter.greater(
        TestFilterField.createdAt,
        '2023-01-01',
      );

      final complexFilter = Filter.and(
        [
          Filter.or([filter1, filter2]),
          filter3,
        ],
      );

      final encoded = json.encode(complexFilter);
      final decoded = json.decode(encoded);

      expect(decoded, {
        r'$and': [
          {
            r'$or': [
              {
                'type': {r'$eq': 'messaging'},
              },
              {
                'members': {
                  r'$in': ['user1', 'user2'],
                },
              },
            ],
          },
          {
            'created_at': {r'$gt': '2023-01-01'},
          },
        ],
      });
    });
  });

  group('Edge Cases', () {
    test('should handle null values in filters', () {
      final filter = Filter.equal(TestFilterField.metadata, null);
      final json = filter.toJson();

      expect(json, {
        'metadata': {r'$eq': null},
      });
    });

    test('should handle empty list in In', () {
      final filter = Filter.in_(TestFilterField.tags, <String>[]);
      final json = filter.toJson();

      expect(json, {
        'tags': {r'$in': <String>[]},
      });
    });

    test('should handle single item list in In', () {
      final filter = Filter.in_(TestFilterField.tags, ['single']);
      final json = filter.toJson();

      expect(json, {
        'tags': {
          r'$in': ['single'],
        },
      });
    });

    test('should handle empty filters list in Logical', () {
      const andFilter = Filter.and(<Filter<TestFilterField>>[]);
      final json = andFilter.toJson();

      expect(json, {r'$and': <Map<String, Object?>>[]});
    });
  });

  group('Type Safety', () {
    test('should enforce FilterField type consistency', () {
      // This test ensures that the generic type system works correctly
      final filter1 = Filter.equal(TestFilterField.name, 'test');
      final filter2 = Filter.greater(TestFilterField.id, 100);

      var logicalFilter = Filter.and([filter1, filter2]);

      expect(logicalFilter, isA<AndOperator<TestModel>>());
      logicalFilter = logicalFilter as AndOperator<TestModel>;
      expect(logicalFilter.filters.length, 2);
      expect(logicalFilter.filters.elementAt(0), filter1);
      expect(logicalFilter.filters.elementAt(1), filter2);
    });
  });

  group('Real-world Usage Examples', () {
    test('should create a complex chat channel filter', () {
      // Example: Find messaging channels where user is a member, created after a date, and has specific metadata
      const userId = 'user123';
      const createdAfter = '2023-01-01T00:00:00Z';

      final filter = Filter.and(
        [
          Filter.equal(TestFilterField.type, 'messaging'),
          Filter.contains(TestFilterField.members, userId),
          Filter.greater(
            TestFilterField.createdAt,
            createdAfter,
          ),
          Filter.exists(TestFilterField.metadata, exists: true),
        ],
      );

      final json = filter.toJson();

      expect(json, {
        r'$and': [
          {
            'type': {r'$eq': 'messaging'},
          },
          {
            'members': {r'$contains': 'user123'},
          },
          {
            'created_at': {r'$gt': '2023-01-01T00:00:00Z'},
          },
          {
            'metadata': {r'$exists': true},
          },
        ],
      });
    });

    test('should create a search filter with autocomplete', () {
      const searchQuery = 'john';

      final filter = Filter.or(
        [
          Filter.query(TestFilterField.name, searchQuery),
          Filter.autoComplete(
            TestFilterField.name,
            searchQuery,
          ),
        ],
      );

      final json = filter.toJson();

      expect(json, {
        r'$or': [
          {
            'name': {r'$q': 'john'},
          },
          {
            'name': {r'$autocomplete': 'john'},
          },
        ],
      });
    });

    test('should create a range filter', () {
      const minId = 100;
      const maxId = 200;

      final filter = Filter.and(
        [
          Filter.greaterOrEqual(TestFilterField.id, minId),
          Filter.lessOrEqual(TestFilterField.id, maxId),
        ],
      );

      final json = filter.toJson();

      expect(json, {
        r'$and': [
          {
            'id': {r'$gte': 100},
          },
          {
            'id': {r'$lte': 200},
          },
        ],
      });
    });
  });

  group('Filter.matches()', () {
    group('Equal', () {
      test('should match primitive values', () {
        final model = TestModel(name: 'John', id: '123');

        expect(
          Filter.equal(TestFilterField.name, 'John').matches(model),
          isTrue,
        );
        expect(Filter.equal(TestFilterField.id, '123').matches(model), isTrue);
        expect(
          Filter.equal(TestFilterField.name, 'Jane').matches(model),
          isFalse,
        );
      });

      test('should not match null values (PostgreSQL semantics)', () {
        final modelWithNull = TestModel(name: null);
        final modelWithValue = TestModel(name: 'John');

        // NULL = NULL → false (PostgreSQL three-valued logic)
        expect(
          Filter.equal(TestFilterField.name, null).matches(modelWithNull),
          isFalse,
        );
        // NULL = 'John' → false
        expect(
          Filter.equal(TestFilterField.name, 'John').matches(modelWithNull),
          isFalse,
        );
        // 'John' = NULL → false
        expect(
          Filter.equal(TestFilterField.name, null).matches(modelWithValue),
          isFalse,
        );
      });

      test('should match arrays with order-sensitivity', () {
        final model = TestModel(tags: ['a', 'b', 'c']);

        expect(
          Filter.equal(TestFilterField.tags, ['a', 'b', 'c']).matches(model),
          isTrue,
        );
        expect(
          Filter.equal(TestFilterField.tags, ['c', 'b', 'a']).matches(model),
          isFalse,
        );
        expect(
          Filter.equal(TestFilterField.tags, ['a', 'b']).matches(model),
          isFalse,
        );
      });

      test('should match objects with key order-insensitivity', () {
        final model = TestModel(metadata: {'a': 1, 'b': 2});

        expect(
          Filter.equal(TestFilterField.metadata, {'b': 2, 'a': 1}).matches(model),
          isTrue,
        );
      });

      test('should respect order rules in nested structures', () {
        final model = TestModel(
          metadata: {
            'user': {'name': 'John', 'age': 30},
            'tags': ['a', 'b'],
          },
        );

        // Object key order doesn't matter, but array order does
        final match = Filter.equal(TestFilterField.metadata, {
          'tags': ['a', 'b'], // Same order - OK
          'user': {'age': 30, 'name': 'John'}, // Different key order - OK
        });

        expect(match.matches(model), isTrue);

        // Array with different order should NOT match
        final noMatch = Filter.equal(TestFilterField.metadata, {
          'tags': ['b', 'a'], // Different order - NOT OK
          'user': {'age': 30, 'name': 'John'},
        });

        expect(noMatch.matches(model), isFalse);
      });

      test('should be case-sensitive for strings', () {
        final model = TestModel(name: 'John');

        expect(
          Filter.equal(TestFilterField.name, 'John').matches(model),
          isTrue,
        );
        expect(
          Filter.equal(TestFilterField.name, 'john').matches(model),
          isFalse,
        );
        expect(
          Filter.equal(TestFilterField.name, 'JOHN').matches(model),
          isFalse,
        );
      });

      test('should handle diacritics in strings', () {
        final modelWithDiacritic = TestModel(name: 'José');
        final modelWithoutDiacritic = TestModel(name: 'Jose');

        expect(
          Filter.equal(TestFilterField.name, 'José').matches(modelWithDiacritic),
          isTrue,
        );
        expect(
          Filter.equal(TestFilterField.name, 'José').matches(modelWithoutDiacritic),
          isFalse,
        );
        expect(
          Filter.equal(TestFilterField.name, 'Jose').matches(modelWithDiacritic),
          isFalse,
        );
        expect(
          Filter.equal(TestFilterField.name, 'jose').matches(modelWithDiacritic),
          isFalse,
        );
      });
    });

    group('In', () {
      test('should match primitives in list', () {
        final model = TestModel(name: 'John');

        expect(
          Filter.in_(TestFilterField.name, ['John', 'Jane']).matches(model),
          isTrue,
        );
        expect(
          Filter.in_(TestFilterField.name, ['Alice', 'Bob']).matches(model),
          isFalse,
        );
      });

      test('should return false for empty list', () {
        final model = TestModel(name: 'John');

        expect(Filter.in_(TestFilterField.name, []).matches(model), isFalse);
      });

      test('should match arrays with order-sensitivity', () {
        final model = TestModel(tags: ['a', 'b', 'c']);

        expect(
          Filter.in_(TestFilterField.tags, [
            ['a', 'b', 'c'],
            ['x', 'y'],
          ]).matches(model),
          isTrue,
        );
        expect(
          Filter.in_(TestFilterField.tags, [
            ['c', 'b', 'a'],
            ['x', 'y'],
          ]).matches(model),
          isFalse,
        );
      });

      test('should match objects with key order-insensitivity', () {
        final model = TestModel(metadata: {'a': 1, 'b': 2});

        expect(
          Filter.in_(TestFilterField.metadata, [
            {'b': 2, 'a': 1},
            {'c': 3},
          ]).matches(model),
          isTrue,
        );
      });

      test('should be case-sensitive for strings', () {
        final model = TestModel(name: 'John');

        expect(
          Filter.in_(TestFilterField.name, ['John', 'Jane', 'Bob']).matches(model),
          isTrue,
        );
        expect(
          Filter.in_(TestFilterField.name, ['john', 'Jane', 'Bob']).matches(model),
          isFalse,
        );
        expect(
          Filter.in_(TestFilterField.name, ['JOHN', 'Jane', 'Bob']).matches(model),
          isFalse,
        );
      });

      test('should handle diacritics in strings', () {
        final modelWithDiacritic = TestModel(name: 'José');
        final modelWithoutDiacritic = TestModel(name: 'Jose');

        expect(
          Filter.in_(TestFilterField.name, [
            'José',
            'François',
            'Müller',
          ]).matches(modelWithDiacritic),
          isTrue,
        );
        expect(
          Filter.in_(TestFilterField.name, [
            'José',
            'François',
            'Müller',
          ]).matches(modelWithoutDiacritic),
          isFalse,
        );
        expect(
          Filter.in_(TestFilterField.name, ['Jose', 'Francois']).matches(modelWithDiacritic),
          isFalse,
        );
        expect(
          Filter.in_(TestFilterField.name, ['jose', 'françois']).matches(modelWithDiacritic),
          isFalse,
        );
      });
    });

    group('Contains', () {
      test('should match JSON subset', () {
        final model = TestModel(metadata: {'a': 1, 'b': 2, 'c': 3});

        expect(
          Filter.contains(TestFilterField.metadata, {'a': 1, 'b': 2}).matches(model),
          isTrue,
        );
        expect(
          Filter.contains(TestFilterField.metadata, {'d': 4}).matches(model),
          isFalse,
        );
      });

      test('should distinguish null value vs missing key', () {
        final modelWithNull = TestModel(metadata: {'status': null});
        final modelWithoutKey = TestModel(metadata: {'name': 'John'});

        final filter = Filter.contains(TestFilterField.metadata, {'status': null});

        expect(filter.matches(modelWithNull), isTrue);
        expect(filter.matches(modelWithoutKey), isFalse);
      });

      test('should match nested structures with order-independence', () {
        final model = TestModel(
          projects: [
            {'name': 'Project A', 'status': 'active'},
            {'name': 'Project B', 'status': 'done'},
          ],
        );

        final filter = Filter.contains(TestFilterField.projects, [
          {'status': 'done', 'name': 'Project B'}, // Different key order
        ]);

        expect(filter.matches(model), isTrue);
      });

      test('should match nested maps with all key-value pairs', () {
        final filter = Filter.contains(
          TestFilterField.metadata,
          {
            'category': 'test',
            'config': {'enabled': true},
          },
        );

        final itemWithMatchingNestedData = TestModel(
          metadata: {
            'category': 'test',
            'priority': 1,
            'config': {'enabled': true, 'timeout': 30},
          },
        );
        final itemWithDifferentNestedValue = TestModel(
          metadata: {
            'category': 'test',
            'config': {'enabled': false, 'timeout': 30},
          },
        );
        final itemWithoutNestedMap = TestModel(
          metadata: {'category': 'test', 'priority': 1},
        );

        expect(filter.matches(itemWithMatchingNestedData), isTrue);
        expect(filter.matches(itemWithDifferentNestedValue), isFalse);
        expect(filter.matches(itemWithoutNestedMap), isFalse);
      });

      test('should match array subset (order-independent)', () {
        final model = TestModel(tags: ['a', 'b', 'c', 'd']);

        expect(
          Filter.contains(TestFilterField.tags, ['c', 'a']).matches(model),
          isTrue,
        );
        expect(
          Filter.contains(TestFilterField.tags, ['a', 'x']).matches(model),
          isFalse,
        );
      });

      test(
        'should treat duplicate elements in filter as single occurrence',
        () {
          final model = TestModel(tags: ['a', 'b', 'c']);

          // Filter with duplicates should match (duplicates ignored)
          expect(
            Filter.contains(TestFilterField.tags, ['a', 'a', 'a']).matches(model),
            isTrue, // Should be TRUE, not FALSE
          );

          expect(
            Filter.contains(TestFilterField.tags, ['a', 'b', 'a']).matches(model),
            isTrue,
          );
        },
      );

      test('should match single item in array', () {
        final model = TestModel(tags: ['a', 'b', 'c']);

        expect(
          Filter.contains(TestFilterField.tags, 'b').matches(model),
          isTrue,
        );
        expect(
          Filter.contains(TestFilterField.tags, 'x').matches(model),
          isFalse,
        );
      });

      test('should match empty list', () {
        final model = TestModel(tags: ['a', 'b']);

        expect(
          Filter.contains(TestFilterField.tags, []).matches(model),
          isTrue,
        );
      });

      test('should return false for null field', () {
        final model = TestModel(tags: null);

        expect(
          Filter.contains(TestFilterField.tags, 'a').matches(model),
          isFalse,
        );
      });

      test('should return false for non-iterable/non-json field', () {
        final model = TestModel(name: 'John');

        expect(
          Filter.contains(TestFilterField.name, 'J').matches(model),
          isFalse,
        );
      });
    });

    group('Comparison Operators', () {
      test('Greater should match when field value is greater', () {
        final model = TestModel(createdAt: DateTime(2023, 6, 15));

        expect(
          Filter.greater(TestFilterField.createdAt, DateTime(2023, 1, 1)).matches(model),
          isTrue,
        );
        expect(
          Filter.greater(TestFilterField.createdAt, DateTime(2023, 6, 15)).matches(model),
          isFalse,
        );
        expect(
          Filter.greater(TestFilterField.createdAt, DateTime(2024, 1, 1)).matches(model),
          isFalse,
        );
      });

      test('Greater should use lexicographic comparison for strings', () {
        // Lexicographic: uppercase < lowercase
        expect(
          Filter.greater(TestFilterField.name, 'John').matches(TestModel(name: 'Johnny')),
          isTrue,
        );
        expect(
          Filter.greater(TestFilterField.name, 'John').matches(TestModel(name: 'Mike')),
          isTrue,
        );
        expect(
          Filter.greater(TestFilterField.name, 'John').matches(TestModel(name: 'john')),
          isTrue,
        );
        expect(
          Filter.greater(TestFilterField.name, 'John').matches(TestModel(name: 'John')),
          isFalse,
        );
        expect(
          Filter.greater(TestFilterField.name, 'John').matches(TestModel(name: 'JOHN')),
          isFalse,
        );
        expect(
          Filter.greater(TestFilterField.name, 'John').matches(TestModel(name: 'Alice')),
          isFalse,
        );
      });

      test('Greater should handle diacritics lexicographically', () {
        expect(
          Filter.greater(TestFilterField.name, 'José').matches(TestModel(name: 'Joséa')),
          isTrue,
        );
        expect(
          Filter.greater(TestFilterField.name, 'José').matches(TestModel(name: 'joséa')),
          isTrue,
        );
        expect(
          Filter.greater(TestFilterField.name, 'José').matches(TestModel(name: 'José')),
          isFalse,
        );
        expect(
          Filter.greater(TestFilterField.name, 'José').matches(TestModel(name: 'Jose')),
          isFalse,
        );
        expect(
          Filter.greater(TestFilterField.name, 'José').matches(TestModel(name: 'jose')),
          isTrue,
        );
      });

      test('GreaterOrEqual should match when field value is greater or equal', () {
        final model = TestModel(id: '50');

        expect(
          Filter.greaterOrEqual(TestFilterField.id, '30').matches(model),
          isTrue,
        );
        expect(
          Filter.greaterOrEqual(TestFilterField.id, '50').matches(model),
          isTrue,
        );
        expect(
          Filter.greaterOrEqual(TestFilterField.id, '70').matches(model),
          isFalse,
        );
      });

      test('GreaterOrEqual should use lexicographic comparison for strings', () {
        expect(
          Filter.greaterOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'Johnny')),
          isTrue,
        );
        expect(
          Filter.greaterOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'Mike')),
          isTrue,
        );
        expect(
          Filter.greaterOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'john')),
          isTrue,
        );
        expect(
          Filter.greaterOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'John')),
          isTrue,
        );
        expect(
          Filter.greaterOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'JOHN')),
          isFalse,
        );
        expect(
          Filter.greaterOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'Alice')),
          isFalse,
        );
      });

      test('Less should match when field value is less', () {
        final model = TestModel(createdAt: DateTime(2023, 6, 15));

        expect(
          Filter.less(TestFilterField.createdAt, DateTime(2024, 1, 1)).matches(model),
          isTrue,
        );
        expect(
          Filter.less(TestFilterField.createdAt, DateTime(2023, 6, 15)).matches(model),
          isFalse,
        );
        expect(
          Filter.less(TestFilterField.createdAt, DateTime(2023, 1, 1)).matches(model),
          isFalse,
        );
      });

      test('Less should use lexicographic comparison for strings', () {
        expect(
          Filter.less(TestFilterField.name, 'John').matches(TestModel(name: 'Johnny')),
          isFalse,
        );
        expect(
          Filter.less(TestFilterField.name, 'John').matches(TestModel(name: 'Mike')),
          isFalse,
        );
        expect(
          Filter.less(TestFilterField.name, 'John').matches(TestModel(name: 'john')),
          isFalse,
        );
        expect(
          Filter.less(TestFilterField.name, 'John').matches(TestModel(name: 'John')),
          isFalse,
        );
        expect(
          Filter.less(TestFilterField.name, 'John').matches(TestModel(name: 'JOHN')),
          isTrue,
        );
        expect(
          Filter.less(TestFilterField.name, 'John').matches(TestModel(name: 'Alice')),
          isTrue,
        );
      });

      test('LessOrEqual should match when field value is less or equal', () {
        final model = TestModel(id: '50');

        expect(
          Filter.lessOrEqual(TestFilterField.id, '70').matches(model),
          isTrue,
        );
        expect(
          Filter.lessOrEqual(TestFilterField.id, '50').matches(model),
          isTrue,
        );
        expect(
          Filter.lessOrEqual(TestFilterField.id, '30').matches(model),
          isFalse,
        );
      });

      test('LessOrEqual should use lexicographic comparison for strings', () {
        expect(
          Filter.lessOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'Johnny')),
          isFalse,
        );
        expect(
          Filter.lessOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'Mike')),
          isFalse,
        );
        expect(
          Filter.lessOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'john')),
          isFalse,
        );
        expect(
          Filter.lessOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'John')),
          isTrue,
        );
        expect(
          Filter.lessOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'JOHN')),
          isTrue,
        );
        expect(
          Filter.lessOrEqual(TestFilterField.name, 'John').matches(TestModel(name: 'Alice')),
          isTrue,
        );
      });

      test('should return false for incomparable types', () {
        final model = TestModel(name: 'John');

        expect(
          Filter.greater(TestFilterField.name, 100).matches(model),
          isFalse,
        );
        expect(
          Filter.greaterOrEqual(TestFilterField.name, 100).matches(model),
          isFalse,
        );
        expect(
          Filter.less(TestFilterField.name, 100).matches(model),
          isFalse,
        );
        expect(
          Filter.lessOrEqual(TestFilterField.name, 100).matches(model),
          isFalse,
        );
      });

      test('should return false for NULL comparisons (PostgreSQL semantics)', () {
        final modelWithNull = TestModel(id: null);
        final modelWithValue = TestModel(id: '50');

        // Greater: NULL > value → false
        expect(
          Filter.greater(TestFilterField.id, '30').matches(modelWithNull),
          isFalse,
        );
        // Greater: value > NULL → false
        expect(
          Filter.greater(TestFilterField.id, null).matches(modelWithValue),
          isFalse,
        );
        // Greater: NULL > NULL → false
        expect(
          Filter.greater(TestFilterField.id, null).matches(modelWithNull),
          isFalse,
        );

        // GreaterOrEqual: NULL >= value → false
        expect(
          Filter.greaterOrEqual(TestFilterField.id, '30').matches(modelWithNull),
          isFalse,
        );
        // GreaterOrEqual: value >= NULL → false
        expect(
          Filter.greaterOrEqual(TestFilterField.id, null).matches(modelWithValue),
          isFalse,
        );
        // GreaterOrEqual: NULL >= NULL → false
        expect(
          Filter.greaterOrEqual(TestFilterField.id, null).matches(modelWithNull),
          isFalse,
        );

        // Less: NULL < value → false
        expect(
          Filter.less(TestFilterField.id, '70').matches(modelWithNull),
          isFalse,
        );
        // Less: value < NULL → false
        expect(
          Filter.less(TestFilterField.id, null).matches(modelWithValue),
          isFalse,
        );
        // Less: NULL < NULL → false
        expect(
          Filter.less(TestFilterField.id, null).matches(modelWithNull),
          isFalse,
        );

        // LessOrEqual: NULL <= value → false
        expect(
          Filter.lessOrEqual(TestFilterField.id, '70').matches(modelWithNull),
          isFalse,
        );
        // LessOrEqual: value <= NULL → false
        expect(
          Filter.lessOrEqual(TestFilterField.id, null).matches(modelWithValue),
          isFalse,
        );
        // LessOrEqual: NULL <= NULL → false
        expect(
          Filter.lessOrEqual(TestFilterField.id, null).matches(modelWithNull),
          isFalse,
        );
      });
    });

    group('Exists', () {
      test('should match when exists = true and field is non-null', () {
        final model = TestModel(name: 'John');

        expect(
          Filter.exists(TestFilterField.name, exists: true).matches(model),
          isTrue,
        );
      });

      test('should not match when exists = true and field is null', () {
        final model = TestModel(name: null);

        expect(
          Filter.exists(TestFilterField.name, exists: true).matches(model),
          isFalse,
        );
      });

      test('should match when exists = false and field is null', () {
        final model = TestModel(name: null);

        expect(
          Filter.exists(TestFilterField.name, exists: false).matches(model),
          isTrue,
        );
      });

      test('should not match when exists = false and field is non-null', () {
        final model = TestModel(name: 'John');

        expect(
          Filter.exists(TestFilterField.name, exists: false).matches(model),
          isFalse,
        );
      });
    });

    group('Query', () {
      test('should match case-insensitive substring', () {
        final model = TestModel(name: 'John Doe');

        expect(
          Filter.query(TestFilterField.name, 'john').matches(model),
          isTrue,
        );
        expect(
          Filter.query(TestFilterField.name, 'doe').matches(model),
          isTrue,
        );
        expect(
          Filter.query(TestFilterField.name, 'JOHN').matches(model),
          isTrue,
        );
        expect(
          Filter.query(TestFilterField.name, 'jane').matches(model),
          isFalse,
        );
      });

      test('should not match empty query', () {
        final modelWithContent = TestModel(name: 'any content');
        final modelWithEmptyName = TestModel(name: '');

        expect(
          Filter.query(TestFilterField.name, '').matches(modelWithContent),
          isFalse,
        );
        expect(
          Filter.query(TestFilterField.name, '').matches(modelWithEmptyName),
          isFalse,
        );
      });

      test('should match partial words and case variations', () {
        final filter = Filter.query(TestFilterField.name, 'PROD');

        final itemWithLowercase = TestModel(name: 'production server');
        final itemWithMixedCase = TestModel(name: 'Development Production Environment');
        final itemWithPartialMatch = TestModel(name: 'reproduced issue');
        final itemWithoutMatch = TestModel(name: 'staging server');

        expect(filter.matches(itemWithLowercase), isTrue);
        expect(filter.matches(itemWithMixedCase), isTrue);
        expect(filter.matches(itemWithPartialMatch), isTrue);
        expect(filter.matches(itemWithoutMatch), isFalse);
      });

      test('should return false for non-string fields', () {
        final model = TestModel(createdAt: DateTime(2023));

        expect(
          Filter.query(TestFilterField.createdAt, 'test').matches(model),
          isFalse,
        );
      });

      test('should handle diacritics case-insensitively', () {
        expect(
          Filter.query(TestFilterField.name, 'josé').matches(TestModel(name: 'José')),
          isTrue,
        );
        expect(
          Filter.query(TestFilterField.name, 'josé').matches(TestModel(name: 'JOSÉ')),
          isTrue,
        );
        expect(
          Filter.query(TestFilterField.name, 'josé').matches(TestModel(name: 'josé')),
          isTrue,
        );
        expect(
          Filter.query(TestFilterField.name, 'josé').matches(TestModel(name: 'Jose')),
          isFalse,
        );
        expect(
          Filter.query(TestFilterField.name, 'josé').matches(TestModel(name: 'jose')),
          isFalse,
        );
      });

      test('should match middle and end substrings', () {
        expect(
          Filter.query(TestFilterField.name, 'hn').matches(TestModel(name: 'John')),
          isTrue,
        );
        expect(
          Filter.query(TestFilterField.name, 'hn').matches(TestModel(name: 'JOHN')),
          isTrue,
        );
        expect(
          Filter.query(TestFilterField.name, 'hn').matches(TestModel(name: 'Jane')),
          isFalse,
        );
      });
    });

    group('AutoComplete', () {
      test('should match word prefix (case-insensitive)', () {
        final model = TestModel(name: 'John Doe Smith');

        expect(
          Filter.autoComplete(TestFilterField.name, 'jo').matches(model),
          isTrue,
        );
        expect(
          Filter.autoComplete(TestFilterField.name, 'do').matches(model),
          isTrue,
        );
        expect(
          Filter.autoComplete(TestFilterField.name, 'JO').matches(model),
          isTrue,
        );
      });

      test('should not match empty query', () {
        final modelWithContent = TestModel(name: 'any content');
        final modelWithEmptyName = TestModel(name: '');

        expect(
          Filter.autoComplete(TestFilterField.name, '').matches(modelWithContent),
          isFalse,
        );
        expect(
          Filter.autoComplete(TestFilterField.name, '').matches(modelWithEmptyName),
          isFalse,
        );
      });

      test('should match word prefixes with punctuation boundaries', () {
        final filter = Filter.autoComplete(TestFilterField.name, 'con');

        final itemWithDotSeparation = TestModel(name: 'app.config.json');
        final itemWithDashSeparation = TestModel(name: 'user-configuration-file');
        final itemWithMixedPunctuation = TestModel(name: 'system/container,settings.xml');
        final itemWithoutWordPrefix = TestModel(name: 'application');
        final itemWithInWordMatch = TestModel(name: 'reconstruction');

        expect(filter.matches(itemWithDotSeparation), isTrue);
        expect(filter.matches(itemWithDashSeparation), isTrue);
        expect(filter.matches(itemWithMixedPunctuation), isTrue);
        expect(filter.matches(itemWithoutWordPrefix), isFalse);
        expect(filter.matches(itemWithInWordMatch), isFalse);
      });

      test('should not match middle of word', () {
        final model = TestModel(name: 'John Doe');

        expect(
          Filter.autoComplete(TestFilterField.name, 'oh').matches(model),
          isFalse,
        );
      });

      test('should handle diacritics case-insensitively', () {
        expect(
          Filter.autoComplete(TestFilterField.name, 'jos').matches(TestModel(name: 'José')),
          isTrue,
        );
        expect(
          Filter.autoComplete(TestFilterField.name, 'jos').matches(TestModel(name: 'JOSÉ')),
          isTrue,
        );
        expect(
          Filter.autoComplete(TestFilterField.name, 'jos').matches(TestModel(name: 'josé')),
          isTrue,
        );
      });

      test('should match word boundaries in multi-word text', () {
        expect(
          Filter.autoComplete(TestFilterField.name, 'john').matches(TestModel(name: 'John Smith')),
          isTrue,
        );
        expect(
          Filter.autoComplete(TestFilterField.name, 'john').matches(TestModel(name: 'JOHN DOE')),
          isTrue,
        );
        expect(
          Filter.autoComplete(TestFilterField.name, 'john').matches(TestModel(name: 'Smith John')),
          isTrue,
        );
        expect(
          Filter.autoComplete(TestFilterField.name, 'smi').matches(TestModel(name: 'John Smith')),
          isTrue,
        );
        expect(
          Filter.autoComplete(TestFilterField.name, 'smi').matches(TestModel(name: 'Johnson')),
          isFalse,
        );
      });

      test('should handle punctuation as word boundaries', () {
        expect(
          Filter.autoComplete(TestFilterField.name, 'john').matches(TestModel(name: 'john-doe')),
          isTrue,
        );
        expect(
          Filter.autoComplete(TestFilterField.name, 'john').matches(TestModel(name: 'john.doe')),
          isTrue,
        );
        expect(
          Filter.autoComplete(TestFilterField.name, 'john').matches(TestModel(name: 'Johnson')),
          isTrue,
        );
      });

      test('should not match when query is longer than word', () {
        expect(
          Filter.autoComplete(TestFilterField.name, 'johnathan').matches(TestModel(name: 'John')),
          isFalse,
        );
      });

      test('should return false for non-string fields', () {
        expect(
          Filter.autoComplete(
            TestFilterField.metadata,
            'test',
          ).matches(TestModel(metadata: {'key': 'value'})),
          isFalse,
        );
      });

      test('should return false for fields with only punctuation', () {
        expect(
          Filter.autoComplete(TestFilterField.name, 'test').matches(TestModel(name: '...')),
          isFalse,
        );
      });
    });

    group('PathExists', () {
      test('should match nested paths', () {
        final model = TestModel(
          metadata: {
            'user': {
              'profile': {'name': 'John'},
            },
          },
        );

        expect(
          Filter.pathExists(TestFilterField.metadata, 'user.profile.name').matches(model),
          isTrue,
        );
        expect(
          Filter.pathExists(TestFilterField.metadata, 'user.profile.age').matches(model),
          isFalse,
        );
      });

      test('should match shallow paths', () {
        final model = TestModel(metadata: {'user': 'John'});

        expect(
          Filter.pathExists(TestFilterField.metadata, 'user').matches(model),
          isTrue,
        );
        expect(
          Filter.pathExists(TestFilterField.metadata, 'age').matches(model),
          isFalse,
        );
      });

      test('should return false for empty path', () {
        final model = TestModel(metadata: {'user': 'John'});

        expect(
          Filter.pathExists(TestFilterField.metadata, '').matches(model),
          isFalse,
        );
      });

      test('should return false for null field', () {
        final model = TestModel(metadata: null);

        expect(
          Filter.pathExists(TestFilterField.metadata, 'user.name').matches(model),
          isFalse,
        );
      });

      test('should return false for non-map field', () {
        final model = TestModel(name: 'John');

        expect(
          Filter.pathExists(TestFilterField.name, 'subfield').matches(model),
          isFalse,
        );
      });

      test('should return false when path goes through non-map value', () {
        final model = TestModel(
          metadata: {
            'user': 'John', // String, not a map
          },
        );

        expect(
          Filter.pathExists(TestFilterField.metadata, 'user.name').matches(model),
          isFalse,
        );
      });

      test('should distinguish between null value and missing key', () {
        final modelWithNull = TestModel(metadata: {'user': null});
        final modelWithoutKey = TestModel(metadata: {'other': 'value'});

        // Path exists but value is null - should match (key exists)
        expect(
          Filter.pathExists(TestFilterField.metadata, 'user').matches(modelWithNull),
          isTrue,
        );

        // Path doesn't exist - should not match
        expect(
          Filter.pathExists(TestFilterField.metadata, 'user').matches(modelWithoutKey),
          isFalse,
        );
      });
    });

    group('Logical Operators', () {
      test('And should match when all filters match', () {
        final model = TestModel(name: 'John', type: 'public');
        final filter = Filter.and([
          Filter.equal(TestFilterField.name, 'John'),
          Filter.equal(TestFilterField.type, 'public'),
        ]);

        expect(filter.matches(model), isTrue);
      });

      test('And should not match when any filter fails', () {
        final model = TestModel(name: 'John', type: 'public');
        final filter = Filter.and([
          Filter.equal(TestFilterField.name, 'John'),
          Filter.equal(TestFilterField.type, 'private'),
        ]);

        expect(filter.matches(model), isFalse);
      });

      test('Or should match when any filter matches', () {
        final model = TestModel(type: 'public');
        final filter = Filter.or([
          Filter.equal(TestFilterField.type, 'public'),
          Filter.equal(TestFilterField.type, 'private'),
        ]);

        expect(filter.matches(model), isTrue);
      });

      test('Or should not match when all filters fail', () {
        final model = TestModel(type: 'archived');
        final filter = Filter.or([
          Filter.equal(TestFilterField.type, 'public'),
          Filter.equal(TestFilterField.type, 'private'),
        ]);

        expect(filter.matches(model), isFalse);
      });

      test('should handle complex nested combinations', () {
        final model = TestModel(
          name: 'John',
          type: 'public',
          createdAt: DateTime(2023, 6, 15),
        );
        final filter = Filter.and([
          Filter.or([
            Filter.equal(TestFilterField.name, 'John'),
            Filter.equal(TestFilterField.name, 'Jane'),
          ]),
          Filter.equal(TestFilterField.type, 'public'),
          Filter.greater(TestFilterField.createdAt, DateTime(2023, 1, 1)),
        ]);

        expect(filter.matches(model), isTrue);
      });
    });

    group('Type Mismatches', () {
      test('should return false for string vs number comparisons', () {
        final model = TestModel(name: 'John');

        expect(
          Filter.greater(TestFilterField.name, 25).matches(model),
          isFalse,
        );
        expect(
          Filter.less(TestFilterField.name, 25).matches(model),
          isFalse,
        );
      });
    });

    group('Edge Cases', () {
      test('should handle empty string values', () {
        final model = TestModel(name: '');

        expect(
          Filter.equal(TestFilterField.name, '').matches(model),
          isTrue,
        );
        expect(
          Filter.equal(TestFilterField.name, 'John').matches(model),
          isFalse,
        );
      });

      test('should handle null values in optional fields (PostgreSQL semantics)', () {
        final modelWithNull = TestModel(name: null);
        final modelWithValue = TestModel(name: 'John');

        // NULL = NULL → false (PostgreSQL three-valued logic)
        expect(
          Filter.equal(TestFilterField.name, null).matches(modelWithNull),
          isFalse,
        );
        // 'John' = NULL → false
        expect(
          Filter.equal(TestFilterField.name, null).matches(modelWithValue),
          isFalse,
        );
        // NULL = 'John' → false
        expect(
          Filter.equal(TestFilterField.name, 'John').matches(modelWithNull),
          isFalse,
        );
      });

      test('should handle empty arrays', () {
        final modelWithEmpty = TestModel(tags: []);
        final modelWithValues = TestModel(tags: ['a', 'b']);

        expect(
          Filter.equal(TestFilterField.tags, []).matches(modelWithEmpty),
          isTrue,
        );
        expect(
          Filter.equal(TestFilterField.tags, []).matches(modelWithValues),
          isFalse,
        );
        expect(
          Filter.contains(TestFilterField.tags, []).matches(modelWithValues),
          isTrue,
        );
      });

      test('should handle empty maps', () {
        final modelWithEmpty = TestModel(metadata: {});
        final modelWithValues = TestModel(metadata: {'a': 1});

        expect(
          Filter.equal(TestFilterField.metadata, {}).matches(modelWithEmpty),
          isTrue,
        );
        expect(
          Filter.equal(TestFilterField.metadata, {}).matches(modelWithValues),
          isFalse,
        );
        // Empty map `{}` is contained in any object
        expect(
          Filter.contains(TestFilterField.metadata, {}).matches(modelWithEmpty),
          isTrue,
        );
        expect(
          Filter.contains(TestFilterField.metadata, {}).matches(modelWithValues),
          isTrue,
        );
      });
    });

    group('Location Filtering', () {
      test('should match location within CircularRegion', () {
        const center = LocationCoordinate(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        const nearbyLocation = LocationCoordinate(
          latitude: 37.8149,
          longitude: -122.4594,
        );

        const farLocation = LocationCoordinate(
          latitude: 40.7128,
          longitude: -74.0060,
        );

        final region = CircularRegion(
          radius: 10.kilometers,
          center: center,
        );

        final filter = Filter.equal(TestFilterField.near, region);

        final modelNearby = TestModel(location: nearbyLocation);
        final modelFar = TestModel(location: farLocation);

        expect(filter.matches(modelNearby), isTrue);
        expect(filter.matches(modelFar), isFalse);
      });

      test('should match location within BoundingBox', () {
        const bbox = BoundingBox(
          northEast: LocationCoordinate(
            latitude: 37.8324,
            longitude: -122.3482,
          ),
          southWest: LocationCoordinate(
            latitude: 37.7079,
            longitude: -122.5161,
          ),
        );

        const insideLocation = LocationCoordinate(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        const outsideLocation = LocationCoordinate(
          latitude: 37.8044,
          longitude: -122.2712,
        );

        final filter = Filter.equal(TestFilterField.withinBounds, bbox);

        final modelInside = TestModel(location: insideLocation);
        final modelOutside = TestModel(location: outsideLocation);

        expect(filter.matches(modelInside), isTrue);
        expect(filter.matches(modelOutside), isFalse);
      });

      test('should support Map-based circular region format', () {
        const location = LocationCoordinate(
          latitude: 37.7849,
          longitude: -122.4294,
        );

        final regionMap = {
          'lat': 37.7749,
          'lng': -122.4194,
          'distance': 10.0,
        };

        final filter = Filter.equal(TestFilterField.near, regionMap);
        final model = TestModel(location: location);

        expect(filter.matches(model), isTrue);
      });

      test('should support Map-based bounding box format', () {
        const insideLocation = LocationCoordinate(
          latitude: 41.89,
          longitude: 12.49,
        );

        const outsideLocation = LocationCoordinate(
          latitude: 41.95,
          longitude: 12.49,
        );

        final bboxMap = {
          'ne_lat': 41.91,
          'ne_lng': 12.51,
          'sw_lat': 41.87,
          'sw_lng': 12.47,
        };

        final filter = Filter.equal(TestFilterField.withinBounds, bboxMap);

        final modelInside = TestModel(location: insideLocation);
        final modelOutside = TestModel(location: outsideLocation);

        expect(filter.matches(modelInside), isTrue);
        expect(filter.matches(modelOutside), isFalse);
      });

      test('should serialize CircularRegion filter to JSON', () {
        final region = CircularRegion(
          radius: 5.kilometers,
          center: const LocationCoordinate(latitude: 41.89, longitude: 12.49),
        );

        final filter = Filter.equal(TestFilterField.near, region);

        expect(filter.toJson(), {
          'near': {
            r'$eq': {
              'lat': 41.89,
              'lng': 12.49,
              'distance': 5.0,
            },
          },
        });
      });

      test('should serialize BoundingBox filter to JSON', () {
        const bbox = BoundingBox(
          northEast: LocationCoordinate(latitude: 41.91, longitude: 12.51),
          southWest: LocationCoordinate(latitude: 41.87, longitude: 12.47),
        );

        final filter = Filter.equal(TestFilterField.withinBounds, bbox);

        expect(filter.toJson(), {
          'within_bounds': {
            r'$eq': {
              'ne_lat': 41.91,
              'ne_lng': 12.51,
              'sw_lat': 41.87,
              'sw_lng': 12.47,
            },
          },
        });
      });

      test('should work with logical operators', () {
        const location = LocationCoordinate(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        final region = CircularRegion(
          radius: 10.kilometers,
          center: location,
        );

        final filter = Filter.and([
          Filter.equal(TestFilterField.name, 'Office'),
          Filter.equal(TestFilterField.near, region),
        ]);

        final model = TestModel(name: 'Office', location: location);

        expect(filter.matches(model), isTrue);
      });

      test('should not match when location field is null', () {
        final region = CircularRegion(
          radius: 10.kilometers,
          center: const LocationCoordinate(
            latitude: 37.7749,
            longitude: -122.4194,
          ),
        );

        const bbox = BoundingBox(
          northEast: LocationCoordinate(
            latitude: 37.8324,
            longitude: -122.3482,
          ),
          southWest: LocationCoordinate(
            latitude: 37.7079,
            longitude: -122.5161,
          ),
        );

        final filterNear = Filter.equal(TestFilterField.near, region);
        final filterBounds = Filter.equal(TestFilterField.withinBounds, bbox);

        final modelWithNull = TestModel(location: null);

        expect(filterNear.matches(modelWithNull), isFalse);
        expect(filterBounds.matches(modelWithNull), isFalse);
      });

      test('should not match with invalid Map format for CircularRegion', () {
        const location = LocationCoordinate(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        final model = TestModel(location: location);

        // Missing 'distance' field
        final invalidMap1 = {'lat': 37.7749, 'lng': -122.4194};
        final filter1 = Filter.equal(TestFilterField.near, invalidMap1);

        expect(filter1.matches(model), isFalse);

        // Missing 'lng' field
        final invalidMap2 = {'lat': 37.7749, 'distance': 10.0};
        final filter2 = Filter.equal(TestFilterField.near, invalidMap2);

        expect(filter2.matches(model), isFalse);
      });

      test('should not match with invalid Map format for BoundingBox', () {
        const location = LocationCoordinate(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        final model = TestModel(location: location);

        // Missing 'sw_lat' field
        final invalidMap1 = {
          'ne_lat': 37.8324,
          'ne_lng': -122.3482,
          'sw_lng': -122.5161,
        };

        final filter1 = Filter.equal(TestFilterField.withinBounds, invalidMap1);
        expect(filter1.matches(model), isFalse);

        // Missing 'ne_lng' field
        final invalidMap2 = {
          'ne_lat': 37.8324,
          'sw_lat': 37.7079,
          'sw_lng': -122.5161,
        };

        final filter2 = Filter.equal(TestFilterField.withinBounds, invalidMap2);
        expect(filter2.matches(model), isFalse);
      });

      test('should match location at exact radius boundary', () {
        const center = LocationCoordinate(latitude: 0, longitude: 0);
        const radiusMeters = 1000.0;
        final region = CircularRegion(
          radius: radiusMeters.meters,
          center: center,
        );

        // Point approximately 1km away at equator
        const pointAtBoundary = LocationCoordinate(
          latitude: 0,
          longitude: 0.00898, // ~1km at equator
        );

        final filter = Filter.equal(TestFilterField.near, region);
        final model = TestModel(location: pointAtBoundary);

        expect(filter.matches(model), isTrue);
      });

      test('should match location at exact bounding box boundary', () {
        const bbox = BoundingBox(
          northEast: LocationCoordinate(latitude: 38, longitude: -122),
          southWest: LocationCoordinate(latitude: 37, longitude: -123),
        );

        const neCorner = LocationCoordinate(latitude: 38, longitude: -122);
        const swCorner = LocationCoordinate(latitude: 37, longitude: -123);

        final filter = Filter.equal(TestFilterField.withinBounds, bbox);

        final modelNE = TestModel(location: neCorner);
        final modelSW = TestModel(location: swCorner);

        expect(filter.matches(modelNE), isTrue);
        expect(filter.matches(modelSW), isTrue);
      });
    });
  });
}
