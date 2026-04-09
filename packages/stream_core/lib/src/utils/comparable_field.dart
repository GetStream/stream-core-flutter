import 'package:meta/meta.dart';

/// A type-safe wrapper for ordering values.
///
/// Wraps values to provide consistent comparison and ordering semantics,
/// particularly useful for handling mixed numeric types (e.g., comparing int
/// with double) and providing clear error messages for incompatible types.
///
/// ## Supported Types
///
/// - **Numeric** (`num`, `int`, `double`): Natural numeric comparison
///   - Handles mixed types: `42` vs `42.0` compares correctly
/// - **String**: Lexicographic (alphabetical) order
/// - **DateTime**: Chronological order
/// - **Boolean**: `false < true`
/// - **Other types**: Throws [ArgumentError] on comparison
///
/// ## Examples
///
/// ### Basic comparison
/// ```dart
/// final age = ComparableField.fromValue(25);
/// final minAge = ComparableField.fromValue(18);
///
/// if (age != null && minAge != null) {
///   print(age > minAge);            // true
///   print(age.compareTo(minAge));   // positive number (> 0)
/// }
/// ```
///
/// ### Null handling
/// ```dart
/// final nullField = ComparableField.fromValue(null);
/// print(nullField);  // null (not a ComparableField instance)
/// ```
///
/// ### Mixed numeric types
/// ```dart
/// final intField = ComparableField.fromValue(42);
/// final doubleField = ComparableField.fromValue(42.0);
/// print(intField?.compareTo(doubleField!));  // 0 (equal)
/// ```
@immutable
class ComparableField<T extends Object> implements Comparable<ComparableField<T>> {
  const ComparableField._(this.value);

  /// Creates a [ComparableField] from [value].
  ///
  /// Returns `null` if [value] is `null`.
  ///
  /// Example:
  /// ```dart
  /// ComparableField.fromValue(42);    // ComparableField<int>
  /// ComparableField.fromValue(null);  // null
  /// ```
  static ComparableField<T>? fromValue<T extends Object>(T? value) {
    if (value == null) return null;
    return ComparableField._(value);
  }

  /// The wrapped value.
  final T value;

  /// Compares this field to [other] for ordering.
  ///
  /// Returns a negative integer if this value is less than [other], zero if
  /// they are equal, or a positive integer if this value is greater.
  ///
  /// **Comparison Rules:**
  /// - Numbers: Natural numeric comparison (handles int vs double)
  /// - Strings: Lexicographic (dictionary) order
  /// - DateTime: Chronological order
  /// - Booleans: `false` < `true`
  ///
  /// Throws [ArgumentError] when comparing incompatible types (e.g., comparing
  /// a String to an int, or attempting to order collections like Maps or Lists).
  @override
  int compareTo(ComparableField<T> other) {
    return switch ((value, other.value)) {
      (final num a, final num b) => a.compareTo(b),
      (final String a, final String b) => a.compareTo(b),
      (final DateTime a, final DateTime b) => a.compareTo(b),
      (final bool a, final bool b) when a == b => 0,
      (final bool a, final bool b) => a && !b ? 1 : -1,
      _ => throw ArgumentError(
        'Incompatible types: ${value.runtimeType} vs ${other.value.runtimeType}',
      ),
    };
  }
}
