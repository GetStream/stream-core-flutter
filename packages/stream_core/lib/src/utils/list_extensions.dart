import 'package:collection/collection.dart';

import 'standard.dart';

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
  /// Inserts or replaces an element in the list based on a key.
  ///
  /// If an element with the same key already exists, it will be replaced.
  /// Otherwise, the new element will be inserted at the position determined by
  /// [insertAt] (defaults to appending at the end).
  /// Time complexity: O(n) for search, O(n) for list creation.
  ///
  /// Where the list is kept sorted, [SortedListExtensions.sortedUpsert] places
  /// the element by sort position instead of by index.
  ///
  /// ```dart
  /// final users = [User(id: '1', name: 'Alice'), User(id: '2', name: 'Bob')];
  /// final updated = users.upsert(
  ///   User(id: '1', name: 'Alice Updated'),
  ///   key: (user) => user.id,
  /// );
  /// // Result: [User(id: '1', name: 'Alice Updated'), User(id: '2', name: 'Bob')]
  ///
  /// // Adding new element (appends to end)
  /// final withNew = users.upsert(
  ///   User(id: '3', name: 'Charlie'),
  ///   key: (user) => user.id,
  /// );
  /// // Result: [User(id: '1', name: 'Alice'), User(id: '2', name: 'Bob'), User(id: '3', name: 'Charlie')]
  ///
  /// // Insert at specific position
  /// final inserted = users.upsert(
  ///   User(id: '3', name: 'Charlie'),
  ///   key: (user) => user.id,
  ///   insertAt: (list) => 0, // Insert at beginning
  /// );
  /// // Result: [User(id: '3', name: 'Charlie'), User(id: '1', name: 'Alice'), User(id: '2', name: 'Bob')]
  /// ```
  List<T> upsert<K>(
    T element, {
    required K Function(T item) key,
    int Function(List<T> list)? insertAt,
    T Function(T original, T updated)? update,
  }) {
    final elementKey = key(element);
    final index = indexWhere((e) => key(e) == elementKey);

    // Add the element if it does not exist
    if (index == -1) {
      final insertionIndex = insertAt?.call(this) ?? length;
      // Clamp index to valid range [0, length]
      final validIndex = insertionIndex.clamp(0, length);
      return [...this].apply((it) => it.insert(validIndex, element));
    }

    T handleUpdate(T original, T updated) {
      if (update != null) return update(original, updated);
      return updated; // Default behavior: prefer the updated
    }

    final original = this[index];
    // Otherwise, replace the existing element at the found index
    return [...this].apply((it) => it[index] = handleUpdate(original, element));
  }

  /// Replaces multiple elements in the list based on matching keys from another list.
  ///
  /// Elements in this list that have matching keys in [other] are replaced.
  /// Elements in [other] that don't match any keys in this list are ignored.
  /// This is useful for batch updates where you want to replace existing elements
  /// but not add new ones. Time complexity: O(n + m) where n and m are the
  /// sizes of this list and [other] respectively.
  ///
  /// ```dart
  /// final users = [
  ///   User(id: '1', name: 'Alice', score: 100),
  ///   User(id: '2', name: 'Bob', score: 80),
  ///   User(id: '3', name: 'Charlie', score: 60),
  /// ];
  ///
  /// final updates = [
  ///   User(id: '1', name: 'Alice', score: 150), // Update existing
  ///   User(id: '2', name: 'Bob', score: 90),    // Update existing
  ///   User(id: '4', name: 'David', score: 70), // Ignored (not in original)
  /// ];
  ///
  /// // Default behavior: replace with new values
  /// final updated = users.batchReplace(
  ///   updates,
  ///   key: (user) => user.id,
  /// );
  /// // Result: [User(id: '1', score: 150), User(id: '2', score: 90), User(id: '3', score: 60)]
  ///
  /// // Custom merge logic: add scores together
  /// final combined = users.batchReplace(
  ///   updates,
  ///   key: (user) => user.id,
  ///   update: (original, updated) => User(
  ///     id: original.id,
  ///     name: original.name,
  ///     score: original.score + updated.score,
  ///   ),
  /// );
  /// // Result: [User(id: '1', score: 250), User(id: '2', score: 170), User(id: '3', score: 60)]
  /// ```
  List<T> batchReplace<K>(
    List<T> other, {
    required K Function(T item) key,
    T Function(T original, T updated)? update,
  }) {
    if (isEmpty || other.isEmpty) return this;

    final lookup = {for (final item in other) key(item): item};

    T handleUpdate(T original, T updated) {
      if (update != null) return update(original, updated);
      return updated; // Default behavior: prefer the updated
    }

    final result = [...this];
    for (var i = 0; i < result.length; i++) {
      final original = result[i];
      final updated = lookup[key(original)];
      if (updated != null) result[i] = handleUpdate(original, updated);
    }

    return result;
  }

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

/// Extensions for list operations that provide optional or required sorting.
///
/// These extensions return new lists with optional or required sorting capabilities.
/// Some methods like [sortedInsert] and [sortedUpsert] use binary search algorithms
/// for efficient insertion into already-sorted lists, while others like [updateWhere]
/// and [merge] provide optional sorting as a convenience.
extension SortedListExtensions<T extends Object> on List<T> {
  /// Updates all elements in the list that match the filter condition.
  ///
  /// Returns a new list where elements matching [filter] are transformed
  /// using the [update] function, while non-matching elements remain unchanged.
  /// Optionally sorts the result if a [compare] function is provided.
  /// Time complexity: O(n) where n is the list length, or O(n log n) if sorting.
  ///
  /// ```dart
  /// final users = [
  ///   User(id: '1', name: 'Alice', active: true),
  ///   User(id: '2', name: 'Bob', active: false),
  ///   User(id: '3', name: 'Charlie', active: true),
  /// ];
  ///
  /// // Update all active users
  /// final updated = users.updateWhere(
  ///   (user) => user.active,
  ///   update: (user) => user.copyWith(lastSeen: DateTime.now()),
  /// );
  /// // Result: Active users have updated lastSeen, inactive users unchanged
  ///
  /// // Update users by name
  /// final renamed = users.updateWhere(
  ///   (user) => user.name == 'Bob',
  ///   update: (user) => user.copyWith(name: 'Robert'),
  /// );
  /// // Result: [User(name: 'Alice'), User(name: 'Robert'), User(name: 'Charlie')]
  ///
  /// // Update and sort by score
  /// final scores = [
  ///   Score(userId: '1', points: 100),
  ///   Score(userId: '2', points: 200),
  ///   Score(userId: '3', points: 150),
  /// ];
  /// final boosted = scores.updateWhere(
  ///   (score) => score.userId == '1',
  ///   update: (score) => score.copyWith(points: score.points + 150),
  ///   compare: (a, b) => b.points.compareTo(a.points), // Sort descending
  /// );
  /// // Result: [Score(userId: '1', points: 250), Score(userId: '2', points: 200), Score(userId: '3', points: 150)]
  /// ```
  List<T> updateWhere(
    bool Function(T item) filter, {
    required T Function(T original) update,
    Comparator<T>? compare,
  }) {
    // Copy only once something matches, so a pass that changes nothing can
    // hand back the receiver and let a listener comparing references skip.
    List<T>? updated;
    for (var i = 0; i < length; i++) {
      final item = this[i];
      if (!filter(item)) continue;
      updated ??= [...this];
      updated[i] = update(item);
    }

    final result = updated ?? this;
    if (compare == null) return result;
    return result.sorted(compare);
  }

  /// Inserts an element into the list, ensuring uniqueness by key.
  ///
  /// Removes any existing element with the same key and appends the new element
  /// to the end. Optionally sorts the result if a [compare] function is provided.
  /// Time complexity: O(n) for filtering + O(n log n) for sorting if compare is provided.
  ///
  /// ```dart
  /// final users = [
  ///   User(id: '1', name: 'Alice', score: 100),
  ///   User(id: '2', name: 'Bob', score: 200),
  /// ];
  ///
  /// // Insert new user (no sorting)
  /// final withNew = users.insertUniqueBy(
  ///   User(id: '3', name: 'Charlie', score: 150),
  ///   key: (user) => user.id,
  /// );
  /// // Result: [User(id: '1'), User(id: '2'), User(id: '3')]
  ///
  /// // Replace existing user and sort by score
  /// final updated = users.insertUniqueBy(
  ///   User(id: '1', name: 'Alice Updated', score: 250),
  ///   key: (user) => user.id,
  ///   compare: (a, b) => b.score.compareTo(a.score), // Sort by score desc
  /// );
  /// // Result: [User(id: '1', score: 250), User(id: '2', score: 200)]
  /// ```
  List<T> insertUnique<K>(
    T element, {
    required K Function(T item) key,
    Comparator<T>? compare,
  }) {
    final elementKey = key(element);
    final updated = where((e) => key(e) != elementKey).followedBy([element]);
    return compare?.let(updated.sorted) ?? updated.toList();
  }

  /// Inserts an element into a sorted list at the correct position.
  ///
  /// The receiver must already be sorted by [compare]. For a list kept in no
  /// particular order, append the element and sort the result instead.
  ///
  /// Uses binary search to find the insertion point and inserts the element
  /// while maintaining the sorted order. Uses stable insertion behavior where
  /// new elements are inserted after existing equal elements.
  /// Time complexity: O(log n) for search, O(n) for insertion.
  ///
  /// ```dart
  /// final numbers = [1, 3, 5, 7];
  /// final result = numbers.sortedInsert(4, compare: (a, b) => a.compareTo(b));
  /// // Result: [1, 3, 4, 5, 7]
  ///
  /// final names = ['Alice', 'Charlie'];
  /// final withBob = names.sortedInsert('Bob', compare: (a, b) => a.compareTo(b));
  /// // Result: ['Alice', 'Bob', 'Charlie']
  ///
  /// // Stable insertion: new elements go after existing equal elements
  /// final users = [User(age: 20, name: 'Alice'), User(age: 25, name: 'Bob')];
  /// final withCharlie = users.sortedInsert(User(age: 20, name: 'Charlie'), compare: (a, b) => a.age.compareTo(b.age));
  /// // Result: [User(age: 20, name: 'Alice'), User(age: 20, name: 'Charlie'), User(age: 25, name: 'Bob')]
  /// ```
  List<T> sortedInsert(
    T element, {
    required Comparator<T> compare,
  }) {
    assert(_debugAssertSorted(this, compare));

    if (isEmpty) return [element];

    // Both ends spread directly rather than splicing. Prepending is what
    // that saves on, since inserting at 0 shifts every element.
    if (compare(last, element) <= 0) return [...this, element];
    if (compare(first, element) > 0) return [element, ...this];

    final insertionIndex = _upperBound(this, element, compare);
    return [...this]..insert(insertionIndex, element);
  }

  // Finds the first position where all elements before it compare less than [element].
  // This implements upperBound behavior for stable insertion.
  static int _upperBound<T>(List<T> list, T element, Comparator<T> compare) {
    var start = 0;
    var end = list.length;

    while (start < end) {
      final mid = start + ((end - start) >> 1);
      final comparison = compare(list[mid], element);

      if (comparison <= 0) {
        // list[mid] <= element, so insertion point is after mid
        start = mid + 1;
      } else {
        // list[mid] > element, so insertion point is at or before mid
        end = mid;
      }
    }

    return start;
  }

  /// Inserts or replaces an element in a sorted list based on a key.
  ///
  /// The receiver must already be sorted by [compare]; [ListExtensions.upsert]
  /// does the same for a list kept in no particular order, appending rather
  /// than placing by sort position.
  ///
  /// First searches for an existing element with the same key. If found,
  /// replaces it using the optional [update] callback (defaults to preferring
  /// the updated element), keeping its position when the replacement sorts to
  /// the same place and moving it otherwise. If not found, inserts the element
  /// at the correct sorted position using binary search.
  /// Time complexity: O(n) for key search + O(n) for the copy if replacing,
  /// O(log n) for binary search + O(n) for insertion if adding new.
  ///
  /// ```dart
  /// final users = [
  ///   User(id: '1', name: 'Alice', score: 100),
  ///   User(id: '3', name: 'Charlie', score: 80)
  /// ];
  ///
  /// // Replace existing user (default behavior: prefer updated)
  /// final updated = users.sortedUpsert(
  ///   User(id: '1', name: 'Alice', score: 150),
  ///   key: (user) => user.id,
  ///   compare: (a, b) => b.score.compareTo(a.score), // Sort by score desc
  /// );
  /// // Result: [User(id: '1', score: 150), User(id: '3', score: 80)]
  ///
  /// // Custom merge logic: add scores together
  /// final combined = users.sortedUpsert(
  ///   User(id: '1', name: 'Alice', score: 50),
  ///   key: (user) => user.id,
  ///   compare: (a, b) => b.score.compareTo(a.score),
  ///   update: (original, updated) => User(
  ///     id: original.id,
  ///     name: original.name,
  ///     score: original.score + updated.score,
  ///   ),
  /// );
  /// // Result: [User(id: '1', score: 150), User(id: '3', score: 80)]
  ///
  /// // Add new user
  /// final withNew = users.sortedUpsert(
  ///   User(id: '2', name: 'Bob', score: 90),
  ///   key: (user) => user.id,
  ///   compare: (a, b) => b.score.compareTo(a.score),
  /// );
  /// // Result: [User(id: '1', score: 100), User(id: '2', score: 90), User(id: '3', score: 80)]
  /// ```
  List<T> sortedUpsert<K>(
    T element, {
    required K Function(T item) key,
    T Function(T original, T updated)? update,
    required Comparator<T> compare,
  }) {
    final elementKey = key(element);
    final index = indexWhere((e) => key(e) == elementKey);
    return sortedUpsertAt(index, element, update: update, compare: compare);
  }

  /// Inserts or replaces the element at [index], keeping the list sorted.
  ///
  /// Like [sortedUpsert], but for a caller that already knows where the
  /// element is and should not pay to look it up again. Pass `-1` when there
  /// is no existing element, and it inserts instead.
  ///
  /// The receiver must already be sorted by [compare]; [ListExtensions.upsert]
  /// does the same for a list kept in no particular order.
  ///
  /// ```dart
  /// final index = scores.lastIndexWhere((it) => it.userId == incoming.userId);
  /// final updated = scores.sortedUpsertAt(
  ///   index,
  ///   incoming,
  ///   compare: (a, b) => b.points.compareTo(a.points),
  /// );
  /// ```
  List<T> sortedUpsertAt(
    int index,
    T element, {
    T Function(T original, T updated)? update,
    required Comparator<T> compare,
  }) {
    if (index == -1) return sortedInsert(element, compare: compare);

    // Asserted after the insert path, which checks for itself, so a debug
    // build never walks the list twice for one call.
    assert(_debugAssertSorted(this, compare));

    final original = this[index];
    // Defaults to preferring the updated element.
    final resolved = update != null ? update(original, element) : element;

    // An update usually leaves the element where it sits, and writing it in
    // place avoids walking the list twice to remove and re-insert.
    if (compare(original, resolved) == 0) {
      return [...this]..[index] = resolved;
    }

    // Placed against the list it is going into rather than through
    // [sortedInsert], which would copy a second time to reach the same index.
    final updated = [...this]..removeAt(index);
    final destination = _upperBound(updated, resolved, compare);

    // The one place a second copy pays for itself: inserting at 0 shifts every
    // element to make room, where spreading writes them out once instead.
    if (destination == 0) return [resolved, ...updated];
    return updated..insert(destination, resolved);
  }

  /// Merges this list with another list, handling duplicates based on a key.
  ///
  /// Elements from both lists are combined into a map using the provided key
  /// function. Duplicates are resolved by the `update` callback, defaulting
  /// to preferring the element from the `other` list. The result can
  /// optionally be sorted. Time complexity: O(n + m) for merging + O(k log k)
  /// for sorting if compare is provided, where n, m are list sizes and k is result size.
  ///
  /// Returns the receiver unchanged when [other] is null, empty, or identical
  /// to this list.
  ///
  /// Where the receiver is kept sorted, [sortedMerge] reaches the same result
  /// in O(n + m) by merging rather than sorting.
  ///
  /// ```dart
  /// final oldScores = [
  ///   Score(userId: '1', points: 100),
  ///   Score(userId: '2', points: 80),
  /// ];
  /// final newScores = [
  ///   Score(userId: '1', points: 50), // Update existing
  ///   Score(userId: '3', points: 120), // New user
  /// ];
  ///
  /// // Default behavior: prefer new values
  /// final merged = oldScores.merge(
  ///   newScores,
  ///   key: (score) => score.userId,
  ///   compare: (a, b) => b.points.compareTo(a.points), // Sort by points desc
  /// );
  /// // Result: [Score(userId: '3', points: 120), Score(userId: '1', points: 50), Score(userId: '2', points: 80)]
  ///
  /// // Custom merge logic: add points together
  /// final combined = oldScores.merge(
  ///   newScores,
  ///   key: (score) => score.userId,
  ///   compare: (a, b) => b.points.compareTo(a.points),
  ///   update: (original, updated) => Score(
  ///     userId: original.userId,
  ///     points: original.points + updated.points,
  ///   ),
  /// );
  /// // Result: [Score(userId: '1', points: 150), Score(userId: '3', points: 120), Score(userId: '2', points: 80)]
  /// ```
  List<T> merge<K>(
    Iterable<T>? other, {
    required K Function(T item) key,
    T Function(T original, T updated)? update,
    Comparator<T>? compare,
  }) {
    // Nothing to merge in: hand back the receiver rather than a copy of it.
    if (other == null || other.isEmpty || identical(other, this)) return this;

    T handleUpdate(T original, T updated) {
      if (update != null) return update(original, updated);
      return updated; // Default behavior: prefer the updated
    }

    final itemMap = {for (final item in this) key(item): item};

    for (final item in other) {
      itemMap.update(
        key(item),
        (original) => handleUpdate(original, item),
        ifAbsent: () => item,
      );
    }

    final result = itemMap.values;
    return compare?.let(result.sorted) ?? result.toList();
  }

  /// Merges [other] into this list, keeping it sorted.
  ///
  /// The receiver must already be sorted by [compare]; [other] may arrive in
  /// any order. Time complexity: O(n + m) when [other] is sorted too and
  /// O(n + m log m) when it has to be sorted first, against
  /// O((n + m) log(n + m)) for [merge], which assumes no order. Prefer this
  /// whenever the receiver is kept sorted anyway, and [merge] when it is not.
  ///
  /// The keys of [other] win: an element of this list whose key appears in
  /// [other] is replaced by the [other] copy, passed through [update] when
  /// given. Each key appears once in the result, keeping the last element
  /// that carried it, as [merge] does. A replacement is placed by sort
  /// position, so one that ties with its neighbours lands behind them where
  /// [merge] would leave it in front.
  ///
  /// Returns the receiver unchanged when [other] is null, empty, or identical
  /// to this list.
  ///
  /// ```dart
  /// final merged = scores.sortedMerge(
  ///   incoming,
  ///   key: (score) => score.userId,
  ///   compare: (a, b) => b.points.compareTo(a.points),
  /// );
  /// ```
  List<T> sortedMerge<K>(
    Iterable<T>? other, {
    required K Function(T item) key,
    required Comparator<T> compare,
    T Function(T original, T updated)? update,
  }) {
    // Nothing to merge in: hand back the receiver rather than a copy of it.
    if (other == null || other.isEmpty || identical(other, this)) return this;

    assert(_debugAssertSorted(this, compare));

    T handleUpdate(T original, T updated) {
      if (update != null) return update(original, updated);
      return updated; // Default behavior: prefer the updated
    }

    final otherList = other is List<T> ? other : other.toList(growable: false);
    // An incoming batch is usually in order already, and noticing that costs
    // one walk against the n log n of sorting it regardless. Skipping the sort
    // leaves this aliasing the caller's list, so it is only ever read.
    final sortedOther = otherList.isSorted(compare) ? otherList : otherList.sorted(compare);
    return _mergeSorted(this, sortedOther, key, compare, handleUpdate);
  }

  // Keeps the last element carrying each key, matching what a keyed-map
  // merge would settle on. Order is otherwise preserved, so a sorted list
  // stays sorted.
  static List<T> _lastPerKey<T, K>(List<T> list, K Function(T item) key) {
    final seen = <K>{};
    final reversed = <T>[];
    for (var i = list.length - 1; i >= 0; i--) {
      final item = list[i];
      if (seen.add(key(item))) reversed.add(item);
    }
    return reversed.reversed.toList();
  }

  // Two-pointer merge of two lists already sorted by [compare]. Walks both
  // once, so it never pays for a full re-sort the way a keyed-map merge does.
  static List<T> _mergeSorted<T, K>(
    List<T> aIn,
    List<T> bIn,
    K Function(T item) key,
    Comparator<T> compare,
    T Function(T original, T updated) resolve,
  ) {
    final aByKey = <K, T>{for (final item in aIn) key(item): item};

    // Whether anything in [bIn] supersedes an element of [aIn] falls out of
    // building its key set, so it costs no pass of its own.
    var supersedes = false;
    final bKeys = <K>{};
    for (final item in bIn) {
      final itemKey = key(item);
      bKeys.add(itemKey);
      if (!supersedes && aByKey.containsKey(itemKey)) supersedes = true;
    }

    // A key identifies one element, so emitting it twice would put the same
    // thing in the list twice. Both collections are keyed already, so a short
    // count notices repeats for free, and only then do we pay to drop them.
    final a = aByKey.length == aIn.length ? aIn : _lastPerKey(aIn, key);
    final b = bKeys.length == bIn.length ? bIn : _lastPerKey(bIn, key);

    // When the two share no key, nothing supersedes anything and the walk
    // needs no key lookups at all — the shape of appending a batch that is
    // entirely new.
    if (!supersedes) return _mergeDisjoint(a, b, compare);

    final result = <T>[];
    var i = 0;
    var j = 0;
    while (i < a.length && j < b.length) {
      final ai = a[i];
      if (bKeys.contains(key(ai))) {
        i++;
        continue;
      }

      final bj = b[j];
      if (compare(ai, bj) <= 0) {
        result.add(ai);
        i++;
      } else {
        final original = aByKey[key(bj)];
        result.add(original != null ? resolve(original, bj) : bj);
        j++;
      }
    }

    while (i < a.length) {
      final ai = a[i++];
      if (!bKeys.contains(key(ai))) result.add(ai);
    }

    while (j < b.length) {
      final bj = b[j++];
      final original = aByKey[key(bj)];
      result.add(original != null ? resolve(original, bj) : bj);
    }

    return result;
  }

  // Merge of two sorted lists that share no keys, so neither supersedes the
  // other and the walk needs no key lookups at all.
  static List<T> _mergeDisjoint<T>(List<T> a, List<T> b, Comparator<T> compare) {
    final result = <T>[];
    var i = 0;
    var j = 0;
    while (i < a.length && j < b.length) {
      final ai = a[i];
      final bj = b[j];
      if (compare(ai, bj) <= 0) {
        result.add(ai);
        i++;
      } else {
        result.add(bj);
        j++;
      }
    }
    while (i < a.length) {
      result.add(a[i++]);
    }
    while (j < b.length) {
      result.add(b[j++]);
    }
    return result;
  }

  /// Recursively removes elements from a nested tree structure.
  ///
  /// Searches for elements matching the [test] condition at any level of
  /// nesting. When an element is found and removed, parent elements are
  /// rebuilt through the [updateChildren] callback function. Uses copy-on-write to
  /// avoid unnecessary object creation. Time complexity: O(n * d) where n is
  /// total number of nodes and d is average depth.
  ///
  /// ```dart
  /// final comments = [
  ///   Comment(
  ///     id: '1',
  ///     text: 'Great post!',
  ///     author: 'alice',
  ///     replies: [
  ///       Comment(id: '2', text: 'Thanks!', author: 'bob', replies: []),
  ///       Comment(
  ///         id: '3',
  ///         text: 'I disagree',
  ///         author: 'charlie',
  ///         replies: [
  ///           Comment(id: '4', text: 'Why?', author: 'alice', replies: []),
  ///           Comment(id: '5', text: 'Spam message', author: 'spammer', replies: []),
  ///         ],
  ///       ),
  ///     ],
  ///   ),
  /// ];
  ///
  /// // Remove spam comment from nested replies
  /// final cleaned = comments.removeNested(
  ///   (comment) => comment.author == 'spammer',
  ///   children: (comment) => comment.replies,
  ///   updateChildren: (parent, newReplies) => parent.copyWith(replies: newReplies),
  /// );
  /// // Result: Spam comment removed, parent comment updated with new replies list
  ///
  /// // Remove entire comment thread
  /// final withoutThread = comments.removeNested(
  ///   (comment) => comment.text == 'I disagree',
  ///   children: (comment) => comment.replies,
  ///   updateChildren: (parent, newReplies) => parent.copyWith(replies: newReplies),
  /// );
  /// // Result: Entire disagreement thread removed
  /// ```
  List<T> removeNested(
    bool Function(T element) test, {
    required List<T> Function(T) children,
    required T Function(T, List<T>) updateChildren,
  }) {
    if (isEmpty) return this;

    final index = indexWhere(test);
    // Try to remove the element at the root level if it matches the test
    if (index != -1) return [...this].apply((it) => it.removeAt(index));

    // Otherwise, recurse into children; copy-on-write only if something changes.
    for (var i = 0; i < length; i++) {
      final parent = this[i];
      final kids = children(parent);
      if (kids.isEmpty) continue;

      final newKids = kids.removeNested(
        test,
        children: children,
        updateChildren: updateChildren,
      );

      if (!identical(newKids, kids)) {
        // If children were updated, rebuild the parent and apply update hook.
        final rebuilt = updateChildren(parent, newKids);
        return [...this].apply((it) => it[i] = rebuilt);
      }
    }

    // If no changes were made, return the original list
    return this;
  }

  /// Recursively updates elements in a nested tree structure.
  ///
  /// Searches for elements matching the test condition at any level of
  /// nesting. When an element is found, it is updated and parent elements are
  /// rebuilt through the provided callback functions. Uses copy-on-write to
  /// avoid unnecessary object creation. Time complexity: O(n * d) where n is
  /// total number of nodes and d is average depth.
  ///
  /// ```dart
  /// final comments = [
  ///   Comment(
  ///     id: '1',
  ///     text: 'What do you think about the new Flutter release?',
  ///     author: 'flutter_dev',
  ///     upvotes: 45,
  ///     replies: [
  ///       Comment(
  ///         id: '2',
  ///         text: 'Love the performance improvements!',
  ///         author: 'mobile_dev',
  ///         upvotes: 12,
  ///         replies: [
  ///           Comment(
  ///             id: '3',
  ///             text: 'Agreed, much faster now',
  ///             author: 'senior_dev',
  ///             upvotes: 8,
  ///             replies: [],
  ///           ),
  ///         ],
  ///       ),
  ///       Comment(
  ///         id: '4',
  ///         text: 'Still has some bugs',
  ///         author: 'skeptic_user',
  ///         upvotes: 3,
  ///         replies: [],
  ///       ),
  ///     ],
  ///   ),
  /// ];
  ///
  /// // Update comment by ID
  /// final updated = comments.updateNested(
  ///   (comment) => comment.id == '3',
  ///   children: (comment) => comment.replies,
  ///   update: (comment) => comment.copyWith(upvotes: comment.upvotes + 1),
  ///   updateChildren: (parent, newReplies) => parent.copyWith(replies: newReplies),
  /// );
  ///
  /// // Update comments by author with complex condition
  /// final moderated = comments.updateNested(
  ///   (comment) => comment.author == 'skeptic_user' && comment.upvotes < 5,
  ///   children: (comment) => comment.replies,
  ///   update: (comment) => comment.copyWith(text: '[Comment moderated]'),
  ///   updateChildren: (parent, newReplies) => parent.copyWith(replies: newReplies),
  ///   compare: (a, b) => b.upvotes.compareTo(a.upvotes), // Sort by upvotes
  /// );
  /// ```
  List<T> updateNested(
    bool Function(T element) test, {
    required List<T> Function(T) children,
    required T Function(T element) update,
    required T Function(T, List<T>) updateChildren,
    Comparator<T>? compare,
  }) {
    if (isEmpty) return this;

    final index = indexWhere(test);
    // If the element is found at the root level, update and sort the list
    if (index != -1) {
      final updatedElement = update(this[index]);
      final updated = [...this].apply((it) => it[index] = updatedElement);
      return compare?.let(updated.sorted) ?? updated;
    }

    // Otherwise, recurse into children; copy-on-write only if something changes.
    for (var i = 0; i < length; i++) {
      final parent = this[i];
      final kids = children(parent);
      if (kids.isEmpty) continue;

      final newKids = kids.updateNested(
        test,
        children: children,
        update: update,
        updateChildren: updateChildren,
        compare: compare,
      );

      if (!identical(newKids, kids)) {
        // If children were updated, rebuild the parent.
        final rebuilt = updateChildren(parent, newKids);
        final updated = [...this].apply((it) => it[i] = rebuilt);
        return compare?.let(updated.sorted) ?? updated;
      }
    }

    // If no changes were made, return the original list
    return this;
  }
}

/// Asserts that [list] is already sorted by [compare].
///
/// **Note**: This method is only called in debug mode.
bool _debugAssertSorted<T>(List<T> list, Comparator<T> compare) {
  assert(() {
    if (!list.isSorted(compare)) {
      throw AssertionError(
        'A ${list.runtimeType} was used as though it were sorted by `compare`, '
        'but it is not. The result would be silently misordered rather than '
        'rejected.',
      );
    }
    return true;
  }());
  return true;
}
