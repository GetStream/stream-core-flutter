import 'filter_operator.dart';

/// A type-safe field identifier for filtering operations.
///
/// This extension type wraps a String to provide compile-time type safety when
/// specifying fields in filter operations. It implements String, making it
/// transparent and zero-cost at runtime while ensuring only valid fields
/// can be used in filter operations.
///
/// ## Supported Operators
///
/// All filter fields support the following operators:
/// - **Comparison**: `.equal`, `.greater`, `.greaterOrEqual`, `.less`, `.lessOrEqual`
/// - **List**: `.in_`, `.contains`
/// - **Existence**: `.exists`
/// - **Evaluation**: `.query`, `.autoComplete`
/// - **Path**: `.pathExists`
/// - **Logical**: `.and`, `.or`
///
/// Example implementation:
/// ```dart
/// extension type const MyFilterField(String remote) implements FilterField {
///   /// Filter by unique identifier.
///   ///
///   /// **Supported operators**: `.equal`, `.in_`
///   static const id = MyFilterField('id');
///
///   /// Filter by display name.
///   ///
///   /// **Supported operators**: `.equal`, `.query`, `.autoComplete`
///   static const name = MyFilterField('name');
///
///   /// Filter by numeric age value.
///   ///
///   /// **Supported operators**: `.equal`, `.greater`, `.greaterOrEqual`, `.less`, `.lessOrEqual`
///   static const age = MyFilterField('age');
///
///   /// Filter by creation timestamp.
///   ///
///   /// **Supported operators**: `.equal`, `.greater`, `.greaterOrEqual`, `.less`, `.lessOrEqual`
///   static const createdAt = MyFilterField('created_at');
///
///   /// Filter by tag collections.
///   ///
///   /// **Supported operators**: `.in_`, `.contains`
///   static const tags = MyFilterField('tags');
///
///   /// Filter by JSON metadata existence.
///   ///
///   /// **Supported operators**: `.exists`, `.pathExists`
///   static const metadata = MyFilterField('metadata');
/// }
/// ```
extension type FilterField(String _) implements String {}

/// A filter for querying data with type-safe field specifications.
///
/// The primary interface for creating filters in queries that provides
/// comprehensive filtering capabilities with compile-time type safety.
/// Supports comparison, list, existence, evaluation, path, and logical operations.
///
/// Each [Filter] instance is associated with a specific [FilterField] extension type
/// that ensures only valid fields can be used in filter operations. The extension type
/// approach provides zero runtime overhead while maintaining full type safety.
///
/// ## Basic Usage
///
/// ```dart
/// // Define your field types
/// extension type const UserField(String remote) implements FilterField {
///   static const id = UserField('id');
///   static const name = UserField('name');
///   static const age = UserField('age');
///   static const email = UserField('email');
///   static const tags = UserField('tags');
///   static const metadata = UserField('metadata');
/// }
///
/// // Create complex filters with inline composition
/// final complexFilter = Filter.and([
///   Filter.equal(UserField.name, 'John'),
///   Filter.or([
///     Filter.greater(UserField.age, 18),
///     Filter.contains(UserField.email, '@company.com'),
///   ]),
///   Filter.in_(UserField.tags, ['admin', 'moderator']),
///   Filter.exists(UserField.metadata, exists: true),
/// ]);
///
/// // Convert to JSON for API usage
/// final json = complexFilter.toJson();
/// ```
sealed class Filter<F extends FilterField> {
  /// Creates a new [Filter] instance.
  const Filter._();

  // Comparison operators

  /// Creates an equality filter that matches values equal to [value].
  ///
  /// Returns an [EqualOperator] that matches when the specified [field]
  /// exactly equals the provided [value].
  const factory Filter.equal(F field, Object? value) =
      EqualOperator<F, Object?>;

  /// Creates a greater-than filter that matches values greater than [value].
  ///
  /// Returns a [GreaterOperator] that matches when the specified [field]
  /// is greater than the provided [value].
  const factory Filter.greater(F field, Object? value) =
      GreaterOperator<F, Object?>;

  /// Creates a greater-than-or-equal filter that matches values greater than or equal to [value].
  ///
  /// Returns a [GreaterOrEqualOperator] that matches when the specified [field]
  /// is greater than or equal to the provided [value].
  const factory Filter.greaterOrEqual(F field, Object? value) =
      GreaterOrEqualOperator<F, Object?>;

  /// Creates a less-than filter that matches values less than [value].
  ///
  /// Returns a [LessOperator] that matches when the specified [field]
  /// is less than the provided [value].
  const factory Filter.less(F field, Object? value) = LessOperator<F, Object?>;

  /// Creates a less-than-or-equal filter that matches values less than or equal to [value].
  ///
  /// Returns a [LessOrEqualOperator] that matches when the specified [field]
  /// is less than or equal to the provided [value].
  const factory Filter.lessOrEqual(F field, Object? value) =
      LessOrEqualOperator<F, Object?>;

  // List operators

  /// Creates an 'in' filter that matches values contained in the provided values.
  ///
  /// Returns an [InOperator] that matches when the specified [field]
  /// value is found within the provided [values] iterable.
  ///
  /// Example:
  /// ```dart
  /// // Match users with specific roles
  /// final roleFilter = Filter.in_(UserField.role, ['admin', 'moderator', 'editor']);
  ///
  /// // Works with any Iterable
  /// final statusFilter = Filter.in_(UserField.status, {'active', 'pending'});
  /// ```
  const factory Filter.in_(F field, Iterable<Object?> values) =
      InOperator<F, Object?>;

  /// Creates a contains filter that matches lists containing the specified value.
  ///
  /// Returns a [ContainsOperator] that matches when the specified [field]
  /// (which should be a list) contains the provided [value].
  const factory Filter.contains(F field, Object? value) =
      ContainsOperator<F, Object?>;

  // Existence operator

  /// Creates an existence filter that matches based on field presence.
  ///
  /// When [exists] is true, matches records where the [field] is present and not null.
  /// When [exists] is false, matches records where the [field] is null or absent.
  ///
  /// Returns an [ExistsOperator] for the specified field existence check.
  const factory Filter.exists(F field, {required bool exists}) =
      ExistsOperator<F>;

  // Evaluation operators

  /// Creates a text search filter that performs full-text search on the field.
  ///
  /// Returns a [QueryOperator] that matches when the specified [field]
  /// contains text matching the provided search [query]. Uses optimized
  /// full-text search capabilities for efficient text matching and ranking.
  const factory Filter.query(F field, String query) = QueryOperator<F>;

  /// Creates an autocomplete filter that matches field values with the specified prefix.
  ///
  /// Returns an [AutoCompleteOperator] that matches when the specified [field]
  /// starts with the provided [query] string.
  const factory Filter.autoComplete(F field, String query) =
      AutoCompleteOperator<F>;

  // Path operator

  /// Creates a path existence filter for nested JSON field checking.
  ///
  /// Returns a [PathExistsOperator] that matches when the specified [field]
  /// contains JSON with the given nested [path]. Uses optimized JSON
  /// path operations for efficient querying.
  const factory Filter.pathExists(F field, String path) = PathExistsOperator<F>;

  // Logical operators

  /// Creates a logical AND filter that matches when all provided filters match.
  ///
  /// Returns an [AndOperator] that combines multiple [filters] with logical AND,
  /// matching only when every filter in the collection matches.
  ///
  /// Example:
  /// ```dart
  /// // All conditions must be true
  /// final strictFilter = Filter.and([
  ///   Filter.equal(UserField.status, 'active'),
  ///   Filter.greater(UserField.age, 18),
  ///   Filter.exists(UserField.email, exists: true),
  /// ]);
  /// ```
  const factory Filter.and(Iterable<Filter<F>> filters) = AndOperator<F>;

  /// Creates a logical OR filter that matches when any of the provided filters match.
  ///
  /// Returns an [OrOperator] that combines multiple [filters] with logical OR,
  /// matching when at least one filter in the collection matches.
  ///
  /// Example:
  /// ```dart
  /// // Any condition can be true
  /// final flexibleFilter = Filter.or([
  ///   Filter.equal(UserField.role, 'admin'),
  ///   Filter.equal(UserField.role, 'moderator'),
  ///   Filter.greater(UserField.loginCount, 1000),
  /// ]);
  /// ```
  const factory Filter.or(Iterable<Filter<F>> filters) = OrOperator<F>;

  /// Converts this filter to a JSON representation for API queries.
  ///
  /// Returns a [Map] containing the filter structure in the format
  /// expected by the API.
  Map<String, Object?> toJson();
}

// region Comparison operators ($eq, $gt, $gte, $lt, $lte)

/// A filter operator that compares field values using comparison operations.
///
/// Base class for all comparison-based filtering operations including equality,
/// greater-than, less-than, and their variants. Each comparison operator
/// evaluates a field against a specific value using the designated comparison logic.
sealed class ComparisonOperator<F extends FilterField, V extends Object?>
    extends Filter<F> {
  const ComparisonOperator._(
    this.field,
    this.value, {
    required this.operator,
  }) : super._();

  /// The field being compared in this filter operation.
  final F field;

  /// The comparison operator used for this filter.
  final FilterOperator operator;

  /// The value to compare the field against.
  final V value;

  @override
  Map<String, Object?> toJson() {
    return {
      field: {operator: value},
    };
  }
}

/// A comparison filter that matches values equal to the specified value.
///
/// Performs exact equality matching between the field value and the provided
/// comparison value. Supports all data types including strings, numbers,
/// booleans, and null values.
///
/// **Supported with**: `.equal` factory method
final class EqualOperator<F extends FilterField, V extends Object?>
    extends ComparisonOperator<F, V> {
  /// Creates an equality filter for the specified [field] and [value].
  const EqualOperator(super.field, super.value)
      : super._(operator: FilterOperator.equal);
}

/// A comparison filter that matches values greater than the specified value.
///
/// Performs greater-than comparison between the field value and the provided
/// comparison value. Primarily used with numeric values and dates.
///
/// **Supported with**: `.greater` factory method
final class GreaterOperator<F extends FilterField, V extends Object?>
    extends ComparisonOperator<F, V> {
  /// Creates a greater-than filter for the specified [field] and [value].
  const GreaterOperator(super.field, super.value)
      : super._(operator: FilterOperator.greater);
}

/// A comparison filter that matches values greater than or equal to the specified value.
///
/// Performs greater-than-or-equal comparison between the field value and the
/// provided comparison value. Primarily used with numeric values and dates.
final class GreaterOrEqualOperator<F extends FilterField, V extends Object?>
    extends ComparisonOperator<F, V> {
  /// Creates a greater-than-or-equal filter for the specified [field] and [value].
  const GreaterOrEqualOperator(super.field, super.value)
      : super._(operator: FilterOperator.greaterOrEqual);
}

/// A comparison filter that matches values less than the specified value.
///
/// Performs less-than comparison between the field value and the provided
/// comparison value. Primarily used with numeric values and dates.
final class LessOperator<F extends FilterField, V extends Object?>
    extends ComparisonOperator<F, V> {
  /// Creates a less-than filter for the specified [field] and [value].
  const LessOperator(super.field, super.value)
      : super._(operator: FilterOperator.less);
}

/// A comparison filter that matches values less than or equal to the specified value.
///
/// Performs less-than-or-equal comparison between the field value and the
/// provided comparison value. Primarily used with numeric values and dates.
final class LessOrEqualOperator<F extends FilterField, V extends Object?>
    extends ComparisonOperator<F, V> {
  /// Creates a less-than-or-equal filter for the specified [field] and [value].
  const LessOrEqualOperator(super.field, super.value)
      : super._(operator: FilterOperator.lessOrEqual);
}

// endregion

// region List / multi-value operators ($in, $contains)

/// A filter operator that performs list-based matching operations.
///
/// Base class for filtering operations that work with collections or lists,
/// including membership testing and containment checking. These operators
/// are designed to handle multi-value scenarios efficiently.
sealed class ListOperator<F extends FilterField, V extends Object?>
    extends Filter<F> {
  const ListOperator._(
    this.field,
    this.value, {
    required this.operator,
  }) : super._();

  /// The field being filtered in this list operation.
  final F field;

  /// The list operator used for this filter.
  final FilterOperator operator;

  /// The value used for list comparison.
  final Object? value;

  @override
  Map<String, Object?> toJson() {
    return {
      field: {operator: value},
    };
  }
}

/// A list filter that matches values contained within a specified list.
///
/// Performs membership testing to determine if the field value exists
/// within the provided list of values. Useful for filtering records
/// where a field matches any of several possible values.
///
/// **Supported with**: `.in_` factory method
final class InOperator<F extends FilterField, V extends Object?>
    extends ListOperator<F, V> {
  /// Creates an 'in' filter for the specified [field] and [values] iterable.
  const InOperator(super.field, Iterable<V> super.values)
      : super._(operator: FilterOperator.in_);
}

/// A list filter that matches lists containing the specified value.
///
/// Performs containment checking to determine if the field (which should be a list)
/// contains the provided value. Useful for filtering records where a list field
/// includes a specific item.
final class ContainsOperator<F extends FilterField, V extends Object?>
    extends ListOperator<F, V> {
  /// Creates a contains filter for the specified [field] and [value].
  const ContainsOperator(super.field, super.value)
      : super._(operator: FilterOperator.contains_);
}

// endregion

// region Element / existence operators ($exists)

/// A filter that matches based on field existence or absence.
///
/// Checks whether a field exists in the record or not, regardless of its value.
/// Useful for filtering records based on the presence or absence of optional fields.
///
/// **Supported with**: `.exists` factory method
final class ExistsOperator<F extends FilterField> extends Filter<F> {
  /// Creates an existence filter for the specified [field] and [exists] condition.
  const ExistsOperator(this.field, {required this.exists}) : super._();

  /// The field to check for existence.
  final F field;

  /// Whether the field should exist (true) or not exist (false).
  final bool exists;

  /// The existence operator used for this filter.
  FilterOperator get operator => FilterOperator.exists;

  @override
  Map<String, Object?> toJson() {
    return {
      field: {operator: exists},
    };
  }
}

// endregion

// region Evaluation / text operators ($q, $autocomplete)

/// A filter operator that performs text-based evaluation operations.
///
/// Base class for filtering operations that evaluate text content,
/// including full-text search and autocomplete functionality.
sealed class EvaluationOperator<F extends FilterField> extends Filter<F> {
  const EvaluationOperator._(
    this.field,
    this.query, {
    required this.operator,
  }) : super._();

  /// The field being evaluated in this text operation.
  final F field;

  /// The evaluation operator used for this filter.
  final FilterOperator operator;

  /// The query string used for text evaluation.
  final String query;

  @override
  Map<String, Object?> toJson() {
    return {
      field: {operator: query},
    };
  }
}

/// An evaluation filter that performs full-text search on field content.
///
/// Searches for the specified query within the field's text content using
/// optimized full-text search capabilities, including ranking and relevance scoring.
///
/// **Supported with**: `.query` factory method
final class QueryOperator<F extends FilterField> extends EvaluationOperator<F> {
  /// Creates a text search filter for the specified [field] and search [query].
  const QueryOperator(super.field, super.query)
      : super._(operator: FilterOperator.query);
}

/// An evaluation filter that matches field values starting with the specified prefix.
///
/// Performs prefix matching for autocomplete functionality, finding records
/// where the field value begins with the provided query string.
final class AutoCompleteOperator<F extends FilterField>
    extends EvaluationOperator<F> {
  /// Creates an autocomplete filter for the specified [field] and prefix [query].
  const AutoCompleteOperator(super.field, super.query)
      : super._(operator: FilterOperator.autoComplete);
}

// endregion

// region Path operators ($path_exists)

/// A filter that checks for the existence of nested JSON paths within a field.
///
/// Evaluates whether the specified field contains JSON data with the given
/// nested path. Useful for filtering records based on complex nested data structures.
/// Uses optimized JSON path operations for efficient querying.
final class PathExistsOperator<F extends FilterField> extends Filter<F> {
  /// Creates a path existence filter for the specified [field] and nested [path].
  const PathExistsOperator(this.field, this.path) : super._();

  /// The field containing JSON data to check.
  final F field;

  /// The nested path to check for existence within the JSON.
  final String path;

  /// The path existence operator used for this filter.
  FilterOperator get operator => FilterOperator.pathExists;

  @override
  Map<String, Object?> toJson() {
    return {
      field: {operator: path},
    };
  }
}

// endregion

// region Logical operators ($and, $or)

/// A filter operator that combines multiple filters using logical operations.
///
/// Base class for logical filtering operations that combine multiple filter
/// conditions using AND/OR logic. Enables complex query construction through
/// filter composition.
sealed class LogicalOperator<F extends FilterField> extends Filter<F> {
  const LogicalOperator._(
    this.filters, {
    required this.operator,
  }) : super._();

  /// The logical operator used to combine filters.
  final FilterOperator operator;

  /// The list of filters to combine with logical operation.
  final Iterable<Filter<F>> filters;

  @override
  Map<String, Object?> toJson() {
    return {
      operator: filters.map((e) => e.toJson()).toList(),
    };
  }
}

/// A logical filter that matches when all provided filters match (logical AND).
///
/// Combines multiple filter conditions where every condition must be satisfied
/// for a record to match. Useful for creating restrictive queries that require
/// multiple criteria to be met simultaneously.
///
/// **Supported with**: `.and` factory method
final class AndOperator<F extends FilterField> extends LogicalOperator<F> {
  /// Creates a logical AND filter combining the specified [filters].
  const AndOperator(super.filters) : super._(operator: FilterOperator.and);
}

/// A logical filter that matches when any of the provided filters match (logical OR).
///
/// Combines multiple filter conditions where at least one condition must be satisfied
/// for a record to match. Useful for creating inclusive queries that accept
/// records meeting any of several criteria.
final class OrOperator<F extends FilterField> extends LogicalOperator<F> {
  /// Creates a logical OR filter combining the specified [filters].
  const OrOperator(super.filters) : super._(operator: FilterOperator.or);
}

// endregion
