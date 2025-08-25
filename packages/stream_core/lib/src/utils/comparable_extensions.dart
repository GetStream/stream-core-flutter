/// Extension for comparing objects that implement the Comparable interface.
extension ComparableExtension<T extends Comparable<T>> on T {
  /// Whether this object is less than the [other] object.
  bool operator <(T other) => compareTo(other) < 0;

  /// Whether this object is less than or equal to the [other] object.
  bool operator <=(T other) => compareTo(other) <= 0;

  /// Whether this object is greater than the [other] object.
  bool operator >(T other) => compareTo(other) > 0;

  /// Whether this object is greater than or equal to the [other] object.
  bool operator >=(T other) => compareTo(other) >= 0;
}
