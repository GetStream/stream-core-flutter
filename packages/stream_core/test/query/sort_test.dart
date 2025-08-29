import 'package:stream_core/src/query/sort.dart';
import 'package:test/test.dart';

// Test models
class Person {
  const Person({
    required this.name,
    required this.age,
    this.birthDate,
    this.isActive = true,
    this.score,
    this.custom,
  });

  final String name;
  final int age;
  final DateTime? birthDate;
  final bool isActive;
  final double? score;
  final Map<String, Object?>? custom; // For testing non-comparable types
}

class Product {
  const Product({
    required this.title,
    required this.price,
  });

  final String title;
  final double price;
}

void main() {
  group('SortField', () {
    test('should create field for string values', () {
      final field = SortField<Person>('name', (p) => p.name);

      expect(field.remote, equals('name'));
      expect(field.comparator, isNotNull);
    });

    test('should create field for int values', () {
      final field = SortField<Person>('age', (p) => p.age);

      expect(field.remote, equals('age'));
    });

    test('should create field for nullable DateTime values', () {
      final field = SortField<Person>('birthDate', (p) => p.birthDate);

      expect(field.remote, equals('birthDate'));
    });

    test('should create field for bool values', () {
      final field = SortField<Person>('isActive', (p) => p.isActive);

      expect(field.remote, equals('isActive'));
    });

    test('should create field for double values', () {
      final field = SortField<Person>('score', (p) => p.score);

      expect(field.remote, equals('score'));
    });

    test('should create field for non-comparable types', () {
      final field = SortField<Person>(
        'metadata',
        (p) => p.custom,
      );

      expect(field.remote, equals('metadata'));
    });
  });

  group('Sort.forward', () {
    test('should create forward sort with default null ordering', () {
      final field = SortField<Person>('name', (p) => p.name);
      final sort = Sort.asc(field);

      expect(sort.direction, equals(SortDirection.asc));
      expect(sort.nullOrdering, equals(NullOrdering.nullsLast));
      expect(sort.field, equals(field));
    });

    test('should create forward sort with custom null ordering', () {
      final field = SortField<Person>('name', (p) => p.name);
      final sort = Sort.asc(field, nullOrdering: NullOrdering.nullsFirst);

      expect(sort.nullOrdering, equals(NullOrdering.nullsFirst));
    });

    test('should sort strings in ascending order', () {
      final field = SortField<Person>('name', (p) => p.name);
      final sort = Sort.asc(field);

      const alice = Person(name: 'Alice', age: 30);
      const bob = Person(name: 'Bob', age: 25);
      const charlie = Person(name: 'Charlie', age: 35);

      expect(sort.compare(alice, bob), lessThan(0)); // Alice < Bob
      expect(sort.compare(bob, charlie), lessThan(0)); // Bob < Charlie
      expect(sort.compare(alice, alice), equals(0)); // Alice == Alice
    });

    test('should sort numbers in ascending order', () {
      final field = SortField<Person>('age', (p) => p.age);
      final sort = Sort.asc(field);

      const young = Person(name: 'Young', age: 20);
      const middle = Person(name: 'Middle', age: 30);
      const old = Person(name: 'Old', age: 40);

      expect(sort.compare(young, middle), lessThan(0)); // 20 < 30
      expect(sort.compare(middle, old), lessThan(0)); // 30 < 40
      expect(sort.compare(young, young), equals(0)); // 20 == 20
    });

    test('should sort DateTime in ascending order', () {
      final field = SortField<Person>('birthDate', (p) => p.birthDate);
      final sort = Sort.asc(field);

      final person1990 =
          Person(name: 'Person1990', age: 34, birthDate: DateTime(1990));
      final person2000 =
          Person(name: 'Person2000', age: 24, birthDate: DateTime(2000));

      expect(sort.compare(person1990, person2000), lessThan(0)); // 1990 < 2000
    });

    test('should sort bool values (false < true)', () {
      final field = SortField<Person>('isActive', (p) => p.isActive);
      final sort = Sort.asc(field);

      const inactive = Person(name: 'Inactive', age: 30, isActive: false);
      const active = Person(name: 'Active', age: 25);

      expect(sort.compare(inactive, active), lessThan(0)); // false < true
      expect(sort.compare(active, inactive), greaterThan(0)); // true > false
    });

    test('should handle null objects', () {
      final field = SortField<Person>('name', (p) => p.name);
      final sort = Sort.asc(field);
      const person = Person(name: 'Alice', age: 30);

      expect(sort.compare(null, null), equals(0));
      expect(
        sort.compare(null, person),
        greaterThan(0),
      ); // null treated as "greater" with nullsLast
      expect(sort.compare(person, null), lessThan(0));
    });

    test('should handle null extracted values with nullsLast', () {
      final field = SortField<Person>('birthDate', (p) => p.birthDate);
      final sort = Sort.asc(field);

      final withDate =
          Person(name: 'WithDate', age: 30, birthDate: DateTime(1990));
      const withoutDate = Person(name: 'WithoutDate', age: 25);

      expect(
        sort.compare(withDate, withoutDate),
        lessThan(0),
      ); // non-null < null
      expect(
        sort.compare(withoutDate, withDate),
        greaterThan(0),
      ); // null > non-null
    });

    test('should handle null extracted values with nullsFirst', () {
      final field = SortField<Person>('birthDate', (p) => p.birthDate);
      final sort = Sort.asc(field, nullOrdering: NullOrdering.nullsFirst);

      final withDate =
          Person(name: 'WithDate', age: 30, birthDate: DateTime(1990));
      const withoutDate = Person(name: 'WithoutDate', age: 25);

      expect(
        sort.compare(withoutDate, withDate),
        lessThan(0),
      ); // null < non-null
      expect(
        sort.compare(withDate, withoutDate),
        greaterThan(0),
      ); // non-null > null
    });
  });

  group('Sort.reverse', () {
    test('should create reverse sort with default null ordering', () {
      final field = SortField<Person>('name', (p) => p.name);
      final sort = Sort.desc(field);

      expect(sort.direction, equals(SortDirection.desc));
      expect(sort.nullOrdering, equals(NullOrdering.nullsFirst));
      expect(sort.field, equals(field));
    });

    test('should create reverse sort with custom null ordering', () {
      final field = SortField<Person>('name', (p) => p.name);
      final sort = Sort.desc(field, nullOrdering: NullOrdering.nullsLast);

      expect(sort.nullOrdering, equals(NullOrdering.nullsLast));
    });

    test('should sort strings in descending order', () {
      final field = SortField<Person>('name', (p) => p.name);
      final sort = Sort.desc(field);

      const alice = Person(name: 'Alice', age: 30);
      const bob = Person(name: 'Bob', age: 25);
      const charlie = Person(name: 'Charlie', age: 35);

      expect(
        sort.compare(alice, bob),
        greaterThan(0),
      ); // Alice > Bob (reversed)
      expect(
        sort.compare(bob, charlie),
        greaterThan(0),
      ); // Bob > Charlie (reversed)
      expect(sort.compare(alice, alice), equals(0)); // Alice == Alice
    });

    test('should sort numbers in descending order', () {
      final field = SortField<Person>('age', (p) => p.age);
      final sort = Sort.desc(field);

      const young = Person(name: 'Young', age: 20);
      const middle = Person(name: 'Middle', age: 30);
      const old = Person(name: 'Old', age: 40);

      expect(sort.compare(young, middle), greaterThan(0)); // 20 > 30 (reversed)
      expect(sort.compare(middle, old), greaterThan(0)); // 30 > 40 (reversed)
      expect(sort.compare(young, young), equals(0)); // 20 == 20
    });
  });

  group('Composite Sorting (Multiple Sort Criteria)', () {
    test('should sort by multiple criteria using extension', () {
      final nameField = SortField<Person>('name', (p) => p.name);
      final ageField = SortField<Person>('age', (p) => p.age);

      final sorts = [
        Sort.asc(nameField),
        Sort.asc(ageField),
      ];

      const alice30 = Person(name: 'Alice', age: 30);
      const alice25 = Person(name: 'Alice', age: 25);
      const bob20 = Person(name: 'Bob', age: 20);

      // Same name, different age - should sort by age
      expect(
        sorts.compare(alice25, alice30),
        lessThan(0),
      ); // Alice(25) < Alice(30)
      expect(
        sorts.compare(alice30, alice25),
        greaterThan(0),
      ); // Alice(30) > Alice(25)

      // Different names - should sort by name first
      expect(sorts.compare(alice30, bob20), lessThan(0)); // Alice < Bob
      expect(sorts.compare(bob20, alice25), greaterThan(0)); // Bob > Alice
    });

    test('should handle mixed sort directions', () {
      final nameField = SortField<Person>('name', (p) => p.name);
      final ageField = SortField<Person>('age', (p) => p.age);

      final sorts = [
        Sort.asc(nameField), // Name ascending
        Sort.desc(ageField), // Age descending
      ];

      const alice25 = Person(name: 'Alice', age: 25);
      const alice30 = Person(name: 'Alice', age: 30);

      // Same name, age should be reverse sorted (30 before 25)
      expect(
        sorts.compare(alice25, alice30),
        greaterThan(0),
      ); // Alice(25) > Alice(30) when age is reversed
      expect(
        sorts.compare(alice30, alice25),
        lessThan(0),
      ); // Alice(30) < Alice(25) when age is reversed
    });

    test('should return 0 when all criteria are equal', () {
      final nameField = SortField<Person>('name', (p) => p.name);
      final ageField = SortField<Person>('age', (p) => p.age);

      final sorts = [
        Sort.asc(nameField),
        Sort.asc(ageField),
      ];

      const alice1 = Person(name: 'Alice', age: 30);
      const alice2 = Person(name: 'Alice', age: 30);

      expect(sorts.compare(alice1, alice2), equals(0));
    });
  });

  group('Real-world Integration Tests', () {
    test('should sort list of people by name', () {
      final nameField = SortField<Person>('name', (p) => p.name);
      final sort = Sort.asc(nameField);

      final people = [
        const Person(name: 'Charlie', age: 35),
        const Person(name: 'Alice', age: 30),
        const Person(name: 'Bob', age: 25),
      ];

      people.sort(sort.compare);

      expect(
        people.map((p) => p.name).toList(),
        equals(['Alice', 'Bob', 'Charlie']),
      );
    });

    test('should sort list of people by age (descending)', () {
      final ageField = SortField<Person>('age', (p) => p.age);
      final sort = Sort.desc(ageField);

      final people = [
        const Person(name: 'Alice', age: 30),
        const Person(name: 'Charlie', age: 35),
        const Person(name: 'Bob', age: 25),
      ];

      people.sort(sort.compare);

      expect(people.map((p) => p.age).toList(), equals([35, 30, 25]));
    });

    test('should sort with composite criteria (name asc, age desc)', () {
      final nameField = SortField<Person>('name', (p) => p.name);
      final ageField = SortField<Person>('age', (p) => p.age);

      final sorts = [
        Sort.asc(nameField),
        Sort.desc(ageField),
      ];

      final people = [
        const Person(name: 'Alice', age: 25),
        const Person(name: 'Bob', age: 30),
        const Person(name: 'Alice', age: 35),
        const Person(name: 'Bob', age: 20),
      ];

      people.sort(sorts.compare);

      final result = people.map((p) => '${p.name}-${p.age}').toList();
      expect(result, equals(['Alice-35', 'Alice-25', 'Bob-30', 'Bob-20']));
    });

    test('should handle nullable values correctly', () {
      final scoreField = SortField<Person>('score', (p) => p.score);
      final sort = Sort.asc(scoreField, nullOrdering: NullOrdering.nullsFirst);

      final people = [
        const Person(name: 'Alice', age: 30, score: 85.5),
        const Person(name: 'Bob', age: 25), // null score
        const Person(name: 'Charlie', age: 35, score: 92),
        const Person(name: 'David', age: 28), // null score
      ];

      people.sort(sort.compare);

      final names = people.map((p) => p.name).toList();
      expect(
        names,
        equals([
          'Bob',
          'David',
          'Alice',
          'Charlie',
        ]),
      ); // nulls first, then by score
    });

    test('should work with different object types', () {
      final titleField = SortField<Product>('title', (p) => p.title);
      final sort = Sort.asc(titleField);

      final products = [
        const Product(title: 'Zebra Toy', price: 15.99),
        const Product(title: 'Apple Phone', price: 999.99),
        const Product(title: 'Book Collection', price: 29.99),
      ];

      products.sort(sort.compare);

      expect(
        products.map((p) => p.title).toList(),
        equals(['Apple Phone', 'Book Collection', 'Zebra Toy']),
      );
    });

    test('should handle mixed numeric types (int and double)', () {
      final priceField = SortField<Product>('price', (p) => p.price);
      final sort = Sort.asc(priceField);

      final products = [
        const Product(title: 'Expensive', price: 999.99),
        const Product(title: 'Cheap', price: 15), // double that equals an int
        const Product(title: 'Medium', price: 29.99),
      ];

      products.sort(sort.compare);

      expect(
        products.map((p) => p.price).toList(),
        equals([15.0, 29.99, 999.99]),
      );
    });

    test('should handle complex multi-field sort with nulls', () {
      final nameField = SortField<Person>('name', (p) => p.name);
      final scoreField = SortField<Person>('score', (p) => p.score);

      final sorts = [
        Sort.asc(nameField),
        Sort.desc(scoreField, nullOrdering: NullOrdering.nullsLast),
      ];

      final people = [
        const Person(name: 'Alice', age: 30, score: 85.5),
        const Person(name: 'Alice', age: 25), // null score
        const Person(name: 'Alice', age: 35, score: 92),
        const Person(name: 'Bob', age: 28, score: 78),
        const Person(name: 'Bob', age: 32), // null score
      ];

      people.sort(sorts.compare);

      final result = people
          .map((p) => '${p.name}-${p.score?.toString() ?? 'null'}')
          .toList();
      expect(
        result,
        equals([
          'Alice-92.0', // Alice, highest score first
          'Alice-85.5', // Alice, next highest score
          'Alice-null', // Alice, null score last
          'Bob-78.0', // Bob, with score
          'Bob-null', // Bob, null score last
        ]),
      );
    });

    test('should handle non-comparable types gracefully', () {
      final metadataField = SortField<Person>(
        'metadata',
        (p) => p.custom,
      );
      final sort = Sort.asc(metadataField);

      const person1 = Person(name: 'Alice', age: 30, custom: {'key': 'value1'});
      const person2 = Person(name: 'Bob', age: 25, custom: {'key': 'value2'});
      const person3 = Person(name: 'Charlie', age: 35); // null metadata

      // Should not throw, even though Map is not directly comparable
      expect(() => sort.compare(person1, person2), returnsNormally);
      expect(() => sort.compare(person1, person3), returnsNormally);

      // Non-comparable types should return 0 for comparison
      expect(sort.compare(person1, person2), equals(0));
    });
  });
}
