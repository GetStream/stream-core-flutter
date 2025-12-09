import '../../utils.dart';
import 'filter_operation_utils.dart';
import 'filter_operator.dart';
import 'location/bounding_box.dart';
import 'location/circular_region.dart';
import 'location/location_coordinate.dart';

/// Function that extracts a field value from a model instance.
///
/// Returns the field value of type [V] from an instance of type [T].
typedef FilterFieldValueGetter<T, V> = V? Function(T);

/// Type-safe field identifier for filtering and value extraction.
///
/// Associates a field name with a value getter function for type-safe filtering.
/// The getter extracts field values from model instances for filter matching.
///
/// Use extension types to create filter field definitions for your models:
///
/// ```dart
/// class User {
///   User(this.id, this.name, this.age);
///
///   final String id;
///   final String name;
///   final int age;
/// }
///
/// class UserFilterField extends FilterField<User> {
///   UserFilterField(super.remote, super.value);
///
///   static const id = UserFilterField('id', (u) => u.id);
///   static const name = UserFilterField('name', (u) => u.name);
///   static const age = UserFilterField('age', (u) => u.age);
/// }
///
/// // Use in filters
/// final filter = Filter.equal(UserFilterField.name, 'John');
/// final matches = filter.matches(User('1', 'John', 30)); // true
/// ```
class FilterField<T> {
  const FilterField(this.remote, this.value);

  /// The remote field name used in API queries.
  final String remote;

  /// The function that extracts the field value of type [T] from a model instance.
  final FilterFieldValueGetter<T, Object> value;
}

/// Type-safe filter for querying data.
///
/// Provides comprehensive filtering with compile-time type safety.
/// Supports comparison, list, existence, evaluation, path, and logical operations.
///
/// ```dart
/// class User {
///   final String name;
///   final int age;
///   final List<String> tags;
///   User(this.name, this.age, this.tags);
/// }
///
/// extension type const UserField._(FilterField<User> field)
///     implements FilterField<User> {
///   const UserField(String name, Object? Function(User) getter)
///       : this._(FilterField(name, getter));
///
///   static const name = UserField('name', (u) => u.name);
///   static const age = UserField('age', (u) => u.age);
///   static const tags = UserField('tags', (u) => u.tags);
/// }
///
/// // Create complex filters
/// final filter = Filter.and([
///   Filter.equal(UserField.name, 'John'),
///   Filter.greater(UserField.age, 18),
///   Filter.contains(UserField.tags, 'admin'),
/// ]);
///
/// // Use for matching
/// final user = User('John', 25, ['admin']);
/// print(filter.matches(user)); // true
///
/// // Convert to JSON for API
/// final json = filter.toJson();
/// ```
sealed class Filter<T extends Object> {
  /// Creates a new [Filter] instance.
  const Filter._();

  // Comparison operators

  /// Equality filter matching [field] equal to [value].
  const factory Filter.equal(
    FilterField<T> field,
    Object? value,
  ) = EqualOperator<T>;

  /// Greater-than filter matching [field] greater than [value].
  const factory Filter.greater(
    FilterField<T> field,
    Object? value,
  ) = GreaterOperator<T>;

  /// Greater-than-or-equal filter matching [field] >= [value].
  const factory Filter.greaterOrEqual(
    FilterField<T> field,
    Object? value,
  ) = GreaterOrEqualOperator<T>;

  /// Less-than filter matching [field] less than [value].
  const factory Filter.less(
    FilterField<T> field,
    Object? value,
  ) = LessOperator<T>;

  /// Less-than-or-equal filter matching [field] <= [value].
  const factory Filter.lessOrEqual(
    FilterField<T> field,
    Object? value,
  ) = LessOrEqualOperator<T>;

  // List operators

  /// Membership filter matching [field] value in [values].
  const factory Filter.in_(
    FilterField<T> field,
    Iterable<Object?> values,
  ) = InOperator<T>;

  /// Containment filter matching [field] containing [value].
  const factory Filter.contains(
    FilterField<T> field,
    Object? value,
  ) = ContainsOperator<T>;

  // Existence operator

  /// Existence filter matching [field] presence when [exists] is true.
  const factory Filter.exists(
    FilterField<T> field, {
    required bool exists,
  }) = ExistsOperator<T>;

  // Evaluation operators

  /// Full-text search filter matching [field] containing [query].
  const factory Filter.query(
    FilterField<T> field,
    String query,
  ) = QueryOperator<T>;

  /// Autocomplete filter matching [field] words starting with [query].
  const factory Filter.autoComplete(
    FilterField<T> field,
    String query,
  ) = AutoCompleteOperator<T>;

  // Path operator

  /// Nested JSON path existence filter for [field] at [path].
  const factory Filter.pathExists(
    FilterField<T> field,
    String path,
  ) = PathExistsOperator<T>;

  // Logical operators

  /// Logical AND filter matching when all [filters] match.
  const factory Filter.and(Iterable<Filter<T>> filters) = AndOperator<T>;

  /// Logical OR filter matching when any [filters] match.
  const factory Filter.or(Iterable<Filter<T>> filters) = OrOperator<T>;

  /// Whether this filter matches the given [other] instance.
  ///
  /// Evaluates filter criteria against field values extracted from [other]
  /// using the field's value getter function.
  ///
  /// ```dart
  /// final filter = Filter.and([
  ///   Filter.equal(UserField.name, 'John'),
  ///   Filter.greater(UserField.age, 18),
  /// ]);
  ///
  /// final user1 = User('1', 'John', 25);
  /// print(filter.matches(user1)); // true
  ///
  /// final user2 = User('2', 'Jane', 25);
  /// print(filter.matches(user2)); // false
  /// ```
  bool matches(T other);

  /// Converts this filter to JSON format for API queries.
  Map<String, Object?> toJson();
}

// region Comparison operators ($eq, $gt, $gte, $lt, $lte)

/// Base class for comparison-based filter operations.
///
/// Supports equality, greater-than, less-than, and their variants.
sealed class ComparisonOperator<T extends Object> extends Filter<T> {
  const ComparisonOperator._(
    this.field,
    this.value, {
    required this.operator,
  }) : super._();

  /// The field being compared in this filter operation.
  final FilterField<T> field;

  /// The comparison operator used for this filter.
  final FilterOperator operator;

  /// The value to compare the field against.
  final Object? value;

  @override
  Map<String, Object?> toJson() {
    return {
      field.remote: {
        operator: switch (value) {
          final BoundingBox bbox => bbox.toJson(),
          final CircularRegion region => region.toJson(),
          _ => value,
        },
      },
    };
  }
}

/// Equality filter using exact value matching.
///
/// Performs deep equality comparison for all data types:
/// - **Primitives**: Standard equality (`==`)
/// - **Arrays**: Order-sensitive, element-by-element comparison
/// - **Objects**: Key-value equality, order-insensitive for keys
///
/// **Supported with**: `.equal` factory method
final class EqualOperator<T extends Object> extends ComparisonOperator<T> {
  /// Creates an equality filter for the specified [field] and [value].
  const EqualOperator(super.field, super.value)
      : super._(operator: FilterOperator.equal);

  @override
  bool matches(T other) {
    final fieldValue = field.value(other);
    final comparisonValue = value;

    // NULL values can't be compared.
    if (fieldValue == null || comparisonValue == null) return false;

    // Special case for location coordinates
    if (fieldValue is LocationCoordinate) {
      final isNear = fieldValue.isNear(comparisonValue);
      final isWithinBounds = fieldValue.isWithinBounds(comparisonValue);

      // Match if either near or within bounds
      return isNear || isWithinBounds;
    }

    // Deep equality: order-sensitive for arrays, order-insensitive for objects.
    return fieldValue.deepEquals(comparisonValue);
  }
}

/// Greater-than comparison filter.
///
/// Primarily used with numeric values and dates.
///
/// **Supported with**: `.greater` factory method
final class GreaterOperator<T extends Object> extends ComparisonOperator<T> {
  /// Creates a greater-than filter for the specified [field] and [value].
  const GreaterOperator(super.field, super.value)
      : super._(operator: FilterOperator.greater);

  @override
  bool matches(T other) {
    final fieldValue = ComparableField.fromValue(field.value(other));
    final comparisonValue = ComparableField.fromValue(value);

    // NULL values can't be compared.
    if (fieldValue == null || comparisonValue == null) return false;

    // Safely compare values, returning false for incomparable types.
    final result = runSafelySync(() => fieldValue > comparisonValue);
    return result.getOrDefault(false);
  }
}

/// Greater-than-or-equal comparison filter.
///
/// Primarily used with numeric values and dates.
final class GreaterOrEqualOperator<T extends Object>
    extends ComparisonOperator<T> {
  /// Creates a greater-than-or-equal filter for the specified [field] and [value].
  const GreaterOrEqualOperator(super.field, super.value)
      : super._(operator: FilterOperator.greaterOrEqual);

  @override
  bool matches(T other) {
    final fieldValue = ComparableField.fromValue(field.value(other));
    final comparisonValue = ComparableField.fromValue(value);

    // NULL values can't be compared.
    if (fieldValue == null || comparisonValue == null) return false;

    // Safely compare values, returning false for incomparable types.
    final result = runSafelySync(() => fieldValue >= comparisonValue);
    return result.getOrDefault(false);
  }
}

/// Less-than comparison filter.
///
/// Primarily used with numeric values and dates.
final class LessOperator<T extends Object> extends ComparisonOperator<T> {
  /// Creates a less-than filter for the specified [field] and [value].
  const LessOperator(super.field, super.value)
      : super._(operator: FilterOperator.less);

  @override
  bool matches(T other) {
    final fieldValue = ComparableField.fromValue(field.value(other));
    final comparisonValue = ComparableField.fromValue(value);

    // NULL values can't be compared.
    if (fieldValue == null || comparisonValue == null) return false;

    // Safely compare values, returning false for incomparable types.
    final result = runSafelySync(() => fieldValue < comparisonValue);
    return result.getOrDefault(false);
  }
}

/// Less-than-or-equal comparison filter.
///
/// Primarily used with numeric values and dates.
final class LessOrEqualOperator<T extends Object>
    extends ComparisonOperator<T> {
  /// Creates a less-than-or-equal filter for the specified [field] and [value].
  const LessOrEqualOperator(super.field, super.value)
      : super._(operator: FilterOperator.lessOrEqual);

  @override
  bool matches(T other) {
    final fieldValue = ComparableField.fromValue(field.value(other));
    final comparisonValue = ComparableField.fromValue(value);

    // NULL values can't be compared.
    if (fieldValue == null || comparisonValue == null) return false;

    // Safely compare values, returning false for incomparable types.
    final result = runSafelySync(() => fieldValue <= comparisonValue);
    return result.getOrDefault(false);
  }
}

// endregion

// region List / multi-value operators ($in, $contains)

/// Base class for list-based filter operations.
///
/// Supports membership testing and containment checking for multi-value scenarios.
sealed class ListOperator<T extends Object> extends Filter<T> {
  const ListOperator._(
    this.field,
    this.value, {
    required this.operator,
  }) : super._();

  /// The field being filtered in this list operation.
  final FilterField<T> field;

  /// The list operator used for this filter.
  final FilterOperator operator;

  /// The value used for list comparison.
  final Object? value;

  @override
  Map<String, Object?> toJson() {
    return {
      field.remote: {operator: value},
    };
  }
}

/// Membership test filter for list containment.
///
/// Tests whether the field value exists within the provided list of values.
/// Uses deep equality with order-sensitive comparison for arrays.
///
/// **Supported with**: `.in_` factory method
final class InOperator<T extends Object> extends ListOperator<T> {
  /// Creates an 'in' filter for the specified [field] and [values] iterable.
  const InOperator(super.field, Iterable<Object?> super.values)
      : super._(operator: FilterOperator.in_);

  @override
  bool matches(T other) {
    final fieldValue = field.value(other);

    final comparisonValues = value;
    if (comparisonValues is! Iterable<Object?>) return false;

    // Deep equality (order-sensitive for arrays).
    return comparisonValues.any(fieldValue.deepEquals);
  }
}

/// Containment filter for JSON and array subset matching.
///
/// Tests whether the field contains the specified value:
/// - **Arrays**: Order-independent containment (all subset items must exist)
/// - **Objects**: Recursive subset matching (all subset keys/values must exist)
/// - **Single values**: Direct equality check
///
/// **Supported with**: `.contains` factory method
final class ContainsOperator<T extends Object> extends ListOperator<T> {
  /// Creates a contains filter for the specified [field] and [value].
  const ContainsOperator(super.field, super.value)
      : super._(operator: FilterOperator.contains_);

  @override
  bool matches(T other) {
    final fieldValue = field.value(other);
    final comparisonValue = value;

    // Order-independent containment for arrays, recursive for objects.
    return fieldValue.containsValue(comparisonValue);
  }
}

// endregion

// region Element / existence operators ($exists)

/// Field existence/absence filter.
///
/// Tests whether a field is present (non-null) or absent in the record.
///
/// **Supported with**: `.exists` factory method
final class ExistsOperator<T extends Object> extends Filter<T> {
  /// Creates an existence filter for the specified [field] and [exists] condition.
  const ExistsOperator(this.field, {required this.exists}) : super._();

  /// The field to check for existence.
  final FilterField<T> field;

  /// Whether the field should exist (true) or not exist (false).
  final bool exists;

  /// The existence operator used for this filter.
  FilterOperator get operator => FilterOperator.exists;

  @override
  bool matches(T other) {
    final fieldValue = field.value(other);
    final valueExists = fieldValue != null;

    return exists ? valueExists : !valueExists;
  }

  @override
  Map<String, Object?> toJson() {
    return {
      field.remote: {operator: exists},
    };
  }
}

// endregion

// region Evaluation / text operators ($q, $autocomplete)

/// Base class for text-based evaluation filters.
///
/// Supports full-text search and autocomplete functionality.
sealed class EvaluationOperator<T extends Object> extends Filter<T> {
  const EvaluationOperator._(
    this.field,
    this.query, {
    required this.operator,
  }) : super._();

  /// The field being evaluated in this text operation.
  final FilterField<T> field;

  /// The evaluation operator used for this filter.
  final FilterOperator operator;

  /// The query string used for text evaluation.
  final String query;

  @override
  Map<String, Object?> toJson() {
    return {
      field.remote: {operator: query},
    };
  }
}

/// Full-text search filter.
///
/// Performs case-insensitive text search within the field's content.
///
/// **Supported with**: `.query` factory method
final class QueryOperator<T extends Object> extends EvaluationOperator<T> {
  /// Creates a text search filter for the specified [field] and search [query].
  const QueryOperator(super.field, super.query)
      : super._(operator: FilterOperator.query);

  @override
  bool matches(T other) {
    if (query.isEmpty) return false;

    final fieldValue = field.value(other);
    if (fieldValue is! String || fieldValue.isEmpty) return false;

    final queryRegex = RegExp(RegExp.escape(query), caseSensitive: false);
    return fieldValue.contains(queryRegex);
  }
}

/// Word prefix matching filter for autocomplete.
///
/// Matches field values where any word starts with the provided prefix.
final class AutoCompleteOperator<T extends Object>
    extends EvaluationOperator<T> {
  /// Creates an autocomplete filter for the specified [field] and prefix [query].
  const AutoCompleteOperator(super.field, super.query)
      : super._(operator: FilterOperator.autoComplete);

  @override
  bool matches(T other) {
    if (query.isEmpty) return false;

    final fieldValue = field.value(other);
    if (fieldValue is! String || fieldValue.isEmpty) return false;

    // Split the text into words and check for any word starting with the query prefix.
    final splitRegex = RegExp(r'[\s\p{P}]+', unicode: true);
    final words = fieldValue.split(splitRegex).where((word) => word.isNotEmpty);

    final queryRegex = RegExp(RegExp.escape(query), caseSensitive: false);
    return words.any((word) => word.startsWith(queryRegex));
  }
}

// endregion

// region Path operators ($path_exists)

/// Nested JSON path existence filter.
///
/// Tests whether the field contains JSON data with the specified nested path.
final class PathExistsOperator<T extends Object> extends Filter<T> {
  /// Creates a path existence filter for the specified [field] and nested [path].
  const PathExistsOperator(this.field, this.path) : super._();

  /// The field containing JSON data to check.
  final FilterField<T> field;

  /// The nested path to check for existence within the JSON.
  final String path;

  /// The path existence operator used for this filter.
  FilterOperator get operator => FilterOperator.pathExists;

  @override
  bool matches(T other) {
    final root = field.value(other);
    if (root is! Map) return false;
    if (path.isEmpty) return false;

    final pathParts = path.split('.');

    Object? current = root;
    for (final part in pathParts) {
      // Empty path segments (e.g., from "" or "a..b") are invalid
      if (part.isEmpty) return false;
      if (current is! Map) return false;
      if (!current.containsKey(part)) return false;

      current = current[part];
    }

    return true;
  }

  @override
  Map<String, Object?> toJson() {
    return {
      field.remote: {operator: path},
    };
  }
}

// endregion

// region Logical operators ($and, $or)

/// Base class for logical filter composition.
///
/// Combines multiple filters using AND/OR logic.
sealed class LogicalOperator<T extends Object> extends Filter<T> {
  const LogicalOperator._(
    this.filters, {
    required this.operator,
  }) : super._();

  /// The logical operator used to combine filters.
  final FilterOperator operator;

  /// The list of filters to combine with logical operation.
  final Iterable<Filter<T>> filters;

  @override
  Map<String, Object?> toJson() {
    return {
      operator: filters.map((e) => e.toJson()).toList(),
    };
  }
}

/// Logical AND filter requiring all conditions to match.
///
/// All provided filters must match for a record to be included.
///
/// **Supported with**: `.and` factory method
final class AndOperator<T extends Object> extends LogicalOperator<T> {
  /// Creates a logical AND filter combining the specified [filters].
  const AndOperator(super.filters) : super._(operator: FilterOperator.and);

  @override
  bool matches(T other) => filters.every((filter) => filter.matches(other));
}

/// Logical OR filter requiring any condition to match.
///
/// At least one provided filter must match for a record to be included.
final class OrOperator<T extends Object> extends LogicalOperator<T> {
  /// Creates a logical OR filter combining the specified [filters].
  const OrOperator(super.filters) : super._(operator: FilterOperator.or);

  @override
  bool matches(T other) => filters.any((filter) => filter.matches(other));
}

// endregion
