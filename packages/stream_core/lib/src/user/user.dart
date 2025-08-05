//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import 'package:meta/meta.dart';

/// Model for the user's info.
@immutable
class User {
  /// Creates a user with the provided id.
  const User({
    required this.id,
    String? name,
    this.imageUrl,
    this.role = 'user',
    this.type = UserAuthType.regular,
    Map<String, dynamic>? customData,
  })  : originalName = name,
        customData = customData ?? const {};

  /// Creates a guest user with the provided id.
  /// - Parameter userId: the id of the user.
  /// - Returns: a guest `User`.
  const User.guest(String userId)
      : this(id: userId, name: userId, type: UserAuthType.guest);

  /// Creates an anonymous user.
  /// - Returns: an anonymous `User`.
  const User.anonymous() : this(id: '!anon', type: UserAuthType.anonymous);

  /// The user's id.
  final String id;

  /// The user's image URL.
  final String? imageUrl;

  /// The user's role.
  final String role;

  /// The user authorization type.
  final UserAuthType type;

  /// The user's custom data.
  final Map<String, dynamic> customData;

  /// User's name that was provided when the object was created. It will be used when communicating
  /// with the API and in cases where it doesn't make sense to override `null` values with the
  /// `non-null` id.
  final String? originalName;

  /// A computed property that can be used for UI elements where you need to display user's identifier.
  /// If a `name` value was provided on initialisation it will return it. Otherwise returns the `id`.
  String get name => originalName ?? id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.imageUrl == imageUrl &&
        other.role == role &&
        other.type == type &&
        other.originalName == originalName &&
        _mapEquals(other.customData, customData);
  }

  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      imageUrl,
      role,
      type,
      originalName,
      Object.hashAll(customData.entries),
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, imageURL: $imageUrl, role: $role, type: $type, customData: $customData)';
  }
}

/// The user authorization type.
enum UserAuthType {
  /// A regular user.
  regular,

  /// An anonymous user.
  anonymous,

  /// A guest user.
  guest,
}
