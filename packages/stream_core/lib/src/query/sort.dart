import 'package:json_annotation/json_annotation.dart';

import '../utils/standard.dart';

part 'sort.g.dart';

/// The direction of a sort operation.
///
/// Defines whether a sort should be performed in ascending (forward) or
/// descending (reverse) order.
enum SortDirection {
  /// Sort in ascending order (A to Z, 1 to 9, etc.).
  @JsonValue(1)
  asc(1),

  /// Sort in descending order (Z to A, 9 to 1, etc.).
  @JsonValue(-1)
  desc(-1);

  /// Creates a new [SortDirection] instance with the specified direction.
  const SortDirection(this.value);

  /// The numeric value representing the sort direction.
  final int value;
}

/// Defines how null values should be ordered in a sort operation.
enum NullOrdering {
  /// Null values appear at the beginning of the sorted list,
  /// regardless of sort direction (ASC or DESC).
  nullsFirst,

  /// Null values appear at the end of the sorted list,
  /// regardless of sort direction (ASC or DESC).
  nullsLast;
}

/// Signature for a function that retrieves a sort field value of type [V] from
/// an instance of type [T].
typedef SortFieldValueGetter<T, V> = V? Function(T);

/// A comparator function that compares two instances of type [T] based on
/// a specified field, sort direction, and null ordering.
typedef SortFieldComparator<T> = int Function(
  T? a,
  T? b,
  SortDirection direction,
  NullOrdering nullOrdering,
);

@JsonSerializable(createFactory: false)
class Sort<T extends Object> {
  const Sort.asc(
    this.field, {
    this.nullOrdering = NullOrdering.nullsLast,
  }) : direction = SortDirection.asc;

  const Sort.desc(
    this.field, {
    this.nullOrdering = NullOrdering.nullsFirst,
  }) : direction = SortDirection.desc;

  static String _fieldToJson(SortField field) => field.remote;

  @JsonKey(toJson: _fieldToJson)
  final SortField<T> field;

  @JsonKey(name: 'direction')
  final SortDirection direction;

  @JsonKey(includeToJson: false, includeFromJson: false)
  final NullOrdering nullOrdering;

  int compare(T? a, T? b) {
    return field.comparator.call(a, b, direction, nullOrdering);
  }
}

class SortField<T extends Object> {
  factory SortField(
    String remote,
    SortFieldValueGetter<T, Object> localValue,
  ) {
    final comparator = SortComparator(localValue).toAny();
    return SortField._(
      remote: remote,
      comparator: comparator,
    );
  }

  const SortField._({
    required this.remote,
    required this.comparator,
  });

  final String remote;

  @JsonKey(includeToJson: false, includeFromJson: false)
  final AnySortComparator<T> comparator;
}

/// A comparator that can sort model instances by extracting comparable values.
///
/// This class provides the foundation for local sorting operations by wrapping
/// a lambda that extracts comparable values from model instances. It handles
/// the comparison logic and direction handling internally.
class SortComparator<T extends Object, V extends Object> {
  /// Creates a new [SortComparator] with the specified value extraction
  /// function.
  const SortComparator(this.value);

  /// The function that extracts a comparable value of type [V] from an instance
  /// of type [T].
  final SortFieldValueGetter<T, V> value;

  /// Compares two instances of type [T] based on the extracted values,
  /// sort direction, and null ordering.
  ///
  /// Returns:
  /// - 0 if both instances are equal
  /// - 1 if the first instance is greater than the second
  /// - -1 if the first instance is less than the second
  ///
  /// Handles null values according to the specified null ordering:
  /// - `NullOrdering.nullsFirst`: Null values are considered less than any
  /// non-null value, regardless of sort direction.
  /// - `NullOrdering.nullsLast`: Null values are considered greater than any
  /// non-null value, regardless of sort direction.
  int call(T? a, T? b, SortDirection direction, NullOrdering nullOrdering) {
    final aValue = a?.let(value)?.let(ComparableField.fromValue);
    final bValue = b?.let(value)?.let(ComparableField.fromValue);

    // Handle nulls first, independent of sort direction
    if (aValue == null && bValue == null) return 0;
    if (aValue == null) return nullOrdering == NullOrdering.nullsFirst ? -1 : 1;
    if (bValue == null) return nullOrdering == NullOrdering.nullsFirst ? 1 : -1;

    // Apply direction only to non-null comparisons
    return direction.value * aValue.compareTo(bValue);
  }

  AnySortComparator<T> toAny() => AnySortComparator<T>(call);
}

/// A type-erased wrapper for sort comparators that can work with any model type.
///
/// This class provides a way to store and use sort comparators without knowing their
/// specific generic type parameters. It's useful for creating collections of different
/// sort configurations that can all work with the same model type.
///
/// Type erased type avoids making SortField generic while keeping the underlying
/// value type intact (no runtime type checks while sorting).
class AnySortComparator<T extends Object> {
  /// Creates a type-erased comparator from a specific comparator instance.
  const AnySortComparator(this.compare);

  /// The comparator function that compares two instances of type [T].
  final SortFieldComparator<T> compare;

  /// Compares two model instances using the wrapped comparator.
  int call(T? a, T? b, SortDirection direction, NullOrdering nullOrdering) {
    return compare(a, b, direction, nullOrdering);
  }
}

/// Extension that combines multiple [Sort] instances into a single comparator.
///
/// Allows sorting of objects based on multiple criteria in sequence.
extension CompositeComparator<T extends Object> on Iterable<Sort<T>> {
  /// Compares two objects using all sort options in sequence.
  ///
  /// Returns the first non-zero comparison result, or 0 if all comparisons
  /// result in equality.
  ///
  /// ```dart
  /// activities.sort(mySort.compare);
  /// ```
  int compare(T? a, T? b) {
    for (final comparator in this) {
      final comparison = comparator.compare(a, b);
      if (comparison != 0) return comparison;
    }

    return 0; // All comparisons were equal
  }
}

/// A wrapper class for values that implements [Comparable].
///
/// This class is used to compare values of different types in a way that
/// allows for consistent ordering.
///
/// This is useful when sorting or comparing values in a consistent manner.
///
/// For example, when sorting a list of objects with different types of fields,
/// using this class will ensure that all values are compared correctly
/// regardless of their type.
class ComparableField<T> implements Comparable<ComparableField<T>> {
  const ComparableField._(this.value);

  /// Creates a new [ComparableField] instance from a [value].
  static ComparableField<T>? fromValue<T>(T? value) {
    if (value == null) return null;
    return ComparableField._(value);
  }

  /// The value to be compared.
  final T value;

  @override
  int compareTo(ComparableField<T> other) {
    return switch ((value, other.value)) {
      (final num a, final num b) => a.compareTo(b),
      (final String a, final String b) => a.compareTo(b),
      (final DateTime a, final DateTime b) => a.compareTo(b),
      (final bool a, final bool b) when a == b => 0,
      (final bool a, final bool b) => a && !b ? 1 : -1, // true > false
      _ => 0 // All comparisons were equal or incomparable types
    };
  }
}
