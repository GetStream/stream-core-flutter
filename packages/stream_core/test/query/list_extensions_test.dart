// ignore_for_file: avoid_redundant_argument_values

import 'package:equatable/equatable.dart';
import 'package:stream_core/src/utils/list_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('ListExtensions', () {
    group('upsert', () {
      test('should add new element when key does not exist', () {
        final users = [
          const _TestUser(id: '1', name: 'Alice'),
          const _TestUser(id: '2', name: 'Bob'),
        ];

        final result = users.upsert(
          const _TestUser(id: '3', name: 'Charlie'),
          key: (user) => user.id,
        );

        expect(result.length, 3);
        expect(result.last.id, '3');
        expect(result.last.name, 'Charlie');
        // Original list should be unchanged
        expect(users.length, 2);
      });

      test('should replace existing element when key exists', () {
        final users = [
          const _TestUser(id: '1', name: 'Alice'),
          const _TestUser(id: '2', name: 'Bob'),
        ];

        final result = users.upsert(
          const _TestUser(id: '1', name: 'Alice Updated'),
          key: (user) => user.id,
        );

        expect(result.length, 2);
        expect(result.first.id, '1');
        expect(result.first.name, 'Alice Updated');
        expect(result.last.name, 'Bob');
        // Original list should be unchanged
        expect(users.first.name, 'Alice');
      });

      test('should work with empty list', () {
        final users = <_TestUser>[];

        final result = users.upsert(
          const _TestUser(id: '1', name: 'Alice'),
          key: (user) => user.id,
        );

        expect(result.length, 1);
        expect(result.first.id, '1');
        expect(result.first.name, 'Alice');
      });

      test('should handle single element list replacement', () {
        final users = [const _TestUser(id: '1', name: 'Alice')];

        final result = users.upsert(
          const _TestUser(id: '1', name: 'Alice Updated'),
          key: (user) => user.id,
        );

        expect(result.length, 1);
        expect(result.first.name, 'Alice Updated');
      });

      test('should handle single element list addition', () {
        final users = [const _TestUser(id: '1', name: 'Alice')];

        final result = users.upsert(
          const _TestUser(id: '2', name: 'Bob'),
          key: (user) => user.id,
        );

        expect(result.length, 2);
        expect(result.first.name, 'Alice');
        expect(result.last.name, 'Bob');
      });

      test('should preserve order when replacing element', () {
        final users = [
          const _TestUser(id: '1', name: 'Alice'),
          const _TestUser(id: '2', name: 'Bob'),
          const _TestUser(id: '3', name: 'Charlie'),
        ];

        final result = users.upsert(
          const _TestUser(id: '2', name: 'Bob Updated'),
          key: (user) => user.id,
        );

        expect(result.length, 3);
        expect(result[0].name, 'Alice');
        expect(result[1].name, 'Bob Updated');
        expect(result[2].name, 'Charlie');
      });

      test('should work with different key types', () {
        final scores = [
          const _TestScore(userId: 1, points: 100),
          const _TestScore(userId: 2, points: 200),
        ];

        final result = scores.upsert(
          const _TestScore(userId: 1, points: 150),
          key: (score) => score.userId,
        );

        expect(result.length, 2);
        expect(result.first.points, 150);
        expect(result.last.points, 200);
      });

      test('should handle complex objects with custom key', () {
        final activities = [
          const _TestActivity(id: 'act1', authorId: 'user1', content: 'Hello'),
          const _TestActivity(id: 'act2', authorId: 'user2', content: 'World'),
        ];

        final result = activities.upsert(
          const _TestActivity(
            id: 'act1',
            authorId: 'user1',
            content: 'Hello Updated',
          ),
          key: (activity) => activity.id,
        );

        expect(result.length, 2);
        expect(result.first.content, 'Hello Updated');
        expect(result.last.content, 'World');
      });
    });
  });

  group('SortedListExtensions', () {
    group('sortedInsert', () {
      test('should insert element at correct position in sorted list', () {
        final numbers = [1, 3, 5, 7];

        final result =
            numbers.sortedInsert(4, compare: (a, b) => a.compareTo(b));

        expect(result, [1, 3, 4, 5, 7]);
        // Original list should be unchanged
        expect(numbers, [1, 3, 5, 7]);
      });

      test('should insert at beginning when element is smallest', () {
        final numbers = [3, 5, 7];

        final result =
            numbers.sortedInsert(1, compare: (a, b) => a.compareTo(b));

        expect(result, [1, 3, 5, 7]);
      });

      test('should insert at end when element is largest', () {
        final numbers = [1, 3, 5];

        final result =
            numbers.sortedInsert(7, compare: (a, b) => a.compareTo(b));

        expect(result, [1, 3, 5, 7]);
      });

      test('should work with single element list', () {
        final numbers = [5];

        final smaller =
            numbers.sortedInsert(3, compare: (a, b) => a.compareTo(b));
        final larger =
            numbers.sortedInsert(7, compare: (a, b) => a.compareTo(b));

        expect(smaller, [3, 5]);
        expect(larger, [5, 7]);
      });

      test('should work with empty list', () {
        final numbers = <int>[];

        final result =
            numbers.sortedInsert(5, compare: (a, b) => a.compareTo(b));

        expect(result, [5]);
      });

      test('should work with reverse order comparator', () {
        final numbers = [7, 5, 3, 1]; // Descending order

        final result =
            numbers.sortedInsert(4, compare: (a, b) => b.compareTo(a));

        expect(result, [7, 5, 4, 3, 1]);
      });

      test('should work with string sorting', () {
        final names = ['Alice', 'Charlie', 'David'];

        final result =
            names.sortedInsert('Bob', compare: (a, b) => a.compareTo(b));

        expect(result, ['Alice', 'Bob', 'Charlie', 'David']);
      });

      test('should work with complex objects', () {
        final users = [
          const _TestUser(id: '1', name: 'Alice'),
          const _TestUser(id: '3', name: 'Charlie'),
          const _TestUser(id: '5', name: 'Eve'),
        ];

        final result = users.sortedInsert(
          const _TestUser(id: '2', name: 'Bob'),
          compare: (a, b) => a.name.compareTo(b.name),
        );

        expect(result.length, 4);
        expect(result.map((u) => u.name), ['Alice', 'Bob', 'Charlie', 'Eve']);
      });

      test('should handle duplicate values', () {
        final numbers = [1, 3, 5, 7];

        final result =
            numbers.sortedInsert(3, compare: (a, b) => a.compareTo(b));

        expect(result, [1, 3, 3, 5, 7]);
      });
    });

    group('sortedUpsert', () {
      test('should replace existing element and maintain sorted order', () {
        final users = [
          const _TestScore(userId: 1, points: 100),
          const _TestScore(userId: 3, points: 80),
          const _TestScore(userId: 5, points: 60),
        ];

        final result = users.sortedUpsert(
          const _TestScore(userId: 1, points: 150),
          key: (score) => score.userId,
          compare: (a, b) =>
              b.points.compareTo(a.points), // Descending by points
        );

        expect(result.length, 3);
        expect(result.map((s) => s.points), [150, 80, 60]);
        expect(result.map((s) => s.userId), [1, 3, 5]);
      });

      test('should insert new element at correct sorted position', () {
        final users = [
          const _TestScore(userId: 1, points: 100),
          const _TestScore(userId: 3, points: 60),
        ];

        final result = users.sortedUpsert(
          const _TestScore(userId: 2, points: 80),
          key: (score) => score.userId,
          compare: (a, b) =>
              b.points.compareTo(a.points), // Descending by points
        );

        expect(result.length, 3);
        expect(result.map((s) => s.points), [100, 80, 60]);
        expect(result.map((s) => s.userId), [1, 2, 3]);
      });

      test('should work with empty list', () {
        final scores = <_TestScore>[];

        final result = scores.sortedUpsert(
          const _TestScore(userId: 1, points: 100),
          key: (score) => score.userId,
          compare: (a, b) => b.points.compareTo(a.points),
        );

        expect(result.length, 1);
        expect(result.first.points, 100);
      });

      test('should handle single element replacement', () {
        final scores = [const _TestScore(userId: 1, points: 100)];

        final result = scores.sortedUpsert(
          const _TestScore(userId: 1, points: 150),
          key: (score) => score.userId,
          compare: (a, b) => b.points.compareTo(a.points),
        );

        expect(result.length, 1);
        expect(result.first.points, 150);
      });

      test('should handle single element addition', () {
        final scores = [const _TestScore(userId: 1, points: 100)];

        final result = scores.sortedUpsert(
          const _TestScore(userId: 2, points: 150),
          key: (score) => score.userId,
          compare: (a, b) => b.points.compareTo(a.points),
        );

        expect(result.length, 2);
        expect(result.map((s) => s.points), [150, 100]);
        expect(result.map((s) => s.userId), [2, 1]);
      });

      test('should maintain sort order after replacement', () {
        final activities = [
          const _TestActivity(id: 'act1', authorId: 'user1', content: 'A'),
          const _TestActivity(id: 'act2', authorId: 'user2', content: 'B'),
          const _TestActivity(id: 'act3', authorId: 'user3', content: 'C'),
        ];

        final result = activities.sortedUpsert(
          const _TestActivity(id: 'act2', authorId: 'user2', content: 'Z'),
          key: (activity) => activity.id,
          compare: (a, b) => a.content.compareTo(b.content),
        );

        expect(result.length, 3);
        expect(result.map((a) => a.content), ['A', 'C', 'Z']);
        expect(result.map((a) => a.id), ['act1', 'act3', 'act2']);
      });
    });

    group('merge', () {
      test('should merge two lists with default update behavior', () {
        final oldScores = [
          const _TestScore(userId: 1, points: 100),
          const _TestScore(userId: 2, points: 80),
        ];
        final newScores = [
          const _TestScore(userId: 1, points: 50), // Update existing
          const _TestScore(userId: 3, points: 120), // New user
        ];

        final result = oldScores.merge(
          newScores,
          key: (score) => score.userId,
          compare: (a, b) => b.points.compareTo(a.points),
        );

        expect(result.length, 3);
        expect(result.map((s) => s.points), [120, 80, 50]);
        expect(result.map((s) => s.userId), [3, 2, 1]);
      });

      test('should merge with custom update function', () {
        final oldScores = [
          const _TestScore(userId: 1, points: 100),
          const _TestScore(userId: 2, points: 80),
        ];
        final newScores = [
          const _TestScore(userId: 1, points: 50),
          const _TestScore(userId: 3, points: 120),
        ];

        final result = oldScores.merge(
          newScores,
          key: (score) => score.userId,
          compare: (a, b) => b.points.compareTo(a.points),
          update: (original, updated) => _TestScore(
            userId: original.userId,
            points: original.points + updated.points,
          ),
        );

        expect(result.length, 3);
        expect(result.map((s) => s.points), [150, 120, 80]);
        expect(result.map((s) => s.userId), [1, 3, 2]);
      });

      test('should return unsorted result when compare is null', () {
        final oldScores = [
          const _TestScore(userId: 1, points: 100),
          const _TestScore(userId: 2, points: 80),
        ];
        final newScores = [
          const _TestScore(userId: 3, points: 120),
          const _TestScore(userId: 1, points: 50),
        ];

        final result = oldScores.merge(
          newScores,
          key: (score) => score.userId,
          compare: null,
        );

        expect(result.length, 3);
        // Order should match original insertion order in map
        final userIds = result.map((s) => s.userId).toList();
        expect(userIds.contains(1), true);
        expect(userIds.contains(2), true);
        expect(userIds.contains(3), true);
      });

      test('should handle empty other list', () {
        final scores = [
          const _TestScore(userId: 1, points: 100),
          const _TestScore(userId: 2, points: 80),
        ];
        final empty = <_TestScore>[];

        final result = scores.merge(
          empty,
          key: (score) => score.userId,
          compare: (a, b) => b.points.compareTo(a.points),
        );

        expect(result, scores);
      });

      test('should handle empty source list', () {
        final empty = <_TestScore>[];
        final scores = [
          const _TestScore(userId: 1, points: 100),
          const _TestScore(userId: 2, points: 80),
        ];

        final result = empty.merge(
          scores,
          key: (score) => score.userId,
          compare: (a, b) => b.points.compareTo(a.points),
        );

        expect(result.length, 2);
        expect(result.map((s) => s.points), [100, 80]);
      });

      test('should handle both lists empty', () {
        final empty1 = <_TestScore>[];
        final empty2 = <_TestScore>[];

        final result = empty1.merge(
          empty2,
          key: (score) => score.userId,
          compare: (a, b) => b.points.compareTo(a.points),
        );

        expect(result, isEmpty);
      });

      test('should handle complex merge scenario', () {
        final oldActivities = [
          const _TestActivity(id: 'act1', authorId: 'user1', content: 'Hello'),
          const _TestActivity(id: 'act2', authorId: 'user2', content: 'World'),
          const _TestActivity(
            id: 'act4',
            authorId: 'user4',
            content: 'Existing',
          ),
        ];
        final newActivities = [
          const _TestActivity(
            id: 'act1',
            authorId: 'user1',
            content: 'Hello Updated',
          ),
          const _TestActivity(
            id: 'act3',
            authorId: 'user3',
            content: 'New Activity',
          ),
          const _TestActivity(
            id: 'act5',
            authorId: 'user5',
            content: 'Another New',
          ),
        ];

        final result = oldActivities.merge(
          newActivities,
          key: (activity) => activity.id,
          compare: (a, b) => a.id.compareTo(b.id),
        );

        expect(result.length, 5);
        expect(
          result.map((a) => a.id),
          ['act1', 'act2', 'act3', 'act4', 'act5'],
        );
        expect(result.first.content, 'Hello Updated'); // Updated content
      });
    });

    group('removeNested', () {
      test('should remove element from root level', () {
        final comments = [
          const _TestComment(id: '1', text: 'Great post!', replies: []),
          const _TestComment(id: '2', text: 'Thanks!', replies: []),
        ];

        final result = comments.removeNested(
          (comment) => comment.id == '1',
          children: (comment) => comment.replies,
          updateChildren: (parent, newReplies) {
            return parent.copyWith(
              replies: newReplies,
              modifiedAt: DateTime.now(),
            );
          },
        );

        expect(result.length, 1);
        expect(result.first.id, '2');
        // Original list should be unchanged
        expect(comments.length, 2);
      });

      test('should remove element from nested level', () {
        final comments = [
          const _TestComment(
            id: '1',
            text: 'Great post!',
            replies: [
              _TestComment(id: '2', text: 'Thanks!', replies: []),
              _TestComment(id: '3', text: 'Spam message', replies: []),
            ],
          ),
        ];

        final result = comments.removeNested(
          (comment) => comment.text == 'Spam message',
          children: (comment) => comment.replies,
          updateChildren: (parent, newReplies) => parent.copyWith(
            replies: newReplies,
            modifiedAt: DateTime.now(),
          ),
        );

        expect(result.length, 1);
        expect(result.first.replies.length, 1);
        expect(result.first.replies.first.text, 'Thanks!');
        expect(result.first.modifiedAt, isNotNull); // Parent was updated
      });

      test('should remove element from deeply nested structure', () {
        final comments = [
          const _TestComment(
            id: '1',
            text: 'Root comment',
            replies: [
              _TestComment(
                id: '2',
                text: 'Level 1 reply',
                replies: [
                  _TestComment(
                    id: '3',
                    text: 'Level 2 reply',
                    replies: [
                      _TestComment(id: '4', text: 'Deep spam', replies: []),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ];

        final result = comments.removeNested(
          (comment) => comment.text == 'Deep spam',
          children: (comment) => comment.replies,
          updateChildren: (parent, newReplies) => parent.copyWith(
            replies: newReplies,
            modifiedAt: DateTime.now(),
          ),
        );

        expect(result.length, 1);
        expect(result.first.replies.first.replies.first.replies, isEmpty);
        expect(result.first.modifiedAt, isNotNull); // Root was updated
      });

      test('should handle empty list', () {
        final comments = <_TestComment>[];

        final result = comments.removeNested(
          (comment) => comment.id == '1',
          children: (comment) => comment.replies,
          updateChildren: (parent, newReplies) => parent.copyWith(
            replies: newReplies,
            modifiedAt: DateTime.now(),
          ),
        );

        expect(result, isEmpty);
      });

      test('should return same list if no element matches', () {
        final comments = [
          const _TestComment(
            id: '1',
            text: 'Great post!',
            replies: [
              _TestComment(id: '2', text: 'Thanks!', replies: []),
            ],
          ),
        ];

        final result = comments.removeNested(
          (comment) => comment.id == 'nonexistent',
          children: (comment) => comment.replies,
          updateChildren: (parent, newReplies) => parent.copyWith(
            replies: newReplies,
            modifiedAt: DateTime.now(),
          ),
        );

        expect(
          identical(result, comments),
          true,
        ); // Should return same instance
      });

      test('should handle multiple matching elements (removes first found)',
          () {
        final comments = [
          const _TestComment(id: '1', text: 'duplicate', replies: []),
          const _TestComment(id: '2', text: 'duplicate', replies: []),
        ];

        final result = comments.removeNested(
          (comment) => comment.text == 'duplicate',
          children: (comment) => comment.replies,
          updateChildren: (parent, newReplies) => parent.copyWith(
            replies: newReplies,
            modifiedAt: DateTime.now(),
          ),
        );

        expect(result.length, 1);
        expect(result.first.id, '2'); // First match ('1') was removed
      });

      test('should handle complex nested removal scenario', () {
        final threadStructure = [
          const _TestComment(
            id: '1',
            text: 'Main discussion',
            replies: [
              _TestComment(
                id: '2',
                text: 'Good point',
                replies: [
                  _TestComment(id: '3', text: 'I agree', replies: []),
                ],
              ),
              _TestComment(
                id: '4',
                text: 'Controversial opinion',
                replies: [
                  _TestComment(id: '5', text: 'Spam reply', replies: []),
                  _TestComment(id: '6', text: 'Valid response', replies: []),
                ],
              ),
            ],
          ),
        ];

        final result = threadStructure.removeNested(
          (comment) => comment.text == 'Spam reply',
          children: (comment) => comment.replies,
          updateChildren: (parent, newReplies) => parent.copyWith(
            replies: newReplies,
            modifiedAt: DateTime.now(),
          ),
        );

        expect(result.length, 1);
        final mainComment = result.first;
        expect(mainComment.replies.length, 2);

        final controversialComment = mainComment.replies
            .firstWhere((c) => c.text == 'Controversial opinion');
        expect(controversialComment.replies.length, 1);
        expect(controversialComment.replies.first.text, 'Valid response');
        expect(mainComment.modifiedAt, isNotNull); // Root was updated
      });
    });

    group('updateNested', () {
      test('should update element at root level', () {
        final comments = [
          const _TestComment(
            id: '1',
            text: 'Original text',
            upvotes: 5,
            replies: [],
          ),
          const _TestComment(
            id: '2',
            text: 'Another comment',
            upvotes: 3,
            replies: [],
          ),
        ];

        const updatedComment = _TestComment(
          id: '1',
          text: 'Updated text',
          upvotes: 6,
          replies: [],
        );

        final result = comments.updateNested(
          updatedComment,
          key: (comment) => comment.id,
          children: (comment) => comment.replies,
          update: (comment) => comment.copyWith(modifiedAt: DateTime.now()),
          updateChildren: (parent, newReplies) =>
              parent.copyWith(replies: newReplies),
        );

        expect(result.length, 2);
        expect(result.first.text, 'Updated text');
        expect(result.first.upvotes, 6);
        expect(result.first.modifiedAt, isNotNull);
        expect(result.last.text, 'Another comment');
      });

      test('should update element in nested structure', () {
        final comments = [
          const _TestComment(
            id: '1',
            text: 'Root comment',
            upvotes: 10,
            replies: [
              _TestComment(
                id: '2',
                text: 'Nested comment',
                upvotes: 5,
                replies: [],
              ),
              _TestComment(
                id: '3',
                text: 'Another nested',
                upvotes: 3,
                replies: [],
              ),
            ],
          ),
        ];

        const updatedComment = _TestComment(
          id: '2',
          text: 'Updated nested comment',
          upvotes: 8,
          replies: [],
        );

        final result = comments.updateNested(
          updatedComment,
          key: (comment) => comment.id,
          children: (comment) => comment.replies,
          update: (comment) => comment.copyWith(modifiedAt: DateTime.now()),
          updateChildren: (parent, newReplies) =>
              parent.copyWith(replies: newReplies),
        );

        expect(result.length, 1);
        expect(result.first.replies.length, 2);
        expect(result.first.replies.first.text, 'Updated nested comment');
        expect(result.first.replies.first.upvotes, 8);
        expect(result.first.replies.first.modifiedAt, isNotNull);
      });

      test('should update and sort when compare function is provided', () {
        final comments = [
          const _TestComment(
            id: '1',
            text: 'Root',
            upvotes: 10,
            replies: [
              _TestComment(id: '2', text: 'Low score', upvotes: 2, replies: []),
              _TestComment(
                id: '3',
                text: 'High score',
                upvotes: 8,
                replies: [],
              ),
            ],
          ),
        ];

        const updatedComment = _TestComment(
          id: '2',
          text: 'Now high score',
          upvotes: 12,
          replies: [],
        );

        final result = comments.updateNested(
          updatedComment,
          key: (comment) => comment.id,
          children: (comment) => comment.replies,
          update: (comment) => comment.copyWith(modifiedAt: DateTime.now()),
          updateChildren: (parent, newReplies) =>
              parent.copyWith(replies: newReplies),
          compare: (a, b) =>
              b.upvotes.compareTo(a.upvotes), // Sort by upvotes desc
        );

        expect(result.length, 1);
        expect(result.first.replies.length, 2);
        // Updated comment should now be first due to higher upvotes
        expect(result.first.replies.first.text, 'Now high score');
        expect(result.first.replies.first.upvotes, 12);
        expect(result.first.replies.last.text, 'High score');
        expect(result.first.replies.last.upvotes, 8);
      });

      test('should handle deeply nested updates', () {
        final comments = [
          const _TestComment(
            id: '1',
            text: 'Level 0',
            replies: [
              _TestComment(
                id: '2',
                text: 'Level 1',
                replies: [
                  _TestComment(
                    id: '3',
                    text: 'Level 2',
                    upvotes: 5,
                    replies: [
                      _TestComment(
                        id: '4',
                        text: 'Level 3',
                        upvotes: 1,
                        replies: [],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ];

        const updatedComment = _TestComment(
          id: '4',
          text: 'Updated Level 3',
          upvotes: 10,
          replies: [],
        );

        final result = comments.updateNested(
          updatedComment,
          key: (comment) => comment.id,
          children: (comment) => comment.replies,
          update: (comment) => comment.copyWith(modifiedAt: DateTime.now()),
          updateChildren: (parent, newReplies) =>
              parent.copyWith(replies: newReplies),
        );

        expect(result.length, 1);
        final deepComment =
            result.first.replies.first.replies.first.replies.first;
        expect(deepComment.text, 'Updated Level 3');
        expect(deepComment.upvotes, 10);
        expect(deepComment.modifiedAt, isNotNull);
      });

      test('should handle empty list', () {
        final comments = <_TestComment>[];

        final result = comments.updateNested(
          const _TestComment(id: '1', text: 'New comment', replies: []),
          key: (comment) => comment.id,
          children: (comment) => comment.replies,
          update: (comment) => comment.copyWith(modifiedAt: DateTime.now()),
          updateChildren: (parent, newReplies) =>
              parent.copyWith(replies: newReplies),
        );

        expect(result, isEmpty);
      });

      test('should return same list if element not found', () {
        final comments = [
          const _TestComment(id: '1', text: 'Existing comment', replies: []),
        ];

        final result = comments.updateNested(
          const _TestComment(id: 'nonexistent', text: 'Not found', replies: []),
          key: (comment) => comment.id,
          children: (comment) => comment.replies,
          update: (comment) => comment.copyWith(modifiedAt: DateTime.now()),
          updateChildren: (parent, newReplies) =>
              parent.copyWith(replies: newReplies),
        );

        expect(
          identical(result, comments),
          true,
        ); // Should return same instance
      });

      test('should handle complex thread update scenario', () {
        final forumThread = [
          const _TestComment(
            id: 'post1',
            text: 'What are your thoughts on the new Flutter update?',
            upvotes: 45,
            replies: [
              _TestComment(
                id: 'reply1',
                text: 'Love the performance improvements!',
                upvotes: 12,
                replies: [
                  _TestComment(
                    id: 'subreply1',
                    text: 'Agreed, much faster now',
                    upvotes: 8,
                    replies: [],
                  ),
                ],
              ),
              _TestComment(
                id: 'reply2',
                text: 'Still has some bugs',
                upvotes: 3,
                replies: [],
              ),
            ],
          ),
        ];

        // User upvotes a deeply nested comment
        const upvotedComment = _TestComment(
          id: 'subreply1',
          text: 'Agreed, much faster now',
          upvotes: 9, // Incremented
          replies: [],
        );

        final result = forumThread.updateNested(
          upvotedComment,
          key: (comment) => comment.id,
          children: (comment) => comment.replies,
          update: (comment) => comment.copyWith(modifiedAt: DateTime.now()),
          updateChildren: (parent, newReplies) =>
              parent.copyWith(replies: newReplies),
          compare: (a, b) => b.upvotes.compareTo(a.upvotes), // Sort by upvotes
        );

        expect(result.length, 1);
        final mainPost = result.first;
        expect(mainPost.replies.length, 2);

        final topReply = mainPost.replies.first;
        expect(topReply.id, 'reply1');
        expect(topReply.replies.first.upvotes, 9); // Upvote count updated
        expect(topReply.replies.first.modifiedAt, isNotNull);
      });
    });
  });

  group('Edge Cases and Performance', () {
    group('Null Safety and Type Safety', () {
      test('should handle null values in custom key functions', () {
        final items = [
          const _TestItemWithNullable(id: '1', value: 'A'),
          const _TestItemWithNullable(id: '2', value: null),
          const _TestItemWithNullable(id: '3', value: 'C'),
        ];

        final result = items.upsert(
          const _TestItemWithNullable(id: '2', value: 'B Updated'),
          key: (item) => item.id,
        );

        expect(result.length, 3);
        expect(result[1].value, 'B Updated');
      });
    });

    group('Performance and Memory', () {
      test('should efficiently handle large lists in upsert', () {
        final largeList = List.generate(
          1000,
          (i) => _TestUser(id: i.toString(), name: 'User $i'),
        );

        final stopwatch = Stopwatch()..start();
        final result = largeList.upsert(
          const _TestUser(id: '500', name: 'Updated User 500'),
          key: (user) => user.id,
        );
        stopwatch.stop();

        expect(result.length, 1000);
        expect(result[500].name, 'Updated User 500');
        expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Should be fast
      });

      test('should efficiently handle large sorted inserts', () {
        final largeList = List.generate(
          1000,
          (i) => _TestScore(userId: i, points: i * 10),
        );

        final stopwatch = Stopwatch()..start();
        final result = largeList.sortedInsert(
          const _TestScore(userId: 1001, points: 5555),
          compare: (a, b) => a.points.compareTo(b.points),
        );
        stopwatch.stop();

        expect(result.length, 1001);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(10),
        ); // Binary search is fast
      });

      test('should handle memory efficiently with copy-on-write', () {
        final originalList = [
          const _TestUser(id: '1', name: 'Alice'),
          const _TestUser(id: '2', name: 'Bob'),
        ];

        final result1 = originalList.upsert(
          const _TestUser(id: '3', name: 'Charlie'),
          key: (user) => user.id,
        );

        final result2 = originalList.upsert(
          const _TestUser(id: '4', name: 'David'),
          key: (user) => user.id,
        );

        // Original list should be unchanged
        expect(originalList.length, 2);
        expect(result1.length, 3);
        expect(result2.length, 3);
        expect(result1.last.name, 'Charlie');
        expect(result2.last.name, 'David');
      });

      test('should handle deeply nested structures efficiently', () {
        // Create a deep nested structure (5 levels deep)
        _TestComment createDeepStructure(int depth, String prefix) {
          if (depth == 0) {
            return _TestComment(id: '${prefix}_$depth', text: 'Leaf $prefix');
          }
          return _TestComment(
            id: '${prefix}_$depth',
            text: 'Level $depth',
            replies: [createDeepStructure(depth - 1, prefix)],
          );
        }

        final deepComments = [
          createDeepStructure(5, 'thread1'),
          createDeepStructure(5, 'thread2'),
        ];

        final stopwatch = Stopwatch()..start();
        final result = deepComments.updateNested(
          const _TestComment(id: 'thread1_0', text: 'Updated leaf'),
          key: (comment) => comment.id,
          children: (comment) => comment.replies,
          update: (comment) => comment.copyWith(modifiedAt: DateTime.now()),
          updateChildren: (parent, newReplies) =>
              parent.copyWith(replies: newReplies),
        );
        stopwatch.stop();

        expect(result.length, 2);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(20),
        ); // Should handle deep nesting
      });
    });

    group('Boundary Conditions', () {
      test('should handle very large merge operations', () {
        final list1 = List.generate(
          500,
          (i) => _TestScore(userId: i, points: i * 10),
        );
        final list2 = List.generate(
          500,
          (i) => _TestScore(userId: i + 250, points: (i + 250) * 15),
        );

        final result = list1.merge(
          list2,
          key: (score) => score.userId,
          compare: (a, b) => b.points.compareTo(a.points),
        );

        expect(result.length, 750); // 500 original + 250 new (250 overlaps)
        expect(
          result.first.points,
          greaterThan(result.last.points),
        ); // Sorted correctly
      });

      test('should handle identical references correctly', () {
        const user = _TestUser(id: '1', name: 'Alice');
        final list = [user];

        final result = list.upsert(user, key: (u) => u.id);

        expect(result.length, 1);
        expect(identical(result.first, user), true); // Should be same instance
      });

      test('should handle extreme nesting in removeNested', () {
        // Create a linear chain of 100 nested comments
        _TestComment createChain(int depth) {
          if (depth == 0) {
            return const _TestComment(id: 'target', text: 'Target comment');
          }
          return _TestComment(
            id: 'level_$depth',
            text: 'Level $depth',
            replies: [createChain(depth - 1)],
          );
        }

        final deepStructure = [createChain(100)];

        final stopwatch = Stopwatch()..start();
        final result = deepStructure.removeNested(
          (comment) => comment.id == 'target',
          children: (comment) => comment.replies,
          updateChildren: (parent, newReplies) => parent.copyWith(
            replies: newReplies,
            modifiedAt: DateTime.now(),
          ),
        );
        stopwatch.stop();

        expect(result.length, 1);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(50),
        ); // Should handle deep nesting
      });
    });

    group('Concurrent Usage Simulation', () {
      test('should maintain immutability under simulated concurrent access',
          () {
        final baseList = [
          const _TestUser(id: '1', name: 'Alice'),
          const _TestUser(id: '2', name: 'Bob'),
        ];

        // Simulate multiple "concurrent" operations
        final results = List.generate(10, (i) {
          return baseList.upsert(
            _TestUser(id: '${i + 3}', name: 'User ${i + 3}'),
            key: (user) => user.id,
          );
        });

        // All operations should have same base + 1 new user
        for (final result in results) {
          expect(result.length, 3);
          expect(result.first.name, 'Alice'); // Base data unchanged
          expect(result[1].name, 'Bob'); // Base data unchanged
        }

        // Base list should remain unchanged
        expect(baseList.length, 2);
      });

      test('should handle rapid state changes in nested structures', () {
        final comments = [
          const _TestComment(
            id: '1',
            text: 'Main thread',
            replies: [
              _TestComment(id: '2', text: 'Reply 1', upvotes: 5),
              _TestComment(id: '3', text: 'Reply 2', upvotes: 3),
            ],
          ),
        ];

        // Simulate rapid upvote changes
        var currentState = comments;
        for (var i = 0; i < 10; i++) {
          currentState = currentState.updateNested(
            _TestComment(id: '2', text: 'Reply 1', upvotes: 5 + i),
            key: (comment) => comment.id,
            children: (comment) => comment.replies,
            update: (comment) => comment.copyWith(modifiedAt: DateTime.now()),
            updateChildren: (parent, newReplies) =>
                parent.copyWith(replies: newReplies),
          );
        }

        expect(currentState.first.replies.first.upvotes, 14); // 5 + 9
        expect(comments.first.replies.first.upvotes, 5); // Original unchanged
      });
    });

    group('Error Handling and Robustness', () {
      test('should handle empty key results gracefully', () {
        final items = [
          const _TestItemWithNullable(id: '', value: 'Empty ID'),
          const _TestItemWithNullable(id: '1', value: 'Normal'),
        ];

        final result = items.upsert(
          const _TestItemWithNullable(id: '', value: 'Updated Empty'),
          key: (item) => item.id,
        );

        expect(result.length, 2);
        expect(result.first.value, 'Updated Empty');
      });

      test('should handle complex key extraction', () {
        final activities = [
          const _TestActivity(id: 'act1', authorId: 'user1', content: 'Hello'),
          const _TestActivity(id: 'act2', authorId: 'user1', content: 'World'),
        ];

        // Use composite key (authorId + first word of content)
        final result = activities.upsert(
          const _TestActivity(
            id: 'act3',
            authorId: 'user1',
            content: 'Hello Updated',
          ),
          key: (activity) =>
              '${activity.authorId}_${activity.content.split(' ').first}',
        );

        expect(result.length, 2); // Should replace 'Hello' activity
        expect(result.first.content, 'Hello Updated');
        expect(result.last.content, 'World');
      });
    });
  });

  group('Production Feed Scenarios', () {
    group('Activity Feed Operations', () {
      test('should handle real-time activity updates in sorted feed', () {
        // Simulate a typical activity feed sorted by creation time (newest first)
        final activities = [
          _TestFeedActivity(
            id: 'act_3',
            userId: 'user1',
            content: 'Just posted a photo',
            timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
            likes: 5,
          ),
          _TestFeedActivity(
            id: 'act_2',
            userId: 'user2',
            content: 'Having a great day!',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            likes: 12,
          ),
          _TestFeedActivity(
            id: 'act_1',
            userId: 'user3',
            content: 'Good morning everyone',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            likes: 8,
          ),
        ];

        // New activity comes in
        final newActivity = _TestFeedActivity(
          id: 'act_4',
          userId: 'user1',
          content: 'Live streaming now!',
          timestamp: DateTime.now(),
          likes: 0,
        );

        final result = activities.sortedInsert(
          newActivity,
          compare: (a, b) => b.timestamp.compareTo(a.timestamp), // Newest first
        );

        expect(result.length, 4);
        expect(result.first.id, 'act_4'); // New activity should be first
        expect(result.first.content, 'Live streaming now!');
      });
    });
  });
}

// region Test Models

/// Test model representing a user with ID and name.
class _TestUser extends Equatable {
  const _TestUser({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// Test model representing a score with user ID and points.
class _TestScore extends Equatable {
  const _TestScore({required this.userId, required this.points});

  final int userId;
  final int points;

  @override
  List<Object?> get props => [userId, points];
}

/// Test model representing an activity with various properties.
class _TestActivity extends Equatable {
  const _TestActivity({
    required this.id,
    required this.authorId,
    required this.content,
  });

  final String id;
  final String authorId;
  final String content;

  @override
  List<Object?> get props => [id, authorId, content];
}

/// Test model representing a comment with nested replies structure.
class _TestComment extends Equatable {
  const _TestComment({
    required this.id,
    required this.text,
    this.upvotes = 0,
    this.replies = const [],
    this.modifiedAt,
  });

  final String id;
  final String text;
  final int upvotes;
  final List<_TestComment> replies;
  final DateTime? modifiedAt;

  _TestComment copyWith({
    String? id,
    String? text,
    int? upvotes,
    List<_TestComment>? replies,
    DateTime? modifiedAt,
  }) {
    return _TestComment(
      id: id ?? this.id,
      text: text ?? this.text,
      upvotes: upvotes ?? this.upvotes,
      replies: replies ?? this.replies,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  @override
  List<Object?> get props => [id, text, upvotes, replies, modifiedAt];
}

/// Test model representing an item with nullable value.
class _TestItemWithNullable extends Equatable {
  const _TestItemWithNullable({required this.id, this.value});

  final String id;
  final String? value;

  @override
  List<Object?> get props => [id, value];
}

/// Test model representing a feed activity with engagement metrics.
class _TestFeedActivity extends Equatable {
  const _TestFeedActivity({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    this.likes = 0,
  });

  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final int likes;

  @override
  List<Object?> get props => [id, userId, content, timestamp, likes];
}

// endregion
