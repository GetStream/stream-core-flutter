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
  /// Updates all elements in the list that match the filter condition.
  ///
  /// Returns a new list where elements matching [filter] are transformed
  /// using the [update] function, while non-matching elements remain unchanged.
  /// Time complexity: O(n) where n is the list length.
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
  /// ```
  List<T> updateWhere(
    bool Function(T item) filter, {
    required T Function(T original) update,
  }) {
    return map((it) => filter(it) ? update(it) : it).toList();
  }

  /// Inserts or replaces an element in the list based on a key.
  ///
  /// If an element with the same key already exists, it will be replaced.
  /// Otherwise, the new element will be appended to the end of the list.
  /// Time complexity: O(n) for search, O(n) for list creation.
  ///
  /// ```dart
  /// final users = [User(id: '1', name: 'Alice'), User(id: '2', name: 'Bob')];
  /// final updated = users.upsert(
  ///   User(id: '1', name: 'Alice Updated'),
  ///   key: (user) => user.id,
  /// );
  /// // Result: [User(id: '1', name: 'Alice Updated'), User(id: '2', name: 'Bob')]
  ///
  /// // Adding new element
  /// final withNew = users.upsert(
  ///   User(id: '3', name: 'Charlie'),
  ///   key: (user) => user.id,
  /// );
  /// // Result: [User(id: '1', name: 'Alice'), User(id: '2', name: 'Bob'), User(id: '3', name: 'Charlie')]
  /// ```
  List<T> upsert<K>(
    T element, {
    required K Function(T item) key,
    T Function(T original, T updated)? update,
  }) {
    final elementKey = key(element);
    final index = indexWhere((e) => key(e) == elementKey);

    // Add the element if it does not exist
    if (index == -1) return [...this, element];

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
}

/// Extensions for operations on sorted lists.
///
/// These extensions maintain list order and provide efficient operations
/// for sorted collections using binary search algorithms where applicable.
extension SortedListExtensions<T extends Object> on List<T> {
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
    final insertionIndex = _upperBound(this, element, compare);
    return [...this].apply((it) => it.insert(insertionIndex, element));
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
  /// First searches for an existing element with the same key. If found,
  /// replaces it using the optional [update] callback (defaults to preferring
  /// the updated element) and re-sorts the list. If not found, inserts the element
  /// at the correct sorted position using binary search.
  /// Time complexity: O(n) for key search + O(n log n) for sorting if replacing,
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

    // If the element does not exist, insert it at the correct position
    if (index == -1) return sortedInsert(element, compare: compare);

    // Otherwise, replace the existing element at the found index
    // and re-sort the list if necessary.

    final updatedList = [...this];
    final original = updatedList.removeAt(index);

    T handleUpdate(T original, T updated) {
      if (update != null) return update(original, updated);
      return updated; // Default behavior: prefer the updated
    }

    return updatedList.sortedInsert(
      handleUpdate(original, element),
      compare: compare,
    );
  }

  /// Merges this list with another list, handling duplicates based on a key.
  ///
  /// Elements from both lists are combined into a map using the provided key
  /// function. Duplicates are resolved by the `update` callback, defaulting
  /// to preferring the element from the `other` list. The result can
  /// optionally be sorted. Time complexity: O(n + m) for merging + O(k log k)
  /// for sorting if compare is provided, where n, m are list sizes and k is result size.
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
    Iterable<T> other, {
    required K Function(T item) key,
    T Function(T original, T updated)? update,
    Comparator<T>? compare,
  }) {
    if (other.isEmpty) return this;

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
