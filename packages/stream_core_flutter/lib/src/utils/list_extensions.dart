/// Extensions for basic iterable operations that work with any object type.
extension IterableExtensions<T extends Object> on Iterable<T> {
  /// Returns the sum of all values produced by [selector] function applied to
  /// each element in the collection.
  int sumOf(int Function(T element) selector) {
    return fold(0, (sum, element) => sum + selector(element));
  }
}

/// Extensions for basic list operations that work with any object type.
///
/// These extensions return new lists rather than modifying existing ones,
/// following immutable patterns for safer concurrent programming.
extension ListExtensions<T extends Object> on List<T> {
  /// Splits the list into two lists based on a filter condition.
  ///
  /// Returns a record where the first list contains elements that match the
  /// filter (return true), and the second list contains elements that don't
  /// match (return false). This is useful for separating elements into two
  /// groups in a single pass. Time complexity: O(n).
  ///
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5, 6];
  /// final (even, odd) = numbers.partition((n) => n.isEven);
  /// // even: [2, 4, 6]
  /// // odd: [1, 3, 5]
  ///
  /// final users = [
  ///   User(id: '1', name: 'Alice', active: true),
  ///   User(id: '2', name: 'Bob', active: false),
  ///   User(id: '3', name: 'Charlie', active: true),
  ///   User(id: '4', name: 'David', active: false),
  /// ];
  ///
  /// // Separate active and inactive users
  /// final (active, inactive) = users.partition((user) => user.active);
  /// // active: [User(name: 'Alice'), User(name: 'Charlie')]
  /// // inactive: [User(name: 'Bob'), User(name: 'David')]
  ///
  /// // Partition by score threshold
  /// final scores = [
  ///   Score(userId: '1', points: 150),
  ///   Score(userId: '2', points: 80),
  ///   Score(userId: '3', points: 200),
  ///   Score(userId: '4', points: 45),
  /// ];
  /// final (high, low) = scores.partition((score) => score.points >= 100);
  /// // high: [Score(points: 150), Score(points: 200)]
  /// // low: [Score(points: 80), Score(points: 45)]
  /// ```
  (List<T>, List<T>) partition(bool Function(T element) test) {
    final matching = <T>[];
    final notMatching = <T>[];

    for (final element in this) {
      if (test(element)) {
        matching.add(element);
      } else {
        notMatching.add(element);
      }
    }

    return (matching, notMatching);
  }
}
