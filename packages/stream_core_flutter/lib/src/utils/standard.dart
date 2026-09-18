/// A set of standard extension methods for any [Object] type.
extension Standard<T extends Object> on T {
  /// Calls the specified function [block] with `this` value as its argument
  /// and returns its result.
  @pragma('vm:prefer-inline')
  R let<R>(R Function(T it) block) {
    return block(this);
  }

  /// Calls the specified function [block] with `this` value as its argument
  /// and returns `this` value.
  @pragma('vm:prefer-inline')
  T also(void Function(T it) block) {
    block(this);
    return this;
  }

  /// Calls the specified function [block] with `this` value as its receiver
  /// and returns `this` value.
  @pragma('vm:prefer-inline')
  T apply(void Function(T it) block) {
    block(this);
    return this;
  }

  /// Returns `this` value if it satisfies the given [predicate] or `null`,
  /// if it doesn't.
  @pragma('vm:prefer-inline')
  T? takeIf(bool Function(T it) predicate) {
    return predicate(this) ? this : null;
  }

  /// Returns `this` value if it satisfies the given [predicate] or `null`,
  /// if it doesn't.
  @pragma('vm:prefer-inline')
  T? takeUnless(bool Function(T it) predicate) {
    return !predicate(this) ? this : null;
  }
}

/// Executes the given function [action] specified number of [times].
///
/// A zero-based index of current iteration is passed as a parameter to the [action] function.
///
/// If the [times] parameter is negative or equal to zero, the [action] function is not invoked.
@pragma('vm:prefer-inline')
void repeat(int times, void Function(int) action) {
  for (var i = 0; i < times; i++) {
    action(i);
  }
}
