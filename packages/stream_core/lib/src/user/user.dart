//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Model for the user's info.
@immutable
class User extends Equatable {
  /// Creates a user with the provided id.
  const User({
    required this.id,
    String? name,
    this.image,
    this.role = 'user',
    this.type = UserType.regular,
    Map<String, Object?>? custom,
  }) : originalName = name,
       custom = custom ?? const {};

  /// Creates a guest user with the provided id.
  /// - Parameter userId: the id of the user.
  /// - Returns: a guest `User`.
  const User.guest(String userId) : this(id: userId, name: userId, type: UserType.guest);

  /// Creates an anonymous user.
  /// - Returns: an anonymous `User`.
  const User.anonymous() : this(id: '!anon', type: UserType.anonymous);

  /// The user's id.
  final String id;

  /// The user's image URL.
  final String? image;

  /// The user's role.
  final String role;

  /// The user authorization type.
  final UserType type;

  /// The user's custom data.
  final Map<String, Object?> custom;

  /// User's name that was provided when the object was created. It will be used when communicating
  /// with the API and in cases where it doesn't make sense to override `null` values with the
  /// `non-null` id.
  final String? originalName;

  /// A computed property that can be used for UI elements where you need to display user's identifier.
  /// If a `name` value was provided on initialisation it will return it. Otherwise returns the `id`.
  String get name => originalName ?? id;

  @override
  List<Object?> get props => [
    id,
    image,
    role,
    type,
    originalName,
    custom,
  ];
}

/// The user authorization type.
enum UserType {
  /// A regular user.
  regular,

  /// An anonymous user.
  anonymous,

  /// A guest user.
  guest,
}
