/// Possible operators to use in filters.
enum FilterOperator {
  /// Matches values that are equal to a specified value.
  equal(r'$eq'),

  /// Matches values that are greater than a specified value.
  greater(r'$gt'),

  /// Matches values that are greater than a specified value.
  greaterOrEqual(r'$gte'),

  /// Matches values that are less than a specified value.
  less(r'$lt'),

  /// Matches values that are less than or equal to a specified value.
  lessOrEqual(r'$lte'),

  /// Matches any of the values specified in an array.
  in_(r'$in'),

  /// Matches values by performing text search with the specified value.
  query(r'$q'),

  /// Matches values with the specified prefix.
  autoComplete(r'$autocomplete'),

  /// Matches values that exist/don't exist based on the specified boolean value.
  exists(r'$exists'),

  /// Matches all the values specified in an array.
  and(r'$and'),

  /// Matches at least one of the values specified in an array.
  or(r'$or'),

  /// Matches any list that contains the specified value
  contains(r'$contains'),

  /// Matches if the value contains JSON with the given path.
  pathExists(r'$path_exists');

  const FilterOperator(this.rawValue);
  final String rawValue;

  /// Returns `true` if the operator is a group operator (i.e., `and` or `or`).
  bool get isGroup {
    return switch (this) {
      FilterOperator.and || FilterOperator.or => true,
      _ => false,
    };
  }
}
