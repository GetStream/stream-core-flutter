import 'package:collection/collection.dart';

// Deep equality checker.
//
// Maps are always compared with key-order-insensitivity (MapEquality).
// Lists/Iterables use order-sensitive comparison (ListEquality/IterableEquality).
const _deepEquality = DeepCollectionEquality();

/// Extension methods for deep equality and containment with PostgreSQL semantics.
extension DeepEqualityExtension<T> on T {
  /// Whether this value deeply equals [other] using PostgreSQL `=` semantics.
  ///
  /// For iterables (lists), order matters and all elements must match.
  /// For JSON objects (maps), key order is ignored but all key-value pairs
  /// must match. Nested structures are compared recursively.
  ///
  /// ```dart
  /// [1, 2, 3].deepEquals([1, 2, 3]);          // true
  /// [1, 2, 3].deepEquals([3, 2, 1]);          // false (order matters)
  /// {'a': 1, 'b': 2}.deepEquals({'b': 2, 'a': 1});  // true (key order ignored)
  /// ```
  bool deepEquals(Object? other) => _deepEquality.equals(this, other);

  /// Whether this value contains [subset] using PostgreSQL `@>` semantics.
  ///
  /// For JSON objects, all key-value pairs in [subset] must exist in this object.
  /// For iterables, all items in [subset] must exist in this iterable
  /// (order-independent). For primitives, checks direct equality.
  ///
  /// ```dart
  /// {'a': 1, 'b': 2}.containsValue({'a': 1});  // true
  /// [1, 2, 3].containsValue([2, 3]);           // true (order doesn't matter)
  /// [1, 2].containsValue(2);                   // true
  /// ```
  bool containsValue(Object? subset) {
    // JSON objects use recursive subset checking.
    if (this is Map && subset is Map) {
      return (this as Map).containsSubset(subset);
    }

    // Iterables use order-independent containment.
    if (this is Iterable<Object?>) {
      final parent = this as Iterable<Object?>;
      bool parentContains(Object? subsetItem) {
        return parent.any((item) => item.containsValue(subsetItem));
      }

      if (subset is Iterable<Object?>) {
        // Check if all subset items exist in parent (order doesn't matter).
        return subset.every(parentContains);
      }

      // Check if parent contains the single value.
      return parentContains(subset);
    }

    return deepEquals(subset);
  }
}

/// Extension methods for JSON subset checking.
extension JSONContainmentExtension<K, V> on Map<K, V> {
  /// Whether this JSON object contains [subset] as a subset.
  ///
  /// All keys in [subset] must exist in this object with matching values.
  /// Values are compared recursively using [containsValue], so nested arrays
  /// use order-independent containment and nested objects use recursive subset
  /// checking. Null values are distinguished from missing keys.
  ///
  /// ```dart
  /// {'a': 1, 'b': 2}.containsSubset({'a': 1});            // true
  /// {'a': null}.containsSubset({'a': null});              // true
  /// {'a': 1}.containsSubset({'b': 2});                    // false
  /// {'items': [1, 2, 3]}.containsSubset({'items': [2, 1]}); // true
  /// ```
  bool containsSubset(Map<Object?, Object?> subset) {
    // An empty subset is always contained.
    if (subset.isEmpty) return true;

    return subset.entries.every((entry) {
      // Key must exist (distinguishes null value from missing key).
      if (!containsKey(entry.key)) return false;

      // Value must match recursively.
      return this[entry.key].containsValue(entry.value);
    });
  }
}
