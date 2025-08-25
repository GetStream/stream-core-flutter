import 'package:equatable/equatable.dart';

import 'filter_operator.dart';

/// Filter types are used to specify conditions for retrieving data from
/// Stream's API. Each filter consists of a field, an operator, and a value to
/// compare against.
///
/// Filters can be combined using logical operators (AND/OR) to create complex
/// queries.
///
/// ```dart
/// final filter = Filter.and(
///     Filter.equal('type', 'messaging'),
///     Filter.in_('members', [user.id])
/// )
/// ```
class Filter extends Equatable {
  const Filter.__({
    required this.value,
    this.operator,
    this.field,
  });

  const Filter._({
    required this.operator,
    required this.value,
    this.field,
  });

  /// An empty filter
  factory Filter.empty() => const Filter.__(value: <String, Object>{});

  /// Matches values that are equal to a specified value.
  factory Filter.equal(String field, Object value) {
    return Filter._(operator: FilterOperator.equal, field: field, value: value);
  }

  /// Matches values that are greater than a specified value.
  factory Filter.greater(String field, Object value) {
    return Filter._(
      operator: FilterOperator.greater,
      field: field,
      value: value,
    );
  }

  /// Matches values that are greater than a specified value.
  factory Filter.greaterOrEqual(String field, Object value) {
    return Filter._(
      operator: FilterOperator.greaterOrEqual,
      field: field,
      value: value,
    );
  }

  /// Matches values that are less than a specified value.
  factory Filter.less(String field, Object value) {
    return Filter._(operator: FilterOperator.less, field: field, value: value);
  }

  /// Matches values that are less than or equal to a specified value.
  factory Filter.lessOrEqual(String field, Object value) {
    return Filter._(
      operator: FilterOperator.lessOrEqual,
      field: field,
      value: value,
    );
  }

  /// Matches any of the values specified in an array.
  factory Filter.in_(String field, List<Object> values) {
    return Filter._(operator: FilterOperator.in_, field: field, value: values);
  }

  /// Matches values by performing text search with the specified value.
  factory Filter.query(String field, String text) {
    return Filter._(operator: FilterOperator.query, field: field, value: text);
  }

  /// Matches values with the specified prefix.
  factory Filter.autoComplete(String field, String text) {
    return Filter._(
      operator: FilterOperator.autoComplete,
      field: field,
      value: text,
    );
  }

  /// Matches values that exist/don't exist based on the specified boolean value.
  factory Filter.exists(String field, {bool exists = true}) {
    return Filter._(
      operator: FilterOperator.exists,
      field: field,
      value: exists,
    );
  }

  /// Combines the provided filters and matches the values
  /// matched by all filters.
  factory Filter.and(List<Filter> filters) {
    return Filter._(operator: FilterOperator.and, value: filters);
  }

  /// Combines the provided filters and matches the values
  /// matched by at least one of the filters.
  factory Filter.or(List<Filter> filters) {
    return Filter._(operator: FilterOperator.or, value: filters);
  }

  /// Matches any list that contains the specified values
  factory Filter.contains(String field, Object value) {
    return Filter._(
      operator: FilterOperator.contains,
      field: field,
      value: value,
    );
  }

  factory Filter.pathExists(String field, String path) {
    return Filter._(
      operator: FilterOperator.pathExists,
      field: field,
      value: path,
    );
  }

  /// Creates a custom [Filter] if there isn't one already available.
  const factory Filter.custom({
    required Object value,
    FilterOperator? operator,
    String? field,
  }) = Filter.__;

  /// Creates a custom [Filter] from a raw map value
  ///
  /// ```dart
  /// final filter = Filter.raw(
  ///   {
  ///     'members': [user1.id, user2.id],
  ///   }
  /// )
  /// ```
  const factory Filter.raw({
    required Map<String, Object> value,
  }) = Filter.__;

  /// An operator used for the filter. The operator string must start with `$`
  final FilterOperator? operator;

  /// The "left-hand" side of the filter.
  /// Specifies the name of the field the filter should match.
  ///
  /// Some operators like `and` or `or`,
  /// don't require the field value to be present.
  final String? field;

  /// The "right-hand" side of the filter.
  /// Specifies the [value] the filter should match.
  final Object /*List<Object>|List<Filter>|String*/ value;

  @override
  List<Object?> get props => [operator, field, value];

  /// Serializes to json object
  Map<String, Object> toJson() {
    final field = this.field;
    final operator = this.operator;

    // Handle raw filters (no operator or key)
    if (operator == null && field == null) {
      // We expect the value to be a Map<String, Object>
      return value as Map<String, Object>;
    }

    // Handle group operators (and, or, nor)
    if (operator != null && operator.isGroup) {
      // We encode them in the following format:
      // { $<operator>: [ <filter 1>, <filter 2> ] }
      return {operator.rawValue: value};
    }

    // Handle field-based operators
    if (operator != null && field != null) {
      // Normal filters are encoded in the following form:
      // { field: { $<operator>: <value> } }
      return {
        field: {operator.rawValue: value},
      };
    }

    // Handle simple key-value pairs (no operator)
    if (field != null) return {field: value};

    // Fallback for edge cases (shouldn't normally happen)
    return <String, Object>{};
  }
}
