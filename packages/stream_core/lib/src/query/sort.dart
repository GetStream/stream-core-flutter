import 'package:json_annotation/json_annotation.dart';

import '../utils.dart';

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
  desc(-1)
  ;

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
  nullsLast,
}

/// Signature for a function that retrieves a sortable field value of type [V] from
/// an instance of type [T].
///
/// This function is used to extract the specific field value that should be used
/// for sorting operations from a model instance.
typedef SortFieldValueGetter<T, V> = V? Function(T);

/// A comparator function that compares two instances of type [T] based on
/// a specified field, sort direction, and null ordering.
typedef SortFieldComparator<T> =
    int Function(
      T? a,
      T? b,
      SortDirection direction,
      NullOrdering nullOrdering,
    );

/// A sort specification that defines how to order a collection of objects.
///
/// Combines a [SortField] with a [SortDirection] and [NullOrdering] to create
/// a complete sorting specification. Can be used for both API queries and
/// local sorting operations.
///
/// Example usage:
/// ```dart
/// final createdAtField = SortField('created_at', (activity) => activity.createdAt);
/// final ascendingSort = Sort.asc(createdAtField);
/// final descendingSort = Sort.desc(createdAtField, nullOrdering: NullOrdering.nullsFirst);
/// ```
@JsonSerializable(createFactory: false)
class Sort<T extends Object> {
  /// Creates an ascending sort with the specified field and null ordering.
  ///
  /// By default, null values are ordered last in ascending sorts.
  const Sort.asc(
    this.field, {
    this.nullOrdering = NullOrdering.nullsLast,
  }) : direction = SortDirection.asc;

  /// Creates a descending sort with the specified field and null ordering.
  ///
  /// By default, null values are ordered first in descending sorts.
  const Sort.desc(
    this.field, {
    this.nullOrdering = NullOrdering.nullsFirst,
  }) : direction = SortDirection.desc;

  static String _fieldToJson(SortField field) => field.remote;

  /// The field to sort by.
  @JsonKey(toJson: _fieldToJson)
  final SortField<T> field;

  /// The direction of the sort operation (ascending or descending).
  @JsonKey(name: 'direction')
  final SortDirection direction;

  /// How null values should be ordered in the sort operation.
  @JsonKey(includeToJson: false, includeFromJson: false)
  final NullOrdering nullOrdering;

  /// Compares two objects using this sort specification.
  ///
  /// Returns:
  /// - 0 if the objects are equal
  /// - A positive value if [a] should come after [b]
  /// - A negative value if [a] should come before [b]
  int compare(T? a, T? b) {
    return field.comparator.call(a, b, direction, nullOrdering);
  }

  /// Converts this sort specification to a JSON representation.
  Map<String, dynamic> toJson() => _$SortToJson(this);
}

/// A sortable field definition that maps remote field names to local value extractors.
///
/// This class defines how to sort model instances by specifying both the remote
/// field name (used in API queries) and a function to extract the corresponding
/// value from local model instances for comparison.
///
/// The [SortField] combines the remote field identifier with a comparator function
/// that can extract and compare values from model instances, enabling both remote
/// API sorting and local client-side sorting with the same field definition.
///
/// Example usage:
/// ```dart
/// final createdAtField = SortField('created_at', (activity) => activity.createdAt);
/// final nameSort = Sort.asc(createdAtField);
/// ```
class SortField<T extends Object> {
  /// Creates a new [SortField] with the specified remote field name and value extractor.
  ///
  /// The [remote] parameter specifies the field name as it appears in API queries.
  /// The [localValue] parameter is a function that extracts the corresponding value
  /// from local model instances for comparison operations.
  SortField(
    this.remote,
    SortFieldValueGetter<T, Object> localValue,
  ) : comparator = SortComparator(localValue).toAny();

  /// The remote field name used in API queries.
  final String remote;

  /// The comparator function used for local sorting operations.
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

    final comparisonResult = runSafelySync(() => aValue.compareTo(bValue));
    // If comparison fails, treat as equal in sorting
    final comparison = comparisonResult.getOrDefault(0);

    // Apply direction only to non-null comparisons
    return direction.value * comparison;
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
