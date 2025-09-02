import 'dart:async';

import 'package:equatable/equatable.dart';

/// A discriminated union that encapsulates a successful outcome with a value of type [T]
/// or a failure with an arbitrary [Object] error.
sealed class Result<T> extends Equatable {
  const Result._();

  const factory Result.success(T value) = Success._;

  const factory Result.failure(
    Object error, [
    StackTrace? stackTrace,
  ]) = Failure._;

  /// Returns `true` if this instance represents a successful outcome.
  /// In this case [isFailure] returns `false`.
  bool get isSuccess => this is Success<T>;

  /// Returns `true` if this instance represents a failed outcome.
  /// In this case [isSuccess] returns `false`.
  bool get isFailure => this is Failure;
}

/// Represents successful result.
class Success<T> extends Result<T> {
  const Success._(this.data) : super._();

  /// The [T] data associated with the result.
  final T data;

  @override
  List<Object?> get props => [data];

  @override
  String toString() => 'Result.Success{data: $data}';
}

/// Represents failed result.
class Failure extends Result<Never> {
  const Failure._(this.error, [this.stackTrace]) : super._();

  /// The [error] associated with the result.
  final Object error;

  /// The [stackTrace] associated with the result.
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [error, stackTrace];

  @override
  String toString() => 'Result.Failure{error: $error, stackTrace: $stackTrace}';
}

extension PatternMatching<T> on Result<T> {
  /// Returns the encapsulated value if this instance represents [Success] or `null`
  /// if it is [Failure].
  ///
  /// This function is a shorthand for `getOrElse(() => null)` or
  /// `fold(onSuccess: (it) => it, onFailure: (_) => null)`.
  T? getOrNull() {
    return switch (this) {
      Success<T>(:final data) => data,
      Failure() => null,
    };
  }

  /// Returns the encapsulated [Object] error if this instance represents [Failure] or `null`
  /// if it is [Success].
  ///
  /// This function is a shorthand for `fold(onSuccess: (_) => null, onFailure: (error) => error)`.
  Object? exceptionOrNull() {
    return switch (this) {
      Success<T>() => null,
      Failure(:final error) => error,
    };
  }

  /// Returns the encapsulated [StackTrace] if this instance represents [Failure] or `null`
  /// if it is [Success].
  StackTrace? stackTraceOrNull() {
    return switch (this) {
      Success<T>() => null,
      Failure(:final stackTrace) => stackTrace,
    };
  }

  /// Returns the encapsulated value if this instance represents [Success] or throws the encapsulated error
  /// if it is [Failure].
  ///
  /// This function is a shorthand for `getOrElse((error) => throw error)`.
  T getOrThrow() {
    return switch (this) {
      Success<T>(:final data) => data,
      Failure(:final error, :final stackTrace) =>
        Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current),
    };
  }

  /// Returns the encapsulated value if this instance represents [Success] or the
  /// result of [onFailure] function for the encapsulated error if it is [Failure].
  ///
  /// Note, that this function rethrows any error thrown by [onFailure] function.
  ///
  /// This function is a shorthand for `fold(onSuccess: (it) => it, onFailure: onFailure)`.
  R getOrElse<R>(R Function(Object error, StackTrace? stackTrace) onFailure) {
    return switch (this) {
      Success<T>(:final data) => data as R,
      Failure(:final error, :final stackTrace) => onFailure(error, stackTrace),
    };
  }

  /// Returns the encapsulated value if this instance represents [Success] or the
  /// [defaultValue] if it is [Failure].
  ///
  /// This function is a shorthand for `getOrElse((_) => defaultValue)`.
  R getOrDefault<R>(R defaultValue) {
    return switch (this) {
      Success<T>(:final data) => data as R,
      Failure() => defaultValue,
    };
  }

  /// Returns the result of [onSuccess] for the encapsulated value if this instance represents [Success]
  /// or the result of [onFailure] function for the encapsulated error if it is [Failure].
  ///
  /// Note, that this function rethrows any error thrown by [onSuccess] or by [onFailure] function.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Object error, StackTrace? stackTrace) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Failure(:final error, :final stackTrace) => onFailure(error, stackTrace),
    };
  }

  /// Returns the encapsulated result of the given [transform] function applied to the encapsulated value
  /// if this instance represents [Success] or the original encapsulated error if it is [Failure].
  ///
  /// Note, that this function rethrows any error thrown by [transform] function.
  /// See [mapCatching] for an alternative that encapsulates errors.
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(:final data) => Result.success(transform(data)),
      final Failure f => f,
    };
  }

  /// Asynchronously returns the encapsulated result of the given [transform] function applied to the encapsulated value
  /// if this instance represents [Success] or the original encapsulated error if it is [Failure].
  ///
  /// Note, that this function rethrows any error thrown by [transform] function.
  /// See [mapCatching] for an alternative that encapsulates errors.
  Future<Result<R>> mapAsync<R>(Future<R> Function(T value) transform) {
    return switch (this) {
      Success<T>(:final data) => runSafely(() => transform(data)),
      final Failure f => Future.value(f),
    };
  }

  /// Returns the encapsulated result of the given [transform] function applied to the encapsulated value
  /// if this instance represents [Success] or the original encapsulated error if it is [Failure].
  ///
  /// This function catches any error thrown by [transform] function and encapsulates it as a failure.
  /// See [map] for an alternative that rethrows errors from [transform] function.
  Result<R> mapCatching<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(:final data) => runSafelySync(() => transform(data)),
      final Failure f => f,
    };
  }

  /// Returns the encapsulated result of the given [transform] function applied to the encapsulated error
  /// if this instance represents [Failure] or the original encapsulated value if it is [Success].
  ///
  /// Note, that this function rethrows any error thrown by [transform] function.
  /// See [recoverCatching] for an alternative that encapsulates errors.
  Result<R> recover<R>(
    R Function(Object error, StackTrace? stackTrace) transform,
  ) {
    return switch (this) {
      Success<T>(:final data) => Result.success(data as R),
      Failure(:final error, :final stackTrace) => Result.success(
          transform(error, stackTrace),
        ),
    };
  }

  /// Returns the encapsulated result of the given [transform] function applied to the encapsulated error
  /// if this instance represents [Failure] or the original encapsulated value if it is [Success].
  ///
  /// This function catches any error thrown by [transform] function and encapsulates it as a failure.
  /// See [recover] for an alternative that rethrows errors.
  Result<R> recoverCatching<R>(
    R Function(Object error, StackTrace? stackTrace) transform,
  ) {
    return switch (this) {
      Success<T>(:final data) => Result.success(data as R),
      Failure(:final error, :final stackTrace) => runSafelySync(
          () => transform(error, stackTrace),
        ),
    };
  }

  /// Performs the given [action] on the encapsulated error if this instance represents [Failure].
  /// Returns the original [Result] unchanged.
  Result<T> onFailure(
    void Function(Object error, StackTrace? stackTrace) action,
  ) {
    if (this case Failure(:final error, :final stackTrace)) {
      action(error, stackTrace);
    }
    return this;
  }

  /// Performs the given [action] on the encapsulated value if this instance represents [Success].
  /// Returns the original [Result] unchanged.
  Result<T> onSuccess(void Function(T value) action) {
    if (this case Success<T>(:final data)) {
      action(data);
    }
    return this;
  }

  /// Flattens a nested [Result] of [Result] to a single [Result].
  /// Only works when [T] is of type [Result<R>].
  Result<R> flatten<R>() {
    if (this case Success<Result<R>>(:final data)) {
      return data;
    }
    return this as Result<R>;
  }

  /// Transforms this [Result<T>] to [Result<R>] by applying [transform] if this is a [Success],
  /// or returns the [Failure] unchanged if this is a [Failure].
  ///
  /// This is similar to [map] but the [transform] function returns a [Result<R>] instead of [R].
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    return switch (this) {
      Success<T>(:final data) => transform(data),
      final Failure f => f,
    };
  }

  /// Asynchronously transforms this [Result<T>] to [Result<R>] by applying [transform] if this is a [Success],
  /// or returns the [Failure] unchanged if this is a [Failure].
  ///
  /// This is similar to [flatMap] but the [transform] function returns a [Future<Result<R>>] instead of [Result<R>].
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T value) transform,
  ) {
    return switch (this) {
      Success<T>(:final data) => transform(data),
      final Failure f => Future.value(f),
    };
  }
}

/// Runs a block of code and returns a [Result] containing the outcome.
///
/// If the block completes successfully, the result is a success with the value
/// returned by the block. Otherwise, if an exception is thrown, it is caught
/// and wrapped in a failure result.
Future<Result<R>> runSafely<R>(FutureOr<R> Function() block) async {
  try {
    final result = await block();
    return Result.success(result);
  } catch (e, stackTrace) {
    return Result.failure(e, stackTrace);
  }
}

/// Runs a block of code and returns a [Result] containing the outcome.
///
/// If the block completes successfully, the result is a success with the value
/// returned by the block. Otherwise, if an exception is thrown, it is caught
/// and wrapped in a failure result.
Result<R> runSafelySync<R>(R Function() block) {
  try {
    final result = block();
    return Result.success(result);
  } catch (e, stackTrace) {
    return Result.failure(e, stackTrace);
  }
}
