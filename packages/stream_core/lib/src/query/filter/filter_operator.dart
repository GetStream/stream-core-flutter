/// A type-safe operator identifier for filtering operations.
///
/// This extension type wraps a String to provide compile-time type safety when
/// specifying operators in filter operations. Each operator represents a different
/// type of comparison or logical operation that can be performed when filtering
/// collections of data. The operators map to database query operators and are used
/// for JSON serialization in API queries.
///
/// Operators are categorized into several types:
/// - **Comparison**: [equal], [greater], [greaterOrEqual], [less], [lessOrEqual]
/// - **List**: [in_], [contains_]
/// - **Existence**: [exists]
/// - **Evaluation**: [query], [autoComplete]
/// - **Path**: [pathExists]
/// - **Logical**: [and], [or]
///
/// Example usage:
/// ```dart
/// // Using comparison operators
/// final equalFilter = Filter.equal(MyField.name, 'John');
/// final greaterFilter = Filter.greater(MyField.age, 18);
///
/// // Using logical operators
/// final andFilter = Filter.and([equalFilter, greaterFilter]);
/// ```
extension type const FilterOperator(String _) implements String {
  /// Matches values that are equal to a specified value.
  static const equal = FilterOperator(r'$eq');

  /// Matches values that are greater than a specified value.
  static const greater = FilterOperator(r'$gt');

  /// Matches values that are greater than or equal to a specified value.
  static const greaterOrEqual = FilterOperator(r'$gte');

  /// Matches values that are less than a specified value.
  static const less = FilterOperator(r'$lt');

  /// Matches values that are less than or equal to a specified value.
  static const lessOrEqual = FilterOperator(r'$lte');

  /// Matches any of the values specified in an array.
  static const in_ = FilterOperator(r'$in');

  /// Matches values by performing full-text search with the specified query string.
  ///
  /// This operator performs a text search across the specified field, typically
  /// used for searching through text content with optimized search algorithms
  /// for performance and relevance scoring.
  static const query = FilterOperator(r'$q');

  /// Matches values that start with the specified prefix string.
  ///
  /// This operator is commonly used for implementing autocomplete functionality,
  /// where you want to find all values that begin with a partial input.
  static const autoComplete = FilterOperator(r'$autocomplete');

  /// Matches records based on whether the specified field exists and is not null.
  ///
  /// When the value is `true`, matches records where the field exists and is not null.
  /// When the value is `false`, matches records where the field is null or does not exist.
  static const exists = FilterOperator(r'$exists');

  /// Performs a logical AND operation on an array of filter expressions.
  ///
  /// All specified filter conditions must be true for a record to match.
  /// This operator combines multiple filters with AND logic.
  static const and = FilterOperator(r'$and');

  /// Performs a logical OR operation on an array of filter expressions.
  ///
  /// At least one of the specified filter conditions must be true for a
  /// record to match. This operator combines multiple filters with OR logic.
  static const or = FilterOperator(r'$or');

  /// Matches arrays that contain the specified value.
  ///
  /// This operator checks if an array field contains at least one element
  /// that matches the specified value.
  static const contains_ = FilterOperator(r'$contains');

  /// Matches records where a JSON field contains the specified path.
  ///
  /// This operator is used to check for the existence of nested paths
  /// within JSON objects stored in database fields. Uses optimized JSON
  /// path operations for efficient querying.
  static const pathExists = FilterOperator(r'$path_exists');
}
