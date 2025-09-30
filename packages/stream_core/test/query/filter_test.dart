import 'dart:convert';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

// Test implementation of FilterField for testing purposes
extension type const TestFilterField(String remote) implements FilterField {
  static const id = TestFilterField('id');
  static const name = TestFilterField('name');
  static const createdAt = TestFilterField('created_at');
  static const members = TestFilterField('members');
  static const type = TestFilterField('type');
  static const metadata = TestFilterField('metadata');
  static const tags = TestFilterField('tags');
}

void main() {
  group('Filter Implementation Tests', () {
    group('Factory Constructors', () {
      test('should create filters using Filter factory constructors', () {
        const field = TestFilterField.name;

        // Test all factory constructors
        const equalFilter = Filter.equal(field, 'test');
        const greaterFilter = Filter.greater(field, 100);
        const greaterOrEqualFilter = Filter.greaterOrEqual(field, 100);
        const lessFilter = Filter.less(field, 100);
        const lessOrEqualFilter = Filter.lessOrEqual(field, 100);
        const inFilter = Filter.in_(field, ['a', 'b']);
        const containsFilter = Filter.contains(field, 'test');
        const existsFilter = Filter.exists(field, exists: true);
        const queryFilter = Filter.query(field, 'search');
        const autoCompleteFilter = Filter.autoComplete(field, 'prefix');
        const pathExistsFilter = Filter.pathExists(field, 'nested.field');

        // Verify types and basic functionality
        expect(equalFilter, isA<EqualOperator<TestFilterField, Object?>>());
        expect(greaterFilter, isA<GreaterOperator<TestFilterField, Object?>>());
        expect(
          greaterOrEqualFilter,
          isA<GreaterOrEqualOperator<TestFilterField, Object?>>(),
        );
        expect(lessFilter, isA<LessOperator<TestFilterField, Object?>>());
        expect(
          lessOrEqualFilter,
          isA<LessOrEqualOperator<TestFilterField, Object?>>(),
        );
        expect(inFilter, isA<InOperator<TestFilterField, Object?>>());
        expect(
          containsFilter,
          isA<ContainsOperator<TestFilterField, Object?>>(),
        );
        expect(existsFilter, isA<ExistsOperator<TestFilterField>>());
        expect(queryFilter, isA<QueryOperator<TestFilterField>>());
        expect(
          autoCompleteFilter,
          isA<AutoCompleteOperator<TestFilterField>>(),
        );
        expect(pathExistsFilter, isA<PathExistsOperator<TestFilterField>>());
      });

      test('should create logical filters using factory constructors', () {
        const filter1 = Filter.equal(TestFilterField.name, 'test');
        const filter2 = Filter.greater(TestFilterField.id, 100);

        const andFilter = Filter.and([filter1, filter2]);
        const orFilter = Filter.or([filter1, filter2]);

        expect(andFilter, isA<AndOperator<TestFilterField>>());
        expect(orFilter, isA<OrOperator<TestFilterField>>());

        expect((andFilter as AndOperator<TestFilterField>).filters.length, 2);
        expect((orFilter as OrOperator<TestFilterField>).filters.length, 2);
      });

      test('should serialize factory-created filters correctly', () {
        const field = TestFilterField.name;

        const equalFilter = Filter.equal(field, 'test');
        const inFilter = Filter.in_(field, ['a', 'b']);
        const andFilter = Filter.and([equalFilter, inFilter]);

        expect(equalFilter.toJson(), {
          'name': {r'$eq': 'test'},
        });
        expect(inFilter.toJson(), {
          'name': {
            r'$in': ['a', 'b'],
          },
        });
        expect(andFilter.toJson(), {
          r'$and': [
            {
              'name': {r'$eq': 'test'},
            },
            {
              'name': {
                r'$in': ['a', 'b'],
              },
            },
          ],
        });
      });

      test('should maintain type safety with factory constructors', () {
        // This should compile and work correctly
        const filter1 = Filter<TestFilterField>.equal(
          TestFilterField.name,
          'test',
        );
        const filter2 = Filter<TestFilterField>.greater(
          TestFilterField.id,
          100,
        );
        const logicalFilter = Filter<TestFilterField>.and([filter1, filter2]);

        expect(
          (logicalFilter as AndOperator<TestFilterField>).filters.length,
          2,
        );
        expect(logicalFilter.toJson()[r'$and'], hasLength(2));
      });

      test('should provide equivalent functionality to direct constructors',
          () {
        const field = TestFilterField.name;
        const value = 'test';

        // Factory constructor vs direct constructor
        const factoryFilter = Filter.equal(field, value);
        const directFilter = EqualOperator(field, value);

        // Should produce identical JSON output
        expect(factoryFilter.toJson(), directFilter.toJson());
        expect(factoryFilter.toJson(), {
          'name': {r'$eq': 'test'},
        });
      });

      test('should enable fluent API usage', () {
        // Demonstrate how factory constructors enable clean, readable filter building
        const complexFilter = Filter.and([
          Filter.equal(TestFilterField.type, 'messaging'),
          Filter.or([
            Filter.contains(TestFilterField.members, 'user123'),
            Filter.query(TestFilterField.name, 'general'),
          ]),
          Filter.exists(TestFilterField.metadata, exists: true),
        ]);

        final json = complexFilter.toJson();
        expect(json, {
          r'$and': [
            {
              'type': {r'$eq': 'messaging'},
            },
            {
              r'$or': [
                {
                  'members': {r'$contains': 'user123'},
                },
                {
                  'name': {r'$q': 'general'},
                },
              ],
            },
            {
              'metadata': {r'$exists': true},
            },
          ],
        });
      });
    });

    group('ComparisonOperator', () {
      group('EqualOperator', () {
        test('should create equal filter correctly', () {
          const field = TestFilterField.name;
          const value = 'test';

          const filter = EqualOperator(field, value);

          expect(filter.field, field);
          expect(filter.value, value);
          expect(filter.operator, FilterOperator.equal);
        });

        test('should serialize to JSON correctly', () {
          const field = TestFilterField.name;
          const value = 'test';

          const filter = EqualOperator(field, value);
          final json = filter.toJson();

          expect(json, {
            'name': {r'$eq': 'test'},
          });
        });

        test('should work with different value types', () {
          const numericFilter = EqualOperator(TestFilterField.id, 123);
          const boolFilter = EqualOperator(TestFilterField.type, true);

          expect(numericFilter.toJson(), {
            'id': {r'$eq': 123},
          });
          expect(boolFilter.toJson(), {
            'type': {r'$eq': true},
          });
        });
      });

      group('GreaterOperator', () {
        test('should create greater filter correctly', () {
          const field = TestFilterField.createdAt;
          final value = DateTime(2023);

          final filter = GreaterOperator(field, value);

          expect(filter.field, field);
          expect(filter.value, value);
          expect(filter.operator, FilterOperator.greater);
        });

        test('should serialize to JSON correctly', () {
          const field = TestFilterField.id;
          const value = 100;

          const filter = GreaterOperator(field, value);
          final json = filter.toJson();

          expect(json, {
            'id': {r'$gt': 100},
          });
        });
      });

      group('GreaterOrEqualOperator', () {
        test('should create greater or equal filter correctly', () {
          const field = TestFilterField.id;
          const value = 50;

          const filter = GreaterOrEqualOperator(field, value);

          expect(filter.field, field);
          expect(filter.value, value);
          expect(filter.operator, FilterOperator.greaterOrEqual);
        });

        test('should serialize to JSON correctly', () {
          const field = TestFilterField.id;
          const value = 50;

          const filter = GreaterOrEqualOperator(field, value);
          final json = filter.toJson();

          expect(json, {
            'id': {r'$gte': 50},
          });
        });
      });

      group('LessOperator', () {
        test('should create less filter correctly', () {
          const field = TestFilterField.id;
          const value = 100;

          const filter = LessOperator(field, value);

          expect(filter.field, field);
          expect(filter.value, value);
          expect(filter.operator, FilterOperator.less);
        });

        test('should serialize to JSON correctly', () {
          const field = TestFilterField.id;
          const value = 100;

          const filter = LessOperator(field, value);
          final json = filter.toJson();

          expect(json, {
            'id': {r'$lt': 100},
          });
        });
      });

      group('LessOrEqualOperator', () {
        test('should create less or equal filter correctly', () {
          const field = TestFilterField.id;
          const value = 100;

          const filter = LessOrEqualOperator(field, value);

          expect(filter.field, field);
          expect(filter.value, value);
          expect(filter.operator, FilterOperator.lessOrEqual);
        });

        test('should serialize to JSON correctly', () {
          const field = TestFilterField.id;
          const value = 100;

          const filter = LessOrEqualOperator(field, value);
          final json = filter.toJson();

          expect(json, {
            'id': {r'$lte': 100},
          });
        });
      });
    });

    group('ListOperator', () {
      group('InOperator', () {
        test('should create in filter correctly', () {
          const field = TestFilterField.tags;
          const values = ['tag1', 'tag2', 'tag3'];

          const filter = InOperator(field, values);

          expect(filter.field, field);
          expect(filter.value, values);
          expect(filter.operator, FilterOperator.in_);
        });

        test('should serialize to JSON correctly', () {
          const field = TestFilterField.tags;
          const values = ['tag1', 'tag2', 'tag3'];

          const filter = InOperator(field, values);
          final json = filter.toJson();

          expect(json, {
            'tags': {
              r'$in': ['tag1', 'tag2', 'tag3'],
            },
          });
        });

        test('should work with different value types', () {
          const numericFilter = InOperator(TestFilterField.id, [1, 2, 3]);

          expect(numericFilter.toJson(), {
            'id': {
              r'$in': [1, 2, 3],
            },
          });
        });
      });

      group('ContainsOperator', () {
        test('should create contains filter correctly', () {
          const field = TestFilterField.members;
          const value = 'user123';

          const filter = ContainsOperator(field, value);

          expect(filter.field, field);
          expect(filter.value, value);
          expect(filter.operator, FilterOperator.contains_);
        });

        test('should serialize to JSON correctly', () {
          const field = TestFilterField.members;
          const value = 'user123';

          const filter = ContainsOperator(field, value);
          final json = filter.toJson();

          expect(json, {
            'members': {r'$contains': 'user123'},
          });
        });
      });
    });

    group('ExistsOperator', () {
      test('should create exists filter correctly', () {
        const field = TestFilterField.metadata;
        const exists = true;

        const filter = ExistsOperator(field, exists: exists);

        expect(filter.field, field);
        expect(filter.exists, exists);
        expect(filter.operator, FilterOperator.exists);
      });

      test('should serialize to JSON correctly with exists=true', () {
        const field = TestFilterField.metadata;
        const exists = true;

        const filter = ExistsOperator(field, exists: exists);
        final json = filter.toJson();

        expect(json, {
          'metadata': {r'$exists': true},
        });
      });

      test('should serialize to JSON correctly with exists=false', () {
        const field = TestFilterField.metadata;
        const exists = false;

        const filter = ExistsOperator(field, exists: exists);
        final json = filter.toJson();

        expect(json, {
          'metadata': {r'$exists': false},
        });
      });
    });

    group('EvaluationOperator', () {
      group('QueryOperator', () {
        test('should create query filter correctly', () {
          const field = TestFilterField.name;
          const query = 'search term';

          const filter = QueryOperator(field, query);

          expect(filter.field, field);
          expect(filter.query, query);
          expect(filter.operator, FilterOperator.query);
        });

        test('should serialize to JSON correctly', () {
          const field = TestFilterField.name;
          const query = 'search term';

          const filter = QueryOperator(field, query);
          final json = filter.toJson();

          expect(json, {
            'name': {r'$q': 'search term'},
          });
        });
      });

      group('AutoCompleteOperator', () {
        test('should create autocomplete filter correctly', () {
          const field = TestFilterField.name;
          const query = 'prefix';

          const filter = AutoCompleteOperator(field, query);

          expect(filter.field, field);
          expect(filter.query, query);
          expect(filter.operator, FilterOperator.autoComplete);
        });

        test('should serialize to JSON correctly', () {
          const field = TestFilterField.name;
          const query = 'prefix';

          const filter = AutoCompleteOperator(field, query);
          final json = filter.toJson();

          expect(json, {
            'name': {r'$autocomplete': 'prefix'},
          });
        });
      });
    });

    group('PathExistsOperator', () {
      test('should create path exists filter correctly', () {
        const field = TestFilterField.metadata;
        const path = 'nested.field';

        const filter = PathExistsOperator(field, path);

        expect(filter.field, field);
        expect(filter.path, path);
        expect(filter.operator, FilterOperator.pathExists);
      });

      test('should serialize to JSON correctly', () {
        const field = TestFilterField.metadata;
        const path = 'nested.field';

        const filter = PathExistsOperator(field, path);
        final json = filter.toJson();

        expect(json, {
          'metadata': {r'$path_exists': 'nested.field'},
        });
      });
    });

    group('LogicalOperator', () {
      group('AndOperator', () {
        test('should create and filter correctly', () {
          const filter1 = EqualOperator(TestFilterField.name, 'test');
          const filter2 = GreaterOperator(TestFilterField.id, 100);
          const filters = [filter1, filter2];

          const andFilter = AndOperator(filters);

          expect(andFilter.filters, filters);
          expect(andFilter.operator, FilterOperator.and);
        });

        test('should serialize to JSON correctly', () {
          const filter1 = EqualOperator(TestFilterField.name, 'test');
          const filter2 = GreaterOperator(TestFilterField.id, 100);
          const filters = [filter1, filter2];

          const andFilter = AndOperator(filters);
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
          const filter1 = EqualOperator(TestFilterField.name, 'test');
          const filter2 = GreaterOperator(TestFilterField.id, 100);
          const orFilter = OrOperator([filter1, filter2]);

          const filter3 = EqualOperator(TestFilterField.type, 'messaging');
          const andFilter = AndOperator([orFilter, filter3]);

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

      group('OrOperator', () {
        test('should create or filter correctly', () {
          const filter1 = EqualOperator(TestFilterField.name, 'test');
          const filter2 = GreaterOperator(TestFilterField.id, 100);
          const filters = [filter1, filter2];

          const orFilter = OrOperator(filters);

          expect(orFilter.filters, filters);
          expect(orFilter.operator, FilterOperator.or);
        });

        test('should serialize to JSON correctly', () {
          const filter1 = EqualOperator(TestFilterField.name, 'test');
          const filter2 = GreaterOperator(TestFilterField.id, 100);
          const filters = [filter1, filter2];

          const orFilter = OrOperator(filters);
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
        const filter = EqualOperator(TestFilterField.name, 'test');
        final encoded = json.encode(filter);

        expect(encoded, r'{"name":{"$eq":"test"}}');
      });

      test('should encode complex nested filters correctly', () {
        const filter1 = EqualOperator(TestFilterField.type, 'messaging');
        const filter2 = InOperator(
          TestFilterField.members,
          ['user1', 'user2'],
        );
        const filter3 = GreaterOperator(
          TestFilterField.createdAt,
          '2023-01-01',
        );

        const complexFilter = AndOperator(
          [
            OrOperator([filter1, filter2]),
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
        const filter = EqualOperator(TestFilterField.metadata, null);
        final json = filter.toJson();

        expect(json, {
          'metadata': {r'$eq': null},
        });
      });

      test('should handle empty list in InOperator', () {
        const filter = InOperator(TestFilterField.tags, <String>[]);
        final json = filter.toJson();

        expect(json, {
          'tags': {r'$in': <String>[]},
        });
      });

      test('should handle single item list in InOperator', () {
        const filter = InOperator(TestFilterField.tags, ['single']);
        final json = filter.toJson();

        expect(json, {
          'tags': {
            r'$in': ['single'],
          },
        });
      });

      test('should handle empty filters list in LogicalOperator', () {
        const andFilter = AndOperator(<Filter<TestFilterField>>[]);
        final json = andFilter.toJson();

        expect(json, {r'$and': <Map<String, Object?>>[]});
      });
    });

    group('Type Safety', () {
      test('should enforce FilterField type consistency', () {
        // This test ensures that the generic type system works correctly
        const filter1 = EqualOperator<TestFilterField, String>(
          TestFilterField.name,
          'test',
        );
        const filter2 = GreaterOperator<TestFilterField, int>(
          TestFilterField.id,
          100,
        );

        const logicalFilter = AndOperator<TestFilterField>([filter1, filter2]);

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

        const filter = AndOperator(
          [
            EqualOperator(TestFilterField.type, 'messaging'),
            ContainsOperator(TestFilterField.members, userId),
            GreaterOperator(
              TestFilterField.createdAt,
              createdAfter,
            ),
            ExistsOperator(TestFilterField.metadata, exists: true),
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

        const filter = OrOperator(
          [
            QueryOperator(TestFilterField.name, searchQuery),
            AutoCompleteOperator(
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

        const filter = AndOperator(
          [
            GreaterOrEqualOperator(TestFilterField.id, minId),
            LessOrEqualOperator(TestFilterField.id, maxId),
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
  });
}
